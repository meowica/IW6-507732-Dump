#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

#include maps\ship_graveyard_util;

intro_track_player_gunfire()
{
	level endon( "start_small_wreck" );
	
	while( 1 )
	{
		level.player waittill( "weapon_fired" );
		
		if ( level.deadly_sharks.size > 0 )
		{
			wait( 0.5 );
			level.deadly_sharks = array_removeDead( level.deadly_sharks );
			level.deadly_sharks = array_removeUndefined( level.deadly_sharks );
			sharks = SortByDistance( level.deadly_sharks, level.player.origin );
			foreach ( s in sharks )
			{
				if ( level.player player_looking_at( s.origin, 0.8 ) && Distance( s.origin, level.player.origin ) < 800 )
				{
					s shark_kill_player();
					wait( 1 );
					break;
				}
			}
		}
		wait( 0.05 );
	}
}

tutorial_player_recover()
{
	ent = get_target_ent("tutorial_dive_player_anim");
	
	level.player_rig = maps\_player_rig::get_player_rig();
	level.player_rig.origin = level.player.origin;
	level.player_rig.angles = level.player.angles;
	
	player_swim_offset = (0,0,48);
	
	dummy = spawn_tag_origin();
	dummy.origin = level.player_rig.origin;
	dummy.angles = level.player_rig.angles;
	dummy linkTo( level.player_rig, "tag_player", player_swim_offset, (0,0,0) );
	
	legs = spawn( "script_model", (0,0,0) );
	legs setModel( "body_seal_udt_dive_a" );
	legs.animname = "legs";
	legs setAnimTree();
	
	level.player PlayerLinkToAbsolute( dummy, "tag_player");
	
	PlayFXOnTag(getfx ("dive_in_bubbles_hand"), level.player_rig, "j_wrist_le");
	PlayFXOnTag(getfx ("dive_in_bubbles_hand"), level.player_rig, "j_wrist_ri");
	PlayFXOnTag(getfx ("dive_in_bubbles_feet"), legs, "J_Ankle_LE");
	PlayFXOnTag(getfx ("dive_in_bubbles_feet"), legs, "J_Ankle_RI");
	
	exploder( "dive_in" );
		
	ent anim_single( [ level.player_rig, legs ], "below_water_tutorial_dive" );
	
	level.player unlink();
	level.player_rig delete();
	legs delete();
	
//	rig = maps\_player_rig::get_player_rig();
//	rig HIde();
//	
//	{
//		org = get_target_ent( "tutorial_player_start" );
//		rig.origin = org.origin;
//		rig.angles = org.angles;
//		level.player disableWeapons();
//		level.player PlayerLinkToAbsolute( rig, "tag_origin" );
//		level.player delayCAll( 1, ::PlayerLinkTo, rig, "tag_origin", 1, 20, 20, 20, 20 );
//		
//		org = org get_target_ent();
//		rig moveTo_rotateTo( org, 4.5, 0, 0 );
//		org = org get_target_ent();
//		rig moveTo_rotateTo( org, 3.6, 0, 1 );
//	}
	level.player enableWeapons();
	level.player GiveMaxAmmo( "aps_underwater+swim" );
	
//	level.player unlink();
//	rig delete();
	
	if ( !greenlight_check())
	{
		wait( 2 );
		thread track_hint_down();
		thread display_hint_timeout( "hint_down", 4 );
	}
	trigger_Wait_targetname( "exit_tiny_cave" );
	
	autosave_by_name_silent( "intro" );
	
	smart_radio_dialogue( "shipg_bkr_thisway" );	
	delaythread( 0.5, ::smart_radio_dialogue, "shipg_bkr_5klicks" );
	
	trigger_Wait_targetname( "tutorial_hint_up" );
}

intro_dialgue()
{
/*	wait( 5 );
	smart_radio_dialogue( "shipg_orb_increasedactivity" );
	wait( 0.2 );
	smart_radio_dialogue( "shipg_bkr_handleit" );*/
}

baker_path_to_wreck()
{
	node = get_target_ent( "baker_start_path" );
	wait( 1 );
	level.baker follow_path_and_animate( node );
	flag_set( "baker_at_wreck" );
}

/* ************ * 
 * WRECK REVEAL *
 * ************ */

#using_animtree( "generic_human" );

wreck_reveal_spotted( zodiac )
{
	level endon( "entering_small_wreck" );
	flag_wait( "_stealth_spotted" );
	level.baker.ignoreall = false;
	node = getNode( "baker_wreck_approach_spotted", "script_noteworthy" );
	level.baker setGoalNode( node );
	flag_set( "_stealth_spotted_punishment" );
	thread smart_radio_dialogue_interrupt( "shipg_bkr_ontous" );
	wait( 1 );
	array_spawn_targetname( "wreck_reveal_backup" );
	flag_clear( "_stealth_spotted_punishment" );
	wait( 1 );
	thread smart_radio_dialogue( "shipg_bkr_droppingin" );
	thread wreck_reveal_spotted_ai_swarm();
	wait( 3 );
	
	level waittill( "never" ); // removing boat shooting for now, until we get better dialogue
		
	zodiac thread boat_shoot_entity( level.player, "entering_small_wreck" );
	trig = get_target_ent( "wreck_approach_dam_trig" );
	while( 1 )
	{
		trig waittill( "trigger", triggerer );
		if ( triggerer == level.player )
			break;
	}
	zodiac notify( "stop_shooting" );
	anime = %ship_graveyard_boat_death_A;
	spawner = get_target_ent( "wreck_approach_boat_shooter" );
	guy = spawner spawn_ai( true );
	guy.origin = ( spawner.origin[0], spawner.origin[1], level.water_level_z + 5 );
	waitframe();
//	guy.deathanim = anime;
	time = getAnimLength( anime );
	org = get_target_ent( "wreck_approach_boat_shooter_fx" );
	
	guy thread magic_bullet_shield();
	guy.forceRagdollImmediate = true;
	guy.skipDeathAnim  = true;
	playFXONTag( getfx( "underwater_object_trail" ), guy, "tag_origin" );	
	spawner thread anim_generic( guy, "death_boat_A" );
	wait( 1.5 );
	PlayFX( getfx( "jump_into_water_splash" ), org.origin );
	thread play_sound_in_space( "enemy_water_splash", org.origin );
	spawner waittill( "death_boat_A" );
	
	mover = guy spawn_tag_origin();
	guy linkTo( mover, "tag_origin" );

	weapon_model = getWeaponModel( guy.weapon );
	weapon = guy.weapon;
	if ( isdefined( weapon_model ) )
	{
		//self waittill_match_or_timeout( "deathanim", "end", 4 );
		guy detach( weapon_model, "tag_weapon_right" );
		org = guy gettagorigin( "tag_weapon_right" );
		ang = guy gettagangles( "tag_weapon_right" );
		gun = Spawn( "script_model", ( 0, 0, 0 ) );
		gun setModel( weapon_model );
		gun.angles = ang;
		gun.origin = org;
		gun PhysicsLaunchClient( gun.origin, (0,0,0) );
	}
	
	mover thread anim_generic_loop( guy, "death_boat_A_loop" );
	
	trace = BulletTrace( guy.origin - (0,0,200), guy.origin - (0,0,6000), false, guy );
	endpos = trace["position"];
	endpos = ( endpos[0], endpos[1], endpos[2] + 50 );
	mover moveTo_speed( endpos, 100, 0, 0 );
	guy stop_magic_bullet_shield();
	guy startragdoll();
	guy unlink();
	mover notify( "stop_loop" );
	wait( 0.1 );
	mover delete();
	wait( 0.5 );
	stopFXONTag( getfx( "underwater_object_trail" ), guy, "tag_origin" );
	guy kill();
}

wreck_reveal_spotted_ai_swarm()
{
	ai = getAiArray( "axis" );
	while( ai.size > 0 )
	{
		if ( ai.size <= 3 )
		{
			ai = SortByDistance( ai, level.player.origin );
			
			farthest = ai[ ai.size-1 ];
			farthest ai_go_to_player();
			
			ai = getAiArray( "axis" );
		}
		else
		{
			wait( 0.05 );
		}
	}
}

ai_go_to_player()
{
	self endon( "death" );
	self.goalradius = 300;
	self setGoalEntity( level.player );
	self waittill( "death" );
}

sonar_ping(soundnum)
{
	tag = self spawn_tag_origin();
	tag linkTo( self, "tag_origin", ( 0, 0, -80 ), ( 0, 0, 0 ) );
	PlayFXOnTag( getfx( "sonar_ping_light" ), tag, "tag_origin" );
	PlayFXOnTag( getfx( "sonar_ping_distortion" ), tag, "tag_origin" );
	wait( 0.1 );
	//play a sound based on which sonar ping it is - concatenate the number onto the end of the string, then play that string
	if ( isdefined ( soundnum ) )
	{
		alias_to_play = "";
		alias_to_play = ( "sonar_ping_dist_" + soundnum );		
		self play_sound_on_entity( alias_to_play );
		
	}
	else
	{
		//play the most distant one
		self play_sound_on_entity( "sonar_ping_dist_01" );
	}
	
	
	tag delete();
}

wreck_zodiac_event()
{
	level.zodiac_b = spawn_vehicle_from_targetname( "wreck_zodiac" );
	zodiac_b = level.zodiac_b;
	
	zodiac = spawn_vehicle_from_targetname( "wreck_zodiac_dropoff" );

	flag_wait( "start_small_wreck" );
	
	thread wreck_reveal_spotted( zodiac );
	
	flag_wait( "approaching_wreck" );
	array_spawn_targetname( "a1_patrol_2" );
	
	//zodiac thread gopath();

	zodiac Vehicle_TurnEngineOff();
	zodiac_b Vehicle_TurnEngineOff();
	zodiac thread play_sound_on_entity( "scn_shipg_sm_wreck_zod1" );
	zodiac_b thread play_sound_on_entity( "scn_shipg_sm_wreck_zod2" );
	zodiac_b thread gopath();
	thread zodiac_arrive( zodiac );
	

	flag_wait( "baker_at_wreck" );
	wait( 1 );
	flag_wait( "drop_off_guys" );
	maps\ship_Graveyard_fx::trigger_fish_school( "fish_school_wreck_approach", "start" );
	
	thread sardines_path_sound_no_trigger( "fish_school_wreck_approach", "scn_fish_swim_away_wreck" );

	wait( 0.5 );
	zodiac thread sonar_ping("04");	
	wait( 1.5 );
	array_spawn_targetname( "a1_patrol_1" );
	/*
	wait( 3 );
	newnode = get_Target_ent( "wreck_dropoff_2_exit" );
	zodiac thread zodiac_wake( zodiac.wake_org );
	zodiac.target = "wreck_dropoff_2_exit";
	zodiac thread maps\_vehicle::getonpath();
	zodiac waittill( "reached_end_node" );
	*/
	thread too_close_to_guys();
	thread too_close_to_boat();
}

zodiac_arrive( zodiac )
{
	zodiac notify( "newpath" );
	zodiac.animname = "missile_boat";
	node = get_Target_Ent( "wreck_approach_boat_arrival");
	node anim_single_solo( zodiac, "missile_boat_arrive" );
	flag_Set( "drop_off_guys" );
	zodiac notify( "reached_end_node" );
	node thread anim_loop_solo( zodiac, "missile_boat_idle" );
}

too_close_to_guys()
{
	level endon( "wreck_approach_guys_dead" );
	level endon( "_stealth_spotted" );
	trigger_wait_Targetname( "wreck_approach_too_close" );
	enemies = getaiarray( "axis" );
	enemies = Sortbydistance( enemies, level.player.origin );
	closest = enemies[0];
	closest setGoalPos( level.player.origin );
}

too_close_to_boat()
{
	level endon( "clear_to_enter_cave" );
	level endon( "_stealth_spotted" );
	trigger_wait_Targetname( "wreck_approach_close_to_boat" );
	enemies = getaiarray( "axis" );
	enemies = Sortbydistance( enemies, level.player.origin );
	flag_set( "_stealth_spotted" );
	closest = enemies[0];
	closest setGoalPos( level.player.origin );
}

baker_approach()
{
	level endon( "_stealth_spotted" );
	
	level.zodiac_b delayThread( 0, ::sonar_ping, "01" );
	
	wait( 1.4 );
	level.baker.ignoreall = true;
	smart_radio_dialogue( "shipg_bkr_enemysonar" );
	thread display_hint( "hint_flashlight" );
	wait (0.3);
	level.zodiac_b delayThread( 0, ::sonar_ping, "02" );	
	wait( 0.6 );
	smart_radio_dialogue( "shipg_bkr_easy" );
	wait( 1.0 );
	level.zodiac_b delayThread( 0, ::sonar_ping, "03" );
	wait( 0.7 );
	smart_radio_dialogue( "shipg_bkr_hugtheground" );
	//wait( 0.1 );
	smart_radio_dialogue( "shipg_bkr_maskoursig" );
	
	flag_wait( "approaching_wreck" );
	
	flag_wait( "baker_at_wreck" );
	wait( 0.8 );
	smart_radio_dialogue( "shipg_bkr_holdup" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_boatpatrol" );
	autosave_stealth_silent();
	level.baker dyn_swimspeed_disable();
	
	flag_wait( "drop_off_guys" );
	
	level endon( "wreck_approach_guys_dead" );
	
	wait( 2.7 );
	smart_radio_dialogue( "shipg_bkr_gotcompany" );
	wait( 0.8 );
	smart_radio_dialogue( "shipg_bkr_themseparate" );
	wait( 1.6 );
	smart_radio_dialogue( "shipg_bkr_ok" );
	wait( 0.5 );
	thread smart_radio_dialogue( "shipg_bkr_staylow" );
	wait( 0.5 );
	autosave_stealth_silent();
	level.baker follow_path_and_animate( get_target_ent( "baker_approach_wreck" ) );
	
	baker_glint_off();
		
	level.baker delayThread( 2, ::set_ignoreall, false );
	smart_radio_dialogue( "shipg_bkr_inposition" );
//	wait( 0.3 );
//	smart_radio_dialogue( "shipg_bkr_onyourgo" );
	wait( 0.9 );
	smart_radio_dialogue( "shipg_bkr_aseffective" );
	wait( 1.2 );
	smart_radio_dialogue( "shipg_bkr_weaponsfree" );
}

baker_wreck_cleanup()
{
	level endon( "start_stealth_area_1" );
	flag_wait( "drop_off_guys" );
	delaythread( 5, ::paired_death_wait_flag, "wreck_approach_guys_dead" );
	flag_wait( "wreck_approach_guys_dead" );
	wait( 0.7 );
	flag_waitopen( "_stealth_spotted" );
	level endon( "_stealth_spotted" );
	
	baker_glint_on();
	
	baker_noncombat();
	smart_radio_dialogue_interrupt( "shipg_bkr_nicelydone" );
	
	flag_set( "clear_to_enter_wreck" );
	level.baker thread dyn_swimspeed_enable();
	smart_radio_dialogue( "shipg_hsh_letsmovethruthe" );
	wait( 0.3 );
	smart_radio_dialogue( "shipg_bkr_distancefromboat" );
	wait( 0.3 );
	smart_radio_dialogue( "shipg_bkr_moreattention" );
}

a1_patrol_1_setup()
{
	self endon( "death" );
	self endon( "_stealth_spotted" );
	if ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "jumper" )
		self waittill( "done_jumping_in" );
	else
	{
		self thread paired_death_think( level.baker );
		self teleport_to_target();
		return;
	}
	org = self get_target_ent();
	org = org get_target_ent();
	
	if ( isdefined( self.script_parameters ) && issubstr( self.script_parameters, "deleteme" ) )
	{
		if ( self ent_flag( "_stealth_spotted" ) )
			return;
	
		self.goalradius = 64;
		self.goalheight = 64;
		self follow_path_and_animate( org, 0 );
		wait( 3 );
		if ( !level.player player_looking_at( self.origin, 0.7 ) )
			self delete();
	}
	else
	{
		self thread paired_death_think( level.baker );
		if ( self ent_flag( "_stealth_spotted" ) )
			return;
		self stealth_idle_reach( org );
	}
}

/* *********** *
 * SMALL WRECK *
 * *********** */

baker_wait_in_front_of_wreck()
{
	if ( flag( "player_close_to_small_wreck" ) )
		return;
	
	level endon( "player_close_to_small_wreck" );
	
	while( !flag( "player_close_to_small_wreck" ) )
	{
		level.baker waittill_player_lookat_for_time( 0.5, 0.8 );
		if ( Distance( level.player.origin, level.baker.origin ) < 250 )
			break;
		wait( 0.1 );
	}
}

baker_enter_wreck()
{
	level endon ("stop_for_e3");
	
	flag_wait_either( "clear_to_enter_wreck", "player_close_to_small_wreck" );
	
	if ( flag( "_stealth_spotted" ) )
		return;
	level endon( "_stealth_spotted" );
	
	thread baker_wreck_dialogue();
	
	level.baker pushplayer( true );
	
	node = get_target_ent( "friendly_follow_2" );
	level.baker setGoalPos( node.origin );
	level.baker.ignoreall = true;
	
	baker_wait_in_front_of_wreck();
	
	node = node get_Target_ent();
	level.baker follow_path_and_animate( node );
	
	org = get_target_ent( "baker_small_wreck_cover_l" );
	org anim_generic_reach( level.baker, "swimming_aiming_move_to_cover_l1" );
	flag_set( "baker_at_small_wreck" );
	
	animated = false;
	if ( !flag( "sdv_passed" ) && !flag( "salvage_baloon_goes" ) )
	{
		animated = true;
		org anim_generic( level.baker, "swimming_aiming_move_to_cover_l1" );
		org.origin = level.baker.origin;
		org.angles = level.baker.angles;
		level.baker.my_animnode = org;
		org thread anim_generic_loop( level.baker, "swimming_cover_l1_idle" );
		flag_wait( "sdv_passed" );
		level.baker disable_Exits();
		org notify( "stop_loop" );
		level.baker thread dyn_swimspeed_disable();
		org thread anim_generic_run( level.baker, "swimming_cover_l1_exit_r180" );
	}
	
	level.baker thread follow_path_and_animate( get_target_ent( "friendly_follow_3" ), 250 );
	
	if ( animated )
	{
		org waittill( "swimming_cover_l1_exit_r180" );
		wait( 0.1 );
		level.baker enable_Exits();
	}
}

baker_wreck_dialogue() 
{
	level endon ("stop_for_e3");
	
	if ( flag( "_stealth_spotted" ) )
		return;
	level endon( "_stealth_spotted" );
	
	flag_wait( "small_wreck_sdv_spawned" );
	flag_wait_or_timeout( "baker_at_small_wreck", 1 );
	wait( 0.2 );
	smart_radio_dialogue( "shipg_bkr_slowdown" );
	wait( 1.5 );
	if ( !flag( "sdv_passed" ) )
	{		
		thread smart_radio_dialogue( "shipg_bkr_stayyydownstaydown" );
		flag_wait( "sdv_passed" );
	}
	
	thread greenlight_skip();
	
	if ( !flag ( "salvage_baloon_goes" ) )
	{
		wait( 0.2 );
		thread smart_radio_dialogue_interrupt( "shipg_bkr_salvaging" );
	}
}



wreck_hint_up()
{
	if ( flag( "_stealth_spotted" ) || level.start_point == "e3")
		return;
	level endon( "_stealth_spotted" );
	
	flag_wait( "clear_to_enter_wreck" );
	level endon( "entering_small_wreck" );
	trigger_wait_targetname( "trigger_hint_up" );
	thread track_hint_up();
	display_hint_timeout( "hint_up", 4 );
}

wreck_spotted_reaction()
{
	level endon( "start_stealth_area_1" );
	level endon ("stop_for_e3");
	
	flag_wait( "_stealth_spotted" );
	thread smart_radio_dialogue_interrupt( "shipg_bkr_ontous" );
	
	level.baker StopAnimScripted();
	level.baker notify( "stop_loop" );
	if ( isdefined( level.baker.my_animnode ) )
		level.baker.my_animnode notify( "stop_loop" );
	flag_waitopen( "_stealth_spotted" );
	flag_set( "move_to_stealth_1" );
	smart_radio_dialogue( "shipg_bkr_areaclear" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_bkr_onme" );
}

sdv_follow_spotted_react()
{
	self endon( "death" );
	wait( 5 );
	flag_wait( "_stealth_spotted" );
	self vehicle_unload();
}

wreck_cargo_surprise()
{
	level endon( "_stealth_spotted" );
	level endon ("stop_for_e3");
		
	cargo = get_target_ent( "baloon_rise_1" );
	flag_wait( "entering_small_wreck" );
	delaythread( 3, ::play_sound_in_space, "balloon_inflate", cargo.origin );
	noself_delayCall( 3, ::PlayFx, getfx( "bubble_burst_large" ), cargo.origin - (0,32,32) );
	
	flag_wait( "salvage_baloon_goes" );
	musicstop( 4 );
	delaythread( 1.15, ::smart_radio_dialogue, "shipg_bkr_hold2" );
	guy = spawn_targetname( "baloon_guy" );
	guy setGoalPos( guy.origin );

	guy thread melee_on_spotted();
	
	guy.ignoreme = true;
	guy.moveplaybackrate = 0.75;
	guy.moveTransitionRate = guy.moveplaybackrate;
	thread play_sound_in_space( "scn_shipg_balloon_inflate", cargo.origin );	
	noself_delayCall( 0.15, ::PlayFx, getfx( "bubble_burst_large" ), cargo.origin - (0,32,32) );	
	cargo thread salvage_cargo_rise( 38 );
	
	/*
	secret_shark = Spawn_anim_model( "shark", cargo.origin );
	secret_shark Hide();
	secret_shark thread delete_on_notify( "start_stealth_area_1" );
	level.deadly_sharks = array_add( level.deadly_sharks, secret_shark );
	thread shark_moment( guy );
	*/
	wait( 1 );
	org = guy get_target_ent();
	guy.goalradius = 32;
	guy.goalheight = 32;
	guy ForceTeleport( org.origin, org.angles );
	org = org get_target_ent();
	guy thread follow_path_and_animate( org, 0 );
	
	level.baker.oldbaseaccuracy = level.baker.baseaccuracy;
	guy thread baker_quip_on_death();
	guy thread delete_on_path_end();
	guy thread flag_on_death( "move_to_stealth_1" );
	guy.health = 1;
	guy endon( "death" );
	guy waittill_notify_or_timeout( "kill_me", 16.5 );
	flag_set( "move_to_stealth_1" );
//	guy.ignoreAll = false;
//	level.baker.baseaccuracy = 9999;
//	guy.dontattackme = undefined;
}

melee_on_spotted()
{
	self endon( "death" );
	self ent_flag_wait( "_stealth_spotted" );
	self enemy_attempt_melee();
}

shark_moment( guy )
{
	node = get_Target_ent( "shark_attack_1_node" );
	shark = Spawn_anim_model( "shark", (0,0,0) );
	level.deadly_sharks = array_add( level.deadly_sharks, shark );
	guy.animname = "generic";
	thread shark_attack_fx( guy, shark );
	node anim_single( [ guy, shark ], "shark_moment" );
	guy delete();
	shark delete();
	flag_set( "move_to_stealth_1" );
}

shark_attack_fx( guy, shark )
{
	wait( 8.9 );
	flag_Set( "no_shark_heartbeat" );
	thread play_sound_in_space( "scn_shark_bite_flesh", guy getTagOrigin( "j_knee_ri" ) );
	PlayFX( getfx( "swim_ai_blood_impact" ), guy getTagOrigin( "j_knee_ri" ) );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), guy, "j_knee_ri" );
	delaythread( 0.5, ::play_sound_in_space, "scn_shark_bite_flesh", guy getTagOrigin( "j_knee_ri" ) );
	delaythread( 0.9, ::play_sound_in_space, "scn_shark_bite_flesh", guy getTagOrigin( "j_knee_ri" ) );
	delaythread( 1.6, ::play_sound_in_space, "scn_shark_bite_flesh", guy getTagOrigin( "j_knee_ri" ) );
}

transition_to_stealth_1()
{
	level endon( "start_stealth_area_1" );
	level endon ("stop_for_e3");
		
	flag_Wait( "move_to_stealth_1" );
	flag_waitopen( "_stealth_spotted" );
	
	thread transition_to_stealth_1_glint_off();	
	
	level.baker thread follow_path_and_animate( get_target_ent( "baker_stealth_1_path" ) );
	
	autosave_stealth();
}

transition_to_stealth_1_glint_off()
{
	baker_glint_on();
	
	node = getnode("trans1_eop", "script_noteworthy");
	node waittill ("trigger");
	
	baker_glint_off();
}

baker_quip_on_death()
{
	level endon( "start_stealth_area_1" );
	msg = self waittill_any_return( "death", "kill_me" );
	if ( !greenlight_check() )
	{
		level.baker.baseaccuracy = level.baker.oldbaseaccuracy;
		if ( isdefined( self ) )
			wait( 1.5 );
		smart_radio_dialogue( "shipg_bkr_closecall" );
		wait( 0.7 );
		thread smart_radio_dialogue( "shipg_bkr_thisway" );
		wait( 0.5 );
		baker_noncombat();
	}
	flag_set( "move_to_stealth_1" );
}

delete_on_path_end()
{
	self waittill( "path_end_reached" );
	looking = level.player player_looking_at( self.origin, 0.6 );
	if ( !looking )
	{
		self delete();
	}
	else
	{
		self notify( "kill_me" );
	}
	flag_set( "move_to_stealth_1" );
}

/* *********** *
 *  STEALTH 1  *
 * *********** */

stealth_1_zodiac_setup()
{
	if ( !isdefined( level.stealth_1_zodiac_sounds ) )
	{
		level.stealth_1_zodiac_sounds = [ "scn_shipg_stealth_1_zod1", "scn_shipg_stealth_1_zod2" ];
		level.stealth_1_zodiac_soundIndex = 0;
	}
	
	self Vehicle_TurnEngineOff();
	self thread play_sound_on_entity( level.stealth_1_zodiac_sounds[ level.stealth_1_zodiac_soundIndex ] );
	level.stealth_1_zodiac_soundIndex += 1;
}

stealth_1_encounter()
{
	level.baker.ignoreall = true;
	guys = array_spawn_targetname( "stealth_1_guys" );
	array_thread( guys, ::teleport_to_target );
//	riser = spawn_targetname( "stealth_1_riser" );
//	guys = array_add( guys, riser );
	flag_wait( "stealth_1_engage" );
//	org = riser get_target_ent();
//	riser thread teleport_to_target();
	wait( 1 );
	level.baker.ignoreall = false;
	jumper = spawn_targetname( "stealth_1_jumper" );
	guys = array_add( guys, jumper );
	
	level endon( "start_stealth_area_2" );
	
	while( GetAIArray( "axis" ).size > 0 )
		wait( 0.05 );
	
	level notify( "stealth_1_done" );
	wait( 1 );
	baker_noncombat();
	smart_radio_dialogue( "shipg_bkr_clear" );
	thread baker_move_to_stealth_2();
	thread move_to_stealth_2_dialogue();
}

sdv_follow_2_passby_audio()
{
	self play_sound_on_entity("scn_shipg_sub_by_01");
}

sdv_stealth_2_sub_1_passby_audio()
{
	self play_sound_on_entity("scn_shipg_sub_by_02");
}

baker_move_to_stealth_2()
{
	baker_glint_on();
	thread stealth_2_light_off();
	
	setSavedDvar( "player_swimSpeed", 85 );
	level.baker.pathrandompercent = 0;
	level.baker.goalradius = 128;
	level.baker.moveplaybackrate = 1.15;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker thread dyn_swimspeed_enable( 100 );
	level.baker.ignoreall = true;
	level.baker follow_path_and_animate( get_target_ent( "baker_stealth_2_path" ) );
	level.baker.ignoreall = false;
	level.baker dyn_swimspeed_disable();
	setSavedDvar( "player_swimSpeed", 75 );
	
	baker_glint_off();
}

stealth_2_light_off()
{
	node = getstruct("rounding_corner", "script_noteworthy");
	node waittill ("trigger");
	baker_glint_off();
}

move_to_stealth_2_dialogue()
{
	wait( 0.5 );
	smart_radio_dialogue( "shipg_bkr_moveup" );
	wait( 5.5 );
	smart_radio_dialogue( "shipg_bkr_rallypoint" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_orb_doubletimeit" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_hsh_rogerthat" );
}
	
stealth_1_dialogue()
{
	flag_wait( "move_to_stealth_1" );
	if ( flag( "_stealth_spotted" ) )
		return;
	wait( 4 );
	//thread music_play( "mus_shipgrave_ambient2" );
	smart_radio_dialogue( "shipg_hsh_shittheyrealreadyhere" );
	wait( 0.8 );
	thread smart_radio_dialogue( "shipg_hsh_neptunewehavecontact" );
	wait( 0.7 );
	thread smart_radio_dialogue( "shipg_hsh_nosignofthe" );
	wait( 0.6 );
	smart_radio_dialogue( "shipg_pri_bastardsdontwasteany" );
	flag_wait( "stealth_1_engage" );
	thread stealth_1_dialogue_kickoff();
	if ( flag( "_stealth_spotted" ) )
		return;
	level endon( "_stealth_spotted" );
//	smart_radio_dialogue( "shipg_bkr_moretangos" );
	wait( 2.5 );
	smart_radio_dialogue( "shipg_bkr_count4" );
	wait( 1.5 );
	smart_radio_dialogue( "shipg_bkr_takeemout" );
/*	smart_radio_dialogue( "shipg_bkr_guysupfront" );
	wait( 0.7 );
	smart_radio_dialogue( "shipg_bkr_nolineofsight" );
	wait( 2.3 );
	trigger = get_target_ent( "stealth_1_vantage" );
	if ( !level.player isTouching( trigger ) )
	{
		smart_radio_dialogue( "shipg_bkr_beworth" );
		wait( 2.3 );
		trigger thread vantage_nag();
	}
	trigger waittill( "trigger" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_shotontangos" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_taketheshot" );*/
}

vantage_nag()
{
	level endon( "stealth_1_done" );
	level endon( "_stealth_spotted" );
	self endon( "trigger" );
	wait( 5 );
	smart_radio_dialogue( "shipg_bkr_outoftime" );
	wait( 0.7 );
	smart_radio_dialogue( "shipg_bkr_bettervantage" );
}

stealth_1_dialogue_kickoff()
{
	level endon( "stealth_1_done" );
	flag_Wait( "_stealth_spotted" );
	smart_radio_dialogue_interrupt( "shipg_bkr_weaponsfree2" );
}

/* *********** *
 *  STEALTH 2  *
 * *********** */
 
stealth_2_encounter()
{
	thread stealth_2_other_guys();
	guys = array_spawn_targetname( "stealth_2_guys" );
	wait( 0.5 );

	thread stealth_2_movement();
	
	while( GetAIArray( "axis" ).size > 0 )
		wait( 0.05 );
	
	flag_set( "clear_to_enter_cave" );
	
	wait( 2 );
	baker_noncombat();
	smart_radio_dialogue( "shipg_bkr_areaclear" );
	wait( 0.75 );
	smart_radio_dialogue( "shipg_bkr_onme" );
	
	flag_set ("to_cave_vo_begin");
}

stealth_2_other_guys()
{
	trigger = get_Target_Ent( "stealth_2_other_guys" );
	trigger waittill( "trigger" );
	guys = array_spawn_targetname( trigger.target );
	level endon( "_stealth_spotted" );
	if ( !flag( "_stealth_spotted" ) )
	{
		wait( 1 );
		array_thread( guys, ::set_moveplaybackrate, 0.8 );
	}

}

stealth_2_dialogue()
{
	level endon( "clear_to_enter_cave" );
	level endon( "_stealth_spotted" );
	if ( flag( "_stealth_spotted" ) )
		return;
	thread stealth_2_spotted();	

	trigger_wait_targetname( "stealth_2_contact" );
	
	thread music_play("mus_shipgrave_plane_stinger");	

	smart_radio_dialogue( "shipg_bkr_contact" );
	wait( 0.8 );
	smart_radio_dialogue( "shipg_hsh_looksliketheygot" );
	wait( 2 );
	smart_radio_dialogue( "shipg_bkr_flankthem" );
	wait( 5 );
	autosave_stealth();
	smart_radio_dialogue( "shipg_bkr_weaponsfree" );
}

stealth_2_spotted()
{
	level endon( "clear_to_enter_cave" );
	flag_wait( "_stealth_spotted" );

	delaythread( 7, ::try_to_melee_player, "clear_to_enter_cave" );
	thread delay_drop_boat();
	
	delaythread( 3, ::smart_radio_dialogue_interrupt, "shipg_bkr_knowwerehere" );
	array_spawn_targetname( "stealth_2_backup" );
	
	while( GetAIArray( "axis" ).size > 2 )
		wait( 0.05 );
	
	enemies = getAIArray( "axis" );
	array_call( enemies, ::setGoalEntity, level.player );
	array_thread( enemies, ::find_best_cover );
}

find_best_cover()
{
	self endon( "death" );
	
	self.favoriteenemy = level.player;
	wait ( RandomFloatRange( 4, 8 ) );
	node = self FindBestCoverNode();
	if ( isdefined( node ) )
	{
		self.goalradius = 32;
		self.goalheight = 96;
		self setGoalNode( node );
		self waittill( "goal" );
		self.goalradius = 800;
	}
}

stealth_2_movement()
{
	level endon( "clear_to_enter_cave" );
	flag_wait( "_stealth_spotted" );
	volume_waittill_no_axis( "stealth_2_area_1_volume", 1 );
	
	level.baker follow_path_and_animate( get_target_ent( "stealth_2_moveup_1" ) );
}

delay_drop_boat()
{
	wait ( RandomFloatRange( 4, 7 ) );
	
	if ( !flag( "clear_to_enter_cave" ) )
		array_notify( level.middle_boat.balloons, "pop" );
}

stealth_2_middle_boat_think()
{
	
	boat = get_target_ent( "stealth_2_middle_boat" );
	level.middle_boat = boat;
		
	linked = boat get_linked_ents();
	array_call( linked, ::linkTo, boat );
	
	foreach ( l in linked )
	{
		if ( l.classname == "script_brushmodel" )
		{
			linked = l;
			break;
		}
	}
	
	balloons = [];
	goal = undefined;
	
	ents = getentarray( boat.target, "targetname" );
	foreach ( e in ents )
	{
		if ( e.script_parameters == "balloon" )
			balloons = array_add( balloons, e );
		else if ( e.script_parameters == "target_pos" )
			goal = e;
	}
	
	level.middle_boat.balloons = balloons;
	
	flag_wait( "start_stealth_area_2" );
	
	array_thread( balloons, ::middle_boat_balloon_think , balloons );

	level waittill( "middle_boat_pop" );
	
	if ( !flag( "_stealth_spotted" ) )
	{
		ai = getAIArray( "axis" );
		foreach ( a in ai )
			a.favoriteenemy = level.player;
	}
	boat thread play_sound_on_entity( "scn_middle_airliner_fall" );
	linked ConnectPaths();
	boat moveTo_rotateTo( goal, 5, 3, 0 );
	Earthquake( 0.5, 1.0, boat.origin, 3000 );
	//boat thread play_sound_on_entity( "middle_boat_crash" );

	//org = get_target_ent( "stealth_2_boat_fx" );
	//PlayFX( getfx( "boat_fall_impact" ), org.origin, (0,0,1), org.origin - level.player.origin );
	
	exploder( "plane_wreck_impact" );
	
	linked DisConnectPaths();
}

middle_boat_balloon_think( balloons )
{
	self setCanDamage( true );
	msg = self waittill_any_return( "damage", "pop" );
	
	array_notify( balloons, "pop" );
	
	if ( isdefined( msg ) && msg != "damage" )
		wait( RandomFloatRange( 0.2, 0.4 ) );
	
	PlayFX( getfx( "shpg_underwater_bubble_explo" ), self.origin );
	//thread play_sound_in_space( "underwater_balloon_pop", self.origin );
	level notify( "middle_boat_pop" );
	waitframe();
	self delete();
	
}

/* **** *
 * CAVE *
 * **** */
 
cave_flashlight_logic()
{
	while( 1 )
	{
		flag_wait( "flashlight_on" );
		level.player notify( "toggle_flashlight_on" );
		flag_waitopen( "flashlight_on" );
		level.player notify( "toggle_flashlight_off" );
	}
}
 
sonar_approach()
{
	level endon( "start_sonar" );
	level.baker endon( "start_weld" );
	baker_noncombat();
	node = get_target_ent( "baker_cave_path" );
	level.baker setGoalPos( node.origin );
		
	baker_glint_on();
	
	while( !flag( "inside_cave" ) )
	{
		level.baker waittill_player_lookat_for_time( 0.5, 0.8 );
		if ( Distance( level.player.origin, level.baker.origin ) < 250 )
			break;
		wait( 0.1 );
	}
	node = node get_Target_ent();
	
	level.baker thread waittill_goal_and_set_flag_to_cave();
	
	level.baker follow_path_and_animate( node );
	level.baker.goalradius = 196;
	
	level.baker follow_path_and_animate( get_Target_ent( "baker_cave_path_2" ), 150 );
	level.baker.goalradius = 256;
	
}

waittill_goal_and_set_flag_to_cave()
{
	self waittill ("goal");
	flag_set("go_into_cave_vo");
}

cave_dialogue()
{
	flag_wait ("to_cave_vo_begin");
	
	wait 2;
	smart_radio_dialogue( "shipg_hsh_looksliketheresan" );
	
	wait 2;
	flag_wait("go_into_cave_vo");
	
	smart_radio_dialogue( "shipg_hsh_okcheckyourregulator" );
	
	wait 2;
	flag_wait( "inside_cave" );
	smart_radio_dialogue( "shipg_hsh_alrightweregoingfurther" );
	
	thread cave_dialogue_2();
	level endon( "stop_cave_dialogue_1" );
	wait( 3 );
	/*
	smart_radio_dialogue( "shipg_bkr_rallypoint" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_orb_doubletimeit" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_hsh_rogerthat" );
	*/
}

cave_dialogue_2()
{
	level endon( "player_ready_to_weld" );
	trigger_wait_targetname( "sonat_boat_cave_spawn" );
	level notify( "stop_cave_dialogue_1" );
	wait( 1.5 );
	smart_radio_dialogue( "shipg_bkr_theresheis" );
	wait( 1.5 );
	smart_radio_dialogue( "shipg_bkr_movingtoengage" );
	wait( 3 );
	smart_radio_dialogue( "shipg_orb_heavysonarblasts" );
	smart_radio_dialogue( "shipg_orb_waterpressure" );
	smart_radio_dialogue( "shipg_orb_proceedwithcaution" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_bkr_wilco" );
	wait( 1 );
	smart_radio_dialogue( "shipg_hsh_aintnowaywe" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_hsh_weregonnahaveto" );
}

cave_dust()
{
	flag_Wait( "cave_sonar" );
	level endon( "stop_cave_dust" );
	
	volume = get_Target_ent( "cave_volume" );
	shake_source = get_Target_ent( "cave_shake_origin" );
	origins = getstructarray_delete( "cave_shake_source", "targetname" );
	
	while( 1 )
	{
		flag_wait( "cave_sonar" );
		wait( RandomFloatRange( 1,3 ) );

		if ( !level.player istouching( volume ) )
			continue;
		
		strength = RandomFloatRange( 0.3, 0.5 );
	
		level notify( "sonar_ping_go" );
		thread play_sound_in_space( "weaponized_sonar_muffled", shake_source.origin );
		level.player PlayRumbleOnEntity( "damage_light" );
		cave_shake( strength, origins );
		
		wait( RandomFloatRange( 3,6 ) );
	}
}

cave_shake( strength, origins, oneshot_soundalias )
{
	origins = SortByDistance( origins, level.player.origin );
	times = 0;
	
	wait( 0.2 );
	
	Earthquake( strength, RandomFloatRange( 0.5, 1 ), level.player.origin, 1024 );
	
	if ( isdefined( oneshot_soundalias ) && origins.size > 0 )
		thread play_sound_in_space( oneshot_soundalias, origins[0].origin );
	
	foreach ( org in origins )
	{
		if ( within_fov_2d( level.player.origin, level.player.angles, org.origin, 0.6 ) )
		if ( cointoss() )
		{
			if ( !isdefined( org.script_fxid ) )
				org.script_fxid = "cave_ceiling_silt_knockoff";
			_delay = RandomFloatRange(0,2.5);
			delaythread( _delay, ::play_sound_in_space, "cave_debris", org.origin );
			noself_delayCall(  _delay, ::PlayFX, getfx( org.script_fxid ), org.origin );
			times += 1;
		}

		if ( times > 5 )
		{
			break;
		}
	}
}

sonar_boat_cave_think()
{
	wait( 3 );
	flag_clear( "cave_sonar" );
	wait( 10 );
	flag_set( "cave_sonar" );
}

sonar_boat_cave_quake()
{
	level.sonar_boat = self;
	
	quake_dist_slider = spawn_tag_origin();
	quake_dist_slider.origin = (0,0,1024);
	
	rumble_ent = self spawn_tag_origin();
	org = self spawn_tag_origin();
	level.sonar_quake_org = org;
	org thread boat_quake( quake_dist_slider );
	org linkTo( self );
	rumble_ent linkTo( self );
	rumble_ent PlayRumbleLoopOnEntity( "littoral_ship_rumble" );
	
	trigger_wait_Targetname( "cave_past_hole" );
	quake_dist_slider moveTo( (0,0,300), 3 );
	rumble_ent moveTo( rumble_ent.origin + (0,0,2000), 4 );
	
	flag_wait( "start_sonar" );
	waittillframeend;
	flag_wait( "welding_done" );
	org unlink();
	org moveTo( level.sonar_boat.origin, 2 );
	rumble_ent moveTo( level.sonar_boat.origin, 3 );
	rumble_ent waittill( "movedone" );
	org linkTo( level.sonar_boat );
	rumble_ent linkTo( level.sonar_boat );
		
	
	quake_dist_slider moveTo( (0,0,1200), 6 );
	level.sonar_boat waittill( "death" );
	org delete();
	rumble_ent StopRumble( "littoral_ship_rumble" );
	rumble_ent delete();
}

boat_quake( dist_slider )
{
	self endon( "death" );
	
	while( 1 )
	{
		Earthquake( 0.3, 0.2, self.origin, dist_slider.origin[2] );
		wait( 0.1 );
	}
}

/* ***** *
 * SONAR *
 * ***** */
 
baker_weld_door()
{
	trigger = get_target_ent( "weld_use_trigger" );
	trigger trigger_off();
	trigger setHintString( &"SHIP_GRAVEYARD_HINT_WELD" );
	
	node = get_target_ent( "baker_weld_node_final" );
	door_L = get_target_ent( "baker_weld_door_L" );
	door_L.animname = "door_L";
	door_L setAnimTree();
	weld_door_setup( door_L );
	
	door_R = get_target_ent( "baker_weld_door_R" );
	door_R.animname = "door_R";
	door_R setAnimTree();
	weld_door_setup( door_R );
	
	door_L_top = spawn( "script_model", door_L.origin );
	door_L_top.origin = door_L.origin;
	door_L_top.angles = door_L.angles;
	door_L_top setModel( "shpg_wrkdoor_a1_normal" );
	door_L_top linkTo( door_L );
	
	pipe = spawn_anim_model( "pipe" );
	
	node anim_first_frame( [ door_L, door_R, pipe ], "weld_approach" );
	
	flag_wait( "inside_cave" );
	
	num_barrels = 16;
	barrels = [];
	for ( i=0; i<num_barrels; i++ )
	{
		b = spawn( "script_model", (0,0,0) );
		b setModel( "com_barrel_benzin2" );
		b.animname = "barrel";
		b setAnimTree();
		b.animname = "barrel_" + i;
		barrels = array_add( barrels, b );
	}
	
	node anim_first_frame( barrels, "weld_breach" );
	
	flag_wait( "start_sonar" );
	
	level.baker notify( "start_weld" );
	level.baker notify( "stop_path" );
	
	trigger trigger_on();
	
	node anim_reach_solo( level.baker, "weld_approach" );
	
	rig = maps\_player_rig::get_player_rig();
	rig Hide();

	rig DontCastShadows();
	
	dummy = spawn_tag_origin();
	dummy.origin = rig.origin;
	dummy.angles = rig.angles;
	
	door_L_obj = spawn( "script_model", door_L.origin );
	door_L_obj.angles = door_L.angles;
	door_L_obj setModel( door_L.model + "_obj" );
	door_L_obj Hide();
	door_L_obj linkto( door_L );
	
	torch_f = spawn_anim_model( "torch_f", (0,0,0) );
	torch_p = spawn_anim_model( "torch_p", (0,0,0) );
	
	fxorg = spawn_tag_origin();
	fxorg linkTo( torch_p, "j_gun", (8,0,0), (0,0,0) );
	level.player.torch_fx_org = fxorg;
	
	fxorg2 = spawn_tag_origin();
	fxorg2 linkTo( torch_f, "j_gun", (8,0,0), (0,0,0) );	
	level.baker.torch_fx_org = fxorg;
	
	fxorg thread maps\ship_graveyard_fx::weld_breach_fx( torch_p );
	fxorg2 thread maps\ship_graveyard_fx::weld_breach_fx( torch_f );
	
	delayThread( 1, ::player_approach_weld, node, rig, dummy, door_L, door_L_obj, torch_p );
	
	if (!greenlight_check())
		node anim_single( [ level.baker, door_R, door_L, torch_f, pipe ], "weld_approach" );
	else
	{
		baker_anim = level.baker getanim("weld_approach");
		door_R_anim = door_R getanim("weld_approach");
		door_L_anim = door_L getanim("weld_approach");
		torch_f_anim = torch_f getanim("weld_approach");
		pipe_anim = pipe getanim("weld_approach");
		
		jump_to = 0.17;
		node thread anim_single( [ level.baker, door_R, door_L, torch_f, pipe ], "weld_approach" );
		anim_time = GetAnimLength(baker_anim);
		
		wait 0.5;
		
		level.baker SetAnimTime( baker_anim, jump_to );
		door_R SetAnimTime( door_R_anim, jump_to );
		door_L SetAnimTime( door_L_anim, jump_to );
		torch_f SetAnimTime( torch_f_anim, jump_to );
		pipe SetAnimTime( pipe_anim, jump_to );
		
		wait (anim_time * (1-jump_to));
	}
	
	
	flag_set( "ai_ready_to_weld" );
	node thread anim_loop( [ level.baker, torch_f ], "weld_breach_idle" );
	waitframe();
	
	flag_wait( "player_ready_to_weld" );
	
	waitframe();
	
	node notify( "stop_loop" );
	
	delayThread( 6.5, ::exploder, "barrel_collapse_dust" );
	//thread music_play( "mus_shipgrave_tension" );
	
	node thread anim_single( barrels, "weld_breach" );
	node thread anim_single_solo_run( level.baker, "weld_breach" );
	path = get_target_ent( "baker_path_after_weld" );
	level.baker.goalradius = 96;
	level.baker setGoalPos( path.origin );
	level.baker disable_exits();
	door_L_top thread door_L_modelswap( door_L );
	node anim_single( [ door_R, door_L, rig, torch_p, torch_f ], "weld_breach" );
	//level.baker delayThread( 0.3, ::enable_exits );
	flag_set( "welding_done" );
	
	level.player unlink();
	rig delete();
	dummy delete();
	
	torch_f delete();
	torch_p delete();
	
	fxorg delete();
	fxorg2 delete();
	
	level.player EnableWeapons();
	thread smart_radio_dialogue( "shipg_bkr_thisway" );
	autosave_by_name( "sonar" );
	
	flag_wait( "start_new_trench" );
	foreach ( b in door_L.brushes )
		b delete();
	foreach ( b in door_R.brushes )
		b delete();
	door_L delete();
	door_R delete();
	foreach ( b in barrels ) 
		b delete();
	barrels = undefined;
	
	door_L_top delete();
	
	pipe delete();
}

door_L_modelswap( doorL )
{
	doorL waittillmatch( "single anim", "door_cut_1" );
	self setModel( "shpg_wrkdoor_a1_broken01" );
	doorL waittillmatch( "single anim", "door_cut_2" );
	self setModel( "shpg_wrkdoor_a1_broken02" );
}

player_approach_weld( node, rig, dummy, door_L, door_L_obj, torch_p )
{
	trigger = get_target_ent( "weld_use_trigger" );
	
	door_L_obj show();
	
	node anim_first_frame( [ rig ], "weld_approach" );
	
	trigger waittill( "trigger" );
	trigger delete();
	
	door_L_obj delete();
	
	player_swim_offset = (0,0,48);

	dummy linkTo( rig, "tag_player", player_swim_offset, (0,0,0) );

	level.player DisableWeapons();
	level.player PlayerLinkToBlend( dummy, "tag_origin", 1, 0.1, 0 );
	
	rig delayCall( 1, ::Show );
	
	thread open_up_player_view_during_weld( dummy );
	
	node anim_single( [ rig, torch_p ], "weld_approach" );
	flag_set( "player_ready_to_weld" );
	
	if ( !flag( "ai_ready_to_weld" ) )
	{
		node thread anim_loop( [ rig, torch_p ], "weld_breach_idle" );
		flag_wait( "ai_ready_to_weld" );
		rig notify( "stop_loop" );
		torch_p notify( "stop_loop" );
	}
	
}

open_up_player_view_during_weld( dummy )
{ 
	//wait 3.15;
	level waittill ("script 87");
	
	level.player PlayerLinkToDelta( dummy, "tag_origin", 1, 0, 0, 0, true ); 
   
	time = 4;
    level.player LerpViewAngleClamp( time, time * 0.5, time * 0.5, 25, 15, 30, 15 );
    
    flag_wait( "ai_ready_to_weld" );
    flag_wait( "player_ready_to_weld" );
    wait 10.1;
    
    level.player PlayerLinkToBlend( dummy, "tag_origin", 1, 0.5, 0 );
}

weld_door_setup( door )
{
	brushes = door get_linked_ents();
	door.brushes = brushes;
	array_call( brushes, ::linkTo, door );
}

first_sonar_ping()
{
	flag_wait( "welding_done" );
	thread weaponized_sonar_chargeup();
	
	flag_wait( "super_sonar_ping" );
	
	level notify( "sonar_ping_go" );
	thread play_sound_in_space( "weaponized_sonar_near", level.sonar_boat.origin );
	wait( 0.2 );
	exploder( 1 );
	wait( 0.3 );
	
	noself_delayCall( 0.1, ::Earthquake, 0.3, 1, level.player.origin, 512 );
	
	level.player delayCall( 0.1, ::PlayRumbleOnEntity, "damage_light" );
//	level.player delayCall( 0.2, ::PlayRumbleOnEntity, "damage_light" );
	level.player delayCall( 0.3, ::PlayRumbleOnEntity, "damage_light" );
//	level.player delayCall( 0.4, ::PlayRumbleOnEntity, "damage_light" );
	level.player delayCall( 0.5, ::PlayRumbleOnEntity, "damage_light" );
	level.player delayCall( 0.6, ::PlayRumbleOnEntity, "damage_light" );
	level.player delayCall( 0.7, ::PlayRumbleOnEntity, "damage_light" );
	
	wait( 1 );
	level.sonar_boat Vehicle_setSpeed( 6, 3, 1 );
	level.sonar_boat delayCall( 6, ::Vehicle_setSpeed, 1, 1, 1 );
	tag = level.player spawn_Tag_origin();
	tag.angles = level.player getPlayerAngles();
	thread baker_sonar_path_dialogue();
	thread baker_sonar_path();
	old = getDvarInt( "player_swimSpeed" );
//	setSavedDvar( "player_swimSpeed", 10 );
	Earthquake( 0.7, 1, level.player.origin, 512 );
//	level.player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
	fwd = 30*( AnglesToForward( level.player.angles ) );
//	level.player ViewKick( 0.1, level.player.origin + fwd );
	level.player DisableWeapons();
	level.player AllowSprint( false );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	level.player delayCall( 0.1, ::PlayRumbleOnEntity, "damage_heavy" );
	level.player delayCall( 0.2, ::PlayRumbleOnEntity, "damage_heavy" );
	level.player delayCall( 0.3, ::PlayRumbleOnEntity, "damage_light" );
	level.player delayCall( 0.4, ::PlayRumbleOnEntity, "damage_light" );
	level.player delayCall( 0.5, ::PlayRumbleOnEntity, "damage_light" );
	level.player delayCall( 0.6, ::PlayRumbleOnEntity, "damage_light" );
//	level.player PlayerlinkToBlend( tag, "Tag_origin", 1, 0, 1 );
	level.player ShellShock( "sonar_ping", 5 );
	level.player DoDamage( 90, level.player.origin );
	level.player delayCall( 2, ::unlink );
	wait( 2 );
//	setSavedDvar( "player_swimSpeed", old );
	wait( 2 );
//	level.player thread maps\_swim_player::shellshock_forever();
	level.player EnableWeapons();
	wait( 1 );
	level.player AllowSprint( true );
	thread track_hint_sprint();
	
	if ( !greenlight_check() )
		thread display_hint_timeout( "hint_sprint", 4 );
	
	flag_set( "start_sonar_pings" );
}

baker_sonar_path()
{
	level.baker disable_exits();
	level.baker anim_generic_run( level.baker, "sonar_hit" );
	level.baker delayThread( 0.5, ::enable_exits );
	level.baker.goalradius = 128;
	thread baker_sonar_speed_change();
	level.baker.movetransitionrate = 1.7;
	level.baker follow_path_and_animate( get_target_ent( "sonar_path_1" ), 450 );
	
	flag_init( "sonar_baker_waiting" );
	node = get_target_ent( "sonar_wait_at_container" );
	level.sonar_node = node;
	node anim_generic_reach( level.baker, "swimming_aiming_move_to_cover_l1_r90" );
	thread baker_wait_at_container();

	flag_wait( "sonar_clear_to_go" );
	wait( 2.5 );
	
	level.baker.moveplaybackrate = 1.7;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	
	flag_Wait( "sonar_baker_waiting" );
	level.sonar_node notify( "stop_loop" );
	level.baker disable_exits();
	level.sonar_node thread anim_generic_run( level.baker, "swimming_cover_l1_to_aiming_move_l90" );
	level.baker follow_path_and_animate( get_target_ent( "sonar_path_3" ), 450 );
	level.baker enable_exits();
	flag_wait( "sonar_clear_to_go" );
	wait( 1 );
	thread smart_radio_dialogue( "shipg_hsh_intothatlighthouse" );
	level.baker follow_path_and_animate( get_target_ent( "sonar_path_4" ), 450 );
	level.baker follow_path_and_animate( get_target_ent( "sonar_path_5" ), 450 );
	level.sonar_node = undefined;
}

baker_wait_at_container()
{
	level.sonar_node anim_generic( level.baker, "swimming_aiming_move_to_cover_l1_r90" );
	level.sonar_node.origin = level.baker.origin;
	level.sonar_node.angles = level.baker.angles;
	level.sonar_node thread anim_generic_loop( level.baker, "swimming_cover_l1_idle" );
	flag_set( "sonar_baker_waiting" );
}

baker_sonar_path_dialogue()
{
	smart_radio_dialogue_interrupt( "shipg_bkr_pain2" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_gettocover" );
	wait( 5 );

	if ( player_safe_from_sonar() )
		autosave_by_name( "sonar" );
	
	smart_radio_dialogue( "shipg_bkr_cannotengage" );
	wait( 0.7 );
	smart_radio_dialogue( "shipg_orb_pulloutimmediately" );
	wait( 0.3 );
	smart_radio_dialogue( "shipg_bkr_missionistoast" );
	
	setSavedDvar( "player_swimSpeed", 90 );
	setSavedDvar( "player_sprintUnlimited", "1" );
}

baker_sonar_speed_change()
{
	level.baker.moveplaybackrate = 1.7;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker waittill( "goal" );
	wait( 5.5 );
	level.baker.moveplaybackrate = 1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
}

weaponized_sonar_chargeup()
{
	thread play_sound_in_space( "weaponized_sonar_chargeup", level.sonar_boat.origin );
	wait( 1.8 );
}

weaponized_sonar_pings()
{
	flag_wait( "start_sonar_pings" );
	level.sonar_exploder = 1;
	level.sonar_times_hit = 0;
	level.sonar_ping_delay = 8;
	
	shock_delay = 1.9;
	
	array_thread( getentarray( "sonar_fire_trigger", "targetname" ), ::sonar_fire_trigger_think );
	array_thread( getentarray( "sonar_safe_trigger", "targetname" ), ::sonar_safe_trigger_think );
	level.sonar_boat endon( "death" );
	level endon( "mine_moveup" );
	wait (1);
	while( 1 )
	{
		level waittill_notify_or_timeout( "weaponized_ping", level.sonar_ping_delay );
		flag_waitopen( "pause_sonar_pings" );
		weaponized_sonar_chargeup();
		wait( 0.75 );
		level notify( "sonar_ping_go" );
		exploder( level.sonar_exploder );
		thread play_sound_in_space( "weaponized_sonar_near", level.sonar_boat.origin );		
		wait shock_delay;		
		flag_set( "sonar_clear_to_go" );
		delayThread( 1, ::flag_clear, "sonar_clear_to_go" );							
		thread sonar_movers();
		if ( player_safe_from_sonar() )
		{	
			Earthquake( 0.3, 1, level.player.origin, 512 );
			level.player PlayRumbleOnEntity( "damage_light" );
			level.player ShellShock( "sonar_ping_light", 2 );
		}
		else
		{	
			Earthquake( 0.6, 1, level.player.origin, 512 );
			level.player PlayRumbleOnEntity( "damage_heavy" );
			level.player ShellShock( "sonar_ping", 6 );
			level.player DoDamage( 200, level.player.origin );
			if ( level.player GetCurrentWeapon() != "underwater_torpedo" )
			{
				level.player DisableWeapons();
				level.player delayCall( 6, ::EnableWeapons );
			}
			level.sonar_times_hit ++;
			if ( level.sonar_times_hit > 1 )
				level.player kill();
			wait( 4 );
		}
//		level.player delaythread( 4, maps\_swim_player::shellshock_forever );
	}
}

player_safe_from_sonar()
{
	if ( flag( "player_on_torpedo" ) )
		return true;
	
	triggers = getentarray( "sonar_safe_trigger", "targetname" );
	
	foreach ( t in triggers )
	{
		if ( level.player isTouching( t ) )
		{
			return true;
		}
	}
	
	return false;
}

sonar_safe_trigger_think()
{
	while( 1 )
	{
		self waittill( "trigger" );
		if ( isdefined( self.script_index ) )
		{
			level.sonar_exploder = self.script_index;
		}
		wait( 0.5 );
	}
}

sonar_fire_trigger_think()
{
	self waittill( "trigger" );
	self script_delay();
	level notify( "weaponized_ping" );
}

sonar_movers()
{
	movers = getentarray( "sonar_ping_mover", "targetname" );
//	movers = array_add( movers, get_target_ent( "sonar_big_wreck" ) );
	foreach ( mover in movers )
	{
		mover thread sonar_mover_think();
	}
}

sonar_wreck_think()
{
	start = get_target_ent( "sonar_big_wreck_start" );
	wreck = getent( "main_lighthouse", "script_noteworthy" );
	wreck_mover = spawn_tag_origin();

	glass = getGlassArray( "lighthouse_glass" );
	foreach ( glassID in glass )
		DeleteGlass( glassID );	
	
	states = getentarray( "sonar_big_wreck_d", "targetname" );
	foreach ( piece in states )
	{
		piece linkTo( wreck );
	}

	wreck_mover.target = "sonar_wreck_move";
	wreck_mover.origin = start.origin;
	wreck_mover.angles = start.angles;
	wreck_mover.script_wait = 2.5;
	wreck_mover.script_radius = 1500;
	wreck linkTo( wreck_mover );
	
	level.sonar_wreck = wreck;
	level.sonar_wreck.glass = Spawn( "script_model", level.sonar_wreck.origin );
	level.sonar_wreck.glass.angles = level.sonar_wreck.angles;
	level.sonar_wreck.glass setModel( "shpg_lighthouse_glass" );
	level.sonar_wreck.glass linkTo( level.sonar_wreck );
	
	level.sonar_wreck.top = Spawn( "script_model", level.sonar_wreck.origin );
	level.sonar_wreck.top.angles = level.sonar_wreck.angles;
	level.sonar_wreck.top setModel( "shpg_lighthouse_top" );
	level.sonar_wreck.top linkTo( level.sonar_wreck );
	
	level.sonar_wreck.damage_states = [];
	level.sonar_wreck.mover = wreck_mover;
	array = [];
	for ( i=0; i<states.size; i++ )
	{
		array[i] = [];
	}
		
	foreach ( piece in states )
	{
		array[ piece.script_index ] = array_add( array[ piece.script_index ], piece );
		piece Hide();
		piece NotSolid();
	}
	
	for ( i=0; i<array.size; i++ )
	{
		if ( array[ i ].size > 0 )
			level.sonar_wreck.damage_states[ i ] = array[ i ];
		else 
			break;
	}
	
	if ( level.sonar_wreck.damage_states.size < 0 )
	{
		foreach ( piece in level.sonar_wreck.damage_states[ 0 ] )
		{
			piece Show();
			piece Solid();
		}
	}
	//wreck DisconnectPaths();
	
	flag_Wait( "start_sonar_mines" );
	level notify( "weaponized_ping" );
	level.sonar_ping_delay = 2;
	wait( 0.5 );
	
	currentState = 0;
	
	while ( currentState <= level.sonar_wreck.damage_states.size )
	{
		flag_wait( "sonar_clear_to_go" );
		
		if ( currentState > 0 )
		{			
			foreach ( piece in level.sonar_wreck.damage_states[ currentState-1 ] )
			{
				piece Hide();
				piece NotSolid();
			}
			
			foreach ( piece in level.sonar_wreck.damage_states[ currentState ] )
			{
				piece Show();
				piece Solid();
				
				if ( isdefined( piece.script_noteworthy ) )
				{
					temp_vec = ( piece.origin - level.player.origin );
	//				temp_vec += ( 0, 0, 400 );
					temp_vec = VectorToAngles( temp_vec );
					temp_vec = AnglesToForward( ( temp_vec[0], temp_vec[1]*1.3, temp_vec[2] ) );
					temp_vec = VectorNormalize( temp_vec );
					PlayFX( getfx( "sm_dust" ), piece.origin );
					piece unlink();
					piece RotateVelocity( temp_vec * random( [ 50, 12.5, 20.0, 32.5 ] ), 10 );
					piece MoveGravity( temp_vec * random( [ 45.0, 57.5, 60.0, 22.5 ] ), 20 );
					piece NotSolid();
				}
			}
		}
		else
		{
			/*
			glass = getGlassArray( "lighthouse_glass" );
			foreach ( glassID in glass )
				thread sonar_glass_destroy( glassID );
			*/
			
			exploder( "lighthouse_glass_break" );
			level.sonar_wreck.glass setModel( "shpg_lighthouse_glass_broken" );
		}
		
		flag_set( "first_damage_state" );
		
		currentState++;
		
		trigger = getent( "inside_sonar_boat", "script_noteworthy" );
		if ( isdefined( trigger ) )
		{
			if ( level.player isTouching( trigger ) )
			{
				level.sonar_ping_delay = 7;
				level.sonar_times_hit = 0;
			}
			else if ( !player_safe_from_sonar() )
				level.player kill();
			trigger delete();
		}
		
		wait( 1.1 );
	}
}

sonar_glass_destroy( glassID )
{
	wait( RandomFloatRange( 0, 0.5 ) );
	orig = GetGlassOrigin( glassID );
	//DestroyGlass( glassID, orig - level.player.origin );
	DeleteGlass( glassID );
}

sonar_mover_think()
{
	if ( !isdefined( self.done_linking ) )
	{
		self.linked = self get_linked_ents();
		array_call( self.linked, ::linkTo, self );
		self.done_linking = true;
		
		if ( !isdefined( self.script_wait ) )
			self.script_wait = 0.75;
		if ( !isdefined( self.script_radius ) )
			self.script_radius = 400;
	}
	
	self script_delay();
	org = self get_target_ent();
	
	oldorigin = self.origin;
	oldangles = self.angles;
	
	
	time = self.script_wait;
	
	thread play_sound_in_space( "metal_sonar_hit", self.origin );
	
	self moveTo( org.origin, time, 0, time );
	self rotateTo( org.angles, time, 0, time );
	
	wait ( time );
	
	self moveTo( oldorigin, time, time, 0 );
	self rotateTo( oldangles, time, time, 0 );
	
	wait ( time );
	
	Earthquake( 0.35, 0.5, self.origin, self.script_radius );
}

sonar_door_think()
{
	door = get_target_ent( "sonar_cargo_door" );
	
	door.linked = door get_linked_ents();
	array_call( door.linked, ::linkTo, door );

	start = get_target_ent( "sonar_cargo_door_start" );
	slam = get_target_ent( "sonar_cargo_door_slam" );
	slam2 = slam get_target_ent();
	
	door.origin = start.origin;
	door.angles = start.angles;
	
	scalar = 1.2;
		
	while( 1 )
	{
		flag_wait( "sonar_clear_to_go" );	
		
		time = 0.3 * scalar;
		door moveTo( slam.origin, time, time, 0 );
		door rotateTo( slam.angles, time, time, 0 );
		wait( time );
		
		time = 0.4 * scalar;
		door moveTo( slam2.origin, time, 0, time );
		door rotateTo( slam2.angles, time, 0, time );
		wait( time );

					
		time = 0.35 * scalar;
		door moveTo( slam.origin, time, time/2, time/2 );
		door rotateTo( slam.angles, time, time/2, time/2 );
		wait( time );

			
		time = 0.6 * scalar;
		door moveTo( slam2.origin, time, time/2, time/2 );
		door rotateTo( slam2.angles, time, time/2, time/2 );
		wait( time );		
		
		if ( !flag( "sonar_door_fly" ) )
		{			
			time = 2 * scalar;
			door moveTo( start.origin, time, 0, time );
			door rotateTo( start.angles, time, 0, time );
			wait( time );
		}
		else
		{
			time = 1.75;
			door rotateTo( (15,0,0), time, 0, time );
		
			wait (time - 0.4);
			
			start = get_target_ent( "sonar_cargo_door_fly" );
			time = 3;
			door moveTo( start.origin, time, 0, 0 );
			door rotateTo( start.angles, time, 0, 0 );
			
			door moveTo( (2601, -60053, 157), time, 0, 0 );
			door rotateTo( (25.6015, 355.278, 3.16485), time, 0, 0 );
			
			wait( time );
			time = 3;
			door moveTo( (2609, -60087, 154), time, 0, 0 );
			door rotateTo( (20.7217, 29.665, 93.757), time, 0, 0 );
			
			wait( time );
			time = 2;
			door moveTo( (2600, -60098, 111), time, 0, time );
			door rotateTo( (334.31, 34.0427, 92.4214), time, 0, time );
			
			array_call( door.linked, ::delete );
			//door delete();
			
			break;
		}
	}
}

sonar_boat_think()
{
	boat = level.sonar_boat;

	flag_wait( "welding_done" );
	trigger_wait_targetname( "sonar_boat_allow_spawn" );

	boat thread lcs_setup();
		
	startnode = GetVehicleNode("sonar_boat_cont","targetname");
	boat Vehicle_Teleport( startnode.origin, startnode.angles );
	boat.target = "sonar_boat_cont";
	boat thread maps\_vehicle_code::getonpath();
	boat ResumeSpeed( 2 );
	
	delaythread( 1, ::weaponized_sonar_chargeup );
	
	thread boat_teleport( boat );
	boat thread sonar_ping_light_think();
}

sonar_ping_light_think( offset )
{
	self endon( "death" );
	while( 1 )
	{
		level waittill( "sonar_ping_go" );
		self thread sonar_ping_light();
	}
}

sonar_boat_e3()
{
	boat = spawn_vehicle_from_targetname( "sonar_boat" );
	boat thread littoral_ship_lights();
	level.sonar_boat = boat;
	
	level.sonar_boat Vehicle_TurnEngineOff();
	
	flag_wait( "welding_done" );
	trigger_wait_targetname( "sonar_boat_allow_spawn" );

	boat thread gopath();
	level.sonar_boat Vehicle_TurnEngineOff();
	
	delaythread( 1, ::weaponized_sonar_chargeup );
	thread boat_teleport( boat );
	boat thread sonar_ping_light_think();
}

sonar_boat_audio( offset )
{		
	org_front = spawn_tag_origin();
	org_front_first_third = spawn_tag_origin();
	org_front_second_third = spawn_tag_origin();
	org_back_left = spawn_tag_origin();
	org_back_right = spawn_tag_origin();

	//hax	
	org_front.origin = (1545.29, -57932.6, 560);
	org_front_first_third.origin = (1301.13, -57170.8, 560);
	org_front_second_third.origin =(1056.96, -56408.9, 560);
	org_back_left.origin = (921.01, -55657.1, 560);
	org_back_right.origin = (730.553, -55718.2, 560);
	
	org_front PlayLoopSound ("scn_sub_fronts_lp");
	org_front_first_third PlayLoopSound ("scn_sub_engine_lp");
	org_front_second_third PlayLoopSound ("scn_sub_rumble_lp");
	org_back_left PlayLoopSound ("scn_sub_prop_l_lp");
	org_back_right PlayLoopSound ("scn_sub_prop_r_lp");
	
	thread scale_lcs_audio_fade(org_front, org_front_first_third, org_front_second_third, org_back_left, org_back_right);
	
	while (!IsDefined(level.sonar_boat))
		wait 0.1;
	
	level.sonar_boat Vehicle_TurnEngineOff();
		
	org_front LinkTo(level.sonar_boat, "tag_splash_front", (0,0,0), (0,0,0));
	//thread update_line(org_front);
	
	org_front_first_third LinkTo(level.sonar_boat, "tag_splash_front", (-800,0,0), (0,0,0));
	//thread update_line(org_front_first_third);
		
	org_front_second_third LinkTo(level.sonar_boat, "tag_splash_front", (-1600,0,0), (0,0,0));
	//thread update_line(org_front_second_third);
	
	org_back_left LinkTo(level.sonar_boat, "tag_splash_back", (0, 100, 0), (0,0,0));
	//thread update_line(org_back_left);
	
	org_back_right LinkTo(level.sonar_boat, "tag_splash_back", (0, -100, 0), (0,0,0));
	//thread update_line(org_back_right);

	thread sonar_boat_audio_mover(org_front, org_front_first_third, org_front_second_third, org_back_left, org_back_right );	
	
	//flag_wait( "welding_done" );	
	flag_wait( "player_ready_to_weld" );
	flag_wait( "ai_ready_to_weld" );
	
	time = 10;
	
	org_front moveto (level.sonar_boat GetTagOrigin("tag_splash_front"), time, time * .5, time * .5);
	org_front_first_third moveto (level.sonar_boat GetTagOrigin("tag_splash_front") + (-800,0,0), time, time * .5, time * .5);
	org_front_second_third moveto (level.sonar_boat GetTagOrigin("tag_splash_front") + (-1600,0,0), time, time * .5, time * .5);
	org_back_left moveto (level.sonar_boat GetTagOrigin("tag_splash_back") + (0, 100, 0), time, time * .5, time * .5);
	org_back_right moveto (level.sonar_boat GetTagOrigin("tag_splash_back") + (0, -100, 0), time, time * .5, time * .5);

	wait time;

	org_front LinkTo(level.sonar_boat, "tag_splash_front", (0,0,0), (0,0,0));
	org_front_first_third LinkTo(level.sonar_boat, "tag_splash_front", (-800,0,0), (0,0,0));
	org_front_second_third LinkTo(level.sonar_boat, "tag_splash_front", (-1600,0,0), (0,0,0));
	org_back_left LinkTo(level.sonar_boat, "tag_splash_back", (0, 100, 0), (0,0,0));
	org_back_right LinkTo(level.sonar_boat, "tag_splash_back", (0, -100, 0), (0,0,0));
	
	flag_wait("sonar_boat_explode");
	
	org_front delete();
	org_front_first_third delete();
	org_front_second_third delete();
	org_back_left delete();
	org_back_right delete();
}

scale_lcs_audio_fade(org_front, org_front_first_third, org_front_second_third, org_back_left, org_back_right)
{
	fade_time = 5;
	
	//wait 0.1;
	
	org_front ScaleVolume (0);
	org_front_first_third ScaleVolume (0);
	org_front_second_third ScaleVolume (0);
	org_back_left ScaleVolume (0);
	org_back_right ScaleVolume (0);
	
	wait 0.1;
	
	org_front ScaleVolume (1, fade_time);
	org_front_first_third ScaleVolume (1, fade_time);
	org_front_second_third ScaleVolume (1, fade_time);
	org_back_left ScaleVolume (1, fade_time);
	org_back_right ScaleVolume (1, fade_time);
}

sonar_boat_audio_mover(org_front, org_front_first_third, org_front_second_third, org_back_left, org_back_right )
{
	level endon ("welding_done");
	
	wait 40;
	
	org_front unlink();
	org_front_first_third unlink();
	org_front_second_third unlink();
	org_back_left unlink();
	org_back_right unlink();
	
	org_front.old_org = org_front.origin;
	org_front_first_third.old_org = org_front_first_third.origin;
	org_front_second_third.old_org = org_front_second_third.origin;
	org_back_left.old_org = org_back_left.origin;
	org_back_right.old_org = org_back_right.origin;
	
	offset = 500;
	time = 30;
	
	while (1)
	{
		org_front 					moveto (org_front.old_org - (offset, offset, 0), time, time / 2, time / 2);
		org_front_first_third 		moveto (org_front_first_third.old_org - (offset, offset, 0), time, time / 2, time / 2);
		org_front_second_third 		moveto (org_front_second_third.old_org - (offset, offset, 0), time, time / 2, time / 2);
		org_back_left 				moveto (org_back_left.old_org - (offset, offset, 0), time, time / 2, time / 2);
		org_back_right 				moveto (org_back_right.old_org - (offset, offset, 0), time, time / 2, time / 2);

		wait time;
		
		org_front 					moveto (org_front.old_org + (offset, offset, 0), time, time / 2, time / 2);
		org_front_first_third 		moveto (org_front_first_third.old_org + (offset, offset, 0) , time, time / 2, time / 2);
		org_front_second_third 		moveto (org_front_second_third.old_org + (offset, offset, 0), time, time / 2, time / 2);
		org_back_left 				moveto (org_back_left.old_org + (offset, offset, 0), time, time / 2, time / 2);
		org_back_right 				moveto (org_back_right.old_org + (offset, offset, 0), time, time / 2, time / 2);
		
		wait time;
	}
}

sonar_boat_audio_e3( offset )
{	
	if (level.start_point != "start_sonar" && level.start_point != "start_sonar_mines" && level.start_point != "e3")
		return;
	
	while (!IsDefined(level.sonar_boat))
		waitframe();
	
	self Vehicle_TurnEngineOff();

	org_front = spawn_tag_origin();
	org_front_first_third = spawn_tag_origin();
	org_front_second_third = spawn_tag_origin();
	org_back_left = spawn_tag_origin();
	org_back_right = spawn_tag_origin();
	
	org_front LinkTo(self, "tag_splash_front", (0,0,0), (0,0,0));
	org_front PlayLoopSound ("scn_sub_fronts_lp");
	//thread update_line(org_front);
	
	org_front_first_third LinkTo(self, "tag_splash_front", (-800,0,0), (0,0,0));
	org_front_first_third PlayLoopSound ("scn_sub_engine_lp");
	//thread update_line(org_front_first_third);
		
	org_front_second_third LinkTo(self, "tag_splash_front", (-1600,0,0), (0,0,0));
	org_front_second_third PlayLoopSound ("scn_sub_rumble_lp");
	//thread update_line(org_front_second_third);
	
	org_back_left LinkTo(self, "tag_splash_back", (0, 100, 0), (0,0,0));
	org_back_left PlayLoopSound ("scn_sub_prop_l_lp");
	//thread update_line(org_back_left);
	
	org_back_right LinkTo(self, "tag_splash_back", (0, -100, 0), (0,0,0));
	org_back_right PlayLoopSound ("scn_sub_prop_r_lp");
	//thread update_line(org_back_right);
	
	thread scale_lcs_audio_fade(org_front, org_front_first_third, org_front_second_third, org_back_left, org_back_right);
		
	flag_wait("sonar_boat_explode");
	
	org_front delete();
	org_front_first_third delete();
	org_front_second_third delete();
	org_back_left delete();
	org_back_right delete();
}

update_line(tag_org)
{
	while (isdefined(tag_org))
	{
		thread draw_line_for_time(tag_org.origin, level.player.origin, 1,1,1,0.05);
		wait 0.05;
	}
}


boat_teleport( boat )
{
	flag_wait( "sonar_boat_teleport" );
	
	startnode = get_Target_ent( "sonar_boat_teleport" );
	boat Vehicle_Teleport( startnode.origin, startnode.angles );
	boat.target = "sonar_boat_teleport";
	boat thread maps\_vehicle_code::getonpath();
	boat ResumeSpeed( 2 );
}

sonar_ping_light()
{
	tag = self spawn_tag_origin();
	tag linkTo( self, "tag_origin", ( 0, 0, -250 ), ( 0, 0, 0 ) );
	PlayFXOnTag( getfx( "sonar_ping_light" ), tag, "tag_origin" );
	PlayFXOnTag( getfx( "sonar_ping_distortion" ), tag, "tag_origin" );
	wait( 3 );
	tag delete();
}

/* *********** *
 * SONAR MINES *
 * *********** */

sonar_mines_dialogue()
{
	level endon( "start_new_trench" );
	thread hit_chain_dialogue();
	
	smart_radio_dialogue( "shipg_bkr_endoftheline" );
	wait( 0.7 );
	smart_radio_dialogue( "shipg_bkr_takeoutthatship" );
	flag_wait( "first_damage_state" );
	level endon( "mine_moveup" );
	
	wait( 0.7 );
	smart_radio_dialogue( "shipg_bkr_thosemines" );
	wait( 0.2 );
	smart_radio_dialogue( "shipg_bkr_shootchains" );
	
	wait( 7 );
	while( !flag( "mine_moveup" ) )
	{
		smart_radio_dialogue( "shipg_bkr_chainsonthemines" );
		wait( 7 );
	}
}

torpedo_dialogue()
{
	thread torpedo_dialogue_2();
	level endon( "player_holding_torpedo" );
	
	smart_radio_dialogue( "shipg_hsh_thereitis" );
	wait( 0.7 );
	smart_radio_dialogue( "shipg_bkr_syncuponme" );
}
	
torpedo_dialogue_2()
{
	flag_wait( "player_holding_torpedo" );
	thread torpedo_dialogue_3();
	level endon( "player_on_torpedo" );
	smart_radio_dialogue_interrupt( "shipg_bkr_proteuscomingonline" );
	wait( 0.5 );
	thread smart_radio_dialogue( "shipg_hsh_weveonlygotone" );
}
torpedo_dialogue_3()
{
	flag_wait( "player_on_torpedo" );
	wait( 0.3 );
	smart_radio_dialogue_interrupt( "shipg_bkr_illlineitup" );
	level waittill( "fire_torpedo" );
	smart_radio_dialogue( "shipg_bkr_firing" );
}

baker_torpedo_position( node )
{
	node anim_single( [ level.baker ], "lighthouse_entry" );
	node thread anim_loop( [ level.baker ], "lighthouse_idle" );
}

torpedo_the_ship()
{
	level.sonar_boat ThermalDrawEnable();
	level.baker ThermalDrawDisable();

	nets = getentarray( "torpedo_nets", "targetname" );
	array_call( nets, ::ThermaldrawEnable );
	
	thread sonar_mines_boat_reaction();
	node = get_Target_ent( "lighthouse_node" );

	trigger = level.baker;
	trigger2 = getent("grab_torpedo","targetname");
	 
	node anim_reach_solo( level.baker, "lighthouse_entry" );
	thread torpedo_dialogue();
	thread baker_torpedo_position( node );

	
	trigger MakeUsable();
	trigger thread watch_if_used();
	
	trigger2 trigger_on();
	trigger2 thread watch_if_used();
	
	trigger SetHintString(&"SHIP_GRAVEYARD_USE_TORPEDO");
	trigger2 SetHintString(&"SHIP_GRAVEYARD_USE_TORPEDO");
	
	flag_Wait("grabbed_torpedo");
	
	trigger MakeUnUsable();
	trigger2 trigger_off();
	
	flag_set( "player_holding_torpedo" );
	flag_set( "pause_sonar_pings" );
	delayThread( 6, ::flag_clear, "pause_sonar_pings" );
	
	SetSavedDvar( "player_swimSpeed", 50 );
	SetSavedDvar( "ammoCounterHide", 1 );
	level.player EnableSlowAim( 0.6, 0.6 );
	
	level.player.last_weapon = level.player GetCurrentWeapon();	
	level.player DisableWeaponSwitch();
	level.player GiveWeapon( "underwater_torpedo" );
	level.player SwitchToWeapon( "underwater_torpedo" );
	level.player AllowFire( false );
        //starting spinning sounds for torpedo
	thread torpedo_drillbit_audio();	
	wait( 4 ); // torpedo pullout time	
	while( 1 )
	{
		level.player waittill( "fire weapon" );
		if ( !player_looking_at( level.sonar_boat.origin, 0.8, true ) )
		{
			display_hint( "hint_notfound" );
		} 
		else if ( !player_not_obstructed( 250 ) )
		{
			display_hint( "hint_blocked" );
		}
		else
		{
			break;
		}
	}
	
		
	start_ang  = level.player GetPlayerAngles();
	fwd = AnglesToForward( start_ang );
	start_pos  = level.player GetEye();
	start_pos += fwd * 64;
	
	flag_set( "player_on_torpedo" );
	thread maps\ship_graveyard_torpedo::torpedo_go( start_pos, start_ang );
	level waittill( "torpedo_ready" );
	time = 1.5;
	level.player.dom.ref_ent moveTo( level.player.dom.ref_ent.origin + (fwd*32), time, 0, time );
	level.player.dom.ref_ent rotateTo( level.player.dom.ref_ent.angles - (level.player.dom.ref_ent.angles[0],0,0), time, 0, time );
	wait( time );
	node notify( "stop_loop" );
	
	while( GetDvarInt( "debug_torpedo", 0 ) )
		wait( 0.05 );
	
	level notify( "fire_torpedo" );
	
	level waittill( "exit_torpedo", hit_lcs );
	
	level.baker thread baker_glint_on();
	
	SetSavedDvar( "ammoCounterHide", 0 );
	
	//level.sun_pos_pre_lcs_death = GetDvar( "r_sunflare_position", (0,0,0) );
	
	if ( hit_lcs )
	{
		//setSunFlarePosition( (290,350,0) );
		//SetDvar("r_sunflare_position", (290,350,0));
		thread impact_vision_set();
		level.player TakeWeapon( "underwater_torpedo" );
		level.player AllowFire( true );
		level notify( "mine_moveup" );
		wait( 0.15 );
		flag_set( "sonar_boat_explode" );
		//smart_radio_dialogue_interrupt( "shipg_bkr_directhit" );
		wait( 1.772 );
		thread smart_radio_dialogue_interrupt( "shipg_bkr_nicework" );
	}
	else
	{
		wait( 0.5 );
		//fade_out( 0.1, "black" );
		force_deathquote( &"SHIP_GRAVEYARD_HINT_TORPEDO" );
		missionfailedwrapper();
	}
}

watch_if_used()
{
	self SetHintString( &"PLATFORM_HOLD_TO_USE" );
				
	self waittill ("trigger");
	flag_set("grabbed_torpedo");
}

torpedo_drillbit_audio()
{
	wait ( 4 );
	level.sound_torpedo_ent = spawn( "script_origin", level.player GetEye() );
	level.sound_torpedo_ent playloopsound( "scn_shipg_torpedo_drillbit_loop" );
	
	
	level.sound_torpedo_ent scalevolume(0.7, 0.0);
	level.sound_torpedo_ent scalepitch(0.5, 0.0);
	wait (0.1);
	level.sound_torpedo_ent scalevolume(1.0, 1.5);
	level.sound_torpedo_ent scalepitch(1.0, 1.5);
	
}


impact_vision_set()
{
	
	//level waittill( "done_changing_vision" );
//	waitframe();
//	last_vision = level.player.vision_set_transition_ent.vision_set;
//	
//	level.player thread vision_set_fog_changes( "shpg_lcs_detonation", 0 );
//	wait( 2 );
//	//iprintlnbold( "V2" );
//	level.player thread vision_set_fog_changes( last_vision, 5 );
	wait (0.3);

	self thread vision_set_fog_changes( "", 0 );
	flag_set( "pause_dynamic_dof" );
	maps\_art::dof_enable_script( 1, 1, 4.5, 500, 500, 0.05, 0.1 );
	wait ( 1 );
	self thread vision_set_fog_changes( "shpg_lcs_detonation", 1 );
	wait ( 1 );
	self thread vision_set_fog_changes( "", 3 );
	maps\_art::dof_disable_script( 1 );
	wait( 1 );
	flag_clear( "pause_dynamic_dof" );
}

sonar_mines()
{
	mines = getentarray( "sonar_mine", "targetname" );
	array_thread( mines, ::sonar_mine_think );
	level waittill( "sonar_boat_explode" );
	wait( 0.15 );
	foreach ( m in mines )
	{
		if ( isdefined( m ) )
		{
			m notify( "explode" );
			wait( RandomFloatRange( 0.3, 0.5 ) );
		}
	}
}

hit_chain_dialogue()
{
	level waittill( "mine_moveup" );
	thread smart_radio_dialogue_interrupt( "shipg_bkr_nicework" );
}

sonar_mine_think()
{
	trigger = self get_target_ent();
	
	self thread mine_notify_on_tigger( trigger );
	self thread mine_notify_on_level();
	self thread mine_explode_think();
	self waittill( "moveup" );
	flag_set( "mine_moveup" );
	
	org = ( self.origin[0], self.origin[1], level.water_level_z - 686 );
	
	self moveTo_speed( org, 150, 0.8 );
	flag_set( "sonar_boat_explode" );
	self notify( "explode" );
}

mine_explode_think()
{
	self waittill( "explode" );
	PlayFX( getfx( "shpg_underwater_explosion_med_a" ), self.origin + (0,0,646) );
	if ( (level.water_level_z - 120 - 686) - self.origin[2] < 10 )
	{
		PlayFX( getfx( "underwater_surface_splash" ), self.origin + (0,0,646) );
	}
	PlayFX( getfx( "shpg_underwater_explosion_med_a" ), self.origin + (0,0,646) );
	thread play_sound_in_space( "underwater_explosion", self.origin + (0,0,646) );
	Earthquake( 0.7, 0.7, self.origin + (0,0,646), 2000 );
	self delete();
}

mine_notify_on_tigger( trigger )
{
	self endon( "moveup" );
	trigger waittill( "trigger" );
	self notify( "moveup" );
}

mine_notify_on_level()
{
	self endon( "moveup" );
	level waittill( "mine_moveup" );
	wait( RandomFloatRange( 0.5, 1.5 ) );
	self notify( "moveup" );
}

sonar_mines_boat_reaction()
{
	node = get_target_ent( "lighthouse_node" );
	flag_wait( "player_on_torpedo" );
	level waittill( "exit_torpedo" );
	
	level.baker DontInterpolate();
	level.baker.animname = "baker";
	node thread anim_first_frame( [ level.baker ], "lighthouse_fall" );
		
	flag_wait( "sonar_boat_explode" );
	musicstop( 1 );
	boat = level.sonar_boat;
	
	front = spawn( "script_model", boat.origin );
	front setModel( "vehicle_lcs_destroyed_front" );
	front.animname = "lcs_front";
	front setAnimTree();
	
	front_org = spawn_tag_origin();
	front_org.origin = front.origin;
	front_org.angles = front.angles;
	front_org linkto( front );
	
	front_org thread lcs_lights_front();
	
	back = spawn( "script_model", boat.origin );
	back setModel( "vehicle_lcs_destroyed_back" );
	back.animname = "lcs_back";
	back setAnimTree();

	back thread lcs_lights_back();
	
	player_swim_offset = (0,0,48);
	
	rig = maps\_player_rig::get_player_rig();
	rig.origin = level.player.origin - player_swim_offset;
	rig.angles = level.player.angles;
	
	dummy = spawn_tag_origin();
	dummy.origin = rig.origin;
	dummy.angles = rig.angles;
	dummy linkTo( rig, "tag_player", player_swim_offset, (0,0,0) );
	
	legs = spawn( "script_model", (0,0,0) );
	legs setModel( "body_seal_udt_dive_a" );
	legs.animname = "legs";
	legs setAnimTree();
	
	level.sonar_wreck unlink();
	level.sonar_wreck.animname = "lighthouse";
	level.sonar_wreck setAnimTree();
	
	level.player thread play_sound_on_entity("scn_shipg_lighthosue_fall_lr");
	
	thread sonar_crash_player_setup( rig, dummy, legs );
	thread sonar_crash_dialogue();
	
	boat delete();
	
	level.baker notify( "stop_first_frame" );
	
	thread sonar_crash_fx( rig, front, back );
	SetSavedDvar( "sv_znear", "1" );
	time = getAnimLength( level.sonar_wreck getanim( "lighthouse_fall" ) );
	
	thread sonar_crash_solo_arms();
	
	level.sonar_wreck.top delete();
	
	node thread anim_single( [ rig, level.sonar_wreck, front, back, level.baker, legs ], "lighthouse_fall" );
	level.sonar_wreck waittillmatch( "single anim", "fadeout" );
//	level.player thread play_sound_on_entity( "scn_ship_graveyard_boat_crash" );
	level notify( "stop_earthquake" );
	Earthquake( 0.8, 0.5, level.player.origin, 2000 );
	level.player_rig StopRumble( "subtle_tank_rumble" );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	maps\_hud_util::fade_out( 0.05 );
	wait( 1 );
	level.player StopShellshock();
	wait( 0.05 );
	level.sonar_wreck.glass delete();
	level.sonar_wreck.mover delete();
	level.sonar_wreck delete();
	level.player unlink();
	level.player_rig delete();	
	flag_set( "start_new_trench" );
	level.player ShowViewModel();
	
	front delete();
	back delete();
	legs delete();
	front_org delete();
}

sonar_crash_solo_arms()
{
	rig = spawn_anim_model( "player_rig", level.player.origin );
	rig LinkToPlayerView( level.player, "tag_origin", (0,0,-64), (0,0,0), true );
	//rig anim_single_solo( rig, "lighthouse_fall_arms" );
	rig SetAnim( rig getanim( "lighthouse_fall_arms" ), 1, 0, 1 );
	wait( 7 );
	rig delete();
	flag_set("turn_on_bubbles_after_torpedo");
}

sonar_crash_fx( rig, front, back )
{
	og_origin = level.sonar_wreck.origin;
	og_angles = level.sonar_wreck.angles;
	upvec = AnglesToUp( og_angles );
	downvec = -1*upvec;
	
	org = level.sonar_wreck spawn_tag_origin();
	
	org2 = level.sonar_wreck spawn_tag_origin();
	org2.angles = VectorToAngles( downvec );
	
	org3 = level.sonar_wreck spawn_tag_origin();
	
	org2 linkTo( level.sonar_wreck );
	org linkTo( org2, "tag_origin", (-400,0,0), (0,0,0) );
	org3 linkTo( org2, "tag_origin", (-600,0,0), (-90,0,0) );
	
	wait( 0.1 );
	
	//org_front = spawn_tag_origin();
	//org_front.origin = front.origin;
	//org_front.angles = front.angles + (0,90,0);
	//org_front linkTo( front );
	//noself_delayCall( 0, ::PlayFXOnTag, getfx( "lighthouse_lcs_detonation_sink" ), org_front, "tag_origin" );
	
	org_player = spawn_tag_origin();
	org_player.origin = (2810, -61853, 89);
	org_player.angles = (0, 141, -45);
	noself_delayCall( 2.5, ::PlayFXOnTag, getfx( "lighthouse_window_mess" ), org_player, "tag_origin" );
	
	
	noself_delaycall( 6.0, ::PlayFXOnTag, getfx( "lighthouse_debris" ), org, "tag_origin" );
	
	noself_delaycall( 6.0, ::PlayFXOnTag, getfx( "lighthouse_bubbles" ), org3, "tag_origin" );
	
	delayThread( 0.0, ::exploder, "lighthouse_lcs_detonation" );
	
	//delayThread( 1.9, ::exploder, "lighthouse_view_impact_force" );
	
	delayThread( 2, ::exploder, "debris_hit_wood_metal" );
	
	PlayFXOnTag( getfx( "lighthouse_debris" ), org, "tag_origin" );
	
	PlayFXOnTag( getfx( "lighthouse_bubbles" ), org3, "tag_origin" );
	
	delayThread( 3.1, ::player_panic_bubbles );
	
	delayThread( 4, ::exploder, "base_snap_debris" );
	
	delayThread( 4.5, ::player_panic_bubbles );
	
	delayThread( 6, ::player_panic_bubbles );
	
	flag_wait( "start_new_trench" );
	
	org delete();
	org2 delete();
	org3 delete();
	org_player delete();
	//org_front delete();
}


sonar_crash_earthquake()
{
	level endon( "stop_earthquake" );
	
	level.earthquake_strength = 0.2;
	thread increase_earthquake_strength();
	
	level.player delayCall( 8, ::SetBlurForPlayer, 6, 5 );
	delayThread( 9, ::fade_out, 9 );
	
	while( 1 )
	{
		Earthquake( level.earthquake_strength, 0.2, level.player.origin, 3000 );
		wait( 0.1 );
	}
}

increase_earthquake_strength()
{
	level endon( "stop_earthquake" );
	wait( 4 );
	org = spawn_tag_origin();
	org.origin = (0,0,level.earthquake_strength);
	org moveZ( 0.22, 6, 6, 0 );
	org thread delete_on_notify( "stop_earthquake" );
	
	level.f_min[ "gasmask_overlay" ] = 0.7;
	level.f_max[ "gasmask_overlay" ] = 0.9;
	level.f_min[ "halo_overlay_scuba_steam" ] = 0.6;
	level.f_max[ "halo_overlay_scuba_steam" ] = 0.7;
	
	while( 1 )
	{
		level.earthquake_strength = org.origin[2];
		wait( 0.05 );
	}
}

sonar_crash_player_setup( hands, rig, legs )
{
	level.player DisableWeapons();
	level.player PlayerLinkToAbsolute( rig, "tag_origin" );
	wait( 0.2 );
	level.player EnableSlowAim( 0.35, 0.35 );
	setSavedDvar( "player_swimSpeed", 35 );
	setSavedDvar( "player_swimVerticalSpeed", 10 );
	hands Hide();
	legs Hide();
	level.player unlink();
	level.player AllowSprint( false );
	thread sonar_crash_dof();
	wait( 3.25 );
	level.player PlayerLinkToBlend( rig, "tag_origin", 0.5, 0, 0 );
	wait( 0.5 );
	level.player PlayerLinkToDelta( rig, "tag_origin", 1, 10, 10, 10, 10 );
	wait( 1 );
	hands Show();
	legs Show();
	level.player Shellshock( "nearby_crash_underwater", 4.5 );
	wait( 0.5 );
	hands Hide();
	legs Hide();
	//level.player unlink();
	wait( 2.25 );
	//level.player PlayerLinkToBlend( rig, "tag_origin", 0.5, 0.0, 0.5 );
	wait( 0.5 );
	//level.player PlayerLinkToDelta( rig, "tag_origin", 1, 10, 10, 10, 10 );
	hands Show();
	legs Show();
	level.player AllowSprint( true );
}

sonar_crash_dof()
{
	wait( 0.75 );
	flag_set( "pause_dynamic_dof" );
	maps\_art::dof_enable_script( 0, 250, 4, 1500, 4000, 1.5, 1 );
	wait( 5.5 );
	maps\_art::dof_disable_script( 1 );
	wait( 1 );
	flag_clear( "pause_dynamic_dof" );
}

sonar_crash_dialogue()
{
	wait( 5 );
	thread sonar_crash_earthquake();
	level.player_rig PlayRumbleLoopOnEntity( "subtle_tank_rumble" );	
	wait( 3 );	
	thread smart_radio_dialogue( "shipg_bkr_ohshit" );
	wait( 3.3 );
	
	thread smart_radio_dialogue( "shipg_bkr_hangon" );
}

base_alarm()
{
	flag_init( "start_base_alarm" );
	// because it's really annoying to hear that alarm all day
	
	play_alarm = GetDvarInt( "play_alarm", 1 );
	
	if ( play_alarm )
	{
		flag_wait( "start_base_alarm" );
		sound_ent = getent( "origin_base_alarm", "targetname" );
	
		//sound_ent thread play_loop_sound_on_entity( "emt_alarm_base_alert" );
		//sound_ent playloopsound( "emt_alarm_base_alert" );
		sound_ent base_alarm_loop();
		flag_waitopen( "start_base_alarm" );
		//sound_ent stopLoopSound( "emt_alarm_base_alert" );
	}
}

base_alarm_loop()
{
	level endon( "start_base_alarm" );
	while( 1 )
	{
		self PlaySound( "emt_alarm_base_alert", "done_playing" );
		self waittill( "done_playing" );
	}
}

canyon_jumper_setup()
{
	self endon( "death" );
	
	org = self get_target_ent();
	
	if ( isdefined( org ) )
	{
		if ( isdefined( org.target ) )
		{
			self waittill( "done_jumping_in" );
			org = org get_target_ent();
			self follow_path_and_animate( org, 0 );
		}
	}
}

initial_depth_charge_run()
{
	level endon( "start_big_wreck" );
	wait( 4.5 );
	
	while( 1 )
	{
		array_thread( getstructarray( "depth_charge_test", "targetname" ), ::depth_charge_org );
		wait( 4 );
		array_thread( getstructarray( "depth_charge_test_2", "targetname" ), ::depth_charge_org );
		wait( 6.5 );
		array_thread( getstructarray( "depth_charge_test_3", "targetname" ), ::depth_charge_org );
		wait( 6.5 );
	}
}

depth_charges()
{
	autosave_by_name( "depth_charges" );
	array_thread( getstructarray( "depth_charge_test", "targetname" ), ::depth_charge_org );
	wait( 1.5 );
	//array_thread( getstructarray( "depth_charge_test_2", "targetname" ), ::depth_charge_org );
	wait( 2.75 );
	//array_thread( getstructarray( "depth_charge_test_3", "targetname" ), ::depth_charge_org );
	wait( 1.5 );

	level notify( "stop_killing_player" );
	flag_clear( "allow_killfirms" );
	
	thread initial_depth_charge_run();
	thread random_depth_charges( "depth_charge_constant", 9, 13 );
	thread smart_radio_dialogue( "shipg_bkr_depthcharges" );
//	delaythread( 1, ::music_crossfade, "mus_shipgrave_stinger", 1 );
	delaythread( 4, ::flag_set, "depth_charge_run_start" );

	thread depth_charge_enemy_check();
	
	flag_wait( "depth_charge_run_start" );

	ai = getAIArray( "axis" );
	foreach ( a in ai )
	{
		a.baseaccuracy = 0.01;
	}
	
	delaythread( 2, ::depth_charges_near_player );
	thread depth_charge_dialogue();
	thread depth_charge_death();
	spd = getDvarFloat( "player_swimSpeed" );
	setSavedDvar( "player_swimSpeed", 110 );
	setSavedDvar( "player_sprintUnlimited", "1" );
	level.baker disable_ai_color();
	prp = level.baker.pathrandompercent;
	level.baker.pathrandompercent = 0;
	level.baker dyn_swimspeed_disable();
	level.baker.moveplaybackrate = 1.55;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker.a.disablepain = 1;
	level.baker disable_arrivals();
	level.baker delayThread( 0.3, ::disable_exits );
	level.baker.ignoreall = true;
	baker_noncombat();
	level.baker delayThread( 0.1, ::dyn_swimspeed_enable, 350 );
	
	baker_glint_on();
	
	level.baker thread big_wreck_wait_turnaround();
	level.baker follow_path_And_animate( get_Target_ent( "baker_enter_big_wreck" ), 0 );
	
	
	ai = getAIArray( "axis" );
	foreach ( a in ai )
	{
		a kill();
	}
	
	level.baker dyn_swimspeed_disable();
	level.baker.moveplaybackrate = 1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker.pathrandompercent = prp;
	level.baker enable_arrivals();
//	level.baker enable_exits();
	level.baker.a.disablepain = 0;
	level.baker.ignoreall = false;
	flag_wait( "start_big_wreck" );
	setSavedDvar( "player_sprintUnlimited", "0" );
}

depth_charge_enemy_check()
{
	level endon( "depth_charge_run_start" );
	
	ai = getAIArray( "axis" );
	array_thread( ai, ::kill_after_time, .75 );
	
	while( 1 )
	{
		count = 0;
		ai = getAIArray( "axis" );
		foreach( a in ai )
		{
			if ( Distance( a.origin, level.player.origin ) < 1024 )
			{
				count += 1;
			}
		}
		if ( count > 0 )
			wait( 0.1 );
		else
			break;
	}
	
	flag_set( "depth_charge_run_start" );
}

kill_after_time( time )
{
	self endon( "death" );
	flag_wait( "depth_charge_run_start" );
	wait RandomFloatRange( time*0.25, time );
	self kill();
}

depth_charge_dialogue()
{
	// magic reload
	level.baker animscripts\weaponList::RefillClip();
	
	smart_radio_dialogue( "shipg_bkr_takecover" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_thiswaymovemove" );	
}

depth_charge_death()
{
	level endon( "start_big_wreck" );
	triggers = getentarray( "depth_charge_death", "targetname" );
	array_thread( triggers, ::depth_charge_death_trig );
	wait( 2 );
	
	while( 1 )
	{
		wait( 3 );
		if ( Distance( level.player.origin, level.baker.origin ) < 600 )
		{
			wait( 3 );
			continue;
		}
		
		thread smart_radio_dialogue( "shipg_bkr_takecover" );
		
		wait( 5 );
		
		if ( Distance( level.player.origin, level.baker.origin ) > 600 )
		{
			depth_charge_death_trig_kill();
		}
	}
	
}

random_depth_charges( _targetname, wait_min, wait_max )
{
	level endon( "stop_depth_charges" );
	array = getstructarray_delete( _targetname, "targetname" );
	
	while( 1 )
	{
		fwd = AnglesToForward( level.player.angles );
		fwd = fwd * 500;
		nearby = SortByDistance( array, level.player.origin + fwd );
		nearby = [ nearby[0], nearby[1], nearby[2] ];
		          
		org = random( nearby );
		org thread depth_charge_org();
		wait( RandomFloatRange( wait_min, wait_max ) );
	}
}

depth_charges_near_player()
{
	level endon( "stop_depth_charges" );
	while( 1 )
	{
		fwd = AnglesToForward( level.player.angles );
		rt = AnglesToRight( level.player.angles );
		
		fwd = fwd * RandomFloatRange( 100, 300 );
		rt = rt * RandomFloatRange( 50, 200 );
		
		rt = rt * random( [ -1, 1 ] );
		
		thread drop_depth_charge( level.player.origin + fwd + rt );
		wait( RandomFloatRange( 4, 6 ) );
	}
}

boat_fall_trigs()
{
	triggers = getentarray( "depth_charge_boat_fall_trigger", "targetname" );
	array_thread( triggers, ::depth_charge_boat_fall_trigger );
}

depth_charge_boat_fall_trigger()
{
	boat = self get_Target_ent();
	self waittill( "trigger" );
	boat thread maps\ship_graveyard_new_trench::crash_model_go( [] );
}

/* ********* *
 * BIG WRECK *
 * ********* */

middle_room_fall()
{
	beam = get_target_Ent( "big_wreck_middle_room_beam" );
	node = beam get_target_ent();
	org = beam spawn_tag_origin();
	org linkTo( beam );
	PlayFXOnTag( getfx( "underwater_object_trail" ), org, "Tag_origin" );
	beam thread play_sound_on_entity( "scn_shipg_titanic_debris_fall" );
	beam moveTo_rotateTo( node , 5, 3, 0 );
	StopFXOnTag( getfx( "underwater_object_trail" ), org, "Tag_origin" );
	Earthquake( 0.4, 0.7, beam.origin, 2000 );
	play_sound_in_space( "scn_shipg_titanic_debris_crash", beam.origin );
	
}

big_wreck_baker_stealth()
{
	level endon( "big_wreck_shark" );
	level.baker.goalradius = 32;
	flag_wait( "big_wreck_baker_path_1" );
	
	thread middle_room_fall();
	
	thread smart_radio_dialogue( "shipg_bkr_areaclear" );
	wait( 2 );
	node = get_target_ent( "big_wreck_baker_node_1" );
	level.baker follow_path_and_animate( node );
	wait( 2 );
	flag_wait( "big_wreck_baker_path_2" );
	level.baker thread dyn_Swimspeed_enable();
	thread smart_radio_dialogue( "shipg_bkr_zerocontacts" );
	wait( 1 );
	
	node = get_target_ent( "big_wreck_baker_node_2" );
	level.baker setGoalNode( node );
	level.baker waittill( "goal" );
}

big_wreck_shark()
{
	flag_wait( "big_wreck_shark" );
	
	autosave_stealth();
	
	level endon( "shark_eating_player" );
	level endon( "start_shark_room" );
	
	exploder( "wreck_hallway" );
	
	big_wreck_shark_baker_teleport();
	
	node = get_target_ent( "big_wreck_baker_node_2" );
	level.baker setGoalNode( node );

	shark = spawn_targetname( "big_wreck_shark_model" );
	shark thread deletable_magic_bullet_shield();
	shark thread attack_player_after_death();
	thread shark_moment_2( shark );
	
	thread big_wreck_track_player_gunfire();
	delaythread( 1.15, ::music_play, "mus_shipgrave_shark_showup" );
	smart_radio_dialogue_interrupt( "shipg_bkr_easy2" );
	wait( 2.5 );
	
	smart_radio_dialogue( "shipg_bkr_handsfull" );
	wait( 0.8 );
	thread smart_radio_dialogue( "shipg_bkr_inthemiddle" );
	wait( 1 );
	level.baker GetEnemyInfo( shark );
	level.baker.ignoreAll = true;
	level.baker ClearEnemy();

	//level.baker follow_path_and_animate( get_target_ent( "baker_wreck_stealth_path_2" ) );

	level.baker.my_animnode = get_target_ent( "big_wreck_2_baker_shark_entry" );

	level.baker.my_animnode anim_generic_reach( level.baker, "swimming_aiming_move_to_cover_r1_l45_d45" );	
	level.baker thread baker_post_up_at_sharks();
	shark thread stop_magic_bullet_shield();
	
	level.baker waittill_player_lookat( 0.65 );
	
	flag_set( "start_shark_room" );
}

big_wreck_shark_baker_teleport()
{
	volume = get_target_ent( "big_wreck_shark_check" );
	if ( !level.baker isTouching( volume ) )
	{
		if ( !level.player player_looking_at( level.baker.origin, 0.7 ) )
		{
			org = get_target_ent( "big_wreck_shark_teleport" );
			if ( !level.player player_looking_at( org.origin, 0.7, false ) )
				level.baker ForceTeleport( org.origin, org.angles );
		}
	}
}

baker_post_up_at_sharks()
{
	//level.baker.anim_blend_time_override = 1;

	//level.baker.my_animnode anim_generic( level.baker, "swimming_aiming_move_to_cover_r1_l45_d45" );
	level.baker AnimCustom( ::baker_post_up_at_sharks_animcustom, ::baker_done_posting_up_at_sharks );

	//level.baker.anim_blend_time_override = undefined;
}

baker_done_posting_up_at_sharks()
{
	level.baker.my_animnode.origin = level.baker.origin;
	level.baker.my_animnode.angles = level.baker.angles;
	level.baker.my_animnode thread anim_generic_loop( level.baker, "swimming_cover_r1_loop" );
}

baker_post_up_at_sharks_animcustom()
{
	arrivalAnim = level.scr_anim[ "generic" ][ "swimming_aiming_move_to_cover_r1_l45_d45" ];

	level.baker ClearAnim( %body, 0.2 );
	level.baker SetFlaggedAnimRestart( "postup", arrivalAnim, 1, 0.5 );

	desiredAngles = level.baker.my_animnode.angles;
	animRotation = GetAngleDelta3D( arrivalAnim );

	angleDiff = desiredAngles - animRotation;

	oldTurnRate = self.turnRate;

	t = GetAnimLength( arrivalAnim ) * 0.3;
	self.turnRate = abs( AngleClamp180( angleDiff[0] - level.baker.angles[0] ) ) / t / 1000;

	level.baker OrientMode( "face angle 3d", angleDiff );
	level.baker AnimMode( "nogravity" );

	self animscripts\shared::DoNotetracks( "postup" );

	self.turnRate = oldTurnRate;
}

shark_room()
{
	level endon( "shark_eating_player" );
	thread shark_room_end();
	thread player_shoots_sharks();
	
	flag_wait( "big_wreck_shark" );
	
	sharks = array_spawn_targetname( "big_wreck_shark_model_veh" );
	array_thread( sharks, ::attack_player_after_death );
	
	flag_wait( "start_shark_room" );
	level.baker dyn_Swimspeed_disable();
	level.baker.ignoreAll = true;
	trig = get_Target_ent( "shark_room_trig" );
	
	smart_radio_dialogue_interrupt( "shipg_bkr_holdup" );
	wait( 1.5 );
	smart_radio_dialogue( "shipg_bkr_doesntlook" );
	wait( 1 );		
	smart_radio_dialogue( "shipg_bkr_oneatatime" );
	wait( 1 );	
	
	thread greenlight_end();
		
	if ( !level.player isTouching( trig ) )
	{
		//autosave_stealth();
		
		thread shark_room_baker_first_dialogue();
		thread tell_player_to_stay( trig );
	}
	else
	{
		smart_radio_dialogue( "shipg_bkr_headstart" );
		wait( 1.5 );
		smart_radio_dialogue( "shipg_bkr_noquick" );
		wait( 1.5 );
		smart_radio_dialogue( "shipg_bkr_trytoanticipatetheir" );
		wait( 1 );
		smart_radio_dialogue( "shipg_bkr_coveryou" );
		flag_wait( "player_past_sharks" );
		wait( 2 );
		smart_radio_dialogue( "shipg_bkr_keepcovered" );
		wait( 2 );
	}
	
	flag_Wait( "shark_b_clear_2" );
	

	
	level.baker.moveplaybackrate = 0.5;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker.goalradius = 32;
	
	node = get_target_ent( "baker_wreck_stealth_path_3" );
	level.baker.my_animnode notify( "stop_loop" );
	level.baker.my_animnode thread anim_generic_run( level.baker, "swimming_cover_r1_to_aiming_move_r45_u45" );
	level.baker disable_exits();
	level.baker setGoalNode( node );
	level.baker.my_animnode waittill( "swimming_cover_r1_to_aiming_move_r45_u45" );
	wait( 0.1 );
	level.baker enable_exits();
	level.baker waittill( "goal" );
	
	if ( greenlight_check() )
		return;
	
	while( !flag( "shark_a_clear" ) || !flag( "shark_b_clear" ) )
		wait( 0.05 );
	
	flag_set( "shark_room_player_can_go" );
	level.baker.goalradius = 256;
	node = node get_target_ent();
	level.baker.moveplaybackrate = 0.7;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker setGoalNode( node );
//	level.baker waittill( "goal" );
	
	flag_set( "baker_past_sharks" );
	
	if ( !flag( "player_past_sharks" ) )
	{
		level.baker.dontevershoot = true;
		level.baker.ignoreAll = false;
		autosave_stealth();
		if ( !level.player isTouching( trig ))
		{
			smart_radio_dialogue( "shipg_bkr_youreup" );
			baker_glint_on();
			trigger_off( "big_wreck_shatk_heartbeat_trig", "targetname" );
			wait( 2 );
			// trig waittill( "trigger" );
		}
		smart_radio_dialogue( "shipg_bkr_noquick" );
		wait( 2 );
		thread smart_radio_dialogue( "shipg_bkr_trytoanticipatetheir" );
		thread shark_room_faster_hint();
		flag_wait( "player_past_sharks" );
		wait( 1 );
		level.baker.dontevershoot = undefined;
		level.baker.ignoreAll = true;
	}
}

attack_player_after_death()
{
	self waittill( "death" );
	
	wait( 0.1 );
	
	my_friends = level.deadly_sharks;
	my_friends = array_removeDead( my_friends );
	my_friends = array_removeUndefined( my_friends );
	my_friends = SortByDistance( my_friends, level.player.origin );
	
	flag_clear( "shark_eating_player" );
	
	foreach ( f in my_friends )
	{
		f thread shark_kill_player( true );
		break;
	}
}

shark_room_end()
{
	flag_wait( "start_shark_room" );
	flag_wait( "player_past_sharks" );
	flag_wait( "baker_past_sharks" );
	flag_waitopen( "shark_eating_player" );

	level notify( "shark_room_player_can_go" );
	
	thread smart_radio_dialogue_interrupt( "shipg_bkr_letsgo" );
	
	level.baker.moveplaybackrate = 1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	
	autosave_stealth();
	level.baker.goalradius = 200;
	level.baker thread dyn_swimspeed_enable();
	level.baker follow_path_and_animate( get_target_ent( "baker_wreck_stealth_path_4" ), 250 );
}

player_shoots_sharks()
{
	volume = get_Target_ent( "shark_room_trig" );
	
	flag_wait( "shark_eating_player" );
	
	if ( isdefined( level.baker.my_animnode ) )
		level.baker.my_animnode notify( "stop_loop" );
	level.baker StopAnimScripted();
		
	more_sharks = true;
	while( more_sharks )
	{
		flag_waitopen( "shark_eating_player" );
		wait( 1 );
		flag_waitopen( "shark_eating_player" );
		more_sharks = false;
		foreach ( s in level.deadly_sharks )
		{
			if ( s isTouching( volume ) )
			{
				more_sharks = true;
				break;
			}
		}
	}
	
	if ( !flag( "baker_past_sharks" ) )
	{
		node = get_target_ent( "baker_wreck_stealth_path_3" );
		level.baker thread follow_path_and_animate( node );
	}
	
	flag_set( "baker_past_sharks" );
	
	iprintlnbold( "YOU HAVE BALLS OF STEEL!" );
	
	smart_radio_dialogue( "shipg_bkr_onme" );
}

shark_room_faster_hint()
{
	level.player endon( "death" );
	level endon( "shark_eating_player" );
	level endon( "player_past_sharks" );
	flag_wait( "shark_room_close_to_exit" );
	flag_wait_either( "shark_a_clear_comeback", "shark_b_clear_comeback" );
	smart_radio_dialogue( "shipg_hsh_hurryuptheyrecoming" );
}

big_wreck_track_player_gunfire()
{
	while( 1 )
	{
		level.player waittill( "weapon_fired" );
		
		wait( 0.5 );
		level.deadly_sharks = array_removeDead( level.deadly_sharks );
		level.deadly_sharks = array_removeUndefined( level.deadly_sharks );
		if ( level.deadly_sharks.size > 0 )
		{
			sharks = SortByDistance( level.deadly_sharks, level.player.origin );
			for ( i=0; i<level.deadly_sharks.size; i++ )
			{
				if ( Distance( sharks[i].origin, level.player.origin ) < 800 )
				{
					success = sharks[i] shark_kill_player();
					if ( isdefined( success ) && success )
						break;
				}
				else
				{
					break;
				}
			}
		}
		wait( 0.05 );
	}
}

shark_moment_2( shark )
{
	pathnode = get_Target_ent( "big_wreck_shark_1_path" );
	node = get_target_ent( "shark_moment_2" );
	sound_node = get_target_ent( "shark_moment_2_sound" );
	
	shark.animnode = node;
	shark.animname = "shark";
	shark thread shark_kill_think();

	shark endon( "killing_player" );
	shark endon( "death" );
/*	
	guy = spawn_targetname( "shark_moment_diver" );
	guy.animname = "generic";
	guy.ignoreme = true;
	
	shark setGoalPos( pathnode.origin );
	
	node thread anim_first_frame( [ shark, guy ], "shark_moment2" );
	
	MagicBullet( "mp5_underwater_projectile", node.origin + (0,0,32), sound_node.origin );
	wait( 0.4 );
	play_sound_in_space( "weap_smgsilenced_fire_npc", sound_node.origin );
	wait( 0.8 );
	thread play_sound_in_space( "weap_smgsilenced_fire_npc", sound_node.origin );
	
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), guy, "j_elbow_ri" );
	node thread anim_single( [shark, guy], "shark_moment2" );
	thread shark_attack_2_fx( guy, shark );
	wait( 3.75 );
	shark ent_flag_set( "shark_busy" );
	node waittill( "shark_moment2" );
	shark ent_flag_clear( "shark_busy" );
	
	guy kill();
*/	
	shark follow_path_and_animate( pathnode, 0 );
}

shark_attack_2_fx( guy, shark )
{
	wait( 3.75 );
	thread play_sound_in_space( "scn_shark_bite_flesh", guy getTagOrigin( "j_knee_ri" ) );
	PlayFX( getfx( "swim_ai_blood_impact" ), guy getTagOrigin( "j_knee_ri" ) );
	wait( 0.25 );
	thread play_sound_in_space( "scn_shark_bite_flesh", guy getTagOrigin( "j_knee_ri" ) );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), guy, "j_knee_ri" );
	exploder( 10 );
}

shark_room_baker_first_dialogue()
{
	level endon( "told_player_to_stay" );	
	smart_radio_dialogue( "shipg_bkr_gofirst" );	
	wait( 1.5 );
	if ( !greenlight_check() )
		smart_radio_dialogue( "shipg_bkr_stayhere" );	
	wait( 2 );	
}
	
tell_player_to_stay( trig )
{
	level endon( "shark_eating_player" );
	level endon( "shark_room_player_can_go" );
	trig waittill( "trigger" );
	level notify( "told_player_to_stay" );
	smart_radio_dialogue_interrupt( "shipg_bkr_stop" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_onlyroom" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_atentrance" );
}

big_wreck_wait_turnaround()
{
	level.baker waittill( "path_end_reached" );
	flag_set("big_wreck_wait_turnaround");
}

big_wreck_dialogue()
{
	baker_noncombat();

	thread smart_radio_dialogue( "shipg_bkr_saferhere" );
	wait( 2 );
	level.baker.pathrandompercent = 0;
	level.baker.goalradius = 128;
	delaythread( 3.5, ::smart_radio_dialogue, "shipg_bkr_eyeout" );
	wait( 0.5 );
	level.baker disable_exits();
	
	flag_wait("big_wreck_wait_turnaround");
	
	level.baker thread anim_generic( level.baker, "swimming_idle_to_aiming_move_180" );

	level.baker thread follow_path_and_animate( get_target_ent( "baker_enter_big_wreck_inside" ) );
	level.baker waittill( "swimming_idle_to_aiming_move_180" );
	
	wait( 0.2 );
	
	level.baker enable_exits();
	
	flag_Wait( "inside_big_wreck" );
	autosave_by_name( "big_wreck" );
	
	level notify( "stop_depth_charges" );
	ai = getaiarray( "axis" );
	array_call( ai, ::delete );	
}

// *** OLD ***
big_wreck_encounter()
{
	trigger_Wait_targetname( "big_wreck_spawn_1" );
	level.baker set_force_color( "r" );
	wait( 0.1 );
	thread smart_radio_dialogue( "shipg_bkr_contact" );
	while( 1 )
	{
		ai = getaiarray( "axis" );
		if ( ai.size <= 1 )
			break;
		wait( 0.1 );
	}
	level.baker.maxfaceenemydist = 64;
	wait( 1 );
	
	ai = getaiarray( "axis" );
	if ( ai.size > 0 )
	{
		foreach( a in ai )
			a setGoalEntity( level.player );
	}
}

big_wreck_kill_when_outside()
{
	trigger = get_Target_ent( "big_wreck_outside" );
	trigger thread depth_charge_death_trig();
}

depth_charge_death_trig()
{
	self waittill( "trigger" );
	depth_charge_death_trig_kill();
}
depth_charge_death_trig_kill()
{
	PlayFX( getfx( "shpg_underwater_explosion_med_a" ), level.player.origin );
	thread play_sound_in_space( "underwater_explosion", level.player.origin );

	Earthquake( 0.6, 0.75, level.player.origin, 1024 );
	
	level.player ViewKick( 15, level.player.origin );
	level.player Shellshock( "depth_charge_hit", 2.5 );

	wait( 0.3 );
	
	RadiusDamage( level.player.origin, 300, 100, 20 );
	
	wait( 1 );
	
	level.player kill();
}

big_wreck_fake_shake()
{
	level endon( "stop_wreck_shake" );
	
//	volume = get_Target_ent( "cave_volume" );
	orgs = getstructarray_delete( "depth_charge_sound_source", "targetname" );
	origins = getstructarray_delete( "big_wreck_shake_org", "targetname" );
	
	while( 1 )
	{
		wait( RandomFloatRange( 1,2 ) );

//		if ( !level.player istouching( volume ) )
//			continue;
		org = random( orgs );
		
		strength = RandomFloatRange( 0.2, 0.4 );
		thread play_sound_in_space( "underwater_explosion_muffled", org.origin );
		cave_shake( strength, origins, "scn_shipg_wreck_rattle" );
		
		wait( RandomFloatRange( 1,6 ) );
	}
}

big_wreck_2_dialogue()
{
	/*
	trigger_wait( "staircase_depth_charge", "script_noteworthy" );
	wait( 4 );
	smart_radio_dialogue( "shipg_bkr_takemuchmore" );
	wait( 2 );
	setSavedDvar( "player_sprintUnlimited", "1" );
	thread smart_radio_dialogue( "shipg_bkr_getoutquick" );
	level.baker.moveplaybackrate = 1.4;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	
	noself_delayCall( 1, ::musicplay, "mus_shipgrave_action" );
	*/
	flag_wait( "player_inside_glass_room" );
	thread smart_radio_dialogue( "shipg_bkr_stayaway" );
	trigger_Wait_targetname( "baker_down_hatch" );
	smart_radio_dialogue( "shipg_bkr_hatchmove" );
}

big_wreck_collapse()
{
//	waittill_notify_or_timeout( "big_wreck_out", 5 );
	flag_wait( "big_wreck_out" );
	
	thread exploder( 97 ); //ceiling collapse 3 explosion
	wait( 0.5 );
	thread exploder( 101 ); //ceiling collapse 3 brushmodel
	
	volume = get_target_ent( "out_of_wreck_volume" );
	if ( level.player isTouching( volume ) )
	{
		musicstop( 1 );
		level.player GiveMaxAmmo( level.player GetCurrentWeapon() );
		level.player Shellshock( "default", 2 );
		level.player thread delay_reset_swim_shock( 2 );
		level.player DisableWeapons();
		level.player delayCall( 2, ::EnableWeapons );
	}
	else
	{
		level.player kill();
	}
	smart_radio_dialogue( "shipg_bkr_pain2" );
	wait( 1 );
	smart_radio_dialogue( "shipg_bkr_intheclear" );
//	wait( 1 );
//	smart_radio_dialogue( "shipg_bkr_fornow" );
	wait( 1.5 );
	autosave_by_name( "end" );
	thread smart_radio_dialogue( "shipg_bkr_thisway2" );
	
	setSavedDvar( "player_swimSpeed", 120 );
	
	level.baker PushPlayer( true );
	level.baker.dontchangepushplayer = true;
	level.baker.goalradius = 256;
	level.baker.moveplaybackrate = 1.7;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker.pathrandompercent = 0;
	level.baker disable_exits();
	level.baker thread anim_generic_run( level.baker, "swimming_idle_to_aiming_move_180" );
	level.baker setGoalNode( get_target_ent( "baker_prepare_to_leave" ) );
	trigger_wait_targetname( "baker_prepare_to_leave_trig" );
	level.baker thread dyn_swimspeed_enable();
	level.baker thread follow_path_and_animate( get_target_ent( "baker_end_level_path" ) );
	level.baker delayThread( 2, ::enable_exits );
	thread end_dialogue();
	
	flag_wait( "the_end" );
	level notify( "stop_depth_charges" );
	//fade_out( 6 );
	//level.player FreezeControls( true );
	//nextmission();
}

end_dialogue()
{
	wait( 7 );
	smart_radio_dialogue( "shipg_bkr_rallypointecho" );
	wait( 0.5 );
	smart_radio_dialogue( "shipg_orb_goodtohear" );
	wait( 0.2 );
	smart_radio_dialogue( "shipg_bkr_ihearya" );
}

delay_remove_invul()
{
	level endon( "killed_a_guy" );
	wait( 4 );
	level.player DisableInvulnerability();
}

final_stand_dialogue()
{
	smart_radio_dialogue( "shipg_bkr_doorsjammed" );
	wait( 1 );
	thread smart_radio_dialogue( "shipg_bkr_watchmyback" );
}
	
player_notify_on_lookup()
{
	org = get_target_Ent( "big_wreck_player_looking_up" );
	org waittill_player_lookat( 0.7 );
	
	level.player notify( "player_looking_up" );
}

door_open()
{
	targ = self get_Target_ent();
	target_angles = targ.angles;
	self rotateTo( target_angles, 0.5, 0, 0.3 );
}

underwater_flood_spawn()
{
	level endon( "wreck_ceiling_collapse" );
	while( 1 )
	{
		guy = self spawn_ai( true );
		guy thread teleport_to_target();
		guy waittill( "death" );
		level notify( "killed_a_guy" );
		wait( RandomFloatRange( 2,4 ) );
	}
}

// *** OLD ***
big_wreck_tilt()
{
	flag_wait( "wreck_tilt" );
	
	wait( 2.5 );
	thread play_sound_in_space( "underwater_explosion", level.player.origin );
	Earthquake( 0.2, 0.75, level.player.origin, 1024 );
	
	thread wreck_tilt_baker_hurt();
	
	ground_ref = spawn_tag_origin();
	level.player PlayerSetGroundReferenceEnt( ground_ref );
	ground_ref RotateTo( (330,0,0), 0.6, 0, 0.4 );
	level.player DisableWeapons();
	level.player Shellshock( "default", 2 );
	level.player thread delay_reset_swim_shock( 3 );
	level.player delayCall( 3, ::EnableWeapons );
	ground_ref waittill( "rotatedone" );
	ground_ref RotateTo( (0,0,0), 0.8, 0.6, 0.1 );
	ground_ref waittill( "rotatedone" );
	level.player PlayerSetGroundReferenceEnt( undefined );
	ground_ref delete();
}

// *** OLD ***
wreck_tilt_baker_hurt()
{
	thread smart_radio_dialogue( "shipg_bkr_pain2", 0.1 );
	mover = level.baker spawn_Tag_origin();
	level.baker linkTo( mover, "tag_origin" );
	level.baker DoDamage( 50, level.baker.origin + ( 0, 0, 0 ) );
	mover rotateTo( (30, 0, 0 ), 0.6, 0, 0.4 );
	mover waittill( "rotatedone" );
	mover RotateTo( (0,0,0), 0.8, 0.6, 0.1 );
	mover waittill( "rotatedone" );
	level.baker unlink();
	mover delete();
}

/* GREEN LIGHT */

greenlight_skip()
{
	if ( !greenlight_check() )
		return;	
	
	wait( 3 );
	
	flag_set( "greenlight_next_phase" );
	//set_audio_zone("ship_graveyard_gl_transition", 10 );
	fade_out( 3 );
	level.player FreezeControls( true );
	level.baker setGoalPos( level.baker.origin );
	wait( 1 );
	music_stop( 12 );
	
	wait( 0.5 );
	
	thread e3_text_hud( &"SHIP_GRAVEYARD_E3_TIME", 2 );
	wait( 3.1 );
	thread e3_text_hud( &"SHIP_GRAVEYARD_E3_TIME2", 2 );
	wait( 3.1 );
	thread e3_text_hud( &"SHIP_GRAVEYARD_E3_TIME3", 2 );
	wait( 4 );
	set_start_positions( "new_trench" );
	
	smart_radio_dialogue( "shipg_bkr_hangon" );
	wait( 0.7 );
	level.player thread play_sound_on_entity( "scn_ship_graveyard_boat_crash" );
	wait( 0.8 );
	flag_set( "start_new_trench" );	
	
}

greenlight_end()
{
	if ( !greenlight_check() )
		return;

	//JS: this crossfade crashes currently... or does it?
	thread music_crossfade( "mus_shipgrave_gl_stinger", 4.5 );
	
	thread set_audio_zone("ship_graveyard_gl_fadeout_end", 5.5 );
	wait( 5.65 );		
	fade_out( 0.05 );	

	level.player FreezeControls( true );
	wait( 11 );
	nextmission();
}

end_tunnel_swim()
{
	trig = getent("trig_swim_up_transition_out","targetname");
	
	trig waittill ("trigger");	
	
	fade_out( 2 );
	level.player thread play_sound_on_entity( "enemy_water_splash" );

	flag_set("go_to_surface");
}

end_surface()
{
	brush = get_target_ent("surface_ai_clip_end");
	
	brush MoveTo(brush.origin + (0,0,-28.5), 0.01);
	
	flag_wait("go_to_surface");
	
	//set_audio_zone( "ship_graveyard_abovewater" );
	level.player SetClientTriggerAudioZone( "ship_graveyard_abovewater_end", 1 );
	
	
	level notify ("stop_particulates");
		
	if (!isdefined(level.ground_ref_ent))
	{
		level.ground_ref_ent = spawn_Tag_origin();
		level.ground_ref_ent.script_duration = 1;
	}	
	
	level.ground_ref_ent.script_max_left_angle = 1;
	level.player PlayerSetGroundReferenceEnt( level.ground_ref_ent );
	level.ground_ref_ent thread maps\ship_graveyard_surface::pitch_and_roll();
	
	level.player SetOrigin( get_target_ent("end_tunnel_above_surface").origin );
	level.player SetPlayerAngles( get_target_ent("end_tunnel_above_surface").angles );

	level notify ("end_swimming");
	
	setSavedDvar( "player_swimWaterCurrent", "0 0 0" );
	SetSavedDvar( "g_gravity"			 , 800 );
	SetSavedDvar( "sm_sunshadowscale"	 , 1 );
	SetSavedDvar( "sm_sunsamplesizeNear" , 1 );
	
	maps\_art::dof_set_base( 1, 1, 4.5, 500, 500, 0.05, 0 );
								 
	if (isdefined(level.distOrg))
	{
		level.distOrg delete();
	}
	
//	level.player thread vision_set_fog_changes( "shpg_start_abovewater_end", 0 );
	
	// fake baker at the end
	spawner = get_target_ent( "baker_end" );
	level.baker_end = spawner spawn_ai( true );
	level.baker_end thread magic_bullet_shield();
	level.baker_end.animname = "baker";	
	level.baker_end set_generic_idle_anim( "surface_swim_idle" );
		
	level.player thread maps\_swim_player::disable_player_swim();
	
	level.player notify( "stop_scuba_breathe" );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowJump( false );
		

	level.player_view_pitch_down = getDvar( "player_view_pitch_down" );

	setSavedDvar( "player_view_pitch_down", 5 );
	level.player EnableSlowAim( 0.5, 0.5 );
	level.player DisableWeapons();
	
	level.player player_speed_percent( 100, 0.1 );
	level.player player_speed_percent( 10, 0.1 );
	
	wait (0.25);
	thread maps\_hud_util::fade_in( 0.25 );
	
	PlayFX( getfx( "large_water_impact_surface_breach" ), level.player.origin );
	level.player thread play_sound_on_entity( "enemy_water_splash" );
	
	wait( 1 );
	smart_radio_dialogue( "shipg_orb_greenlit" );
	wait( 0.3 );
	thread fade_out( 4 );	
	smart_radio_dialogue( "shipg_bkr_seeyoutopside" );		
	level.player SetClientTriggerAudioZone( "ship_graveyard_fadeout_end", 2.1 );
	wait( 1 );	
	nextmission();
}
