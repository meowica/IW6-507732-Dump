#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


satellite_start()
{
	//iprintlnbold( "Satellite Start" );
	maps\odin_util::move_player_to_start_point( "start_odin_satellite" );

	wait 0.1;

	maps\odin_util::actor_teleport( level.ally, "odin_satellite_ally_tp" );

	// Move the earth down
	// JR TODO - We really need a generic earth mover script
	earthA = GetEnt( "earth_mover_0" , "targetname" );
	earthA MoveZ( -65000 , .05 , 0 , 0 );
	earthA waittill( "movedone" );
	newNode = GetEnt( "spin_skybox_rotator2" , "targetname" );
	earthA linkTo( newNode );
	newNode RotateRoll( 180 , 0.1 );
	flag_set( "trigger_spacejump" );
	flag_set( "landed_on_satellite" );
	thread ROD_assembly_setup();
	thread spin_blade_node();
	//thread maps\odin_spacejump::Play_ROG_Hit_FX_On_Earth();
	level.player thread maps\odin_spacejump::damage_player_suit_player("satellite_traversal_done", "satellite_clear");
}

section_precache()
{
}

section_flag_init()
{
	flag_init( "interrupt_climb" );
	flag_init( "satellite_clear" );
	flag_init( "satellite_traversal_done" );
	flag_init( "blade_can_spin" );
	flag_init( "prompt2" );
	flag_init( "prompt3" );
	flag_init( "next_prompt" );
	flag_init( "clear_to_fire_first_rog" );
	flag_init( "ROG_FIRING" );
	flag_init( "commence_firing_system" );
	flag_init( "clear_to_tweak_player" );
	flag_init( "sync_blades" );
	flag_init( "animated_sequence_complete" );
	flag_init( "damage_level_1" );
	flag_init( "damage_level_2" );
	flag_init( "damage_level_3" );
	flag_init( "damage_level_4" );
	
	//Dialogue flags
	flag_init( "ally_at_top" );
	flag_init( "player_clear_to_fire" );
	flag_init( "damage_line_1" );
	flag_init( "damage_line_2" );
	flag_init( "damage_line_3" );
	flag_init( "sat_explosion" );
	
	flag_init( "new_pod_opens" );
}

section_hint_string_init()
{
}


//================================================================================================
//	MAIN
//================================================================================================
satellite_main()
{
	//iprintlnbold( "Satellite Main" );
	
	//speed playback of Kyra
	level.ally.moveplaybackrate = 2;
	
	// Save
	thread autosave_by_name( "satellite_begin" );
	thread ally_movement_logic();
	thread tube_rip_sequence();
	thread satellite_dialogue();
	thread thor_pod_opens();
	thread satellite_traversal_setup();

	// Make sure Kira is in a good spot
	// JR - This needs to happen currently because Kiras jump anim puts her far away.
	maps\odin_util::actor_teleport( level.ally, "odin_satellite_ally_tp" );

	// Checkpoint setup
	satellite_setup();

	// Setup temp objective markers
	thread satellite_temp_objective();
	flag_set( "commence_firing_system" );

	// Halt to prevent auto fallthrough into next checkpoint
	flag_wait( "satellite_clear" );
}

satellite_setup()
{
	thread maps\_space_player::player_location_check( "exterior" );
}


satellite_dialogue()
{
	//Kyra: We need to push this whole damn thing out of orbit and scuttle it! Follow me!
	smart_radio_dialogue( "odin_kyr_weneedtopush" );

	flag_wait( "new_pod_opens" );
	//Kyra: Oh no!  It's sequencing!  Hurry!
	smart_radio_dialogue( "odin_kyr_ohnothesecond" );	

	//Kyra: We need to get to the top - near the RCS alignment thrusters.
	smart_radio_dialogue( "odin_kyr_weneedtoget_2" );

//	//Kyra: If we blow the RCS thruster supply lines, we should be able to send this whole thing down.
//	smart_radio_dialogue( "odin_kyr_ifweblowthe" );
	//Kyra: Hurry!  It's re-aligning to fire the second salvo!
	smart_radio_dialogue( "odin_kyr_hurrytheplatformis" );
//	flag_wait( "ally_at_top" );
//	//Kyra: Up here Bud!
//	smart_radio_dialogue( "odin_kyr_upherebud" );
//	flag_wait( "player_clear_to_fire" );
	flag_wait( "sync_blades" );
	smart_radio_dialogue( "odin_kyr_holdon_2" );
	flag_wait( "animated_sequence_complete" );
	//Kyra: Ok! Just unload into the supply lines and don’t stop firing!
	smart_radio_dialogue( "odin_kyr_okjustunloadinto" );
	flag_wait( "damage_line_1" );
	//Kyra: That's it!
	smart_radio_dialogue( "odin_kyr_thatsit" );
	flag_wait( "damage_line_2" );
	//Kyra: Almost!
	smart_radio_dialogue( "odin_kyr_almost" );
	flag_wait( "damage_line_3" );
	//Kyra: Whoah!
	smart_radio_dialogue( "odin_kyr_whoah" );
	flag_wait( "sat_explosion" );
	//Kyra: Ok! Just unload into the supply lines and don’t stop firing!
	smart_radio_dialogue( "odin_kyr_wedidit" );
	wait 5;
	smart_radio_dialogue( "odin_kyr_aaahhhburning" );
	
}

//Ally Movement Control
ally_movement_logic()
{
	level.ally set_goal_radius( 8 );
	ally_trail = [];
	for( i = 0 ; i < 5 ; i++ )
	{
		ally_trail[i] = GetNode( "ally_sat_trail_" + i , "targetname" );
	}
	
	level.ally SetGoalNode( ally_trail[0] );
	level.ally waittill( "goal" );
	level.ally SetGoalNode( ally_trail[1] );
	flag_wait( "player_trail_0" );
	level.ally SetGoalNode( ally_trail[4] );
	level.ally waittill( "goal" );
	flag_set( "ally_at_top" );
}

//Find where the player is and keep them from leaving Thor
player_movement_check()
{
	

}

tube_rip_sequence()
{	
	flag_wait ("animated_sequence_complete");
	level.player Unlink();
	level.player EnableWeapons();
	thread push_player_back_from_thor();
}

push_player_back_from_thor()
{
	flag_set( "player_clear_to_fire" );
	tether = GetEnt( "player_tube_rip_node" , "targetname" );
	bCheck = false;
	ally_node = GetNode( "ally_final_node" , "targetname" );
	level.ally set_goal_node( ally_node );
	thread thor_damage_check();
	
	while( bCheck == false )
	{
		flag_set( "clear_to_tweak_player" );
		distance = Distance( level.player.origin , tether.origin );
		if( distance >= 0 && distance <= 256 ) 
		{
			SetSavedDvar( "player_swimWaterCurrent" , ( 6000 , 0 , 6000 ) );
		}
		if( distance >= 257 && distance <= 320 ) 
		{
			SetSavedDvar( "player_swimWaterCurrent" , ( 5000 , 0 , 5000) );
		}
		if( distance >= 321 && distance <= 384 ) 
		{
			SetSavedDvar( "player_swimWaterCurrent" , ( 4000 , 0 , 4000 ) );
		}
		if( distance >= 385 && distance <= 512 ) 
		{
			SetSavedDvar( "player_swimWaterCurrent" , ( 3000 , 0 , 3000 ) );
		}
		if( distance >= 513 && distance <= 640 ) 
		{
			SetSavedDvar( "player_swimWaterCurrent" , ( 1500 , 0 , 2000 ) );
		}
		if( distance >= 641 ) 
		{
			SetSavedDvar( "player_swimWaterCurrent" , ( 0 , 0 , 1000 ) );
			wait 1;
			SetSavedDvar( "player_swimWaterCurrent" , ( 0 , 0 , 0) );
			flag_clear( "clear_to_tweak_player" );
			bCheck = true;
		}
		wait .1;
	}
	
}

thor_damage_check()
{
	thread sat_damage_VFX();
	clip 	= getEnt( "shoot_target_player" , "script_noteworthy" );
	sat_org = GetEnt( "satellite_link_org", "targetname" );
	blades 	= GetEnt( "sat_blades_model" , "script_noteworthy" );
	clip SetCanDamage( true );
	level.sat_damage = 0;
	thread sat_location_check( clip );
	flag_wait( "animated_sequence_complete" );
	level notify( "stop_firing_rods" ); 

	while( 1 )
	{
		clip waittill( "damage", amount, attacker, direction_vec, point, type );
		level.sat_damage = level.sat_damage + amount;
		//IPrintLnBold ("damage "+level.sat_damage);
		thread thor_finale_movement( level.sat_damage );
		flag_set( "damage_line_1" );
		//Stop the blades from spinning and link them to Thor
		//TODO:  This is where the anim call for the blades breaking up goes
		flag_clear( "blade_can_spin" );
		blades Unlink();
		blades LinkTo( sat_org );
	}
}

sat_damage_VFX()
{
	satellite_launcher = GetEnt( "origin_satellite_waypoint", "targetname" );	
	level.sat_damage = 0;
	while (level.sat_damage < 200)
	{
		wait 0.5;
	}
	thread damage_on_satellite( "circuit_breaker", 0.1, 0.2, 1000 );
	thread damage_on_satellite( "jet_afterburner_ignite", 0.1, 0.2, 1000 );
	level.player playsound( "scn_odin_pod_explosion" );
	while (level.sat_damage < 500)
	{
		wait 0.5;
	}
	thread damage_on_satellite( "jet_afterburner_ignite", 0.1, 0.5, 200 );
	while (level.sat_damage < 1000)
	{
		wait 0.5;
	}
	thread damage_on_satellite( "smoke_geotrail_ssnmissile", 8.1, 10.2, 3000 );
	while (level.sat_damage < 1400)
	{
		wait 0.5;
	}
	thread damage_on_satellite( "ac130_smoke_geotrail_missile_large", 10.1, 10.5, undefined );
	while (level.sat_damage < 2000)
	{
		wait 0.5;
	}
	level.player playsound( "scn_odin_pod_explosion" );
	thread damage_on_satellite( "rog_smoke_odin", 8.1, 10.2 );
	wait 2;
	thread damage_on_satellite( "ac130_smoke_geotrail_missile_large", 10.1, 10.5, undefined, (0,0,0) );
	level.player playsound( "scn_odin_pod_explosion" );
	wait 2;
	thread damage_on_satellite( "ac130_smoke_geotrail_missile_large", 10.1, 10.5, undefined, (0,0,200) );
	wait 2;
	thread damage_on_satellite( "ac130_smoke_geotrail_missile_large", 10.1, 10.5, undefined, (0,0,700) );
	level.player playsound( "scn_odin_pod_explosion" );
	wait 2;
	thread damage_on_satellite( "rog_flash_odin", 1.1, 5.5, undefined, undefined );
	level.player playsound( "scn_odin_pod_explosion" );
	wait 2;
	level.player playsound( "scn_odin_pod_explosion" );
	thread damage_on_satellite( "rog_explosion_odin", 1.1, 5.5, undefined, undefined );
	wait 3;
	level.player playsound( "scn_odin_pod_explosion" );
	thread damage_on_satellite( "rog_flash_odin", 1.1, 5.5, undefined, undefined );
	wait 3;
	level.player playsound( "scn_odin_pod_explosion" );
	wait 3;
	level.player playsound( "scn_odin_pod_explosion" );
	thread damage_on_satellite( "rog_flash_odin", 1.1, 2.5, undefined, undefined );
	wait 3;
	level.player playsound( "scn_odin_pod_explosion" );
}

damage_on_satellite( damage_effect, refresh_rate1, refresh_rate2 , death_damage, offset )
{
	fx_origin = GetEnt( "satellite_link_org", "targetname" );	
    new_model = spawn_tag_origin();
    new_model.origin = fx_origin.origin;
    if (IsDefined (offset))
	    new_model.origin = ( new_model.origin + offset );
    else
	    new_model.origin = ( new_model.origin + ( RandomFloatRange (1600,1800),RandomFloatRange (-800,-600),1870 ) );
    new_model LinkTo (fx_origin);
	while (1)
	{
		//if (IsAlive (new_model) )
			PlayFXOnTag( level._effect[ damage_effect ], new_model, "tag_origin" );
		wait RandomFloatRange (refresh_rate1,refresh_rate2);
		//StopFXOnTag( level._effect[ damage_effect ], new_model, "tag_origin" );
		if (IsDefined ( death_damage) )
		{
			if (level.sat_damage > death_damage)
				break;
		}
	}
	new_model Delete();
}

thor_finale_movement( sat_damage )
{
	sat_origin = satellite_get_script_mover();
	finale_origin = GetEnt( "firing_position_2" , "script_noteworthy" );	
	finale_origin Unlink();
	satellite = GetEntArray( "spacejump_sat", "targetname" );
	
	rate = 700 - (sat_damage / 5);
	if( rate < 20 )
	{
		rate = 20;	
	}
	
	sat_origin MoveTo( finale_origin.origin , rate , 0 , 0 );
	sat_origin RotateTo ((0,30,0),rate*.1,0,0);
	
	current_amount = 0 - (sat_damage * 2 ) ;
	flag_set( "clear_to_tweak_player" );
	if( current_amount < -5000 )
	{
		current_amount = -5000;	
	}
	SetSavedDvar( "player_swimWaterCurrent" , ( current_amount , 0 , current_amount ) );
}

sat_location_check( clip )
{
	
	testB = GetEnt( "firing_position_3" , "script_noteworthy" );
	testA = testB.origin[2] - 3500;
	explo_start = testB.origin[2] - 500;
	second_shake_depth = testB.origin[2] - 2000;
	sat = GetEntArray( "spacejump_sat", "targetname" );
	bCheck = false;
	bFirst_exploded = false;
	second_speed = false;
	
	while( bCheck == false )
	{
		if( explo_start > testb.origin[2] && bFirst_exploded == false )
		{
			flag_set( "damage_line_2" );
			first_group = GetEntArray( "first_to_explode", "script_noteworthy" );
			thread sat_exploder( first_group , .4 );
			bFirst_exploded = true;
			Earthquake( .05 , 200 , level.player.origin , 2000 );
		}
		
		if( second_shake_depth > testb.origin[2] && second_speed == false )
		{
			flag_set( "damage_line_3" );
			second_speed = true;
			Earthquake( .15 , 200 , level.player.origin , 2000 );

			flag_set( "satellite_clear" );
		}

		if( testA > testb.origin[2] )
		{
			flag_set( "sat_explosion" );
			thread sat_exploder( sat , 0 );
			Earthquake( .25 , 200 , level.player.origin , 2000 );
			bCheck = true;
		}
		wait .25 ;
	}
}

sat_exploder( array , time_offset)
{
	foreach( piece in array )
			{
				if( IsDefined( piece.script_parameters ) && piece.script_parameters == "do_not_explode" )
				{
					
				}
				else
				{
					if( piece.classname == "script_model" || piece.classname == "script_brushmodel" && piece.classname != "script_origin"  )
					{
						piece unlink();
					}
				}
			}
	foreach( piece in array )
	{
		if( IsDefined( piece.script_parameters ) && piece.script_parameters == "do_not_explode" )
		{
			piece thread SatellitePieceBurnUp( piece );
		}
		else
		{
			if( piece.classname == "script_model" || piece.classname == "script_brushmodel" && piece.classname != "script_origin" )
			{	
				wait RandomFloatRange (0.1,0.4);
				thread SatellitePieceBurnUp (piece);
				piece unlink();
				randomX = RandomFloatRange( -1000 , 3000 );
				randomY = RandomFloatRange( -3000, 3000 );
				randomZ = RandomFloatRange( 2000  , 10000 );
				
				newX = piece.origin[0] + randomX;
				newY = piece.origin[1] + randomY;
				newZ = piece.origin[2] + randomZ;
				
				time 		= RandomFloatRange( 20 , 40 );
				wait_time 	= RandomFloatRange( 2 , 4 );
				degree		= RandomFloatRange( -1080 , 1080 );
				randomCheck = RandomIntRange( 1 , 3 );
				
				switch ( randomCheck )
				{
					case 1:
						piece RotateRoll( degree , time , (time * .25 ) , (time * .25 ) );
						break;
						
					case 2:
						piece RotatePitch( degree , time , (time * .25 ) , (time * .25 ) );
						break;
						
					case 3:
						piece RotateYaw( degree , time , (time * .25 ) , (time * .25 ) );
						break;					
				
					default:
						piece RotateRoll( degree , time , (time * .25 ) , (time * .25 ) );
						break;
				}
				
				piece MoveTo( ( newX, newY , newZ ) , time , 0 , (time * .25 ) );
				wait time_offset;
			}
		}
		
	}
}

SatellitePieceBurnUp( piece )
{
	if (piece.classname != "script_brushmodel" && piece.model != "iss_sail_center" && piece.model != "fah_sidewalk_tubes_01" && piece.model != "clk_fusebox_01" )
	{
		//IPrintLnBold ("SatellitePieceBurnUp");
		thread maps\odin_audio::sfx_distant_explo( piece );
		BurnUpVFX = "ambient_explosion";
		randomVFX = RandomIntRange( 1 , 7 );
		switch ( randomVFX )
		{
			case 1:
				BurnUpVFX = "rog_flash_odin";
				break;
			case 2:
				BurnUpVFX = "ac130_smoke_geotrail_missile_large";
				break;
			case 3:
				BurnUpVFX = "smoke_geotrail_ssnmissile";
				break;
			case 4:
				BurnUpVFX = "airstrip_explosion";
				break;
			case 5:
				BurnUpVFX = "ambient_explosion";
				break;
			case 6:
				BurnUpVFX = "xm25_explosion";
				break;
			case 7:
				BurnUpVFX = "rog_smoke_odin";
				break;
		}
		wait RandomFloatRange (1,10);
		PlayFXOnTag( level._effect[ BurnUpVFX ], piece, "tag_origin" );
	}
	
}

// Links the satellite parts to a mover org
satellite_get_script_mover()
{
	// If it doesnt exist, create it
	if( !isDefined( level.satellite_script_mover ))
	{
		// Get the org
		sat_org = GetEnt( "satellite_link_org", "targetname" );

		// Get the parts
		parts = GetEntArray( "spacejump_sat", "targetname" );
		foreach( part in parts )
		{
			part LinkTo( sat_org );
		}

		// Save it.
		level.satellite_script_mover = sat_org;
	}

	return level.satellite_script_mover;
}

// Move satellite far away for space jump
satellite_move_to( targetname, time, accel, decel )
{
	sat = satellite_get_script_mover();
	dest = GetEnt( targetname, "targetname" );

	// Move it far away
	if( isDefined( accel ))
	{
		sat MoveTo( dest.origin, time, accel, decel );
	}
	else
	{
		sat MoveTo( dest.origin, time );
	}
}

// Temp objective for where to go on the satellite
// JR-HACK HACK HACK BAD BAD BAD
satellite_temp_objective()
{
	SetSavedDvar( "compass", "1" );
	Objective_Add( 1, "current", "DISRUPT THE SATELLITE" );

	waypoint = GetEnt( "origin_satellite_waypoint", "targetname" );	
	follow_icon = NewHudElem();
	follow_icon SetShader( "hud_grenadepointer", 5, 5 );
	follow_icon.alpha = .25;
	follow_icon.color = ( 0, 1, 0 );
	follow_icon SetTargetEnt( waypoint );
	follow_icon SetWayPoint( true, true );

	flag_wait( "satellite_player_at_top" );

	Objective_Delete( 1 );
	waypoint delete();
}

ROD_assembly_setup()
{
	level endon( "stop_firing_rods" );

	rods 			= [];
	origins			= [];
	fire1 			= GetEnt( "firing_position_0" , "script_noteworthy" );		//The point where the circular ROD drum connects to THOR
	fire2 			= GetEnt( "firing_position_1" , "script_noteworthy" );		//Top of the "barrel" of THOR
	fire3 			= GetEnt( "firing_position_2" , "script_noteworthy" );		//Target of the ROD.  ROD deletes upon reaching
	rotation_node 	= GetEnt( "firing_array_rotator" , "script_noteworthy" );
	
	// fire bobus ROGs until spacejump actually happens
	//thread fire_bogus_rods();

	flag_wait ( "begin_firing_bogus_rods" );
	thread maps\odin_spacejump::Play_ROG_Hit_FX_On_Earth();
	flag_wait ( "trigger_spacejump" );

	//Establish each ROD and stick it in an array, then link it to the rotator
	for( i = 0 ; i < 10 ; i++ )
	{
		new_rod = getEnt( "firing_ROD_" + i , "script_noteworthy" );
		rods[i] = new_rod;
		origins[i] = new_rod.origin;
		new_rod unlink();
	}
	offset = 0;
	
	for( i = 0 ; i < 10 ; i++ )
	{
		rods[i] MoveTo( fire1.origin , .25 , 0 , 0 );
		
		for( d = i ; d < 10 ; d++ )
		{
			next = ( d + 1 );
			position = d - offset ;
			if( IsDefined( rods[ next ] ) )
			   {
					rods[ next ] MoveTo( origins [position] , 8 , 0 , 0 );
			   }
		}

		offset = offset + 1;
		flag_wait( "clear_to_fire_first_rog" );
		thread fire_rod( rods[i] );
		wait 8;
	}

}

fire_rod( rod )
{
	level endon( "stop_firing_rods" );

	fire2 = GetEnt( "firing_position_1" , "script_noteworthy" );		//Top of the "barrel" of THOR
	fire3 = GetEnt( "firing_position_2" , "script_noteworthy" );		//Target of the ROD.  ROD deletes upon reaching	
	
	rod MoveTo( fire2.origin , 4 , 0 , 0 );
	wait 4 ;
	PlayFXOnTag( level._effect[ "rog_flash_odin" ], rod, "tag_origin" );
	Earthquake( .25 , 4.0 , level.player.origin , 2000 );
	thread Rod_Firing_SFX();
	wait 2;
	if (flag ( "trigger_spacejump" ) )
		thread Rod_firing_FX();
	rod MoveTo( fire3.origin , 6 , 2 , 0 );
	flag_set( "ROG_FIRING" );
	if(flag( "landed_on_satellite" ) )
	{
		PlayFXOnTag( level._effect[ "smoke_geotrail_ssnmissile" ], rod, "tag_origin" );
		//wait 0.2;
		Earthquake( .75 , 3.0 , level.player.origin , 2000 );
		wait 2.0;
		Earthquake( .15 , 0.5 , level.player.origin , 2000 );
		wait 1;
		StopFXOnTag( level._effect[ "smoke_geotrail_ssnmissile" ], rod, "tag_origin" );
	}
	else
	{
		PlayFXOnTag( level._effect[ "ac130_smoke_geotrail_missile_large" ], rod, "tag_origin" );
		wait 3;
		StopFXOnTag( level._effect[ "ac130_smoke_geotrail_missile_large" ], rod, "tag_origin" );
	}
	wait 3;
	rod hide();
}

Rod_Firing_SFX()
{
	satellite_launcher = GetEnt( "origin_satellite_waypoint", "targetname" );	
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.6;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.5;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.4;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.3;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.2;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.1;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	satellite_launcher playsound( "scn_odin_pod_explosion" );
	wait 0.3;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.3;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.3;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.3;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
	wait 0.3;
	thread maps\odin_audio::sfx_distant_explo( satellite_launcher );
}

Rod_firing_FX()
{
	exploder ("rog_barrel_01");
	wait 0.1;
	exploder ("rog_barrel_02");
	wait 0.1;
	exploder ("rog_barrel_03");
	wait 0.1;
	exploder ("rog_barrel_04");
	wait 0.1;
	exploder ("rog_barrel_05");
	wait 0.1;
	exploder ("rog_barrel_06");
	wait 0.1;
	exploder ("rog_barrel_07");
	wait 0.1;
	exploder ("rog_barrel_08");
	wait 0.1;
	exploder ("rog_barrel_09");
	wait 0.1;
	exploder ("rog_barrel_10");
	wait 0.1;
	exploder ("rog_barrel_11");
	wait 0.1;
	exploder ("rog_barrel_12");
}

thor_pod_opens()
{
	pod1				= GetEntArray( "pod_that_opens_0" , "script_noteworthy" );
	pod2				= GetEntArray( "pod_that_opens_1" , "script_noteworthy" );
	pod3				= GetEntArray( "pod_that_opens_2" , "script_noteworthy" );
	pod1_origin			= GetEnt( "pod_that_opens_origin_0" , "script_noteworthy" );
	pod2_origin			= GetEnt( "pod_that_opens_origin_1" , "script_noteworthy" );
	pod3_origin			= GetEnt( "pod_that_opens_origin_2" , "script_noteworthy" );
	pod1_destination	= GetEnt( "pod_cover_target_0" , "script_noteworthy" );
	pod2_destination	= GetEnt( "pod_cover_target_1" , "script_noteworthy" );
	pod3_destination	= GetEnt( "pod_cover_target_2" , "script_noteworthy" );
	
	foreach ( piece in pod1)
	{
		if( piece.classname == "script_brushmodel" )
		{
			piece LinkTo( pod1_origin );
		}
	}
	
	foreach ( piece in pod2)
	{
		if( piece.classname == "script_brushmodel" )
		{
			piece LinkTo( pod2_origin );
		}
	}
	
	foreach ( piece in pod3)
	{
		if( piece.classname == "script_brushmodel" )
		{
			piece LinkTo( pod3_origin );
		}
	}
	
	flag_wait( "new_pod_opens" );
	thread pod_two_spools_up();
	thread thor_pod_opens_fx();
	wait 3;
	pod1_origin MoveTo( pod1_destination.origin , 15 , 0 , 10 );
	pod2_origin MoveTo( pod2_destination.origin , 15 , 0 , 10 );
	pod3_origin MoveTo( pod3_destination.origin , 15 , 0 , 10 );
	pod3_origin Rotatepitch( -30 , 44 , 0 , 25 );
	wait 6;
	pod1_origin MoveTo( pod1_destination.origin , 40 , 0 , 25 );
	pod2_origin MoveTo( pod2_destination.origin , 40 , 0 , 25 );
	pod3_origin MoveTo( pod2_destination.origin , 40 , 0 , 25 );
	pod1_origin RotateRoll( -25, 44 , 0 , 25 );
	pod2_origin RotateYaw( -30 , 44 , 0 , 25 );	
		
}

thor_pod_opens_fx()
{
	//IPrintLnBold ("pod_open_warning");
	exploder ("pod_open_warning");
	wait 3.0;
	exploder ("pod_open");
	//IPrintLnBold ("stop_exploder pod_open_warning");
	stop_exploder ("pod_open_warning");
	
}

pod_two_spools_up()
{
	rods		= [];
	positions 	= [];
	counter = 0;
	for( i = 0 ; i < 16 ; i++ )
	{
		rod = GetEnt( "second_firing_rod_array_" + i , "script_noteworthy" );
		rods[i] = rod;
	}
	
	while( !flag( "damage_line_3" ) )
	{
		foreach( piece in rods )
		{
			positions[counter] = piece.origin;
			counter = counter + 1;
		}
		counter = 0;
		foreach( piece in rods )
		{
			if( counter !=15 )
			{
				next = 	counter + 1;
				piece MoveTo( positions[next] , 8 , 0 , 0 );
				counter = next;
			}
			else
			{
				next = 	0;	
				piece MoveTo( positions[next] , 8 , 0 , 0 );
				counter = 0;
			}
				
		}
		wait 8;	
	}
}
//================================================================================================
//	ANIM/MOVEMENT CONTROL
//	The following functions and script control the player animations for climbing and jumping
//	around THOR.
//================================================================================================
#using_animtree( "player" );
satellite_traversal_setup()		//This function handles the order and logic calls for the sat climb
{
	//The primary animation node.
	animNode = 	getEnt( "satellite_traversal" , "script_noteworthy" );
	//sat = maps\odin_satellite::satellite_get_script_mover();
	//wait 0.1;
	//animNode.origin = sat.origin;
	//animNode.angles = sat.angles;
	//Spawn the player rig
	player_rig = spawn_anim_model( "player_rig" );
	player_rig hide();
	level.player DisableWeapons();
	flag_set( "stop_wall_pushing" );
	
	guys = [];
	guys[ "player_rig" ] = player_rig;
	
	arc = 20;
	animNode anim_first_frame( guys , "satellite_traversal_start" );
	player_rig thread maps\odin_spacejump::damage_player_suit_rig();
	level.player PlayerLinkToBlend( player_rig , "tag_player" , 2 );
	wait 2;
	player_rig show();
	//TODO: Remove this VO line
	//Kyra: We need to move it!
	thread smart_radio_dialogue( "odin_kyr_weneedtomove" );
	thread traversal_helper_prompts();
	
	//Rung 1
	flag_set( "prompt2" );
	thread grab_counter();
	wait_for_input( "RT", animNode );
	flag_set( "clear_to_fire_first_rog" );
	animNode anim_first_frame( guys , "satellite_traversal_r1_start" );
	animNode anim_single( guys , "satellite_traversal_r1_start" );
	animnode thread anim_loop( guys , "satellite_traversal_r1_idle" , "stop_loop" );
	
	//Rung 2
	flag_set( "prompt3" );
	wait_for_input( "LT", animNode );
	animNode anim_first_frame( guys , "satellite_traversal_r2_start" );
	animNode anim_single( guys , "satellite_traversal_r2_start" );
	
	//Rung 3
	traversal_anim_handling( animNode , guys , "satellite_traversal_r3_start" , "satellite_traversal_r2_idle" , player_rig , "satellite_traversal_r2_recoil" , "satellite_traversal_r2_jump" , "RT" ); 
	
	//Rung 4
	traversal_anim_handling( animNode , guys , "satellite_traversal_r4_start" , "satellite_traversal_r3_idle" , player_rig , "satellite_traversal_r3_recoil" , "satellite_traversal_r3_jump" , "LT" );
	flag_set( "new_pod_opens" );
	
	//Rung 5
	traversal_anim_handling( animNode , guys , "satellite_traversal_r5_start" , "satellite_traversal_r4_idle" , player_rig , "satellite_traversal_r4_recoil" , "satellite_traversal_r4_jump" , "RT" );
	
	//Rung 6
	traversal_anim_handling( animNode , guys , "satellite_traversal_r6_start" , "satellite_traversal_r5_idle" , player_rig , "satellite_traversal_r5_recoil" , "satellite_traversal_r5_jump" , "LT" );
	
	thread traversal_helper_prompts_both();
	wait_for_input( "BOTH", animNode );
	animNode anim_first_frame( guys , "satellite_traversal_rod_01_start" );
	animNode anim_single( guys , "satellite_traversal_rod_01_start" );
	animnode thread anim_loop( guys , "satellite_traversal_rod_01_idle" , "stop_loop" );
	
	thread traversal_helper_prompts_both();
	wait_for_input( "BOTH", animNode );
	animNode anim_first_frame( guys , "satellite_traversal_rod_02_start" );
	animNode anim_single( guys , "satellite_traversal_rod_02_start" );
	animnode thread anim_loop( guys , "satellite_traversal_rod_02_idle" , "stop_loop" );

	thread traversal_helper_prompts_both();
	wait_for_input( "BOTH" , animNode );
	animNode anim_first_frame( guys , "satellite_traversal_solar_jump_start" );
	animNode anim_single( guys , "satellite_traversal_solar_jump_start" );
	
	//The player is about to jump from the body to the top of Thor.  We are going to move to the new animNode node.
	animNode = GetEnt( "satellite_traversal_top" , "script_noteworthy" );
	player_rig LinkTo( animNode );
	animNode RotateRoll( -1440 , 80 , 0 , 0 );
	animnode thread anim_loop( guys , "satellite_traversal_solar_jump_idle" , "stop_loop" );	
	
	thread traversal_helper_prompts_both();
	wait_for_input( "BOTH" , animNode );
	animNode anim_first_frame( guys , "satellite_traversal_top_jump_start" );
	animNode anim_single( guys , "satellite_traversal_top_jump_start" );
	level.player Unlink();
	level.player EnableWeapons();
	player_rig delete();
	flag_set( "animated_sequence_complete" );
}


//Handles the playing fo the anims for the climb
traversal_anim_handling( animNode , guys , full_climb_anim , idle_anim , player_rig , recoil_anim , quick_anim , input_string )
{
	bCheck = false;
	switch ( input_string )
	{
		case "LT":
			if( level.left_grabbed == true )
			{
				bCheck = true;	
			}
			break;
			
		case "RT":
			if( level.right_grabbed == true )
			{
				bCheck = true;	
			}
			break;
			
		default:
			break;
	}
	
	//If the player has recently hit the grab button (thanks to info from grab counter), they drop into the "quick anim" with no recoil or stopping
	if( bCheck == true )
	{
		animNode anim_first_frame( guys , quick_anim );
		flag_set( "next_prompt" );
		animNode anim_single( guys , quick_anim );
	}
	else  //The player has been too slow, and now the space man recoils
	{
		animNode anim_first_frame( guys , recoil_anim );
		animNode anim_single( guys , recoil_anim );
		animnode thread anim_loop( guys , idle_anim , "stop_loop" );
		wait_for_input( input_string , animNode );
		flag_set( "next_prompt" );
		animNode anim_single( guys , full_climb_anim );
	}
	
	waittillframeend;
	return;
}


//Function continuously runs a check to see if the player has made the right button grab recently
grab_counter()
{
	level.left_grabbed 	= false;	
	level.right_grabbed	= false;
	bLeftHeld			= false;
	bRightHeld			= false;
	lCheckTimer 		= GetTime();
	rCheckTimer 		= GetTime();
	lTimer				= 9999;
	rTimer				= 9999;
	constraint			= 1000; //time in ms to limit the button window
	
	while( !flag( "animated_sequence_complete" ) )
	{
		lTimer = GetTime() + 100;
		rTimer = GetTime() + 100;
		if( level.player AdsButtonPressed() )  //Left Trigger
		{
			if( bLeftHeld == false )
			{
				bLeftHeld 		= true;
				lCheckTimer 	= GetTime();
				lTimer			= GetTime();
			}	
		}
		else
		{
			bLeftHeld = false;	
		}
		
		if( level.player AttackButtonPressed() )  //right Trigger
		{
			if( bRightHeld == false )
			{
				bRightHeld 		= true;
				rCheckTimer 	= GetTime();
				rTimer			= GetTime();
			}	
		}
		else
		{
			bRightHeld = false;
		}
		
		if( (lTimer - lCheckTimer ) < constraint )
		{
			level.left_grabbed 	= true;	
		}
		else
		{
			level.left_grabbed 	= false;		
		}
		
		if( (rTimer - rCheckTimer ) < constraint )
		{
			level.right_grabbed 	= true;	
		}
		else
		{
			level.right_grabbed 	= false;		
		}
		wait .01;
	}
}

//Syncs the solar array with the player whenever they jump
sync_blades( guy )
{
	flag_set( "sync_blades" );
	blades = GetEnt( "sat_blades_model" , "script_noteworthy" );
	blades.animname = "satellite_traversal_solar_panels" ;
	blades assign_animtree();
	blades assign_model();
	guys = [];
	guys["satellite_traversal_solar_panels"] = blades;
	animNode = 	getEnt( "satellite_traversal_top" , "script_noteworthy" );
	blades unlink();
	animNode anim_first_frame( guys , "satellite_traversal_props" );
	animNode anim_single( guys , "satellite_traversal_props" );
	linker = GetEnt( "blade_spinner" , "script_noteworthy" );
	blades LinkTo( linker );
}

//Handles the spinning of the solar array
spin_blade_node()
{
	blades = GetEnt( "sat_blades_model" , "script_noteworthy" );
	linker = GetEnt( "blade_spinner" , "script_noteworthy" );
	blades LinkTo( linker );
	linker Unlink();
	flag_set( "blade_can_spin" );
	while( flag( "blade_can_spin" ))
	{
		linker RotateRoll( -360 , 20 , 0 , 0 );
		wait 20;
	}

	
}

//Notetrack controlled functions that handles when the player jumps up to solar array
player_has_jumped( guy )
{
	animNode = GetEnt( "satellite_traversal_top" , "script_noteworthy" );	
	animNode RotateRoll( 0 , 1 , 0 , 0 );	
}

//Function the provides a blocker until the player presses a certain button
wait_for_input( input , animNode )
{
	while(1)
	{
		switch ( input )
		{
			case "LT":
				if( level.player AdsButtonPressed() )
				{
					animNode notify( "stop_loop" );
					return;	
				}
				break;
				
			case "RT":
				if( level.player AttackButtonPressed() )
				{
					animNode notify( "stop_loop" );
					return;	
				}
				break;
				
			case "BOTH":
				if( level.player AdsButtonPressed() && level.player AttackButtonPressed()  )
				{
					animNode notify( "stop_loop" );
					return;	
				}
				break;
				
			default:
				break;
		}
		wait .01;
	}
		
}


//This function controls when what prompt shows
//TODO:  Make this a little less hardcoded - DCS
traversal_helper_prompts()
{
	bCheck = false;	
	
	flag_wait( "prompt2" );
	while(bCheck == false)
	{
		if( level.player AttackButtonPressed() || flag( "next_prompt" ) )
		{
			bCheck = true ;
		}
		else
		{
			thread hint( "                          [{+attack}]" , .3 );
		}
		wait .3;		
	}
	
	bCheck = false;	
	
	flag_wait( "prompt3" );
	while(bCheck == false)
	{
		if( level.player AdsButtonPressed() || flag( "next_prompt" )  )
		{
			bCheck = true ;
		}
		else
		{
			thread hint( "[{+speed_throw}]                     " , .3 );
		}
		wait .3;		
	}
	
	
	bCheck = false;	
	wait .5;
	while(bCheck == false)
	{
		if( level.player AttackButtonPressed() || flag( "next_prompt" ) )
		{
			bCheck = true ;
		}
		else
		{
			thread hint( "                          [{+attack}]" , .3 );
		}
		wait .3;		
	}
	
	bCheck = false;	
	
	flag_wait( "next_prompt" );
	flag_clear( "next_prompt" );
	wait .2;
	while(bCheck == false)
	{
		if( level.player AdsButtonPressed() || flag( "next_prompt" )  )
		{
			bCheck = true ;
		}
		else
		{
			thread hint( "[{+speed_throw}]                     " , .3 );
		}
		wait .3;		
	}
	
	bCheck = false;	
	
	flag_wait( "next_prompt" );
	flag_clear( "next_prompt" );
	wait .1;
	while(bCheck == false)
	{
		if( level.player AttackButtonPressed() || flag( "next_prompt" ) )
		{
			bCheck = true ;
		}
		else
		{
			thread hint( "                          [{+attack}]" , .3 );
		}
		wait .3;		
	}
	
	bCheck = false;	
	
	flag_wait( "next_prompt" );
	flag_clear( "next_prompt" );
	wait .1;
	while(bCheck == false)
	{
		if( level.player AdsButtonPressed() || flag( "next_prompt" )  )
		{
			bCheck = true ;
		}
		else
		{
			thread hint( "[{+speed_throw}]                     " , .3 );
		}
		wait .3;		
	}
}


//Threse are the prompts that appear during the climb up the satellite
traversal_helper_prompts_both()
{
	bCheck = false;
	while(bCheck == false)
	{
		if( level.player AdsButtonPressed() && level.player AttackButtonPressed()  )
		{
			bCheck = true ;
		}
		else
		{
			thread hint( "[{+speed_throw}]          [{+attack}]" , .4 );
		}
		wait .4;		
	}
}
//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
satellite_cleanup( force_immediate_cleanup )
{
}