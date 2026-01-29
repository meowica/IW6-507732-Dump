#include maps\_utility;
#include common_scripts\utility;
#include maps\enemyhq_code;
#include maps\_vehicle;
#include maps\_anim;


//fx\impacts\tank_round_spark.efx
enemyhq_rooftop_intro_pre_load()
{
	flag_init("finished_intro_dof");
	flag_init("bishop_glimpse_over");
	flag_init("watching_bishop_glimpse");
	flag_init("activate_vip_sniper");
	flag_init("enable_butchdance");
	flag_init("start_rpg_kibble");
	flag_init("start_exfil_sniper");
	flag_init("blow_koolaid_wall");
	flag_init("FLAG_move_to_player_truck");
	flag_init("checkit_zoom");
	flag_init("checkit_dryfire");
	flag_init("checkit_pan");
	flag_init("start_convoy");

	precacheModel( "weapon_bursted_sticky_grenade" );
	precacheModel( "hamburg_security_gate_crash_pieces");
	precacheModel( "hamburg_security_gate_crash");
	precacheModel( "weapon_sticky_grenade" );
	precacheModel( "ehq_seat_dyn");
	precacheModel( "viewmodel_mk14");
	precacheModel( "cargocontainer_20ft_white");
	precacheModel( "com_ammo_pallet");
	precacheModel( "berlin_barrelcluster_pallet_01");
	precacheModel( "militarybase_generator");
	precacheModel( "ls_aid_crate_02");
	precacheModel( "shipping_frame_boxes");
	
	

	
	PreCacheShader( "killiconheadshot" );
	precacheitem("remote_chopper_gunner");
	PreCacheShader( "remote_chopper_hud_target_enemy" );
	PreCacheShader( "remote_chopper_hud_target_friendly" );
	PreCacheShader( "remote_chopper_hud_target_e_vehicle");
	PreCacheShader( "inventory_stickybomb");
	
	PrecacheItem( "nosound_magicbullet" );
	
	//This stuff needs to run for everyone's checkpoint.
	thread sniper_vip_breach();
	thread butchdance();
	thread rpg_kibble();
	thread exfil_sniper();
	thread handle_m32_launcher();	
	
	level.player thread handle_sticky_clacker();
	level.switching_to_detonator = 0;
	level.switching_from_detonator = 0;
	
	//hide stuff.								 script_parameters
	hideme = GetEntArray( "intro_hide_on_load", "script_noteworthy" );
	array_call(hideme,::Hide);
	array_call(hideme,::NotSolid);
	
}

setup_rooftop_shoot()
{
	level.start_point = "introshoot";
	maps\enemyhq_intro::spawn_player_truck();
	maps\enemyhq::setup_common("introroof");
	thread intro_common();
	level.allies[0]  delayCall(0.1,::AllowedStances,"prone");
	level.player switchToWeapon( "deserteagle" );
	thread cargo_choppers();
	thread blow_wall();
	thread air_armada();
		/#
		array_spawn_targetname_allow_fail("dog_test", 1);
//			delaythread(5,::flag_set,"start_exfil_sniper");
//	delaythread(5,::flag_set,"blow_koolaid_wall");
//	delaythread(5,::flag_set,"start_sniper_vip_breach");
//	delaythread(5,::flag_set,"start_butchdance");
//	delaythread(5,::flag_set,"start_rpg_kibble");
//	thread debug_color_dog();
		
		
		#/

	
}

debug_color_dog()
{
	wait 10;
	level.dog thread disable_ai_color();
	IPrintLnBold("DISABLE");
	
	wait 10;
	level.dog thread enable_ai_color();
	IPrintLnBold("ENABLE");
	
	wait 10;
	level.dog thread disable_ai_color();
	IPrintLnBold("DISABLE");
}

begin_rooftop_shoot()
{
	level.mk32_intro_fire = true;
	
	disable_trigger_with_targetname("TRIG_player_enter_truck");
	level.player.allow_dry_fire = false;
	level.next_repeat_vo = 0;
	
	thread keegan_tinkers_with_rifle();
	level.player SetStance("crouch");
	
	wait 0.05;
	//level.player SetStance("prone");
	level.player SetStance("crouch");
	thread autosave_by_name("intro_rooftop");
	
	safe_activate_trigger_with_targetname( "rooftop_crawl_forward");
//	wait 3;
	thread convoy();
	pickup_mk32();
	level waittill("stop_convoy");
	
	thread go_street();
	flag_wait( "intro_done" );
	level.mk32_intro_fire = false;

}

setup_rooftop_intro()
{
	level.ehq_blackout_time =5;
	intro_screen_create( "Enemy HQ", "October 22nd - 6:01", "Adam", "USMC","No Man's Land" );
	intro_screen_custom_func( ::introscreen );
	
	level.start_point = "intro";
	maps\enemyhq::setup_common("introroof");
	thread cargo_choppers();
	
}
introscreen()
{
//	delayThread(::add_dialogue_line,"Merrick","Calibrating remote sniper");
	level.allies[0] delayThread(2,::char_dialog_add_and_go, "enemyhq_mrk_calibratingremotesniper" );

	
	level.allies[0] delaythread (4.7,::char_dialog_add_and_go, "enemyhq_mrk_adjustingfocus" );
	//level.allies[0] delaythread (5.5,::char_dialog_add_and_go, "enemyhq_mrk_andzoom" );


	
	maps\_introscreen::introscreen( false,level.ehq_blackout_time );
}
intro_common()
{
	thread ship_vista();

}

begin_rooftop_intro()
{
	thread maps\enemyhq_intro::spawn_player_truck();
	disable_trigger_with_targetname("TRIG_player_enter_truck");
	thread intro_common();
	thread autosave_now_silent();
	level.player.allow_dry_fire = true;
	level.player takeallweapons();
	level.player giveWeapon("deserteagle");
	level.player switchToWeapon( "deserteagle" );
	level.player.presniper_weapon = "deserteagle";
	
	level.player GiveWeapon( "remote_chopper_gunner" );
	level.player switchToWeapon( "remote_chopper_gunner" );	
	
	level.player FreezeControls( true );
		
	//flag_wait( "introscreen_complete" );
	wait level.ehq_blackout_time;
	level.player FreezeControls( false );
//	sniper_vip_breach();
	safe_activate_trigger_with_targetname( "rooftop_intro_color");
	level.allies[0]  delayCall(0.1,::AllowedStances,"crouch");
	level.allies[0]  delayCall(0.3,::AllowedStances,"prone");
	
	thread bishop_glimpse();
	//thread animate_vip_enemies_intro();
	
	level.player intro_overlook_static();

	flag_wait("bishop_glimpse_over");
}
blow_wall()
{
	
	flag_wait("blow_koolaid_wall");
	ent = GetEnt("security_gate_crash_pieces2", "targetname");
	ent.anim_speed = 2;
	root = getstruct("security_gate_root", "targetname");

	ent.animname = "hamburg_security_gate_crash";	

	ent useAnimTree( level.scr_animtree[ ent.animname ] );
	
	root anim_single_solo(ent,"security_gate_crash" );

	
}
exfil_sniper()
{
	flag_wait("start_exfil_sniper");

	wait_for_dpad();
	level.player.remote_canreload = true;
	level.player setup_sniper_view("exfil_sniper_struct");
	level.player endon("remote_turret_deactivate");
	wait 0.05;
	
	level.remote_turret_max_fov = 45;
	level.remote_turret_min_fov = 10;

	lookat = getstruct( "exfil_sniper_struct", "targetname" );
	
	level.player.turret_look_at_ent.origin = lookat.origin;

	level.player LerpViewAngleClamp(1.0,0.2,0.2,30,30,2,25);
	level.remote_turret_current_fov = 25;
	level.player LerpFOV( level.remote_turret_current_fov,0.05 );
	level.player thread intro_dof( 0.7 );
	level waittill("done_sniping_early");
	level.player notify( "use_remote_turret");
}

butchdance()
{
	flag_wait("enable_butchdance");
	wait_for_dpad();
	
	level.player setup_sniper_view("butchdance_struct");
	level.player endon("remote_turret_deactivate");
	wait 0.05;
	
	level.remote_turret_max_fov = 25;
	level.remote_turret_min_fov = 6;

	lookat = getstruct( "butchdance_struct", "targetname" );
	
	level.player.turret_look_at_ent.origin = lookat.origin;

	level.player LerpViewAngleClamp(1.0,0.2,0.2,25,10,5,5);
	level.remote_turret_current_fov = 9;
	level.player LerpFOV( level.remote_turret_current_fov,0.05 );
	level.player thread intro_dof( 0.7 );
//	IPrintLnBold("waiting 8 or weapon fire.");
	level.player waittill("weapon_fired");
//	IPrintLnBold("past wait- waiting 10 or until ammo out..");
	
	level notify("hot_butchdance_action");
	level waittill_notify_or_timeout("done_sniping_early",10);
	wait 0.5;
	level.player notify( "use_remote_turret");

}

rpg_kibble()
{
	flag_wait("start_rpg_kibble");
	wait_for_dpad();
	
	level.player setup_sniper_view("rpg_kibble_struct");
	level.player endon("remote_turret_deactivate");
	wait 0.05;
	
	level.remote_turret_max_fov = 15;
	level.remote_turret_min_fov = 4;

	lookat = getstruct( "rpg_kibble_struct", "targetname" );
	
	level.player.turret_look_at_ent.origin = lookat.origin;

	level.player LerpViewAngleClamp(1.0,0.2,0.2,6,6,5,5);
	level.remote_turret_current_fov = 8;
	level.player LerpFOV( level.remote_turret_current_fov,0.05 );
	level.player thread intro_dof( 0.7 );
	
	level notify("ppoor_kibble_action");
	flag_wait_or_timeout("done_sniping_early",60);
	wait 0.5;
	level.player notify( "use_remote_turret");

}

sniper_vip_breach()
{
	flag_wait("activate_vip_sniper");
	wait_for_dpad();
	
	level.player setup_sniper_view("vip_sniper_breach_struct");
	level.player endon("remote_turret_deactivate");
	wait 0.05;
	
	level.remote_turret_max_fov = 10;
	level.remote_turret_min_fov = 2;

	lookat = getstruct( "vip_sniper_breach_struct", "targetname" );
	
	level.player.turret_look_at_ent.origin = lookat.origin;
	angclamp = 4;

	level.player LerpViewAngleClamp(1.0,0.2,0.2,angclamp,6,2,2);
	level.remote_turret_current_fov = 7;
	level.player LerpFOV( level.remote_turret_current_fov,0.05 );
	level.player thread intro_dof( 0.7 );
//	IPrintLnBold("waiting 8 or weapon fire.");
	level.player waittill("weapon_fired");
//	IPrintLnBold("past wait- waiting 10 or until ammo out..");
	
	level notify("vip_breach_hot");
	level waittill_notify_or_timeout("done_sniping_early",10);
	wait 0.5;
	level.player notify( "use_remote_turret");
	
	
	
}



wait_for_dpad()
{
	level.player NotifyOnPlayerCommand( "scripted_sniper_dpad", "+actionslot 1" ); // Only ever triggered by code now.
	level.player setWeaponHudIconOverride( "actionslot1", "killiconheadshot" );
	RefreshHudAmmoCounter();

	level.player waittill( "scripted_sniper_dpad");


	level.player.ignoreme = true;
	level.player setWeaponHudIconOverride( "actionslot1", "none" );
	level.player NotifyOnPlayerCommand( "", "+actionslot 1" ); // Only ever triggered by code now.
	level.player.presniper_weapon = level.player GetCurrentWeapon();
	level.player GiveWeapon( "remote_chopper_gunner" );
	level.player switchToWeapon( "remote_chopper_gunner" );	
	wait 0.05;
	//level.player FreezeControls( true );
	wait 1.5;	
	thread set_black_fade(1,0.15);
	delayThread(0.45,::set_black_fade,0,0.15);
	//level.player delayCall(0.45,::FreezeControls,false);
	wait 0.25;
	
}

setup_sniper_view( lookat_struct,forward_dist )
{
	if(!IsDefined(forward_dist))
		forward_dist = 8000;
	level.player thread watch_for_remote_turret_activate(forward_dist);
	
	start = getstruct( "sniper_placement", "targetname" );
	level.remote_sniper_origin = start.origin;

	lookat = getstruct( lookat_struct, "targetname" );
	//remote_sniper_angles = VectorToAngles(lookat.origin - start.origin);
	
	if ( !IsDefined( self.turret_look_at_ent ) )
	{
		self.turret_look_at_ent = Spawn( "script_model", self.origin );
		self.turret_look_at_ent SetModel( "tag_origin" );
	}
	self.turret_look_at_ent.origin = lookat.origin;
	
	self notify( "use_remote_turret");

	
}

debug_lookent()
{
	self endon("remote_turret_deactivate");
	
	while (isdefined(self.turret_look_at_ent))
	{
		IPrintLn( self.turret_look_at_ent.angles);
		wait 0.05;
		
	}
	
}



debug_look_flag()
{
	curr = flag("bishop_glimpse");
	while(1)
	{
		if(curr)
			flag_waitopen( "bishop_glimpse");
		else
			flag_wait( "bishop_glimpse");
		curr = flag("bishop_glimpse");
		IPrintLnBold("glimpse flag changed to: ",curr);

		
	}
	
}


nag_player_dialog_debug( talker,dialog,wait_flag,first_wait_time)
{
	level endon(wait_flag);
	if(!IsDefined(first_wait_time))
		first_wait_time = 6;
	current_wait = first_wait_time;
	while(!flag(wait_flag))
	{
		
		flag_wait_or_timeout(wait_flag,current_wait);
		if(!flag(wait_flag))
		{
			thread add_dialogue_line(talker,dialog);
			current_wait *= 1.5;
			current_wait = min(current_wait,(first_wait_time * 3));
			
		}
		
	}
}
monitor_player_used_zoom(start_fov)
{
	
	while(!flag("checkit_zoom"))
	{
		if( abs(start_fov - level.remote_turret_current_fov) > 30)
			flag_set("checkit_zoom");
		wait 0.05;
	}

}

sniper_paces()
{
	sniper_paces_static();
	level.player ForceUseHintOff();
	}

sniper_paces_static()
{
	level endon( "bishop_glimpse");
	
	flag_clear("checkit_pan");
	//Check DryFire.
	
	
	//Check Zoom
	if(!flag("checkit_zoom"))
	{
		thread add_dialogue_line("Merrick","Adam, zoom in on the fleet.");
		flag_wait_or_timeout( "checkit_zoom",4);
		if(!flag("checkit_zoom"))
		{
			level.player ForceUseHintOn( "Use ^3[{+sprint}]^7 to control zoom." );
			flag_wait_or_timeout( "checkit_zoom",4);
			if(!flag("checkit_zoom"))
			{
				talker = "Merrick";
				dialog= "Adam, Try using the Sniper Zoom.";
				wait_flag = "checkit_zoom";
	
				first_wait = 6;
				nag_player_dialog_debug( talker,dialog,wait_flag,first_wait);
			}
			level.player ForceUseHintOff();
		}
		wait 0.1;
		thread add_dialogue_line("Merrick","Zoom online.");
	
	
	}
	if(	flag("checkit_dryfire") )
	{
		flag_clear("checkit_dryfire");
		thread add_dialogue_line("Merrick","Adam, fire the remote sniper again- it should dryfire.");
		self thread maps\enemyhq_remoteturret::remote_turret_monitor_dryfire( "remote_sniper" );
	}
	else
		thread add_dialogue_line("Merrick","Dry-fire the remote sniper.");
		
	flag_wait_or_timeout( "checkit_dryfire",4);
	while(!flag("checkit_dryfire"))
	{
		talker = "Merrick";
		dialog= "Adam, test-fire the remote sniper.";
		wait_flag = "checkit_dryfire";
		first_wait = 6;
		level.player ForceUseHintOn( "Press ^3[{+attack}]^7 to fire the remote sniper" );
		
		nag_player_dialog_debug( talker,dialog,wait_flag,first_wait);
		level.player ForceUseHintOff();
		
	}
	thread add_dialogue_line("Merrick","That's Foxtrot Golf.");
	
	wait 3;

		
				
	thread add_dialogue_line("Merrick","You have full control. Eyes on for Old Boy- look for Fed activity.");
	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_handingcontroltoyou" );
	}
	
intro_overlook_static()
{
//	thread add_dialogue_line("Merrick","Calibrating remote sniper");
//	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_calibratingremotesniper" );
	
//	
//	delaythread (0.5,::add_dialogue_line,"Merrick","...adjusting focus....and zoom.");
//	level.allies[0] delaythread (0.5,::char_dialog_add_and_go, "enemyhq_mrk_adjustingfocus" );
//	delaythread (2.5,::add_dialogue_line,"Merrick","...adjusting focus....and zoom.");
//	level.allies[0] delaythread (2.5,::char_dialog_add_and_go, "enemyhq_mrk_andzoom" );
//
	
	lookat = getstruct( "sniper_introaim_static", "targetname" );
	level.remote_turret_current_fov = Int(lookat.script_noteworthy);
	
	setup_sniper_view("sniper_introaim_static",5000);
	
	
	wait 0.05;
//	self notify( "remote_turret_nozoom" );
//	self EnableSlowAim( 0.25,0.25);
	self LerpViewAngleClamp(1.0,0.2,0.2,30,60,15,20);
	
	
	self.turret_look_at_ent.origin = lookat.origin;
	thread intro_dof( 0.7 );
	
	
	self LerpFOV( level.remote_turret_current_fov,0.05 );
	
	
	//self thread intro_dof( );
	
		
	thread air_armada();
	self thread monitor_player_used_zoom(55);
			

	
	delayThread(2,::add_dialogue_line,"Merrick","There goes Vargas' invasion fleet.");
	level.allies[0] delayThread(2,::char_dialog_add_and_go, "enemyhq_mrk_theregoesvargasinvasion" );
	
	wait 4;
//	thread autosave_by_name("intro_fleet");

	thread add_dialogue_line("Merrick","Adam, you need to run the remote sniper through its paces.");
	
	wait 2;
	thread sniper_paces();
	monitor_player_bishop();
	self notify( "remote_turret_nozoom" );
	
	
	
	
	if(!Flag( "bishop_glimpse"))
	{
		thread add_dialogue_line("Merrick","I see activity in VIP suites. I'm Overriding control.");
		level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_iseeactivityin" );
	}
	else
	{
		thread add_dialogue_line("Merrick","Wait, you have something.");
	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_waitwhatwasthat" );
	}
	thread intro_dof( 0.7 );
	
	wait 0.4;
	last_dist = Length(self.turret_look_at_ent.origin - self.origin);
	lookat = getstruct( "sniper_introaim_4", "targetname");
//	lookat = getstruct( lookat.target, "targetname" );
	newpos = self.origin + (AnglesToForward( level.player GetPlayerAngles()) *last_dist);
//	Sphere(newpos,50,(1,1,1),0,200);
//	Sphere(lookat.origin,50,(0,0,1),0,200);
//	wait 4;
	self.turret_look_at_ent.origin = newpos;
//	wait 0.05;
//	IPrintLnBold("snapping now");
	self.player_view_controller SnapToTargetEntity( self.turret_look_at_ent );
	
	self LerpViewAngleClamp(0,0,0,0,0,0,0);
//	wait 4;
//	IPrintLnBold("NORMAL_MOVE");
	
	dist = Length(lookat.origin - self.turret_look_at_ent.origin) / 1000;
	dist = min(dist, 4);
	dist = max(dist, 1);
	wait 0.05;
	self.turret_look_at_ent MoveTo( lookat.origin,dist,dist/4,dist/4);
	lerp_to = 2;//Int(1.5);
	//IPrintLnBold("Lerping to " + lerp_to  );
	self LerpFOV( lerp_to,dist );
	level.remote_turret_current_fov = lerp_to;
	
	flag_set("watching_bishop_glimpse");
	wait dist;
	self LerpViewAngleClamp(0,0,0,5,5,1,1);
	level.remote_turret_min_fov = 1;
	level.remote_turret_max_fov = 4;
	delaythread(0.1,::add_dialogue_line,"Merrick","We have a possible ID on Old Boy. VIP Suites, top floor.");
	//thread add_dialogue_line("Merrick","Tagging this view for later.");
	delaythread(3.5,::add_dialogue_line,"Hesh","Roger that.");

	self thread maps\enemyhq_remoteturret::remote_turret_handle_zoom();
//	lookat = getstruct( lookat.target, "targetname" );
	wait 4;
//	lerp_to = Int(lookat.script_noteworthy);
//	self LerpFOV( 1.5,4 );
	wait 6.7;
	//wait 1;
//	self.turret_look_at_ent MoveTo( lookat.origin,4,1,1);
	delaythread(0.5,::add_dialogue_line,"Hesh","Convoy Incoming.");
	delaythread(3,::add_dialogue_line,"Merrick","Alright, Adam lets finish up.");

	
	wait 3.4;	
	

	
	self notify("use_remote_turret");
	
	flag_set("bishop_glimpse_over");
	

}


monitor_player_bishop()
{
	end_time = GetTime() +25000;
//	end_time = GetTime() +5000;
	while(1)
	{
		//IPrintLn(level.remote_turret_current_fov);
		if((flag( "bishop_glimpse") && level.remote_turret_current_fov <=6 ) || GetTime() >= end_time)
			break;
		wait 0.05;		
	}
	
}


bishop_glimpse()
{
	root = getstruct(	"vip_sniper_breach_struct", "targetname" );
	hech = spawn_targetname( "bishop_tease_hech",1);
	hech.animname = "bishop";
	guys = array_spawn_targetname_allow_fail( "bishop_tease");
	guys[ 0 ] .animname = "bish_e1";
	guys[ 1 ] .animname = "bish_e2";
	guys[ 2 ] .animname = "bish_e3";
	guys[ guys.size ] = hech;
	
	root anim_first_frame(guys,"bishop_glimpse" );
	
	array_thread( guys,::gun_remove);
	
	
	flag_wait("watching_bishop_glimpse");
	
	root anim_single( guys, "bishop_glimpse" );
	array_call( guys, ::Delete );
	
}
intro_dof( quickie )
{
	level notify("stop_introdof");
	level endon("stop_introdof");

	if(IsDefined(quickie) )
	{
		towait =quickie;
		maps\_art::dof_enable_script( 50, 55, 10, 60, 65, 10, towait );
		wait towait;
		
		towait = quickie *2;
		maps\_art::dof_disable_script( towait );
		wait towait;
		return;
	}

	
//	towait =1.5;
//	blend_dof( dof_mid_blur, dof_all_blur, towait);
//	wait towait;
	
	towait = 4;
	maps\_art::dof_enable_script( 50, 55, 8, 60, 65, 8, towait );
	wait towait;
	
	towait =1;
	maps\_art::dof_disable_script( towait );
	wait towait;
	
//	towait = 1;
//	blend_dof( level.originalDoFDefault,dof_mid_blur, towait);
//	wait towait;
//	
//	towait = 0.5;
//	blend_dof( dof_mid_blur,level.originalDoFDefault, towait);
//	wait towait;
	
	flag_set("finished_intro_dof");

}

pickup_mk32( anim_struct_targetname )
{
	struct = getstruct( "sniper_placement", "targetname" );
	level.allies[0].goalradius = 128;
	struct  thread anim_single( [ level.allies[0]], "intro_player" );
	wait 3;
	player_struct = getstruct( "sniper_placement_forward", "targetname" );
	
	flag_wait("picked_up_mk32");
	
	safe_disable_trigger_with_targetname("picked_up_mk32");
	level.player GiveWeapon( "mk32_dud" );
	level.player switchToWeapon( "mk32_dud" );	

	SetUpPlayerForAnimations("crouch");
	
	prop = spawn_anim_model("mk32");
	prop SetModel("viewmodel_mk14");

	player_rig = spawn_anim_model( "player_rig" );
	player_rig  hide();
	
	player_struct anim_first_frame( [ player_rig, prop], "intro_player" );

	
	
	lerp_time = 0.4;
	level.player PlayerLinkToBlend( player_rig, "tag_player", lerp_time, 0.2, 0.2 );
	wait lerp_time;
	
	player_rig Show();
	
	player_struct anim_single( [ player_rig, prop], "intro_player" );
	SetUpPlayerForGamePlay();
	
	//clean up

	level.player Unlink();
	player_rig Delete();
	prop Delete();
	

}

convoy()
{
	flag_wait("start_convoy");
	level.allies[0] thread ally_shoot_convoy();
	level endon("stop_convoy");
	thread watch_convoy_trig();
	level.player_hit_convoy = 0;
	
	num_spawned = 0;
	spawners = GetEntArray( "intro_convoy", "targetname");
	last_spawn = undefined;
	thread player_get_mk32();
	spawn_num =1;
	while(level.player_hit_convoy < 3)
	{
		if(spawn_num %3)
			spawner = spawners[0];
		else
			spawner = spawners[1];
			
		spawn_num++;
		//spawner = spawners[RandomInt(spawners.size)];
		last_spawn = spawner spawn_vehicle_and_gopath();
		last_spawn.cargo = [];
		if(string_starts_with(last_spawn.classname,"script_vehicle_man_7t"))
			last_spawn load_up();
		//last_spawn delayThread(2, ::debug_phys_fount);
		num_spawned++;
		wait(RandomFloatRange(2.5,4));
	}
	level.last_spawned_veh = last_spawn;
	
	
	level waittill("stop_convoy");
	
}
load_up()
{
	loadme=[];
	loadme[loadme.size]="com_ammo_pallet";
	loadme[loadme.size]="berlin_barrelcluster_pallet_01";
	loadme[loadme.size]="militarybase_generator";
	
	loadme[loadme.size]="ls_aid_crate_02";
	loadme[loadme.size]="shipping_frame_boxes";
	loadme[loadme.size]="empty";
	slots = 3;
	// Figure out our orientation once.
	offset_vec= AnglesToForward(self GetTagAngles("tag_body"));
	for(i=0;i<slots;i++)
	{
		newcargo = RandomInt(loadme.size);
		if(loadme[newcargo] == "empty")
			continue;
		load_point = self GetTagOrigin("tag_body") + offset_vec * -80 * i;
		self.cargo[self.cargo.size] = spawn( "script_model", load_point);
		self.cargo[self.cargo.size-1].angles = self GetTagAngles("tag_body");
		self.cargo[self.cargo.size-1] SetModel( loadme[newcargo]);
		self.cargo[self.cargo.size-1] linkto( self );
		self.cargo[self.cargo.size-1].linked_vehicle = self;
	}
		/*
	 * 
	 * 
	precacheModel( "miltarybase_generator");
	precacheModel( "la_aid_crate_02");
	precacheModel( "shipping_frame_boxes");
	
	 tag_body
tag_guy01 -08 
	  
	  
	 * */
}
debug_phys_fount()
{
	
	ent_offset= (275,0,30);
	if(self.classname == "script_vehicle_iveco_lynx")
		ent_offset= (150,0,50);
	
//	rel_launch_ang= VectorNormalize((2, RandomFloatRange(-0.5,0.5), 2));
	rel_launch_ang= VectorNormalize((2, 0, 2));
	thread physics_fountain("ehq_seat_dyn", self, ent_offset,rel_launch_ang,0.9,4,200,8000);

}
watch_convoy_trig()
{
	   
	trig = GetEnt( "convoy_touchup", "targetname" );
	while( IsDefined(trig))
	{
		trig waittill( "trigger",veh );
		{
			if(IsDefined(level.last_spawned_veh) && veh == level.last_spawned_veh)
			{
				trig Delete();
			}
			foreach(thing in veh.cargo)
			{
				thing Delete();
			}
			veh Delete();
		}
	}

}

//ally_shoot_convoy()
//{
//	level endon("stop_convoy");
//	self forceUseWeapon( "mk32_dud", "primary" );
//	
//	
//	while(1)
//	{
//		trig = GetEnt("stick_me", "targetname");
//		trig waittill( "trigger",ent);
//		if( ent isVehicle())
//		{
//			self SetEntityTarget(ent);
//			//IPrintLnBold("ally fires at vehicle");
//			wait 0.5;
//			MagicBullet( "mk32_dud",self GetTagOrigin( "tag_eye" ),ent.origin);
//			wait 0.7;
//
//		}
//		else		
//			wait 1.2;
//		
//	}
//	
//}


ally_shoot_convoy()
{
    self.old_weapon = self.weapon;
	self forceUseWeapon( "mk32_dud", "primary" );
	anim.grenadeTimers[ "AI_teargas_grenade" ] = randomIntRange( 0, 20000 );	

	trig = GetEnt("stick_me", "targetname");
	while(1)
	{
		trig waittill( "trigger",ent);
		if( ent isVehicle())
		{
			self SetEntityTarget(ent);
			wait 0.5;
			endpos = bulletSpread( self getMuzzlePos(), ent.origin, 4 );
		
			self.a.lastShootTime = gettime();
		
			
			bFireSoundOnce = true;
			self.grenadeammo=1;
			self.grenadeWeapon = "teargas_grenade";	

			gren =self MagicGrenade( self getMuzzlePos(),ent.origin+(0,0,100),5,true);
			self.grenadeammo=0;
			
			if(IsDefined(gren))
				gren delayCall(1.5,::Delete);
			else //IPrintLnBold("no grenade spawned");
			wait 0.7;
//			self notify( "shooting" );
//			self shoot( 1, endPos, bFireSoundOnce );
			self ClearEntityTarget( ent );
			if(IsDefined(level.last_spawned_veh) && ent == level.last_spawned_veh)
			{
				level notify("stop_convoy");
				break;
			}
		}
		else		
			wait 1.2;
		
	}
	wait 3;
    self forceUseWeapon( self.old_weapon , "primary" );
	
	
}


player_get_mk32()
{
	thread add_dialogue_line( "Merrick", "Convoy incoming.");
	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_convoyincoming" );
	
	wait 3;
	thread add_dialogue_line( "Merrick", "Grab that MK32 and stick some grenades on the convoy.");
	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_grabthatmk32and" );
	wait 3;
	thread add_dialogue_line( "Merrick", "The grenades are on a time delay- that's our diversion.");
	wait 3;
	inc = 0;
	waittime = 0.2;
	while(1)
	{
		if( level.player GetCurrentPrimaryWeapon() == "mk32_dud" )
			break;
		wait waittime;
		inc++;
		if(inc * waittime >6 )
		{
			thread add_dialogue_line( "Merrick", "You need to grab that MK32.");
			inc = 0;
		}
			
	}
	flashy = GetEnt( "mk32_glowy", "targetname" );
	flashy Delete();
	
}

keegan_tinkers_with_rifle()
{
	root = getstruct("remote_sniper_workon", "targetname");
	root thread anim_loop_solo(level.allies[1],"training_humvee_repair","stop_loop");
	level.allies[1] gun_remove();
	level waittill( "keegan_stop_tinkering" );
	root notify("stop_loop");
	level.allies[1] anim_stopanimscripted();
	wait 0.1;
	level.allies[1] enable_ai_color();
	safe_activate_trigger_with_targetname("keegan_post_tinker");
	keeg = GetNode("keegan_please_shift_it", "targetname");
	level.allies[1] SetGoalNode(keeg);
	level.allies[1].goalradius = 64;
	wait 0.2;
	level.allies[1] gun_recall();

}



go_street()
{
	level.allies[0] AllowedStances("crouch","stand");
	level notify( "keegan_stop_tinkering" );
	
	flag_set("FLAG_move_to_player_truck");
	thread add_dialogue_line( "Merrick", "Looks like that was the last of them.");
	wait 3;
	thread add_dialogue_line( "Merrick", "Let's move. On me.");
	enable_trigger_with_targetname("TRIG_player_enter_truck");
	wait 2;
	
	flag_set( "intro_done" );
	
	thread maps\enemyhq_audio::aud_truck_ext_idle_loop();
}



/////////////////////////////////////////////////////////////////////////////////
//
// Generic multi use functions
//
/////////////////////////////////////////////////////////////////////////////////

handle_m32_launcher()
{
	level endon("death");
	
	level.mk32_intro_fire = false;
	
	for (;;)
	{
    	//level.player waittill ( "weapon_fired", grenade, weaponName ); 
    	level.player waittill ( "grenade_fire", grenade, weaponName ); 
		//level.player waittill( "projectile_impact", weaponName, org, radius );
		if( level.player GetCurrentWeapon() == "mk32_dud")
		{
			if( level.player GetWeaponAmmoClip("mk32_dud") == 0)
				level.player notify( level.c4_weaponname);
	    	
				//	Sphere(org,64,(0,0,1),0,500);
	    		
			if( level.mk32_intro_fire )
	    		grenade thread track_dud();
			else
	    		grenade thread track_live();
		}
	}
}

//self is player.
handle_sticky_clacker()
{
	self endon("death");
	clacker_state = 0;
	level.num_active_clacks =0;
	
	while(1)
	{
		result = self waittill_any_return( "sticky_gone_boom","new_sticky_attached", "clack_stickies");
		stickies = GetEntArray("live_sticky_grenade","targetname");
		if(result == "sticky_gone_boom")
		{
			if(stickies.size == 0)
			{
				self notify("cancel_clacker_ui");
				
			}
			
			
		}
		else if(result == "clack_stickies")
		{
			/#
			if(stickies.size == 0)
				IPrintLnBold("STICKY ERROR- trying to blow ZERO stickies up");
			#/
			level.my_clack_num = 0;
			foreach(sticky in stickies)
				sticky notify("exploderize_me");
//			self notify("exploderize_me");
			self notify("cancel_clacker_ui");
		
		}
		
		else if(result == "new_sticky_attached" )
		{
			if(stickies.size == 1)
			//if(!clacker_state)
			{
				clacker_state = 1;
				self thread watch_clacker();
			}
			
		}
	}
}


safe_switch_to_detonator()
{
	while(level.switching_from_detonator)
	{
		
		wait 0.05;
	}
	level.switching_to_detonator = 1;
	
	//self thread maps\_c4::switch_to_detonator();
	level.preclack_weapon = self getcurrentweapon();
	self giveWeapon( level.c4_weaponname );
	self SetWeaponAmmoClip( level.c4_weaponname, 0 );
	self switchtoweapon( level.c4_weaponname );
	self DisableWeaponSwitch();
	self DisableWeaponPickup();
	self waittill( "weapon_change", newWeapon );
	level.switching_to_detonator = 0;
}
safe_switch_from_detonator()
{
	while(level.switching_to_detonator)
	{
		
		wait 0.05;
	}
	level.switching_from_detonator = 1;
	
	
	self SwitchToWeapon(level.preclack_weapon);
	self waittill( "weapon_change" );
    self takeweapon( level.c4_weaponname );

	level.switching_from_detonator = 0;
    
	self EnableWeaponSwitch();
	self EnableWeaponPickup();

}
watch_clacker()
{
	self endon("death");
	self notify("stop_watch_clacker");
	self endon("stop_watch_clacker");
	self NotifyOnPlayerCommand( level.c4_weaponname, "+actionslot 2" );
	self setWeaponHudIconOverride( "actionslot2", "inventory_stickybomb" );
	RefreshHudAmmoCounter();


	
	result = self waittill_any_return("cancel_clacker_ui", level.c4_weaponname);
	if( result == "cancel_clacker_ui" )
	{
		self setWeaponHudIconOverride( "actionslot2", "none" );
		self NotifyOnPlayerCommand( "", "+actionslot 2" );
		RefreshHudAmmoCounter();
		
		return;
	}
	self thread safe_switch_to_detonator();
	while(1)
	{
		result = self waittill_any_return("detonate", level.c4_weaponname,"cancel_clacker_ui");
		self thread safe_switch_from_detonator();
		if( result == "detonate")
		{
			self notify("clack_stickies");
			self setWeaponHudIconOverride( "actionslot2", "none" );
			self NotifyOnPlayerCommand( "", "+actionslot 2" );
			RefreshHudAmmoCounter();
		
			return;			
		}
		else if(result ==level.c4_weaponname)
		{
			self setWeaponHudIconOverride( "actionslot2", "none" );
			self NotifyOnPlayerCommand( "", "+actionslot 2" );

			//Send us back to the top of this function, which will kill this version of it off.
			self thread watch_clacker();
			wait 1;
				
		}
		else if(result == "cancel_clacker_ui" )
		{
			self setWeaponHudIconOverride( "actionslot2", "none" );
			self NotifyOnPlayerCommand( "", "+actionslot 2" );
			RefreshHudAmmoCounter();
			return;
			//Send us back to the top of this function, which will kill this version of it off.

		}
		else
		{
			IPrintLnBold("WATCH CLACKER messedup- got unknown message");
			return;
		}
			    
	
	}
}

//	Line(start,end,(0,0,1),1,0,200);
//	Sphere(end,64,(0,0,1),0,200);
//		level.player maps\_c4::switch_to_detonator();
//		level.player EnableWeapons();
//		level.player waittill( "detonate" );
//		flag_set("FLAG_blow_sticky_01");
//		wait 1;
//		level.player TakeWeapon("c4");


//grenade is self- each grenade comes in here to stick and die.
track_live()
{
	level.player endon("death");
	start = self.origin;
	self waittill("explode", end);
	
	half = ((start-end) /2);
	start = half+ end;
	end = end - half;
	
	sticky_lifetime = 6;

	trace = BulletTrace(start,end,true,level.player,true,true);
//	trace2 = PhysicsTrace(start,end);
	if(IsDefined(trace) && IsDefined(trace["position"]))
	{
		end = trace["position"]+ (trace["normal"] *1.5);
		
		org = spawn( "script_model",end );
		org setmodel( "weapon_sticky_grenade" );
		org.angles = VectorToAngles(trace["normal"]);
		org.targetname = "live_sticky_grenade";
		tag_origin = spawn_tag_origin();
		
		fx = undefined;
		if( IsDefined(trace["entity"])) 
		{
			ent = trace["entity"] ;
			if(IsAI(ent) ) //	isVehicle())
			{
				has_shield = true;
				if ( !IsDefined( ent.magic_bullet_shield ) || ent.magic_bullet_shield == false )
				{
					ent magic_bullet_shield( true );
					has_shield = false;
				}
				//getting the best tag to bolt the grenade on to.
				ent 
				thread do_dud_damage(start,end);
				ent waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
				attach_tag = "";
				if( IsDefined(partName) && partName!="")
				{
					attach_tag = partName;
				}
				else if( IsDefined(tagName) && tagName!="")
				{
					attach_tag = tagName;
				}
				if(attach_tag != "")
				{
					//IPrintLnBold("AI Ent " + ent.classname + " hit on tag " + attach_tag);
					org linkto(ent,attach_tag);
				}
				else
				{
				//	IPrintLnBold("AI Ent " + ent.classname + " hit- got no tag.");
					org linkto(ent);
				}
				
				if( !has_shield)
					ent delayThread(0.05,::stop_magic_bullet_shield);
			
			}
			else
			{
//				if(IsDefined(modelName))
//					IPrintLnBold("Ent " + ent.classname + " hit model " + modelName);
//				else
//					IPrintLnBold("Ent " + ent.classname + " hit- got no model.");
				//	IPrintLnBold("Ent " + ent.classname + " hit.");
				org linkto(ent);
			}
		}
		
		tag_origin LinkTo( org);
		level.player notify("new_sticky_attached");
		PlayFXOnTag( getfx( "sparks_car_scrape_point" ),tag_origin,"tag_origin");
		
		
		// Wait to explode.
		reason = org waittill_notify_or_timeout_return( "exploderize_me",sticky_lifetime);
		//so they don't all go off in the same frame. May need more of a wait.
		if( IsDefined(reason) && reason == "exploderize_me" )
		{
			mywait = level.my_clack_num*0.05;
			level.my_clack_num++;
			wait mywait;
			
			
		}
		damage_loc = org.origin;
				
		StopFXOnTag( getfx( "sparks_car_scrape_point" ),tag_origin, "tag_origin" );
		tag_origin Unlink();
		tag_origin Delete();
		org Unlink();
		org Delete();
		MagicGrenadeManual( "fraggrenade",damage_loc,(0,0,0),0);
		level.player notify("sticky_gone_boom");
	//	IPrintLnBold("magic grenade go boom!");
		//RadiusDamage( damage_loc, 64, 150, 50, level.player, "MOD_EXPLOSIVE" );

	}
//	Line(start,end,(0,0,1),1,0,200);
//	Sphere(end,64,(0,0,1),0,200);
//		level.player maps\_c4::switch_to_detonator();
//		level.player EnableWeapons();
//		level.player waittill( "detonate" );
//		flag_set("FLAG_blow_sticky_01");
//		wait 1;
//		level.player TakeWeapon("c4");

}

do_dud_damage(start,end)
{
	wait 0.05;
	MagicBullet("nosound_magicbullet",start,end,level.player);
//	MagicBullet( "nosound_magicbullet", ( 738, 0, 8110 ), ( 738, 0, 7900 ) , level.player );

}
track_dud()
{
	level endon("death");
	start = self.origin;
	self waittill("explode", end);
	
	half = ((start-end) /2);
	start = half+ end;
	end = end - half;


	trace = BulletTrace(start,end,true,level.player,true,true);
//	trace2 = PhysicsTrace(start,end);
	if(IsDefined(trace) && IsDefined(trace["position"]))
	{
		end = trace["position"]+ (trace["normal"] *1.5);
		
		org = spawn( "script_model",end );
		org setmodel( "weapon_sticky_grenade" );
		org.angles = VectorToAngles(trace["normal"]);
		tag_origin = spawn_tag_origin();
		
		fx = undefined;
		ent = undefined;
		if( IsDefined(trace["entity"]))
		{
			ent = trace["entity"];
			if(IsDefined(ent.linked_vehicle))
				ent = ent.linked_vehicle;
		}
		if( IsDefined(ent) && ent isVehicle())
		{
			if( !IsDefined( ent.already_stuck))
			{
				ent.already_stuck = 0;
				if(	level.player_hit_convoy <3 && level.player_hit_convoy %2 ==0)
					thread player_hit_vo(ent.vehicletype,level.player_hit_convoy);
				level.player_hit_convoy++;
			}
			org linkto( ent );
		}
		
		tag_origin LinkTo( org);
		PlayFXOnTag( getfx( "sparks_car_scrape_point" ),tag_origin,"tag_origin");
		
		wait 0.6;
		StopFXOnTag( getfx( "sparks_car_scrape_point" ),tag_origin, "tag_origin" );
		wait 7;
		tag_origin Unlink();
		tag_origin Delete();
		org Unlink();
		org Delete();
	}
//	Line(start,end,(0,0,1),1,0,200);
//	Sphere(end,64,(0,0,1),0,200);

}
player_hit_vo(vehicletype,choice)
{
	//vo_lines=[][];
	vo_lines["iveco_lynx"][0]="That's a hit on the Lynx.";
	vo_lines["iveco_lynx"][1]="That's a hit on the Lynx.";
	vo_lines["iveco_lynx"][2]="That's a hit on the Lynx.";
	cues["iveco_lynx"][0]="enemyhq_mrk_thatsahiton";
	cues["iveco_lynx"][1]="enemyhq_mrk_thatsahiton";
	cues["iveco_lynx"][2]="enemyhq_mrk_thatsahiton";

	
	
		
	vo_lines["man_7t_physics"][2]="That's a hit on the truck`.";
	vo_lines["man_7t_physics"][1]="Confirmed timed grenade on that truck.";
	vo_lines["man_7t_physics"][0]="Timed Grenade stuck to that track.";
	cues["man_7t_physics"][0]="enemyhq_mrk_timedgrenadestuckto";
	cues["man_7t_physics"][1]="enemyhq_mrk_timedgrenadestuckto";
	cues["man_7t_physics"][2]="enemyhq_mrk_timedgrenadestuckto";

	
	thread add_dialogue_line("Merrick",vo_lines[vehicletype][choice]);
	level.allies[0] thread char_dialog_add_and_go( cues[vehicletype][choice] );
	
	
}




watch_for_remote_turret_activate(forward_dist)
{
	self notify( "stop_watching_remote_sniper");
	self endon( "stop_watching_remote_sniper");
//	self NotifyOnPlayerCommand( "use_remote_turret", "+actionslot 1" ); // Only ever triggered by code now.
	sniper_placement = getstruct( "sniper_placement", "targetname" );
	
	while ( 1 )
	{
		self waittill( "use_remote_turret" );
		sniper_origin = sniper_placement.origin;
		sniper_angles = sniper_placement.angles;
		
		//self maps\enemyhq_remoteturret::remote_turret_activate( "remote_sniper", sniper_origin + AnglesToForward( sniper_angles ) * 5000, sniper_angles + ( 15, 0, 0 ), 45, 45, 35, 5 );
		self maps\enemyhq_remoteturret::remote_turret_activate( "remote_sniper", sniper_origin + AnglesToForward( sniper_angles ) * forward_dist, sniper_angles , 45, 45, 35, 5 );
		
		ret = self waittill_any_return( "use_remote_turret", "remote_turret_deactivate" );
		
		if ( ret == "use_remote_turret" )
		{
			thread set_black_fade(1,0.1);
			wait 0.2;
			waittillframeend;
			self maps\enemyhq_remoteturret::remote_turret_deactivate();
		}
		delayThread(0.45,::set_black_fade,0,0.15);

		wait 0.1;
//		self SwitchToWeaponImmediate( "remote_chopper_gunner" );
		
		wait 1.1;
		self.ignoreme = false;
		self.allow_dry_fire = false;
		self GiveWeapon( level.player.presniper_weapon );
		self switchToWeapon( level.player.presniper_weapon );	
		wait 2;	
		self TakeWeapon( "remote_chopper_gunner" );
	}
}



////////////////////////////////////////////////////
//
//War Ambience
//
///////////////////////////////////////////////////
handle_loopers()
{
	loopers= create_vehicle_from_spawngroup_and_gopath( 983 );
	array_thread(loopers,::handle_looper);
	
}
handle_looper()
{
	self endon("kill_war_ambiance");
	
	startpos = self.origin;
	startang = self.angles;
	startnode = self.target;
	while(1)
	{
		self waittill( "reached_dynamic_path_end" );
		self Vehicle_Teleport(startpos,startang);
		path = getstruct( startnode, "targetname" );
		self thread vehicle_paths( path );
	}
}

cargo_choppers()
{
	//unhide everything first.
	showme = GetEntArray( "intro_hide_on_load", "script_noteworthy" );
	array_call(showme,::Show);
	//array_call(showme,::NotSolid);

	arr = create_vehicle_from_spawngroup_and_gopath( 982 );
	thread handle_loopers();
	
	cargo_heli_spawners = getentarray( "cargo_heli_group2", "targetname" );
	foreach ( spawner in cargo_heli_spawners )
	{
		Cargo_item_spawners = getentarray( spawner.script_noteworthy, "targetname" );
		foreach ( ent in cargo_item_spawners )
			ent Hide();
		spawner.cargo_item_spawners = cargo_item_spawners;
	}
	
	//flag_wait( "cargo_choppers_2" );
	
	current_spawner = 0;
	num_of_groups = 1;
	while( num_of_groups > 0 )
	{
		//group = randomintrange( 2, 4 );
		group = cargo_heli_spawners.size;
		
		while( group > 0 )
		{
			if( current_spawner >= cargo_heli_spawners.size )
				current_spawner = 0;
			thread spawn_cargo_carrier( cargo_heli_spawners[current_spawner] );
			current_spawner++;
			group--;
		}
		num_of_groups--;
	}
}



spawn_cargo_carrier( cargo_spawner )
{
	cargo_veh =  vehicle_spawn( cargo_spawner );
	wait .1;//vehicle spawns in one place and then moves on the first frame
	cargo_item_spawners = cargo_spawner.cargo_item_spawners;
	new_cargo = [];
	for( i = 0 ; i < cargo_item_spawners.size ; i++ )
	{
		new_cargo[i] = spawn( cargo_item_spawners[i].classname, cargo_item_spawners[i].origin );
		new_cargo[i].angles = cargo_item_spawners[i].angles;
		if( new_cargo[i].classname == "script_model" )
			new_cargo[i] setmodel( cargo_item_spawners[i].model );
		new_cargo[i] linkto( cargo_veh );
	}
	
	wait .1;
	
	thread gopath( cargo_veh );
	
	cargo_veh waittill( "death" );

	foreach ( ent in new_cargo )
		ent Delete();
}

air_armada()
{
	planes = GetEntArray( "air_armada", "targetname" );
	array_thread( planes, ::oneshot_armada,60000,15 );

	planes = GetEntArray( "air_armada_looper", "targetname" );
	array_thread( planes, ::loop_armada,70000,14 );
}

ship_vista()
{
	ships = GetEntArray( "vista_armada","targetname");
	array_thread(ships,::oneshot_armada);
	
	ships = GetEntArray( "vista_armada_looper","targetname");
	array_thread(ships,::loop_armada);
//	IPrintLnBold( ships.size + " ttl ships in armada");
}
oneshot_armada(dist,movetime)
{
	if(!IsDefined(dist))
		dist = 20000;
	if(!IsDefined(movetime))
		movetime = Int(self.script_noteworthy);
	
	fwd = AnglesToForward(self.angles);
	dest = self.origin + (fwd*dist);
	self moveto(dest,movetime,1,1);
	wait movetime;
	self Delete();
}
loop_armada(dist,movetime)
{
	if(!IsDefined(dist))
		dist = 20000*1.5;
	if(!IsDefined(movetime))
		movetime = Int(self.script_noteworthy)*1.5;

	self endon("kill_war_ambiance");
	startpos = self.origin;
	startang = self.angles;
	while(1)
	{
		fwd = AnglesToForward(self.angles);
		dest = self.origin + (fwd*dist);
		self moveto(dest,movetime,1,1);
		wait movetime;
		self.origin = startpos;
		self.angles =startang;
	}
}


animate_vip_enemies_intro()
{
	vol = GetEnt("vip_enemy_volume", "targetname");
	
	spawners = GetEntArray("vip_enemy", "targetname");
		
	guys = [];
	
	foreach (spawner in spawners)
	{
		animname = spawner.script_noteworthy;
		struct = GetStruct(spawner.target, "targetname");
		
		guy = spawner spawn_ai(true);
		
		guy.animname = animname;
		guy.struct = struct;
		guy.allowdeath = true;
		struct thread anim_first_frame_solo(guy, "vip_enemy");
		
		guy thread go_go_vip_enemies(struct);
		
		guys = array_add(guys, guy);
	}
	
	flag_wait("kick_off_atrium_combat");
	array_delete(guys);
}

go_go_vip_enemies(struct)
{
	flag_wait("watching_bishop_glimpse");
	struct anim_single_solo(self, "vip_enemy");
}
	



intro_overlook()
{
	//thread debug_look_flag();
//	thread add_dialogue_line("Merrick","Calibrating remote sniper");
//	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_calibratingremotesniper" );
	
//	
//	delaythread (0.5,::add_dialogue_line,"Merrick","...adjusting focus....and zoom.");
//	level.allies[0] delaythread (0.5,::char_dialog_add_and_go, "enemyhq_mrk_adjustingfocus" );
//	delaythread (2.5,::add_dialogue_line,"Merrick","...adjusting focus....and zoom.");
//	level.allies[0] delaythread (2.5,::char_dialog_add_and_go, "enemyhq_mrk_andzoom" );
//
	setup_sniper_view("sniper_introaim_1",5000);
	lookat = getstruct( "sniper_introaim_1", "targetname" );
	
	
	wait 0.05;
	self notify( "remote_turret_nozoom" );
	self EnableSlowAim( 0.25,0.25);
	closeang = 0.5;
	midang = 1;
	farang = 4;
	self LerpViewAngleClamp(1.0,0.2,0.2,closeang,closeang,closeang,closeang);
	
	
	self.turret_look_at_ent.origin = lookat.origin;
	thread intro_dof( 0.7 );
	
	level.remote_turret_current_fov = 7;//Int(lookat.script_noteworthy);
	self LerpFOV( level.remote_turret_current_fov,0.05 );
	
	
	self thread intro_dof( );
	
		
	thread air_armada();
	
	self LerpViewAngleClamp(1.0,0.2,0.2,farang,farang,farang,farang);
	lookat = getstruct( lookat.target, "targetname" );
			
	self.turret_look_at_ent MoveTo( lookat.origin,5.5,4,1);
	wait 1.5;

	lerp_to = Int(lookat.script_noteworthy);
	//IPrintLnBold("Lerping to " + lerp_to  );
	self LerpFOV( lerp_to,4 );
	level.remote_turret_current_fov=lerp_to;
	
	delayThread(3,::add_dialogue_line,"Merrick","There goes Vargas' invasion fleet.");
	level.allies[0] delayThread(3,::char_dialog_add_and_go, "enemyhq_mrk_theregoesvargasinvasion" );
	
	wait 4;
	thread autosave_by_name("intro_fleet");

	thread add_dialogue_line("Merrick","Bringing remote controls online.");
	self LerpViewAngleClamp(1.0,0.2,0.2,40,70,20,30);
	wait 2;
	thread add_dialogue_line("Merrick","Adam, you need to run the remote sniper through its paces.");
	
	wait 2;
	flag_clear("checkit_zoom");
	flag_clear("checkit_pan");
	self thread maps\enemyhq_remoteturret::remote_turret_handle_zoom();
	self thread monitor_player_used_zoom();
	//Check DryFire.
	if(	flag("checkit_dryfire") )
	{
		flag_clear("checkit_dryfire");
		thread add_dialogue_line("Merrick","Adam, fire the remote sniper again- it should dryfire.");
		self thread maps\enemyhq_remoteturret::remote_turret_monitor_dryfire( "remote_sniper" );
	}
	else
		thread add_dialogue_line("Merrick","Adam, test fire the remote sniper. The chamber is clear so it will dryfire.");
		
	wait 3;
	while(!flag("checkit_dryfire"))
	{
		talker = "Merrick";
		dialog= "Adam, test-fire the remote sniper.";
		wait_flag = "checkit_dryfire";
		first_wait = 6;
		level.player ForceUseHintOn( "Press ^3[{+attack}]^7 to fire the remote sniper" );
		
		nag_player_dialog_debug( talker,dialog,wait_flag,first_wait);
		level.player ForceUseHintOff();
		
	}
	thread add_dialogue_line("Merrick","That's Foxtrot Golf.");
	
	wait 3;

	//Check Zoom
	if(!flag("checkit_zoom"))
	{
		thread add_dialogue_line("Merrick","Adam, test the zoom control.");
		
		wait 4;
		if(!flag("checkit_zoom"))
		{
			level.player ForceUseHintOn( "Use ^3[{+sprint}]^7 to control zoom." );
			wait 3;
			if(!flag("checkit_zoom"))
			{
				talker = "Merrick";
				dialog= "Adam, Try using the Sniper Zoom.";
				wait_flag = "checkit_zoom";
				
				first_wait = 6;
				nag_player_dialog_debug( talker,dialog,wait_flag,first_wait);
			}
			level.player ForceUseHintOff();
		}
		wait 1;
		thread add_dialogue_line("Merrick","Sweet. You could hit a Fed between the eyes at a 1000 yards with that thing.");
	
	}
	else
		thread add_dialogue_line("Merrick","Looks like you've already tested the zoom is online and functional.");
	
	wait 2;


	self LerpViewAngleClamp(1.0,0.2,0.2,40,70,20,30);
	thread add_dialogue_line("Merrick","You have full control. Eyes on for Old Boy- look for Fed activity.");
	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_handingcontroltoyou" );
	
	monitor_player_bishop();
	self notify( "remote_turret_nozoom" );
	
	
	
	
	if(!Flag( "bishop_glimpse"))
	{
		thread add_dialogue_line("Merrick","I see activity in VIP suites. I'm Overriding control.");
		level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_iseeactivityin" );
	}
	else
	{
		thread add_dialogue_line("Merrick","Wait, you have something. I'm Overriding control.");
	level.allies[0] thread char_dialog_add_and_go( "enemyhq_mrk_waitwhatwasthat" );
	}
	thread intro_dof( 0.7 );
	
	wait 0.4;
	last_dist = Length(lookat.origin - self.origin);
	lookat = getstruct( "sniper_introaim_4", "targetname");
//	lookat = getstruct( lookat.target, "targetname" );
	newpos = self.origin + (AnglesToForward(self.angles) *last_dist);
//	Sphere(newpos,50,(1,1,1),0,200);
//	wait 4;
	self.turret_look_at_ent.origin = newpos;
//	IPrintLnBold("snapping now");
	self.player_view_controller SnapToTargetEntity( self.turret_look_at_ent );
	self LerpViewAngleClamp(0,0,0,closeang,closeang,closeang,closeang);
	
//	wait 4;
//	IPrintLnBold("NORMAL_MOVE");
	
	dist = Length(lookat.origin - self.turret_look_at_ent.origin) / 1000;
	dist = min(dist, 4);
	dist = max(dist, 1);
	wait 0.05;
	self.turret_look_at_ent MoveTo( lookat.origin,dist,dist/4,dist/4);
	lerp_to = Int(lookat.script_noteworthy);
	//IPrintLnBold("Lerping to " + lerp_to  );
	self LerpFOV( lerp_to,dist );
	flag_set("watching_bishop_glimpse");
	wait dist;
	delaythread(0.1,::add_dialogue_line,"Merrick","We have a possible ID on Old Boy. VIP Suites, top floor.");
	//thread add_dialogue_line("Merrick","Tagging this view for later.");
	delaythread(3.5,::add_dialogue_line,"Hesh","Roger that.");

	lookat = getstruct( lookat.target, "targetname" );
	wait 4;
//	lerp_to = Int(lookat.script_noteworthy);
	self LerpFOV( 1.5,4 );
	wait 6.7;
	//wait 1;
	self.turret_look_at_ent MoveTo( lookat.origin,4,1,1);
	delaythread(0.5,::add_dialogue_line,"Hesh","Convoy spotted. It'll be here in 15 seconds.");
	delaythread(4.2,::add_dialogue_line,"Merrick","Alright, Adam lets finish up.");

	
	wait 4.4;	
	

	
	self notify("use_remote_turret");
	
	flag_set("bishop_glimpse_over");
	

}
