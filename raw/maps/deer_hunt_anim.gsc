#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

#using_animtree("generic_human");
main()
{
	maps\_hand_signals::initHandSignals();
	maps\_patrol_anims::main();
	generic_human_anims();
	player_anims();
	dog_anims();
}


generic_human_anims()	
{
	level.scr_anim[ "generic" ][ "gundown_walk"						 ] = %active_patrolwalk_gundown;
	level.scr_anim[ "generic" ][ "paris_delta_deploy_flare_crouched" ] = %paris_delta_deploy_flare_crouched;
	
	level.scr_anim[ "generic" ][ "shop_door_idle" ][ 0 ] = %hunted_open_barndoor_idle;
	level.scr_anim[ "generic" ][ "shop_door_open" ]		 = %hunted_open_barndoor_flathand;
	
	level.scr_anim[ "generic" ][ "meeting_idle1" ][0] = %jungle_ghost_patrol_meeting_idle_guy1;
	level.scr_anim[ "generic" ][ "meeting_idle2" ][0] = %jungle_ghost_patrol_meeting_idle_guy2;
	level.scr_anim[ "generic" ][ "meeting_idle3" ][0] = %jungle_ghost_patrol_meeting_idle_guy3;
	
	//360 spin
	level.scr_anim[ "generic" ][ "360" ]		 = %combatwalk_f_spin;
	
	//level.scr_anim[ "generic" ][ "patrol_walk_meeting" ]	  = %creepwalk_f;
	level.scr_anim[ "generic" ][ "patrol_idle_meeting" ][ 0 ] = %jungle_ghost_patrol_meeting_idle_guy3;
	
	level.scr_anim[ "generic" ][ "door_kick" ]		 = %doorkick_2_cqbwalk;
	level.scr_anim[ "generic" ][ "wall_kick" ]		 = %door_kick_in;
	
	//jeep ride
	level.scr_anim[ "generic" ][ "clockwork_checkpoint_tapglass_enemy_a" ] = %clockwork_checkpoint_tapglass_enemy_a;
	level.scr_anim[ "generic" ][ "flood_convoy_checkpoint_opfor02"		 ] = %flood_convoy_checkpoint_opfor02;
	level.scr_anim[ "generic" ][ "flood_convoy_checkpoint_opfor01"		 ] = %flood_convoy_checkpoint_opfor01;
	level.scr_anim[ "generic" ][ "clockwork_checkpoint_shoetie_enemy"	 ] = %clockwork_checkpoint_shoetie_enemy;
	level.scr_anim[ "generic" ][ "training_pit_stand_idle"				 ] = %training_pit_stand_idle;
	level.scr_anim[ "generic" ][ "jungle_ghost_patrol_meeting_idle_guy1" ] = %jungle_ghost_patrol_meeting_idle_guy1;
	level.scr_anim[ "generic" ][ "jungle_ghost_patrol_meeting_idle_guy2" ] = %jungle_ghost_patrol_meeting_idle_guy2;
	level.scr_anim[ "generic" ][ "jungle_ghost_patrol_meeting_idle_guy3" ] = %jungle_ghost_patrol_meeting_idle_guy3;
	level.scr_anim[ "generic" ][ "hamburg_tank_driver_afterfall_loop"	 ] = %hamburg_tank_driver_afterfall_loop;
	level.scr_anim[ "generic" ][ "patrol_jog_orders_once"				 ] = %patrol_jog_orders_once;
	level.scr_anim[ "generic" ][ "patrol_jog"							 ] = %patrol_jog;
	//level.scr_anim[ "generic" ][ "civilian_directions_1_A"				 ] = %civilian_directions_1_A;
	//level.scr_anim[ "generic" ][ "civilian_directions_2_B"				 ] = %civilian_directions_2_B;
	
	level.scr_anim[ "generic" ][ "creepwalk_duck"							 ] = %creepwalk_traverse_under;
	
	level.scr_anim[ "generic" ][ "dog_react"							 ]				= %prague_dog_scare_b;
	level.scr_anim[ "generic" ][ "stumble_creepwalk"							 ] = %creepwalk_f_stumble_looping;
	
	//lariver slides
	level.scr_anim[ "generic" ] [ "afgan_caves_price_slide" ] = %afgan_caves_price_slide;
	level.scr_anim[ "generic" ] [ "rescue_pipe_slide"		] = %rescue_pipe_slide;
	
	//backdoor takedown
	level.scr_anim[ "ai_enemy" ][ "intro_takedown" ] = %jungle_ghost_intro_stealthkill_ai_enemy;
	level.scr_anim[ "ai_enemy" ][ "intro_takedown_death_idle" ][0] = %jungle_ghost_intro_stealthkill_ai_enemy_deathidle;
	level.scr_anim[ "ai_enemy" ][ "intro_takedown_death" ] = %jungle_ghost_intro_stealthkill_ai_enemy_death;

	level.scr_anim[ "ai_friendly" ][ "intro_takedown" ] = %jungle_ghost_intro_stealthkill_ai_friendly;
	
	level.scr_anim[ "victim" ][ "dog_kill_long" ] = %iw6_dog_kill_back_long_guy_1;  //8.33 secs / 85% in = ragdoll
	
	level.scr_anim[ "generic" ][ "knees_idle" ][0] = %hostage_knees_idle;  //8.33 secs / 85% in = ragdoll
		
	addNotetrack_customFunction( "generic", "kick", ::door_kick_func, "door_kick" );
	addNotetrack_customFunction( "generic", "kick", ::wall_kick_func, "wall_kick" );
	addNotetrack_customFunction( "ai_enemy", "knife out", ::gasstation_takedown_knife_notetrack_func );
	
}

gasstation_takedown_knife_notetrack_func( guy )
{
	guy die();
}

#using_animtree( "player" );
player_anims()
{
	level.scr_animtree[ "player_rig" ] 					 			= #animtree;
	level.scr_model[ "player_rig" ] 					 			= "viewhands_player_sas_woodland";	
	
	level.scr_anim[ "player_rig" ][ "intro_jeep_exit_player" ] = %payback_gatecrash_dismount_player;
}


#using_animtree( "dog" );
dog_anims()
{
	//level.scr_anim[ "dog" ][ "sniff"	 ] = %iw6_dog_sniff_walk;
	level.scr_anim[ "generic" ][ "walk"		 ] = %iw6_dog_walk;
	level.scr_anim[ "generic" ][ "walk_slow" ] = %german_shepherd_walk_slow;
	
	level.scr_anim[ "generic" ][ "dog_kill_long" ] = %iw6_dog_kill_back_long_1;
	
	level.scr_anim[ "generic" ][ "sneak_idle"	 ] = %iw6_dog_sneakidle;
	level.scr_anim[ "generic" ][ "sneak_walk"		 ] = %iw6_dog_sneak_walk_forward;
	
}

door_kick_func( guy )
{
	door = getent( "kicked_door", "targetname" );
	//target_angles = getent("kicked_door_finish", "targetname" ).angles;
	door RotatePitch( -110, .5, .1, .4 );
	thread play_sound_in_space( "physics_ammobox_default", guy.origin );
	//door rotateto( target_angles, .5, .1, .4 );
	door ConnectPaths();
						  	
}

wall_kick_func( guy  )
{
	rebar = getentarray( "wall_rebar", "targetname" );
	clip = getent(  "wall_clip", "targetname" );
	wall_top = ( -13707.5, 14076, -195.5 );
	wall_bottom = ( -13707.5, 14076, -223 );
	
	PhysicsExplosionSphere( wall_top, 50,30, .5 );
	PhysicsExplosionSphere( wall_bottom, 50,30, .3 );	
	PlayFX( getfx( "wall_kick_impact_deer_hunt" ), wall_top );
	array_thread( rebar, ::rebar_rotate );
	
	clip.origin +=( 0,0,10000 );
	clip connectpaths();
	
	thread play_sound_in_space( "wall_kick_impact", wall_top );
	thread play_sound_in_space( "wall_kick_impact_rubble", wall_bottom );
	
	wait 1;
	clip delete();
}

rebar_rotate()
{
	time = randomfloatrange( .2, .6);
	self RotatePitch( 110, time, .1, time - .1 );	
}