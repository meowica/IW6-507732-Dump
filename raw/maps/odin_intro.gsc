#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


intro_start()
{
	//iprintlnbold( "Intro Start" );
	maps\odin_util::move_player_to_start_point( "start_odin_intro" );
	
	level.player thread player_recoil();
	
	maps\odin_spacejump::safe_hide_spacejump();
}

section_precache()
{
	// Precache the level weapons for Prologue's purposes
	PreCacheItem( "kriss_space" );
	PreCacheItem( "fp6_space" );
}

section_flag_init()
{
	flag_init( "start_transition_to_youngblood" );
	flag_init( "do_transition_to_odin" );
	flag_init( "player_in_rot_test" );
	flag_init( "clear_to_tweak_player" );
	flag_init( "clear_to_tweak_player_forced" );
	flag_init( "wall_push_tweak_player" );
	flag_init( "push_player_hard_wall" );
	flag_init( "get_intro_moving" );
	flag_init( "player_left_satellite" );
	flag_init( "player_approaching_base" );
	flag_init( "player_at_airlock" );
	flag_init( "invasion_clear" );
}

section_hint_string_init()
{
	
}


//================================================================================================
//	MAIN
//================================================================================================
intro_main()
{
	thread maps\_introscreen::introscreen_generic_fade_in( undefined, 1, 4 , 0 );
	
	// FIXME *** WARNING *** FIXME
	// Youngblood currently has 0 blocks or waits.
	// So Youngblood instantly falls through to this checkpoint.
	// Anything you put in here will run from Youngblood in Prologue
	// FIXME *** WARNING *** FIXME
	
	if( isDefined( level.prologue ) && level.prologue == true )
	{
		flag_wait( "do_transition_to_odin" );

		// Teleport the player to Odin start position
		maps\odin_util::move_player_to_start_point( "start_odin_intro" );
	}
	
	level.player SetViewModel( "viewhands_us_lunar" ); 
	
	//iprintlnbold( "Intro Main" );
	create_dvar( "shuttle_dock", 0 );
	clear_dvar("shuttle_dock");
	level.player DisableWeapons();

	
	thread intro_dialogue();
	
	// Force higher FOV
	if( !isDefined( level.prologue ))
	{
		SetSavedDvar( "cg_fov", 70 );
	}
	
	thread odin_5x5_fx();
	thread maps\_space_player::player_location_check( "exterior" );
	
	flag_set( "clear_to_tweak_player" );
	
	thread tweak_off_axis_player();
	
	//iprintlnbold( "player_left_satellite" );

	level.ally thread maps\odin_util::add_light_to_actor ( "ally" );

	// Main script for handling ally movement through the intro
	level.ally intro_vignette();
	
	// Handoff to next segment of Kyra progression
	level.ally station_entrance_to_infiltration();

//	flag_wait( "player_at_airlock" );
	
	// Cleanup
	thread intro_cleanup();
}

intro_setup()
{
}

intro_dialogue()
{
	level endon( "player_at_airlock" );
	
//	TODO:  Commented script is because this dialogue is too long for the current gameplay flow.  Need to figure out the flow of this event
	wait 1; // TODO: get rid of this wait
//	//Kyra: Bud - you have that signal transmitting yet?
//	smart_radio_dialogue( "odin_kyr_budyouhavethat" );
//	//Cubby: Take it easy, Kyra.  Bud's been on 5 hour EVA's every day to get the upgrade online.
//	smart_radio_dialogue( "odin_cub_kyratakeiteasy" );
//	//Kyra: Stow it, Cubby.  This diagnostics upgrade has taken too long as it is.
//	smart_radio_dialogue( "odin_kyr_stowitcubbythis" );
//	//Kyra: … there!  That's it Bud - we have your test signal - you are clear for engage.
//	smart_radio_dialogue( "odin_kyr_therethatsitbud" );
	//Kyra: Looks like the Firing Platform is receiving the diagnostics upgrade… reception is five by five
	smart_radio_dialogue( "odin_kyr_lookslikethefiring" );
//	//Kyra: Bud, you should be seeing a confirmation test strobe on the firing platform
//	smart_radio_dialogue( "odin_kyr_budyoushouldbe" );
//	//Cubby: I see it too, Kyra.
//	smart_radio_dialogue( "odin_cub_iseeittoo" );
	//Kyra: Ok, Bud - come on home. Airlock C is prepped.
	smart_radio_dialogue( "odin_kyr_okbudcomeon" );
	//Cubby: Payload, this is Odin landing - ready to receive.
	smart_radio_dialogue( "odin_cub_payloadthisisodin" );
//	//Payload: Odin landing, this is Payload. Let's uplink that.
//	smart_radio_dialogue( "odin_pyl_odinlandingthisis" );

//	//Cubby: Payload, ten meters... begin rotate.
	smart_radio_dialogue( "odin_cub_payloadtenmetersbegin" );
//	//Cubby: Five meters, Payload.
	smart_radio_dialogue( "odin_cub_fivemeterspayload" );
//	//Cubby: Two meters… zero your rotation delta Payload…
	smart_radio_dialogue( "odin_cub_twometerszeroyour" );
//	//Payload: Capturing...
	smart_radio_dialogue( "odin_pyl_capturing" );
//	//Payload: Talkback is barber pole, begin retract.
	smart_radio_dialogue( "odin_pyl_talkbackisbarberpole" );
//	//Cubby: Copy Payload.

}

odin_5x5_fx()
{
	wait 2;
	IPrintLnBold ("15 minutes earlier..." );
	exploder ("odin_5x5");
	wait 0.4;
	exploder ("odin_5x5");
	wait 0.2;
	exploder ("odin_5x5");
	wait 0.2;
	exploder ("odin_5x5");
	wait 0.4;
	exploder ("odin_5x5");
	
	while ( !flag ("play_invader_scene") )
	{
		wait 3.1;
		exploder ("odin_5x5");
		wait 0.3;
		exploder ("odin_5x5");
	}
}

//Opening ignette of the player and Kyra outside of the station
#using_animtree( "generic_human" );
intro_vignette()
{
	level endon( "intro_exterior_scene_end" );
	
	// Set up and position ally for the opening sequence
	maps\odin_util::actor_teleport( self, "odin_intro_ally_tp" );
	self.animname = "odin_ally" ;
	self.ignoreall = true;
	self gun_remove();

	node = GetEnt( "scriptednode_player", "script_noteworthy" );
	
	// Set up and run shuttle sequence
	thread shuttle_docking_sequence( node );
	
//	player_rig 			= spawn_anim_model( "player_rig" );
	
//	guys = [];
//	guys["player_rig"]	= player_rig;
//	
//	animNode anim_first_frame( guys , "intro_exterior_scene" );
//	arc = 15;
//	level.player PlayerLinkToDelta( player_rig , "tag_player" , 1 , arc , arc ,  arc , arc );
//	wait 3;
//	animNode thread anim_single( guys , "intro_exterior_scene" );
//	wait 11.95;
//	level.player Unlink();
//	player_rig hide();
	
	// Keeping Kyra hanging around the player at the start
	node thread anim_loop_solo( self, "odin_intro_kyra_satellite_idle", "stop_loop" );
	
	// Wait for player to leave starting volume
	ally_movement();  

	// ...then get Kyra moving/leading		
	node notify( "stop_loop" );
	node anim_single_solo( self, "intro_exterior_scene" );
//	waitframe();
//	anim_start_time = 0.06;
//	self SetAnimTime( %odin_intro_kyra, anim_start_time );
//	
//	// Wait for length of remaining animation time
//	length = getanimlength( %odin_intro_kyra );
//	wait ( length * ( 1 - anim_start_time ) );
	
	// Wait up for the player at the scaffolding
	node thread anim_loop_solo( self, "odin_intro_kyra_idle", "stop_loop" );
	
	flag_wait( "player_approaching_station" );
	
	node notify( "stop_loop" );
	
	// Player is on the move so lets keep the ally moving
	node anim_single_solo( self, "odin_intro_kyra_move_to_door" );
	node thread anim_loop_solo( self, "odin_intro_kyra_door_idle", "stop_loop" );
	
	flag_wait( "player_at_entrance" );
	
	node notify( "stop_loop" );
	self StopAnimScripted();
	waittillframeend;
}

station_entrance_to_infiltration()
{
	// Handing off to a new animation node
	node = GetEnt( "anim_entrance_to_infiltrate", "script_noteworthy" );
	
	node anim_single_solo( self, "odin_infiltrate_kyra_entrance" );
	node thread anim_loop_solo( self, "odin_infiltrate_kyra_midpoint_idle", "stop_loop" );
	
	flag_wait( "player_entered_station" );
	
	node notify( "stop_loop" );
	
//	self.intro_anim = true;  // HACK: tagTJ: temp hack to account for very long animation spanning two checkpoints
//	
//	// Moving Kyra to the infiltration hatch door and having her wait there
//	node anim_single_solo( self, "odin_infiltrate_kyra_to_door" );
//	node thread anim_loop_solo( self, "odin_infiltrate_kyra_door_idle", "stop_loop" );
	
//	flag_wait( "player_approaching_infiltration" );
}

ally_movement()
{
	delayThread( 12.0, ::flag_set, "get_intro_moving" );
	
	while( level.player IsTouching( GetEnt( "vol_player_at_satellite", "script_noteworthy" ) ) && !flag( "get_intro_moving" ) )
	{
		wait 0.1;	
	}
}

shuttle_docking_sequence( node )
{
	shuttle = spawn_anim_model( "shuttle" );
	
	node anim_single_solo( shuttle, "odin_intro_shuttle" );
}

tweak_off_axis_player()
{
	level.RNDpitchMax = 2;
	level.RNDrollhMax = 20;
	//thread tweak_off_translation_player();
	thread tweak_player_wall_push();
	view_ref_ent = spawn_tag_origin();
	level.view_ref_ent = view_ref_ent;
	level.player PlayerSetGroundReferenceEnt (level.view_ref_ent);
	wait 0.1;
	if ( flag ("player_approaching_base"))
	{
		level.view_ref_ent RotateTo ((-0,0,-25), 0.1, 0, 0);
		wait 2;
		level.view_ref_ent RotateTo ((-2,0,-10), 10, 3, 3);
		level.view_ref_ent waittill ("rotatedone");
	}
	else
		IPrintLnBold ("not flagged");
	thread rotation_reset( level.view_ref_ent );
	while(1)
	{
		if (flag ( "clear_to_tweak_player" ) && !flag("clear_to_tweak_player_forced"))
		{
			level.player PlayerSetGroundReferenceEnt (level.view_ref_ent);
			RNDpitch = RandomFloatRange (0-level.RNDpitchMax,level.RNDpitchMax);
			RNDroll = RandomFloatRange (0-level.RNDrollhMax,level.RNDrollhMax);
			//IPrintLnBold ("clear_to_tweak_player");
			time = RandomFloatRange (10,30);
			accel = (time*0.25);
			level.view_ref_ent RotateTo ((RNDpitch,0,RNDroll), time, accel, accel);
			level.view_ref_ent waittill ("rotatedone");
		}
		else
		{
			//IPrintLnBold ("NOT clear_to_tweak_player");
		//	level.view_ref_ent waittill ("rotatedone");
		//	level.player PlayerSetGroundReferenceEnt (undefined);
		//	level.view_ref_ent RotateTo ((0,0,0), 10, 0, 0);
		//	level.view_ref_ent waittill ("rotatedone");
			wait 1.0;
		}
	//wait 10;
	}
	//IPrintLnBold ("clearing groundrefent");
	level.player PlayerSetGroundReferenceEnt ( undefined );
	level.view_ref_ent delete();
}

rotation_reset(view_ref_ent)
{
	while(1)
	{
		if (!flag ( "clear_to_tweak_player" ))	
		{
			level.player PlayerSetGroundReferenceEnt (undefined);
			level.view_ref_ent RotateTo ((0,0,0), .1, 0, 0);		
		}
		wait 1;		
	}
}

tweak_off_translation_player()
{
	CURRENT1 = 0;
	CURRENT2 = 0;
	CURRENT3 = 0;
	while(1)
	{
		choice = RandomInt (3);
		if (choice == 0)
		{
			duration_frames = RandomFloatRange (10,30);
			DESIRED_CURRENT1 = RandomFloatRange (-300,300);
			DESIRED_CURRENT2 = RandomFloatRange (-300,300);
			DESIRED_CURRENT3 = RandomFloatRange (-300,300);
		}
		else
		{
			duration_frames = RandomFloatRange (5,10);
			DESIRED_CURRENT1 = 0;
			DESIRED_CURRENT2 = 0;
			DESIRED_CURRENT3 = 0;
		}
		DELTA_CURRENT1 = ( ( DESIRED_CURRENT1 - CURRENT1) * ( 1 / duration_frames));
		DELTA_CURRENT2 = ( ( DESIRED_CURRENT2 - CURRENT2) * ( 1 / duration_frames));
		DELTA_CURRENT3 = ( ( DESIRED_CURRENT3 - CURRENT3) * ( 1 / duration_frames));
			
		while (duration_frames > 0)
		{
			if (flag ( "clear_to_tweak_player" ) && !flag("clear_to_tweak_player_forced"))
			{
				CURRENT1 = ( CURRENT1 + DELTA_CURRENT1);
				CURRENT2 = ( CURRENT2 + DELTA_CURRENT2);
				CURRENT3 = ( CURRENT3 + DELTA_CURRENT3);
				SetSavedDvar ("player_swimWaterCurrent", (CURRENT1,CURRENT2,CURRENT3));
				duration_frames = duration_frames - 1;
				wait 0.05;
			}
			else
			{
				wait 1.0;
			}
		}
		//IPrintLnBold ("current1 " + CURRENT1);
		//IPrintLnBold ("current2 " + CURRENT2);
		//IPrintLnBold ("current3 " + CURRENT3);
		if (choice == 0)
			wait RandomFloatRange (0.5,1);
		else
			wait RandomFloatRange (0.5,1);
	}
}

tweak_player_wall_push()
{
	while (1)
	{
		flag_wait( "wall_push_tweak_player" );
		wait 0.8;
		//IPrintLnBold ("Tweakin player - angle "+level.view_ref_ent.angles[2]);
		//IPrintLnBold ("Tweakin player - angles "+level.player.angles[0]+", "+level.player.angles[1]+", "+level.player.angles[2]);
		if (level.player.angles[1] < -120 || level.player.angles[1] > 120)
		{
			RNDpitch = RandomFloatRange (-2,2);
			if (level.view_ref_ent.angles[2] > 0)
				RNDroll = RandomFloatRange (-25,-5);
			else
				RNDroll = RandomFloatRange (5,25);
		}
		else
		{
			RNDroll = RandomFloatRange (-2,2);
			if (level.view_ref_ent.angles[0] > 0)
				RNDpitch = RandomFloatRange (-25,-5);
			else
				RNDpitch = RandomFloatRange (5,25);
		}
		time = RandomFloatRange (2.3,4.8);
		level.view_ref_ent RotateTo ((RNDpitch,0,RNDroll), time, 0, time*0.8);
		wait time*0.3;
		flag_clear( "wall_push_tweak_player" );
		//IPrintLnBold ("Tweakin player done");
	}
}

intro_trigger_explosions_far()
{
	flag_set ("odin_breach_far");
	thread spawn_and_fling_bodies ("intro_dead_bodies_far", (-320, -3280, -600));
	breach_script_org_far = GetEnt( "odin_breach_stationpiece_far_org", "targetname" );
	thread maps\odin_audio::sfx_distant_explo( breach_script_org_far );
	breach_parts_far = GetEntArray( breach_script_org_far.target, "targetname" );
	foreach( piece in breach_parts_far )
		piece LinkTo( breach_script_org_far );
	breach_script_org_far MoveY (2000, 50);
	breach_script_org_far RotatePitch (360, 20);
}

intro_trigger_explosions_mid()
{
	flag_set ("odin_breach_mid");
	thread spawn_and_fling_bodies ("intro_dead_bodies_right", (3733, -3888, 500));
	breach_script_org_right = GetEnt( "odin_breach_stationpiece_right_org", "targetname" );
	thread maps\odin_audio::sfx_distant_explo( breach_script_org_right );
	breach_parts_right = GetEntArray( breach_script_org_right.target, "targetname" );
	foreach( piece in breach_parts_right )
		piece LinkTo( breach_script_org_right );
	breach_script_org_right MoveX (-2000, 50);
	breach_script_org_right RotateYaw (360, 20);
}

intro_trigger_explosions_near()
{
	flag_set ("odin_breach_near");
	thread spawn_and_fling_bodies ("intro_dead_bodies_left", (3100, -2200, 200));
	breach_script_org_left = GetEnt( "odin_breach_stationpiece_left_org", "targetname" );
	breach_parts_left = GetEntArray( breach_script_org_left.target, "targetname" );
	foreach( piece in breach_parts_left )
		piece LinkTo( breach_script_org_left );
	breach_script_org_left MoveZ (3000, 50);
	breach_script_org_left RotateRoll (360, 20);
	breach_script_org_left = GetEnt( "odin_breach_stationpiece_left_org", "targetname" );
	thread maps\odin_audio::sfx_distant_explo( breach_script_org_left );
	wait 0.25;
	thread maps\odin_audio::sfx_distant_explo( breach_script_org_left );
	wait 9.5;
	flag_set ("odin_breach_enter");
	breach_script_org_far = GetEnt( "odin_breach_stationpiece_far_org", "targetname" );
	thread maps\odin_audio::sfx_distant_explo( breach_script_org_far );
	intro_explosions = 5;
	wait 4;
	while ( intro_explosions > 0)
	{
		wait RandomFloatRange (6,15);
		thread maps\odin_audio::sfx_distant_explo( breach_script_org_far );
		intro_explosions = intro_explosions - 1;
	}
}

intro_trigger_dead_bodies_encounter1()
{
	thread spawn_and_fling_bodies ("intro_dead_bodies_room", (3744, -3744, 200));
}

spawn_and_fling_bodies (group_targetname, impulse_location)
{
	array_spawn_function_targetname( group_targetname, maps\odin_util::teleport_to_target );
	bodies_to_fling = GetEntArray( group_targetname, "targetname" );
	foreach ( spawner in bodies_to_fling )
	{
		guy = spawner StalinGradSpawn();
		if ( spawn_failed( guy ) )
		{
			iprintlnbold( "spawn failed" );
			return;
		}
		guy thread maps\_space_ai::enable_space();
		guy kill();
	}
		
	wait 1.2;
	physicsexplosionsphere ( (impulse_location), 1525, 1200, 1.5 );
}


//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
intro_cleanup( force_immediate_cleanup )
{
	// CHAD - disabling this while doing FOV tests!!!
	// Return FoV to normal
	//SetSavedDvar( "cg_fov", 65 );
}

script_shuttle_docking_dvar_stuff()
{
	thread script_airlock01_lights();
	dvar_state = getdvarint( "shuttle_dock" );

    // Loop every frame, check the dvar for changes
    while( 1 )
    {
        // Did the dvar change?
        if( getdvarint( "shuttle_dock" ) != dvar_state )
        {
            // Update the local one so we can track when it changes again
            dvar_state = getdvarint( "shuttle_dock" );

            // The dvar changed!  Do your plane script
           	thread script_shuttle_docking();
            IPrintLnBold ("justin rules");
        }
        wait 0.1;
    }

}
script_shuttle_docking()
{
	
	if( getdvarint ( "shuttle_dock" ) == 0 )
	{
		script_brushmodel_crashing_shuttle00 = get_target_ent( "script_brushmodel_crashing_shuttle00" );
		script_brushmodel_crashing_shuttle00 hide();
		script_brushmodel_crashing_shuttle = get_target_ent( "script_brushmodel_crashing_shuttle" );
		script_brushmodel_crashing_shuttle hide();
		script_brushmodel_docking_shuttle = get_target_ent( "script_brushmodel_docking_shuttle" );
		script_brushmodel_docking_shuttle hide();
		script_brushmodel_docking_shuttle04 = get_target_ent( "script_brushmodel_docking_shuttle04" );
		script_brushmodel_docking_shuttle04 hide();
		
	
		script_brushmodel_docking_shuttle02 = get_target_ent( "script_brushmodel_docking_shuttle02" );
		script_brushmodel_docking_shuttle02 show();
	
		vehicle_empty_docking_shuttle02 = GetEnt ( "vehicle_empty_docking_shuttle02", "targetname" );
		script_brushmodel_docking_shuttle02 LinkTo( vehicle_empty_docking_shuttle02 );
	
		node_start_docking_shuttle02 = GetVehicleNode ( "node_start_docking_shuttle02", "targetname" );	
		
		vehicle_empty_docking_shuttle02 AttachPath ( node_start_docking_shuttle02 );
	
		vehicle_empty_docking_shuttle02 gopath();

	}
	                                
	if( getdvarint ( "shuttle_dock" ) == 1 )
	{
		script_brushmodel_crashing_shuttle00 = get_target_ent( "script_brushmodel_crashing_shuttle00" );
		script_brushmodel_crashing_shuttle00 hide();
		script_brushmodel_crashing_shuttle = get_target_ent( "script_brushmodel_crashing_shuttle" );
		script_brushmodel_crashing_shuttle hide();
		script_brushmodel_docking_shuttle02 = get_target_ent( "script_brushmodel_docking_shuttle02" );
		script_brushmodel_docking_shuttle02 hide();
		script_brushmodel_docking_shuttle04 = get_target_ent( "script_brushmodel_docking_shuttle04" );
		script_brushmodel_docking_shuttle04 hide();
	
		script_brushmodel_docking_shuttle = get_target_ent( "script_brushmodel_docking_shuttle" );
		script_brushmodel_docking_shuttle show();	
		
		vehicle_empty_docking_shuttle = GetEnt ( "vehicle_empty_docking_shuttle", "targetname" );
		script_brushmodel_docking_shuttle LinkTo( vehicle_empty_docking_shuttle );
	
		node_start_docking_shuttle = GetVehicleNode ( "node_start_docking_shuttle", "targetname" );	
		
		vehicle_empty_docking_shuttle AttachPath ( node_start_docking_shuttle );
	
		vehicle_empty_docking_shuttle gopath();
		

	}
	
	if( getdvarint ( "shuttle_dock" ) == 2 )
	{
		script_brushmodel_crashing_shuttle00 = get_target_ent( "script_brushmodel_crashing_shuttle00" );
		script_brushmodel_crashing_shuttle00 hide();
		script_brushmodel_crashing_shuttle = get_target_ent( "script_brushmodel_crashing_shuttle" );
		script_brushmodel_crashing_shuttle hide();
		script_brushmodel_docking_shuttle = get_target_ent( "script_brushmodel_docking_shuttle" );
		script_brushmodel_docking_shuttle hide();
		script_brushmodel_docking_shuttle02 = get_target_ent( "script_brushmodel_docking_shuttle02" );
		script_brushmodel_docking_shuttle02 hide();
	
		script_brushmodel_docking_shuttle04 = get_target_ent( "script_brushmodel_docking_shuttle04" );
		script_brushmodel_docking_shuttle04 show();
		
		vehicle_empty_docking_shuttle04 = GetEnt ( "vehicle_empty_docking_shuttle04", "targetname" );
		script_brushmodel_docking_shuttle04 LinkTo( vehicle_empty_docking_shuttle04 );
	
		node_start_docking_shuttle04 = GetVehicleNode ( "node_start_docking_shuttle04", "targetname" );	
		
		vehicle_empty_docking_shuttle04 AttachPath ( node_start_docking_shuttle04 );
	
		vehicle_empty_docking_shuttle04 gopath();
	}
}

script_airlock01_lights()
{
	wait 5;
	
	thread maps\odin_fx::fx_odin_airlock01_lights_setup();
		
}

player_recoil()
{
	
}


