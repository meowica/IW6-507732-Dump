#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_vehicle_code;
#include maps\_anim;
#include maps\_utility_dogs;

spawn_targetname_at_struct_targetname( tname , sname )
{
    spawner = getent( tname , "targetname" );
	sstart = getstruct( sname , "targetname" );
	if( IsDefined( spawner ) && IsDefined( sstart ) )
	{
		spawner.origin = sstart.origin;
		if( IsDefined( sstart.angles ) )
		{
			spawner.angles = sstart.angles;
		}
		spawned = spawner spawn_ai();
	    return spawned;  
	}
	if( IsDefined( spawner ) )
	{
		spawned = spawner spawn_ai();
    	IPrintLnBold( "Add a script struct called: " + sname + " to spawn him in the correct location.");
    	spawned Teleport( level.player.origin, level.player.angles );
    	return spawned;
		
	}
	IPrintLnBold( "failed to spawn " + tname + " at " + sname );
	
	return undefined;
}

array_spawn_targetname_allow_fail( targetname, bForceSpawn )
{
//	IPrintLnBold("array spawn: "+targetname);
	spawners = GetEntArray( targetname, "targetname" );
	AssertEx( spawners.size, "Tried to spawn spawners with targetname " + targetname + " but there are no spawners" );
	
	spawned = array_spawn_allow_fail( spawners, bForceSpawn );

	return spawned;
}

array_spawn_allow_fail( spawners, bForceSpawn )
{
	guys = [];
	foreach ( spawner in spawners )
	{
		spawner.count = 1;
		guy = spawner spawn_ai( bForceSpawn );
		if ( IsDefined( guy ))
		{
			guys[ guys.size ] = guy;
		}
	}
	return guys;
}

// ======================================================================================================
// 							color trigger management functions
// ======================================================================================================
// looks for color triggers and has them wait to be triggered, and then disable all "Sibling triggers"
// used to make allies not back-track if the player does and takes a different path
//
// disable_all_previous <optional>: If true, assume trigger targetname's end in _####, and when a trigger
// with targetname _#### is hit, all other triggers with values <= _#### are disabled (not just ones
// with the same targetname.  This way if one path has 1600 -> 1700 -> 1800, and one path has 1610 -> 1810
// (no 1700 entry), 1810 will cancel 1700 as well as 1800.
//
// rules:
//		1) triggers must all have the same script_noteworthy set
//		2) triggers will disable all other triggers with the same targetname as themselves.
init_color_trigger_listeners( script_noteworthy_name , disable_all_previous )
{
	if ( !IsDefined( disable_all_previous ))
	{
		disable_all_previous = false;
	}
	if ( disable_all_previous )
	{
		if ( !IsDefined( level.payback_color_trigger_disable_previous ))
		{
			level.payback_color_trigger_disable_previous = [];
		}
		level.payback_color_trigger_disable_previous[script_noteworthy_name] = true;
	}

	color_triggers = GetEntArray( script_noteworthy_name , "script_noteworthy" );
	foreach ( trigger in color_triggers )
	{
		if ( disable_all_previous )
		{
			tokens = StrTok( trigger.targetname , "_" );
			color_value = tokens[tokens.size-1];
			trigger.payback_color_value = Int( color_value );
		}
		trigger thread ehq_color_trigger_listener();
	}
}


// when one of the same "line" of triggers is activated, turn off the rest of the line
// (no backwards progression)
ehq_color_trigger_listener()
{
	self endon( "disable_trigger" );
	
	self.payback_color_trigger_active = true;
	self waittill( "trigger" );
	otherTriggers = [];
	if ( IsDefined(level.payback_color_trigger_disable_previous) && IsDefined( level.payback_color_trigger_disable_previous[self.script_noteworthy] ))
	{
		tempTriggers = GetEntArray( self.script_noteworthy , "script_noteworthy" );
		foreach ( trigger in tempTriggers )
		{
			if ( trigger.payback_color_trigger_active
			    && trigger.payback_color_value <= self.payback_color_value )
			{
				otherTriggers[otherTriggers.size] = trigger;
				trigger.payback_color_trigger_active = false;
			}
		}
	}
	else
	{
		otherTriggers = GetEntArray( self.targetname , "targetname" );
	}
	foreach ( trigger in otherTriggers )
	{
		trigger notify("disable_trigger");
		trigger trigger_off();
	}
}


retreat_from_vol_to_vol( from_vol, retreat_vol, delay_min, delay_max)
{
	AssertEx (  ((IsDefined(retreat_vol)  && IsDefined( from_vol ) ) ), "Need the two info volume names ." );

	checkvol = getEnt( from_vol , "targetname" );
	retreaters = checkvol get_ai_touching_volume(  "axis" );
	goalvolume = getEnt( retreat_vol , "targetname" );
	goalvolumetarget = getNode( goalvolume.target , "targetname" );
	
	foreach( retreater in retreaters )
	{
		if(IsDefined(retreater) && IsAlive(retreater))
		{
			//retreater.ignoreall = true;
			//thread wait_goal();
			retreater.forcegoal = 0;
			retreater.fixednode = 0;
			retreater.pathRandomPercent = randomintrange( 75, 100 );
			retreater SetGoalNode( goalvolumetarget );
			retreater SetGoalVolumeauto( goalvolume );		
					
		}
	}
}

wait_goal()
{
	self waittill("goal");
	self.ignoreall = false;
}
ai_array_killcount_flag_set( guys , killcount , flag , timeout )
{
	waittill_dead_or_dying( guys , killcount , timeout );
	flag_set( flag );
}

d_dialogue_queue( line, name_override )
{
	if( !IsDefined( name_override ) )
		name_override = self.script_friendname;
	
	IPrintLnBold( name_override + ": " + line );
}

die_quietly()
{
	if ( IsDefined(self.magic_bullet_shield) && self.magic_bullet_shield == true )
	{
		self stop_magic_bullet_shield();
	}
	self.no_pain_sound = true;
    self.diequietly = true;
    self die();
}

safe_activate_trigger_with_targetname( msg )
{
	TOUCH_ONCE = 64;
	
	trigger = GetEnt( msg, "targetname" );
	if ( IsDefined( trigger ) && !IsDefined(trigger.trigger_off) )
	{
		trigger activate_trigger();
		
		if ( IsDefined(trigger.spawnflags) && ( trigger.spawnflags & TOUCH_ONCE ) )
		{
			trigger trigger_off();
		}
	}
}

safe_disable_trigger_with_targetname( msg )
{
	trigger = GetEnt( msg, "targetname" );
	if( IsDefined(trigger))
	{
		trigger trigger_off();
	}
}

safe_delete_trigger_with_targetname( msg )
{
	trigger = GetEnt( msg, "targetname" );
	if( IsDefined(trigger))
	{
		trigger Delete();
	}
}

set_flag_on_killcount( enemies , killcount , flag , timeout )
{
	waittill_dead_or_dying( enemies , killcount );
	flag_set( flag );
}

radio_dialog_add_and_go( alias, timeout )
{
	radio_add( alias );
	radio_dialogue( alias,timeout );
}

char_dialog_add_and_go( alias )
{
	level.scr_sound[ self.animname ][ alias ] = alias;
	self dialogue_queue( alias );
}

raven_player_can_see_ai( ai, latency )
{
	currentTime = getTime();

	if ( !isdefined( latency ) )
		latency = 0;

	if ( isdefined( ai.playerSeesMeTime ) && ai.playerSeesMeTime + latency >= currentTime )
	{
		assert( isdefined( ai.playerSeesMe ) );
		return ai.playerSeesMe;
	}

	ai.playerSeesMeTime = currentTime;

	if ( !within_fov( level.player.origin, level.player.angles, ai.origin, 0.766 ) )
	{
		ai.playerSeesMe = false;
		return false;
	}

	playerEye = level.player GetEye();

	feetOrigin = ai.origin;
	if ( SightTracePassed( playerEye, feetOrigin, false, level.player ) )
	{
		ai.playerSeesMe = true;
		return true;
	}

	eyeOrigin = ai GetEye();
	if ( SightTracePassed( playerEye, eyeOrigin, false, level.player ) )
	{
		ai.playerSeesMe = true;
		return true;
	}

	midOrigin = ( eyeOrigin + feetOrigin ) * 0.5;
	if ( SightTracePassed( playerEye, midOrigin, false, level.player ) )
	{
		ai.playerSeesMe = true;
		return true;
	}

	ai.playerSeesMe = false;
	return false;
}

debug_show_ai_counts()
{
	level notify( "end_debug_counts" );
	level endon( "end_debug_counts" );
	level.osprey_debug_ai = true;
	last_axis = -1;
	last_ally = -1;
	while( level.osprey_debug_ai )
	{
		axis = GetAIArray( "axis" );
		ally = GetAIArray( "allies" );
		if( last_axis != axis.size || last_ally != ally.size )
		{
		IPrintLn( "Ax:" + axis.size + " Al:" + ally.size );
			last_axis = axis.size;
			last_ally = ally.size;
		}
		wait 0.05;
	}
}
ambient_animate(delete_on_complete, shoot_me_notify, spawn_drone, civilian)
{
	
	struct = undefined;
	target_node = undefined;

	if ( !IsDefined(civilian) )
	{
		civilian = true;
	}
	
	if (IsDefined(spawn_drone) && spawn_drone == true)
	{
		guy = dronespawn_bodyonly(self);
	}
	else
	{
		spawn_drone = false;
		guy = self spawn_ai();
	}
	
	if ( IsDefined(guy) )
	{
		guy endon("death");

		if (spawn_drone == false)
		{
			if ( IsDefined(shoot_me_notify) )
			{
				guy thread prepare_to_be_shot(shoot_me_notify, civilian);
			}
			
			guy set_allowdeath(true);
		}
		
		if ( IsDefined(self.animation) )
		{
			guy.animname = "generic";
			
			if (spawn_drone == false && civilian == true)
			{
				guy set_generic_idle_anim("scientist_idle");
			}

			if ( IsDefined(self.target) )
			{
				struct = GetStruct(self.target, "targetname");
				if ( !IsDefined(Struct) )
				{
					target_node = GetNode(self.target, "targetname");
				}
				if (IsDefined(struct))
				{
					struct thread anim_generic_loop(guy, self.animation);
				}
				if (IsDefined(target_node))
				{
					guy disable_arrivals();
					guy disable_turnAnims();
					guy disable_exits();
					guy set_run_anim(self.animation);

					if ( IsDefined(delete_on_complete) && delete_on_complete == true)
					{
						guy thread delete_on_complete(true);
					}
				}
			}
			else
			{
				if ( IsArray(level.scr_anim["generic"][self.animation]) )
				{
					guy thread anim_generic_loop(guy, self.animation);
				}
				else
				{
					guy disable_turnAnims();
					guy.ignoreall = true;
					if (spawn_drone == false)
					{
						guy.allowdeath = true;
					}

					guy thread anim_single_solo(guy, self.animation);
					if ( IsDefined(delete_on_complete) && delete_on_complete == true )
					{
						guy thread delete_on_complete(false);
					}
				}
			}
		}
	}
	return guy;
}
//spawns relative to the passed in ent.
physics_fountain(modelName, relative_ent, ent_offset,rel_launch_vec,spawn_interval,lifetime,num_spawn,launch_vel)
{
	off_size = Length(ent_offset);
	off_norm = VectorNormalize(ent_offset);
	relative_ent endon("death");
	if(!IsDefined(level.phys_fountain))
		level.phys_fountain = [];
	while(num_spawn >0)
	{
		start_org = RotateVector(off_norm,relative_ent.angles);
		start_org= (start_org*off_size) + relative_ent.origin;
		
		
		launch_vec = RotateVector(rel_launch_vec,relative_ent.angles) * launch_vel;
		
		// Spawn a model to use for physics using the modelname and position of the part
		physicsObject = Spawn( "script_model", start_org );
//		physicsObject.angles =(RandomFloat(360),RandomFloat(360),RandomFloat(360));
		physicsObject.angles =(0,0,0);
		physicsObject SetModel( modelName );
	
		/#
		// Give it a targetname that makes it easy to identify using g_entinfo
			physicsObject.targetname = modelName + "(thrown physics model)";
		#/
	

		// Do physics on the model
		physicsObject PhysicsLaunchClient( start_org, launch_vec );
		thread cleanup_phys_obj( physicsObject, lifetime );
		wait spawn_interval;
		num_spawn--;
	}
}

cleanup_phys_obj( physicsObject, lifetime )
{
	wait lifetime;
	physicsObject Delete();
}
		
delete_on_complete(on_goal)
{
	if ( !on_goal )
		{
       	self waittillmatch("single anim", "end");
       	self notify( "killanimscript" );
		}
	else
	{
		self waittill("reached_path_end");
	}

	if ( !raven_player_can_see_ai(self) )
	{
		self delete();
	}
}

sniper_hint(cancel_flag, hint_time)
{
	wait hint_time;
	
	if ( !flag(cancel_flag) )
	{
		thread hint( "[{+actionslot 1}] to use remote sniper" );

		flag_wait(cancel_flag);	

		thread hint_fade();
	}
}

do_nag_dialog(who, line)
{
	if ( IsString(who) )
	{
		// for backwards compatibility with temp vo
		thread add_dialogue_line(who, line);
	}
	else
	{
		if (who == level.player)
		{
			radio_dialog_add_and_go(line);
		}
		else
		{
			who char_dialog_add_and_go(line);
		}
	}
}

nag_player_until_flag(who, complete_flag, line1, line2, line3, line4)
{
	level endon("death");
	
	lines = make_array(line1, line2, line3, line4);

	do_nag_dialog(who, lines[0]);
	
	i = 1;
	waittime = 2;

	wait waittime;
	
	while ( !flag(complete_flag) )
	{
		do_nag_dialog(who, lines[i]);
		
		waittime = waittime * 2;
		i++;
		
		if ( !IsDefined(lines[i]) )
		{
			i = 0;
		}
		
		wait waittime;
	}
}

prepare_to_be_shot(shoot_me_notify, civilian)
{
	self endon("death");
	
	level waittill(shoot_me_notify);
		
	self.ignoreme = false;
	self.ignoreall = false;
	self anim_stopanimscripted();
	
	if (civilian == true)
	{
		self set_generic_idle_anim("scientist_idle");
	}
	
	self enable_arrivals();
	self enable_exits();
	self enable_turnAnims();
}


reassign_goal_volume(guys, volume_name)
{
	if (!IsArray(guys))
	{
		guys = make_array(guys);
	}
	
	guys = array_removeDead_or_dying(guys);
	vol = GetEnt(volume_name, "targetname");

	foreach (guy in guys)
	{
		guy SetGoalVolumeAuto(vol);
	}
}
// set_black_fade() - set full screen black out level
//   <black_amount>: 1 for black, 0 for off (or anywhere in between)
//   <fade_duration>: transition time
set_black_fade( black_amount, fade_duration )
{
	level endon("set_black_fade");

	if ( !IsDefined( black_amount ) )
	{
		black_amount = 1;
	}
	black_amount = max(0.0, min(1.0, black_amount));

	if ( !IsDefined( fade_duration ) )
	{
		fade_duration = 1;
	}
	fade_duration = max(0.01, fade_duration);
	
	if ( !IsDefined( level.hud_black ) )
	{
		level.hud_black = NewHudElem();
		level.hud_black.x = 0;
		level.hud_black.y = 0;
		level.hud_black.horzAlign = "fullscreen";
		level.hud_black.vertAlign = "fullscreen";
		level.hud_black.foreground = true;
		level.hud_black.sort = -999; // in front of everything
		level.hud_black SetShader("black", 650, 490);
		level.hud_black.alpha = 0.0;
	}
	
	level.hud_black FadeOverTime(fade_duration);
	level.hud_black.alpha = max(0.0, min(1.0, black_amount));
	if ( black_amount <= 0 )
	{
		wait fade_duration;
		level.hud_black destroy();
		level.hud_black = undefined;
	}
}


/*
=============
///ScriptDocBegin
"Name: SetUpPlayerForAnimations()"
"Summary: prepare the player for getting animations played on them (opposite call to SetUpPlayerForGamePlay)"
call when you're setting up to plan an animation on the player
"Example: SetUpPlayerForAnimations()"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

SetUpPlayerForAnimations(desired_stance)
{
	if(!IsDefined(desired_stance))
		desired_stance = "stand";
	if( level.player IsThrowingGrenade() )
	{
		wait( 1.2 );	
	}
	level.player DisableWeapons();
	level.player AllowJump( false );
	level.player allowMelee(false);
	level.player DisableOffhandWeapons();
	level.player allowSprint(false);
	level.player AllowAds( false );

	if(desired_stance != "stand")
		level.player allowStand(false);
	if(desired_stance != "crouch")
		level.player allowCrouch(false);
	if(desired_stance != "prone")
		level.player allowProne(false);
	
	if ( level.player GetStance() != desired_stance )
	{
		level.player SetStance( desired_stance );
		wait( 0.4 );
	}
}

/*
=============
///ScriptDocBegin
"Name: SetUpPlayerForGamePlay()"
"Summary: prepare the player for gameplay after animations have been called (opposite call to SetUpPlayerForAnimations)"
call after you're done playing animations on the player
"Example: SetUpPlayerForGamePlay()"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

SetUpPlayerForGamePlay()
{
	level.player allowSprint(true);	
	level.player allowProne(true);
	level.player allowCrouch(true);
	level.player allowStand(true);
	level.player EnableOffhandWeapons();
	level.player allowMelee(true);
	level.player AllowAds( true );
	level.player AllowJump( true );
	level.player EnableWeapons();	
}


// ========================================= TRUCK STUFF =========================================



player_enter_truck_progression(truck)
{
	flag_wait("FLAG_player_enter_truck");
	
	level.player SetStance("stand");
	level.player allowCrouch(false);
	
	player_enter_truck_func(truck);
}


vehicle_play_guy_anim(anime, guy, pos, playIdle)
{	 
    animpos = anim_pos( self, pos );
    animation = guy getanim(anime);
    
    guy notify ("newanim");
    guy endon( "newanim" );
    guy endon( "death" );
    
	//self animontag(guy, animpos.sittag, animation );
	self anim_single_solo(guy, anime, animpos.sittag);
	
	if(!IsDefined(playIdle) || playIdle == true)
	{
		self guy_idle(guy, pos); 	
	}
}



player_enter_truck_func( truck )
{
	thread maps\enemyhq_audio::aud_enter_truck();
	
	thread maps\enemyhq_intro::spawn_trucks();
	
	
	thread autosave_now_silent();
	
	scene = getstruct("player_teleport_atrium","targetname");
    level.truck_player_arms = spawn_anim_model( "player_rig" );
    level.truck_player_arms.animname = "player_rig";
	level.player DisableWeapons();
	level.truck_player_arms.animname = "player_rig";
	truck.animname = "truck";
	level.truck_player_arms SetModel( "viewhands_player_yuri" );
	level.truck_player_arms hide();
	

	
	level.truck_player_arms LinkTo( truck, "tag_passenger" );
	level.truck_player_arms thread anim_first_frame_solo( level.truck_player_arms, "player_enter_truck" );
	
	level.player PlayerLinkToBlend( level.truck_player_arms, "tag_player", .5 );
	
	truck thread anim_single_solo( level.truck_player_arms,"player_enter_truck","tag_passenger" );
	truck thread anim_single_solo( truck,"player_enter_truck" );
	
	wait .25;
	level.player PlayerLinkTo( level.truck_player_arms, "tag_player", .5,25,25,25,25 );	
	level.truck_player_arms show();
	level.truck_player_arms waittillmatch("single anim","end");
		
	level.player PlayerLinkToDelta( level.truck_player_arms, "tag_player",1, 70, 70,35,35 );
		
	level.truck_player_arms hide();
	level.player allowCrouch(true);
	
	flag_wait("bring_up_clacker");

	
	level.player_truck thread listen_player_jolt_first_vehicle();

	level.player maps\_c4::switch_to_detonator();
	level.player EnableWeapons();
	level.player waittill( "detonate" );
	flag_set("FLAG_blow_sticky_01");
	wait 1;
	level.player TakeWeapon("c4");
	level.player DisableWeapons();
	
	
	flag_wait("FLAG_player_bust_windshield");
	
	wait 1;
	
	level.player SetStance("stand");
	level.player allowCrouch(false);
	
	
	ScreenShake( level.player.origin, 18, 16, 10, 1, 0, .5, 256, 8, 15, 12, 1.8 );
	thread maps\enemyhq_audio::aud_bust_windshield();
	gun = spawn( "script_model", level.truck_player_arms gettagorigin( "tag_weapon_right" ) );
	gun.angles = level.truck_player_arms gettagangles( "tag_weapon_right" );
	gun linkto( level.truck_player_arms, "tag_weapon_right" );
	gun setmodel( "weapon_m4m203_acog" );
		
	blah = [];
	blah[0] = level.truck_player_arms;
	blah[1] = truck;
	
	level.truck_player_arms show();
	truck thread anim_single_solo( blah[0],"player_smash_windshield","tag_passenger" );
	level.player PlayerLinkToDelta( level.truck_player_arms, "tag_player", .2,30,30,30,30 );	
	truck SetFlaggedAnimRestart( "vehicle_anim_flag", truck getanim("player_smash_windshield") );
	blah[0] waittillmatch("single anim","end");
	level.player GiveWeapon("sc2010+acog_sp");			  
	level.player switchToWeapon( "sc2010+acog_sp" );
	
	level.truck_player_arms hide();
	
	flag_set("FLAG_player_gun_up");
	
	level notify("end_jolt_jumps_thread");
	
	waitframe();
	
	level.player_truck thread listen_player_jolt_vehicles();

	
	level.player EnableWeapons();
	level.player SwitchToWeaponImmediate("sc2010+acog_sp");
										
	
	gun delete();
	
	flag_wait("FLAG_truck_exploder_start");
	level.player PlayerLinkTo( level.truck_player_arms, "tag_player", 1,50,50,30,30 );	
	
	flag_wait("FLAG_start_pathblockers");
	level.player PlayerLinkTo( level.truck_player_arms, "tag_player", 1,70,70,70,70 );	

	thread player_bust_thru_scene( scene, truck );
	
	flag_wait("drive_in_done");
	
	level notify("end_jolt_vehicles_thread");
	
	waitframe();
	
	level.player_truck thread listen_player_jolt_jumps();
}
	
	
player_enter_truck_atrium_startpoint( truck )
{
	scene = getstruct("player_teleport_atrium","targetname");

	level.truck_player_arms = spawn_anim_model( "player_rig" );
	level.truck_player_arms.animname = "player_rig";
	truck.animname = "truck";
	level.truck_player_arms LinkTo( truck, "tag_passenger" );
	level.player PlayerLinkToDelta( level.truck_player_arms, "tag_player",1, 70, 70,35,35,true );
	level.player DisableWeapons();
	level.truck_player_arms SetModel( "viewhands_player_yuri" );
	level.truck_player_arms hide();
	
	thread player_bust_thru_scene(scene, truck);
}
	
player_bust_thru_scene( scene, truck )
{
	flag_wait("FLAG_bust_thru_prep");
	
	level notify("drive_in_done");
	wait 0.05;
		
	level.player DisableWeapons();

	fieldguys = get_ai_group_ai("field_chaos_guys");
	foreach(guy in fieldguys)
	{
		guy delete();
	}
	
	level.truck_player_arms show();
	
	//level.player PlayerLinkToAbsolute (level.truck_player_arms, "tag_player");//,1,15,15,15,15, true);
	level.player PlayerLinkToDelta(level.truck_player_arms, "tag_player",.8,45,60,25,25, true);
	
	
	truck thread anim_single_solo(level.truck_player_arms,"bust_thru_prep", "tag_passenger");

	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_comininhot");
	
	flag_wait("kick_off_atrium_combat");
	

	
	level.player DisableWeapons();
	level.truck_player_arms unlink();
	
	scene thread anim_single_solo(level.truck_player_arms,"bust_thru");
	
	flag_wait("FLAG_bust_thru_player_control");
	
	thread add_dialogue_line("Merrick","Bishop is through this atrium! Move Move Move!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_bishopisthroughthis");
	
	level.truck_player_arms hide();
	
	wait .2;
	
	activate_trigger_with_targetname("TRIG_advance_allies_wave1");
	
	level.player_truck vehicle_stop_named( "atrium_truck_stop", 10, 10 );
	//level.player PlayerLinkToDelta( level.truck_player_arms, "tag_player",1,60,60,60,60, true);
	level.player switchToWeapon( "sc2010+acog_sp" );
	level.player EnableWeapons();
	thread listen_player_press_x();
	level notify("end_jolt_jumps_thread");

	thread turn_exit_trigger_on();
	
	flag_wait("FLAG_player_exit_truck");
	
	thread dog_hint();
	
	thread handle_baker_teleport();	
		
	level notify("player_exited_truck");
	
	
	activate_trigger_with_targetname("TRIG_advance_allies_wave1");
	level.player disableweapons();
	trigger_off("TRIG_player_exit_truck","targetname");
	
	actors = [];
	actors[0] = level.truck_player_arms;
	actors[1] = level.player_truck;
	
	scene anim_single(actors, "bust_thru_exit");
	
	level.player EnableWeapons();
	level.player Unlink();
	
	wait 2;
	
	thread add_dialogue_line("Merrick","Got em on the run! Covering fire");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_gotemonthe");
	
	
}

dog_hint()
{
	thread hint( "[{+frag}] to command dog" );
	wait 2;
	thread hint_fade();	
}

handle_baker_teleport()
{
	node2 = getNode("NODE_ally2_teleport_atrium","targetname");
	level.allies[0] Unlink();
	level.player_truck notify("stop_baker_loop");
	level.allies[0] anim_stopanimscripted();
	waitframe();
	level.allies[0] forceteleport( node2.origin, node2.angles );
}
listen_player_press_x()
{
	level endon("player_exited_truck");
	
	while( true )
	{
		if( level.player UseButtonPressed() )
		{
			flag_set("FLAG_player_exit_truck");
		}

		wait( 0.05 );
	}
}

turn_exit_trigger_on()
{
	wait 4;
	trigger_on("TRIG_player_exit_truck","targetname");
}

create_overlay_element( shader_name, start_alpha )
{
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( shader_name, 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = start_alpha;
	overlay.foreground = true;
	overlay.sort = 2;
	return overlay;
}

/// RYAN: this code will have to gracefully handle the player sending the dog off to atack etc.
// so probably best to disable dog control here? else need to work together to handle it.
handle_dog_sniffing()
{
	level endon("death");

	while (true)
	{
		self waittill("trigger", other);
		
		if (other == level.dog)
		{
			if (self.targetname == "start_dog_sniffing")
			{
				other enable_dog_sniff();
				other notify("start_sniffing");
			}
			else
			{
				other SetGoalPos(self.origin);
				other disable_ai_color();
				other disable_dog_sniff();
				wait 0.1;
				other enable_ai_color();
				other notify("stop_sniffing");
			}
		}
	}
}


listen_player_jolt_first_vehicle()
{
	while(1)
	{
		self waittill( "veh_jolt", jolt );
		thread screen_shake_vehicles();
		thread reaction_anims();
		
		flag_set("FLAG_player_bust_windshield");
		
		
		
		level.player_truck thread listen_player_jolt_jumps();
		break;
	}
}

listen_player_jolt_vehicles()
{
	level endon("end_jolt_vehicles_thread");
	
	//thread debug_jolt_vehs();
	while( 1 )
	{
		self waittill( "veh_jolt", jolt );
		thread screen_shake_vehicles();
		thread reaction_anims();
		
		wait 2;
	}
}

listen_player_jolt_jumps()
{
	level endon("end_jolt_jumps_thread");
	
	//thread debug_jolt_jumps();
	while( 1 )
	{
		self waittill( "veh_jolt", jolt );
		thread screen_shake_jumps();
	}
}

debug_jolt_jumps()
{
	level endon("end_jolt_jumps_thread");
	
	while(1)
	{
		wait .25;
		IPrintLn("running jumps thread");	
	}
}

debug_jolt_vehs()
{
	level endon("end_jolt_vehicles_thread");
	
	while(1)
	{
		wait .25;
		IPrintLn("running vehs thread");	
	}
}

#using_animtree( "player" );
reaction_anims()
{
	guys = [];
	guys[0] = level.allies[1];
	
	level.truck_player_arms setanim( %ehq_truck_drivein_hit_player, 0.9, 1, true);

}

screen_shake_vehicles()
{
	level.player playsound( "clkw_scn_chase_player_jolt" );	
	thread play_rumble_seconds( "damage_heavy", 2 );
	
	//initial hit is lots of roll.
	//ScreenShake(level.player.origin, 0, 0, 15, 1, 0, 1, 500, 0, 0, 4, 1.2 );
	
	//wait .25;
	
	ScreenShake(level.player.origin, 3, 12, 3, 4, 0, 2, 500, 17, 5, 3, 1.2 );
	
	wait 1;
	
	ScreenShake(level.player.origin, 3, 2, 3, 2, 0, 2, 500, 5, 5, 3, 1.2 );
	
}

screen_shake_jumps()
{
	
	level.player playsound( "clkw_scn_chase_player_jolt" );	
	thread play_rumble_seconds( "damage_heavy", 1 );
	ScreenShake(level.player.origin, 6, 0, 2, 1.5, 0, 1.5, 500, 17, 0, 10, 1 );
}

RUMBLE_FRAMES_PER_SEC = 10;
screenshakeFade( scale, duration, fade_in, fade_out)
{
	if ( !isdefined( fade_in ) )
		fade_in = 0;
	if ( !isdefined( fade_out ) )
		fade_out = 0;

	assert( ( fade_in + fade_out ) <= duration );

	frame_count = duration * RUMBLE_FRAMES_PER_SEC;
	fade_in_frame_count = fade_in * RUMBLE_FRAMES_PER_SEC;
	if ( fade_in_frame_count > 0 )
		fade_in_scale_step = scale / fade_in_frame_count;
	else
		fade_in_scale_step = scale;

	fade_out_frame_count = fade_out * RUMBLE_FRAMES_PER_SEC;
	fade_out_start_frame = frame_count - fade_out_frame_count;
	if ( fade_out_frame_count > 0 )
		fade_out_scale_step = scale / fade_out_frame_count;
	else
		fade_out_scale_step = scale;

	delay = 1/RUMBLE_FRAMES_PER_SEC;
	scale = 0;
	for ( i = 0; i < frame_count; i++ )
	{
		if ( i <= fade_in_frame_count )
			scale += fade_in_scale_step;

		if ( i > fade_out_start_frame )
			scale -= fade_out_scale_step;

		earthquake( scale, delay, level.player.origin, 500 );
		wait delay;
	}
}

play_rumble_seconds( damage_name, seconds )
{
	for ( i = 0; i < ( seconds * 20 ); i++ )
	{
		level.player PlayRumbleOnEntity( damage_name );	
		wait 0.05;
	}
}

delete_ai_at_path_end()
{
	self endon( "death" );
	self waittill( "reached_path_end" );
	self delete_ai();
}

delete_ai()
{
	guys[ 0 ] = self;
	level thread AI_delete_when_out_of_sight( guys, 512 );
}

//#using_animtree( "generic_human" );
carry_bishop()
{	
	self disable_cqbwalk();
	self.disablearrivals = true;
	self.disableexits = true;
	self.nododgemove = true;
	self pathrandompercent_set( 0 );
	self pushplayer( true );
	self ignore_everything();
	self thread set_generic_run_anim( "wounded_carry_carrier" );
	self thread set_generic_idle_anim( "wounded_carry_idle" );
	self thread anim_generic_loop( level.bishop, "wounded_carry_wounded", "stop_anim", "tag_origin" );
	level.bishop linkto( self, "tag_origin" );
}

ignore_everything()
{
	self.ignoreall = true;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	
	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
}

clear_ignore_everything()
{
	self.ignoreall = false;
	self.grenadeawareness = 1;
	self.ignoreexplosionevents = false;
	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.fixednode = true;
	self.disableBulletWhizbyReaction = false;
	self enable_pain();
	
	if( IsDefined( self.og_newEnemyReactionDistSq ) )
	{
		self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
	}
}

gasmask_on_npc()
{
	self.gasmask = Spawn("script_model", (0, 0, 0));
	self.gasmask SetModel("prop_sas_gasmask");
	self.gasmask LinkTo(self, "tag_eye", (-4, 0, 2), (120, 0, 0));
	self.gasmask_on = true;
}



// player gasmask

bob_mask( hudElement )
{
	self endon( "stop_mask_bob" );

	weapIdleTime = 0;
	previousAngles = level.player GetPlayerAngles();
	offsetY = 0;	// for vertical changes. eg. jumping
	offsetX = 0;	// for turning left/right

	frameTime = 0.05;
	while (1)
	{
		if ( IsDefined( hudElement ) )
		{
			angles = level.player GetPlayerAngles();
			velocity = level.player GetVelocity();
			zVelocity = velocity[2];
			velocity = velocity - velocity * ( 0, 0, 1 ); // zero out z velocity ( up/down velocity )
			speedXY = Length( velocity );
			stance = level.player GetStance();

			// speedScale goes from 0 to 1 as speed goes between 0 and full sprint
			speedScale = clamp( speedXY, 0, 280 ) / 280;
			// bobXFraction and bobXFraction control the amount of the maximum xy displacement that is allocated to the bob motion.
			// The remainder goes to the xy offset due to turn and z velocity.
			// As speed increases more displacement goes to bob and less to the xy offset due to turn and z velocity.
			bobXFraction = 0.1 + speedScale * 0.25;
			bobYFraction = 0.1 + speedScale * 0.25;

			// bobScale controls the amount of bob displacement based on stance
			bobScale = 1.0;	// default
			if ( stance == "crouch" )	bobScale = 0.75;
			if ( stance == "prone" )	bobScale = 0.4;
			if ( stance == "stand" )	bobScale = 1.0;

			// bobSpeed controls the frequency of the bob cycle
			idleSpeed = 5.0;
			ADSSpeed = 0.9;
			playerADS = level.player playerADS();
			// lerp bobSpeed between idleSpeed and ADSSpeed
			bobSpeed = idleSpeed * ( 1.0 - playerADS ) + ADSSpeed * playerADS;
			bobSpeed = bobSpeed * ( 1 + speedScale * 2 );

			maxXYDisplacement = 5;	// corresponds to 650 by 490 in the hud elem SetShader()
			bobAmplitudeX = maxXYDisplacement * bobXFraction * bobScale;
			bobAmplitudeY = maxXYDisplacement * bobYFraction * bobScale;

			// control the bob motion in the same pattern as the viewmodel bob - through it will not be in phase
			weapIdleTime = weapIdleTime + frameTime * 1000.0 * bobSpeed;
			rad_to_deg = 57.295779513; // radians to degrees
			 // the constants 0.001 and 0.0007 match those in BG_ComputeAndApplyWeaponMovement_IdleAngles()
			verticalBob   = sin( weapIdleTime * 0.001  * rad_to_deg );
			horizontalBob = sin( weapIdleTime * 0.0007 * rad_to_deg );

			// calculate some x offset based on player turning
			angleDiffYaw = AngleClamp180( angles[ 1 ] - previousAngles[ 1 ] );
			angleDiffYaw = clamp( angleDiffYaw, -10, 10 );
			offsetXTarget = ( angleDiffYaw / 10 ) * maxXYDisplacement * ( 1 - bobXFraction );
			offsetXChange = offsetXTarget - offsetX;
			offsetX = offsetX + clamp( offsetXChange, -1.0, 1.0 );

			// calculate some y offset based on vertical velocity
			offsetYTarget = ( clamp( zVelocity, -200, 200 ) / 200 ) * maxXYDisplacement * ( 1 - bobYFraction );
			offsetYChange = offsetYTarget - offsetY;
			offsetY = offsetY + clamp( offsetYChange, -0.6, 0.6 );
			
			hudElement MoveOverTime( 0.05 );
			hudElement.x = clamp( ( verticalBob   * bobAmplitudeX + offsetX - maxXYDisplacement ), 0 - 2 * maxXYDisplacement, 0 );
			hudElement.y = clamp( ( horizontalBob * bobAmplitudeY + offsetY - maxXYDisplacement ), 0 - 2 * maxXYDisplacement, 0 );
			
			previousAngles = angles;
		}
		wait frameTime;
	}
}

gasmask_hud_on(bFade)
{
	wait 0.333; // AUDIO: wait timer is timed for audio, do not change without consulting audio department
	
	Assert(IsPlayer(self));	
	if(!IsDefined(bFade)) bFade = true;
		
	if(bFade)
	{	
		self set_black_fade( 1.0, 0.25 );
		wait(0.25);
	}
	array_thread(level.allies, ::gasmask_on_npc);

	SetHUDLighting( true );
	
	self.gasmask_hud_elem = NewHudElem();
	self.gasmask_hud_elem.x = 0;
	self.gasmask_hud_elem.y = 0;
	self.gasmask_hud_elem.horzAlign = "fullscreen";
	self.gasmask_hud_elem.vertAlign = "fullscreen";
	self.gasmask_hud_elem.foreground = false;
	self.gasmask_hud_elem.sort = -1; // trying to be behind introscreen_generic_black_fade_in	
	self.gasmask_hud_elem SetShader("gasmask_overlay_delta2", 650, 490);
	self.gasmask_hud_elem.alpha = 1.0;
	
//	level.player delaythread( 1.0, ::gasmask_breathing );
	
	////scuba_mask = level.player GetCurrentWeapon();
	////scuba_mask hidepart( "J_Gun", "viewmodel_scuba_mask");
	
	if(bFade)
	{
		wait(0.25);
		self set_black_fade( 0.0, 0.25 );
	}
	thread bob_mask( self.gasmask_hud_elem );
}

gasmask_hud_off(bFade)
{
	wait 0.333; // AUDIO: wait timer is timed for audio, do not change without consulting audio department
	
	Assert(IsPlayer(self));	
	if(!IsDefined(bFade)) bFade = true;
	
	if(bFade)
	{
		self set_black_fade( 1.0, 0.25 );
		wait(0.25);
	}

	self notify( "stop_mask_bob" );

	self.gasmask_hud_elem Destroy();
	self.gasmask_hud_elem = undefined;
	level.player notify("stop_breathing");
	
	SetHUDLighting( false );
	
	if(bFade)
	{
		wait(0.25);
		self set_black_fade( 0.0, 0.25 );
	}
}

gasmask_breathing()
{
	delay = 1.0;
	self endon( "stop_breathing" );
	
	while ( 1 )
	{
		self play_sound_on_entity( "pybk_breathing_gasmask" );
		wait( delay );
	}
}

gas_mask_on_player_anim()
{
	level endon( "death" );
	//maps\payback_aud::payback_aud_msg_handler("gasmask_on_player"); // AUDIO: gas mask on
	level.player DisableWeaponSwitch();
	level.player DisableUsability();
	level.player DisableOffhandWeapons();
	wait(.25);
	level.player.last_weapon = level.player GetCurrentWeapon();
	level.player DisableWeapons();
	wait(.5);
	if ( level.player.last_weapon == "alt_ak47_grenadier" )
	{
		level.player.last_weapon = "ak47_grenadier";	// hack to fix SRE
	}
	if ( level.player.last_weapon == "alt_m4m203_acog_payback" )
	{
		level.player.last_weapon = "m4m203_acog_payback";	// hack to fix SRE
	}
	if ( level.player.last_weapon == "alt_m4_grenadier" )
	{
		level.player.last_weapon = "m4_grenadier";	// hack to fix SRE
	}
	
	stock_amt = undefined;
	clip_amt = undefined;
	
	if ( level.player.last_weapon != "none" )
	{
		stock_amt = level.player GetWeaponAmmoStock( level.player.last_weapon );
		clip_amt = level.player GetWeaponAmmoClip( level.player.last_weapon );
	}
		
	level.player TakeWeapon(level.player.last_weapon);
	level.player GiveWeapon( "scuba_mask_on" );
	level.player EnableWeapons();
	level.player SwitchToWeapon( "scuba_mask_on" );
	level.player delayThread( 0.75 , ::gasmask_hud_on );
	wait(2.5);
	level.player TakeWeapon( "scuba_mask_on" );
	level.player GiveWeapon(level.player.last_weapon);
	
	if ( level.player.last_weapon != "none" )
	{
		level.player SetWeaponAmmoStock( level.player.last_weapon , stock_amt );
		level.player SetWeaponAmmoClip( level.player.last_weapon , clip_amt );
		level.player SwitchToWeapon( level.player.last_weapon);
	}
	
	level.player EnableUsability();
	level.player EnableWeaponSwitch();	
	level.player EnableOffhandWeapons();
}

gas_mask_off_player_anim()
{
	level endon( "death" );
//	maps\payback_aud::payback_aud_msg_handler("gasmask_off_player"); // AUDIO: gas mask off
	level.player DisableWeaponSwitch();
	level.player DisableUsability();
	level.player DisableOffhandWeapons();
	wait(.25);
	level.player.last_weapon = level.player GetCurrentWeapon();

	level.player DisableWeapons();
	wait(.5);
	if ( level.player.last_weapon == "alt_ak47_grenadier" )
	{
		level.player.last_weapon = "ak47_grenadier";	// hack to fix SRE
	}
	if ( level.player.last_weapon == "alt_m4m203_acog_payback" )
	{
		level.player.last_weapon = "m4m203_acog_payback";	// hack to fix SRE
	}
	if ( level.player.last_weapon == "alt_m4_grenadier" )
	{
		level.player.last_weapon = "m4_grenadier";	// hack to fix SRE
	}
	
	stock_amt = undefined;
	clip_amt = undefined;
	
	if ( level.player.last_weapon != "none" )
	{
		stock_amt = level.player GetWeaponAmmoStock( level.player.last_weapon );
		clip_amt = level.player GetWeaponAmmoClip( level.player.last_weapon );
	}
	
	level.player TakeWeapon(level.player.last_weapon);
	level.player GiveWeapon( "scuba_mask_off" );
	level.player EnableWeapons();
	level.player SwitchToWeapon( "scuba_mask_off" );
	level.player delayThread( 0.02 , ::gasmask_hud_off );
	wait(2.5);
	level.player TakeWeapon( "scuba_mask_off" );
	level.player GiveWeapon(level.player.last_weapon);
	
	if ( level.player.last_weapon != "none" )
	{
		level.player SetWeaponAmmoStock( level.player.last_weapon , stock_amt );
		level.player SetWeaponAmmoClip( level.player.last_weapon , clip_amt );
		level.player SwitchToWeapon( level.player.last_weapon);	
	}
			
	level.player EnableUsability();
	level.player EnableWeaponSwitch();	
	level.player EnableOffhandWeapons();
    autosave_now();
}


