#include maps\_utility;
#include common_scripts\utility;
#include maps\enemyhq_code;
#include maps\_vehicle;
#include maps\_vehicle_code;
#include maps\_anim;
enemyhq_intro_pre_load()
{
	flag_init( "intro_done" );
	flag_init( "drive_in_done" );
	flag_init( "drive_start" );
	flag_init("FLAG_intro_truck_arrived");
	flag_init("FLAG_spawn_checkpoint_guys");
	flag_init("FLAG_player_bust_windshield");
	flag_init("FLAG_player_gun_up");
	flag_init("FLAG_stop_hit_reactions");
	flag_init("bring_up_clacker");
	flag_init("ally1_enter_veh");
	flag_init("ally2_enter_veh");
	flag_init("ally3_enter_veh");
	flag_init("ally4_enter_veh");
	flag_init("ally5_enter_veh");
	flag_init("FLAG_truck_exploder_start");
	flag_init("FLAG_blow_sticky_04");
	flag_init("FLAG_drive_in_startpoint");
	flag_init("FLAG_start_pathblockers");
}

setup_drive_in()
{
	level.start_point = "drive_in";
	flag_set("intro_done");
	spawn_player_truck();
	maps\enemyhq::setup_common();
	maps\enemyhq_audio::aud_truck_ext_idle_loop();
	flag_set("FLAG_drive_in_startpoint");
}

begin_drive_in()
{
	thread spawn_checkpoint_guys();
	thread get_in_truck_nag_vo();
	thread gold_door_on_player_truck();
	thread maps\enemyhq_rooftop_intro::blow_wall();
	thread player_enter_truck_progression(level.player_truck);
	thread truck_start_driving();
	thread truck_pathblockers();
	thread sticky_grenade_01();
	thread sticky_grenade_02();
	thread sticky_grenade_03();
	thread sticky_grenade_04();
	thread sticky_grenade_05();
	thread sticky_grenade_06();
	thread sticky_grenade_07();
	thread truck_exploder_start_driving();
	setup_allies_vehicle_approach();
	flag_wait( "drive_in_done" );
}
// ============================================================================================================
// =====================  DRIVE IN SCRIPTING STARTS HERE
// ============================================================================================================


get_in_truck_nag_vo()
{

	flag_wait("FLAG_intro_truck_arrived");
		
	nag_player_until_flag("Merrick","FLAG_player_enter_truck","Alright lets load up.","Adam, lets move!","Get in, Adam","Lets, go!");
	
}

gold_door_on_player_truck()
{
	wait 1;
	
	enable_trigger_with_targetname("TRIG_player_enter_truck");
	
	level.gold_player_door = Spawn("script_model",level.player_truck.origin);
	level.gold_player_door SetModel("vehicle_man_7t_front_door_RI_obj");
	level.gold_player_door.angles = level.player_truck.angles;
	level.gold_player_door LinkTo(level.player_truck);//_truck);
	
	flag_wait("FLAG_player_enter_truck");
	level.gold_player_door Delete();
	disable_trigger_with_targetname("TRIG_player_enter_truck");
}

setup_allies_vehicle_approach()
{
	foreach(ally in level.allies)
	{
		ally enable_ai_color();
	}
		
	if(level.start_point != "drive_in")
	{
		safe_activate_trigger_with_targetname("TRIG_intro_allies_wait_for_ride");
	}
		
	flag_wait("FLAG_intro_truck_arrived");
	
    allynode1 = getnode("ally1node", "targetname");
    allynode2 = getnode("ally2node", "targetname");
    allynode3 = getnode("ally3node", "targetname");
    allynode4 = getnode("ally4node", "targetname");
    allynode5 = getnode("ally5node", "targetname");    
    
    level.allies[0].animname = "baker";
    level.allies[1].animname = "keegan";
    level.allies[2].animname = "hesh";
    
    thread guy_goto_veh_and_enter( level.allies[0], level.player_truck, allynode1,"ally1_enter_veh");
    thread guy_goto_veh_and_enter( level.allies[1], level.player_truck, allynode5,"ally2_enter_veh");
    thread guy_goto_veh_and_enter( level.allies[2], level.player_truck, allynode3,"ally3_enter_veh");
    thread dog_goto_veh_and_enter( level.dog, level.player_truck, allynode2,"ally5_enter_veh");
}

guy_goto_veh_and_enter( guy, veh, node, flag )
{
    guy SetGoalNode(node);
    guy.goalradius = 32;
 
    guy waittill("goal");
	flag_wait("FLAG_player_enter_truck");

	
	if(guy.animname == "keegan")
	{
		//guy override_ride_anims();
		veh anim_single_solo(guy,"enter_truck","tag_driver");
		guy LinkTo(level.player_truck,"tag_driver");
   		veh thread anim_loop_solo(guy, "enter_truck_loop","stop_keegan_loop","tag_driver");
   		guy thread keegan_additional_drivein_anims();
	}
	
    if(guy.animname == "baker")
	{
    	wait 2;
		guy LinkTo(level.player_truck,"tag_detach");
   		veh thread anim_loop_solo(guy, "enter_truck_loop","stop_baker_loop","tag_detach");
    }
	
    if(guy.animname == "hesh")
	{
    	wait 2;
		guy LinkTo(level.player_truck,"tag_detach");
   		veh thread anim_loop_solo(guy, "enter_truck_loop","stop_hesh_loop","tag_detach");
    }
    
    flag_set(flag);
}

#using_animtree( "generic_human" );
override_ride_anims()
{
	wait .1;
	self.vehicle_idle_override = %ehq_truck_enter_loop_keegan;
}

keegan_additional_drivein_anims()
{
	level endon("stop_truck_hit_reactions");

	while(!flag("FLAG_stop_hit_reactions"))
	{
		level.player_truck waittill( "veh_jolt", jolt );
		level.player_truck notify("stop_keegan_loop");
		level.player_truck anim_single_solo(self,"truck_smash","tag_driver");
		level.player_truck thread anim_loop_solo(self, "enter_truck_loop","stop_keegan_loop","tag_driver");
	}
}



dog_goto_veh_and_enter( guy, veh, node, flag )
{
    guy SetGoalNode(node);
    guy.goalradius = 32;
    guy waittill("goal");
    
   	flag_wait("FLAG_player_enter_truck");

	veh anim_single_solo(guy,"enter_truck","tag_driver");
    guy LinkTo(level.player_truck,"tag_dog");
    veh thread anim_loop_solo(guy, "veh_idle","stop_dog_loop","tag_dog");
    flag_set(flag);
    guy thread dog_additional_drivein_anims();
}

dog_additional_drivein_anims()
{
	level endon("stop_truck_hit_reactions");
	thread stop_vehicle_hit_reactions();
	
	
	while(!flag("FLAG_stop_hit_reactions"))
	{
		level.player_truck waittill( "veh_jolt", jolt );
		level.player_truck notify("stop_dog_loop");
		level.player_truck anim_single_solo(self,"truck_smash","tag_dog");
		level.player_truck thread anim_loop_solo(self, "veh_idle","stop_dog_loop","tag_dog");
	}
}

stop_vehicle_hit_reactions()
{
	flag_wait("FLAG_stop_hit_reactions");
	
	level notify("stop_truck_hit_reactions");
}

truck_start_driving()
{
    ehq_intro_flag_wait_all("ally1_enter_veh","ally2_enter_veh","ally3_enter_veh","ally5_enter_veh","FLAG_player_enter_truck");
   
    wait 1.5;
    level.player_truck.dontunloadonend = true;	
    flag_set("drive_start");
    thread drive_in_vo();
	
    drive_path = GetVehicleNode( "drive_start_path", "targetname" );
	level.player_truck thread vehicle_paths( drive_path );
    level.player_truck StartPath( drive_path );
    
    level.player_truck thread vehicle_loop_anim();
    

    level.player_truck thread handle_phys_debris();

    
    //level.player_truck Vehicle_SetSpeed( 15, 4, 4 ); //needed to get the vehicle moving
    //level.player_truck ResumeSpeed( 25 );
  	
}
handle_phys_debris()
{
	flag_wait("FLAG_VO_hang_on_again");
	delayThread( 4,::flag_clear,"FLAG_VO_hang_on_again");
	while(flag("FLAG_VO_hang_on_again"))
	{
		ent_offset= (275,RandomIntRange(-60,-10),30);
		rel_launch_ang= VectorNormalize((RandomFloatRange(2,12), RandomFloatRange(-1.6,-0.1), (RandomFloatRange(2,12))));
		physics_fountain("ehq_seat_dyn", self, ent_offset,rel_launch_ang,0,4,1,RandomIntRange(15000,17000));
		//wait 0.05;
		ent_offset= (275,RandomIntRange(10,60),30);
		rel_launch_ang= VectorNormalize((RandomFloatRange(2,12), RandomFloatRange(-1.6,-0.1), (RandomFloatRange(2,12))));
		physics_fountain("ehq_seat_dyn", self, ent_offset,rel_launch_ang,0,4,1,RandomIntRange(15000,17000));
		//physics_fountain("ehq_seat_dyn", self, ent_offset,rel_launch_ang,0,4,1,RandomIntRange(14000,24000));
		//wait 0.05;
		ent_offset= (275,0,30);
		rel_launch_ang= VectorNormalize((RandomFloatRange(2,12), RandomFloatRange(-1.6,-0.1), (RandomFloatRange(2,12))));
		physics_fountain("ehq_seat_dyn", self, ent_offset,rel_launch_ang,0,4,1,RandomIntRange(15000,17000));
		//physics_fountain("ehq_seat_dyn", self, ent_offset,rel_launch_ang,0,4,1,RandomIntRange(14000,24000));
		wait 0.5;
	}

}

vehicle_loop_anim()
{
	self SetFlaggedAnimRestart("vehicle_anim_flag", self getanim("truck_loop"));

	wait 12;
	
	//IPrintLnBold("STOP TRUCK LOOP");
	
	self ClearAnim(self getanim("truck_loop"), 0);
}


drive_in_vo()
{
	wait 1.5;
	
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_oncetheexplosionsgo");
	thread add_dialogue_line("Merrick","Once the explosions go off, we're headed straight for the homeplate dugout...");
	
	wait 1;
	
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_thatsthequickestway");
	thread add_dialogue_line("Merrick","That's the quickest way to Bishop.");
	
	flag_wait("bring_up_clacker");
	thread add_dialogue_line("Merrick","Alright Rook, clack it!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_alrightadamclackit");
	
	
	flag_wait("FLAG_player_gun_up");
	thread add_dialogue_line("Merrick","Weapons free!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_weaponsfree");
	
	flag_wait("FLAG_VO_cut_off1");
	thread add_dialogue_line("Merrick","They are trying to cut us off... going around!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_theyaretryingto");
	
	flag_wait("FLAG_VO_cut_off2");
	thread add_dialogue_line("Merrick","They are boxing us in!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_theyareboxingus");
	thread maps\enemyhq_audio::aud_bumpy_ride();
	
	flag_wait("FLAG_VO_hang_on_again");
	thread add_dialogue_line("Merrick","Hold on!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_holdon");
	
}

spawn_trucks()
{
	level.convoy_veh_01 = spawn_vehicle_from_targetname( "convoy_veh_01" );
	level.convoy_veh_01a = spawn_vehicle_from_targetname( "convoy_veh_01a" );
	level.convoy_veh_02 = spawn_vehicle_from_targetname( "convoy_veh_02" );
	level.convoy_veh_03 = spawn_vehicle_from_targetname( "convoy_veh_03" );
	level.convoy_veh_03a = spawn_vehicle_from_targetname( "convoy_veh_03a" );
	level.convoy_veh_04 = spawn_vehicle_from_targetname( "convoy_veh_04" );
	level.convoy_veh_05 = spawn_vehicle_from_targetname( "convoy_veh_05" );
	level.convoy_veh_07 = spawn_vehicle_from_targetname( "convoy_veh_07" );		
}

spawn_player_truck()
{
	level.player_truck = spawn_vehicle_from_targetname( "player_truck" );
	
	if(level.start_point == "intro" || level.start_point == "introshoot" || level.start_point == "drive_in" )
	{
		thread handle_truck_windshield_break();
	}
}
handle_truck_windshield_break()
{
	level.truck_broke_glass = getent("mdl_truck_broken_glass","targetname");
	level.truck_broke_glass linkto(level.player_truck,"tag_window_front_right");
	level.truck_broke_glass hide();
	flag_wait("FLAG_player_bust_windshield");
	level.truck_broke_glass show();	
}

spawn_checkpoint_guys()
{
	flag_wait("FLAG_spawn_checkpoint_guys");
	guys = array_spawn_targetname_allow_fail("intro_checkpoint_guys");
	level.truck_bash_guys = array_spawn_targetname_allow_fail("intro_checkpoint_guys_truck_bash");
	
	flag_wait("FLAG_blow_sticky_01");
	
	wait 4;
	
	foreach(guy in guys)
	{
		if(IsDefined(guy) && IsAlive(guy))
		{
			guy.ignoreall = false;
		}
	}
}

truck_exploder_start_driving()
{
    flag_wait ("FLAG_truck_exploder_start");
    //wait .5;	
    level.convoy_veh_06 = spawn_vehicle_from_targetname_and_drive( "convoy_veh_06" );
    level.convoy_veh_06b = spawn_vehicle_from_targetname_and_drive( "convoy_veh_06b" );
    level.convoy_veh_06.dontunloadonend = true;	 
    
    
}

truck_pathblockers()
{
	flag_wait("FLAG_start_pathblockers");
	
	
	
	truck2 = spawn_vehicle_from_targetname_and_drive("convoy_veh_pathblocker_2");												 
	truck2b = spawn_vehicle_from_targetname_and_drive("convoy_veh_pathblocker_2b");
	
	wait 2;
	
	truck1 = spawn_vehicle_from_targetname_and_drive("convoy_veh_pathblocker_3");
	
}

sticky_grenade_01()
{
	flag_wait ("FLAG_blow_sticky_01");
	thread maps\enemyhq_audio::aud_blow_vehicle(level.convoy_veh_01);
	//level.player TakeWeapon("c4");
	level.player notify("detonate");
	startpos = level.convoy_veh_01.origin;
	level.convoy_veh_01 DoDamage( 9999, startpos);
	RadiusDamage( level.convoy_veh_01.origin, 350, 4000, 1000, level.player, "MOD_EXPLOSIVE" );
	wait .3;
	
	startposA = level.convoy_veh_01a.origin;
	level.convoy_veh_01a DoDamage( 9999, startposA);
	RadiusDamage( level.convoy_veh_01a.origin, 350, 4000, 1000, level.player, "MOD_EXPLOSIVE" );
}

sticky_grenade_02()
{
	flag_wait ("FLAG_blow_sticky_02");
	
	foreach(guy in level.truck_bash_guys)
	{
		//guy StartRagdoll();
		guy kill();
	}
	
	jeep = GetEnt("truck_bash_jeep","targetname");
	
	thread maps\enemyhq_audio::aud_blow_vehicle(jeep);
	startpos = jeep.origin;
	jeep DoDamage( 9999, startpos);
	
	RadiusDamage( jeep.origin, 750, 4000, 1000, level.player, "MOD_EXPLOSIVE" );
	
	PlayFX(level._effect[ "lynxexplode" ], jeep.origin );
	
	jeep SetModel( "vehicle_iveco_lynx_destroyed_iw6_static" );
	

		    
		
	
	guys = array_spawn_targetname_allow_fail("field_guys1");
	
	thread truck_bash_moment();
	
}

truck_bash_moment()
{
	flag_wait("FLAG_truck_bash");
	
	thread maps\enemyhq_code::screen_shake_vehicles();
	thread maps\enemyhq_code::reaction_anims();
	scn = GetEnt( "convoy_veh_02_blow_spot", "targetname" );
	jeep = GetEnt( "truck_bash_jeep", "targetname" );
	jeep.animname = "intro_jeep_ram";	
	
	jeep useAnimTree( level.scr_animtree[ jeep.animname ] );
	
	scn thread anim_single_solo(jeep,"jeep_ram");
	
	flag_set("FLAG_player_bust_windshield");	
	level.player_truck thread listen_player_jolt_jumps();	
}



silent_magic_bullet_windshield()
{
	startpoint = GetEnt("drivein_magic_bullet_start","targetname");
		
	MagicBullet("nosound_magicbullet", startpoint.origin, level.player.origin);
	wait .125;
	MagicBullet("nosound_magicbullet", startpoint.origin, level.player.origin);
	wait .125;
	MagicBullet("nosound_magicbullet", startpoint.origin, level.player.origin);
	wait .125;
	
}
sticky_grenade_03()
{
	
	flag_wait ("FLAG_blow_sticky_03");
	thread maps\enemyhq_audio::aud_blow_vehicle(level.convoy_veh_03);
	startposA = level.convoy_veh_03.origin;
	level.convoy_veh_03 DoDamage( 9999, startposA );
	RadiusDamage( level.convoy_veh_03.origin, 350, 4000, 1000, level.player, "MOD_EXPLOSIVE" );

	wait 1.5;
	
	startposB = level.convoy_veh_03a.origin;
	level.convoy_veh_03a DoDamage( 9999, startposB );
	RadiusDamage( level.convoy_veh_03a.origin, 350, 4000, 1000, level.player, "MOD_EXPLOSIVE" );
	PlayFX(getfx("field_smoke_stack_small"),startposB);
	PlayFX(getfx("field_smoke_stack_thick"),startposA);
}

sticky_grenade_04()
{
	
	flag_wait ("FLAG_blow_sticky_04");
	thread maps\enemyhq_audio::aud_blow_vehicle(level.convoy_veh_04);
	startpos = level.convoy_veh_04.origin;
		
	level.convoy_veh_04 DoDamage( 9999, startpos);
	RadiusDamage( level.convoy_veh_04.origin, 350, 4000, 1000, level.player, "MOD_EXPLOSIVE" );
}

sticky_grenade_05()
{
	flag_wait ("FLAG_blow_sticky_05");
	thread maps\enemyhq_audio::aud_blow_vehicle(level.convoy_veh_05);
	startpos = level.convoy_veh_05.origin;
		
	level.convoy_veh_05 DoDamage( 9999, startpos);
	RadiusDamage( level.convoy_veh_05.origin, 350, 4000, 1000, level.player, "MOD_EXPLOSIVE" );
	
	PlayFX(getfx("field_smoke_stack_small"),startpos);

	guys = array_spawn_targetname_allow_fail("field_guys6");
	guysb = array_spawn_targetname_allow_fail("field_guys6_ignore");
	
	foreach(guy in guysb)
	{
		guy.ignoreall = true;
}
}

sticky_grenade_06()
{
	flag_wait ("FLAG_blow_sticky_06");
	//thread maps\enemyhq_audio::aud_blow_vehicle(level.convoy_veh_06);
	//startpos = level.convoy_veh_06.origin;
	//level.convoy_veh_06 thread vehicle_pathdetach();
	//level.convoy_veh_06 thread deathrollon ();
	//level.convoy_veh_06 DoDamage( 9999, startpos);	
	
	
}


sticky_grenade_07()
{
	
	flag_wait ("FLAG_blow_sticky_07");
	thread maps\enemyhq_audio::aud_blow_vehicle(level.convoy_veh_07);
	startpos = level.convoy_veh_07.origin;		
	level.convoy_veh_07 DoDamage( 9999, startpos);
	RadiusDamage( level.convoy_veh_07.origin, 350, 4000, 1000, level.player, "MOD_EXPLOSIVE" );
	
	PlayFX(getfx("field_smoke_stack_small"),startpos);
}

ehq_intro_flag_wait_all( flag1, flag2, flag3, flag4, flag5, flag6 )
{
	if ( isdefined( flag1 ) )
		flag_wait( flag1 );

	if ( isdefined( flag2 ) )
		flag_wait( flag2 );

	if ( isdefined( flag3 ) )
		flag_wait( flag3 );

	if ( isdefined( flag4 ) )
		flag_wait( flag4 );
	
	if ( isdefined( flag5 ) )
		flag_wait( flag5 );
	
	if ( isdefined( flag6 ) )
		flag_wait( flag6 );
}
