#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\clockwork_code;


clockwork_interior_nvg_pre_load()
{
	flag_init( "start_nvg_guy_anims" );
	flag_init( "lights_out" );
	flag_init("nvg_light_on");
	flag_init( "nvg_go_go_go" );
	flag_init( "inside_clear");
	flag_init( "entry_clear");
	flag_init( "halls_clear");
	flag_init( "security_complete" );
	flag_init( "into_hall" );
	flag_init( "FLAG_eyes_and_ears_complete" );
	flag_init("FLAG_start_hacking");
	flag_init("nvg_halls_flashlight2");
	flag_init("insideb_clear");
	flag_init("nvgs_on");
	flag_init("nvg_enemies_provoked");
	flag_init("start_garage_ambience");
	flag_init("start_closing_vault_door");
	flag_init("lights_out_approach");
	flag_init("camera_track_player");
	flag_init("player_in_garage");
	flag_init( "entry_guard_anims" );
	flag_init( "security_room_b_anims" );
	flag_init( "security_room_anims" );
	flag_init( "garage_enemies_provoked" );
	flag_init( "intro_spotlight");
	flag_init("FLAG_player_getout_jeep");
	flag_init("FLAG_player_leave_garage");
	flag_init("power_out_failsafe");
	flag_init("lights_off");
	flag_init("player_in_garage2");
	flag_init("interior_start_point");
	flag_init("FLAG_blackout_enemy3");
	flag_init("entry_guard_anims_scripted");
	flag_init("bo_buddies45_dead");
	flag_init("bo_buddies3_dead");
	flag_init("entry_clear");
	precache("viewmodel_NVG");
	
	
	
	
	PreCacheModel("generic_prop_raven");
	PreCacheModel("weapon_fn_fiveseven");
		
	PrecacheModel("machinery_xray_scanner_bin_single");
	PreCacheModel("clk_metal_detector_wand");
	PrecacheModel("weapon_fn_fiveseven");
}

setup_interior()
{
	setup_player();
	spawn_allies();
//	setup_dufflebag_anims();
	thread init_tunnel();
	thread handle_tunnel_ambience();
	level.jeep = spawn_vehicle_from_targetname("interior_jeep");
	

	
	
	
	level.allies[0].script_startingposition = 1;
	level.allies[1].script_startingposition = 0;
	level.allies[2].script_startingposition = 3;
	
	foreach( guy in level.allies)
	{
		level.jeep thread maps\_vehicle_aianim::guy_enter( guy );
	}
	
	thread maps\clockwork_intro::exit_jeep_anims();
	
	flag_set("FLAG_player_getout_jeep");
	flag_set("interior_start_point");
	vision_set_changes("clockwork_indoor", 0);
	
	flag_set("start_garage_ambience");
	
	//disable_trigger_with_targetname("vault_charge_trig");
	
	
	flag_set("jeep_intro_ride_done");

	
	thread hold_fire_unless_ads("nvgs_on");
	
	thread maps\clockwork_intro::blackout_timer(41,&"CLOCKWORK_POWERDOWN", false, true);
	maps\clockwork_audio::checkpoint_interior();	
}

init_tunnel()
{
	//init_nvg_lights();
	level.tunnel_door_scene = GetEnt("lights_out_scene","targetname");
	level.tunnel_door = spawn_anim_model("vault_door");
	
	level.tunnel_door_scene thread anim_first_frame_solo(level.tunnel_door, "tunnel_vault");
	
	level.tunnel_door_clip = GetEnt("entrance_door_clip","targetname");
	
	level.tunnel_door_clip LinkTo(level.tunnel_door);
	
	flag_wait("start_closing_vault_door");
	
	thread maps\clockwork_audio::entry_door_close();
	
	level.tunnel_door_scene thread anim_single_solo(level.tunnel_door, "tunnel_vault");
	
	
	level.tunnel_door thread disconnect_paths_at_end_anim(level.tunnel_door_clip);
	
	
	flag_wait("power_out_failsafe");
	
	
	if(flag("player_in_garage") || flag("player_in_garage2"))
	{
		thread mission_failed_garage();
	}
	else
	{
	    
		garage_amb = get_ai_group_ai("garage_ambience");
		foreach(guy in garage_amb)
		{
			if(IsDefined(guy) && IsAlive(guy))
			{
				guy Delete();
			}
		}
	}

}

disconnect_paths_at_end_anim( clip )
{
	self waittillmatch("single anim","end");
	clip DisconnectPaths();
}

mission_failed_garage()
{
	SetDvar( "ui_deadquote", &"CLOCKWORK_QUOTE_KEEP_UP" );
	maps\_utility::missionFailedWrapper();
}

mission_failed_garage_provoke()
{
	SetDvar( "ui_deadquote", &"CLOCKWORK_QUOTE_COMPROMISE" );
	maps\_utility::missionFailedWrapper();
}

//handle_entrance_tunnel_door()
//{
//	wait 2;
//	
//	level.entrance_tunnel_door RotateYaw(100, 15);
//	
//	thread maps\clockwork_audio::entry_door_close();
//	
//	wait 15;
//	level.entrance_tunnel_door DisconnectPaths();
//
//	flag_wait("inside_entrance");
//	level.entrance_tunnel_door RotateYaw(50, 7.5);
//	wait 15;
//	level.entrance_tunnel_door DisconnectPaths();
//}

begin_interior()
{
	battlechatter_off("allies");
	battlechatter_off("axis");

	bloodstains = GetEntArray( "chaos_decals", "targetname" );
	foreach( blood in bloodstains )
		blood hide();
	
	//thread handle_tunnel_ambience();
	thread handle_blackout();
	thread control_nvg_lightmodels();//controls the swapping of off/on versions of light models in NVG lights out section.
	thread hold_fire_unless_ads("nvgs_on");
	//thread nvg_alert_handle();
	
	
	//player_speed_percent(40);
	thread blend_movespeedscale_custom(26,.25);
	thread player_dynamic_move_speed();
	
	level.player AllowSprint(false);
	
	array_thread( level.allies, ::cool_walk, true );
	
	level.allies[ 1 ].animname = "keegan";
	level.allies[ 1 ] set_run_anim( "walk_gun_unwary" );
	
	level.allies[ 2 ].animname = "cipher";
	level.allies[ 2 ] set_run_anim( "walk_gun_unwary" );
	
	wait 2;
	
	
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_meaninglesspatrol" );

	level.allies[1] char_dialog_add_and_go( "clockwork_ru1_dieofboredom" );
	
	waitframe();
	
	//thread handle_entrance_tunnel_door();
	
	flag_wait("nvgs_on");

	foreach (ally in level.allies)
	{
		ally.old_baseaccuracy = ally.baseaccuracy;
		ally set_baseaccuracy(500);
	}
	
	//COOL ANIMS HERE FOR ALLIES
	
	wait 1;
	
	thread hacking_eyes_and_ears();
	
	flag_wait_any("at_vault_door","FLAG_eyes_and_ears_complete" );
	
	foreach (ally in level.allies)
	{
		ally.baseaccuracy = ally.old_baseaccuracy;
		ally.disableplayeradsloscheck = false;
	}
}


handle_tunnel_ambience()
{
	flag_wait("start_garage_ambience");
	

	thread player_inside_nvg_area();
	
	
	array_spawn_function_noteworthy("tunnel_wave_guy",::wave_anim);
		
	thread handle_nvg_guards();
	
	patrollers = array_spawn_targetname_allow_fail("tunnel_guard_patrol");
	idle_guys = array_spawn_targetname_allow_fail("idle_guys");
	
	foreach( guy in patrollers )
	{
		guy.disablearrivals = true;
		guy.disableexits = true;
		guy.animname = "generic";
		guy set_run_anim("walk_gun_unwary");
		guy thread garage_alert_handle();
	}
	
	foreach(guy in idle_guys)
	{
		guy thread tunnel_idle_guys();
	}
	
	arrComb = array_combine( patrollers, idle_guys );
	
	thread failcase_garage( arrComb );
	thread camera_track_player();
	flag_set("camera_track_player");
	
	wait 1;
	
	jeep1 = create_vehicle_from_spawngroup_and_gopath( 240 );
	waitframe();
	
	wait 1;
	
	jeep2 = create_vehicle_from_spawngroup_and_gopath( 241 );
}

tunnel_idle_guys()
{
	self gun_remove();
	
	if(IsDefined(self.animation))
	{
		self.animname = "generic";
		self.allowdeath = true;
		self thread anim_generic_loop( self, self.animation );

	}
}

wave_anim()
{
	self thread garage_alert_handle();
	scene = getstruct("tunnel_wave","targetname");
	self.animname = "generic";
	scene anim_reach_solo(self,"tunnel_wave");
	scene thread anim_loop_solo(self, "tunnel_wave","stop_waving_loop");
	self.allowdeath = true;

	flag_wait("garage_enemies_provoked");
	
	scene notify("stop_waving_loop");
}

//stop_ignoring(guys)
//{
//	foreach (guy in guys)
//	{
//		if ( IsAlive(guy) )
//		{
//			guy.ignoreme = false;
//		}
//	}
//}

camera_track_player()
{
	//level endon("");
	
	time 	= 0.5;
	camera = getent("sec_cam_track","targetname");
	camera.angles = (camera.angles[0], camera.angles[1], 0);
	
	while(flag("camera_track_player"))
	{
		wait .1;
		
		angles = VectorToAngles(level.player.origin - camera.origin ) + (0,-90,0);
		angles = (0, angles[1], angles[2]);
		
		camera RotateTo( angles , time, time * 0.5, time * 0.5 );
	}
}



handle_nvg_guards()
{
	
	level.nvg_recover_anim = [];
	level.nvg_recover_anim[0] = "nvg_recover_anim1";

	nvg_spawner1 = GetEnt( "nvg_guy1", "targetname" );
	nvg_spawner2 = GetEnt( "nvg_guy2", "targetname" );
	nvg_spawner3 = GetEnt( "nvg_guy3", "targetname" );
	nvg_spawner4 = GetEnt( "nvg_guy4", "targetname" );
	nvg_spawner5 = GetEnt( "nvg_guy5", "targetname" );
	
	nvg_moment_guardA1 = nvg_spawner1 spawn_ai();
	nvg_moment_guardA2 = nvg_spawner2 spawn_ai();
	nvg_moment_guardB1 = nvg_spawner3 spawn_ai();
	nvg_moment_guardB2 = nvg_spawner4 spawn_ai();
	nvg_moment_guardB3 = nvg_spawner5 spawn_ai();
	
	level.nvg_moment_guardsA = [];
	level.nvg_moment_guardsB = [];
	
	
	level.nvg_moment_guardsA[0] = nvg_moment_guardA1;
	level.nvg_moment_guardsA[1] = nvg_moment_guardA2;
	level.nvg_moment_guardsB[0] = nvg_moment_guardB1;
	level.nvg_moment_guardsB[1] = nvg_moment_guardB2;
	level.nvg_moment_guardsB[2] = nvg_moment_guardB3;
	
	
	i=1;
	foreach (guy in level.nvg_moment_guardsA)
	{
		guy.animname = "nvg_guy"+i;
		guy set_allowdeath(true);
		guy.dontdropweapon = true;
		i++;
	}
	
	j=3;
	foreach (guy in level.nvg_moment_guardsB)
	{
		guy.animname = "nvg_guy"+j;
		guy set_allowdeath(true);
		guy.dontdropweapon = true;
		j++;
	}
	
	//spawn dudes with loop anims, then play specific anims when parm1 flag is hit.
	array_spawn_function_targetname("entry_guards",::blackout_loop_anims,"entry_guard_anims");
	array_spawn_function_targetname("nvg_security_room_b",::blackout_loop_anims,"security_room_b_anims");
	array_spawn_function_targetname("nvg_security_room_b1",::blackout_loop_anims,"security_room_b_anims");
	array_spawn_function_targetname("nvg_security_room",::blackout_loop_anims,"security_room_anims");
	
	//que up guys down the hall
	thread blackout_enemy3();//dude stumbles out of door at the top of stairs
	thread blackout_enemy45();//dude stumbles out of door at the top of stairs
	
	entry_guards = array_spawn_targetname_allow_fail("entry_guards");
	entry_guards_scripted1 = spawn_targetname("entry_guards_scripted1");
	entry_guards_scripted2 = spawn_targetname("entry_guards_scripted2");
	
	//que up blackout react anims
	thread blackout_enemy1and2_react_anims( entry_guards_scripted1, entry_guards_scripted2 );
	
	combArr = array_combine(level.nvg_moment_guardsA, level.nvg_moment_guardsB);
	thread ai_array_killcount_flag_set(combArr, combArr.size, "nvg_go_go_go");
	thread ai_array_killcount_flag_set(entry_guards, entry_guards.size, "security_room_b_anims");
	thread ai_array_killcount_flag_set(combArr, combArr.size-1, "entry_guard_anims");
	
	
	thread nvg_animted_scene( combArr ); //
	thread handle_lower_flashlight_guys();
		
	flag_wait ("lights_out" );
	
	foreach(guy in level.allies)
	{
		guy forceUseWeapon( "ak47_silencer_reflex_iw6", "primary" );	
	}
	
	inside_guardsb = array_spawn_targetname_allow_fail("nvg_security_room_b");
	inside_guardsb1 = array_spawn_targetname_allow_fail("nvg_security_room_b1");
	inside_guards = array_spawn_targetname_allow_fail("nvg_security_room");
	thread ai_array_killcount_flag_set(inside_guards, inside_guards.size, "inside_clear");
	
	blend_movespeedscale_custom(65,1);
	flag_set( "player_DMS_allow_sprint" );
	level notify( "starting_new_player_dyn_move" );
	
	flag_wait("nvgs_on");
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_cleanhouse");
	
		
	foreach (ally in level.allies)
	{
		ally.ignoreall = true;
	}
	
	wait 1;
	
	thread attack_targets(level.allies, level.nvg_moment_guardsA, .2, .5, true);
	
	wait 1;
	
	thread attack_targets(level.allies, level.nvg_moment_guardsB, .2, .5, true);
	
	wait 1;
	
	safe_activate_trigger_with_targetname("nvg_go_go_go");
	
	foreach(ally in level.allies)
	{
		ally enable_ai_color();
	}
	
	arrcomb = add_to_array(entry_guards, entry_guards_scripted1);
	arrcomb2 = add_to_array(arrcomb, entry_guards_scripted2);
	
	wait 2;
	
	thread attack_targets(level.allies, arrcomb2, .8, 1.1, true);

	
	waittill_aigroupcleared("nvg_grp_lower");
	
	
	foreach(ally in level.allies)
	{
		ally disable_cqbwalk();
	}
	
	safe_activate_trigger_with_targetname("nvg_go_go_go2");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_roomclear");
	
	wait 1.2;
	//threshold guy
	attack_targets(level.allies, inside_guardsb, .85, 1, true);
	
	flag_wait("attack_insideb");
	
	attack_targets(level.allies, inside_guardsb1, .85, 1, true);
	
	
	flag_wait_or_timeout("insideb_clear",1); 
	
	//the two guys coming around the corner, up the stairs.
	bo_buddies = [];
	bo_buddies[0] = level.bo_enemy3;
	bo_buddies[1] = level.bo_enemy4;
	bo_buddies[2] = level.bo_enemy5;
	
	attack_targets(level.allies, bo_buddies, .75, 1, true);
	
	attack_targets(level.allies, inside_guards, .75, 1, true);
	
	foreach (ally in level.allies)
	{
		ally.ignoreall = false;
	}
	
	flag_wait("security_complete");
	
	waittill_aigroupcleared("nvg_halls2");
	
	level.allies[1] char_dialog_add_and_go("clockwork_kgn_clear");
	
	foreach(guy in level.allies)
	{
	    guy.ignoreSuppression = false;
	    guy.IgnoreRandomBulletDamage = false;
	    guy.ignoreExplosionEvents = false;
	    guy.disableBulletWhizbyReaction = false;
	    guy.disableFriendlyFireReaction = false;
	}
}

handle_lower_flashlight_guys()
{
	flag_wait("nvg_halls_flashlight2");
	array_spawn_function_targetname("nvg_halls_flashlight2",::attach_flashlight);
	hall_guards_flashlight2 =array_spawn_targetname_allow_fail("nvg_halls_flashlight2");	
}

handle_lights_out_approach()
{
	level endon("blackout_early");
	
	flag_wait("lights_out_approach");
	
	lights_out_scene = Getent("lights_out_scene", "targetname");
	
	level.allies[0].animname = "baker";
	level.allies[1].animname = "keegan";
	level.allies[2].animname = "cipher";
	

	level.allies[0] thread reach_and_play_anim( lights_out_scene,.5 );
	level.allies[1] thread reach_and_play_anim( lights_out_scene, 1 );
	level.allies[2] thread reach_and_play_anim( lights_out_scene, 1.25 );
}

reach_and_play_anim( org, time )
{	
	level endon("blackout_early");
	
	wait (time);
	
	org anim_reach_solo(self,"lights_out_approach");
	org thread anim_single_solo(self,"lights_out_approach");
	
	flag_wait("allies_prep_lightsout");  

	org anim_single_solo(self,"lights_out_breakout");
	//self enable_ai_color();
}

nvg_animted_scene( guys )
{
	lights_out_scene = Getent("lights_out_scene", "targetname");
	
	// needed for teleporting these guys while they animate
	
	foreach (guy in guys)
	{
		guy.animated_scene = "lights_out";
		guy.animated_scene_org = lights_out_scene;
	}
	
	//spawn a anim joint and attach a bin model to it for scene.
	joint = spawn_anim_model("nvg_bin_joint", lights_out_scene.origin);
	bin = spawn_anim_model( "nvg_bin", lights_out_scene.origin );
	bin linkto( joint , "J_prop_1" );
	
	joint thread bin_failsafe( bin );
	
	guys[0] gun_remove();
	
	pistol = spawn( "script_model", (0, 0, 0) );
	pistol setmodel( "weapon_fn_fiveseven" );
	pistol linkto( guys[0], "tag_weapon_right", (0, 0, 0), (0, 0, 0) );
	
	guys[2] gun_remove();
	//guys[3] gun_remove();
	
	wand = spawn( "script_model", (0, 0, 0) );
	wand setmodel( "clk_metal_detector_wand" );
	wand linkto( guys[3], "tag_weapon_chest", (0, 0, 0), (0, 0, 0) );
	
	lights_out_scene thread anim_first_frame(guys, "lights_out");
	lights_out_scene thread anim_first_frame_solo(joint, "bin_joint");
	
	flag_wait("start_nvg_guy_anims");
	
	lights_out_scene thread anim_single(guys, "lights_out" );
	lights_out_scene thread anim_single_solo(joint, "bin_joint" );
	
	thread cool_walk_at_end_of_anim( guys );
	
	thread maps\clockwork_audio::security_beeps();
}

bin_failsafe( bin )
{
	level waittill("blackout_early");
	
	//flag_wait("start_enemies_provoked_early");
	self anim_stopanimscripted();	
	scale = randomfloatrange( 10, 100 );
	bin_vec = vectorNormalize( (bin.origin -1 ) - bin.origin );
	bin unlink();
	bin PhysicsLaunchClient( bin.origin, bin_vec * scale );
}

cool_walk_at_end_of_anim(arr)
{
	
	foreach(guy in arr)
	{
		guy thread waittillend_of_anim_set_walk();
	
	}
}

waittillend_of_anim_set_walk()
{
	self endon("death");
	self endon("lights_out");
	
	self waittillmatch("single anim","end");
	self.animname = "generic";
	self set_cool_walk();
	
	//thread wake_up_enemies( "nvg_enemies_provoked" ); //wake up enemies when provoked, called in nvg_alert_handle();
	
}

//wake_up_enemies(flag_to_wait)
//{
//	self endon("death");
//	self endon("lights_out");
//	
//	flag_wait( flag_to_wait );
//	
//	self.ignoreall = false;
//	self.disablearrivals = false;
//	self.disableexits = false;
//
//	self clear_run_anim();
//}

set_cool_walk()
{
	self.disablearrivals = true;
	self.disableexits = true;
	self set_run_anim("walk_gun_unwary");
}
//cower_anims()
//{
//	self.animname = "generic";
//	self.allowdeath = true;
//	self.looping_anim = "unarmed_cowercrouch_idle";
//	self thread anim_generic_loop( self, self.looping_anim, "stop_loop" );
//}

blackout_loop_anims( flag_to_play_anim )
{	
	self endon("death");
	
	self.health = 1;
	
	flag_wait("lights_out");
	// wait a little to give them a chance to teleport
	wait 0.2;
	
	if(IsDefined(self) && IsAlive(self))
	{
		self.animname = "generic";
		self.allowdeath = true;
		//nvg_recover_anim = level.nvg_recover_anim[randomint(level.nvg_recover_anim.size)];
		self thread anim_generic_loop(self, "nvg_recover_anim1","recover_stop_loop");
		self thread nvg_blackout_anims( flag_to_play_anim );
	}
}

#using_animtree("generic_human");
nvg_blackout_anims( flag_to_play_anim )
{
	scene = Getent("lights_out_scene", "targetname");
	
	self endon("death");
	flag_wait( flag_to_play_anim );
	self notify("recover_stop_loop");
	waittillframeend;
	//self StopAnimScripted();
	self.allowdeath = 1;

	
	if(IsDefined(self) && IsAlive(self))
	{
		if(IsDefined(self.animation))
		{
			self thread anim_generic( self, self.animation);
		}
		if( isdefined( self.script_noteworthy ) && (self.script_noteworthy=="blackout_blind_fire_pistol") )
			self thread shoot_loop();
		
		if( isdefined( self.script_noteworthy ) && (self.script_noteworthy=="security_room_guys") )
			self thread shoot_loop();

	}
}



blackout_enemy1and2_react_anims(guy1, guy2)
{
	flag_wait("lights_out");
	scene = Getent("lights_out_scene", "targetname");
	joint = spawn_anim_model("bo_alerted_door_jt", scene.origin);
	door = spawn_anim_model( "bo_alerted_door", scene.origin );
	door linkto( joint , "J_prop_1" );
	
	guy1 notify("recover_stop_loop");
	guy2 notify("recover_stop_loop");
	waittillframeend;
	
	guy1.animname = "generic";
	guy2.animname = "generic";
	guy1.allowdeath = true;
	guy2.allowdeath = true;
	guy1.ignoreall = true;
	guy2.ignoreall = true;
	
	

	wait(3);
	
	if ( IsDefined( guy1 ) && IsAlive( guy1 ) )
		scene thread anim_single_solo(guy1,"clockwork_nvg_hallway_run_and_trip_enemy1");
	wait 3.2;
	
	if ( IsDefined( guy2 ) && IsAlive( guy2 ) )
		scene thread anim_single_solo(guy2,"clockwork_nvg_hallway_alerted_enemy2");
	//spawn a anim joint and attach a DOOR model to it for scene.

	scene thread anim_single_solo(joint, "alerted_door_joint" );
	
}

blackout_enemy3()
{
	scene = Getent("lights_out_scene", "targetname");
	
	flag_wait("FLAG_blackout_enemy3");
	spawner = GetEnt("nvg_security_room_enemy3","targetname");
	level.bo_enemy3 = spawner spawn_ai(true);
	level.bo_enemy3.animname = "generic";
	level.bo_enemy3.allowdeath = true;
	
	//spawn a anim joint and attach a DOOR model to it for scene.
	joint = spawn_anim_model("bo_grope_door_jt", scene.origin);
	door = spawn_anim_model( "bo_grope_door", scene.origin );
	door linkto( joint , "J_prop_1" );
	scene thread anim_single_solo(joint, "bo_grope_door_joint" );
	scene thread anim_single_solo(level.bo_enemy3,"clockwork_nvg_hallway_grope_enemy3");
	
	flag_wait_or_timeout("bo_buddies3_dead",3);
	
	if(IsDefined(level.bo_enemy3) && IsAlive(level.bo_enemy3))
	{
		attack_targets(level.allies, make_array(level.bo_enemy3),.3,.4, true);
	}
}

blackout_enemy45()
{
	scene = Getent("lights_out_scene", "targetname");
	
	flag_wait("FLAG_blackout_enemy45");
	spawner = GetEnt("nvg_security_room_enemy4","targetname");
	level.bo_enemy4 = spawner spawn_ai(true);
	level.bo_enemy4.animname = "generic";
	level.bo_enemy4.allowdeath = true;
	scene thread anim_single_solo(level.bo_enemy4,"clockwork_nvg_hallway_buddies_enemy4");

	spawner = GetEnt("nvg_security_room_enemy5","targetname");
	level.bo_enemy5 = spawner spawn_ai(true);
	level.bo_enemy5.allowdeath = true;
	level.bo_enemy5.animname = "generic";
	scene thread anim_single_solo(level.bo_enemy5,"clockwork_nvg_hallway_buddies_enemy5");	
	
	
	flag_wait_or_timeout("bo_buddies45_dead",6);
	
	if(IsDefined(level.bo_enemy4) && IsAlive(level.bo_enemy4))
	{
		attack_targets(level.allies, make_array(level.bo_enemy4),.3,.4, true);
	}
	
	if(IsDefined(level.bo_enemy5) && IsAlive(level.bo_enemy5))
	{
		attack_targets(level.allies, make_array(level.bo_enemy5),.3,.4, true);
	}
}

//run_to_goal_after_anim( nodename )
//{
//	node = GetNode(nodename,"targetname");
//	self waittillmatch("single anim","end");
//	self SetGoalNode(node);
//}

shoot_loop()
{
	self endon("death");
	
	while(1)
	{
		wait ( RandomFloatRange(.2, 1) );
		self ShootBlank();
		wait ( RandomFloatRange(.3, 1.3) );
		self ShootBlank();
	}
}

attach_flashlight()
{
	PlayFXOnTag( level._effect[ "flashlight" ], self, "tag_flash" );
	self.have_flashlight = true;
}

//lights_out_soldier_vo()
//{
//	radio_dialog_add_and_go("clockwork_ru1_goingon");
//	
//	radio_dialog_add_and_go("clockwork_ru2_comebackon");
//	
//	radio_dialog_add_and_go("clockwork_ru1_yurisfault");
//	
//	radio_dialog_add_and_go("clockwork_ru2_almostover");
//	
//	radio_dialog_add_and_go("clockwork_ru1_youdoing");
//	
//	radio_dialog_add_and_go("clockwork_ru2_whatishappening");
//}
//
//
//animate_nvg_guy(flag)
//{
//	if ( IsDefined(self.animation) )
//	{
//		self anim_first_frame_solo(self, self.animation);
//	    	
//		if ( IsDefined(flag) )
//		{
//			flag_wait( flag );
//		}
//		
//		if ( IsDefined(self.script_parameters) )
//		{
//			wait self.script_parameters;
//		}
//		
//		self anim_single_solo(self, self.animation);
//	}
//}
	

nvg_ally_vo()
{
	flag_wait ("nvgs_on");

	wait 1;
	//level.allies[0] char_dialog_add_and_go("clockwork_bkr_backuppower");
	
	killTimer();
	
	flag_wait("nvg_go_go_go");
	
	wait .5;
	
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_go");
	
	flag_wait("entry_clear");
	//level.allies[0] char_dialog_add_and_go("clockwork_bkr_3min16secs");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_donthavemuchtime");
	
	flag_wait ("inside_clear");
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_buginplace");

	//level.allies[0] char_dialog_add_and_go("clockwork_bkr_coverour6");
	
	flag_wait("FLAG_start_hacking");
	
	flag_wait("FLAG_eyes_and_ears_complete");

	//wait 3;
	
	flag_set("security_complete");
}

hacking_eyes_and_ears()
{
	flag_wait("inside_clear");
		
	thread autosave_by_name( "eyes_and_ears" );
	scene = getstruct("scn_eyes_and_ears","targetname");

	
	//spawn a anim joint and attach a BUG model to it for scene.
	joint = spawn_anim_model("bug_device_joint", scene.origin);
	bug = spawn_anim_model( "bug_device", scene.origin );
	bug linkto( joint , "J_prop_1" );
	server = getent("security_cipher_hack","targetname");
	server.animname = "server";
	server SetAnimTree();
	
	//spawn a anim joint and attach a glowstick model to it for scene.
	joint2 = spawn_anim_model("bug_glowstick_joint", scene.origin);
	glowstick = spawn_anim_model( "bug_glowstick", scene.origin );
	glowstick linkto( joint2 , "J_prop_1" );

	actors = [];
	actors[0] = level.allies[2]; //cipher
	actors[1] = server;
	
	actors[0].animname = "cipher";
	level.allies[0].animname = "baker";
	
	allies = make_array(level.allies[0],level.allies[2]);
	
	scene anim_reach_together(allies,"eyes_and_ears");
	
	flag_set("FLAG_start_hacking");
	
	//actors[0] hide_dufflebag(true);
	
	//cypher
	scene thread anim_single_solo(joint, "bug_joint" );
	scene thread anim_single(actors,"eyes_and_ears");
	//baker
	scene thread anim_single_solo(joint2, "glowstick_joint" );
	scene thread anim_single_solo(level.allies[0],"eyes_and_ears");
	
	thread maps\clockwork_audio::hacking();
	thread maps\clockwork_audio::glowstick_hacking();
	
	wait 3;
	
	thread pip_vo();
	
	flag_wait("security_complete");

	
	actors[0] show_dufflebag(true);
	
	flag_set("FLAG_eyes_and_ears_complete");
	flag_set("FLAG_obj_enterbase_complete");
	level.allies[2] enable_ai_color();
	level.allies[0] enable_ai_color();
}



/*
keegan_plant_mine()
{
	flag_wait("entry_clear");
		
	scene = getstruct("scn_eyes_and_ears","targetname");
	node = GetNode("node_keegan_plant_mine","targetname");
	
	joint = spawn_anim_model("mine_joint", scene.origin);
	mine = spawn_anim_model( "mine", scene.origin );
	mine linkto( joint , "J_prop_1" );
	
	level.allies[1].animname = "keegan";
	
	scene anim_reach_solo(level.allies[1] ,"plant_mine");
	
	level.allies[1] SetGoalNode( node );
	level.allies[1] waittill("goal");
	
	scene thread anim_single_solo(joint, "plant_mine" );
	scene anim_single_solo (level.allies[1],"plant_mine");
	
	level.allies[1] waittillmatch("single anim","end");
	level.allies[1] show_dufflebag(true);
	level.allies[1] enable_ai_color();
}
*/

pip_vo()
{
	//level.allies[1] char_dialog_add_and_go("clockwork_cyr_testpattern");

//	thread maps\clockwork_pip::pip_enable();

	flag_wait("FLAG_checkcheck");
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_check");

	wait 0.35;
	
	level.allies[2] char_dialog_add_and_go("clockwork_kgn_check");
}

handle_blackout()
{
	flag_wait("lights_out");
    
	// === FX OFF ===
	exploder(260);  // lights ramp down
	flag_set("tubelight_parking"); //tubelights in garage
	flag_set("cagelight"); //hanging cage lights
	stop_exploder(250);  // nvg checkpoint lights
	stop_exploder(300); //ambient smoke garage

	// allies change movement style from cool walk to cqb
	array_thread( level.allies, ::cool_walk, false );
	array_thread( level.allies, ::cqb_walk, "on");
	thread nvg_ally_vo();
	thread nvgs_on_blackout();
	
	scene_org = GetEnt("lights_out_scene", "targetname");
//	thread nvg_teleport(true, scene_org);
//	nvg_teleport(true);
	
	flag_wait("nvgs_on");
	
	thread player_light();
	
	level.player AllowSprint(true);
}

	
player_light()
{
	// only run this on next gen
	if ( level.xb3 || level.ps4 )
	{
		level endon("death");
		
		tag_origin = spawn_tag_origin();
		PlayFXOnTag( level._effect[ "player_nvg_light" ], tag_origin, "tag_origin" );
	
		thread keep_track_of_nvg_light();
		
		while ( !flag("lights_on") )
		{
			if (flag("nvg_light_on"))
			{
				tag_origin.angles = level.player GetPlayerAngles();
				tag_origin.origin = level.player.origin + (0,0,64);
			}
			else
			{
				tag_origin.origin = (0,0,0);
			}
			wait 0.01;
		}
		
		tag_origin delete();
	}
}

nvg_area_lights_on_fx()
{
	exploder( 250 ); //turn security checkpoint fx on
	exploder( 301 ); //turn on bulbs 
}

keep_track_of_nvg_light()
{
	level endon("death");
	
	level.player NotifyOnPlayerCommand("nvg_toggle", "+actionslot 1");

	flag_set("nvg_light_on");
	
	while ( !flag("lights_on") )
	{
		level.player waittill( "night_vision_off" );
		flag_clear("nvg_light_on");
		
		level.player waittill("night_vision_on");
			flag_set("nvg_light_on");

		wait 0.05;
	}
}

nvgs_on_blackout()
{	
	level endon("notify_nvgs_on");
	
	// TODO: SOMEDAY TELEPORT THE PLAYER to the dark part in here
	thread maps\clockwork_audio::power_down();
	// fake the lights turning off for now	
	vision_set_changes("clockwork_lights_off", 0);
	// set special nightvision visionset for when lights are off (no bloom)
	VisionSetNight( "clockwork_night" );
	
	flag_set("lights_out");
	
	//hack: have to do this with how disguise Ak is currently working, or you cannot switch to NVGs and shit.
	level.player enableWeaponSwitch();
	
	level.player SetActionSlot( 1, "nightvision" ); // player can now use night vision
	level.player thread display_hint( "nvg" );
	
	thread nvg_on_check();
	
	wait 3;
	
	thread nvg_goggles_on();
	flag_set("nvgs_on");
}

nvg_on_check()
{
	level endon("notify_nvgs_on");
	
	while(1)
	{
		wait .1;
		if( isDefined (level.player.nightVision_Enabled))
		{
			flag_set("nvgs_on");
			level notify("notify_nvgs_on");	
			break;
		}
	}
}


nvg_alert_handle()
{
	//self endon( "ready_nvgs" );
	level endon( "ready_nvgs" );
	self endon( "death" );
	
	self AddAIEventListener( "grenade danger"	 );
	self AddAIEventListener( "projectile_impact" );
	self AddAIEventListener( "silenced_shot"	 );
	self AddAIEventListener( "bulletwhizby"		 );
	self AddAIEventListener( "gunshot"			 );
	self AddAIEventListener( "gunshot_teammate"	 );
	self AddAIEventListener( "explode"			 );
    self AddAIEventListener( "death"			 );
    
    self waittill_any( "ai_event", "flashbang" );
    flag_set( "nvg_enemies_provoked" );
    
    self anim_stopanimscripted();
    self.ignoreme = false;
    self.ignoreall = false;
    self clear_run_anim();
    self gun_recall();
   
}

garage_alert_handle()
{
	self endon( "player_in_nvg");
	self endon( "death" );
	
	self AddAIEventListener( "grenade danger"	 );
	self AddAIEventListener( "projectile_impact" );
	self AddAIEventListener( "silenced_shot"	 );
	self AddAIEventListener( "bulletwhizby"		 );
	self AddAIEventListener( "gunshot"			 );
	self AddAIEventListener( "gunshot_teammate"	 );
	self AddAIEventListener( "explode"			 );
    self AddAIEventListener( "death"			 );
    self waittill_any( "ai_event", "flashbang" );
    
    flag_set( "garage_enemies_provoked" );
    level notify("garage_enemies_provoked");
}

failcase_blackout_early()
{
	level endon("ready_nvgs");
	flag_wait("nvg_enemies_provoked");
	
	level notify("blackout_early");
	
	thread add_dialogue_line("Baker","Cut the power now!");
	
	foreach(guy in level.allies)
	{
		guy anim_stopanimscripted();
		guy enable_cqbwalk();
	}
	
	
    wait 1;
    
    //do blackout
	flag_set( "lights_out" );
	flag_set("lights_off");
	
	level.timer Destroy();
	
	thread add_dialogue_line("Baker","Damnit Rook... that was sloppy");
}

failcase_garage( guys )
{
	level endon("player_in_nvg");
	
	flag_wait( "garage_enemies_provoked" );
	
	
	foreach(guy in level.allies)
	{
		guy anim_stopanimscripted();
	}
	
	foreach(guy in guys )
	{
		if(IsDefined(guy) && IsAlive(guy))
		{
		guy gun_recall();
		//guy set_goal_pos(guy.origin);
		guy.ignoreall = false;
		guy.ignoreme = false;
		guy clear_run_anim();
		guy anim_stopanimscripted();
		guy notify("stop_loop");
	
		}
	}
	wait 6;
	
	mission_failed_garage_provoke();
}

player_inside_nvg_area()
{
	level endon("garage_enemies_provoked");
	
	flag_wait("inside_entrance");
	level notify("player_in_nvg");
	
	thread failcase_blackout_early();
	
	//que up guys for alerted.
	foreach(guy in level.nvg_moment_guardsA)
	{
		if(IsDefined(guy) && IsAlive(guy))
		{
			guy thread nvg_alert_handle();
		}
	}
	
	foreach(guy in level.nvg_moment_guardsB)
	{
		if(IsDefined(guy) && IsAlive(guy))
		{
			guy thread nvg_alert_handle();
		}
	}
}



control_nvg_lightmodels()
{
	alllights = GetEntArray("nvg_lab_lights","targetname");
	
	flag_wait("lights_out");
	
	control_nvg_staticscreens_off();
	foreach( light in alllights)
	{
		light.on_version = light.model;
		light SetModel(light.script_parameters);
	}
	
	flag_wait("lights_on");
	
	control_nvg_staticscreens_on();
	foreach( light in alllights)
	{
		light.on_version = light.model;
		light SetModel(light.on_version);
	}
	
}
	
	
	
control_nvg_staticscreens_off()
{	
	nvg_monitors = getentarray("nvg_monitors","targetname");
	nvg_mainscreens = getentarray("nvg_mainscreens","targetname");
	nvg_mapscreen = getent("nvg_mapscreen","targetname");
	nvg_mapscreen_light_accents = getent("nvg_mapscreen_light_accents","targetname");
	
	
	foreach(thing in nvg_monitors)
	{
		thing hide();
	}
	
	foreach(thing in nvg_mainscreens)
	{
		thing hide();
	}
	nvg_mapscreen hide();
	nvg_mapscreen_light_accents hide();
}

control_nvg_staticscreens_on()
{	
	nvg_monitors = getentarray("nvg_monitors","targetname");
	nvg_mainscreens = getentarray("nvg_mainscreens","targetname");
	nvg_mapscreen = getent("nvg_mapscreen","targetname");
	nvg_mapscreen_light_accents = getent("nvg_mapscreen_light_accents","targetname");
	
	foreach(thing in nvg_monitors)
	{
		thing show();
	}
	
	foreach(thing in nvg_mainscreens)
	{
		thing show();
	}
	nvg_mapscreen show();
	nvg_mapscreen_light_accents show();
}

player_failcase_leave_garage()
{
	//level endon("player_in_jeep");
	
	flag_wait("FLAG_player_leave_garage");
	
	SetDvar( "ui_deadquote", &"CLOCKWORK_QUOTE_LEFT_TEAM" );
	maps\_utility::missionFailedWrapper();
	
}