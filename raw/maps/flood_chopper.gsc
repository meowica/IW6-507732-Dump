#include maps\_utility;
#include common_scripts\utility;

section_main()
{
}

section_precache()
{
	precacheshader( "hint_mantle" );
}

section_flag_inits()
{
	flag_init( "player_jumped" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

chopper_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "chopper_start" );
	
	//set_audio_zone( "flood_chopper", 2 );
	
	// spawn the allies
	maps\flood_util::spawn_allies();
}

chopper()
{
//	level thread autosave_now();
//	
//	//"Press [{+gostand}] to "
//	level.strings[ "mantle" ]				 = &"SCRIPT_MANTLE";
//	maps\_hud_util::create_mantle();
//	
//	level thread breach_heli_door();
//	
//	level thread helicopter_jump();
//	
//	level thread helicopter_fail();
//	
//	level waittill( "rorke_heli_end" );
//	
//	level.player EnableWeapons();
//	
//	maps\flood_util::player_move_to_checkpoint_start( "flooding_ext_start" );
}

breach_heli_door()
{
    trigger_anim = GetEnt("kick_door_trigger", "targetname");
    //breach_start_trigger = GetEnt( "trigger_use_breach", "classname" );
    trigger_anim SetHintString( &"SCRIPT_PLATFORM_BREACH_ACTIVATE" );
    trigger_anim UseTriggerRequireLookAt();
    
    trigger_anim waittill("trigger");
    
    trigger_anim trigger_off();
    
    level thread breach_door( "anim_node_breach_door", ::open_church_doors, ::church_weapon_pullout );
    
    maps\flood_util::hide_scriptmodel_by_targetname( "embassy_door_collision" ); 
}

breach_door(anim_struct_targetname, open_door_function, weapon_pullout_function)
{
//    level.open_door_note_fn = open_door_function;
//    level.weapon_pullout_note_fn = weapon_pullout_function;
//    level.slowmo_breach_note_fn = slowmo_function;
//    level.slowmo_breach_note_arg = slowmo_arg;
    
    level.player DisableWeapons();
    level.player AllowCrouch( false );
    level.player AllowProne( false );
    level.player AllowSprint( false );
    level.player AllowJump( false );
        
    level.breach_player_rig = spawn_anim_model( "breach_player_rig" );
    level.breach_player_legs = spawn_anim_model( "breach_player_legs" );
    
    guys = [];
    guys[ "breach_player_rig" ] = level.breach_player_rig;
    guys[ "breach_player_legs" ] = level.breach_player_legs;
        
    scene = "lowtech_breach";

    level.player PlayerLinkToBlend( level.breach_player_rig, "tag_player", 0.2, 0.1, 0.1 );
    
    struct = getstruct( anim_struct_targetname, "targetname" );
    struct thread maps\_anim::anim_single( guys, scene );
    
    struct waittill( scene );
    
    level.player Unlink();

    level.player AllowCrouch( true );
    level.player AllowProne( true );
    level.player AllowSprint( true );
    level.player AllowJump( true );

    level.breach_player_rig Delete();
    level.breach_player_legs Delete(); 
}

open_church_doors( guy )
{
    breach_door_left = GetEnt( "embassy_door_main_left", "targetname" );
    breach_door_right = GetEnt( "embassy_door_main_right", "targetname" );
    
    breach_door_left RotateYaw( 90, 0.2, 0.1, 0.1 );
    breach_door_right RotateYaw( -90, 0.2, 0.1, 0.1 );
    
    embassy_door_collision = GetEnt( "embassy_door_collision", "targetname" );
    embassy_door_collision ConnectPaths();
    
    flag_set( "vignette_heli_crash" );
}

church_weapon_pullout( guy )
{
    level.player EnableWeapons();
    arc = 180;
    //level.player PlayerLinkToDelta( level.breach_player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
    level.player PlayerLinkToDelta( level.breach_player_rig, "tag_player", .5, arc, arc, arc, arc, 1 );
}

helicopter_jump()
{
	level endon( "heli_got_away" );
	level endon( "rorke_heli_end" );
	
	// Helicopter Event Animation Controller
	
	// End Jump Trigger
	end_jump();
	
	flag_set( "player_jumped" );
	
	level notify( "player_jumped_to_heli" );

	level.player DisableWeapons();	
	
//	maps\flood_anim::heli_crash_player_jump();
	
//	level waittill( "first_heli_enemy_dead" );
	
//	maps\flood_anim::heli_crash_fight_02();
	
//	maps\flood_anim::heli_crash_fight_03();
}

end_jump()
{
	level endon( "heli_got_away" );
	level endon( "rorke_heli_end" );

	jump = GetEnt( "trig_heli_jump", "targetname" );
	NotifyOnCommand( "jump", "+gostand" );
	NotifyOnCommand( "jump", "+moveup" );

	jump thread end_jump_mantle();

	jump waittill( "trigger" );

	while ( 1 )
	{
		level.player waittill( "jump" );

		if ( level.player IsTouching( jump ) && level.player GetStance() == "stand" && end_mantle_angle() )
			break;
	}

	level.hud_mantle[ "text" ].alpha = 0;
	level.hud_mantle[ "icon" ].alpha = 0;
}

end_mantle_angle()
{
	level endon( "heli_got_away" );
	level endon( "rorke_heli_end" );
	
	angles = level.player GetPlayerAngles();

	vec1 = AnglesToForward( angles );
	vec2 = VectorNormalize( level.rorke_heli.origin - level.player.origin );

	if ( VectorDot( vec1, vec2 ) > 0.75 )
		return true;
	else
		return false;
}

end_jump_mantle()
{
	level endon( "end_start_player_anim" );
	level endon( "end_seaknight_leaving" );
	level endon( "heli_got_away" );
	level endon( "rorke_heli_end" );

	while ( 1 )
	{
		self waittill( "trigger" );

		if ( end_mantle_angle() )
			level.hud_mantle[ "text" ].alpha = 1;
			level.hud_mantle[ "icon" ].alpha = 1;

		while ( level.player IsTouching( self ) && end_mantle_angle() )
			wait 0.05;

		level.hud_mantle[ "text" ].alpha = 0;
		level.hud_mantle[ "icon" ].alpha = 0;
	}
}

end_nojump()
{
	level endon( "heli_got_away" );
	level endon( "rorke_heli_end" );

	nojump = GetEnt( "trig_heli_nojump", "targetname" );

	while ( 1 )
	{
		nojump waittill( "trigger" );

		flag_set( "end_no_jump" );
		level.player AllowJump( false );

		while ( level.player IsTouching( nojump ) )
			wait 0.05;

		level.player AllowJump( true );
	}
}

helicopter_fail()
{
	level endon( "player_jumped" );
	
	level waittill( "heli_got_away" );
	
    SetDvar( "ui_deadquote", &"FLOOD_HELICOPTER_ESCAPED" );
    self thread maps\_utility::missionFailedWrapper();
}
