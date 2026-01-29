#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;


end_start()
{
	//iprintlnbold( "End Start" );
	maps\odin_util::move_player_to_start_point( "start_odin_end" );

	thread maps\odin_satellite::tube_rip_sequence();
	// Move the earth down
	// JR TODO - We really need a generic earth mover script
	earthA = GetEnt( "earth_mover_0" , "targetname" );
	earthA MoveZ( -65000 , .05 , 0 , 0 );
	earthA waittill( "movedone" );
	newNode = GetEnt( "spin_skybox_rotator2" , "targetname" );
	earthA linkTo( newNode );
	newNode RotateRoll( 180 , 0.1 );
	thread maps\odin_spacejump::Play_ROG_Hit_FX_On_Earth();
	level.player thread maps\odin_spacejump::damage_player_suit_player( undefined, "satellite_clear");
	//level.player thread burn_up_player();
	//flag_set( "sat_explosion" );
	wait 0.1;
	flag_set ("animated_sequence_complete");
	flag_set ("satellite_traversal_done");

	//maps\odin_util::actor_teleport( level.ally, "odin_end_ally_tp" );
}

section_precache()
{
}

section_flag_init()
{
	flag_init( "end_clear" );
}

section_hint_string_init()
{
}


//================================================================================================
//	MAIN
//================================================================================================
end_main()
{
	flag_wait( "satellite_clear" );
	wait 1;
	level.player thread burn_up_player();
	flag_wait( "sat_explosion" );
	wait 20.0;
	
	flag_set( "start_transition_to_youngblood" );
	flag_set( "end_clear" );
	
	// End the mission
	if( !isDefined( level.prologue ) || isDefined( level.prologue ) && level.prologue == false )
	{
		fade_out( 2.0 );
		nextmission();
	}
	

	// Halt to prevent auto fallthrough into next checkpoint
	flag_wait( "end_clear" );
}

end_setup()
{
	thread maps\_space_player::player_location_check( "exterior" );
}


end_dialogue()
{
}

burn_up_player()
{
	flag_wait( "sat_explosion" );
	IPrintLnBold ("start burning player");
	model3 = Spawn( "script_model", (0,0,0) );
	model0 = Spawn( "script_model", (0,0,0) );
	model1 = Spawn( "script_model", (0,0,0) );
	model2 = Spawn( "script_model", (0,0,0) );
	
	model0 SetModel( "tag_origin" );
	model1 SetModel( "tag_origin" );
	model2 SetModel( "tag_origin" );
	//model3 SetModel( "tag_origin" );
	
	model0.origin = level.player.origin;
	model0.origin = ( model0.origin  + (0,0,0));
	//model3.origin = level.player.origin;
	//model3.origin = ( model3.origin  + (-500,0,0));

	model0 LinkTo( level.player );
	//model3 LinkTo( level.player );
	model1 LinkToPlayerView( self, "j_wrist_le", ( 100, 0, 0 ), ( 0, 0, 0 ), true );
	model2 LinkToPlayerView( self, "j_wrist_ri", ( -100, 100, -300 ), ( 0, 0, 0 ), true );

	PlayFXOnTag( getfx( "glow_red_light_400_strobe" ), model0, "tag_origin" ); // cool for initial hit
	//PlayFXOnTag( getfx( "glow_red_light_400_strobe" ), model3, "tag_origin" ); // cool for initial hit
	thread burn_suit_fx_loop( model1, "rog_launch_barrel", 1.0, 2.0, "end_clear");
	thread burn_suit_fx_loop( model2, "rog_launch_barrel", 1.0, 2.0, "end_clear");
	wait 3;
	PlayFXOnTag( getfx( "glow_red_light_400_strobe" ), model0, "tag_origin" ); // cool for initial hit
	//PlayFXOnTag( getfx( "rog_explosion_odin" ), model3, "tag_origin" ); // cool for initial hit
	thread burn_suit_fx_loop( model1, "rog_launch_barrel", 1.0, 2.0, "end_clear");
	thread burn_suit_fx_loop( model2, "rog_explosion_odin", 5.0, 10.0, "end_clear");
	wait 3;
	thread burn_suit_fx_loop( model1, "rog_launch_barrel", 1.0, 2.0, "end_clear");
	thread burn_suit_fx_loop( model2, "rog_launch_barrel", 1.0, 2.0, "end_clear");
	wait 3;
	PlayFXOnTag( getfx( "glow_red_light_400_strobe" ), model0, "tag_origin" ); // cool for initial hit
	PlayFXOnTag( getfx( "glow_red_light_400_strobe" ), model0, "tag_origin" ); // cool for initial hit
	//PlayFXOnTag( getfx( "rog_explosion_odin" ), model3, "tag_origin" ); // cool for initial hit
	thread burn_suit_fx_loop( model1, "rog_flash_odin", 5.0, 12.0, "end_clear");
	thread burn_suit_fx_loop( model2, "rog_explosion_odin", 2.0, 5.0, "end_clear");
	wait 3;
	//PlayFXOnTag( getfx( "rog_explosion_odin" ), model3, "tag_origin" ); // cool for initial hit
	thread burn_suit_fx_loop( model1, "rog_launch_barrel", 1.0, 2.0, "end_clear");
	thread burn_suit_fx_loop( model2, "rog_explosion_odin", 5.0, 10.0, "end_clear");
	wait 3;
	PlayFXOnTag( getfx( "glow_red_light_400_strobe" ), model0, "tag_origin" ); // cool for initial hit
	//PlayFXOnTag( getfx( "rog_explosion_odin" ), model3, "tag_origin" ); // cool for initial hit
	thread burn_suit_fx_loop( model1, "rog_launch_barrel", 0.3, 1.0, "end_clear");
	thread burn_suit_fx_loop( model2, "rog_explosion_odin", 0.3, 1.0, "end_clear");
	wait 3;
	//PlayFXOnTag( getfx( "rog_explosion_odin" ), model3, "tag_origin" ); // cool for initial hit
	thread burn_suit_fx_loop( model1, "rog_flash_odin", 5.0, 12.0, "end_clear");
	thread burn_suit_fx_loop( model2, "rog_explosion_odin", 2.0, 5.0, "end_clear");
	flag_wait ("end_clear");
	wait 2;
	model1 Delete();
	model2 Delete();
}

burn_suit_fx_loop( link_model, fx, min_time, max_time, end_flag )
{
	if (IsDefined (end_flag))
		level endon( end_flag );
	while (1)
	{
		PlayFXOnTag( getfx( fx ), link_model, "tag_origin" );
		wait RandomFloatRange (min_time, max_time);
	}
}


//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
end_cleanup( force_immediate_cleanup )
{
}