#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


spin_start()
{
	maps\odin_util::move_player_to_start_point( "start_odin_spin" );

	// Move Ally to start point
	wait 0.1;
	maps\odin_util::actor_teleport( level.ally, "odin_spin_ally_tp" );
	thread maps\odin_intro::tweak_off_axis_player();
	flag_set( "clear_to_tweak_player" );
}

section_precache()
{
}

section_flag_init()
{
	flag_init( "EarthSetupComplete" );
	flag_init( "start_explosion_sequence" );
	flag_init( "start_near_explosion_sequence" );
	flag_init( "spin_start_dialogue" );
	flag_init( "increase_decompression" );
	flag_init( "spin_approaching_enemies" );
	flag_init( "spin_player_near_end" );
	flag_init( "spin_clear" );
	flag_init( "stop_spinning_room" );
	flag_init( "delete_spinning_room" );

	// Doors
	flag_init( "lock_spin_start" );
	flag_init( "unlock_spin_start" );
}

section_hint_string_init()
{
}


//================================================================================================
//	MAIN
//================================================================================================
spin_main()
{
	//iprintlnbold( "Spin Main" );
	
	thread maps\odin_spacejump::safe_hide_spacejump( true );
	thread rotating_earth();
	thread spin_ai_actions();
	// Save
	thread autosave_by_name( "spin_begin" );

	// Destruction Setup
	thread destruction_setup();

	// Colliding ObjectsSetup
	thread colliders_setup();
	
	// Checkpoint setup
	spin_setup();

	// Ally logic
	thread spin_ally_logic();

	// Spawn spinning room enemies
	spinning_room_enemies();

	// Start the spinning room geo
	thread spinning_room_geo();
	//thread spinning_room_debris();
	thread spinning_cover();
//	thread maps\odin_util::moving_cover_medium(); tagTJ: commenting out until ready for primetime

	// Dialogue thread
	thread spin_dialogue();

	// Explosions that cause spinning
	thread spin_start_moment();
	
	// Temp hack objective marker
	thread spinning_room_temp_objective();


	// Get the satellite setup correctly
	thread maps\odin_satellite::ROD_assembly_setup();
	// Halt to prevent auto fallthrough into next checkpoint
	flag_wait( "begin_firing_bogus_rods" );
	flag_set( "spin_clear" );

	flag_set( "stop_spinning_room" );
	
	// JR-TODO
	maps\odin_util::actor_teleport( level.ally, "odin_spacejump_ally_tp" );

	// Cleanup
	thread spin_cleanup();
}

// Checkpoint setup
spin_setup()
{
	// Setup door
	//thread maps\odin_util::create_sliding_space_door( "odin_spin_intro_door", 1.2, 0.1, 0, false, "lock_spin_start", "unlock_spin_start" );

	// Make sure the satellite is far away before we get to spacejump
	//thread maps\odin_satellite::satellite_move_to( "satellite_far_org", 0.1 );

	// Start broken door
	//thread spin_broken_door();

	// Allign the satellite with the earth
	sat = maps\odin_satellite::satellite_get_script_mover();
	sat rotateRoll( 180, 0.1 );

//	//CHAD - removing for new test
//	// Setup the doors at the end of the spinning room
//	thread maps\odin_util::create_sliding_space_door( "odin_spacejump_entrance_door", 1.2, 0.1, 0, false, "spacejump_player_in_airlock" );
//	thread maps\odin_util::create_sliding_space_door( "odin_spacejump_entrance_door_alt", 1.2, 0.1, 0.4, false, "spacejump_player_in_airlock" );


}

spin_dialogue()
{
	flag_wait( "odin_escape_start_spinning_room" );
	flag_wait( "start_explosion_sequence" );
	flag_wait( "start_near_explosion_sequence" );
	//IPrintLnBold ("doing hard push!");
	//Kyra: Aargh!
	smart_radio_dialogue( "odin_kyr_argh_2" );

	flag_wait( "spin_start_dialogue" );
//	//Kyra: Oh no…
//	smart_radio_dialogue( "odin_kyr_ohno" );

	//Kyra: My god…
	smart_radio_dialogue( "odin_kyr_mygod" );
	//Kyra: Bud! They're not all dead! They're still heading to rod control!
	smart_radio_dialogue( "odin_kyr_budtheyrenotall" );
//	//Atlas Main: Be advised electrical is still hot, work your way around.
//	smart_radio_dialogue( "odin_atl_beadvisedelectricalis" );
//	//Kyra: Screw that, it’s the fastest way to rod control.  Bud, let’s go.
//	smart_radio_dialogue( "odin_kyr_screwthatitsthe" );



//	//Kyra: We're floating away from the Firing Platform.
//	smart_radio_dialogue( "odin_kyr_werefloatingawayfrom" );
//	//Kyra: If we're going to stop the firing sequence, we need to go through this…
//	smart_radio_dialogue( "odin_kyr_ifweregoingto" );
//	//Kyra: Main Observation should be ahead of this mess.
//	smart_radio_dialogue( "odin_kyr_mainobservationshouldbe" );
	flag_wait( "spin_approaching_enemies" );

//	//Kyra: We need to get to Main Observation!
//	smart_radio_dialogue( "odin_kyr_weneedtoget" );
	//Kyra: Bud! We've got some stragglers!
	smart_radio_dialogue( "odin_kyr_budwevegotsome" );
	flag_wait( "spin_player_near_end" );
//	//Kyra: Get inside! I'll repressurize!
//	smart_radio_dialogue( "odin_kyr_getinsideillrepressurize" );	
}

spin_ally_logic()
{
	// Temp because previous checkpoint doesnt handle the ally properly
	//iprintlnbold( "ally tp" );
	//maps\odin_util::actor_teleport( level.ally, "odin_spin_ally_tp" );
	//wait 1.0;
	//iprintlnbold( "ally move start" );
	//maps\odin_util::safe_trigger_by_targetname( "spin_ally_position_start" );

	//wait 1.0;

	//iprintlnbold( "ally move airlock" );

	// Move ally to first airlock door
	maps\odin_util::safe_trigger_by_targetname( "spin_ally_position_first_airlock" );

	flag_wait( "odin_escape_start_spinning_room" );

	// Teleport ally past the narrow spinning room - cant navigate via AI
	flag_wait( "begin_firing_bogus_rods" );

	maps\odin_util::actor_teleport( level.ally, "spin_ally_narrow_teleport" );
}

// Broken door goes back and forth
spin_broken_door()
{
	// Get the door model
	model = GetEnt( "spin_broken_door_model", "targetname" );
	brush = GetEnt( "spin_broken_door", "targetname" );

	brush LinkTo( model );

	while (  !flag( "stop_spinning_room" ))
	{
		dist = RandomFloatRange( 8, 21 );
		// Open

		model MoveY( dist * -1, 0.26, 0.1, 0.1 );
		model waittill( "movedone" );

		wait RandomFloatRange( 0.23, 1.1 );

		// Close
		model MoveY( dist, 0.26, 0.1, 0.1 );
		model waittill( "movedone" );

		wait RandomFloatRange( 0.75, 1.8 );

		wait 0.1;
	}

	model delete();
	brush delete();
}

destruction_setup()
{
	cracked_glass_01 = GetEntArray( "script_brushmodel_spin02_cracked_glass01", "targetname" );
	cracked_glass_02 = GetEntArray( "script_brushmodel_spin02_cracked_glass02", "targetname" );
	cracked_glass_03 = GetEntArray( "script_brushmodel_spin02_verycracked_glass01", "targetname" );
	cracked_glass_04 = GetEntArray( "script_brushmodel_spin02_verycracked_glass02", "targetname" );
	foreach( glass in cracked_glass_01 )
		glass hide();
	foreach( glass in cracked_glass_02 )
		glass hide();
	foreach( glass in cracked_glass_03 )
		glass hide();
	foreach( glass in cracked_glass_04 )
		glass hide();

	flag_wait( "odin_escape_start_spinning_room" );

	flag_set( "clear_to_tweak_player_forced" );
	SetSavedDvar( "player_swimWaterCurrent" , ( 3500, -2000, 0 ) ); 
	thread maps\odin_audio::sfx_odin_decompress();
	wait 0.3;
	exploder("pre_decomp_01");
	wait 0.3;
	wait 0.3;
	wait 0.2;
	wait 0.2;
	wait 0.2;
	wait 0.2;
	EarthQuake( 0.1, 3, level.player.origin, 500 );
	exploder("pre_decomp_02");
	wait 0.2;
	wait 0.2;
	foreach( glass in cracked_glass_01 )
		glass show();
	wait 0.3;
	foreach( glass in cracked_glass_02 )
		glass show();
	flag_set( "start_explosion_sequence" );
	wait 0.2;
	wait 0.2;
	exploder("pre_decomp_03");
	wait 0.4;
	wait 0.2;
	EarthQuake( 0.3, 3, level.player.origin, 500 );
	wait 0.2;
	foreach( glass in cracked_glass_03 )
		glass show();
	wait 0.2;
	exploder("decomp_01");
	exploder("post_explosion_damage");
	foreach( glass in cracked_glass_04 )
		glass show();
	wait 1;
	thread maps\odin_audio::sfx_odin_decompress_explode();
	wait 0.3;
	flag_set( "start_near_explosion_sequence" );
	thread airlock_break();
	

	flag_wait( "spin_start_dialogue" );
	//thread destruction_shuttle();
	//thread destruction_large_pieces_close_01();
	//thread destruction_large_pieces_close_02();
	//thread destruction_large_pieces_mid_01();
//	thread destruction_tiny_pieces();
	
}

destruction_large_pieces_close_01()
{
	satellite_piece = Spawn( "script_model", (0,0,0) );
	satellite_piece SetModel( "fac_satellite_part" );
	satellite_piece RotatePitch (90,0.1);
	satellite_piece MoveTo  ((-727, -3188, -65486), 0.1 );
	satellite_piece waittill ("movedone");
    satellite_piece_fx = spawn_tag_origin();
    satellite_piece_fx.origin = satellite_piece.origin;
    satellite_piece_fx LinkTo (satellite_piece);
	satellite_piece MoveTo ( (-697,-6754,-66445),30);
	satellite_piece RotateRoll (1720,30);
	wait 2;
	PlayFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], satellite_piece_fx, "tag_origin" );
	PlayFXOnTag( level._effect[ "smoke_geotrail_ssnmissile" ], satellite_piece_fx, "tag_origin" );
	satellite_piece waittill ("movedone");
	StopFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], satellite_piece_fx, "tag_origin" );
	StopFXOnTag( level._effect[ "smoke_geotrail_ssnmissile" ], satellite_piece_fx, "tag_origin" );
	satellite_piece_fx Delete();
	satellite_piece Delete();
}

destruction_large_pieces_close_02()
{
	station_piece = Spawn( "script_model", (0,0,0) );
	station_piece SetModel( "fac_satellite_part" );
	station_piece MoveTo  ((-530, -3074, -65800), 0.1 );
	station_piece waittill ("movedone");
    wait 3;
	station_piece_fx = spawn_tag_origin();
    station_piece_fx.origin = station_piece.origin;
    station_piece_fx LinkTo (station_piece);
	station_piece MoveTo ( (-1167,-3639,-65800),10);
	station_piece RotateYaw (170,10);
	PlayFXOnTag( level._effect[ "ac130_smoke_geotrail_missile_large" ], station_piece_fx, "tag_origin" );
	station_piece waittill ("movedone");
	station_piece MoveTo ( (-4482,-895,-65390),30);
	station_piece RotateRoll (-1130,30);
	station_piece waittill ("movedone");
	StopFXOnTag( level._effect[ "ac130_smoke_geotrail_missile_large" ], station_piece_fx, "tag_origin" );
	station_piece_fx Delete();
	station_piece Delete();
}

destruction_large_pieces_mid_01()
{
	wait 10;
	satellite_piece = Spawn( "script_model", (0,0,0) );
	satellite_piece SetModel( "fac_satellite_part" );
	satellite_piece RotatePitch (90,0.1);
	satellite_piece MoveTo  ((-1956, -5795, -65609), 0.1 );
	satellite_piece waittill ("movedone");
    satellite_piece_fx = spawn_tag_origin();
    satellite_piece_fx.origin = satellite_piece.origin;
    satellite_piece_fx LinkTo (satellite_piece);
	satellite_piece MoveTo ( (-1904,1637,-65972),50);
	satellite_piece RotatePitch (1020,50);
	PlayFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], satellite_piece_fx, "tag_origin" );
	satellite_piece waittill ("movedone");
	StopFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], satellite_piece_fx, "tag_origin" );
	satellite_piece_fx Delete();
	satellite_piece Delete();
}

destruction_shuttle()
{
	enemy_shuttle = GetEnt( "script_brushmodel_docking_shuttle02", "targetname" );
	if( IsDefined( enemy_shuttle ) )
	{
		enemy_shuttle MoveTo ( (-1937,-2971,-65607),0.1);
		enemy_shuttle waittill ("movedone");
	    enemy_shuttle_fx = spawn_tag_origin();
	    enemy_shuttle_fx.origin = enemy_shuttle.origin;
	    enemy_shuttle_fx LinkTo (enemy_shuttle);
		enemy_shuttle MoveTo ( (-22956,421,-59323),120);
		enemy_shuttle RotateYaw (1720,120);
		PlayFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], enemy_shuttle_fx, "tag_origin" );
		enemy_shuttle waittill ("movedone");
		StopFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], enemy_shuttle_fx, "tag_origin" );
		enemy_shuttle_fx Delete();
		enemy_shuttle Delete();
	}
	
}

destruction_tiny_pieces()
{
	flag_wait( "spin_approaching_enemies" );
	
	Exploder( "debris_ambient_particles" );
}

colliders_setup()
{
	flag_wait("spin_approaching_enemies");
	IPrintLnBold ("spin_approaching_enemies");
	flag_wait("vignette_move_ai");
	IPrintLnBold ("vignette_move_ai");
	flag_wait("spin_in_system_exit");
	IPrintLnBold ("spin_in_system_exit");
	flag_wait("begin_firing_bogus_rods");
	IPrintLnBold ("begin_firing_bogus_rods");
	flag_wait("spin_player_near_end");
	IPrintLnBold ("spin_player_near_end");
}

spin_start_moment()
{
	flag_wait( "start_near_explosion_sequence" );
	EarthQuake( 0.6, 5, level.player.origin, 500 );
	thread spin_player_during_decomp( 2 );
	//level.player thread maps\odin_spacejump::damage_player_suit_player( undefined, "landed_on_satellite");
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 0, -2000 , 0 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 0, 12000 , -12000 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 5000, 0, 20000 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 5000, -20000 , 20000 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 5000, -20000 , 0 ) ); 
	wait 0.3;
	SetSavedDvar( "player_swimWaterCurrent" , ( 5000, 20000 , -20000 ) ); 
	wait 1;
	SetSavedDvar( "player_swimWaterCurrent" , ( 0, 0 , 0 ) ); 
	CurrentX = -3000;
	CurrentY = 0;
	CurrentZ = 0;
	FX_Wait = 0;
	exploder("decomp_02");
	while (level.player.origin[0] > -540)
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
		FX_Wait = FX_Wait + 1;
		if (FX_Wait > 5)
		{
			exploder("decomp_02");
			FX_Wait = 0;
		}
		wait 0.05;
	}
	SetSavedDvar( "player_swimWaterCurrent" , ( -10000, 0 , 0 ) ); 
	wait 1;
	SetSavedDvar( "player_swimWaterCurrent" , ( 0, 0 , 0 ) ); 
}

spin_player_during_decomp( speed_number )
{
	flag_set( "clear_to_tweak_player_forced" );
	level.view_ref_ent RotateTo ((0,0,160), speed_number, 0.1, speed_number*0.4);
	level.view_ref_ent waittill ("rotatedone");
	level.view_ref_ent RotateTo ((0,0,0), 1, 0.5, 0);
	level.view_ref_ent waittill ("rotatedone");
	level.view_ref_ent RotateTo ((0,0,-90), 1, 0, 0.5);
	level.view_ref_ent waittill ("rotatedone");
	level.view_ref_ent RotateTo ((0,0,0), speed_number, speed_number*0.4, speed_number*0.4);
	level.view_ref_ent waittill ("rotatedone");
	flag_clear( "clear_to_tweak_player_forced" );
}

//================================================================================================
// Main geo mover for spinning room section
spinning_room_geo()
{
	level.spinning_room_parts = [];
	
	// Main room entrance debris																					
	level.spinning_room_parts["spin_in_system_entrance"] = room_swapper_create( "stunnel_grp01_entry", 60, 22, (0,0,10), "spin_in_system_entrance", true );
	level.spinning_room_parts["spin_in_system_main"] = room_swapper_create( "stunnel_grp03_big_int", -60, 14, (0,0,50), "spin_in_system_main" );
	level.spinning_room_parts["spin_in_system_exit"] = room_swapper_create( "stunnel_grp04_exit", -60, 22, (0,0,0), "spin_in_system_exit" );
	//level.spinning_room_parts["spin_in_system_narrow"] = room_swapper_create( "stunnel_narrow", -60, 22, (0,0,140), "spin_in_system_narrow" );

	// Run the system attach scripts to make sure we are attached to the correct moving system
	level.player.current_mover_system_name = "";
	thread room_swapper_transition_attacher();
	thread room_swapper_swap_attacher();

	// Attach lights to the main room spin org
	// JR-TODO - Clean this up
	if( isDefined( level.spinning_room_parts["main_room"] ))
	{
		lights = GetEntArray( "stunnel_grp03_door_light", "script_noteworthy" );
		fxName = "fx/misc/tower_light_red_steady";
		foreach( light in lights )
		{
			tag_origin = light spawn_tag_origin();
			tag_origin.origin = ( light.origin );
		    tag_origin LinkTo( level.spinning_room_parts["main_room"] );
		    PlayFXOnTag( level._effect[ "light_blue_steady_FX" ], tag_origin, "tag_origin" );
		}
	}

	// Start the spin
	//flag_wait( "start_spinning_room" );
	flag_wait( "odin_escape_start_spinning_room" );
	exploder ("spin02_airlock_breach_steam01");
	level.spinning_room_parts["spin_in_system_entrance"] thread room_swapper_start();
	level.spinning_room_parts["spin_in_system_main"] thread room_swapper_start();
	level.spinning_room_parts["spin_in_system_exit"] thread room_swapper_start();
	//level.spinning_room_parts["spin_in_system_narrow"] thread room_swapper_start();
	//thread attach_spinning_FX();
}
	
airlock_break()
{
	airlock = [];
	airlock = GetEntArray( "spin_airlock01" , "targetname" );	
	nums = [];
	linker = GetEnt( "spin_airlock01_linker" , "targetname" );
	index_num = 0;
	
	for( i = 0 ; i < 5 ; i ++ )
	{
		waittime = 1 - ( i * .18 );
		bCheck = false;
		bUsed = false;
		while( bCheck == false )
		{
			index_num = RandomIntRange( 1 , 16 );
			bUsed = false;
			foreach ( number in nums)
			{
				if( number == index_num )
				{
					bUsed = true;	
				}
			}
			if( bUsed == false )
			{
				nums[i] = index_num;
				bCheck = true;				
			}
			wait .01;			
		}
		flag_set( "increase_decompression" );
		new_link = spawn_tag_origin();
		new_link.origin = linker.origin;
		airlock[ index_num ] LinkTo( new_link );
		new_link MoveX( -2000 , 1 , 0 , 0 );
		randomNum = RandomFloatRange( -90 , 90 );
		new_link RotateBy( (randomNum , randomNum , randomNum ) , 1 );
		wait waittime;
		new_link delete();
	}
	maps\odin_util::actor_teleport( level.ally, "spin_ally_airlock_teleport" );
	links = [];
	counter = 1;
	foreach ( piece in airlock)
	{
		new_link = spawn_tag_origin();
		new_link.origin = linker.origin;
		links[counter] = new_link;
		piece Unlink();
		piece LinkTo( new_link );
		randomNum = RandomFloatRange( -90 , 90 );
		new_link MoveX( -2000 , 1 , 0 , 0 );
		new_link RotateBy( (randomNum , randomNum , randomNum ) , 1 );
		counter = counter + 1;
	}
	wait 1;
	foreach ( piece in airlock)
	{
		piece delete();
	}
	
	foreach ( piece in links)
	{
		piece delete();
	}
	
}

attach_spinning_FX()
{
	if( isDefined( level.spinning_room_parts["spin_in_system_main"] ))
	{
		// left->right (0, 90, 0)
		// top->down (90, 0, 0)

		//fire
		tag_origin = spawn_tag_origin();
		tag_origin.origin = (-1172, -4160, -66081);
		tag_origin.angles = (-30, 90, 0);
		tag_origin LinkTo( level.spinning_room_parts["spin_in_system_main"] );
		PlayFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], tag_origin, "tag_origin" );

		//fire
		tag_origin2 = spawn_tag_origin();
		tag_origin2.origin = (-1295, -3542, -65737);
		tag_origin2.angles = (90, 0, 0);
		tag_origin2 LinkTo( level.spinning_room_parts["spin_in_system_main"] );
		PlayFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], tag_origin2, "tag_origin" );

		//fire
		tag_origin1 = spawn_tag_origin();
		tag_origin1.origin = (-1529, -3729, -65312);
		tag_origin1.angles = (90, 40, 0);
		tag_origin1 LinkTo( level.spinning_room_parts["spin_in_system_main"] );
		PlayFXOnTag( level._effect[ "vfx_fire_burning_zeroG" ], tag_origin1, "tag_origin" );

	}
	else
		IPrintLnBold ("pieces not alive yet");
}

// Moving debris
spinning_room_debris()
{
	org = GetEnt( "spacejump_falling_module_org", "targetname" );
	parts = GetEntArray( "spacejump_falling_module", "targetname" );
	foreach( part in parts )
	{
		part LinkTo( org );
	}

	// Get start and end pos
	start = GetEnt( "spacejump_falling_module_org_start", "targetname" );
	end = GetEnt( "spacejump_falling_module_org_end", "targetname" );

	org MoveTo( start.origin, 0.1 );

	wait 0.1;

	// Slide slowly
	org MoveTo( end.origin, 120 );
}


// Spawn some enemies and lock them to spinning walls
// JR-TODO - This script could be better, improve this
// JR-FIXME spawn the guys using the spawn_odin_actor() script
spinning_room_enemies()
{
	// Big room wall lock
	spawners = GetEntArray( "v3_wall_lock_guys", "targetname" );
	foreach( spawner in spawners )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			continue;
		}

		guy thread maps\_space_ai::enable_space();
		guy.health = 25;
		guy.jumping = true;
		guy.ignoreall = true;
		guy.approachType = "";

		// Teleport to the target
		org = spawner get_target_ent();
		if ( !isdefined( org.angles ) )
			org.angles = spawner.angles;
		guy ForceTeleport( org.origin, org.angles );
		guy thread maps\_space_ai::handle_angled_nodes();
		guy thread path_and_lock_to_wall( org, "stunnel_grp03_big_int_org" );
	}

	// Back wall lock
	spawners = GetEntArray( "v3_wall_lock_guys_back", "targetname" );
	foreach( spawner in spawners )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			continue;
		}
		guy thread maps\_space_ai::enable_space();
		guy.health = 25;
		guy.jumping = true;
		guy.ignoreall = true;
		guy.approachType = "";

		// Teleport to the target
		org = spawner get_target_ent();
		if ( !isdefined( org.angles ) )
			org.angles = spawner.angles;
		guy ForceTeleport( org.origin, org.angles );
		guy thread maps\_space_ai::handle_angled_nodes();
		guy thread path_and_lock_to_wall( org, "stunnel_grp04_exit_org" );
	}

	spawners = GetEntArray( "v3_wall_lock_guys_end", "targetname" );
	foreach( spawner in spawners )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			continue;
		}
		guy thread maps\_space_ai::enable_space();
		guy.health = 25;
		guy.jumping = true;
		guy.ignoreall = true;
		guy.approachType = "";

		// Teleport to the target
		org = spawner get_target_ent();
		if ( !isdefined( org.angles ) )
			org.angles = spawner.angles;
		guy ForceTeleport( org.origin, org.angles );
		guy thread maps\_space_ai::handle_angled_nodes();
		//guy thread path_and_lock_to_wall( org, "stunnel_narrow_org" );
	}

	// Give time for the enemies to get into position before things start rotating
	wait 5.0;
	flag_set( "unlock_spin_start" );
}

path_and_lock_to_wall( org, lock_org )
{
	// Set goal volume on targets target
	ai_node = GetNode( org.target, "targetname" );
	self SetGoalNode( ai_node );
	self.goalradius = 4;
	self waittill( "goal" );

	lock_org = GetEnt( lock_org, "targetname" );
	self linkTo( lock_org );
	self thread spinning_wall_match_orient( lock_org, ai_node.angles );	
}

// Static Rotating cover objects
spinning_cover()
{
	cover_orgs = GetEntArray( "spin_box_cover_org", "targetname" );
	foreach( org in cover_orgs )
	{
		// Get the box
		box = GetEnt( org.target, "targetname" );

		// Link
		box LinkTo( org );

		time = RandomFloatRange( 5.0, 25.0 );
		spin_type = RandomInt( 3 );

		// Run the spin script
		org thread spinning_cover_spin_loop( time, spin_type );
	}
}

spinning_cover_spin_loop( time, spin_type )
{
	level endon( "stop_spinning_room" );

	while( 1 )
	{
		switch( spin_type )
		{
			case 0:
				self RotateRoll( 360, time );
				break;
			case 1:
				self RotateYaw( 360, time );
				break;
			case 2:
				self RotatePitch( 360, time );
				break;
			default:
		}
		self waittill( "rotatedone" );
	}
}


//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
spin_cleanup( force_immediate_cleanup )
{
	// Delete triggers

	// Delete spawners

	// Delete lights

	//flag_wait( "player_started_spacejump" );

	// Generic delete
	maps\odin_util::safe_delete_noteworthy( "spin_parts" );

	// Delete all the rotating room parts
	/*
	foreach( room in level.spinning_room_parts )
	{
		iprintlnbold( "room cleanup" );
		foreach( org in room.swap_org )
		{
			iprintlnbold( "swap cleanup" );
			maps\odin_util::safe_delete_array( org.parts );
		}
	}
	*/
}


//================================================================================================
//	UTILITIES
//================================================================================================
// Does the 6 swap room illusion
room_swapper_create( basename, angles, time, initial_angles, system_flag, force )
{
	level endon( "stop_spinning_room" );

	// One origin that does the full non segmented rotation
	full_spin_org = GetEnt( basename + "_org", "targetname" );
	full_spin_org.spin_angles = angles;
	full_spin_org.spin_time = time;

	// Safety
	if( !isDefined( full_spin_org ))
	{
		AssertMsg( "Error: room_swapper cannot find full_spin_org for " + basename );
		return;
	}

	if( isDefined( system_flag ))
	{
		full_spin_org.system_flag = system_flag;
	}

	full_spin_org.swap_org = [];
	full_spin_org.swap_org[0] = link_all_to_org( basename + "_01", basename + "_org_01" );
	full_spin_org.swap_org[1] = link_all_to_org( basename + "_02", basename + "_org_02" );
	full_spin_org.swap_org[2] = link_all_to_org( basename + "_03", basename + "_org_03" );
	full_spin_org.swap_org[3] = link_all_to_org( basename + "_04", basename + "_org_04" );
	full_spin_org.swap_org[4] = link_all_to_org( basename + "_05", basename + "_org_05" );
	full_spin_org.swap_org[5] = link_all_to_org( basename + "_06", basename + "_org_06" );


	// Safety
	if( !isDefined( full_spin_org.swap_org[0] ) || !isDefined( full_spin_org.swap_org[1] ) || !isDefined( full_spin_org.swap_org[2] )
	   || !isDefined( full_spin_org.swap_org[3] ) || !isDefined( full_spin_org.swap_org[4] ) || !isDefined( full_spin_org.swap_org[5] ))
	{
		AssertMsg( "Error: room_swapper could not find one of the 6 parts for " + basename );
		return;
	}

	// Initialize positions ( skip entry 0 because its already in the right spot )
	full_spin_org.swap_org[1].origin = full_spin_org.swap_org[1].origin - (0,2000,0);
	full_spin_org.swap_org[2].origin = full_spin_org.swap_org[2].origin - (0,4000,0);
	full_spin_org.swap_org[3].origin = full_spin_org.swap_org[3].origin - (0,6000,0);
	full_spin_org.swap_org[4].origin = full_spin_org.swap_org[4].origin - (0,8000,0);
	full_spin_org.swap_org[5].origin = full_spin_org.swap_org[5].origin - (0,10000,0);

	// Initialize the angles
	if( isDefined( initial_angles ))
	{
		full_spin_org.swap_org[0].angles = full_spin_org.swap_org[0].angles + initial_angles;
		full_spin_org.swap_org[1].angles = full_spin_org.swap_org[1].angles + initial_angles;
		full_spin_org.swap_org[2].angles = full_spin_org.swap_org[2].angles + initial_angles;
		full_spin_org.swap_org[3].angles = full_spin_org.swap_org[3].angles + initial_angles;
		full_spin_org.swap_org[4].angles = full_spin_org.swap_org[4].angles + initial_angles;
		full_spin_org.swap_org[5].angles = full_spin_org.swap_org[5].angles + initial_angles;
		full_spin_org.angles = full_spin_org.angles + initial_angles;
	}

	// Hide the non active swaps ( skip entry 0 since it should show initially )
	full_spin_org.swap_org[1] thread room_swapper_hide();
	full_spin_org.swap_org[2] thread room_swapper_hide();
	full_spin_org.swap_org[3] thread room_swapper_hide();
	full_spin_org.swap_org[4] thread room_swapper_hide();
	full_spin_org.swap_org[5] thread room_swapper_hide();


	return full_spin_org;
}

// Main rotation loop for the room swap
room_swapper_start()
{
	level endon( "stop_spinning_room" );

	angles = self.spin_angles;
	time = self.spin_time;

	// Safety check
	if( !isDefined( self ))
	{
		AssertMsg( "Error: Invalid self in room_swapper_loop" );
		return;
	}

	reverse_time = time * 3;
	self.current_mover_system = self.swap_org[0].system_brush;
	while( 1 )
	{
		// Do a full spin on the primary origin
		self RotateRoll( angles*6, time*6 );

		// JR-TODO - This could be cleaner.

		// SWAP 0 -> 1
		self.swap_org[0] RotateRoll (angles,time);
		self.swap_org[0] waittill ("rotatedone");
		self.swap_org[1] thread room_swapper_show( self.system_flag );
		self.current_mover_system = self.swap_org[1].system_brush;
		level notify( "room_swapper_new_swap", self.system_flag );
		self.swap_org[0] thread room_swapper_hide();

		// SWAP 1 -> 2
		self.swap_org[0] RotateRoll (-1 * angles,reverse_time);
		self.swap_org[1] RotateRoll (angles,time);
		self.swap_org[1] waittill ("rotatedone");
		self.swap_org[2] thread room_swapper_show( self.system_flag );
		self.current_mover_system = self.swap_org[2].system_brush;
		level notify( "room_swapper_new_swap", self.system_flag );
		self.swap_org[1] thread room_swapper_hide();

		// SWAP 2 -> 3
		self.swap_org[1] RotateRoll (-1 * angles,reverse_time);
		self.swap_org[2] RotateRoll (angles,time);
		self.swap_org[2] waittill ("rotatedone");
		self.swap_org[3] thread room_swapper_show( self.system_flag );
		self.current_mover_system = self.swap_org[3].system_brush;
		level notify( "room_swapper_new_swap", self.system_flag );
		self.swap_org[2] thread room_swapper_hide();

		// SWAP 3 -> 4
		self.swap_org[2] RotateRoll (-1 * angles,reverse_time);
		self.swap_org[3] RotateRoll (angles,time);
		self.swap_org[3] waittill ("rotatedone");
		self.swap_org[4] thread room_swapper_show( self.system_flag );
		self.current_mover_system = self.swap_org[4].system_brush;
		level notify( "room_swapper_new_swap", self.system_flag );
		self.swap_org[3] thread room_swapper_hide();

		// SWAP 4 -> 5
		self.swap_org[3] RotateRoll (-1 * angles,reverse_time);
		self.swap_org[4] RotateRoll (angles,time);
		self.swap_org[4] waittill ("rotatedone");
		self.swap_org[5] thread room_swapper_show( self.system_flag );
		self.current_mover_system = self.swap_org[5].system_brush;
		level notify( "room_swapper_new_swap", self.system_flag );
		self.swap_org[4] thread room_swapper_hide();

		// SWAP 5 -> 0
		self.swap_org[4] RotateRoll (-1 * angles,reverse_time);
		self.swap_org[5] RotateRoll (angles,time);
		self.swap_org[5] waittill ("rotatedone");
		self.swap_org[0] thread room_swapper_show( self.system_flag );
		self.current_mover_system = self.swap_org[0].system_brush;
		level notify( "room_swapper_new_swap", self.system_flag );
		self.swap_org[5] thread room_swapper_hide();

		self.swap_org[5] RotateRoll (-1 * angles,reverse_time);
	}
}

// Links all objects with parts_targetname to org_targetname
// Returns the org
link_all_to_org( parts_targetname, org_targetname )
{
	org = GetEnt( org_targetname, "targetname" );
	if( !isDefined( org ))
	{
		return;
	}
	org.parts = GetEntArray( parts_targetname, "targetname" );
	org.system_brush = undefined;
	foreach( part in org.parts )
	{
		part Linkto ( org );

		// Check for the primary brush in this grouping
		if( isDefined( part.script_parameters ) && part.script_parameters == "system" )
		{
			org.system_brush = part;
		}
	}
	return org;
}


// Updates mover attachment when entering a new module area
room_swapper_transition_attacher()
{
	level endon( "stop_spinning_room" );

	while( 1 )
	{
		// Check for entering a new module
		ret = level waittill_any_return( "spin_in_system_entrance", "spin_in_system_main", "spin_in_system_exit" /*, "spin_in_system_narrow"*/ );

		// Double check to ignore flag_clear notify
		if( !flag( ret ))
		{
			continue;
		}

		// Update current module
		if( level.player.current_mover_system_name != ret )
		{
			level.player.current_mover_system_name = ret;

			// Force an attach to new system
			iprintln( "SWAP: New system. New module: " + ret );
			level.player ForceMovingPlatformEntity( level.spinning_room_parts[ ret ].current_mover_system );
		}
		wait 0.1;
	}
}

// Updates mover attachment when a swap occurs in the current module
room_swapper_swap_attacher()
{
	level endon( "stop_spinning_room" );

	while( 1 )
	{
		// Check for system swap updates
		level waittill( "room_swapper_new_swap", system_name );

		// Only care about the current system
		if( level.player.current_mover_system_name != system_name )
		{
			continue;
		}

		// Update current system
		level.player.current_mover_system_name = system_name;

		// Force an attach to new system
		iprintln( "SWAP: New system. Swap: " + system_name );
		level.player ForceMovingPlatformEntity( level.spinning_room_parts[ system_name ].current_mover_system );

		wait 0.1;
	}
}

// Guys locked to wall match the orientation of the wall
spinning_wall_match_orient( org, node_angles )
{
	self endon( "death" );
	self endon( "stop_match_orient" );

	// If the character is on an oriented node, factor in that orientation
	orientation_angles = (0,0,0);
	if( isDefined( self.current_node_orientation ))
	{
		//iprintlnbold( "Node Orient: " + self.current_node_orientation[2] );
		orientation_angles = self.current_node_orientation;
	}

	// Update angles to match lock node
	while ( 1 )
	{
		target_angles =  ( node_angles[0], node_angles[1], node_angles[2] - org.angles[2] + orientation_angles[2] );
		self thread maps\_space_ai::doing_in_space_rotation( self.angles, target_angles, 4 );
		wait 0.1;
	}
}

rotating_earth()
{
	level endon( "spin_clear" );
	thread sat_and_Earth_final_position();
	origin = GetEnt( "spin_skybox_rotator" , "targetname" );
	space = getEnt( "space_mover" , "targetname" );
	earth_rotate_speed = 90;
	
	sat = maps\odin_satellite::satellite_get_script_mover();
	
	piece = getEnt( "earth_mover_0" , "targetname" );
	if( !flag( "earth_drop" ) )
	{
		piece MoveZ( -55000 , .05 , 0 , 0 );	
	}
	wait .25;
	piece  LinkTo( space );
	
	flag_wait( "start_near_explosion_sequence" );
	//wait 5;
	space RotatePitch (-20,0.1);
	sat RotatePitch (-30,0.1);
	wait 0.1;
	sat RotateYaw (-20,0.1);
	wait 0.1;
	sat MoveZ (-2500,0.1);
	wait 0.1;
	sat MoveX (6500,0.1);
	space MoveX (-1500,0.1);
	wait 0.1;
	flag_set ("EarthSetupComplete");
	//IPrintLnBold ("starting rotate loop");
	
	if( !isDefined( origin ) || !isDefined( space ))
	{
		return;
	}

	space LinkTo( origin );
	sat LinkTo( origin );
	
	while(1)
	{
		if (!flag ("spin_clear"))
		{
			origin RotateRoll( -360 , earth_rotate_speed , 0 , 0 );
			wait earth_rotate_speed;
		}
	}
}

sat_and_Earth_final_position()
{
	flag_wait ("trigger_spacejump");
	IPrintLnBold ("reseting earth and satellite");
	sat = maps\odin_satellite::satellite_get_script_mover();
	sat Unlink();
	thread maps\odin_spacejump::Earth_and_Satellite_final_position();
}

// Hide a room swap section
room_swapper_hide()
{
	foreach ( part in self.parts )
	{
		part Hide();
		part NotSolid();
	}
}

// Show a room swap section
room_swapper_show( system_flag )
{
	foreach ( part in self.parts )
	{
		part Show();
		part Solid();
	}
}

/*
// Move to util - Not needed?  Might need this for static rotating objects in space jump
// Grabs parts, links them, and rotates
rotate_parts( parts_org_name, parts_name, rotate_type, angles, time, initial_rotation )
{
	org = GetEnt( parts_org_name, "targetname" );
	if( !isDefined( org ))
	{
		return;
	}
	parts = GetEntArray( parts_name, "targetname" );
	foreach( part in parts )
	{
		part LinkTo( org );
	}
	switch( rotate_type )
	{
		case "yaw":
			if( isDefined( initial_rotation ))
			{
				org RotateYaw( initial_rotation, 0.1 );
				wait 0.1;
			}
			org RotateYaw( angles, time );
			break;
		case "pitch":
			if( isDefined( initial_rotation ))
			{
				org RotatePitch( initial_rotation, 0.1 );
				wait 0.1;
			}
			org RotatePitch( angles, time );
			break;
		case "roll":
		default:
			if( isDefined( initial_rotation ))
			{
				org RotateRoll( initial_rotation, 0.1 );
				wait 0.1;
			}
			org rotateroll( angles, time );
			break;
	}
}
*/

// Temp objective for where to go in spin section
// JR-HACK HACK HACK BAD BAD BAD
spinning_room_temp_objective()
{
	SetSavedDvar( "compass", "1" );
	Objective_Add( 1, "current", "GET TO AIRLOCK" );

	waypoint = GetEnt( "origin_airlock_waypoint", "targetname" );
	follow_icon = NewHudElem();
	follow_icon SetShader( "hud_grenadepointer", 5, 5 );
	follow_icon.alpha = .25;
	follow_icon.color = ( 0, 1, 0 );
	follow_icon SetTargetEnt( waypoint );
	follow_icon SetWayPoint( true, true );

	flag_wait( "spacejump_player_in_airlock" );
	Objective_Delete( 1 );
	waypoint delete();
}

spin_ai_actions()
{
	level endon( "ai_vignette_stop" );
	enemy = maps\odin_util::spawn_odin_actor_single( "vignette_ai_guy", true );
	enemy.animname = "odin_opfor" ;
	thread stop_on_death( "ai_vignette_stop" , enemy );
	//enemy[0] endOnDeath();
	enemy set_ignoreme( true );
	level.ally set_ignoreme( true );
	
	node1 = GetNode( "ai_vignette_node_0" , "targetname" );
	node2 = GetNode( "ai_vignette_node_1" , "targetname" );
	node3 = GetNode( "ai_vignette_node_2" , "targetname" );

	guys = [];
	guys["odin_opfor"] = enemy;
	
	animNodes 		= [];
	animNodes[0]	= GetEnt( "anim_loop_start" , "targetname" );
	animNodes[1]	= animNodes[0] get_target_ent();
	animNodes[2]	= animNodes[1] get_target_ent();
	
	flag_wait( "odin_escape_start_spinning_room" );
	enemy SetGoalNode( node1 );
	flag_wait( "vignette_move_ai_1" );
	animNodes[0] anim_reach( guys , "space_traversal_L_to_R" );
	animNodes[0] anim_first_frame( guys , "space_traversal_L_to_R" );
	animNodes[0] anim_single( guys , "space_traversal_L_to_R" );
	enemy SetGoalNode( node2 );
	flag_wait( "vignette_move_ai" );
	animNodes[1] anim_reach( guys , "space_traversal_R_to_L" );
	animNodes[1] anim_first_frame( guys , "space_traversal_R_to_L" );
	animNodes[1] anim_single( guys , "space_traversal_R_to_L" );
	enemy SetGoalNode( node3 );
	
}

stop_on_death( notify_string , enemy )
{
	while(1)
	{
		enemy waittill( "damage", amount, attacker, direction_vec, point, type );
		if( amount >= 5 )
		{
			enemy anim_stopanimscripted();
			enemy kill();
			break;
		}
		break;
	}
	
	guys = [];
	guys[0] = enemy;
	waittill_dead_or_dying( guys );
	level notify( notify_string );
}

vignette_ai_shooting( enemy )
{
	level endon( "ai_vignette_stop" );
	initial_target = level.player GetShootAtPos();
	difficulty = level getDifficulty();
	randA =  60 ;
	randB = -60 ;
	
	switch ( difficulty )
	{
		case "easy":
			randA =  60 ;
			randB = -60 ;
			break;
				
		case "medium":
			randA =	 40 ;
			randB = -40 ;
			break;

		case "hard":
			randA =	 25 ;
			randB = -25 ;
			break;

		case "fu":
			randA =	 15 ;
			randB = -15 ;
			break;	
		default:
			break;
	}
	
	Random1 = RandomFloatRange( randB , randA );
	Random2 = RandomFloatRange( randB , randA );
	Random3 = RandomFloatRange( randB , randA );
	
	target = ( ( initial_target[0] + Random1 ) , ( initial_target[1] + Random2 ) , ( initial_target[2] + Random3 ) );
	time_to_shoot = RandomIntRange( 2 , 4 );
	waittime = RandomFloatRange( 1.5 , 3 );
	
	for( i = 0 ; i < time_to_shoot ; i++ )
	{
		enemy Shoot( 1 , target );
		wait waittime;	
	}

}