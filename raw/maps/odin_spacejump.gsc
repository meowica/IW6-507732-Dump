#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;


spacejump_start()
{
	maps\odin_util::move_player_to_start_point( "start_odin_spacejump" );
	
	wait 0.1;
	
	maps\odin_util::actor_teleport( level.ally, "odin_spacejump_ally_tp" );

	// Make sure the satellite is far away before we get to spacejump
	//thread maps\odin_satellite::satellite_move_to( "satellite_far_org", 0.1 );

	// Unhide all the jump geo
	thread maps\odin_spacejump::safe_hide_spacejump( true );

	// Init the satellite rotation
	sat = maps\odin_satellite::satellite_get_script_mover();
	sat rotateRoll( 180, 0.1 );

	// Move the earth and satellite to correct positions
	thread Earth_and_Satellite_final_position();


//	//CHAD - removing for new test
//	// Setup the doors
//	thread maps\odin_util::create_sliding_space_door( "odin_spacejump_entrance_door", 1.2, 0.1, 0, false, "spacejump_player_in_airlock" );
//	thread maps\odin_util::create_sliding_space_door( "odin_spacejump_entrance_door_alt", 1.2, 0.1, 0.4, false, "spacejump_player_in_airlock" );

	//level.player thread damage_player_suit_player( undefined, "landed_on_satellite");

	thread maps\odin_intro::tweak_off_axis_player();
	flag_set( "clear_to_tweak_player" );

}

section_precache()
{
}

section_flag_init()
{
	flag_init( "trigger_spacejump" );
	flag_init( "player_may_now_shoot_glass" );
	flag_init( "player_started_spacejump" );
	flag_init( "player_reaches_satellite" );
	flag_init( "landed_on_satellite" );
	flag_init( "spacejump_clear" );
}

section_hint_string_init()
{
}


//================================================================================================
//	MAIN
//================================================================================================
spacejump_main()
{
	//iprintlnbold( "Spacejump Checkpoint Begin" );

	// Save
	thread autosave_by_name( "spacejump_begin" );

	//thread getting the satllite firing
	//thread maps\odin_satellite::ROD_assembly_setup();

	//thread spacejump_player_triggered();
	thread spacejump_start_jump();
	//thread player_shoots_window();
	
	// Ally movement
	//thread spacejump_ally_logic();

	// Main dialog thread
	thread spacejump_dialogue();

	// NOTE - this is now being done earlier
	// Spin the earth
	//thread Earth_and_Satellite_final_position();

	// Debris field
	thread do_small_debris();
	thread do_large_debris();

	flag_wait( "spacejump_clear" );
	//iprintlnbold( "SpaceJump Checkpoint Clear" );
}

spacejump_setup()
{
}

spacejump_dialogue()
{
	flag_wait( "begin_firing_bogus_rods" );
//	//Kyra: So this is the part you won’t like…
//	smart_radio_dialogue( "odin_kyr_sothisisthe" );
	//Kyra: There's the Kinetic ROD firing platform. We can’t stop it from here, so this is a one way trip Bud…
	smart_radio_dialogue( "odin_kyr_theresthekineticrod" );
	//Kyra: No! The first salvo is already firing! We have to stop it before the Firing Platform can fire any more…
	smart_radio_dialogue( "odin_kyr_nothefirstsalvo" );
	//Kyra: They just hit San Diego… Arizona… Florida…
	smart_radio_dialogue( "odin_kyr_theyjusthitsan" );
//	//Kyra: I'll blow the front hatch and the decompression will fire us over.
//	smart_radio_dialogue( "odin_kyr_illblowthefront" );
//	//Kyra: I hope…
//	smart_radio_dialogue( "odin_kyr_ihope" );
//	//Kyra: Ok…
//	smart_radio_dialogue( "odin_kyr_ok" );
//	//Kyra: Ready…
//	smart_radio_dialogue( "odin_kyr_ready" );
//	//Kyra: 3…
//	smart_radio_dialogue( "odin_kyr_3" );
//	wait .8;
//	//Kyra: 2…
//	smart_radio_dialogue( "odin_kyr_2" );
//	wait .8;
//	//Kyra: 1…
//	smart_radio_dialogue( "odin_kyr_1" );
//	wait .8;
//	flag_set( "player_may_now_shoot_glass" );
	flag_wait( "trigger_spacejump" );
//	wait 1.2;
	//Kyra: Hold on!!!!
	smart_radio_dialogue( "odin_kyr_holdon" );
//	wait 2;
//	//Kyra: We cannot let them fire the second salvo
//	smart_radio_dialogue( "odin_kyr_wecannotletthem" );
	//Kyra: Ok, Bud… here it comes!
	smart_radio_dialogue( "odin_kyr_okbudhereit" );
//	//Kyra: Argh!
//	smart_radio_dialogue( "odin_kyr_argh_2" );
//	//Kyra: Hold on!
//	smart_radio_dialogue( "odin_kyr_holdon_2" );
}

// Ally movement
spacejump_ally_logic()
{
	// Give ally a start position
	maps\odin_util::safe_trigger_by_targetname( "spacejump_ally_entry" );

	wait 1.0;

	// Move to window
	maps\odin_util::safe_trigger_by_targetname( "spacejump_ally_window" );
}

// Player initiated spacejump by pressing X
spacejump_player_triggered()
{
	flag_wait ( "spacejump_player_in_airlock" );
	level thread autosave_now();
	IPrintLnBold( "Press X to Decompress Room" );
	while ( true )
	{
		if ( level.player ButtonPressed( "BUTTON_X" ) )
		{
			iprintlnbold( "Space Jump Go" );
			flag_set( "trigger_spacejump" );
			return;
		}
		wait 0.1;
	}
}

// Does the spacejump once it is triggered.
spacejump_start_jump()
{
	iprintlnbold( "Holding for Space Jump" );
	wait 14;
	iprintlnbold( "Doing Space Jump" );
	thread spacejump_causal_FX();
	wait 1.5;
	flag_set( "trigger_spacejump" );
	//flag_wait ( "trigger_spacejump" );
	level thread autosave_now();
	//iprintlnbold( "Space Jump Go" );
//	delayThread( 5.0, maps\odin_satellite::satellite_move_to, "satellite_close_org", 10, 0.1, 3.0 );

	// Play the ally jump anim
//	level.ally thread maps\odin_anim::odin_spacejump_ally();
//	level.player thread maps\odin_anim::odin_spacejump_player();
	end_spin_fly_to_satellite();

	//thread script_do_space_jump();
}

spacejump_causal_FX()
{
	PlayFX( getfx( "airstrip_explosion" ), (level.player.origin + (-100,-100,0)) );
	wait 0.5;
	PlayFX( getfx( "airstrip_explosion" ), (level.player.origin + (100,-100,0)) );
}

end_spin_fly_to_satellite()
{
	//flag_wait( "start_near_explosion_sequence" );
	IPrintLnBold ("end_spin_fly_to_satellite");
	EarthQuake( 0.6, 5, level.player.origin, 500 );
	thread maps\odin_spin::spin_player_during_decomp( 4 );
	level.player thread damage_player_suit_player( undefined, "landed_on_satellite");
	level.player playsound( "scn_odin_pod_explosion" );
	CurrentX = -20000;
	CurrentY = 0;
	CurrentZ = 0;
	FX_Wait = 0;
	DesriredLoc = GetEnt( "satellite_traversal" , "script_noteworthy" );

	while (level.player.origin[0] > DesriredLoc.origin[0])
	{
		DesiredCurrentY = (DesriredLoc.origin[1] - level.player.origin[1])*2000;
		DesiredCurrentZ = (DesriredLoc.origin[2] - level.player.origin[2])*2000;
		if (DesiredCurrentY < CurrentY)
			CurrentY = CurrentY - abs(DesiredCurrentY)*.5;
		else
			CurrentY = CurrentY + abs(DesiredCurrentY)*.5;
		
		if (DesiredCurrentZ < CurrentZ)
			CurrentZ = CurrentZ - abs(DesiredCurrentZ)*.5;
		else
			CurrentZ = CurrentZ + abs(DesiredCurrentZ)*.5;

		//if (CurrentX > -20000)
		//	CurrentX=CurrentX - 1000;

		if ( CurrentY > 20000)
			CurrentY=20000;
		if ( CurrentY < -20000)
			CurrentY=-20000;
		if ( CurrentZ > 20000)
			CurrentZ=20000;
		if ( CurrentZ < -20000)
			CurrentZ=-20000;
		
		SetSavedDvar( "player_swimWaterCurrent" , ( CurrentX, CurrentY , CurrentZ ) );
		//IPrintLnBold ("CurrentX="+CurrentX+"CurrentY="+CurrentY+", CurrentZ="+CurrentZ);
		wait 0.05;
	}
	// stop player movement and satellite movement
	flag_set( "player_reaches_satellite" );
	SetSavedDvar( "player_swimWaterCurrent" , ( 0, 0 , 0 ) ); 
	flag_set( "landed_on_satellite" );
	flag_set( "spacejump_clear" );
}

//Set up the window shooting bit for the space jump.
player_shoots_window()
{
	clip = GetEnt( "space_jump_window_shoot_trig" , "targetname" );
	clip SetCanDamage( true );
	
	flag_wait( "player_may_now_shoot_glass" );
	IPrintLnBold( "Shoot the window out, Bud!" );
	
	clip waittill( "damage", amount, attacker, direction_vec, point, type );
	thread player_decompress_moment();
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
	wait 0.3;
	exploder("decomp_sat");
}

player_decompress_moment()
{
	flag_clear( "clear_to_tweak_player" );
	exploder("decomp_sat");
	level.player playsound( "scn_odin_pod_explosion" );
	EarthQuake( 0.6, 5, level.player.origin, 500 );
	thread maps\odin_spin::spin_player_during_decomp( 2 );
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 0, -2000 , 0 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 0, 12000 , -12000 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 15000, 0, 10000 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 15000, -10000 , 10000 ) ); 
	wait 0.3;
	level.player playsound( "scn_odin_pod_explosion" );
	SetSavedDvar( "player_swimWaterCurrent" , ( 15000, -20000 , 0 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 15000, 20000 , -20000 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 5000, 0 , 0 ) ); 
	//wait 2;
	level.player playsound( "scn_odin_pod_explosion" );
	wait 1;
	CurrentX = -3000;
	CurrentY = 0;
	CurrentZ = 0;
	while (level.player.origin[0] > -4360)
	{

		DesiredCurrentY = (-3607 - level.player.origin[1])*2000;
		DesiredCurrentZ = (-65745 - level.player.origin[2])*2000;
		if (DesiredCurrentY < CurrentY)
			CurrentY = CurrentY - abs(DesiredCurrentY)*.5;
		else
			CurrentY = CurrentY + abs(DesiredCurrentY)*.5;
		
		if (DesiredCurrentZ < CurrentZ)
			CurrentZ = CurrentZ - abs(DesiredCurrentZ)*.5;
		else
			CurrentZ = CurrentZ + abs(DesiredCurrentZ)*.5;

		if (CurrentX > -20000)
			CurrentX=CurrentX - 1000;

		if ( CurrentY > 20000)
			CurrentY=20000;
		if ( CurrentY < -20000)
			CurrentY=-20000;
		if ( CurrentZ > 20000)
			CurrentZ=20000;
		if ( CurrentZ < -20000)
			CurrentZ=-20000;
		
		SetSavedDvar( "player_swimWaterCurrent" , ( CurrentX, CurrentY , CurrentZ ) );
		//IPrintLnBold ("CurrentX="+CurrentX+"CurrentY="+CurrentY+", CurrentZ="+CurrentZ);
		wait 0.05;
	}
	//SetSavedDvar( "player_swimWaterCurrent" , ( -10000, 0 , 0 ) ); 
	//wait 1;
	//SetSavedDvar( "player_swimWaterCurrent" , ( 0, 0 , 0 ) ); 
	wait 1;
	flag_set( "clear_to_tweak_player" );
	flag_set( "trigger_spacejump" );
}

// FIXME - COPIED FROM TEST_SPACEJUMP
script_do_space_jump()
{
	//IPrintLnBold( "JUMPING!!!!!" );
	//flag_set("spacejump_decompression_01");
	//flag_set("space_jumping");
	//airlock_door = GetEnt ( "airlock_door", "script_noteworthy" );
	//airlock_door delete();
	//thread script_gettostation_objective();
	wait 0.1;
	travel_time = 15;
    new_model = spawn_tag_origin();
	new_model.origin = level.player.origin;
	new_model.angles = (0, 0, 0);
	movementY = 0;
	movementZ = 0;
	lag_movementY = 0;
	lag_movementZ = 0;

	while ( travel_time > 0 )
	{
		new_model.origin = level.player.origin - ( 50, 0, 0 );
		/*
		// ADJUST FOR PLAYER LOOKING
		view_angles = level.player getplayerangles();
		movementY = view_angles[1]*0.005;
		if (movementY > 15)
			movementY = 15;
		if (movementY < -15)
			movementY = -15;

		//if (lag_movementY > 15)
		//	lag_movementY = 15;
		//if (lag_movementY < -15)
		//	lag_movementY = -15;

		if (lag_movementY > movementY)
			lag_movementY = lag_movementY - 2.0;
		if (lag_movementY < movementY)
			lag_movementY = lag_movementY + 2.0;
		//new_model.origin = new_model.origin + ( 0, movementY, 0 );
		new_model.origin = new_model.origin + ( 0, lag_movementY, 0 );
			
		movementZ = (0 - view_angles[0]*0.005);
		if (movementZ > 15)
			movementZ = 15;
		if (movementZ < -15)
			movementZ = -15;

		//lag_movementZ = lag_movementZ + movementZ*0.5;

		//if (lag_movementZ > 15)
		//	lag_movementZ = 15;
		//if (lag_movementZ < -15)
		//	lag_movementZ = -15;

		if (lag_movementZ > movementZ)
			lag_movementZ = lag_movementZ - 2.0;
		if (lag_movementZ < movementZ)
			lag_movementZ = lag_movementZ + 2.0;
		//new_model.origin = new_model.origin + ( 0, 0, movementZ );
		new_model.origin = new_model.origin + ( 0, 0, lag_movementZ );
		*/

		// SET NEW PLAYER LOCATION
		level.player setOrigin( new_model.origin );

		// Hack to move ally also - this needs to be an anim!
		//level.ally ForceTeleport( new_model.origin + ( -200, -50, 0 ), (0,145,210));

		//level.player.origin = new_model.origin;
		EarthQuake( randomFloatRange( travel_time*0.01, travel_time*0.015 ), randomFloatRange( 0.05, 0.08 ), level.player.origin, 500 );
		travel_time = travel_time - 0.05;
		//IPrintLnBold (travel_time );
		wait 0.01;
	}
	wait 2.0;
	flag_set( "landed_on_satellite" );
	flag_set( "spacejump_clear" );
}

// FIXME - COPIED FROM TEST_SPACEJUMP
do_small_debris()
{
	rotate_debris( "script_brushmodel_debris_small01", "origin_debris_small01", (7060, 0,1760), 120 );
	rotate_debris( "script_brushmodel_debris_small02", "origin_debris_small02", (-60, 20000, -2760), 120 );
	rotate_debris( "script_brushmodel_debris_small03", "origin_debris_small03", (2000, -1060, 25000), 120 );
	rotate_debris( "script_brushmodel_debris_small04", "origin_debris_small04", (-13009, 0, 25760), 120 );
	rotate_debris( "script_brushmodel_debris_small05", "origin_debris_small05", (25000, 0, -12760), 120 );
	rotate_debris( "script_brushmodel_debris_small06", "origin_debris_small06", (13060, 0, 31760), 120 );	
	rotate_debris( "script_brushmodel_debris_small07", "origin_debris_small07", (-60, 26060, -2760), 120 );
	rotate_debris( "script_brushmodel_debris_small08", "origin_debris_small08", (24000, -1060, 18000), 120 );
	rotate_debris( "script_brushmodel_debris_small09", "origin_debris_small09", (-16009, 0, 25760), 120 );
	rotate_debris( "script_brushmodel_debris_small10", "origin_debris_small10", (35000, 0, -22760), 120 );
	rotate_debris( "script_brushmodel_debris_small11", "origin_debris_small11", (360, 15000, 0), 120 );
	rotate_debris( "script_brushmodel_debris_small12", "origin_debris_small12", (18000, 0, -4760), 120 );
	rotate_debris( "script_brushmodel_debris_small13", "origin_debris_small13", (25060, 0,21760), 120 );
	rotate_debris( "script_brushmodel_debris_small14", "origin_debris_small14", (-60, 23060, -17760), 120 );
	rotate_debris( "script_brushmodel_debris_small15", "origin_debris_small15", (2000, -1060, 5000), 120 );
	rotate_debris( "script_brushmodel_debris_small16", "origin_debris_small16", (-26009, 0, 22760), 120 );
	rotate_debris( "script_brushmodel_debris_small17", "origin_debris_small17", (-26009, 0, 22760), 120 );
	rotate_debris( "script_brushmodel_debris_small18", "origin_debris_small18", (-13009, 0, 12760), 120 );
	rotate_debris( "script_brushmodel_debris_small19", "origin_debris_small19", (5000, 0, -2760), 120 );
	rotate_debris( "script_brushmodel_debris_small20", "origin_debris_small20", (20360, 5000, 10000), 120 );
	rotate_debris( "script_brushmodel_debris_small21", "origin_debris_small21", (5000, 0, -2760), 120 );
	rotate_debris( "script_brushmodel_debris_small22", "origin_debris_small22", (25060, 0,21760), 120 );
	rotate_debris( "script_brushmodel_debris_small23", "origin_debris_small23", (-60, 23060, -17760), 120 );
	rotate_debris( "script_brushmodel_debris_small24", "origin_debris_small24", (2000, -1060, 5000), 120 );
	rotate_debris( "script_brushmodel_debris_small25", "origin_debris_small25", (-26009, 0, 22760), 120 );
	rotate_debris( "script_brushmodel_debris_small26", "origin_debris_small26", (25000, 0, -22760), 120 );
	rotate_debris( "script_brushmodel_debris_small27", "origin_debris_small27", (-13009, 0, 12760), 120 );
	rotate_debris( "script_brushmodel_debris_small28", "origin_debris_small28", (360, 15000, 0), 120 );
	rotate_debris( "script_brushmodel_debris_small29", "origin_debris_small29", (360, 15000, 0), 120 );
	rotate_debris( "script_brushmodel_debris_small30", "origin_debris_small30", (360, 15000, 0), 120 );
}

// FIXME - COPIED FROM TEST_SPACEJUMP
do_large_debris()
{
	rotate_debris( "script_brushmodel_debris_still01", "origin_debris_still01", (0, 640,2520), 120 );
	rotate_debris( "script_brushmodel_debris_crate_still01", "origin_debris_crate_still01", (2520, 0,2520), 120 );
	rotate_debris( "script_brushmodel_debris_crate_still02", "origin_debris_crate_still02", (0, 0,2520), 120 );
	rotate_debris( "script_brushmodel_debris_crate_still03", "origin_debris_crate_still03", (0, 0,2520), 120 );
	rotate_debris( "script_brushmodel_debris_crate_still04", "origin_debris_crate_still04", (0, 2520,0), 120 );
	//rotate_debris( "script_brushmodel_debris_large02", "origin_debris_large02", (1260, 0,2260), 60 );
}


// Rotate a single debris
rotate_debris( brush_name, org_name, rotate, time )
{
	brush = get_target_ent( brush_name );
	org = GetEnt ( org_name, "targetname" );

	if(!isDefined( brush ) || !isDefined( org ))
	{
		iprintln( "rotate_debri failed: " + brush_name );
		return;
	}

	brush LinkTo( org );
	org rotateby(rotate, time, 0, 0 );
}


Earth_and_Satellite_final_position()
{
	newNode = GetEnt( "spin_skybox_rotator2" , "targetname" );
	space = getEnt( "space_mover" , "targetname" );
	earthA = GetEnt( "earth_mover_0" , "targetname" );
	//earth_rotate_speed = 17.5;
	earth_rotate_speed = 2.5;
	
	if( !flag( "earth_drop" ) )
	{
		earthA MoveZ( -65000 , .05 , 0 , 0 );	
	}
	wait .25;
	
	end_orientation = 180; // Change this to change where the Earth ends up
	
	//flag_wait( "player_started_spacejump" );
	
	//Gonna do some math to determine how far we need to go to match the Odin orientation
	origin = GetEnt( "spin_skybox_rotator" , "targetname" );
	//origin_angles = 0;
	origin_angles = origin.angles[2];
	
	if( origin_angles <= 0 )
	{
		origin_angles = origin_angles + 360 ;
	}
	
	// Safety check
	if( !isDefined( space ))
	{
		return;
	}
	// Safety check
	if( !isDefined( earthA ))
	{
		return;
	}
	earthA Unlink();
	space Unlink();
	
	earthA linkto( newNode );
	space LinkTo( newNode );
	
	if( (origin_angles + end_orientation) > 360) 
	{
		spin_amount = (origin_angles + end_orientation) - 360;	
	}
	else
	{
		spin_amount = (origin_angles + end_orientation);
	}
	
	//iprintlnbold( "spin amount: " + spin_amount );
	newNode RotateRoll( 0 - spin_amount , earth_rotate_speed , 0 , earth_rotate_speed*0.7 );
	//thread earth_move_with_player( newNode );

	// Animate the satellite moving, also rotate it the same amount as the earth
	sat = maps\odin_satellite::satellite_get_script_mover();
	sat thread maps\odin_anim::odin_spacejump_satellite( spin_amount, earth_rotate_speed );

	wait earth_rotate_speed;
	//thread Play_ROG_Hit_FX_On_Earth(); // being done separately
	//newNode RotatePitch( -10 , earth_rotate_speed , earth_rotate_speed*0.4 , earth_rotate_speed*0.4 );
	//wait earth_rotate_speed;

	// Unlink the satellite
	newNode Unlink();
	// moving the satellite toward the player until they touch
	while (!flag ("player_reaches_satellite"))
	{
		sat MoveX (100,0.1);
		wait 0.1;
	}
	thread maps\odin_satellite::spin_blade_node();
	
	wait 2.25;
	// setup the ROGs to fire
	// thread maps\odin_satellite::ROD_assembly_setup();
	
	//wait 14;
	// Play FX of Earth being hit
	flag_wait( "trigger_spacejump" );
	//thread Play_ROG_Hit_FX_On_Earth();
}

earth_move_with_player( newNode )
{
	newNode MoveTo( ( -20000 , -3603 , newNode.origin[2] ) , 15 , 0 , 0 );
}

/*
damage_hud()
{
	level endon( "end_clear" );
	while(1)
	{
		if ( IsDefined( self.hud_space_helmet_overlay ) )
		{
			//IPrintLnBold ("off");
			self.hud_space_helmet_overlay destroyElem();
		}
		wait RandomFloatRange (0.05,0.6);
		//IPrintLnBold ("on");
		self.hud_space_helmet_overlay = self create_client_overlay( "hud_xm25_temp", 0.1, self );
		self.hud_space_helmet_overlay.foreground = false;
		self.hud_space_helmet_overlay.sort = -99;
		wait RandomFloatRange (0.05,0.06);
	}
}
*/

damage_player_suit_rig()
{
	wait 1;
	//IPrintLnBold ("Oh no, Bud! Your rig suit is damaged! You're venting gasses!");
	model1 = Spawn( "script_model", (0,0,0) );
	model1 SetModel( "tag_origin" );
	model1 LinkTo( self, "tag_weapon_right", ( 0, 0, 25 ), ( 0, 0, -1 ) );
	wait 3;
	PlayFXOnTag( getfx( "steam_pipe_burst" ), model1, "tag_origin" ); // cool for initial hit
	thread damage_suit_fx_loop( model1, "swim_ai_death_blood", 9.0, 15.0, "satellite_traversal_done" );
	thread damage_suit_fx_loop( model1, "space_jet_small", 1.0, 3.0, "satellite_traversal_done" );
	thread damage_suit_fx_loop( model1, "circuit_breaker", 5.0, 10.0, "satellite_traversal_done" );
	PlayFXOnTag( getfx( "steam_jet_loop" ), model1, "tag_origin" ); // cool for initial hit
	flag_wait ("satellite_traversal_done");
	model1 Delete();
}

damage_player_suit_player( start_flag, end_flag )
{
	if (IsDefined ( start_flag ))
		flag_wait (start_flag);
	//IPrintLnBold ("damage_player_suit_player");
	// level.player thread damage_hud();
	model1 = Spawn( "script_model", (0,0,0) );
	model1 SetModel( "tag_origin" );
	model1 LinkToPlayerView( self, "j_thumb_le_0", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
	PlayFXOnTag( getfx( "steam_pipe_burst" ), model1, "tag_origin" ); // cool for initial hit
	thread damage_suit_fx_loop( model1, "swim_ai_death_blood", 9.0, 15.0, end_flag);
	thread damage_suit_fx_loop( model1, "space_jet_small", 1.0, 3.0, end_flag);
	wait 1;
	thread damage_suit_fx_loop( model1, "circuit_breaker", 5.0, 10.0, end_flag);
	PlayFXOnTag( getfx( "factory_roof_steam_small_01" ), model1, "tag_origin" ); // ok once a lot of damage has occured
	flag_wait (end_flag);
	model1 Delete();
}

damage_suit_fx_loop( link_model, fx, min_time, max_time, end_flag )
{
	if (IsDefined (end_flag))
		level endon( end_flag );
	while (1)
	{
		PlayFXOnTag( getfx( fx ), link_model, "tag_origin" );
		wait RandomFloatRange (min_time, max_time);
	}
}

Play_ROG_Hit_FX_On_Earth()
{
	level endon( "trigger_spacejump" );
	//IPrintLnBold ("Play_ROG_Hit_FX_On_Earth");
	//wait 2;
	//newNode = GetEnt( "spin_skybox_rotator2" , "targetname" );
	flag_wait("EarthSetupComplete");
	origin = GetEnt( "spin_skybox_rotator" , "targetname" );
    new_model1 = spawn_tag_origin();
    new_model1.origin = (-50339, 10137, -60973);
	new_model1 LinkTo(origin);
    new_model2 = spawn_tag_origin();
    new_model2.origin = (-43729, 64, -59470);
	new_model2 LinkTo(origin);
	//wait_for_flag_or_time_elapses ("trigger_spacejump",10);
	new_model = new_model1;
	while (1)
	{
		randomVFX = RandomIntRange( 1 , 5 );
		//IPrintLnBold (randomVFX);
		switch ( randomVFX )
		{
			case 1:
				//IPrintLnBold ("case 1");
				new_model = new_model1;
				break;
			case 2:
				//IPrintLnBold ("case 2");
				new_model = new_model2;
				break;
		}
		thread fire_bogus_rod (new_model);
		wait 15;
	}
	/*
    new_model.origin = newNode.origin;
	new_model.angles = newNode.angles;
	new_model.origin = ( new_model.origin + (-20000, -4000, -5700) );
	while (1)
    {
		ROG_Hit_Location = ( new_model.origin + (RandomFloatRange(-2000, 500), RandomFloatRange(-900, 900), 0) );
		thread Create_ROG_Hit_Effect( ROG_Hit_Location );
		wait RandomFloatRange(1.9, 3.5);
		if (new_model.origin[0] < -12000)
			new_model.origin = ( new_model.origin + (RandomIntRange(2000,4000), RandomIntRange(1000,2000), 0) );
		else
			break;
    }
	*/    
}

fire_bogus_rod(Hit_Loc)
{
	//level endon( "trigger_spacejump" );
	bogus_rog = spawn_tag_origin();
	fire2 = GetEnt( "firing_position_1" , "script_noteworthy" );		//Top of the "barrel" of THOR
	bogus_rog.origin = fire2.origin;
	origin = GetEnt( "spin_skybox_rotator" , "targetname" );
	bogus_rog LinkTo(origin);
	PlayFXOnTag( level._effect[ "rog_flash_odin" ], bogus_rog, "tag_origin" );
	wait 2;
	PlayFXOnTag( level._effect[ "ac130_smoke_geotrail_missile_large" ], bogus_rog, "tag_origin" );
    moving_target = spawn_tag_origin();
	fire3 = GetEnt( "firing_position_2" , "script_noteworthy" );		//Target of the ROD.  ROD deletes upon reaching	
    moving_target.origin = fire3.origin;
	bogus_rog Unlink();
	rog_time=0.5;
	while (rog_time<10)
	{
		bogus_rog MoveTo( moving_target.origin, 3 );
		rog_time = rog_time + 1;
		wait 0.05;
	}
	while (rog_time<150)
	{
		moving_target MoveTo (Hit_Loc.origin, 1 );
		bogus_rog MoveTo( moving_target.origin, 3 );
		rog_time = rog_time + 1;
		wait 0.05;
	}
	StopFXOnTag( level._effect[ "ac130_smoke_geotrail_missile_large" ], bogus_rog, "tag_origin" );
	bogus_rog Delete();
	wait 3;
	PlayFXOnTag( level._effect[ "rog_flash_odin" ], Hit_Loc, "tag_origin" );
	PlayFXOnTag( level._effect[ "rog_shockwave_odin" ], Hit_Loc, "tag_origin"  );
	wait 0.5;
	PlayFXOnTag( level._effect[ "rog_ambientfire_odin" ], Hit_Loc, "tag_origin"  );
	PlayFXOnTag( level._effect[ "airstrip_explosion" ], Hit_Loc, "tag_origin"  );
	wait RandomFloatRange(0.1,0.5);
	PlayFXOnTag( level._effect[ "airstrip_explosion" ], Hit_Loc, "tag_origin"  );
	wait RandomFloatRange(0.1,0.5);
	PlayFXOnTag( level._effect[ "airstrip_explosion" ], Hit_Loc, "tag_origin"  );
	wait RandomFloatRange(0.1,0.5);
	PlayFXOnTag( level._effect[ "airstrip_explosion" ], Hit_Loc, "tag_origin" );
}


Create_ROG_Hit_Effect( R_FX_Loc )
{
		PlayFX( level._effect[ "rog_flash_odin" ], R_FX_Loc, (1,0,0), (0,0,1) );
		PlayFX( level._effect[ "rog_shockwave_odin" ], R_FX_Loc, (1,0,0), (0,0,1) );
		wait 0.5;
		PlayFX( level._effect[ "rog_ambientfire_odin" ], R_FX_Loc, (1,0,0), (0,0,1) );
		PlayFX( level._effect[ "airstrip_explosion" ], R_FX_Loc + (RandomFloatRange(-900, 900), RandomFloatRange(-900, 900),-200), (1,0,0), (0,0,1) );
		wait RandomFloatRange(0.1,0.5);
		PlayFX( level._effect[ "airstrip_explosion" ], R_FX_Loc + (RandomFloatRange(-900, 500), RandomFloatRange(-900, 900),-200), (1,0,0), (0,0,1) );
		wait RandomFloatRange(0.1,0.5);
		PlayFX( level._effect[ "airstrip_explosion" ], R_FX_Loc + (RandomFloatRange(-900, 900), RandomFloatRange(-900, 900),-200), (1,0,0), (0,0,1) );
		wait RandomFloatRange(0.1,0.5);
		PlayFX( level._effect[ "airstrip_explosion" ], R_FX_Loc + (RandomFloatRange(-900, 900), RandomFloatRange(-900, 900),-200), (1,0,0), (0,0,1) );
		wait RandomFloatRange(0.1,0.5);
		wait 1;
		PlayFX( level._effect[ "wall_collapse_dust_wave_hamburg" ], R_FX_Loc, (1,0,0), (0,0,1) );
		wait 3;
		PlayFX( level._effect[ "rog_smoke_odin" ], R_FX_Loc, (1,0,0), (0,0,1) );
		while (1)
		{
			rog_roll_loop = RandomIntRange (7,15);
			while (rog_roll_loop > 0)
				{
				rndexp = RandomIntRange (0,8);
				switch (rndexp)
				{
					case 0:
					case 1:
						PlayFX( level._effect[ "wall_collapse_dust_wave_hamburg" ], R_FX_Loc + (RandomFloatRange(-900, 900), RandomFloatRange(-900, 900),0), (1,0,0), (0,0,1) );
					case 2:
					case 3:
						PlayFX( level._effect[ "rog_ambientfire_odin" ], R_FX_Loc + (RandomFloatRange(-900, 900), RandomFloatRange(-900, 900),0), (1,0,0), (0,0,1) );
						break;
					default:
						PlayFX( level._effect[ "airstrip_explosion" ], R_FX_Loc + (RandomFloatRange(-900, 900), RandomFloatRange(-900, 900),-200), (1,0,0), (0,0,1) );
						break;
				}
				rog_roll_loop = rog_roll_loop - 1;
				wait RandomFloatRange(0.3,5.0);
				//if (flag ( "landed_on_satellite" ) )
				//	break;
			}
			PlayFX( level._effect[ "rog_smoke_odin" ], R_FX_Loc + (RandomFloatRange(-900, 900), RandomFloatRange(-900, 900),0), (1,0,0), (0,0,1) );
			wait 1;
			if (flag ( "landed_on_satellite" ) )
				break;
		}
}

// Hide all the spacejump stuff untill we need it
safe_hide_spacejump( unhide )
{
	all_parts = [];
	more_parts = GetEntArray( "spacejump_hide", "script_noteworthy" );
	parts = array_combine( all_parts, more_parts );
		
	foreach( part in parts )
	{
		if( isDefined( part ))
		{
			if( isDefined( unhide ))
				part show();
			else
				part hide();
		}
	}
}

//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
spacejump_cleanup( force_immediate_cleanup )
{
}