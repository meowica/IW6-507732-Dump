#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\jungle_ghosts_util;
#include maps\_stealth_utility;

#using_animtree( "generic_human" );

friendly_stream_navigation()
{
	thread watersheet_trig_setup();
	thread stream_vo();
	
	switch ( level.start_point )
	{
		case "default":
		case"parachute":
		case"jungle_corridor":
		case"jungle_hill":
			thread jungle_cleanup();
			
		case"waterfall":
		case "stream":			
			thread second_distant_sat_launch();
				
			flag_wait( "player_rescued_hostage" );
			time = GetAnimLength( %jungle_ghost_wf_holdup_hostage1_helpup );
			
			thread chopper_crash();
			
			thread deactivate_stream_trigs_until_ambush();
			
			level.squad = array_combine( level.alpha, level.bravo );
			
			if( level.start_point != "stream" )
			{
				wait time - 5;
			}
			
			flag_wait("second_distant_sat_launch");
	
			array_thread( level.squad, maps\jungle_ghosts_util::stream_waterfx, "stop_water_footsteps", "step_walk_water");
			array_thread( level.bravo, ::set_force_color, "b" );
			level.alpha2 set_force_color ("g");
			array_thread( level.squad, ::enable_ai_color );
			array_thread( level.squad, ::set_ignoreall, 1);
			//thread friendly_squad_ignore_all(true);
			
			activate_trigger_with_targetname( "stream_pos_1" );
	
			stream_color_trigs = getentarray( "stream_color_trigs", "script_noteworthy" );
			array_thread( stream_color_trigs, ::trigger_off );
			
			//player is at stream corner with chopper
			flag_wait( "chopper_crash_arrive" );	
			autosave_by_name("stream_fight");	
			
			// Keegan shoots down the chopper
			thread stream_ai_shoot_down_chopper();
			thread stream_player_rushes_chopper();
			
			flag_wait_any("begin_shoot_chopper", "stream_heli_out");
			
			
			//array_call( level.squad, ::SetEntityTarget, level.chopper_pilot_ent );
			
			thread stream_fight_goes_hot();
			thread stream_fight_stealth();
			
			//stream enemies dead, setup waterfall aumbush
			flag_wait( "stream_clear" );
			flag_wait("bridge_area_exit");
			
			//turn off color trigs that got us here. 
			stream_color_trigs = getentarray( "stream_color_trigs", "script_noteworthy" );
			array_thread( stream_color_trigs, ::trigger_off );
			
			array_thread(level.squad, ::enable_cqbwalk );
			
			wait( 4 ); 
			
			flag_wait("squad_to_waterfall_ambush");
		
		case "stream waterfall":
		
			autosave_by_name( "waterfall_ambush" );
			
			//send squad to ambush area
			activate_trigger_with_targetname( "waterfall_ambush_setup" );
			
			ambush_area = GetEnt( "ambush_area", "targetname" );
			
			//axis only bad place so baddies dont go under wataerfall
			BadPlace_Cylinder( "axis_badplace", -1, ambush_area.origin, 353, 200, "axis" );
		
			ambush_stealth_settings();	
			guys_in_position = [];
			//wait for all squad members to get there
			while( guys_in_position.size != level.squad.size )		
			{
				foreach( guy in level.squad )	
				{
					if( guy istouching( ambush_area ) && !is_in_array( guys_in_position, guy ) )
						guys_in_position = add_to_array( guys_in_position, guy );
				}
				wait( .5 );
			}
			
			//iprintln( "all squad members in position" );
			//iprintln( "waiting for player..." );
			
			foreach ( guy  in guys_in_position)
			{
				guy.perfectaim = true;
			}
				
			guys_in_position = undefined; //cleanup
			
			flag_set("squad_in_ambush_position");
						
			//super low visibility while in waterfall
			maps\_stealth_utility::stealth_detect_ranges_set( level.ambush_hidden_settings );
			
			thread player_ambush_area_monitor( ambush_area );
			
			//iprintln( "player in position. here we go." );
			flag_wait( "player_in_ambush_position" ); //gets set when player commits to a position for the ambush
			
			flag_set( "waterfall_ambush_begin" );
			
			thread waterfall_goes_hot();
			
			flag_wait_any("waterfall_patrollers_dead", "waterfall_patrollers_passed");
			battlechatter_off();
			thread play_sound_in_space("scn_sold1_enemy_radio_static", (3588, 5594, 628) );
			autosave_by_name( "stream_backend" );
		
			wait( 4 );
		
			array_thread( level.squad, ::enable_ai_color ); //stealth system turns this off in some cases. 
			
			foreach ( guy  in level.squad )
			{
				guy.perfectaim = false;
				guy thread enable_cqbwalk();
				guy delayThread( 4, ::disable_cqbwalk );
			}
	
	case "stream backend":
		
			activate_trigger_with_targetname( "stream2_pos1" );
			
			//array_spawn_function_noteworthy( "tall_grass_patroller", ::jungle_enemy_logic, "zero", 1 );
			func = maps\jungle_ghosts_jungle::jungle_enemy_logic;
			array_spawn_function_targetname( "tall_grass_intro_guys_stealth", func, "zero", 1 );
			
			// only if there was an ambush
			if (flag("ambush_open_fire"))
			{
				trig = getent("stream_backend_moveup_stealth","targetname");
				trig delete();
				
				flag_wait("stream_backend_enemies_dead");
			
				if(!flag("stream_backend_moveup" ) )//get set by trig. Player may have moved up already 
					activate_trigger_with_targetname("stream_backend_moveup");
			}
			else
			{
				array_thread( level.squad, level.ignore_on_func );
				delaythread( 3, ::array_thread, level.squad, ::enable_cqbwalk );
			
				trig = getent("stream_backend_moveup","targetname");
				trig delete();
				
				flag_wait("stream_exit" );
				activate_trigger_with_targetname("stream_backend_moveup_stealth");
			}
			
			flag_wait("to_grassy_field"); //player hit trig
			array_thread( level.squad, ::squad_save_old_color );
			
			// set them to go right
			if (!flag("ambush_open_fire"))
			{
				array_thread( level.squad, ::set_force_color, "c" );
				array_thread( level.squad, ::backend_friendly_stealth_logic);
			}
			
			array_notify( level.squad, "stop_water_footsteps" );
			level.player notify( "stop_water_footsteps" );
		
			//delayThread( 5, ::flag_set, "tall_grass_intro_goes_hot" );
			thread tall_grass_friendly_navigation();	
	}
	
}

backend_friendly_stealth_logic()
{
	self endon ("death");
	
	self AllowedStances("crouch", "prone");
	
	flag_wait("backend_friendlies_go_hot");
	array_thread( level.squad, level.ignore_off_func );
	
	if (isdefined(self.old_color))
		self set_force_color(self.old_color);
	
	self AllowedStances("crouch", "prone", "stand");
}

squad_save_old_color()
{
	if (IsDefined(self.script_forcecolor))
		self.old_color = self.script_forcecolor;
	else if (IsDefined(self.old_forcecolor))
		self.old_color = self.old_forcecolor;
}

waterfall_goes_hot()
{
		flag_wait( "ambush_open_fire" );
		
		array_thread(level.squad, level.ignore_off_func );
	
		battlechatter_on();
}


stream_player_rushes_chopper()
{
	// in case chopper left
	level endon ("stream_heli_out");
	
	// wait for trig
	flag_wait("stream_rush_chopper");
	
	// so ai shoot chopper
	flag_set("begin_shoot_chopper");
	
	// so ai see you rushed
	flag_set( "_stealth_spotted" );
}

stream_ai_shoot_down_chopper()
{
	level endon ("smaw_target_detroyed");
	level endon ("stream_heli_out");
	
	flag_wait("begin_shoot_chopper");
	
	level.alpha2 SetEntityTarget( level.chopper_pilot_ent );
	level.alpha2 disable_dontevershoot();
	level.alpha2 set_ignoreall(0);
}

stream_fight_goes_hot()
{
	level endon ( "bridge_area_exit" );
	
	flag_wait_any( "_stealth_spotted", "smaw_target_detroyed" );
			
	// just shut off the stealth stuff on enemies
	ai = GetAIArray("axis");
	foreach (guy in ai)
		guy disable_stealth_for_ai();

	//flag_wait_or_timeout( "smaw_target_detroyed", 30 );
	
	battlechatter_on();
		
	stream_color_trigs = getentarray( "stream_color_trigs", "script_noteworthy" );
	array_thread( stream_color_trigs, ::trigger_on );
	
	if( !flag( "smaw_target_detroyed" ) )
		flag_set( "smaw_target_detroyed" );
	
	array_thread (level.squad, ::delayCall, 2, ::ClearEntityTarget );
	
	flag_wait( "stream_fight_begin" );
	
	// if player rushes ahead dont sent AI back
	if (!flag("abort_chopper_crash"))
	{
		wait (7);
		activate_trigger_with_targetname( "stream_fight_pos_1" );
		level.alpha2 set_force_color ("r");
	}

	array_thread(level.squad, ::disable_cqbwalk );
	array_thread(level.squad, level.ignore_off_func );
}


stream_fight_stealth()
{
	level endon ("_stealth_spotted");
			
	flag_wait( "stream_heli_out" );
	
	wait 7;
		
	stream_color_trigs = getentarray( "stream_color_trigs", "script_noteworthy" );
	array_thread( stream_color_trigs, ::trigger_on );
		
	array_thread (level.squad, ::delayCall, 2, ::ClearEntityTarget );

	activate_trigger_with_targetname( "stream_fight_pos_1" );
	
	level.alpha2 set_force_color ("r");
	
	flag_set( "stream_clear" );
}



second_distant_sat_launch()
{
	flag_wait("second_distant_sat_launch");
	level.player thread play_sound_in_space("jg_sat_launch_distant_second", level.player.origin);
	wait (0.3);
	
	Earthquake(0.15, 5, level.player.origin, 850);
}

watersheet_trig_setup()
{
	level endon( "tall_grass_begin" );
	trig = getent("watersheet", "targetname" );	
	//level.player ent_flag_init("water_sheet_sound");
	level thread watersheet_sound( trig );
	
	while(1)
	{
		trig waittill("trigger" );
		
		level.player SetWaterSheeting( 1, 2 );
		
		wait 0.5;
		
		if (level.player IsTouching(trig))
		{
		level.player SetWaterSheeting( 0 );		
	}	
		else	
		{
			wait 1.5;
}

	}	
}

watersheet_sound( trig )
{
	level endon( "tall_grass_begin" );
	while( 1 )
	{
		trig waittill( "trigger" );
		ent = spawn( "script_origin", level.player GetEye() );
		ent thread play_sound_on_entity("scn_jungle_under_falls_plr_enter");
		ent playloopsound( "scn_jungle_under_falls_plr" );					
		ent scalevolume(0.0, 0.0);
		wait ( 0.1 );
		ent scalevolume(1.0, 0.25);			
		while( level.player istouching( trig ) )
		{
			wait( .10 );
		}
		ent thread play_sound_on_entity("scn_jungle_under_falls_plr_exit");
		wait (0.15);
		ent scalevolume( 0.0, 0.5 );	
		wait ( 0.5 );		
		ent stop_loop_sound_on_entity( "scn_jungle_under_falls_plr" );
		ent delete();
	}		
}



tall_grass_intro_goes_hot()
{
	flag_wait( "tall_grass_intro_goes_hot" );
	array_thread( level.squad, level.ignore_off_func );			
}


deactivate_stream_trigs_until_ambush()
{
	//turning off color trigs until the waterfall ambush is done so player cant go ahead and hit them
	trigs = getentarray("post_ambush", "script_noteworthy" );	
	array_thread( trigs, ::trigger_off );	
	flag_wait_any("waterfall_patrollers_dead", "waterfall_patrollers_passed");	
	array_thread( trigs, ::trigger_on );
}

jungle_cleanup()
{	
	delete_ai_array_safe( level.hill_patrollers );
	delete_ai_array_safe( level.jungle_enemies );
}

#using_animtree("vehicles");
chopper_crash()
{
	level endon ("stream_heli_out");
	
	chopper_crash_enemies();
	thread chopper_rumble_earthquake();
	//script_brushmodel collision at final crash position	
	crash_final_collision = getent( "crash_final_collision", "targetname" );
	crash_final_collision NotSolid();
	
	dest_crate = getent( "dest_crate", "targetname" );
	dest_crate NotSolid();
	dest_crate ConnectPaths();
	
	
	//anim ent
	scene = getstruct("new_crash", "targetname" );
	
	//spawn chopper
	scene.chopper = spawn_vehicle_from_targetname("supply_heli");
	scene.chopper.animname = "aas";
	wait 1;
	//scene.chopper = chopper[0];
	scene.chopper thread chopper_sound();
	scene.chopper Vehicle_TurnEngineOff();
		
	//script_brushmodel collision on the chopper as it crashes
	scene.crate_clip = getent( "chopper_clip", "targetname" );	
	scene.crate_clip.origin = scene.chopper.origin;
	scene.crate_clip.angles = scene.chopper.angles;
	scene.crate_clip linkto( scene.chopper, "tag_origin" );
	scene.crate_clip thread notify_on_damage();
 	level.chopper_pilot_ent= scene.crate_clip;	//ent for Ai to shoot 
 	
 	spawner = getent("chopper_pilot", "targetname");
	spawner SetSpawnerTeam("axis");
 
	//spawn rest of actors
	scene.pristine_crate = spawn_anim_model( "pristine_crate" );
	scene.damaged_crate = spawn_anim_model( "damaged_crate" );
	
	scene.damaged_crate hide();
	
	scene.pilot = spawn_targetname( "chopper_pilot", 1 );
	scene.pilot.animname = "pilot";
	scene.pilot.team = "axis";
	scene.pilot.name = "";
	//scene.pilot LinkTo( scene.chopper );
	scene.pilot thread crash_pilot_logic( scene.chopper );
	/*
	//corpse of pilot
 	scene.pilot_corpse = spawn( "script_model", scene.origin );
	scene.pilot_corpse setmodel( scene.pilot.model );
	scene.pilot_corpse.animname = "pilot";
	scene.pilot_corpse UseAnimTree( #animtree );
	scene.pilot_corpse.origin = scene.chopper GetTagOrigin( "tag_driver" );
	scene.pilot_corpse.angles = scene.chopper GetTagangles( "tag_driver" );
	scene.pilot_corpse linkto( scene.chopper );
	scene.pilot_corpse SetAnimKnob( %jungle_ghost_helicrash_pilot, 1, 0, 0 );
	scene.pilot_corpse SetAnimTime( %jungle_ghost_helicrash_pilot, 1 );
	scene.pilot_corpse hide();
	*/
	
	//everyone in an array!
	scene.actors = [  scene.pristine_crate, scene.damaged_crate, scene.chopper ];
	
	//check for damage
	//array_thread( scene.actors, ::notify_on_damage );
	
	//play the idle on everyone
	scene.pilot linkto (scene.chopper, "tag_pilot1", (0,0,0), (0,0,0));
	scene.chopper thread anim_loop_solo( scene.pilot, "new_crash_idle", "stop_loop", "tag_pilot1" );
	scene thread anim_loop( scene.actors, "new_crash_idle" );


	
	scene thread chopper_leaves_after_time();
	
	//wait for the damage to happen
	flag_wait( "smaw_target_detroyed" );
		
	anim_time =  GetAnimLength( %jungle_ghost_helicrash_helicopter ); 
	
	//kill anyone touching the collmap while its crashing
	scene.crate_clip thread crate_clip_of_doom();
	scene.crate_clip thread notify_delay( "stop_checking_collision", anim_time );
	delayThread( anim_time, ::flag_set, "chopper_crash_complete" );
	
	//allies_bad_place = (1472, 5344, 512);
	//BadPlace_Cylinder( "allies_avoid_crash", anim_time - 2, allies_bad_place, 208, 70, "allies" );
	
	scene notify( "stop_loop" );
	scene.chopper notify ("stop_loop");
	scene.pilot notify ("stop_loop");
	
	//play the crash scene
	scene thread anim_single( scene.actors, "new_crash" );
	

	scene.chopper thread anim_single_solo( scene.pilot, "new_crash", "tag_pilot1" );
	scene.pilot linkto (scene.chopper, "tag_pilot1");
	
	music_play("mus_jungle_chopper_crash_battle", 1);
	//scene thread anim_last_frame_solo( scene.pilot, "new_crash" );
}

chopper_leaves_after_time()
{
	level endon ("smaw_target_detroyed");
	self.chopper endon ("death");
	
	flag_wait("can_see_chopper");
	flag_wait("time_for_chopper_to_leave");
	
	self notify ("stop_loop");
	self.chopper notify ("stop_loop");
	self.pilot notify ("stop_loop");
	
	flag_set("stream_heli_out");
	
	self.pristine_crate LinkTo(self.chopper, "tag_origin");

	
	self.chopper thread anim_loop_solo( self.pilot, "new_crash_idle", "stop_loop", "tag_pilot1" );
	//self.pilot LinkTo(self.chopper, "tag_pilot1", (0,0,0),(0,0,0));
	
	org1 = getent("supply_chopper_leave","targetname");
	org2 = getent(org1.target,"targetname");
	org3 = getent(org2.target,"targetname");
	
	self.chopper setlookatent( org1 );
	self.chopper SetVehGoalPos(org1.origin, 1);
	self.chopper Vehicle_SetSpeed(60, 1, 1);
	wait 10;
	self.chopper setlookatent( org2 );
	self.chopper SetVehGoalPos(org2.origin, 1);
	wait 10;
	self.chopper setlookatent( org3 );
	self.chopper SetVehGoalPos(org3.origin, 1);
	
	wait 22;
	
	if (IsDefined(self.pilot))
		self.pilot delete();

	if (IsDefined(self.pristine_crate))
		self.pristine_crate delete();

	if (IsDefined(self.damaged_crate))
		self.damaged_crate delete();

	if (IsDefined(self.chopper))
		self.chopper delete();	
}

chopper_rumble_earthquake()
{
	flag_wait("chopper_impact");
	earthquake( .6, .75, level.player.origin, 800 );
	level.player PlayRumbleOnEntity( "grenade_rumble");
	wait (.8 );
	earthquake( .4, .5, level.player.origin, 800 );
	level.player PlayRumbleOnEntity( "grenade_rumble");
}

chopper_sound()
{
	self thread play_loop_sound_on_entity ("aascout72x_engine_high" );
	
	flag_wait("smaw_target_detroyed" );
	wait 2;
	self thread play_loop_sound_on_entity( "aascout72x_helicopter_dying_loop" );
	wait .5;
	self thread stop_loop_sound_on_entity( "aascout72x_engine_high" );
	
	flag_wait("chopper_impact");
	self thread play_sound_on_entity( "aascout72x_helicopter_crash" );
	self thread stop_loop_sound_on_entity( "aascout72x_helicopter_dying_loop" );
	
	self delaythread( .8,  ::play_sound_on_entity, "aascout72x_helicopter_hit" );
	
	wait 1.5;
	
	//detail sounds
	for( i=0; i< 2; i++ )
	{
		self thread play_sound_on_entity( "aascout72x_helicopter_crash_detail" );
		wait( randomfloatrange( .3, .9 ) );
	}
	
	self notify( "stop_kicking_up_dust" );

}

#using_animtree("generic_human");
crash_pilot_logic( chopper )
{
	self.ignoreme = 1;
	self.ignoreall = 1;
	//self thread deletable_magic_bullet_shield();
	
	self.ragdoll_immediate = true;
	
	flag_wait("chopper_impact");
	//self stop_magic_bullet_shield();
	//self forceteleport( chopper GetTagOrigin( "tag_driver") , chopper GetTagangles( "tag_driver" ) );
	wait 3;
	
	
	self.allowDeath = true;
	self.a.nodeath = true;
	
	self die();
	self StartRagdoll();
	//self linkto( chopper );
//	wait.05;
//	self SetAnimKnob( %jungle_ghost_helicrash_pilot, 1, 0, 0 );
//	wait .05;
//	
//	self SetAnimTime( %jungle_ghost_helicrash_pilot, 1 );
	
}

notify_on_damage()
{
	level endon ("stream_heli_out");
		
	self setcandamage( true );	
	self waittill( "damage", amount, attacker, direction, point, type, model, tag, part, dFlags, weapon );

	delay_for_squad_to_keep_shooting = 0.5;
	
	if(!flag( "smaw_target_detroyed" ) )
	{
		if( isdefined( attacker ) )
		{
			if( is_in_array( level.squad, attacker ) ) //worldspawn is from magicbullet
			{	
				wait ( delay_for_squad_to_keep_shooting );
				flag_set( "smaw_target_detroyed" );				
			}
			else if( attacker == level.player )
			{
				wait ( delay_for_squad_to_keep_shooting );					
				flag_set( "smaw_target_detroyed" );	
			}
		}
	}
}

crate_clip_of_doom()
{

	//self = clip script_brushmodel
	self endon( "stop_checking_collision" );	
	baddies = getaiarray( "axis" );
	baddies = add_to_array( baddies, level.player );
	while(1)
	{
		foreach( guy in baddies )			
		{
			if(  isalive( guy ) && guy istouching( self ) )
				guy thread die();
		}
		wait(.05 );
	}
}


chopper_crash_enemies()
{
	array_spawn_function_targetname( "crate_casualty", ::chopper_crash_guy_logic );
	array_spawn_function_targetname( "crate_casualty", ::crate_casualty_enemy_logic );
	array_spawn_function_targetname( "bridge_guard", ::on_death_start_chopper_crash );

			
	array_spawn_targetname( "crate_casualty", 1 );
	thread stream_enemy_setup( "start" );
	
	level.crash_hidden_settings[ "prone"  ] = 70;//70
	level.crash_hidden_settings[ "crouch" ] = 300;//600 450
	level.crash_hidden_settings[ "stand"  ] = 450;//1024
	
	maps\_stealth_utility::stealth_detect_ranges_set( level.crash_hidden_settings );
	
}

crate_death_fling()
{
	//self waittill ("death");
	self animscripts\shared::DropAllAIWeapons();
	self.skipDeathAnim = true;
	
	dir =  AnglesToForward( VectorToAngles(getstruct("crate_do_damage2","targetname").origin - getstruct("crate_do_damage","targetname").origin));
	dir *= RandomFloatRange( 1500, 3000 ); 
	self StartRagdollFromImpact(self.damagelocation, dir);
	wait( 0.05 );
	
	
//	dir = AnglesToForward( VectorToAngles( self.origin - level.player.origin ) + ( -20, RandomFloatRange( -10, 10 ), 0 ) ); 
//     dir *= RandomFloatRange( 1500, 3000 ); 
//     self StartRagdollFromImpact( self.damagelocation, dir ); 
//      
//     wait( 0.05 ); 
// 
	
	
}

stream_enemy_setup( start)
{	
//smaw_target_detroyed

	// on enter
	array_spawn_function_targetname( "close_guys", ::stream_close_enemy_logic );
	array_spawn_function_targetname( "close_guys", ::on_death_start_chopper_crash );
	
	array_spawn_function_targetname( "bridge_guard", ::stream_bridge_guard_logic );
	array_spawn_function_targetname( "bridge_guard", ::on_death_start_chopper_crash );

	// if hot
	array_spawn_function_targetname( "upper_stream_right", ::stream_upper_logic );
	array_spawn_function_targetname( "upper_stream_left", ::stream_upper_logic );
	array_spawn_function_noteworthy( "stream_enemies", ::stream_enemy_logic );
	
	// waterfall 
	array_spawn_function_targetname( "ambush_patrol", ::ambush_patrol_logic );
	
	// if hot at waterfall
	array_spawn_function_targetname( "stream_backend_enemies", ::stream_enemy_logic );
	
	// steath near tall grass
	array_spawn_function_targetname( "tall_grass_intro_guys_stealth", ::pre_tallgrass_stealth_guys_logic );

		
	switch ( start )
	{
		case "start":
	
		array_spawn_targetname("close_guys", 1 );
		array_spawn_targetname("bridge_guard", 1 );
	
		flag_wait_any( "smaw_target_detroyed","player_rushed_chopper_crash", "stream_heli_out" );		
		flag_set("stream_fight_begin" );
		
		thread stream_enemy_setup_on_going_hot();
		

		
		baddies = getaiarray( "axis" );
		
		// do this so patrol around corner guys aren't counted and friendly AI moveup
		if (!isdefined(level.ambush_patrol_guys))
		{
			level.ambush_patrol_guys = [];
		}
		baddies = array_remove_array(baddies, level.ambush_patrol_guys);
	
		thread set_flag_when_x_remain(  baddies, 0, "stream_clear" );
		
		flag_wait( "stream_clear" );
				
		flag_wait("bridge_area_exit");
		level.alpha2 set_force_color ("r");	// just in case
		
	case "waterfall":
		
		level.ambush_patrollers = array_spawn_targetname( "ambush_patrol", 1 );
		level thread ambush_kickoff_logic();
		flag_wait( "player_in_ambush_position" );
		
		flag_wait_or_timeout( "ambush_open_fire", 6 );
				
		level.ambush_patrollers = array_removedead_or_dying( level.ambush_patrollers );
		
		level thread waterfall_check_patrollers();
		
		//plays some chatter on the guys
		num = randomintrange( 0, 4 );
		cover_me = "SP_" +num+ "_order_action_coverme";
		
		num = randomintrange( 0, 4 );
		roger = "SP_" +num+ "_resp_ack_co_gnrc_affirm";
		
		if (IsDefined(level.ambush_patrollers[0]))
		{
			level.ambush_patrollers[0] delayThread( 1.5, ::play_sound_on_tag, cover_me, undefined, true );
			level.ambush_patrollers[0] delayThread( 3, ::play_sound_on_tag, roger, undefined, true );
		}
				
		flag_wait_any("waterfall_patrollers_dead", "waterfall_patrollers_passed");
		
		
		
	case "backend":
	
		flag_wait( "stream_backend_start" );

		level thread maps\jungle_ghosts_jungle::jungle_stealth_settings();
		// take these out based on conditions later
		if (flag("ambush_open_fire"))
		{
			array_thread(level.squad, level.ignore_off_func );
		}
		
		level.player.ignoreme = false;
		
		chopper = spawn_vehicle_from_targetname_and_drive( "stream_ambient_heli" );
		chopper mgoff();
		thread tall_grass_globals();
		//thread tall_grass_enemy_setup();
		
		if (flag("ambush_open_fire"))
		{
			stream_backend_enemies = array_spawn_targetname("stream_backend_enemies", 1 );
		wait(4.5);
		start = (4562, 7708, 844);
		end = (4600, 5640, 810);
		missile = MagicBullet( "rpg_straight", start, end );
		missile thread escape_earthquake_on_missile_impact();
		battlechatter_on();
	}
	}
}

on_death_start_chopper_crash()
{
	level endon ("stream_heli_out");
				 
	self waittill_any("death", "damage");
	wait RandomFloatRange(0.25, 1.0);
	flag_set ("smaw_target_detroyed");
}
	
pre_tallgrass_stealth_guys_logic()
{
	self endon ("death");
	
	flag_wait( "_stealth_spotted" );
	flag_set("backend_friendlies_go_hot");
	wait randomintrange( 1, 3 );
	self disable_stealth_for_ai();
	self.goalradius = 250;
	self SetGoalEntity( level.player );	
}
	
waterfall_check_patrollers()
{
	level endon ("stream_exit");

	waittill_dead_or_dying( level.ambush_patrollers );
	flag_set("waterfall_patrollers_dead");
}

stream_enemy_setup_on_going_hot()
{
	level endon ("bridge_approach");
	flag_Wait_any("_stealth_spotted", "smaw_target_detroyed");
	
	thread spawn_ai_throttled_targetname( "lower_stream_group_1", 1, 2.5 );
				
	wait( 2 );
	if( cointoss() )
		guys = "upper_stream_left";
	else
		guys = "upper_stream_right";
		
	thread spawn_bridge_guys( guys );
		
	waittill_notify_or_timeout( "done_throttled_spawn", 7 );
}

stream_upper_logic()
{
	self.goalradius = 64;
	self SetGoalNode(getnode(self.target, "targetname"));
}

stream_close_enemy_logic()
{
	level endon ("_stealth_spotted");
	self endon ("death");
	
	flag_wait("stream_heli_out");
	
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	
	self waittill("goal");
	self Delete();
}

stream_bridge_guard_logic()
{
	level endon ("_stealth_spotted");
	self endon ("death");
	
	flag_wait("stream_heli_out");
	self.goalradius = 64;
	
	wait 3;
	self SetGoalNode(getnode("bridge_guard_run_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("bridge_guard_run_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("bridge_guard_run_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("bridge_guard_run_node", "targetname"));
	
	self waittill("goal");
	self Delete();
}

crate_casualty_enemy_logic()
{
	level endon ("_stealth_spotted");
	self endon ("death");
	
	flag_wait("stream_heli_out");
	self.goalradius = 64;
	
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	wait 3;
	self SetGoalNode(getnode("close_guys_run_away_node", "targetname"));
	
	self waittill("goal");
	self Delete();
}

ambush_stealth_settings()
{	
	array = [];
	array[ "player_dist" ] 		 = 1;// this is the max distance a player can be to a corpse
	array[ "sight_dist" ] 		 = 1;// this is how far they can see to see a corpse
	array[ "detect_dist" ] 		 = 1;// this is at what distance they automatically see a corpse
	array[ "found_dist" ] 		 = 1;// this is at what distance they actually find a corpse
	array[ "found_dog_dist" ] 	 = 1;// this is at what distance they actually find a corpse
	
	maps\_stealth_utility::stealth_corpse_ranges_custom( array );
	
	level.ambush_hidden_settings			 = [];
	level.ambush_hidden_settings[ "prone"  ] = 1;//70
	level.ambush_hidden_settings[ "crouch" ] = 1;//600 450
	level.ambush_hidden_settings[ "stand"  ] = 1;//1024
	
	level.ambush_visible_settings = [];
	level.ambush_visible_settings[ "prone" ]	 = 400;//70
	level.ambush_visible_settings[ "crouch" ]	 = 400;//600 450
	level.ambush_visible_settings[ "stand" ]	 = 400;//1024
			
}

player_ambush_area_monitor( trig )
{
	//if the player isnt hidden when the enemies come, dont play the reaction anim and crank up their accuracy. 	
	level endon( "ambush_open_fire" );
	level endon( "waterfall_patrollers_passed" );
	
	player_is_hidden = true;
	hidden_accuray = .5;
	visible_accuracy = 10;
	
	trig waittill("trigger");
	flag_set ( "player_in_ambush_position" );
	
	while ( 1 )
	{
		while( level.player istouching( trig ) )
		{
			wait .25;
		}
		
		flag_clear( "player_in_ambush_position" );
		maps\_stealth_utility::stealth_detect_ranges_set( level.ambush_visible_settings );
		array_thread( level.ambush_patrollers, maps\_stealth_shared_utilities::ai_clear_custom_animation_reaction );
		array_thread( level.ambush_patrollers, ::set_baseaccuracy, visible_accuracy );
		
		while( !level.player istouching( trig ) )
		{
			wait .25;
		}
		
		flag_set ( "player_in_ambush_position" );
		maps\_stealth_utility::stealth_detect_ranges_set( level.ambush_hidden_settings );
		foreach( guy in level.ambush_patrollers )
		{
			guy thread maps\_stealth_shared_utilities::ai_set_custom_animation_reaction( guy, guy.script_noteworthy, "tag_origin", "steve_ender");
			guy thread set_baseaccuracy( hidden_accuray);	
		}
	             
	}
	
}


spawn_bridge_guys( name )
{
	//need to spawn the script_noteworthy guy first. he stops and does covering fire. 
	spawners = getentarray( name, "targetname" );	
	foreach( s in spawners )
	{
		if( isdefined( s.script_noteworthy ) )
		{
			guy = s spawn_ai( 1 );
			guy thread stream_enemy_logic();
			guy enable_sprint();
			spawners = array_remove( spawners, s );
			break;
		}
	}
	
	wait 2;	
	foreach( s in spawners )
	{
		guy = s spawn_ai( 1 );
		guy thread stream_enemy_logic();
		guy enable_sprint();
		wait( randomfloatrange( 2, 4 ) );
	}
	
}

orient_to_ent_point( ent )
{
	ent endon ( "death" );
	self endon ( "death" );
	self endon ( "stop_orient_to_ent" );
	
	//angle = vectortoangles( ent.origin - self.origin  );
	
	vec = vectornormalize( self.origin - ent.origin );
	start_spot = self.origin + vec;
	
	while ( true )
	{
		self orientmode( "face point", ent.origin );
		//self orientmode( "face direction", vector );//todo this seems to work but mess with these optional params and see if it improves
		//self thread draw_line_from_ent_to_vec_for_time( self, vector, 10000, 1, 0, 0, .05 );
		wait 0.05;
	}
}

stream_enemy_logic()
{
	self.goalradius = 32;
	self set_ai_bcvoice( "shadowcompany" );
	self disable_long_death();
	self disable_blood_pool();
	self thread grenade_ammo_probability( 20 );
	self forceuseweapon( "sc2010", "primary" ); //these guys use non-silenced
	//self set_baseaccuracy( 2 );
	
}

ambush_patrol_logic()
{
	self endon( "death" );
	
	if (!isdefined(level.ambush_patrol_guys))
	{
		level.ambush_patrol_guys = [];
	}
	
	level.ambush_patrol_guys = array_add(level.ambush_patrol_guys, self);
	
	self.oldmaxsight 	 = self.maxsightdistsqrd;
	self.maxsightdistsqrd = 1;
	//if( cointoss() )		
	
	self enable_cqbwalk();
	/*
	else
	{
		self.animname = "generic";
		self set_run_anim("patrol_walk_creepwalk");
		self set_moveplaybackrate( 1.2 );
	}
	*/	
	self set_ai_bcvoice( "shadowcompany" );
//	self.ignoreme = 1;
//	self.ignoreall = 1;
	self.goalradius = 32;
	self set_grenadeammo( 0 );	
	self thread ambush_damage_notify();
	self disable_long_death();
	self.animname = "generic";
	self thread ambush_guy_outcome_logic();
	self thread ambush_guy_change_sight_dist();
	
	
	if( self has_script_parameters("orders_guy") )
	{
		self thread ambush_guy_does_anim("patrol_jog_orders_once");
		return;
	}
	
	if( self has_script_parameters("360_guy") )
	{
		self thread ambush_guy_does_anim("patrol_jog_360_once");
		return;
	}
	
	self maps\_stealth_shared_utilities::ai_set_custom_animation_reaction( self, self.script_noteworthy, "tag_origin","steve_ender");	
	
	wait 50;
	
	while (isdefined(self))
	{
		if (!player_can_see_ai(self))
		{
			array_remove(level.ambush_patrollers, self);
			self delete();
		}
		
		wait (0.5);
	}
}

ambush_guy_change_sight_dist()
{
	self endon ("death");
	
	trig = getent("hidden_in_waterfalls","targetname");
	
	while (1)
	{
		if (level.player istouching(trig))
		{
			
			self.maxsightdistsqrd = 1;
		}
		else
		{
			 self.maxsightdistsqrd = self.oldmaxsight;
		}
		wait (0.5);
	}
}

ambush_guy_outcome_logic()
{
	self endon ("death");
	
	flag_wait( "ambush_open_fire" );
	
	wait( .5 );
	self.maxsightdistsqrd = self.oldmaxsight;
	if( flag( "player_didnt_ambush" ) )
	{
		flag_set( "waterfall_ambush_begin" );
		self StopAnimScripted();
		self disable_cqbwalk();
		//self set_baseaccuracy( 1000 );
		//self maps\_spawner::scrub_guy();
		self.perfectAim = 1;
		self.favoriteenemy = level.player;
		//self.goalradius = 100;
		//self enable_sprint();
		return;
		//self SetGoalEntity( level.player );
	}
	
	wait( randomintrange( 5, 7 ) );
	
	if( IsAlive( self ) )
		self kill_me_from_closest_enemy();
	
}


ambush_guy_does_anim( struct_noteworthy )	
{
	self endon("death");
	flag_wait( "waterfall_ambush_begin" );
	//self thread stop_anim_on_damage();
	self disable_cqbwalk();
	self set_generic_run_anim( "patrol_jog" );
	
	node = getstruct( struct_noteworthy, "script_noteworthy" );
	node anim_reach_solo( self, struct_noteworthy );
	node anim_single_solo( self, struct_noteworthy );
}


ambush_damage_notify()
{	
	self thread maps\_stealth_utility::stealth_enemy_endon_alert();
	self waittill_any( "damage", "bulletwhizby", "stealth_enemy_endon" );
	level notify("ambush_enemy_shot");
	
	flag_set( "ambush_open_fire" );	
	
	self stopanimscripted();	
}


ambush_kickoff_logic()
{
	thread ambush_player_ran_ahead();
	thread ambush_player_did_ambush();
	
	array_thread( level.squad, level.ignore_on_func );
}


ambush_player_ran_ahead()
{
	level endon ("waterfall_patrollers_passed");
	level endon ("waterfall_patrollers_dead");
	
	trig = getent( "ambush_early", "targetname" );
	trig waittill("trigger");
	thread sky_change();
	flag_set("player_didnt_ambush");
	flag_set("player_in_ambush_position");
	maps\_stealth_utility::disable_stealth_system();
	
	//player is sprinting ahead
	flag_wait("stream_backend_start");
	
	if(!flag("waterfall_patrollers_dead") && !flag("waterfall_patrollers_passed"))	
	{
		wait 2;
		kill_player_from_closest_enemy();
	}
}

ambush_player_did_ambush()
{
	level endon ("ambush_enemy_shot");
	
	flag_wait( "player_in_ambush_position" );
	thread sky_change();
	wait( .5 );

	time_to_pass = 13;
	
	if( !flag("player_didnt_ambush") )	
	{
		wait time_to_pass;
		level notify("ambush_safe_timeout");	
		flag_set("waterfall_patrollers_passed");
	}	
}

chopper_crash_guy_logic()
{
	self endon( "death" );	
	self set_ai_bcvoice( "shadowcompany" );
//	self.ignoreme = 1;
//	self.ignoreall = 1;
//	self.anchor = spawn("script_origin", self.origin );
//	self linkto ( self.anchor );
	self.goalradius = 32;
	self set_grenadeammo( 0 );	
	//self thread ambush_damage_notify();
	self disable_long_death();
	self.animname = "generic";
//	self.ignoreme = 1;
	self.deathFunction = ::crate_death_fling;
//	self thread stop_anim_on_damage();
	
//	level waittill( "smaw_target_detroyed" );
	
	//self maps\_stealth_utility::disable_stealth_system();
	
//	if( randomint( 100 ) > 60 )
//	{
//		my_anim = "explo_react1";
//		if( randomint( 100 ) > 60 )
//			my_anim = "explo_react2";	
//		self thread anim_single_solo( self, my_anim );
//	}
//	
//	wait 1.5;
//	self.ignoreme = 0;

}

stop_anim_on_damage()
{
	self endon( "death" );
	self waittill( "damage" );
	self StopAnimScripted();
}


/*=-=-=-=-=-=-=-
tall grass 
=-=-=-=-=-=-=-=-*/

const_base_accurcay = 5;
const_base_elevated_threat_bias = 100000;
const_time_before_going_hot = 9;

//music: DKR: 01,
tall_grass_globals(no_suppression)
{	
	thread tall_grass_moving_grass_settings();
	thread tall_grass_vo();
	thread tall_grass_weather();
	level.player_stalker = level.player; //this gets set to an enemy att he start of the event
	flag_wait( "to_grassy_field" );
	
	if (!isdefined(no_suppression) && flag( "ambush_open_fire" ))	
	{
		thread tall_grass_intro_suppression();
		delayThread( 7, ::flag_set, "tall_grass_intro_goes_hot" );
	}
	//vision_set_changes( "jungle_tall_grass_arrive", 5 );
	//thread tall_grass_intro_smoke();
	//battlechatter_on();
	level.player setviewkickscale( .5 );
	level.player setmovespeedscale(.8);
	setsaveddvar( "player_sprintspeedscale", 1.2 ); //default 1.5
		
	//level thread tall_grass_ai_dist_monitor();
	
	createthreatbiasgroup( "axis_preffered_targets" );
	setthreatbias( "axis", "axis_preffered_targets", const_base_elevated_threat_bias );
	
	array_thread( level.squad, ::set_baseaccuracy, .5 );
	
	
	flag_wait("field_entrance" );		
	
	thread grass_aas_approach();
		
	
	wait 4;
	music_play( "mus_jungle_tall_grass_intro" );
	
	thread tall_grass_watch_player_jump();
	//custom DoF
//	maps\_art::dof_enable_script( 0, 153.242, 4, 5000, 7000, 1.8, 3 );
//	thread tall_grass_player_stalker();
//	thread tall_grass_ignore_control();
	thread tall_grass_death_hint();

	//flag_wait("field_end");
//	maps\_art::dof_disable_script( 3 );
}

grass_aas_approach()
{
	array_spawn_function_targetname("tall_grass_chopper_guys", ::aas_guys_spawn_logic );
	
	if (level.player.origin[0] > 4000)
	{
		aas[0] = spawn_vehicle_from_targetname_and_drive("chops_r1");
		aas[1] = spawn_vehicle_from_targetname_and_drive("chops_r2");
		aas[2] = spawn_vehicle_from_targetname_and_drive("chops_r3");
	}
	else
	{
		aas[0] = spawn_vehicle_from_targetname_and_drive("chops_l1");
		aas[1] = spawn_vehicle_from_targetname_and_drive("chops_l2");
		aas[2] = spawn_vehicle_from_targetname_and_drive("chops_l3");
	}
	
	array_thread(aas, ::aas_think);
	
	level thread tall_grass_stealth_settings();
	//level thread tall_grass_player_logic();
}

aas_think()
{
	wait (7);
	self notify( "stop_kicking_up_dust" );
}

aas_guys_spawn_logic()
{
	self endon ("death");
	//self.ignoreme = 1;
	//self.ignoreall = 1;
	
	self set_ai_bcvoice( "shadowcompany" ); //shadowcompany = Spanish
	self.grenadeammo = 0;

	self thread enable_cqbwalk();

	self thread tall_grass_guys_path_to_trees();
	self thread tall_grass_guys_went_hot();
	
	// they got shot at
	self waittill ("damage");
	flag_set ("grass_went_hot");
	level.player.ignoreme = 0;
}

tall_grass_guys_went_hot()
{
	self endon("death");
	
	flag_wait ("grass_went_hot");
	
	self disable_cqbwalk();
	self disable_stealth_for_ai();
}

tall_grass_guys_path_to_trees()
{
	self endon("death");
		
	level endon ("grass_went_hot");
	
	self waittill ("unload");
	flag_set("tall_grass_heli_unloaded");

	self set_moveplaybackrate(0.5);
	path_starts = getstructarray("tall_grass_guys_paths_out","targetname");
	
	use_point = undefined;

	while (!isdefined(use_point) || path_starts.size > 0)
	{
		closest = getClosest(self.origin, path_starts);
		if (!IsDefined(closest.used))
		{
			closest.used = 1;
			use_point = closest;
			break;
		}
		path_starts = array_remove(path_starts, closest);
	}

	self follow_path(use_point);	
}

tall_grass_player_logic()
{
	level endon ("grass_went_hot");
	
	while (1)
	{
		if (level.player GetStance() == "crouch" || level.player GetStance() == "prone")
		{
			level.player.ignoreme = 1;
		}
		else
		{
			level.player.ignoreme = 0;
		}
		waitframe();
	}
}

tall_grass_stealth_settings()
{
	jungle_hidden = [];
	jungle_hidden[ "prone" ]	 = 70;//70
	jungle_hidden[ "crouch" ]	 = 70;//600 450
	jungle_hidden[ "stand" ]	 = 300;//1024
		
	jungle_spotted = [];
	jungle_spotted[ "prone" ]	 = 500; //512;
	jungle_spotted[ "crouch" ]	 = 1500; //5000;
	jungle_spotted[ "stand" ]	 = 2000; //8000;
	
	maps\_stealth_utility::stealth_detect_ranges_set( jungle_hidden, jungle_spotted );

	array = [];
	array[ "player_dist" ] 		 = 50;//1500;// this is the max distance a player can be to a corpse
	array[ "sight_dist" ] 		 = 50;//1500;// this is how far they can see to see a corpse
	array[ "detect_dist" ] 		 = 50;//256;// this is at what distance they automatically see a corpse
	array[ "found_dist" ] 		 = 50;//96;// this is at what distance they actually find a corpse
	array[ "found_dog_dist" ] 	 = 50;//50;// this is at what distance they actually find a corpse

	maps\_stealth_utility::stealth_corpse_ranges_custom( array );

}



tall_grass_death_hint()
{
	level endon("field_end");
	
	level.player waittill( "death" );
	level notify( "new_quote_string" );
	
	if( cointoss() )
		setdvar( "ui_deadquote", &"JUNGLE_GHOSTS_GRASS_DEATH_HINT1" );		
	else
		setdvar( "ui_deadquote", &"JUNGLE_GHOSTS_GRASS_DEATH_HINT2" );					
}

sky_change()
{
	//
	//this func gets called from 2 different locations and gets run depending on where the player goes
	if( flag("skybox_changed" ) )
		return;
	
	if( game_is_current_gen() )
	{	
		current_sunlight = GetMapSunLight();
		new_sunlight = (206/256, 225/256, 255/256 );
		thread sun_light_fade( current_sunlight, new_sunlight, 10 );
	}
	
	flag_set("skybox_changed");	
	if( isdefined( level.rain_skybox ) )
		level.rain_skybox show();
}

tall_grass_weather()
{	
	//jungle_overcast_sky
	flag_wait("tall_grass_intro_goes_hot");
	thread thunder_and_lightning( 10, 15 );	
	
//	current_sunlight = GetMapSunLight();
//	new_sunlight = (206/256, 225/256, 255/256 );
//	thread sun_light_fade( current_sunlight, new_sunlight, 3 );
	//noself_delayCall( 3,  ::setsunlight, 206/256, 225/256, 255/256 );
	
	flag_wait( "prone_guys_getup" );	
	thread start_raining();
	thread thunder_and_lightning( 8, 12 );	
	//set_audio_zone("jungle_ghosts_escape_rain", 10);	
	level.player SetClientTriggerAudioZone( "jungle_ghosts_escape_rain", 10 );		
	
}

tall_grass_intro_smoke()	
{
	spots = [(4271, 9330, 648), (4942, 9954, 765)];
	foreach( spot in spots )
	{
		MagicGrenade( "smoke_grenade_american", spot +(0,0,20), spot, 1 );
	}
	
}

CONST_WIND_STRENGTH = 1;
CONST_WIND_AMPLITUDE = .2;

tall_grass_moving_grass_settings()
{
/*
"r_reactiveMotionWindDir" - Controls the global wind direction. Steve: 3d vector -1 to 1 ( 1 -1 0 ) for example
"r_reactiveMotionWindStrength" - Scale of the global wind direction . 1 = normal 50 = WINDY 1-- looks dumb. 
"r_reactiveMotionWindAreaScale" - Scales distribution of wind motion . Steve: Makes the grass more bendy instead of stiff, Shouldnt go past 10ish.. 
"r_reactiveMotionWindAmplitudeScale" - Scales amplitude of wind wave motion. Steve* How much the grass actually moves. .1 = subtle. 1 = Theres wind. 2 = WINDY. .  

r_reactiveMotionPlayerRadius: Radial distance from the player that influences reactive motion models (inches) 
r_reactiveMotionActorRadius: Radial distance from the ai characters that influences reactive motion models (inches) 
r_reactiveMotionActorVelocityMax: AI velocity considered the maximum when determining the length of motion tails (inches/sec) 
r_reactiveMotionVelocityTailScale: Additional scale for the velocity-based motion tails, as a factor of the effector radius

r_reactiveMotionWindFrequencyScale: scales the frequency of the system's wind wave motion
*/
	//SetSavedDvar( "r_reactiveMotionPlayerRadius", 60 );
	SetSavedDvar( "r_reactiveMotionActorRadius", 80 );
	SetSavedDvar( "r_reactiveMotionWindDir", ( -1, 0, 1 ) );
	
	
	adjust_moving_grass( 2, 1, .5 );	
	flag_wait("field_entrance" );
	adjust_moving_grass( 1, 1, .05, .5 );
	thread tall_grass_wind_gust_logic();
}

tall_grass_wind_gust_logic()
{
	chopper_arrive_wind_gust();
		
	level endon( "field_end" );
	
	while(1)
	{
		wait( randomintrange( 5, 9 ) );
		tall_grass_do_wind_gust();
	}
	
}

tall_grass_do_wind_gust()
{
	//IPrintLn( "wind gust start" );
	if( flag( "adjusting_wind" ) )
		return;
	
	flag_set("adjusting_wind" );
	
	//strength
	level.player delayThread( .5, ::play_sound_on_entity, "elm_wind_leafy_jg" );
	gust_strength = randomfloatrange( 2.5, 4.5 );//1.5, 3
	thread blend_wind_setting_internal( gust_strength, "r_reactiveMotionWindStrength" );
	
	//amplitude
	gust_amplitude = randomfloatrange( 2.5, 4 );//1.5, 2.5
	blend_wind_setting_internal( gust_amplitude, "r_reactiveMotionWindAmplitudeScale" );
		
	//restore to current (the blend wasnt ending the exact place it started )
	thread blend_wind_setting_internal( CONST_WIND_STRENGTH, "r_reactiveMotionWindStrength" );	
	blend_wind_setting_internal( CONST_WIND_AMPLITUDE, "r_reactiveMotionWindAmplitudeScale" );	
	
	flag_clear( "adjusting_wind" );
	//IPrintLn( "wind gust end" );
}

chopper_arrive_wind_gust()
{
	//strength
	level.player delayThread( .5, ::play_sound_on_entity, "elm_wind_leafy_jg" );
	gust_strength = randomfloatrange( 2.5, 4.5 );//1.5, 3
	thread blend_wind_setting_internal( gust_strength, "r_reactiveMotionWindStrength" );
	
	//amplitude
	gust_amplitude = randomfloatrange( 2.5, 4 );//1.5, 2.5
	blend_wind_setting_internal( gust_amplitude, "r_reactiveMotionWindAmplitudeScale" );
		
	wait 13;
	
	//restore to current (the blend wasnt ending the exact place it started )
	thread blend_wind_setting_internal( CONST_WIND_STRENGTH, "r_reactiveMotionWindStrength" );	
	blend_wind_setting_internal( CONST_WIND_AMPLITUDE, "r_reactiveMotionWindAmplitudeScale" );	
}


tall_grass_get_enemies_except_prone_and_rpg_guys()
{
	current_baddies = getaiarray("axis");
	
	return current_baddies;
}

tall_grass_intro_guys_logic()
{

	self endon("death");
	
	level.tall_grass_intro_enemies = add_to_array( level.tall_grass_intro_enemies, self );
	
	self set_ai_bcvoice( "shadowcompany" );
	self disable_long_death();
	self.dropweapon = false;
	self [[level.ignore_on_func]]();
	self.goalradius = 32;
	self.baseaccuracy = 10;
	self grenade_ammo_probability( 30 );	
	
	flag_wait( "tall_grass_intro_goes_hot" );	
	self [[level.ignore_off_func]]();
	
	flag_wait("tall_grass_intro_halfway");
	self [[level.ignore_on_func]]();
	self set_forcegoal();
	self enable_sprint();
	self.goalradius = 32;
	self SetGoalNode( self.retreat_node );
	
	self waittill ("goal" );
	self unset_forcegoal();		
	self AllowedStances("crouch");

}


infinite_ammo()
{
	self endon("death");	
	while(1)
	{
		self.bulletsinclip = 20;
		wait 1;
	}
}

//tall_grass_intro_guys_retreat_notify()
//{
//	self endon("death");
//	self waittill_any( "enemy_awareness_reaction", "damage", "bulletwhizby" );
//	if( !flag( "tall_grass_intro_goes_hot" ) )
//		flag_set("tall_grass_intro_goes_hot" );	
//}

tall_grass_watch_player_jump()
{
	level.player_original_jump_height = GetDvarFloat("jump_height"); //39 default
	setsaveddvar("jump_height", 20 );
	
	NotifyOnCommand( "playerjump", "+gostand" );
	NotifyOnCommand( "playerjump", "+moveup" );
	
	while( !flag( "field_end" ) )
	{
		level.player waittill( "playerjump" );
		wait( 0.1 );  // jumps don't happen immediately
		
		level.player AllowJump(false);
		wait(1.5);
		level.player AllowJump(true);
	}
	
	setsaveddvar("jump_height", level.player_original_jump_height );	
}

tall_grass_ai_dist_monitor()
{
	//this func prevents the axis and allies from getting too close to eachother in the tall grass
	flag_wait("field_entrance");
	array_thread( getaiarray("allies"), ::set_baseaccuracy, 1 );
	team_dist = 0;
	min_fight_interval = 800*800;//1250*1250;
	
	while( 1 )
	{
		axis = getaiarray("axis" );
		//if theres no baddies do nothing
		if( axis.size > 0 )
		{
			axis_avg_pos = get_average_origin( axis );
			allies_avg_pos = get_average_origin( level.squad );
			//thread draw_line_for_time( allies_avg_pos, axis_avg_pos, 1, 0, 0, .5 );
			if( distancesquared( allies_avg_pos, axis_avg_pos ) <= min_fight_interval )
			{
				flag_set( "ai_hold" );
				//iprintln( "ai hold movement" );
			}
			else
			{
				flag_clear("ai_hold");
			}	
		}
		else
			if( flag("ai_hold" ) )
		        flag_clear("ai_hold" );
		wait( 1.5 );	
	}
	
}

tall_grass_friendly_navigation()
{
	
	array_thread(level.squad, ::enable_cqbwalk );
	level thread tall_grass_intro_goes_hot();
	
	delayThread( 120, ::flag_set, "tall_grass_intro_halfway" );//this also gets set by a trig, or 2 enemies remaining
	
	flag_wait( "tall_grass_intro_halfway" ); 
	battlechatter_off();
	//level.player.ignoreme = 1;
	array_thread(level.squad, ::disable_cqbwalk );
	array_thread(level.squad, level.ignore_on_func );
	array_thread( level.squad, ::enable_ai_color ); //stealth system turns this off in some cases. 
	activate_trigger_with_targetname( "tall_grass_setup" );
	
	flag_wait( "field_entrance" );	//player hit trigger
	autosave_by_name("tall_grass_begin" );
	
	flag_wait("moving_into_tall_grass");
	structs = getstructarray("friendly_start_structs", "targetname" );
	
	//put the friendlies on struct splines through the field
	foreach( guy in level.squad )
	{
		guy.start_struct = getclosest( guy.origin, structs );
		guy thread tall_grass_friendly_logic( guy.start_struct );
	}
	

	
	flag_wait( "field_halfway" );
	wait .10;
	//tall_grass_everyone_resume_fighting();
	
	//they are at the end of their splines at this point. Wait for player to catch up and put them on new ones. 
	flag_wait( "prone_guys_getup" ); //trig
	
	structs = getstructarray("new_friendly_spline", "targetname" );
	
	foreach( guy in level.squad )
	{
		guy.start_struct = getclosest( guy.origin, structs );
		guy thread tall_grass_friendly_logic( guy.start_struct );
	}
		
	flag_wait("field_end");
	
	//flag_wait_or_timeout( "prone_guys_dead", 8 ); //script_deathflag on the AI in radiant
	flag_set("squad_exiting_tall_grass");
	
	//spawns all vehicles and AI on runway!	
	battlechatter_off();
	array_thread( level.squad, ::tall_grass_friendly_exit_logic );
	activate_trigger_with_targetname( "squad_to_runway");
	wait .5;
	level thread maps\jungle_ghosts_runway::runway_setup();
	
	autosave_by_name("to_runway");
	
	flag_wait( "field_end" );
	
	//cleanup
	current_baddies = getaiarray("axis" );
	if( current_baddies.size != 0 )
	{
		foreach( guy in current_baddies )
			guy delete_if_player_cant_see_me();
	}
	
}

tall_grass_intro_suppression()
{
	flag_wait("tall_grass_intro_goes_hot");
	battlechatter_on();
	array_thread( getaiarray("allies"), ::set_baseaccuracy, .10 );
	wait 1;
	
	structs = getstructarray("phantom_shot", "targetname" );
	array_thread ( structs, ::shoot_at_player );
	wait 6;
	level notify( "stop_suppression" );
}

shoot_at_player()
{
	level endon("stop_suppression");
	wait( randomfloatrange( .05, .5 ) );
	while( 1 )
	{
		dist = DistanceSquared( self.origin, level.player.origin );			
		if( !player_looking_at( self.origin ) && dist > 600*600 )
		{
			burst_fire_at_player( self );
			wait( 1 );
		}	
		wait(.05);
	}		
}

burst_fire_at_player( struct )
{
	shot_amount = randomintrange( 10, 16 );	
	weapons = ["honeybadger", "kriss", "microtar", "sc2010"];
	for( i = 0; i< shot_amount; i++)
	{
		if( level.player.health < 50 )
			return;
				
		spot = level.player.origin;
		offset = randomintrange( -100, 100 );
		MagicBullet( weapons[RandomInt(4)], struct.origin, spot + ( offset, offset, offset ) );
		wait( RandomFloatRange( .05, .15 ) );
	}	
}


tall_grass_friendly_exit_logic()
{
	//wait( RandomFloatRange( .5, 2 ) );
	self [[level.ignore_on_func]]();
	self notify ( "stop_tall_grass_beahavior" );
	
	if (isdefined(self.old_color))
		self set_force_color(self.old_color);

	self enable_ai_color();
	self enable_cqbwalk();
	self delaythread( 4, ::disable_cqbwalk );
	self allowedStances( "crouch", "stand", "prone"  );	
	self.moveplaybackrate = 1;
}

tall_grass_friendly_logic( start_struct )
{
	//ai should be targeted to a struct placed at the end of their intended path
	self endon("death");
	if( !self ent_flag_exist( "override_grass_behavior" ) )
		self ent_flag_init( "override_grass_behavior" );
	self notify ("stop_tall_grass_behavior" ); //clear existing instance of this function
	wait( .10 );
	self endon( "stop_tall_grass_beahavior");
	self enable_cqbwalk();
	if( !self ent_flag_exist( "end_of_spline" ) )
		self ent_flag_init("end_of_spline");
	self disable_ai_color();
	self.moveplaybackrate = randomfloatrange(.7, .9);
	self.goalradius = 32;
	self.moveplaybackrate = .7;
	
	if( self ent_flag( "end_of_spline" ) ) //could be set from previous instance of this function
		self ent_flag_clear( "end_of_spline" );
	
	if(!isdefined( self.script_moveoverride ) )
		self.script_moveoverride = 1;
	
	self.script_forcegoal = 1;// need this or else _spawner changes the goalradius after reaching goal =(
	home = self.origin;	
	
	if( !isdefined( start_struct ) )
		self.goal_struct = getstruct( self.target, "targetname" );
	else
		self.goal_struct = start_struct;
	
	self thread get_latest_struct();

	//spawn an ent to send them to (this gets moved around)
	self.home_ent = spawn("script_origin", self.origin );
	self.home_ent thread delete_me_on_parent_ai_death( self );
	first_time = true;
	
	while( 1 )
	{	
		if( flag( "ai_hold" ) )
		{
			wait 2;
			continue;			
		}
		if( self ent_flag( "override_grass_behavior" ) )
		{
			wait 2;
			continue;
		}
		//get the vector between ai and their targeted struct
		forwardvec = vectornormalize( self.goal_struct.origin - self.origin);	
		
		//get a spot along that vector a bit further up
		random_forwardvec = ( forwardvec * randomintrange( 250, 350 ) );
		
		//move the script origin to that spot in front of ai
		self.home_ent.origin = groundpos( self.origin + random_forwardvec + ( 0,0,200 ) );
		
		//send them to that script_origin
		self setgoalpos( self.home_ent.origin );
		//debug
		//thread draw_line_for_time ( self geteye(), self.home_ent.origin, 0, 0, 1, 60 );
		
		if( !first_time )
		{
			self allowedstances( "crouch" );
		}
					
		//waittill they get there
		self waittill ("goal");
		
		if( !self ent_flag( "override_grass_behavior" ) )
		{
			//now they can stand and attack
			self allowedstances( "stand" );
		}
		if(  isdefined( self.sprint) )
			self.sprint = 0;
			
		if( self ent_flag("end_of_spline") )
		   break;
		
		if(!first_time )
		{
			wait(randomfloatrange(3.5, 5) );	//stands up and fights		
		}
		
		
		first_time = false;
	}	
	
	//is at end of path
	self thread tall_grass_friendly_end_of_spline_behavior();
		
}

tall_grass_friendly_end_of_spline_behavior()
{
	self endon( "stop_tall_grass_behavior" );
	cover_time = RandomIntRange( 3, 5 ); 
	//IPrintLn( "friendly end of spline behavior" );
	while(1)
	{
		self AllowedStances( "stand", "crouch", "prone" );
		self waittill( "damage" );
		
		self AllowedStances( "crouch" );		
		self.ignoreme =1; //still needs to attack enemies but not take fire
		
		wait( cover_time );
		
		self.ignoreme =0;
	}
	
}

get_latest_struct()
{
	self endon("death");
	while ( 1 )
	{
		if ( distancesquared( self.origin, self.goal_struct.origin) <= 150*150 )
		{
			if(isdefined( self.goal_struct.target ) )
			{
				self.goal_struct = getstruct( self.goal_struct.target, "targetname" );
			}
			else
			{
				self ent_flag_set("end_of_spline");
			}
		}
		wait(1);
	}
	
}
	
delete_me_on_parent_ai_death( ai )
{
	//self = ent associated with an ai
	ai waittill( "death" );
	self delete();	
}	
/*
 motiontracker3d_ping_enemy  texture_assets\ui\hud\cb_motiontracker_ping_red.tga
 
*/ 
stream_vo()
{
	open_fire_lines = [	"jungleg_gs1_lightemup", "jungleg_gs1_goinloud", "jungleg_gs1_openfire", "jungleg_gs1_openfire_2" ];
	
	switch ( level.start_point )
	{		
		case "default":
		case "parachute":	
		case"jungle_corridor":
		case"jungle_hill":
		case"waterfall":
		case"stream":
			
			flag_wait( "waterfall_to_stream" );
			level.diaz.anmimname = "diaz";
			level.baker.anmimname = "baker";
			
			wait 5;
			
			//Merrick: It's a supply drop…they're huntin' us.
			level.diaz thread smart_radio_dialogue( "jungleg_bkr_lookslikeasupply" );
			
			wait 2;
			flag_wait( "can_see_chopper");
			wait (2);
			//Ghost 1: Hmm no getting through quietly. Diaz.  You're on Anti-Air. Everyone else stand by and be ready. 
			//level.alpha1 smart_radio_dialogue( "jungleg_gs1_nogettingthroughquietly" );
			if( !flag( "smaw_target_detroyed" ) )
			{
				thread add_dialogue_line( "Elias", "Too many uphead, let's wait for the heli to clear out.");
				wait 4;
			}
			if( !flag( "smaw_target_detroyed" ) )
			{
				thread add_dialogue_line( "Elias", "Wait for it..." );
				wait 4;
			}
			
			flag_set("time_for_chopper_to_leave");
			
			if( !flag( "smaw_target_detroyed" ) )
			{
				wait 4;
				thread add_dialogue_line( "Elias", "Okay, looks like they've cleared out. Let's move up." );
			}
			
			flag_set("begin_shoot_chopper");
			
			flag_wait("stream_fight_begin"); 
			
			//Baker: Targets on the bridge!
			//level.baker delayThread( RandomIntRange( 8, 15 ), ::smart_radio_dialogue, "jungleg_bkr_targetsonthebridge" );
			flag_wait( "stream_clear" );
			flag_wait( "bridge_area_exit" );

			battlechatter_off();
			
			//Inturder alert blah blah blah!!!!
			thread play_sound_in_space( "SP_0_stealth_alert", ( 2744.8, 5818.3, 607.3), 1 );
			wait (1.85);
			
			flag_set( "squad_to_waterfall_ambush" );
			
			//Merrick: Reinforcements.  We need to get out of the open.
			level.diaz smart_radio_dialogue( "jungleg_diz_soundslikereenforcements" );
			wait 0.25;
			//Keegan: Sir..that waterfalll…
			level.alpha2 smart_dialogue( "jungleg_gs2_sirthatwaterfalll" );
			
			//Price: Under the waterfall!  Go!  Now!
			level.alpha1 smart_dialogue( "jungleg_gs1_righteveryoneunderthat" );
			
			array_thread( level.squad, ::disable_cqbwalk );
		
	case "stream waterfall":
		
			flag_set("squad_to_waterfall_ambush");
				
			flag_wait("squad_in_ambush_position");
			
			//Do nags if player isnt under falls in 2 secs
			level.alpha1 delayThread( 2,  ::do_nags_til_flag, "player_in_ambush_position", 8, 13, "jungleg_gs1_rookunderthewaterfall", "jungleg_gs1_rookwhataredoing");
			
			flag_wait( "player_in_ambush_position" );
			wait 5;
			if(!flag( "player_didnt_ambush"))
			{
				//Ghost 1: I see 'em. 
				level.alpha1 smart_radio_dialogue( "jungleg_gs1_iseeem" );
				wait( 2 );
				//Ghost 2: Wait for it…..
				level.alpha2 smart_dialogue( "jungleg_gs2_waitforit" );
				
				flag_wait( "ambush_open_fire" );
				level.alpha1 smart_radio_dialogue( random( open_fire_lines ) );
				
			}
		
	case "Stream Backend":
		//flag_wait("stream_exit");
		//wait 6;
		//level.diaz smart_radio_dialogue( "jungleg_diz_anotherfootpatrol" );
	
	}
	
}

tall_grass_vo()
{		
	flag_wait( "to_grassy_field" );
	if ( level.start_point == "tallgrass" )
		//Diaz: Another foot patrol. 
		level.diaz smart_radio_dialogue( "jungleg_diz_anotherfootpatrol" );
	
	//Price: Adam, Merrick, and Hesh - flank right.
	level.alpha1 smart_radio_dialogue( "jungleg_gs1_rookyoubakerand" );
	
	thread do_tall_grass_transition_vo_til_hot();
	
	flag_wait("tall_grass_intro_halfway");
	wait 2;
	
	level.alpha1 smart_dialogue("jungleg_gs1_theyrefallingbackmove");
	wait 3;
	level.alpha1 smart_radio_dialogue("jungleg_gs1_cmonthisway");
	
	flag_wait( "field_entrance");
	// Elias: Wait, you hear that?
	level.alpha1 thread add_dialogue_line ("Elias", "Wait, you hear that?");
	wait 2;
	// Keegan: Hold up... Helis imbound
	level.alpha2 thread add_dialogue_line ("Keegan", "Hold up the treeline... Helis overhead. Let em' pass.");
 	
	flag_wait("tall_grass_heli_unloaded");
	wait (2);
	
	if( cointoss() )
		level.alpha2 smart_radio_dialogue("jungleg_gs2_terrific");
	else
		level.alpha2 smart_radio_dialogue("jungleg_gs2_lovely");
	
	wait 1;
	// Hesh: Let's not wait for them to come to us...
	level.baker thread add_dialogue_line ("Hesh", "Let's not wait for them to come to us...");
	wait 3;
	// Elias: Alright, stay low and keep moving, five meter spread.
	level.alpha1 thread add_dialogue_line ("Elias", "Alright, stay low and keep moving, five meter spread.");
	wait 2;
	flag_set("moving_into_tall_grass");
	
	//level.alpha1 smart_radio_dialogue("jungleg_gs1_fanout5meter");
	

	
	flag_wait("field_halfway");

	//level.baker delayThread( 24, ::smart_radio_dialogue, "jungleg_bkr_targetsatthetreeline" );
	
	//prone guys stand up and attack. If theres 2 or more play the AMBUSH line ( they may have died just waiting prone from nades or whatever)
	//flag_wait("prone_guys_getup");
	//level.prone_guys = array_removeDead_or_dying( level.prone_guys );
	
	//if ( level.prone_guys.size >= 2 )
	//{
	//	wait 2;
	//	//Ghost 2: Ambush!!!
	//	level.alpha2 smart_radio_dialogue( "jungleg_gs2_ambush" );
	//}
	
	flag_wait( "squad_exiting_tall_grass" );
	wait 1.5;
	//Ghost 2: Clear left!
	level.alpha2 smart_radio_dialogue( "jungleg_gs2_clearleft" );
	//Baker: Clear right!
	level.baker smart_radio_dialogue( "jungleg_bkr_clearright" );
	wait .5;
	//Ghost 1: Ok, we're clear!
	level.alpha1 smart_radio_dialogue( "jungleg_gs1_okwereclear" );
	wait 4;
	
	//Ghost 1: OK prepare to rappel. 
	level.alpha1 smart_radio_dialogue ( "jungleg_gs1_okpreparetorappel" );
	
	
	
}

do_tall_grass_transition_vo_til_hot()
{
	//plays this exchange until stealth is broken
	level endon("tall_grass_intro_goes_hot");
	
	wait( 2 );
	//Keegan: I see 'em. 
	level.alpha2 smart_radio_dialogue( "jungleg_gs2_iseeem" );
	//Price: Copy that
	level.alpha1 smart_radio_dialogue( "jungleg_gs1_copythat" );
	
	wait( 3 );
	//Price: Firing on your go.
	level.alpha1 smart_radio_dialogue( "jungleg_gs1_firingonyourgo" );

}
