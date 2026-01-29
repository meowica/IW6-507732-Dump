#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\_hud_util;
#include maps\oilrocks_apache_vo;


// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Apache Escort
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

start()
{
	// Setup Player Apache
	spawn_apache_player( "apache_escort" );
	
	// Spawn and set up friendlies
	spawn_blackhawk_ally( "struct_blackhawk_ally_escort" );
	
	spawn_apache_allies( "struct_apache_ally_escort_0" );
	
	// Make apache allies chopper bosses
	apache_allies = get_apache_allies();
	array_thread( apache_allies, ::self_make_chopper_boss, undefined, true );
	
	
	flag_set( "FLAG_apache_chase_vo_done" );
	flag_set( "FLAG_apache_chase_finished" );
	
}

main()
{
	thread apache_mission_vo_think( ::apache_mission_vo_escort );

	thread maps\oilrocks_apache_hints::apache_hints_escort();

	flag_wait_any( "FLAG_apache_chase_player_close_to_island", "FLAG_apache_chase_finished" );
	
	autosave_by_name();

	
	thread objectives_following_chase();
	// Spawn the encounter logic when the player gets close or when the chase is finished
	apache_escort_encounter_infantry_think();
	objective_complete( obj( "apache_escort" ) );
	
	
}

objectives_following_chase()
{
	flag_wait_all( "FLAG_apache_chase_vo_done", "FLAG_apache_chase_finished" );
	
	thread apache_escort_blackhawk_think();
	thread objectives();

}

objectives()
{
	if ( obj_exists( "apache_chase" ) )
		objective_complete( obj( "apache_chase" ) );
	
	//"Escort Infantry Troops"
	Objective_Add( obj( "apache_escort" ), "active", &"OILROCKS_OBJ_APACHE_ESCORT" );
	Objective_Current( obj( "apache_escort" ) );

}

CONST_RAGDOLL_LIFE_MAX_FOR_ESCORT = 2000; //Default is 4500
CONST_RAGDOLL_SIM_MAX_FOR_ESCORT  = 10;	  //Default is 16
CONST_CORPSE_MAX_FOR_ESCORT		  = 8;	  //Default is 16

apache_escort_encounter_infantry_think()
{
	// Allies get their setup on exiting the black hawk
	thread apache_escort_set_up_ally_infantry();
	
	// A lot of AI are spawned and thrown around during this. Optimize corpses and rag dolls.
	ragdoll_life = GetDvarInt( "ragdoll_max_life" );
  //  ragdoll_count = GetDvarInt( "ragdoll_max_simulating" );
  //  corpse_count	= GetDvarInt( "ai_corpseCount" );
	
	SetSavedDvar( "ragdoll_max_life", CONST_RAGDOLL_LIFE_MAX_FOR_ESCORT );
//	SetSavedDVar( "ragdoll_max_simulating", CONST_RAGDOLL_SIM_MAX_FOR_ESCORT );
//	SetSavedDVar( "ai_corpseCount", CONST_CORPSE_MAX_FOR_ESCORT );
	
	// Make any rpg ai that are living fire on the player occaisonally
	thread manage_all_rpg_ai_attack_player_think( "apache_escort_enemy_ai", "apache_escort_finished" );
	
	struct_encounter_first = getstruct( "apache_escort_struct_first", "targetname" );
	ai_remaining		   = escort_encounter_think( struct_encounter_first, "apache_escort_enemy_ai" );
	
								 //   key 							      func 										    
	array_spawn_function_targetname( "apache_escort_spawner_final_wave", ::apache_escort_encounter_final_wave_on_spawn );
	array_spawn_function_targetname( "apache_escort_spawner_final_wave", ::ai_record_spawn_pos );
	array_spawn_function_targetname( "apache_escort_spawner_final_wave", ::add_as_apache_target_on_spawn );
	ai_final_wave = array_spawn_targetname( "apache_escort_spawner_final_wave" );
	
	// Make sure the transition to the chopper fight is faster
	flag_wait_or_timeout( "FLAG_apache_escort_allies_inside", 3.0 );
	if ( !flag( "FLAG_apache_escort_allies_inside" ) )
	{
		flag_set( "FLAG_apache_escort_allies_inside" );
	}
	
	// Clean up allies once they get far enough inside
	array_thread( level.infantry_guys, ::apache_escort_delete_infantry_on_inside );
	level.infantry_guys = undefined;
	
	level notify ( "FLAG_apache_escort_finished" );
	delayThread( 5, ::cleanup_escort, ai_remaining, ai_final_wave );
	
		// Reset corpse and rag doll optimizations
	if ( CONST_RAGDOLL_LIFE_MAX_FOR_ESCORT == GetDvarInt( "ragdoll_max_life" ) )
		SetSavedDvar( "ragdoll_max_life", ragdoll_life );
	
//	if ( CONST_RAGDOLL_SIM_MAX_FOR_ESCORT == GetDvarInt( "ragdoll_max_simulating" ) )
//		SetSavedDVar( "ragdoll_max_simulating", ragdoll_count );
	
//	if ( CONST_CORPSE_MAX_FOR_ESCORT == GetDvarInt( "ai_corpseCount" ) )
//		SetSavedDVar( "ai_corpseCount", ai_remaining );

}

cleanup_escort( ai_remaining, ai_final_wave )
{
	// Clean up remaining ai from encounter system
	ai_remaining = array_remove_undefined_dead_or_dying( ai_remaining );
	array_thread( ai_remaining, ::ai_clean_up );
	
	// Clean up remaining ai from final wave
	ai_final_wave = array_remove_undefined_dead_or_dying( ai_final_wave );
	array_thread( ai_final_wave, ::ai_clean_up );
}

apache_escort_encounter_final_wave_on_spawn()
{
	self.attackeraccuracy = 10.0;
}

apache_escort_blackhawk_think()
{
	blackhawk = get_blackhawk_ally();
	blackhawk thread vehicle_paths( getstruct( "path_blackhawk_escort_drop_off", "targetname" ) );
}

apache_escort_delete_infantry_on_inside()
{	
	volume_inside = GetEnt( "apache_escort_volume_allies_inside", "targetname" );
	
	while ( !self IsTouching( volume_inside ) )
		wait 0.05;
	
	apache_player = get_apache_player();
	apache_player thread vehicle_scripts\_apache_player::hud_hideTargets( [ self ] );
	
	self stop_magic_bullet_shield();
	self Delete();
}

apache_escort_set_up_ally_infantry()
{
	AssertEx( IsDefined( level.infantry_guys ) && level.infantry_guys.size, "Tried to set up the ground friendlies with invalid or empty infantry_guys array." );
	array_thread( level.infantry_guys, ::apache_escort_set_up_ally_infantry_on_jumping_out );
}

apache_escort_set_up_ally_infantry_on_jumping_out()
{
	self endon( "death" );
	self waittill( "jumping_out" );
	self.moveplaybackrate		  = 1.25;
	self.ignoresuppression		  = true;
	self.disableplayeradsloscheck = true;
	self.pathrandompercent		  = 0;
	self disable_pain();
	self set_ignoreme( false );
	
	apache_player = get_apache_player();
	apache_player thread vehicle_scripts\_apache_player::hud_addAndShowTargets( [ self ] );
}
