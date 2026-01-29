#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


escape_start()
{
	maps\odin_util::move_player_to_start_point( "start_odin_escape" );
	wait 0.1;
	maps\odin_util::actor_teleport( level.ally, "odin_escape_ally_tp" );
	
	// Setup the doors!
	thread create_escape_doors();
	
	flag_set( "ally_clear" );
}

section_precache()
{
}

section_flag_init()
{
	flag_init( "ally_turn_1" );
	flag_init( "escape_clear" );
	flag_init( "ally_turn_2" );
	flag_init( "odin_escape_ally_remark_01" );
	flag_init( "earth_move3" );
	flag_init( "earth_move4" );
	flag_init( "earth_drop" );
	
	flag_init( "odin_breach_spin2" );

	// Door control
	flag_init( "lock_crash_tunnel" );
	flag_init( "unlock_crash_tunnel" );
	flag_init( "lock_post_crash_door" );
	flag_init( "unlock_post_crash_door" );
	flag_init( "clear_to_tweak_player" );
}

section_hint_string_init()
{
}


//================================================================================================
//	MAIN
//================================================================================================
escape_main()
{
	//iprintlnbold( "Escape Checkpoint Begin" );
	flag_wait( "ally_clear" );
	// Save
	thread autosave_by_name( "escape_begin" );

	// Do checkpoint setup
	thread escape_setup();
	thread escape_ally_movement_start();
	thread escape_dialogue();
	
	//TODO:  Remove, it's temporary
	thread ally_temp_tp();
	//thread escape_shake();

	// Halt to prevent auto fallthrough into next checkpoint
	flag_wait( "escape_clear" );
	
	//iprintlnbold( "Escape Checkpoint Clear" );
	
}

escape_ally_movement_start()
{
	maps\odin_util::safe_trigger_by_targetname( "final_cover_escape" );		
}

escape_setup()
{
	thread maps\odin_util::floating_corpses( "floaters_first_module", "jolt_first_module" );
	thread maps\odin_util::floating_corpses( "floaters_zigzag_module", "jolt_zigzag_module" );
	
	Exploder( "fx_shell_casings_escape" );
}

// Sets up the escape checkpoint scripted doors
create_escape_doors()
{
}

// Section dialog
escape_dialogue()
{
//	//Kyra: The whole place is breaking up!  Move!
//	smart_radio_dialogue( "odin_kyr_thiswholeplaceis" );
	//Kyra: Atlas Main, they’re everywhere!  I think they’re headed to rod control.
	smart_radio_dialogue( "odin_kyr_atlasmaintheyreeverywhere" );	
	//Atlas Main: ODIN main, we're now seeing a firing sequence intiation!
	smart_radio_dialogue( "odin_atl_odinmainwerenow" );
//	//Atlas Main: Kyra, can you cut them off?
	smart_radio_dialogue( "odin_atl_kyracanyoucut" );	
	//Kyra: No… they have a head start on us.
	smart_radio_dialogue( "odin_kyr_notheyhavea" );	
	flag_wait( "odin_escape_warning" );
//	//Kyra: The whole station has lost gimbal lock!
//	smart_radio_dialogue( "odin_kyr_thewholestationhas" );	
	//Atlas Main: Kyra, we’re going to vent methane into electrical and bring the station down. It’s our only choice…
	smart_radio_dialogue( "odin_atl_kyraweregoingto" );
	//Atlas Main: I’m sorry, Kyra.  This is coming down from SecDef.
	smart_radio_dialogue( "odin_atl_imsorrykyrathis" );
	//Kyra: Do it Atlas Main, we know what we signed up for.
	smart_radio_dialogue( "odin_kyr_doitatlasmain" );
	flag_wait( "odin_escape_ally_remark_01" );
}

// Do period earthquakes
escape_shake()
{
	level endon( "odin_escape_start_spinning_room" );
	while( 1 )
	{
		//IPrintLnBold ("shake");
		EarthQuake( randomFloatRange( 0.1, 0.6 ), randomFloatRange( 0.2, 1.0 ), level.player.origin, 500 );
		wait randomFloatRange( 0.1, 0.5 );
		thread maps\odin_audio::sfx_distant_explo( level.player );
		wait randomFloatRange( 0.1, 3.5 );
	}
}

//TODO:  REMOVE BECAUSE IT'S TEMPORARY
ally_temp_tp()
{
	flag_wait( "trigger_temp_tp_0" );
	maps\odin_util::actor_teleport( level.ally, "temp_tp_0" );
	
	flag_wait( "odin_escape_ally_remark_01" );
	maps\odin_util::actor_teleport( level.ally, "temp_tp_1" );
	
	flag_wait( "trigger_temp_tp_2" );
	maps\odin_util::actor_teleport( level.ally, "temp_tp_2" );
}


//Commenting this out for now in case we wanna use these FX scripts later
//
//script_stephen_escape_stuff()
//{
//	IPrintLn( "start script stephen escape stuff" );
//	exploder ("red_emergency_light04");
//	exploder ("red_emergency_light05");
//	
//	exploder ("red_emergency_light00");
//	exploder ("red_emergency_light01");
//	exploder ("red_emergency_light02");
//	exploder ("red_emergency_light03");
//	
//	exploder ("red_emergency_light06");
//	exploder ("red_emergency_light_spin01");
//	exploder ("red_emergency_light_spin02");
//	exploder ("red_emergency_light_spin03");
//	thread script_escape_circuit_flash_loop();
//	
//	trigger_escape_out_explosion01 = GetEnt( "trigger_escape_out_explosion01", "targetname" );
//	trigger_escape_out_explosion01 waittill( "trigger" );
//	
//	thread script_escape_out_explosion01();
//	
//	trigger_glass_crack01 = GetEnt( "trigger_glass_crack01", "targetname" );
//	trigger_glass_crack01 waittill( "trigger" );
//	
//	thread script_glass_crack01();
//	
//	
//	trigger_start_sparks_and_steam = GetEnt( "trigger_start_sparks_and_steam", "targetname" );
//	trigger_start_sparks_and_steam waittill( "trigger" );
//	IPrintLn( "sparks" );
//	thread script_stephen_spin_stuff();
//	
//	exploder ("escape_breaker_flash01");
//	exploder ("steam_loop00");
//	wait .3;
//	exploder ("spark_loop01");
//	exploder ("escape_breaker_flash02");
//	exploder ("steam_loop01");
//	wait .1;
//	exploder ("escape_breaker_flash03");
//	exploder ("spark_loop02");
//
//	wait .4;
//	exploder ("escape_breaker_flash04");
//	exploder ("spark_loop03");
//	exploder ("steam_loop02");
//	exploder ("steam_loop03");
//	wait .3;
//	exploder ("escape_breaker_flash06");
//	exploder ("spark_loop04");
//	exploder ("steam_loop04");
//	exploder ("steam_loop05");
//	wait .3;
//	exploder ("spark_loop06");
//	
//}
//
//script_escape_out_explosion01()
//{
//	level notify("kill_escape_circuit_flash_loop");
//	wait .2;
//	
//	exploder ("escape_out_explosion01");
//	exploder ("escape_out_explosion03");
//	
//	wait .8;
//	
//	exploder ("escape_out_explosion02");
//	exploder ("escape_out_explosion04");
//	
//	wait .4;
//	
//	exploder ("escape_out_explosion05");
//	exploder ("escape_out_explosion06");
//	
//	wait 1;
//	exploder ("escape_out_explosion03");
//}
//
//script_escape_circuit_flash_loop()
//{
//    level endon( "kill_escape_circuit_flash_loop" );
//    while( 1 )
//    {
//        which_explosion = RandomInt( 3 );
//        
//        if( which_explosion == 0 )
//        {
//            exploder ("escape_breaker_flash_early01");
//        }
//        else if( which_explosion == 1 )
//        {
//            exploder ("escape_breaker_flash_early02");
//        }
//        else if( which_explosion == 2 )
//        {
//            exploder ("escape_breaker_flash_early03");
//        }
//        
//        wait RandomFloatRange( 0.6, 1.25 );
//    }
//}
//
//
//script_glass_crack01()
//{
//	script_brushmodel_escape02_cracked_glass01 = GetEnt( "script_brushmodel_escape02_cracked_glass01" , "targetname" );
//	script_brushmodel_escape02_cracked_glass01 hide();	
//	script_brushmodel_escape02_cracked_glass02 = GetEnt( "script_brushmodel_escape02_cracked_glass02" , "targetname" );
//	script_brushmodel_escape02_cracked_glass02 hide();	
//	script_brushmodel_escape02_cracked_glass03 = GetEnt( "script_brushmodel_escape02_cracked_glass03" , "targetname" );
//	script_brushmodel_escape02_cracked_glass03 hide();	
//	script_brushmodel_escape02_cracked_glass04 = GetEnt( "script_brushmodel_escape02_cracked_glass04" , "targetname" );
//	script_brushmodel_escape02_cracked_glass04 hide();	
//	///-------------------------------------------
//	script_brushmodel_escape_debris_large02 = get_target_ent( "script_brushmodel_escape_debris_large02" );
//
//	vehicle_empty_escape_debris_large01 = GetEnt ( "vehicle_empty_escape_debris_large01", "targetname" );
//	script_brushmodel_escape_debris_large02 LinkTo( vehicle_empty_escape_debris_large01 );
//
//	node_start_escape_debris_large01 = GetVehicleNode ( "node_start_escape_debris_large01", "targetname" );	
//	
//	vehicle_empty_escape_debris_large01 AttachPath ( node_start_escape_debris_large01 );
//	///-------------------------------------------
//	script_brushmodel_spin_debris_large02 = get_target_ent( "script_brushmodel_spin_debris_large02" );
//
//	vehicle_empty_spin_debris_large01 = GetEnt ( "vehicle_empty_spin_debris_large01", "targetname" );
//	script_brushmodel_spin_debris_large02 LinkTo( vehicle_empty_spin_debris_large01 );
//
//	node_start_spin_debris_large01 = GetVehicleNode ( "node_start_spin_debris_large01", "targetname" );	
//	
//	vehicle_empty_spin_debris_large01 AttachPath ( node_start_spin_debris_large01 );
//	///-------------------------------------------
//	wait .2;
//	script_brushmodel_escape_cracked_glass01 = GetEnt( "script_brushmodel_escape_cracked_glass01" , "targetname" );
//	script_brushmodel_escape_cracked_glass01 show();	
//	
//	IPrintLn( "start moving large debris" );
//	vehicle_empty_escape_debris_large01 gopath();
//	vehicle_empty_spin_debris_large01 gopath();
//	
//	thread script_glass_crack02();
//	
//	wait 1;
//
//	script_brushmodel_escape_cracked_glass02 = GetEnt( "script_brushmodel_escape_cracked_glass02" , "targetname" );
//	script_brushmodel_escape_cracked_glass02 show();	
//	
//	wait .2;
//	exploder ("escape_breaker_flash_early04");
//	wait .2;
//	exploder ("steam_loop_early01");
//	
//	wait .5;
//	exploder ("escape_debris_explosion01");
//	exploder ("escape_debris_explosion02");
//	
//	IPrintLn( "explode!!!!!!!!" );
//	wait .5;
//	exploder ("escape_breaker_flash_early05");
//	wait .3;
//	exploder ("steam_loop_early02");
//	
//	
//}
//
//script_glass_crack02()
//{
//	trigger_glass02_crack01 = GetEnt( "trigger_glass02_crack01", "targetname" );
//	trigger_glass02_crack01 waittill( "trigger" );
//	
//	script_brushmodel_escape02_cracked_glass01 = GetEnt( "script_brushmodel_escape02_cracked_glass01" , "targetname" );
//	script_brushmodel_escape02_cracked_glass01 show();	
//	
//	trigger_glass02_crack02 = GetEnt( "trigger_glass02_crack02", "targetname" );
//	trigger_glass02_crack02 waittill( "trigger" );
//	
//	script_brushmodel_escape02_cracked_glass02 = GetEnt( "script_brushmodel_escape02_cracked_glass02" , "targetname" );
//	script_brushmodel_escape02_cracked_glass02 show();	
//	
//	wait .3;
//	
//	script_brushmodel_escape02_cracked_glass03 = GetEnt( "script_brushmodel_escape02_cracked_glass03" , "targetname" );
//	script_brushmodel_escape02_cracked_glass03 show();	
//	
//	trigger_glass02_crack03 = GetEnt( "trigger_glass02_crack03", "targetname" );
//	trigger_glass02_crack03 waittill( "trigger" );
//	
//	script_brushmodel_escape02_cracked_glass04 = GetEnt( "script_brushmodel_escape02_cracked_glass04" , "targetname" );
//	script_brushmodel_escape02_cracked_glass04 show();	
//	
//	
//}
//
//script_stephen_spin_stuff()
//{
//	trigger_start_sparks_and_steam_spinarea = GetEnt( "trigger_start_sparks_and_steam_spinarea", "targetname" );
//	trigger_start_sparks_and_steam_spinarea waittill( "trigger" );
//	level thread autosave_now();
//	thread script_stephen_spin_stuff02();
//	
//	thread escape_corpse_room();
//		
//	stop_exploder("red_emergency_light04");
//	stop_exploder("red_emergency_light05");
//	stop_exploder ("red_emergency_light00");
//	stop_exploder ("red_emergency_light01");
//	stop_exploder ("red_emergency_light02");
//	stop_exploder ("red_emergency_light03");
//	
//	exploder ("spin02_emergency_light01");
//	exploder ("spin02_emergency_light02");
//	exploder ("spin02_emergency_light03");
//	exploder ("spin02_emergency_light04");
//	
//	
//	exploder ("steam_loop06");
//	wait .4;
//	exploder ("steam_loop_spin01");
//	wait .5;
//	exploder ("spin_breaker_flash01");
//	wait 1.5;
//	exploder ("steam_loop07");
//	wait 1;
//	exploder ("steam_loop08");
//	exploder ("spark_loop_spin01");
//		
//	
//}
//
//script_stephen_spin_stuff02()
//{
//	script_brushmodel_spin02_cracked_glass01 = GetEnt( "script_brushmodel_spin02_cracked_glass01" , "targetname" );
//	script_brushmodel_spin02_cracked_glass01 hide();	
//	script_brushmodel_spin02_cracked_glass02 = GetEnt( "script_brushmodel_spin02_cracked_glass02" , "targetname" );
//	script_brushmodel_spin02_cracked_glass02 hide();	
//	
//	script_brushmodel_spin02_verycracked_glass01 = GetEnt( "script_brushmodel_spin02_verycracked_glass01" , "targetname" );
//	script_brushmodel_spin02_verycracked_glass01 hide();
//	script_brushmodel_spin02_verycracked_glass02 = GetEnt( "script_brushmodel_spin02_verycracked_glass02" , "targetname" );
//	script_brushmodel_spin02_verycracked_glass02 hide();	
//	
//		
//	trigger_spin_cracked_glass01 = GetEnt( "trigger_spin_cracked_glass01", "targetname" );
//	trigger_spin_cracked_glass01 waittill( "trigger" );
//	
//	stop_exploder("spark_loop01");
//	stop_exploder("spark_loop02"); 
//	stop_exploder("spark_loop03");
//	stop_exploder("spark_loop04");
//	stop_exploder("spark_loop05");
//	
//	exploder ("spin02_spark_loop01");
//	exploder ("spin02_spark_loop02");
//	exploder ("spin02_spark_loop03");
//	exploder ("spin02_spark_loop04");
//	
//	thread script_spin02_out_explode();
//	thread script_spin02_kill_airlock01();
//	
//	
//	///-------------------------------------------
//	script_brushmodel_spin_debris_crate01 = get_target_ent( "script_brushmodel_spin_debris_crate01" );
//
//	vehicle_empty_spin_debris_crate01 = GetEnt ( "vehicle_empty_spin_debris_crate01", "targetname" );
//	script_brushmodel_spin_debris_crate01 LinkTo( vehicle_empty_spin_debris_crate01 );
//
//	node_start_spin_debris_crate01 = GetVehicleNode ( "node_start_spin_debris_crate01", "targetname" );	
//	
//	vehicle_empty_spin_debris_crate01 AttachPath ( node_start_spin_debris_crate01 );
//	///-------------------------------------------
//	script_brushmodel_spin_debris_crate02 = get_target_ent( "script_brushmodel_spin_debris_crate02" );
//
//	vehicle_empty_spin_debris_crate02 = GetEnt ( "vehicle_empty_spin_debris_crate02", "targetname" );
//	script_brushmodel_spin_debris_crate02 LinkTo( vehicle_empty_spin_debris_crate02 );
//
//	node_start_spin_debris_crate02 = GetVehicleNode ( "node_start_spin_debris_crate02", "targetname" );	
//	
//	vehicle_empty_spin_debris_crate02 AttachPath ( node_start_spin_debris_crate02 );
//	///-------------------------------------------
//	vehicle_empty_spin_debris_crate01 gopath();
//	vehicle_empty_spin_debris_crate02 gopath();
//	
//	wait .2;	
//
//	script_brushmodel_spin02_cracked_glass01 show();	
//	exploder ("spin02_glass_steam01");
//	
//	wait .7;
//	script_brushmodel_spin02_cracked_glass02 show();
//	exploder ("spin02_glass_steam03");
//	wait 1;	
//	script_brushmodel_spin02_verycracked_glass01 show();	
//	exploder ("spin02_glass_steam02");
//	exploder ("spin02_glass_steam05");
//	wait .5;	
//	script_brushmodel_spin02_verycracked_glass02 show();	
//	exploder ("spin02_glass_steam04");
//	exploder ("spin02_glass_steam06");
//	
//}
//
//script_spin02_kill_airlock01()
//{
//	trigger_spin02_kill_airlock01 = GetEnt( "trigger_spin02_kill_airlock01", "targetname" );
//	trigger_spin02_kill_airlock01 waittill( "trigger" );
//	///-------------------------------------------
//	script_brushmodel_spin_debris_large03 = get_target_ent( "script_brushmodel_spin_debris_large03" );
//
//	vehicle_empty_spin_debris_large03 = GetEnt ( "vehicle_empty_spin_debris_large03", "targetname" );
//	script_brushmodel_spin_debris_large03 LinkTo( vehicle_empty_spin_debris_large03 );
//
//	node_start_spin_debris_large03 = GetVehicleNode ( "node_start_spin_debris_large03", "targetname" );	
//	
//	vehicle_empty_spin_debris_large03 AttachPath ( node_start_spin_debris_large03 );
//	vehicle_empty_spin_debris_large03 gopath();
//	///-------------------------------------------
//	wait 1;
//	level notify("kill_script_spin02_out_explode");
//
//	//wait .1;
//	
//	wait .2;
//	exploder ("spin02_airlock_breach_dust");
//	flag_clear( "clear_to_tweak_player" );
//	SetSavedDvar( "player_swimWaterCurrent" , ( -20000 , 0 , 0 ) ); 
//	wait .4;
//	SetSavedDvar( "player_swimWaterCurrent" , ( -18000 , 0 , 0 ) ); 
//	wait .3;
//	SetSavedDvar( "player_swimWaterCurrent" , ( -10000 , 0 , 0 ) ); 
//	wait .4;
//	SetSavedDvar( "player_swimWaterCurrent" , ( -5000 , 0 , 0 ) ); 
//	wait .4;
//	SetSavedDvar( "player_swimWaterCurrent" , ( 0 , 0 , 0 ) ); 
//	flag_set( "clear_to_tweak_player" );
//	
//	
//
//}
//
//script_spin02_out_explode()
//{
//	level endon( "kill_script_spin02_out_explode" );
//	wait .4;	
//	exploder ("spin02_out_explosion02");
//	wait .5;
//	exploder ("spin02_out_explosion04");
//	wait 1;
//	exploder ("spin02_out_explosion03");
//	wait .5;
//	exploder ("spin02_out_explosion01");
//	wait .2;
//	  
//    while( 1 )
//    {
//        which_explosion = RandomInt( 6 );
//        
//        if( which_explosion == 0 )
//        {
//            exploder ("spin02_out_explosion02");
//        }
//        else if( which_explosion == 1 )
//        {
//            exploder ("spin02_out_explosion04");
//        }
//        else if( which_explosion == 2 )
//        {
//            exploder ("spin02_out_explosion03");
//        }
//        else if( which_explosion == 3 )
//        {
//            exploder ("spin02_out_explosion01");
//        }
//        else if( which_explosion == 4 )
//        {
//            exploder ("spin02_out_explosion05");
//        }
//        else if( which_explosion == 5 )
//        {
//            exploder ("spin02_out_explosion06");
//        }
//        
//        wait RandomFloatRange( .6, 2 );
//    }
//	
//}
//
//escape_corpse_room()
//{
//    //flag_wait( "some_flag" );
//    spawners = GetEntArray( "spin02_room_ally_corpse", "targetname" );
//    foreach( spawner in spawners )
//    {
//        guy = spawner spawn_ai( true );
//        if( spawn_failed( guy ))
//        {
//                        continue;
//        }
//        guy.forceRagdollImmediate = true;
//        guy kill();
//    }
//    
//    wait 1.0;
//
//    // Fire a folt from the ground to get them bodies movin'
//    jolt_org = GetEnt( "spin02_corpse_jolt", "targetname" );
//    vec = randomvector( 0.4 );
//    PhysicsJolt( jolt_org.origin, 60, 10, vec );
//
//    // Give the player a physics aura
//    count = 0;
//    while( 1 )
//    {
//            if ( flag( "odin_escape_start_spinning_room" ) || flag( "spin_clear" ) )
//            {
//                            return;
//            }
//            PhysicsExplosionSphere( level.player.origin, 45, 32, 0.15 );
//            wait 0.05;
//    }
//}



//explosion_micro_pulses( strength , length )
//{
//	flag_clear( "clear_to_tweak_player" );
//	SetSavedDvar( "player_swimWaterCurrent" , ( strength , -2000 , 0 ) );	
//	thread ally_explosion_reaction();
//	wait (length / 2);
//	flag_set( "clear_to_tweak_player" );
//	SetSavedDvar( "player_swimWaterCurrent" , ( 0 , 0 , 0 ) );	
//}
//ally_explosion_reaction()
//{
//	level.ally SetGoalPos( level.ally.origin );
//	angles = level.ally.angles;
//	node = spawn( "script_origin" , level.ally.origin );
//	node.angles = angles;
//	
//	guys = [];
//	guys["odin_ally"] = level.ally;
//}

//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
escape_cleanup( force_immediate_cleanup )
{
}

