#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\cornered_code_slide;
#include maps\cornered_lighting;
#include maps\_hud_util;
#include maps\player_scripted_anim_util;

cornered_destruct_pre_load()
{
	PreCacheRumble( "artillery_rumble" );
	PreCacheRumble( "collapsing_building" );
	PreCacheRumble( "light_1s" );
	PreCacheRumble( "light_2s" );
	PreCacheRumble( "light_3s" );
	PreCacheRumble( "heavy_1s" );
	PreCacheRumble( "heavy_2s" );
	PreCacheRumble( "heavy_3s" );
	
	//PreCacheShader( "gfx_laser_bright" );
	
	PreCacheModel( "com_computer_keyboard" );
	PreCacheModel( "com_computer_mouse" );
	PreCacheModel( "hjk_tablet_01" );
	PreCacheModel( "bowl_wood_modern_01" );
	PreCacheModel( "viewhands_player_sas" );
	PreCacheModel( "viewlegs_generic" );
	PreCacheModel( "cnd_briefcase_01_animated" );
	//PreCacheModel( "cnd_briefcase_01_animated_obj" );
	PreCacheModel( "cnd_briefcase_01_glow" );
	PreCacheModel( "generic_prop_x30_raven" );
	
	PreCacheModel( "cnd_parachute" );
	PreCacheModel( "ctl_parachute_ripcord_prop" );
	PreCacheModel( "ctl_parachute_player" );
	PreCacheModel( "cnd_player_rubble" );
	
	//"You killed the HVT."
	PreCacheString( &"CORNERED_HVT_KILLED_FAIL" );
	
	PreCacheShellShock( "cornered_stairwell" );
	PreCacheShellShock( "cornered_horizontal_start" );
	
	//--use this to init flags or precache items for an area.--
	flag_init( "baker_breach_ready" );
	flag_init( "hvt_office_rorke_entry" );
	flag_init( "hvt_rorke_ready_door" );
	flag_init( "hvt_rorke_ready" );
	flag_init( "hvt_baker_ready" );
	flag_init( "hvt_office_explosion" );
	flag_init( "hvt_player_done" );
	//flag_init( "open_hvt_exit_door" );
	
	flag_init( "rorke_ready_shake3" );
	flag_init( "open_stairwell_doors" );
	flag_init( "stairwell_shake_1" );
	flag_init( "stairwell_shake_2" );
	flag_init( "stairwell_shake_3" );
	
	flag_init( "office_ally_anims_starting" );
	flag_init( "office_explosion" );
	
	flag_init( "player_can_use_briefcase" );
	flag_init( "player_used_briefcase" );
	
	flag_init( "baker_ready_for_office_shake" );
	flag_init( "rorke_ready_for_office_shake" );
	
	flag_init( "lobby_stairwell_shake" );
	flag_init( "lobby_rorke_ready" );
	flag_init( "fall_stagger_anim_done" );
	flag_init( "fall_down_shake" );
	
	flag_init( "player_is_slipping" );
	flag_init( "fall_rubble_shift" );
	flag_init( "fall_enemy_a" );
	flag_init( "fall_enemy_b" );
	flag_init( "fall_enemy_c" );
	flag_init( "fall_enemy_d" );
	flag_init( "fall_enemy_e" );
	flag_init( "fall_enemy_f" );
	flag_init( "go_building_fall" );
	flag_init( "atrium_pre_rail_hit" );
	flag_init( "fall_rail_hit" );
	flag_init( "atrium_pillar_break" );
	flag_init( "atrium_floor_break" );
	flag_init( "building_player_anim_begin" );
	flag_init( "pre_glass_impact" );
	
	flag_init( "parachute_exfil" );
	flag_init( "go_exfil_bldg" );
	flag_init( "show_ally_chute" );
	flag_init( "show_player_chute" );
	
	flag_init( "rescue_finished" );
	flag_init( "stairwell_finished" );
	flag_init( "atrium_finished" );	
	
	flag_init( "teleport" );
}

setup_capture()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.rescue_checkpoint = true;
	setup_player();
	spawn_allies();
	thread handle_intro_fx();
	thread maps\cornered_audio::aud_check( "rescue" );
		
	//level.player SwitchToWeapon( "mp5_silencer_eotech" );
	level.player SwitchToWeapon( "kriss+eotechsmg_sp+silencer_sp" );
	
	delete_building_glow();
}

setup_stairwell()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.stairwell_checkpoint = true;
	
	level.rescue_anim_struct = getstruct( "rescue_animnode", "targetname" );
	level.fall_anim_struct = getStruct( "fall_animnode", "targetname" );
	level.hvt_office_anim_struct = getstruct( "hvt_office_animnode", "targetname" );
	thread maps\cornered::obj_escape(); //objective 5 start
	
	door1 = getEnt( "hvt_exit_door_rt", "targetname" );
	door2 = getEnt( "hvt_exit_door_lf", "targetname" );
	//exit_door1 = getEnt( "stairwell_exit_door_left", "targetname" );
	//exit_door2 = getEnt( "stairwell_exit_door_right", "targetname" );
	exit_clip = getEnt( "stairwell_exit_door_clip", "targetname" );
	
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "stairwell_door", "cnd_stair_escape_prop_doors", "stairwell_exit_door_left", "stairwell_exit_door_right", true, "open_stairwell_doors" );	

	door1 RotateYaw( 100, .05 );
	door2 RotateYaw( -100, .05 );
	//exit_door1 RotateYaw( 100, .05 );
	//exit_door2 RotateYaw( -105, .05 );
	exit_clip NotSolid();
	exit_clip ConnectPaths();
	door1 ConnectPaths();
	door2 ConnectPaths();
	
	setup_player();
	spawn_allies();
	thread stairwell_pipes();
	thread handle_intro_fx();
	thread stairwell_cracks();
	thread maps\cornered_audio::aud_check( "stairwell" );
	thread maps\cornered_audio::aud_collapse( "pipes" );
	
	thread vista_tilt();
		
	//level.player SwitchToWeapon( "mp5_silencer_eotech" );
	level.player SwitchToWeapon( "kriss+eotechsmg_sp+silencer_sp" );
	
	delete_building_glow();
	
	wait( .05 );
	exit_clip Delete();
}

setup_atrium()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.atrium_checkpoint = true;
	setup_player();
	spawn_allies();
	
	//thread vista_tilt_setup();
	thread vista_tilt();
	thread fall_props();
	thread fall_physics_debris_lobby();
	//SetPhysicsGravityDir( ( 0, -0.02, -0.03 ) );
	
	thread handle_intro_fx();
	thread maps\cornered_audio::aud_check( "atrium" );
	maps\_utility::vision_set_fog_changes( "cornered_08", 0 );

	//level.player SwitchToWeapon( "mp5_silencer_eotech" );
	level.player SwitchToWeapon( "kriss+eotechsmg_sp+silencer_sp" );
	
	delete_building_glow();
}

begin_capture()
{
	//--use this to run your functions for an area or event.--
	level thread hvt_office_handler();

	flag_wait( "rescue_finished" );
}

begin_stairwell()
{
	level thread stairwell_handler();
	level thread office_handler();
	
	flag_wait( "stairwell_finished" );
}

begin_atrium()
{
	//--use this to run your functions for an area or event.--
	level thread fall_handler();
	
	flag_wait( "atrium_finished" );
}

vista_tilt_setup()
{
	// --All vista items that need to rotate are attached to one pivot--
	level.vista		  = GetEntArray( "vista_buildings", "targetname" );
	level.vista_pivot = GetEnt	   ( "air_vista_pivot", "targetname" );
	
	thread fall_fx_crowd_setup();
	
	foreach ( item in level.vista )
	{
		item NotSolid();
		item LinkTo( level.vista_pivot );
	}
}

vista_tilt()
{
	// --Player's camera ref ent.--
	level.player_ref_ent = GetEnt( "player_ref_ent_1", "targetname" );
	Assert( IsDefined( level.player_ref_ent ) );
	level.player PlayerSetGroundReferenceEnt( level.player_ref_ent );
		
	// --PART 1 - HVT OFFICE EXPLOSION --	
	// --Small unanimated tilt when building first explodes in HVT office--
	if( !IsDefined( level.stairwell_checkpoint ) && !IsDefined( level.atrium_checkpoint ) )
	{
		flag_wait( "hvt_office_explosion" );
		level.player_ref_ent RotateTo( ( -4, 0, -7 ), 5, 1.5 );
		level.vista_pivot RotateTo( ( -4, 0, -7 ), 5, 1.5 );
		
		xdir = 0; //will end up 0.02
		ydir = 0; //will end up -0.01
		for ( i = 0; i < 20; i++ )
		{
			SetPhysicsGravityDir( ( xdir, ydir, -0.03 ) );
			wait( .25 );
			xdir += 0.001;
			ydir +=	-0.0005;
		}
	}
	else
	{
		level.player_ref_ent RotateTo( ( -4, 0, -7 ), 0.05 );
		level.vista_pivot RotateTo( ( -4, 0, -7 ), 0.05 );
		
		//SetPhysicsGravityDir( ( .02, -0.01, -0.03 ) );
		waitframe();
	}
	
	// --PART 2 - OLD OFFICE EXPLOSION --
	// --Office explosion moves the building back to 0 roll in prep for later anim.
	if( !isDefined( level.atrium_checkpoint ) )
	{
		flag_wait( "office_explosion" );
		Earthquake( 0.5, 4, level.player.origin, 2500 );
		level.player_ref_ent RotateTo( ( 0, 0, -8 ), 5, 1.5 );
		level.vista_pivot RotateTo( ( 0, 0, -8 ), 5, 1.5 );
		
		wait( 4.0 );
		level thread random_building_shake_loop( 0.1, 3.0, 7.0, 1.0 );
	}
	else
	{
		level.player_ref_ent RotateTo( ( 0, 0, -8 ), .05 );
		level.vista_pivot RotateTo( ( 0, 0, -8 ), .05 );
		waitframe();
	}
	
	// --PART 3 - STAIRWELL TO SLIDE --
	flag_wait( "lobby_stairwell_shake" );
	level.player_ref_ent RotateTo( ( 0, 0, -18 ), 9, 1, 2 );
	level.vista_pivot RotateTo( ( 0, 0, -18 ), 9, 1, 2 );
	
	wait( 9.0 );
	
	// --PART 4 - FALL DOWN AND SLIDE TO DOOR--
	flag_wait_all( "lobby_shake", "lobby_rorke_ready" );
	level.player_ref_ent RotateTo( ( 0, 0, -20 ), 4, 3 );
	level.vista_pivot RotateTo( ( 0, 0, -20 ), 4, 3 );
	LerpSunAngles( ( -12, -10, 0 ), ( -16, -3, 0 ), 4, 3 );
	wait( 4.0 );

	// --PART 5 - SLIDE--
	// --Set up animated vista tilt--
	level.vista_tilt_animnode	  = getstruct( "bldg_tilt_struct", "targetname" );
	level.vista_tilt_model		  = spawn_anim_model( "bldg_tilt_cam", level.vista_pivot.origin );
	level.vista_tilt_model.angles = ( 0, 0, 0 );
	
	// --Link GroundRefEnt and vista to animated object--
	level.vista_tilt_animnode anim_first_frame_solo( level.vista_tilt_model, "cornered_building_fall_building" );
	level.player_ref_ent LinkTo( level.vista_tilt_model, "J_prop_1" );
	level.vista_pivot LinkTo( level.vista_tilt_model, "J_prop_1" );
	waitframe();
	flag_wait( "go_building_fall" );
	
	level.vista_tilt_animnode thread anim_single_solo( level.vista_tilt_model, "cornered_building_fall_building" );
	LerpSunAngles( ( -16, 3, 0 ), ( -25, 21.9, 0 ), 10, 0, 3 );

	level.vista_tilt_model waittillmatch( "single anim", "rubble_start" );

	flag_wait( "parachute_exfil" );
	
	level.player PlayerSetGroundReferenceEnt( undefined );
	level.vista_pivot Unlink();

	level.vista_pivot RotateTo( ( 0, 0, 0 ), .05 );
	SetPhysicsGravityDir( ( 0 , 0, -1 ) );
	ResetSunDirection();
	
	end_bldg = getEntArray( "end_broken_bldg", "targetname" );
	array_thread( end_bldg, ::show_entity );
	
	bldg_tiran_dmg = GetEntArray( "vista_building_tiran_dmg", "targetname" );
	array_thread( bldg_tiran_dmg, ::show_entity );
	
	wait( .1 );
	
	foreach ( item in level.vista )
	{
		item Unlink();
	}
	
	//flag_set( "vista_unlinked" );
			
	// --Cleanup--
	//level.vista_tilt_model waittillmatch( "single anim", "end" );
	//level.vista_tilt_model Delete();
	//thread maps\cornered_fx::delete_stage_one_fx();
}

///////////////////////
//
// HVT OFFICE
//
///////////////////////

hvt_office_handler()
{
	level.rescue_anim_struct = getstruct( "rescue_animnode", "targetname" );
	level.fall_anim_struct = getStruct( "fall_animnode", "targetname" );
	level.hvt_office_anim_struct = getstruct( "hvt_office_animnode", "targetname" );
	
	if( isDefined( level.rescue_checkpoint ) )
	{
		flag_set( "garden_finished" );
		thread maps\cornered_garden::close_hvt_office_doors( .05 );
	}
	
	battlechatter_off( "axis" );
	battlechatter_off( "allies" );

	wait( .25 );
	level.allies[ level.const_baker ] thread hvt_office_baker();
	level.allies[ level.const_rorke ] thread hvt_pre_office_rorke();
	
	// --Baker is in place to start scene.--
	flag_wait( "baker_breach_ready" );
	thread hvt_office_props();
	thread hvt_office_briefcase();
	thread hvt_office_doors();
	thread hvt_office_player();
	
	// --Player is in place to start scene.--
	flag_wait( "hvt_office_breach" );
	flag_set( "obj_capture_complete" ); //objective 2 complete	
	thread hvt_office_hvt();
	thread hvt_office_rorke();
	thread vista_tilt();

	// --Called from notetrack in Baker's exit animation.--
	flag_wait( "hvt_office_explosion" );
	thread maps\cornered_audio::aud_collapse( "building" ); //copied from other office
	thread hvt_office_environment();
	thread hvt_office_light();
	thread stairwell_pipes();

	wait( 2.25 );
	thread maps\cornered::obj_escape(); //objective 5 start
}

hvt_office_player()
{
	arms = spawn_anim_model( "player_office" );
	arms Hide();
	
	level.hvt_office_anim_struct anim_first_frame_solo( arms, "cornered_office_player" );
	
	flag_wait( "player_used_briefcase" );

	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player DisableWeapons();
	level.player PlayerLinkToBlend( arms, "tag_player", 0.6 );
	
	level.hvt_office_anim_struct thread anim_single_solo( arms, "cornered_office_player" );
	wait( 0.55 );
	arms Show();
	level.player PlayerLinkToDelta( arms, "tag_player", 0, 10, 10, 10, 10 );
	
	arms waittillmatch( "single anim", "end" );
	
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player EnableWeapons();
	level.player Unlink();
	
	flag_set( "hvt_player_done" );

	waitframe();
	arms Delete();
}

hvt_pre_office_rorke()
{	
	if( !isDefined( level.rescue_checkpoint ) )
	{	
		rorke_struct = getstruct( "rorke_pre_hvt", "targetname" );
		
		if ( !IsDefined( rorke_struct ) )
			return;
			
		wait 2;
		
		rorke_struct anim_reach_solo( self, "breach_stackL_approach" );
		
		if ( flag( "hvt_office_breach" ) )
			return;
		
		rorke_struct anim_single_solo( self, "breach_stackL_approach" );
		
		if ( !flag( "hvt_office_breach" ) )
			rorke_struct thread anim_loop_solo( self, "explosivebreach_v1_stackL_idle", "stop_loop" );
		
		flag_wait( "hvt_office_breach" );
		rorke_struct notify( "stop_loop" );
	}
}

hvt_office_baker()
{
	self enable_cqbwalk();
	self.grenadeammo = 0;
	self disable_ai_color();
	self.ignoresuppression = true;
	self.baseaccuracy	   = 1;
	self disable_bulletwhizbyreaction();

	if( !isDefined( level.rescue_checkpoint ) )
	{	
		baker_struct = getstruct( "baker_hvt_door", "targetname" );
		baker_struct anim_reach_solo( self, "breach_stackL_approach" );
		baker_struct anim_single_solo( self, "breach_stackL_approach" );
		flag_set( "baker_breach_ready" );

		if( !flag( "hvt_office_breach" ))
		{
			baker_struct thread anim_loop_solo( self, "explosivebreach_v1_stackL_idle", "stop_loop" );
		}
		
		flag_wait( "hvt_office_breach" );
		baker_struct notify( "stop_loop" );	
		waittillframeend;
	}
	else
	{
		flag_set( "baker_breach_ready" );
		flag_wait( "hvt_office_breach" );
	}	
		
	level.hvt_office_anim_struct thread anim_single_solo( self, "cornered_office_baker_enter" );
	thread maps\cornered_audio::aud_hvt( "door" );
	
	self waittillmatch( "single anim", "start_rorke_ramos_anims" );
	flag_set( "hvt_office_rorke_entry" );
	
	self waittillmatch( "single anim", "end" );
	flag_set( "player_can_use_briefcase" );
	level.hvt_office_anim_struct thread anim_loop_solo( self, "cornered_office_baker_loop", "stop_loop" );

	flag_wait( "player_used_briefcase" );
	level.hvt_office_anim_struct notify( "stop_loop" );
	
	waittillframeend;
	//delayThread( 36.85, ::flag_set, "hvt_office_explosion" );
	level.hvt_office_anim_struct thread anim_single_solo( self, "cornered_office_baker_exit" );
	
	self waittillmatch( "single anim", "explosion" );
	thread stairwell_cracks();
	flag_set( "hvt_office_explosion" );
	//delayThread( 2.25, ::flag_set, "open_hvt_exit_door" );
	
	self waittillmatch( "single anim", "end" );
}

hvt_office_hvt_setup()
{
	self.ignoreme = true;
	self.ignoreall = true;
	self.diequietly = true;
	self.animname = "hvt";
	self.a.nodeath = true;
	self.skipDeathAnim = true;
	self thread hvt_office_hvt_death();
	self gun_remove();
	self.health = 1000000;
}

hvt_office_hvt_death()
{
	self endon( "hvt_dead" );
	
	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
			
		if( IsDefined( attacker ) && IsPlayer( attacker ) )
		{
			self Kill();
			//self StartRagdoll();
			
			//"You killed the HVT."
			SetDvar( "ui_deadquote", &"CORNERED_HVT_KILLED_FAIL" );
			missionFailedWrapper();
			
			self notify( "hvt_dead" );
		}
	}

}

hvt_office_hvt()
{
	spawner = getEnt( "office_hvt", "targetname" );
	spawner add_spawn_function( ::hvt_office_hvt_setup );
	hvt = spawn_targetname( "office_hvt", true );
	//level.hvt = hvt;
	
	hvt endon( "death" );
	
	waitframe();
	level.hvt_office_anim_struct anim_first_frame_solo( hvt, "cornered_office_enter" );
	
	flag_wait( "hvt_office_rorke_entry" );
	
	thread maps\cornered_audio::aud_hvt( "part1", hvt );
	
	level.hvt_office_anim_struct anim_single_solo( hvt, "cornered_office_enter" );
	
	if( !flag( "player_used_briefcase" ))
	{
		level.hvt_office_anim_struct thread anim_loop_solo( hvt, "cornered_office_loop", "stop_loop" );
	}
		
	flag_wait( "player_used_briefcase" );
	
	thread maps\cornered_audio::aud_hvt( "part2", hvt );
	
	level.hvt_office_anim_struct notify( "stop_loop" );
	
	waittillframeend;
	level.hvt_office_anim_struct thread anim_single_solo( hvt, "cornered_office_exit" );

	wait( 48 );
	hvt notify( "hvt_dead" );
	hvt waittillmatch( "single anim", "end" );
	
	level.hvt_office_anim_struct thread anim_loop_solo( hvt, "cornered_office_ramos_death_loop", "stop_loop" );
	
	hvt InvisibleNotSolid();
	hvt.noragdoll = true;
	hvt.a.nodeath = true;
	hvt.allowdeath = false;
}

hvt_office_rorke()
{
	guy = level.allies[ level.const_rorke ];
	
	guy enable_cqbwalk();
	guy.grenadeammo = 0;
	guy disable_ai_color();
	guy.ignoresuppression = true;
	guy.baseaccuracy = 1;	
	guy disable_bulletwhizbyreaction();
	
	level.hvt_office_anim_struct anim_first_frame_solo( guy, "cornered_office_enter" );
	
	flag_wait( "hvt_office_rorke_entry" );
		
	level.hvt_office_anim_struct anim_single_solo( guy, "cornered_office_enter" );
	
	if( !flag( "player_used_briefcase" ))
	{
		level.hvt_office_anim_struct thread anim_loop_solo( guy, "cornered_office_loop", "stop_loop" );
	}
	
	flag_wait( "player_used_briefcase" );
	thread maps\cornered_garden::close_hvt_office_doors( .05 );
	
	stop_exploder( 1200 );//Stop ambient FX in garden
	stop_exploder( 20 ); // Stop blue flood Fx on buildings
	
	level.hvt_office_anim_struct notify( "stop_loop" );
	
	waittillframeend;
	level.hvt_office_anim_struct thread anim_single_solo( guy, "cornered_office_exit" );
	
	//wait( 39 );
	//wait( 53.65 );
	wait( 47.0 );
	//guy forceUseWeapon( "kriss", "primary" );
	guy forceUseWeapon( "kriss+eotechsmg_sp+silencer_sp", "primary" );
	guy.lastWeapon = guy.weapon; // needed to avoid animscript SRE later
	
	guy waittillmatch( "single anim", "end" );
	
	flag_set( "rescue_finished" );
	//level thread stairwell_handler();
	thread autosave_by_name( "post_explosion_intel" );
}

hvt_office_props()
{
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_prop_monitors", "hvt_office_monitor1", "hvt_office_monitor2", true, "hvt_office_rorke_entry" );
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_prop_mouse_keyboard", "hvt_office_keyboard", "hvt_office_mouse", true, "hvt_office_rorke_entry" );
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_debris_chair", "hvt_office_debris_chair", "hvt_office_debris_chair2", true, "hvt_office_explosion" );	
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_debris_plant", "hvt_debris_plant1", "hvt_debris_plant2", true, "hvt_office_explosion" );	
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_debris_couch", "hvt_office_debris_couch1", "hvt_office_debris_couch2", true, "hvt_office_explosion" );	
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_debris_statue", "hvt_office_debris_statue", undefined, true, "hvt_office_explosion" );	
	
	chair1 = getEnt( "hvt_office_debris_chair", "targetname" );
	chair1_clip = getEnt( "hvt_office_debris_chair_clip", "targetname" );
	chair1_clip LinkTo( chair1 );
	
	chair2 = getEnt( "hvt_office_debris_chair2", "targetname" );
	chair2_clip2 = getEnt( "hvt_office_debris_chair_clip2", "targetname" );
	chair2_clip2 LinkTo( chair2 );
	
	couch1 = getEnt( "hvt_office_debris_couch1", "targetname" );
	couch1_clip = getEnt( "hvt_office_debris_couch1_clip", "targetname" );
	couch1_clip LinkTo( couch1 );
	couch1_cushions = GetEntArray( "hvt_office_debris_couch1_cushions", "targetname" );
	foreach( obj in couch1_cushions )
	{
		obj LinkTo( couch1 );
	}
	
	couch2 = getEnt( "hvt_office_debris_couch2", "targetname" );
	couch2_clip = getEnt( "hvt_office_debris_couch2_clip", "targetname" );
	couch2_clip LinkTo( couch2 );
	couch2_cushions = GetEntArray( "hvt_office_debris_couch2_cushions", "targetname" );
	foreach( obj in couch2_cushions )
	{
		obj LinkTo( couch2 );
	}
	
	thread hvt_office_chair();
	
	light_rig1 = spawn_anim_model( "rescue_lights", level.hvt_office_anim_struct.origin );
	light_rig2 = spawn_anim_model( "rescue_lights", level.hvt_office_anim_struct.origin );
	light_rig3 = spawn_anim_model( "rescue_lights", level.hvt_office_anim_struct.origin );
	light_rig4 = spawn_anim_model( "rescue_lights", level.hvt_office_anim_struct.origin );
	light_rig5 = spawn_anim_model( "rescue_lights", level.hvt_office_anim_struct.origin );
	
	light_rig1 thread office_light( "light1", "office", level.hvt_office_anim_struct, "hvt_office_explosion" );
	light_rig2 thread office_light( "light2", "office", level.hvt_office_anim_struct, "hvt_office_explosion" );
	light_rig3 thread office_light( "light3", "office", level.hvt_office_anim_struct, "hvt_office_explosion" );
	light_rig4 thread office_light( "light4", "office", level.hvt_office_anim_struct, "hvt_office_explosion" );
	light_rig5 thread office_light( "light5", "office", level.hvt_office_anim_struct, "hvt_office_explosion" );
	
	briefcase = spawn_anim_model( "office_briefcase", level.hvt_office_anim_struct.origin ); 
	level.hvt_office_anim_struct anim_first_frame_solo( briefcase, "cornered_office_prop_briefcase_enter" );
	
	flag_wait( "hvt_office_rorke_entry" );
	level.hvt_office_anim_struct anim_single_solo( briefcase, "cornered_office_prop_briefcase_enter" );
	
	flag_wait( "player_can_use_briefcase" );
	//briefcase glow();
	//briefcase SetModel( "cnd_briefcase_01_glow" );
	briefcase_glow = Spawn( "script_model", briefcase.origin );
	briefcase_glow.angles = briefcase.angles;
	briefcase_glow SetModel( "cnd_briefcase_01_glow" );
	briefcase Hide();
	
	flag_wait( "player_used_briefcase" );
	
	//briefcase stopGlow();
	//briefcase SetModel( "cnd_briefcase_01_animated" );
	briefcase Show();
	briefcase_glow Delete();
	
	level.hvt_office_anim_struct thread anim_single_solo( briefcase, "cornered_office_prop_briefcase_exit" );
	
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	
	wait( 1.0 );
	CinematicInGame( "cornered_briefcase_intro" );
	wait( 4.0 );

	CinematicInGameLoopResident( "cornered_briefcase_loop" );
	
	briefcase waittillmatch( "single anim", "end" );
	
	//wait( 14.65 );
	flag_wait( "hvt_player_done" );
	
	//briefcase Delete();
}

hvt_office_chair()
{	
	chair = getEnt( "hvt_office_chair", "targetname" );	
	rig = spawn_anim_model( "office_props" );
	
	level.hvt_office_anim_struct anim_first_frame_solo( rig, "cornered_office_prop_chair_enter" );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	waitframe();
	
	chair.origin = j1_origin;
	chair.angles = j1_angles;
	
	waitframe();
	chair LinkTo( rig, "J_prop_1" );
	
	flag_wait( "hvt_office_rorke_entry" );
	
	level.hvt_office_anim_struct anim_single_solo( rig, "cornered_office_prop_chair_enter" );
	
	if( !flag( "player_used_briefcase" ))
	{
		level.hvt_office_anim_struct thread anim_loop_solo( rig, "cornered_office_prop_chair_loop", "stop_loop" );
	}
		
	flag_wait( "player_used_briefcase" );
	
	level.hvt_office_anim_struct anim_single_solo( rig, "cornered_office_prop_chair_exit" );

	chair Unlink();
	
	waitframe();
	rig Delete();
}

hvt_office_doors()
{
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_prop_door_a", "hvt_office_entry_door_left", undefined, true, "hvt_office_breach" );	
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "office_props", "cornered_office_prop_door_b", "hvt_exit_door_lf", "hvt_exit_door_rt", true, "hvt_office_rorke_entry" );	
	
	thread generic_prop_raven_anim( level.hvt_office_anim_struct, "stairwell_door", "cnd_stair_escape_prop_doors", "stairwell_exit_door_left", "stairwell_exit_door_right", true, "open_stairwell_doors" );	
	
	// --making sure exit doors get path connection.
	door1 = getEnt( "hvt_exit_door_rt", "targetname" );
	door2 = getEnt( "hvt_exit_door_lf", "targetname" );
	
	flag_wait( "hvt_office_rorke_entry" );
	wait( 1 );
	door1 ConnectPaths();
	door2 ConnectPaths();

	flag_wait( "open_stairwell_doors" );
	//exit_door1 = getEnt( "stairwell_exit_door_left", "targetname" );
	//exit_door2 = getEnt( "stairwell_exit_door_right", "targetname" );
	exit_clip = getEnt( "stairwell_exit_door_clip", "targetname" );
		
	//wait( .55 );
	//exit_door1 RotateYaw( 100, .6, .05, .3 );
	//exit_door2 RotateYaw( -105, .6, .05, .3 );
	thread maps\cornered_audio::aud_hvt( "exit" );
	
	wait( .3 );
	exit_clip NotSolid();
	exit_clip ConnectPaths();
	
	wait( .3 );
	exit_clip Delete();
}

hvt_office_environment()
{
	exploder( 7751 );
	SetSavedDvar( "phys_gravityChangeWakeupRadius", 4000 );

	level.player PlayRumbleOnEntity( "heavy_3s" );
	Earthquake( 0.5, 4, level.player.origin, 2500 );
	level thread lobby_and_stair_fx();

	jolters = getstructarray( "hvt_office_phys", "targetname" );
	foreach ( obj in jolters )
	{
		PhysicsJitter( obj.origin, 300, 200, 1.0, 1.0 );
	}
	
	//wait( 2.0 );
	junk = GetEntArray( "hvt_office_junk", "targetname" );
	foreach( obj in junk )
	{
		obj PhysicsLaunchClient( obj.origin + ( 0, 0, -4 ), ( 0, -15, 60 ));
	}
	
	wait( 2.0 );
	Earthquake( 0.14, 8, level.player.origin, 2500 );
	
	wait( 8.0 );
	level thread random_building_shake_loop( 0.1, 3.0, 7.0, 1.0 );
}

hvt_office_briefcase()
{
	use_trig = GetEnt( "briefcase_trigger", "targetname" );
	//"Press and hold [{+activate}] to pick up briefcase "
	use_trig SetHintString( &"CORNERED_PICK_UP_BRIEFCASE_HINT" );
	
	lookat = getstruct( "briefcase_look", "targetname" );
	
	use_trig trigger_off();
	
	flag_wait( "player_can_use_briefcase" );
	use_trig trigger_on();
	waittill_trigger_activate_looking_at( use_trig, lookat, Cos( 40 ), false, true );
	
	
	//use_trig waittill( "trigger" );
	flag_set( "player_used_briefcase" );
	//use_trig Delete();
}

///////////////////////
//
// STAIRWELL
//
///////////////////////

stairwell_handler()
{
	//delayThread( 2.0, ::flag_set, "stairwell_shake_1" );
	level.allies[ level.const_rorke ] thread stairwell_rorke();
	level.allies[ level.const_baker ] thread stairwell_baker();
	thread stairwell_office_vo();
	//thread stairwell_pipes();
	thread office_enemy_setup();
	
	level.default_sprint = GetDvar( "player_sprintSpeedScale" );
	setSavedDvar( "player_sprintSpeedScale", 1.20 );
	
	// ---Shake 1 - Moderate shake, allies stumble---
	flag_wait( "stairwell_shake_1" );
	level notify( "done_random_shaking" );
	level.player ShellShock( "cornered_stairwell", 1.5 );
	level.player PushPlayerVector( ( 0, -25, 0 ) );
	level.player SetMoveSpeedScale( 0.4 );
	level.player ViewKick( 64, level.player.origin );
	exploder( 7651 );
	maps\cornered_audio::aud_hvt_destruct01();
	
	thread stairwell_light( 16 );
	level.player PlayRumbleOnEntity( "heavy_2s" );
	Earthquake( 0.25, 2, level.player.origin, 2500 );
	level thread lobby_and_stair_fx();
	
	wait( .25 );
	level.player PushPlayerVector( ( 0, 0, 0 ) );
	
	wait( 1.75 );
	level.player blend_movespeedscale( 1.0, 2.5 );
	
	//level thread lobby_random_shaking( 0.1, 3.0, 7.0, 1.0 );
	thread stairwell_light( 2 );
	
	// ---Shake 2 - Small shake---
	flag_wait( "stairwell_shake_2" ); // --Set in map
	//wait( 2.0 );
	level notify( "done_random_shaking" );
	maps\cornered_audio::aud_hvt_destruct02();
	
	maps\cornered_audio::aud_collapse( "lobby" );
	level.player ShellShock( "cornered_stairwell", 1.0 );
	level.player PushPlayerVector( ( 0, -25, 0 ) );
	
	thread stairwell_light( 18 );
	level.player PlayRumbleOnEntity( "light_3s" );
	Earthquake( 0.15, 2, level.player.origin, 2500 );
	level thread lobby_and_stair_fx();
		
	wait( .25 );
	level.player PushPlayerVector( ( 0, 0, 0 ) );
	
	wait( 1.75 );
	
	level thread random_building_shake_loop( 0.1, 3.0, 7.0, 1.0 );
	thread stairwell_light( 2 );
	
	// ---Shake 3 - Moderate shake, allies stumble---
	flag_wait( "stairwell_shake_3" );
	level notify( "done_random_shaking" );
	
	thread stairwell_light( 12 );
	level.player PlayRumbleOnEntity( "heavy_3s" );
	Earthquake( 0.25, 3, level.player.origin, 2500 );
	level thread lobby_and_stair_fx();
	wait( 3.0 );
	
	level thread random_building_shake_loop( 0.1, 3.0, 7.0, 1.0 );
	thread stairwell_light( 2 );
}

stairwell_cracks()
{
	thread stairwell_crack_flat( "a" );
	thread stairwell_crack_flat( "c", 0.3 );
}

stairwell_crack_flat( crack_ver, time )
{
	ent1 = GetEnt( "stairwell_crack_decal_1" + crack_ver, "targetname" );
	ent2 = GetEnt( "stairwell_crack_decal_2" + crack_ver, "targetname" );
	ent3 = GetEnt( "stairwell_crack_decal_3" + crack_ver, "targetname" );
	ent4 = GetEnt( "stairwell_crack_decal_4" + crack_ver, "targetname" );
	
	ent1 Hide();
	ent2 Hide();
	ent3 Hide();
	ent4 Hide();
	
	flag_wait( "stairwell_shake_1" );
	
	if( IsDefined( time ))
	{
		wait( time );
	}
	
	ent1 Show();
	
	wait( .15 );
	ent2 Show();
	
	wait( .15 );
	ent3 Show();
	
	wait( .15 );
	ent4 Show();
	
	flag_wait( "found_hvt" );
	
	ent1 Delete();
	ent2 Delete();
	ent3 Delete();
	ent4 Delete();

}
	
stairwell_pipes()
{
	pipe_left = getEnt( "stair_pipe_left", "targetname" );
	pipe_right1 = getEnt( "stair_pipe_right1", "targetname" );
	pipe_right2 = getEnt( "stair_pipe_right2", "targetname" );
	pipe_right3 = getEnt( "stair_pipe_right3", "targetname" );
	
	pipe_right2 LinkTo( pipe_right1 );
	pipe_right3 LinkTo( pipe_right1 );
	
	waitframe();
	
	rig = spawn_anim_model( "stairwell_pipe" );
	
	level.hvt_office_anim_struct anim_first_frame_solo( rig, "cnd_stair_escape_prop_pipe" );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	j2_origin = rig GetTagOrigin( "J_prop_2" );
	j2_angles = rig GetTagAngles( "J_prop_2" );
	
	pipe_right1.origin = j1_origin;
	pipe_right1.angles = j1_angles;

	pipe_left.origin = j2_origin;
	pipe_left.angles = j2_angles;
	
	pipe_left LinkTo( rig, "J_prop_2" );
	pipe_right1 LinkTo( rig, "J_prop_1" );
	
	// ---Shake 1 - Moderate shake, allies stumble---
	flag_wait( "stairwell_shake_1" );
	level.hvt_office_anim_struct thread anim_single_solo( rig, "cnd_stair_escape_prop_pipe" );
	exploder( 8471 ); // Pipe shake 1
	
	// ---Shake 2 - Small shake---
	flag_wait( "stairwell_pipe_2" );
	wait( RandomFloatRange( 0.5, 1.6 ) );
	exploder( 8472 ); // Pipe shake 1
	
	vol1 = getEnt( "stairway_hall_vol_1", "targetname" );
	vol2 = getEnt( "stairway_hall_vol_2", "targetname" );
	
	flag_wait( "allies_move_to_rescue" );
	
	destructibles = GetEntArray( "destructible_toy", "targetname" );
	foreach( item in destructibles )
	{
		if( item IsTouching( vol1 ))
		{
		   	item notify( "damage", 250, level.player, self.origin, item.origin, "MOD_EXPLOSIVE" );
		}
	}
	
	flag_wait( "trigger_stair_hall_vol_2" );
	
	destructibles = GetEntArray( "destructible_toy", "targetname" );
	foreach( item in destructibles )
	{
		if( item IsTouching( vol2 ))
		{
		   	item notify( "damage", 250, level.player, self.origin, item.origin, "MOD_EXPLOSIVE" );
		}
	}
}

stairwell_rorke()
{
	level endon( "stop_stairwell_rorke" );
	
	level.hvt_office_anim_struct thread anim_single_solo( self, "cornered_stairs" );
	
	self waittillmatch( "single anim", "doors" );
	flag_set( "open_stairwell_doors" );
	
	self waittillmatch( "single anim", "explosion" );
	flag_set( "stairwell_shake_1" );
	
	self waittillmatch( "single anim", "end" );
	
	flag_wait( "allies_move_to_rescue" );
	
	self disable_cqbwalk();
	self disable_surprise();
	self.baseaccuracy = 500000;
	
	flag_set( "stairwell_shake_3" );
	self.goalradius = 16;
	
	self set_moveplaybackrate( 1.1 );	
	rorke_node2 = getNode( "hall_post_stumble_rorke", "targetname" );
	level.allies[ level.const_rorke ] SetGoalNode( rorke_node2 );
	
	level.allies[ level.const_rorke ] waittill( "goal" );
	self set_moveplaybackrate( 1.0 );
	flag_set( "rorke_ready_for_office_shake" );
}

stairwell_baker()
{
	level endon( "stop_stairwell_baker" );
	
	self disable_cqbwalk();
	self disable_surprise();
	self.disablearrivals = true;
	self.baseaccuracy = 500000;
	self.goalradius = 16;
	
	level.hvt_office_anim_struct thread anim_single_solo( self, "cornered_stairs" );
	
	wait( 9.7 );
	
	//Hesh: Jump!
	self thread smart_dialogue( "cornered_hsh_jump" );
	
	self waittillmatch( "single anim", "end" );
	
	vol = getEnt( "stair_baker_dont_stop", "targetname" );
	
	if( level.player isTouching( vol ))
	{
		level.hvt_office_anim_struct anim_single_solo( self, "cornered_stairs_run" );
	}
	else
	{
		level.hvt_office_anim_struct anim_single_solo( self, "cornered_stairs_wait" );
		if( !flag( "allies_move_to_rescue" ))
		{
			level.hvt_office_anim_struct thread anim_loop_solo( self, "cornered_stairs_wait_loop", "stop_loop" );
		}
		flag_wait( "allies_move_to_rescue" );
		level.hvt_office_anim_struct notify( "stop_loop" );
		self StopAnimScripted();
	}
	
	baker_node2 = getNode( "hall_post_stumble_baker", "targetname" );
	level.allies[ level.const_baker ] SetGoalNode( baker_node2 );
	
	level.allies[ level.const_baker ] waittill( "goal" );
	flag_set( "baker_ready_for_office_shake" );

}

stairwell_office_vo()
{
	wait( .75 );
	
	//Merrick: Oracle, mission is compromised! Attempting an aerial exfil from the 52nd floor
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_oraclemissionis" );
	
	//Oracle: Copy Black Knight. Prepping emergency team for your new rally point.
	smart_radio_dialogue( "cornered_orc_copyblackknightprepping" );
	
	flag_wait( "trigger_stair_hall_vol_2" );
	
	//Merrick: We need to find a window before the whole damn place comes down!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_weneedtofind" );
}

///////////////////////
//
// OFFICE COMBAT
//
///////////////////////

office_enemy_setup()
{
	flag_wait( "found_hvt" );
	
	array_spawn_function_targetname( "fall_office_runners", ::office_enemy );
	level.office_enemies = array_spawn_targetname( "fall_office_runners", true );
}

office_enemy()
{
	self endon( "death" );
	
	self disable_surprise();
	self.ignoreall = true;
	self.health = 10;
	self.movespeedscale = 0.80;
	
	node = getstruct( self.target, "targetname" );
	self thread office_enemy_die();
	self follow_path( node );
	
	self waittill( "reached_path_end" );
	
	self.goalradius = 16;
	self.ignoreall = false;
	self.movespeedscale = 1.0;
	
	a_enemies = [ level.allies[ level.const_baker ], level.allies[ level.const_rorke ], level.player ];

	// Randomly pick one
	self.favoriteenemy =  a_enemies[ RandomInt( a_enemies.size ) ];
}

office_enemy_die()
{
	self endon( "death" );
	
	flag_wait( "rorke_ready_for_office_shake" );
	
	if( isAlive( self ))
	{
		bullet_1 = getstruct( "office_bullet_1", "targetname" );
		bullet_2 = getstruct( "office_bullet_2", "targetname" );
		
		if( !level.player IsLookingAt( bullet_1 ))
		{
			MagicBullet( "kriss", bullet_1.origin, self GetTagOrigin( "tag_eye" ) );
			IPrintLnBold( "Can't see bullet_1, firing." );
		}
		else
		{
			MagicBullet( "kriss", bullet_2.origin, self GetTagOrigin( "tag_eye" ) );		
			IPrintLnBold( "Can't see bullet_2, firing." );
		}
	
	}
}

office_handler()
{
	thread office_props();
	thread fall_props();
	thread fall_physics_debris_lobby();
	
	flag_wait( "found_hvt" );
	level.allies[ level.const_baker ] thread office_teleport_allies();
	level.allies[ level.const_rorke ] thread office_teleport_allies();
	
	//flag_wait( "office_enemies_dead" );
	thread autosave_by_name( "post_explosion_office" );
	
	battlechatter_off( "axis" );
	battlechatter_off( "allies" );
	
	flag_wait_all( "rorke_ready_for_office_shake", "baker_ready_for_office_shake" );
	array_thread( level.allies, ::set_baseaccuracy , 1 );
	
	//wait( 0.75 );
	
	thread office_ally_anims();
	thread office_vo();
	flag_set( "office_ally_anims_starting" );
	
	flag_wait( "office_explosion" );
	exploder( 7651 );
	thread maps\cornered_audio::aud_collapse( "building" );
	exploder( 88 );
}

office_teleport_allies()
{
	volume = getEnt( "stairwell_teleport_check", "targetname" );
	
	node = getNode( "stairwell_teleport_" + self.animname, "targetname" );
	point = getEnt( "player_look_at_office", "targetname" );
	
	dirToAlly = VectorNormalize( level.player.origin - self.origin );
	forward	  = AnglesToForward( self.angles );

	if ( self IsTouching( volume ) && VectorDot( dirToAlly, forward ) <= -0.25 )
	{
		if( self == level.allies[ level.const_baker ] )
		{
			node2 = getnode( "hall_post_stumble_baker", "targetname" );
			level notify( "stop_stairwell_baker" );
			self StopAnimScripted();
			
			self ClearEnemy();
			self teleport_ai( node );
			self.goalradius = 16;
			
			self SetGoalNode( node2 );
			self waittill( "goal" );
			flag_set( "baker_ready_for_office_shake" );
		}
		if( self == level.allies[ level.const_rorke ] )
		{
			node2 = getnode( "hall_post_stumble_rorke", "targetname" );
			level notify( "stop_stairwell_rorke" );
			self StopAnimScripted();
			
			self ClearEnemy();
			self teleport_ai( node );
			self.goalradius = 16;
			
			self SetGoalNode( node2 );
			self waittill( "goal" );
			flag_set( "rorke_ready_for_office_shake" );
		}
	}
}

#using_animtree( "generic_human" );
office_ally_anims()
{
	level.rescue_anim_struct anim_reach_solo( level.allies[ level.const_baker ], "cornered_office_shift" );
	
	guys	  = [];
	guys[ 0 ] = level.allies[ level.const_baker ];
	guys[ 1 ] = level.allies[ level.const_rorke ];
	
	level.rescue_anim_struct thread anim_single( guys, "cornered_office_shift" );
	
	wait( 2.7 );
	flag_set( "office_explosion" );
	
	guys[ 1 ] waittillmatch( "single anim", "end" );
	flag_set( "stairwell_finished" );
}

office_vo()
{
	wait( 3.75 );
	
	//Hesh: Windows ahead!
	level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_windowsahead" );
	
	//Merrick: Copy, we can jump from here!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_copywecanjump" );
}

office_props()
{
	thread generic_prop_raven_anim( level.rescue_anim_struct, "office_shift_chair", "cornered_office_shift_chair", "office_shift_chair", undefined, true, "office_ally_anims_starting" );
	
	light_rig1 = spawn_anim_model( "rescue_lights", level.rescue_anim_struct.origin );
	light_rig2 = spawn_anim_model( "rescue_lights", level.rescue_anim_struct.origin );
	light_rig3 = spawn_anim_model( "rescue_lights", level.rescue_anim_struct.origin );
	light_rig4 = spawn_anim_model( "rescue_lights", level.rescue_anim_struct.origin );
	light_rig5 = spawn_anim_model( "rescue_lights", level.rescue_anim_struct.origin );
	light_rig6 = spawn_anim_model( "rescue_lights", level.rescue_anim_struct.origin );
	light_rig7 = spawn_anim_model( "rescue_lights", level.rescue_anim_struct.origin );
	
	light_rig1 thread office_light( "light1", "rescue", level.rescue_anim_struct, "office_explosion" );
	light_rig2 thread office_light( "light2", "rescue", level.rescue_anim_struct, "office_explosion" );
	light_rig3 thread office_light( "light3", "rescue", level.rescue_anim_struct, "office_explosion" );
	light_rig4 thread office_light( "light4", "rescue", level.rescue_anim_struct, "office_explosion" );
	light_rig5 thread office_light( "light5", "rescue", level.rescue_anim_struct, "office_explosion" );
	light_rig6 thread office_light( "light6", "rescue", level.rescue_anim_struct, "office_explosion" );
	light_rig7 thread office_light( "light7", "rescue", level.rescue_anim_struct, "office_explosion" );

	waitframe();
	
	flag_wait( "office_explosion" );
	SetPhysicsGravityDir( ( 0, -0.02, -0.03 ));

	junk		 = GetEntArray( "office_debris", "targetname" );
	phys_structs = getstructarray( "office_phys", "targetname" );
	
	foreach( obj in junk )
	{
		obj PhysicsLaunchClient( obj.origin + ( 0, 0, -6 ), ( 0, -.05, .02 ) );
		obj thread debris_remove_after_time( 25.0 );
	}
	foreach( obj in phys_structs )
	{
		obj thread office_jitter();
	}	
}

office_jitter()
{
	for ( i = 0; i < 20; i++ )
	{
		PhysicsJitter( self.origin, 400, 300, 2.0, 3.0 );
		wait( 0.2 );
	}
}

office_light( light_name, area_name, animnode, flag_to_start )
{
	bar = getEnt( light_name + "_bar_" + area_name, "targetname" );
	shade = getEnt( light_name + "_shade_" + area_name, "targetname" );
	bulb = getEnt( light_name + "_bulb_" + area_name, "targetname" );
	
	animnode anim_first_frame_solo( self, "cornered_rescue_" + light_name );
	
	bar LinkTo( self, "J_prop_1" );
	shade LinkTo( self, "J_prop_2" );
	bulb LinkTo( shade );
	
	flag_wait( flag_to_start );
	animnode anim_single_solo( self, "cornered_rescue_" + light_name );
	animnode thread anim_loop_solo( self, "cornered_rescue_" + light_name + "_loop", "stop_light_loop" );
	
	flag_wait_all( "lobby_shake", "lobby_rorke_ready" );
	animnode notify( "stop_light_loop" );
	waitframe();
	self delete();
	bar delete();
	shade delete();
	bulb delete();
}

office_door_to_lobby()
{
	door = getEnt( "door_to_lobby", "targetname" );
	clip = getEnt( "lobby_door_player_clip", "targetname" );
	handles = GetEntArray ( "door_to_lobby_handles", "targetname" );
	foreach( handle in handles )
	{
		handle linkTo( door );
	}
	
	wait( .65 );
	
	door RotateYaw( -95, .6, .05, .05 );
	wait( 1 );
	clip Delete();
	door ConnectPaths();
}

///////////////////////
//
// FALL SEQUENCE
//
///////////////////////

fall_handler()
{
	level.fall_anim_struct = getStruct( "fall_animnode", "targetname" );

	// --ON STAIRS--
	level.allies[ level.const_rorke ] thread fall_allies_rorke();
	level.allies[ level.const_baker ] thread fall_allies_baker();
	
	thread fall_physics_debris_entry_stairs(); //throw stuff off shelves by door
	thread fall_prop_picture();
	thread office_door_to_lobby();
	thread fall_environment();
	thread fall_vo();
	level thread maps\cornered_lighting::handle_fog_changes();
	
	// --HUGE LOBBY EXPLOSION--
	flag_wait_all( "lobby_shake", "lobby_rorke_ready" );

	thread fall_player();
	thread fall_enemies_start();		
}
	
fall_environment()
{
	// --ON STAIRS--
	flag_wait( "lobby_stairwell_shake" ); //set via notetrack
	level notify( "done_random_shaking" );

	thread maps\cornered_audio::aud_collapse( "stumble" );
		
	exploder( 3023 ); // Fire,trash,spark fx on cieling
	stop_exploder( 22 ); // turn off building lights
	stop_exploder( 8471 ); // stop all water/fire fx in stairwell
	
	//Earthquake( 0.30, 2.0, level.player.origin, 500 );
	ScreenShake( level.player.origin, .5, .5, .25, 2.0, 0, 0.5, 500, 8, 8, 2 );
	level.player PlayRumbleOnEntity( "light_2s" );
	level.player blend_movespeedscale( .5, .5 );
	level.player ShellShock( "cornered_horizontal_start", 2 );
	level thread lobby_and_stair_fx();
	
	wait( 2.0 );
	level thread random_building_shake_loop( 0.1, 2.0, 7.0, 1.0 );
	
	// --HUGE LOBBY EXPLOSION--
	flag_wait_all( "lobby_shake", "lobby_rorke_ready" );
	
	exploder( 3122 ); // Dust and stuff in atrium
	exploder( 3004 ); // Explosion outside
	thread maps\cornered_audio::aud_collapse( "crack" );
	
	level notify( "done_random_shaking" );
	waitframe();

	level.player ShellShock( "cornered_horizontal_start", 1.5 );
	level thread lobby_and_stair_fx();
	
	flag_wait( "fall_stagger_anim_done" );	
	//Earthquake( 0.40, 1.0, level.player.origin, 500 );
	ScreenShake( level.player.origin, .75, .5, .25, 3.0, 0, 0.5, 500, 8, 5, 2 );
	
	//wait( 1.0 );
	//Earthquake( 0.20, 2.0, level.player.origin, 500 );
	//level thread lobby_and_stair_fx();
	
	wait( 3.5 );
	exploder( 8799 ); // Large chunks spawn in middle of atrium
	
	// --PLAYER FALLS DOWN--
	flag_wait( "fall_down_shake" );
	//Earthquake( 0.30, 4.75, level.player.origin, 500 );
	ScreenShake( level.player.origin, .5, .5, .25, 4.75, 0, 1.5, 500, 8, 8, 2 );
	level thread lobby_and_stair_fx();
	
	wait( 5.75 );
	level thread random_building_shake_loop( 0.2, 0.5, 1.5, 0.0 );
	
	// --RUBBLE SLIPS TO DOORWAY--
	flag_wait( "fall_rubble_shift" );
	level notify( "done_random_shaking" );
	waitframe();
	//Earthquake( 0.25, 1, level.player.origin, 800 );
	ScreenShake( level.player.origin, .5, .5, .25, 1.0, 0, .25, 500, 8, 8, 2 );
	
	// --RUBBLE RELEASES FROM DOORWAY BUT HANGS MOMENTARILY THEN SLIDE STARTS--
	flag_wait( "go_building_fall" );
	thread fall_fx_tile();
	exploder( 3001 ); // Exterior falling debris
	exploder( 3747 ); // Explosion upper right.
	wait( 0.2 );
	//Earthquake( 0.25, 10.0, level.player.origin, 1200 );
	ScreenShake( level.player.origin, .35, .35, .15, 15.0, 0, 5.0, 500, 10, 10, 4 );
	SetPhysicsGravityDir( ( 0, -0.075, -0.04 ) );
	
	// --PILLAR FALLS--
	flag_wait( "atrium_pillar_break" );
	exploder( 3005 ); // Pillar FX
	thread maps\cornered_audio::aud_collapse( "pillar" ); //calls audio func for pillar explode

	wait( 2.65 );
	ScreenShake( level.player.origin, .75, .75, .25, 1.0, 0, .25, 500, 12, 12, 6 );
	
	wait( 1.65 );
	ScreenShake( level.player.origin, .75, .75, .25, 1.0, 0, .25, 500, 12, 12, 6 );
	
	flag_wait( "parachute_exfil" );
	ScreenShake( level.player.origin, 1.5, 1.5, .25, 3.0, 0, 2.0, 500, 12, 12, 6 );
}

fall_fx_crowd_setup()
{
	//turning on crowd for tilt
	//exploder( 3456 ); //FX crowd
	vfxarry = get_exploder_array( 3456 );
	
	foreach( fx in vfxarry )
	{
		ent		   = spawn_tag_origin();
		ent.fxid   = fx.v[ "fxid" ];
		ent.origin = fx.v[ "origin" ];
		ent.angles = fx.v[ "angles" ];
		
		ent LinkTo( level.vista_pivot );
		
		thread fall_fx_crowd_fx( ent );

	}	
}

fall_fx_crowd_fx( ent )
{
	flag_wait( "fall_down_shake" );
		
	PlayFXOnTag( level._effect[ ent.fxid ], ent, "tag_origin" );
}

fall_fx_tile()
{
	tile1 = getstruct( "test_tile1", "targetname" );
	tile2 = getstruct( "test_tile2", "targetname" );
	tile3 = getstruct( "test_tile3", "targetname" );
	tile4 = getstruct( "test_tile4", "targetname" );
	
	//flag_wait( "go_building_fall" );
	
	wait( 6.85 );
	
	PlayFX( level._effect[ "vfx_atrium_tile" ], tile1.origin + ( 0, 0, 2 ), ( 0, 1, 0 ) );
	wait( 0.55 );
	PlayFX( level._effect[ "vfx_atrium_tile" ], tile2.origin + ( 0, 0, 2 ), ( 0, 1, 0 ) );
	wait( 0.55 );
	PlayFX( level._effect[ "vfx_atrium_tile" ], tile3.origin + ( 0, 0, 2 ), ( 0, 1, 0 ) );
	wait( 0.55 );
	PlayFX( level._effect[ "vfx_atrium_tile" ], tile4.origin + ( 0, 0, 2 ), ( 0, 1, 0 ) );
}

fall_player()
{
	level.player endon( "death" );
	
	level.fall_arms_and_legs = [];
	player_rig	  = spawn_anim_model( "player_bldg_fall" );
	player_legs	  = spawn_anim_model( "player_bldg_fall_legs" );
	player_rig Hide();
	player_legs Hide();
	level.fall_arms_and_legs[ 0 ] = player_rig;
	level.fall_arms_and_legs[ 1 ] = player_legs;
	
	level.player EnableInvulnerability();
	
	// --BIG EXPLOSION - PLAYER STAGGERS--
	level.player PlayerLinkToBlend( player_rig, "tag_player", .6 );
	level.player PlayRumbleOnEntity( "heavy_1s" );
	level.fall_anim_struct anim_single_solo( level.fall_arms_and_legs[0], "lobby_tumble_player" );
	flag_set( "fall_stagger_anim_done" );
	
	level.player Unlink();
	level.player SetMoveSpeedScale( .4 );
	level.player PlayRumbleOnEntity( "light_3s" );
		
	wait( 3.0 );
	
	// --PLAYER FALLS DOWN--
	flag_set( "fall_down_shake" );
	level.player PlayerLinkToBlend( player_rig, "tag_player", .5, .25 );
	level.fall_anim_struct thread anim_single( level.fall_arms_and_legs, "lobby_react_player" );
	//start frame 345
	//FRAME 359 "enemy_b"
	//FRAME 370 "rumble_release"
	//FRAME 383 "enemy_c"
	//FRAME 418 "enemy_e"
	//FRAME 441 "enemy_d"
	//FRAME 502 "kick_view"
	level.player PlayRumbleOnEntity( "heavy_2s" );
	player_rig Show();
	player_legs Show();
	level.player SetViewKickScale( 2.0 );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowJump( false );
	level.player SetMoveSpeedScale( 1 );
	
	wait( .65 );
	level.player ViewKick( 127, level.player.origin );
	
	waitframe();
	level.player SetViewKickScale( 1 );
	
	wait( .85 );
	// --MOMENTARY LOOK AT CEILING--
	//level notify( "remove_runners" );
	//runners = get_living_ai_array( "lobby_running_enemies", "script_noteworthy" );
	//array_delete( runners );
	
	wait( .95 );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 0.5, 70, 70, 65, 40 );
	
	level.fall_arms_and_legs[0] waittillmatch( "single anim", "kick_view" );
	level.player SetViewKickScale( 2.5 );
	level.player PlayRumbleOnEntity( "heavy_1s" );
	
	waitframe();
	level.player ViewKick( 127, level.player.origin );
		
	waitframe();
	level.player SetViewKickScale( 1 );
	
	// --PLAYER HITTING RUBBLE--
	player_rig waittillmatch( "single anim", "end" ); 

	flag_set( "player_is_slipping" );
	ClearAllCorpses();
	//thread fall_physics_debris_slide();
	
	// --ATTACH RIG TO INVISIBLE ANIM TO GIVE PLAYER L/R CONTROL --
	level thread building_fall_anim_rig();
	
	//start frame 530
	//FRAME 550 "original_start"
	//FRAME 570 "enemy_f"
	//FRAME 598 "view_kick"
	//FRAME 694 "pillar_break"
	//FRAME 772 "start_floor"
	//FRAME 840 "camera_to_front"
	//FRAME 912 "slomo_on"
	//FRAME 925 "slomo_on"
	//FRAME 960 "slomo_off"
	//FRAME 976 "spiderweb_glass"
	//FRAME 979 "teleport_player"
	
	// --RUBBLE SLIPS TO DOORWAY--
	//level.fall_path_rig waittillmatch( "single anim", "rumble_release" );
	flag_set( "fall_rubble_shift" );
	level.player PlayRumbleOnEntity( "heavy_2s" );
		
	// --RUBBLE RELEASES FROM DOORWAY BUT HANGS MOMENTARILY THEN SLIDE STARTS--
	level.fall_path_rig waittillmatch( "single anim", "original_start" );
	
	flag_set( "go_building_fall" );
	level notify( "begin_atrium_fall" );
	
	thread fall_enemies_slide();
	
	level.player PlayRumbleOnEntity( "collapsing_building" );
	level.player LerpViewAngleClamp( 0.75, 0.5, 0, 55, 70, 50, 50 );
	level.player DisableInvulnerability();
	wait( 2.0 );
	thread corpse_clear();
	
	// --PILLAR STARTS TO COLLAPSE--
	level.fall_path_rig waittillmatch( "single anim", "pillar_break" );
	flag_set( "atrium_pillar_break" );
	
	// --FLOOR STARTS TO COLLAPSE--
	level.fall_path_rig waittillmatch( "single anim", "start_floor" );
	flag_set( "atrium_floor_break" );

	// --PULL THE PLAYER'S VIEW TO FRONT FOR RAIL HIT--
	level.fall_path_rig waittillmatch( "single anim", "camera_to_front" );
	level notify( "fall_slide_ending" );
	flag_set( "atrium_pre_rail_hit" );
	level.player LerpViewAngleClamp( 1.8, 0, 0.5, 10, 10, 10, 10 );
	thread fall_enemies_rail_hit();
	
	wait( 1.0 );
	level.player DisableWeapons();
	
	// --THIS IS THE RAIL HIT--
	level.fall_path_rig waittillmatch( "single anim", "slomo_on" ); 
	flag_set( "fall_rail_hit" );
	thread fall_player_dof();
	thread maps\cornered_audio::aud_collapse( "slow" );

	thread fall_props_parachute();
	thread fall_props_player_parachute();
	
	level.player PlayRumbleOnEntity( "heavy_1s" );
	//level.player SetViewKickScale( 2.5 );
	//level.player ViewKick( 127, level.player.origin );
	//level.player SetBlurForPlayer( 3.5, 0.0 );
	level thread lobby_and_stair_fx();
	
	level.player LerpViewAngleClamp( 0.5, 0, 0, 80, 80, 120, 120 );
	SetPhysicsGravityDir( ( 0, -0.7, -0.1 ) );
	
	// --THIS IS THE OLD SLO-MO (NOW GONE)--
	level.fall_path_rig waittillmatch( "single anim", "slomo_on" );  //this is the real slo-mo
	//level.player SetViewKickScale( 1.0 );
	level.player SetBlurForPlayer( 0.0, 0.25 );
	
	level.fall_path_rig waittillmatch( "single anim", "slomo_off" );
	flag_set( "pre_glass_impact" );
	level.player LerpViewAngleClamp( 0.5, 0, 0, 0, 0, 0, 0 );
	//level.player DisableWeapons();
	PhysicsExplosionSphere( level.player.origin, 100, 64, 1 );
	
	level.fall_path_rig waittillmatch( "single anim", "spiderweb_glass" );
	thread fall_glass_final_impact();
	PhysicsExplosionSphere( level.player.origin, 100, 64, 1 );
	
	level.fall_path_rig waittillmatch( "single anim", "teleport_player" );
	
	fade_out( .05, "white" );
	flag_set( "parachute_exfil" );
	level.player SetBlurForPlayer( 5.0, 0.0 );
	level.player PlayerLinkToDelta( level.fall_arms_and_legs[ 0 ], "tag_player", 1, 0, 0, 0, 0 );
	level.fall_anim_struct thread anim_single_solo( level.fall_arms_and_legs[ 0 ], "cornered_exfil_player" );
	//level.player LerpViewAngleClamp( 0.5, 0, 0, 35, 35, 40, 40 );
	
	flag_set( "obj_escape_complete" ); //objective 5 complete
	
	wait( .1 );
	fade_in( .25, "white" );
	wait( .4 );
	level.player SetBlurForPlayer( 0.0, 0.5 );
	
	wait( 3.5 );
	level.player PlayerLinkToDelta( level.fall_arms_and_legs[ 0 ], "tag_player", 0, 25, 25, 40, 40 );
	
	time = GetAnimLength( level.fall_arms_and_legs[ 0 ] getanim( "cornered_exfil_player" ));
	//wait( time - 3.5 );
	wait( time - 7.0 );

	fade_out( 3.0 );
	wait( 4.0 );
	nextmission();			
}

fall_player_dof()
{	
	//blur during slide
	maps\_art::dof_enable_script( 1, 75, 4, 1000, 7000, 1.75, .1 );
	
	flag_wait( "pre_glass_impact" );
	
	//blur during slide
	maps\_art::dof_enable_script( 1, 200, 5.5, 750, 7000, 0.06, 1 );
	
	flag_wait( "parachute_exfil" );	
	maps\_art::dof_disable_script( 0.75 );
		
	//flag_wait( "atrium_finished" );
	//maps\_art::dof_disable_script( 0.3 );
}

fall_allies_rorke()
{
	self set_ignoreall( true );
	self set_ignoreme( true );
	self disable_arrivals();
	self pathrandompercent_zero();
	self PushPlayer( true );
	self disable_pain();
	self disable_surprise();
	self.grenadeAwareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	
	level.fall_anim_struct thread anim_single_solo( self, "enter_lobby" );
	wait( .5 );
	anim_set_rate_single( self, "enter_lobby", 1.28 );
	self waittillmatch( "single anim", "end" );
	
	flag_set( "lobby_rorke_ready" );
	
	if( !flag( "lobby_shake" ))
	{
		level.fall_anim_struct thread anim_loop_solo( self, "idle_lobby", "stop_lobby_idle" );
	}	
	
	flag_wait( "lobby_shake" );
	
	level.fall_anim_struct notify( "stop_lobby_idle" );
	waittillframeend;
	
	level.fall_anim_struct anim_single_solo( self, "cornered_building_fall_lobby_tumble_enter" );
	level.fall_anim_struct thread anim_loop_solo( self, "cornered_building_fall_lobby_tumble_idle", "stop_lobby_idle" );
	
	flag_wait( "fall_down_shake" );
	level.fall_anim_struct notify( "stop_lobby_idle" );
	waittillframeend;
	
	level.fall_anim_struct thread anim_single_solo( self, "cornered_building_fall_lobby_tumble_exit" );
	
	flag_wait( "player_is_slipping" );
	level.fall_anim_struct thread anim_single_solo( self, "allies_building_fall_slide" );
	
	flag_wait( "parachute_exfil" );
	//Building opposite destruction;
	exploder( 4999 );
		
	level.fall_anim_struct anim_single_solo( self, "cornered_exfil_ally1" );
}

fall_allies_baker()
{
	self set_ignoreall( true );
	self set_ignoreme( true );
	self disable_arrivals();
	self pathrandompercent_zero();
	self PushPlayer( true );
	self disable_pain();
	self disable_surprise();
	self.grenadeAwareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	
	self thread fall_allies_baker_fall_down();
	level.fall_anim_struct thread anim_single_solo( self, "enter_lobby" );
	
	level endon( "lobby_shake" );
	
	self waittillmatch( "single anim", "end" );
	
	level.fall_anim_struct anim_reach_solo( self, "lobby_window_enter" );
	level.fall_anim_struct thread anim_single_solo( self, "lobby_window_enter" );
	
	self waittillmatch( "single anim", "end" );
	
	level.fall_anim_struct thread anim_loop_solo( self, "lobby_window_idle", "stop_lobby_idle" );
	
	/*while( !flag( "lobby_shake" ) || !flag( "lobby_rorke_ready" ))
	{
		waitframe();
		if( self GetAnimTime( self getanim( "enter_lobby" )) >= 1 )
		{
			break;
		}
	}
	
	if( !flag( "lobby_shake" ))
	{
		level.fall_anim_struct thread anim_reach_solo( self, "lobby_window_enter" );
	}	
	
	if( !flag( "lobby_shake" ))
	{
		level.fall_anim_struct thread anim_loop_solo( self, "idle_lobby", "stop_lobby_idle" );
	}	*/
	

}

fall_allies_baker_fall_down()
{
	flag_wait( "lobby_shake" );
	
	level.fall_anim_struct notify( "stop_lobby_idle" );
	waittillframeend;

	org = self spawn_tag_origin();
	org anim_single_solo( self, "cornered_building_fall_lobby_tumble_enter" );
	org thread anim_loop_solo( self, "cornered_building_fall_lobby_tumble_idle", "stop_lobby_idle" );
	
	flag_wait( "parachute_exfil" );
	org notify( "stop_lobby_idle" );	
	level.fall_anim_struct anim_single_solo( self, "cornered_exfil_ally2" );
}

fall_vo()
{
	wait( .5 );
	//Merrick: Get to the window! 
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_gettothewindow" );
	
	wait( 2.5 );
	//Merrick: Prep your chutes!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_prepyourchutes" );
	
	flag_wait_all( "lobby_shake", "lobby_rorke_ready" );
	wait( 1.5 );
	//Merrick: It's going down!!!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_itsgoingdown" );
	
	wait( .75 );
	//Hesh: Grab on to something!!!
	level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_grabontosomething" );
	
	flag_wait( "fall_down_shake" );
	//Hesh : Watch out!!!
	level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_watchout" );
	
	flag_wait( "atrium_pre_rail_hit" );
	//Merrick: Ready your chutes!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_readyyourchutes" );
	
	flag_wait( "parachute_exfil" );
	wait( 7 );
	//Merrick: Oracle, Black Knight is airborne; en route to rally point echo.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_oracleblackknightis" );
}

fall_enemies_start()
{
	stumble_guys = array_spawn_function_targetname( "lobby_enemies_stumbler_start", ::fall_enemy_self_anim );
	stumble_guys = array_spawn_targetname( "lobby_enemies_stumbler_start", true );
	
	flag_wait( "fall_down_shake" );
	
	thread fall_enemy_anim( "lobby_enemy_a", "fall_enemy_a" );
	thread fall_enemy_anim( "lobby_enemy_b", "fall_enemy_b" );
	thread fall_enemy_anim( "lobby_enemy_c", "fall_enemy_c" );
	thread fall_enemy_anim( "lobby_enemy_d", "fall_enemy_d" );
	thread fall_enemy_anim( "lobby_enemy_e", "fall_enemy_e" );
	
	//flag_wait( "fall_enemy_a" );
//	array_spawn_function_targetname( "lobby_enemy_a", ::fall_enemy_node_anim, "fall_animnode" );
//	array_spawn_targetname( "lobby_enemy_a", true );
	
	railing_guys = array_spawn_function_targetname( "lobby_railing_enemy", ::fall_enemy_self_anim );
	railing_guys = array_spawn_targetname( "lobby_railing_enemy", true );
	
//	flag_wait( "fall_enemy_b" );
//	array_spawn_function_targetname( "lobby_enemy_b", ::fall_enemy_node_anim, "fall_animnode" );
//	array_spawn_targetname( "lobby_enemy_b", true );
//	
//	flag_wait( "fall_enemy_c" );
//	array_spawn_function_targetname( "lobby_enemy_c", ::fall_enemy_node_anim, "fall_animnode" );
//	array_spawn_targetname( "lobby_enemy_c", true );
//	
//	flag_wait( "fall_enemy_e" );
//	array_spawn_function_targetname( "lobby_enemy_e", ::fall_enemy_node_anim, "fall_animnode" );
//	array_spawn_targetname( "lobby_enemy_e", true );
//	
//	flag_wait( "fall_enemy_d" );
//	array_spawn_function_targetname( "lobby_enemy_d", ::fall_enemy_node_anim, "fall_animnode" );
//	array_spawn_targetname( "lobby_enemy_d", true );
//	
//	flag_wait( "fall_enemy_f" );
//	array_spawn_function_targetname( "lobby_enemy_f", ::fall_enemy_node_anim, "fall_animnode" );
//	array_spawn_targetname( "lobby_enemy_f", true );

	//wait( 3.9 );
	//stumble_guys = array_spawn_function_targetname( "lobby_enemies_stumbler", ::fall_enemy_self_anim );
	//stumble_guys = array_spawn_targetname( "lobby_enemies_stumbler", true );
}

fall_enemy_anim( targetname, flagname )
{
	flag_wait( flagname );
	array_spawn_function_targetname( targetname, ::fall_enemy_node_anim, "fall_animnode" );
	array_spawn_targetname( targetname, true );
}

fall_enemies_slide()
{
	sliders = array_spawn_function_targetname( "atrium_enemies_sliding_group", ::fall_enemy_node_anim, "fall_animnode" );
	
	wait( 1.25 );
	//enemy1 = spawn_script_noteworthy( "slide_enemy_f", true );
	
	wait( 2.55 );
	enemy2 = spawn_script_noteworthy( "slide_enemy_h", true );
	
	wait( .25 );
	enemy3 = spawn_script_noteworthy( "slide_enemy_g", true );
	}	

fall_enemies_rail_hit()
{
	wait( 2 );
	enemies = array_spawn_function_noteworthy( "atrium_enemies_slomo", ::fall_enemy_self_anim );
	enemy1 = spawn_targetname( "atrium_enemies_slomo_1", true );
	wait( .2 );
	enemy2 = spawn_targetname( "atrium_enemies_slomo_2", true );
	wait( .1 );
	enemy3 = spawn_targetname( "atrium_enemies_slomo_3", true );
	wait( .1 );
	enemy4 = spawn_targetname( "atrium_enemies_slomo_4", true );	
}

#using_animtree( "animated_props" );
fall_props()
{
	exterior_beams = getEntArray( "fallbeams", "targetname" );
	array_delete( exterior_beams );
	
	thread fall_props_lobby_furniture();
	
	rubble = GetEnt( "lobby_rubble", "targetname" );
	rubble.animname = "bldg_shake_rubble";
	rubble SetAnimTree();
	
	light1 = GetEnt( "lobby_hanging_light_1", "targetname" );
	light1.animname = "lobby_lights";
	light1 SetAnimTree();
	
	light2 = GetEnt( "lobby_hanging_light_2", "targetname" );
	light2.animname = "lobby_lights";
	light2 SetAnimTree();
	
	pillar = GetEnt( "falling_pillar_1", "targetname" );
	pillar.animname = "bldg_tilt_pillar";
	pillar SetAnimTree();
	
	floor_break = GetEnt( "fall_floor_collapse", "targetname" );
	floor_break.animname = "bldg_tilt_floor";
	floor_break SetAnimTree();
		
	atrium_lights = GetEntArray( "falling_lights", "targetname" );
	array_thread( atrium_lights, ::fall_props_atrium_lights );
	
	thread fall_prop_corner_collapse();
	thread fall_props_ext_bldg_sign();

	all_debris = GetEntArray( "fall_debris", "script_noteworthy" );
	foreach( piece in all_debris )
	{
		piece.animname = piece.targetname;
		piece SetAnimTree();
	}
	
	wait( 0.2 );
	
	level.fall_anim_struct thread anim_first_frame_solo( rubble, "cornered_building_fall_lobby_celling_debris" );
	level.fall_anim_struct thread anim_first_frame( all_debris, "cornered_building_fall_debris" );
	level.fall_anim_struct thread anim_first_frame_solo( pillar, "cornered_building_fall_pillar_break" );
	level.fall_anim_struct thread anim_first_frame_solo( floor_break, "cornered_building_fall_floor_collapse" );
	
	level.fall_anim_struct thread anim_loop_solo( light1, "cornered_building_fall_lobby_hanging_light_a", "stop_light_loop" );
	level.fall_anim_struct thread anim_loop_solo( light2, "cornered_building_fall_lobby_hanging_light_b", "stop_light_loop" );
	
	// --ON STAIRS--
	flag_wait( "lobby_stairwell_shake" );
	
	// --HUGE LOBBY EXPLOSION--
	flag_wait_all( "lobby_shake", "lobby_rorke_ready" );
	//level.fall_anim_struct thread anim_single_solo( rubble, "cornered_building_fall_lobby_celling_debris" );
	level.fall_anim_struct notify( "stop_light_loop" );
	level.fall_anim_struct thread anim_single_solo( light1, "cornered_building_fall_lobby_hanging_light_exp_a" );
	level.fall_anim_struct thread anim_single_solo( light2, "cornered_building_fall_lobby_hanging_light_exp_b" );
	level.fall_anim_struct thread anim_single( all_debris, "cornered_building_fall_debris" );
		
	thread fall_break_glass();
	
	flag_wait( "fall_stagger_anim_done" );
	level.fall_anim_struct thread anim_single_solo( rubble, "cornered_building_fall_lobby_celling_debris" );

	// --PLAYER HITTING RUBBLE--
	flag_wait( "player_is_slipping" );
	level.fall_anim_struct thread anim_single_solo( rubble, "cornered_building_fall_release_rubble" );	

	// --Tilt--
	flag_wait( "atrium_pillar_break" );
	level.fall_anim_struct thread anim_single_solo( pillar, "cornered_building_fall_pillar_break" );
	thread fall_props_pillar_rumble();
	
	flag_wait( "atrium_floor_break" );
	level.fall_anim_struct thread anim_single_solo( floor_break, "cornered_building_fall_floor_collapse" );
}

fall_props_pillar_rumble()
{
	wait( 2.65 );
	level.player PlayRumbleOnEntity( "heavy_1s" );
	
	wait( 1.65 );
	level.player PlayRumbleOnEntity( "heavy_1s" );

	level.player SetBlurForPlayer( 3.0, .05 );
	wait( .35 );
	level.player SetBlurForPlayer( 0.0, .5 );
}
	
fall_prop_picture()
{
	picture = GetEnt( "lobby_tilting_picture", "targetname" );
	picture add_target_pivot();
	picture_pivot = picture.pivot;
	
	rollang1 = 18;
	rollang2 = 18;
	ang_dec = 0.75;
	t		= 0.75;

	if( isDefined( level.atrium_checkpoint ) )
	{
		picture_pivot RotateRoll( 7, 0.05 );
	}
	
	flag_wait( "lobby_stairwell_shake" );
	
	for ( i = 0; i < 13; i++ )
	{
		picture_pivot RotateRoll( rollang2, t, t * ( 1 / 3 ), t * ( 2 / 3 ) );
		wait t;
		rollang2 = ( -1 * rollang1 )  + ( -1 * rollang1 * ang_dec );
		rollang1 = -1 * rollang1 * ang_dec;
		t		= t * 0.95;
	}
}

fall_props_lobby_furniture()
{
	rig = spawn_anim_model( "lobby_objects" );
	furniture = GetEntArray( "lobby_furniture", "targetname" );
	
	animnode = getstruct( "fall_animnode", "targetname" );
	animnode anim_first_frame_solo( rig, "cornered_building_fall_lobby_furniture_a" );
	
	foreach( object in furniture )
	{
		joint_origin = rig GetTagOrigin( "J_prop_" + object.script_noteworthy );
		joint_angles = rig GetTagAngles( "J_prop_" + object.script_noteworthy );
		
		object.origin = joint_origin;
		object.angles = joint_angles;
		
		object LinkTo( rig, "J_prop_" + object.script_noteworthy );
		
		if( object.script_noteworthy == "6" || object.script_noteworthy == "11" )
		{
			pillows = GetEntArray( "pillows_" + object.script_noteworthy, "targetname" );
			
			foreach( pillow in pillows )
			{
				pillow LinkTo( object );
			}
		}
	}
	
	flag_wait( "lobby_stairwell_shake" );
	
	thread fall_physics_debris_furniture();
	animnode anim_single_solo( rig, "cornered_building_fall_lobby_furniture_a" );
	
	flag_wait_all( "lobby_shake", "lobby_rorke_ready" );
	
	animnode anim_single_solo( rig, "cornered_building_fall_lobby_furniture_b" );
	
	flag_wait( "fall_down_shake" );
	
	animnode anim_single_solo( rig, "cornered_building_fall_lobby_furniture_c" );
}

fall_prop_corner_collapse()
{
	falling_struct = getstruct( "fall_animnode", "targetname" );
	
	corner = GetEntArray( "bldg_fall_corner_collapse", "targetname" );
	foreach( item in corner )
	{
		item.animname = "bldg_tilt_corner";
		item SetAnimTree();
	}

	glass_decal_1 = getEntArray( "bldg_fall_corner_collapse_glass1", "targetname" );
	glass_decal_2 = getEntArray( "bldg_fall_corner_collapse_glass2", "targetname" );
	
	falling_struct thread anim_first_frame( corner, "cornered_building_fall_corner_collapse" );

	flag_wait( "go_building_fall" );
	wait( 0.75 );
	
	falling_struct thread anim_single( corner, "cornered_building_fall_corner_collapse" );
		
	corner[ 0 ] waittillmatch( "single anim", "shatter_1" );
	foreach( item in glass_decal_1 )
	{
		item Delete();
	}
	glass1 = GetGlassArray( "glass_level_1" );
	foreach( item in glass1 )
		{
		DestroyGlass( item );
		}
	beams = GetEnt( "corner_beam", "targetname" );
	beams Delete();
	
	wait( 0.7 );
	foreach( item in glass1 )
		{
		DeleteGlass( item );
		}
	
	corner[ 0 ] waittillmatch( "single anim", "shatter_2" );
	foreach( item in glass_decal_2 )
		{
		item Delete();
		}
		
	glass2 = GetGlassArray( "glass_level_2" );
	foreach( item in glass2 )
	{
		DestroyGlass( item );
	}
		
	wait( 0.7 );
	foreach( item in glass2 )
	{
		DeleteGlass( item );
	}
}

fall_props_atrium_lights()
{
	falling_struct = getstruct( "fall_animnode", "targetname" );
	
	self.animname = "bldg_tilt_light";
	self SetAnimTree();
	
	falling_struct thread anim_loop_solo( self, "cornered_building_fall_idle_hanging_light_" + self.script_noteworthy, "stop_swaying_loop" );

	flag_wait( "go_building_fall" );
	falling_struct notify( "stop_swaying_loop" );
	waittillframeend;
	falling_struct thread anim_single_solo( self, "cornered_building_fall_slide_hanging_light_" + self.script_noteworthy );
}

fall_props_parachute()
{
	falling_struct = getstruct( "fall_animnode", "targetname" );
	
	props = [];
	props[ 0 ] = spawn_anim_model( "exfil_chute_1" );
	props[ 1 ] = spawn_anim_model( "exfil_chute_2" );
	
	falling_struct anim_first_frame( props, "cornered_exfil" );
	
	foreach ( item in props )
	{
		item Hide();
	}

	flag_wait( "parachute_exfil" );
	falling_struct thread anim_single( props, "cornered_exfil" );
	props[ 1 ] Show();
	
	flag_wait( "show_ally_chute" );
	props[ 0 ] Show();
}

fall_props_player_parachute()
{
	falling_struct = getstruct( "fall_animnode", "targetname" );
	
	props = [];
	props[ 0 ] = spawn_anim_model( "exfil_ripcord_player" );
	props[ 1 ] = spawn_anim_model( "exfil_chute_player" );
	
	falling_struct anim_first_frame( props, "cornered_exfil" );
	
	foreach ( item in props )
	{
		item Hide();
	}
	
	flag_wait( "parachute_exfil" );
	
	falling_struct thread anim_single( props, "cornered_exfil" );
	
	flag_wait( "show_player_chute" );
	
	foreach ( item in props )
	{
		item Show();
	}
}

fall_props_ext_bldg_sign()
{
	
	end_bldg = getEntArray( "end_broken_bldg", "targetname" );
	//bldg_sign = getEnt( "fall_tiran_sign", "script_noteworthy" );
	
	end_bldg[ 0 ] thread fall_fx_end_bldg();
		
	rig = spawn_anim_model( "exfil_bldg" );
	
	falling_struct = getstruct( "fall_animnode", "targetname" );
	falling_struct anim_first_frame_solo( rig, "cornered_exfil_building_and_sign" );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	j2_origin = rig GetTagOrigin( "J_prop_2" );
	j2_angles = rig GetTagAngles( "J_prop_2" );
	
	waitframe();

	foreach( obj in end_bldg )
	{
		obj LinkTo( rig, "J_prop_1" );
	}
	
	flag_wait( "go_exfil_bldg" );
	
	//bldg_sign LinkTo( rig, "J_prop_2" );
	falling_struct anim_single_solo( rig, "cornered_exfil_building_and_sign" );
}


fall_fx_end_bldg()
{
	//grabbing fires to link to bldg
	//exploder( 3999 );
	vfxarry = get_exploder_array( 3999 );
	
	foreach( fx in vfxarry )
	{
		if ( IsSubStr( fx.v[ "fxid" ], "falling_debris_card" ) || IsSubStr( fx.v[ "fxid" ], "vfx_debris_fall_exfil_2" ) )
		{
			ent		   = spawn_tag_origin();
			ent.fxid   = fx.v[ "fxid" ];
			ent.origin = fx.v[ "origin" ];
			ent.angles = fx.v[ "angles" ];
			
			ent LinkTo( self ); //self is a building bmodel.
			
			thread fall_fx_bldg_fx( ent );
		}
	}
}

fall_fx_bldg_fx( ent )
{
	flag_wait( "go_exfil_bldg" );
		
	PlayFXOnTag( level._effect[ ent.fxid ], ent, "tag_origin" );
}

fall_break_glass()
{
	wait( 1.25 );
	lobby_glass_atrium = GetGlassArray( "lobby_atrium_glass" );
	foreach ( pane in lobby_glass_atrium )
	{
		thread fall_break_glass_with_delay( pane, 0.05, 0.06, 0, 1, .1 );
	}

	// Lobby Doors
	lobby_glass_doors = GetGlassArray( "lobby_atrium_glass_doors" );
	handles			  = GetEntArray( "atrium_door_handles", "targetname" );
	array_delete( handles );
	foreach ( pane in lobby_glass_doors )
	{
		thread fall_break_glass_with_delay( pane, 0.05, 0.06, 0, 1, 0 );
	}
	
	flag_wait( "fall_down_shake" );
	wait( 1.6 );
	foreach( pane in lobby_glass_doors )
	{
		DeleteGlass( pane );
	}
}
	
fall_break_glass_with_delay( id, min_delay, max_delay, x_dir, y_dir, z_dir )
{
	wait( RandomFloatRange( min_delay, max_delay ) );
	DestroyGlass( id, ( x_dir, y_dir, z_dir ) );
}

fall_glass_final_impact()
{
	glass = getGlass( "atrium_fall_glass" );
	clip = getEnt( "atrium_fall_glass_clip", "targetname" );
	
	DestroyGlass( glass );
	clip Delete();
}

fall_physics_debris_entry_stairs()
{
	stuff1 = GetEntArray( "pre_lobby_shelf_debris1", "targetname" );
	stuff2 = GetEntArray( "pre_lobby_shelf_debris2", "targetname" );
	stuff3 = GetEntArray( "pre_lobby_shelf_debris3", "targetname" );
		
	flag_wait( "lobby_stairwell_shake" );
	thread maps\cornered_audio::aud_collapse( "shelf" );

	SetPhysicsGravityDir( ( -0.02, 0, -0.03 ));
	foreach( object in stuff1 )
	{
		object PhysicsLaunchClient( object.origin + ( -2, 2, 0 ), ( 0, -0.002, -1 ) );
		object thread debris_remove_after_time( 15.0 );
	}

	wait( .2 );
	foreach( object in stuff2 )
	{
		object PhysicsLaunchClient( object.origin + ( -2, 2, 0 ), ( 0, -0.002, -1 ) );
		object thread debris_remove_after_time( 15.0 );
	}

	wait( .2 );	
	foreach( object in stuff3 )
	{
		object PhysicsLaunchClient( object.origin + ( -2, 2, 0 ), ( 0, -0.002, -1 ) );
		object thread debris_remove_after_time( 15.0 );
	}
	SetPhysicsGravityDir( ( 0, -0.02, -0.03 ));
}

fall_physics_debris_lobby()
{
	if( !isDefined( level.atrium_checkpoint ) )
	{
		flag_wait( "office_explosion" );
	}
	
	lobby_debris1 = GetEntArray( "lobby_debris1", "targetname" );
	foreach( piece in lobby_debris1 )
	{
		piece PhysicsLaunchClient( piece.origin + ( 0, 0, -6 ), ( 0, -1, 0) );
		piece thread debris_remove_after_time( 20.0 );
	}
			
	wait( 2.8 );
	lobby_debris2 = GetEntArray( "lobby_debris2", "targetname" );
	foreach( piece in lobby_debris2 )
	{
		piece PhysicsLaunchClient( piece.origin + ( 0, 0, -6 ), ( 0, -1, 0) );
		piece thread debris_remove_after_time( 20.0 );
	}
					
	flag_wait( "player_is_slipping" );	
	lobby_debris3 = GetEntArray( "lobby_debris3", "targetname" );
	foreach( piece in lobby_debris3 )
	{
		piece PhysicsLaunchClient( piece.origin + ( 0, 0, -6 ), ( 0, -1, 0) );
		piece thread debris_remove_after_time( 20.0 );
	}
}

fall_physics_debris_furniture()
{
	furniture_debris = GetEntArray( "lobby_furniture_junk", "targetname" );
	
	foreach( piece in furniture_debris )
	{
		piece PhysicsLaunchClient( piece.origin + ( 0, 0, -8 ), ( 0, -125, 500 ) );
		piece thread debris_remove_after_time( 20.0 );
	}
}
		
fall_physics_debris_slide()
{
	// STARTS WITH PLAYER HITTING RUBBLE AT DOOR
	debris_c = level.player spawn_tag_origin();
	debris_c.origin = level.player.origin + ( 0, 16, 32 );
	debris_c thread debris_spawner( 0.1, 0.2, 600, ( 0, -1, -0.01 ), true, true );
	
	flag_wait( "atrium_pillar_break" );
	
	debris_a = level.player spawn_tag_origin();
	debris_a.origin = level.player.origin + ( 24, 4, 12 );
	debris_a LinkTo( level.fall_arms_and_legs[0] );
	debris_a thread debris_spawner( 0.1, 0.2, 1200, ( 0, -1, -0.01 ), true, true );
	
	debris_b = level.player spawn_tag_origin();
	debris_b.origin = level.player.origin + ( -24, 4, 12 );
	debris_b LinkTo( level.fall_arms_and_legs[0] );
	debris_b thread debris_spawner( 0.1, 0.2, 1200, ( 0, -1, -0.01 ), true, true );
	
	flag_wait_any( "atrium_finished", "parachute_exfil" );
	
	debris_a Delete();
	debris_b Delete();
	debris_c Delete();
}

/*lobby_bkground_runners()
{
	self endon( "death" );
	level endon( "remove_runners" );
	
	self.ignoreme = true;
	self.ignoreall = true;
	
	wait( RandomFloatRange( 0.05, 0.65 ));
	
	node = getstruct( self.target, "targetname" );
	node anim_generic_reach( self, node.animation );
	node anim_generic_gravity_run( self, node.animation );

	node = getNode( node.target, "targetname" );
	self SetGoalNode( node );
	
	self waittill( "goal" );
	self Delete();
}*/

/*building_fall_effect_handler()
{
	// All Effects in the vista need to rotate:
	if ( IsDefined( level.rotating_effects ) )
	{
		if ( level.rotating_effects.size != 0 )
{
			array_delete( level.rotating_effects ); // Remove what's there, play new
			array_removeUndefined( level.rotating_effects ); // Isn't working 100%, use new array
	
			level.vfxarry = get_exploder_array( 9999 );
			level.smoke_effect_tags	= [];
			foreach ( ent in level.vfxarry )
	{
				tag_origin = ent spawn_tag_origin();
				tag_origin.origin = ent.v[ "origin" ];
				tag_origin.angles = ent.v[ "angles" ];
				tag_origin LinkTo( level.vista_pivot );
				PlayFXOnTag( level._effect[ ent.v[ "fxid" ]], tag_origin, "tag_origin" );
					
				level.smoke_effect_tags[ level.smoke_effect_tags.size ] = tag_origin;
			}		
	}	
}

	flag_wait( "fall_rail_hit" );
	wait( 1 );
	stop_exploder( 3023 ); // Stop trash/fire FX in Atrium
	//stop_exploder( 3088 ); // Stop dust FX in Atrium
}*/

///////////////////////
//
// BUILDING FALL UTILS
//
///////////////////////
	
lobby_and_stair_fx()
{
	//IPrintLnBold("Shake");
	exploder( 7651 );
	exploder( 3088 );
}	

random_building_shake_loop( magnitude, min_length, max_length, calm_interval )
{
	level endon( "done_random_shaking" );
	
	AssertEx( min_length > 0				, "lobby_random_shaking(): min_length must be > 0" );
	AssertEx( max_length > min_length		, "lobby_random_shaking(): max_length must be > min_length" );
	AssertEx( min_length + calm_interval > 0, "lobby_random_shaking(): min_length + calm_interval must be > 0 " );

	while ( 1 )
	{
		ran = RandomFloatRange( min_length, max_length );
		if( ran < 2 )
	{
			level.player PlayRumbleOnEntity( "light_1s" );
	}	
		else if( ran >= 2 && ran < 3 )
		{
			level.player PlayRumbleOnEntity( "light_2s" );
}
		else
{
			level.player PlayRumbleOnEntity( "light_3s" );
		}
	
	
		level thread lobby_and_stair_fx();
		Earthquake( magnitude, ran, level.player.origin, 2500 );
		maps\cornered_audio::aud_collapse( "lobby" );
		PhysicsJitter( level.player.origin, 3000, 2800, 1.0, 2.0 );
		wait( ran + calm_interval );
	}
}

fall_enemy_self_anim()
	{
	self.animname = "generic";
	self.allowdeath = true;
	self.deathanim = undefined;
	self.deathfunction = ::death_only_ragdoll;	
	waitframe();
	self anim_generic( self, self.animation );
	
	if( isAlive( self ) && isDefined( self ))
	{
		self kill();
	}
}

fall_enemy_node_anim( animnode, animtime )
{
	assertEx( IsDefined( animnode ), "Animnode is not defined." );
	
	node = getstruct( animnode, "targetname" );
	
	self.animname = "generic";
	self.allowdeath = true;
	waitframe();
	
	self.deathanim = undefined;
	self.deathfunction = ::death_only_ragdoll;
	node anim_generic( self, "cornered_building_fall_" + self.script_noteworthy );

	if( isAlive( self ) && isDefined( self ))
{
		self kill();
	}	
}

corpse_clear()
{
	level endon( "teleported" );
	
	trigger = getEnt( "corpse_cleaner", "targetname" );
	
	while( 1 )
	{
		corpses = GetCorpseArray();	
		foreach( corpse in corpses )
		{
			if( corpse isTouching( trigger ))
			{
			   	corpse Delete();
			}
		}
		wait( .05 );
	}
	
}
