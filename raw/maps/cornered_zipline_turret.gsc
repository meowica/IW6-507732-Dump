#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\cornered_code;
#include maps\player_scripted_anim_util;

player_handle_zipline_turret( turret )
{
	wait( 1.75 );
	level.fake_turret SetModel( "weapon_zipline_rope_launcher_alt_obj" );
	
	zipline_launcher_trigger = GetEnt( "zipline_launcher_trigger_player", "targetname" );
	zipline_launcher_trigger SetCursorHint( "HINT_NOICON" );
	//"Press and hold [{+activate}] to deploy zipline launcher. "
	zipline_launcher_trigger SetHintString( &"CORNERED_DEPLOY_ZIPLINE_TURRET" );
	
	zipline_launcher_lookat = getstruct( "zipline_launcher_lookat", "targetname" );
	waittill_trigger_activate_looking_at( zipline_launcher_trigger, zipline_launcher_lookat, Cos( 40 ), false, true );
	
	flag_set( "zipline_launcher_setup" );
	
	level.fake_turret SetModel( "weapon_zipline_rope_launcher_alt" );
	
	thread maps\cornered_audio::aud_zipline( "unfold" );
	
	if ( IsDefined( level.player.binoculars_active ) && level.player.binoculars_active )
	{
		level.player notify( "use_binoculars" );
		waittillframeend;
	}
	maps\cornered_binoculars::take_binoculars();
	
	//level.player DisableWeapons();
	level.player _disableWeapon();
	level.player SetStance( "stand" );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	if ( level.player GetStance() == "crouch" || level.player GetStance() == "prone" )
		wait 1;
		
	level.zipline_anim_struct anim_first_frame_solo( level.cornered_player_arms, "cornered_launcher_setup_player" );
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", 0.5 );
	wait( 0.5 );
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
	show_player_arms();
	
	thread lerp_fov_to_turret();
												   //   guy 			   anime 						   
	level.zipline_anim_struct thread anim_single_solo( level.fake_turret, "zipline_launcher_setup_player" );
	level.zipline_anim_struct anim_single_solo( level.cornered_player_arms, "cornered_launcher_setup_player" );
	
	turret.origin = level.fake_turret.origin;
	
	level.player Unlink();
	
	hide_player_arms();
	
	thread player_viewhands_zipline_launcher( turret, "viewhands_player_sas" );
	
	level.fake_turret Hide();
	
	turret Show();
	turret MakeTurretOperable();
	turret UseBy( level.player );
	
	flag_set( "player_on_turret" );
	
	turret thread turret_moving();
			
	self DisableTurretDismount();
	turret TurretFireEnable();
	
	thread display_zipline_fire_hint();
	
	level.zipline_anim_struct anim_first_frame_solo( level.cornered_player_arms, "cornered_zipline_launcher_fire_playerarms" );
	
	turret waittill( "turret_fire" );
	ScreenShake( level.player.origin, 2, 0, 0, 0.75, 0, -1, 0, 17 );
	waitframe();
	
	turret TurretFireDisable();
	
	self EnableTurretDismount();
	turret MakeTurretInoperable();
	turret SetTurretDismountOrg( level.cornered_player_arms GetTagOrigin( "tag_player" ) );
	turret UseBy( self );
	
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	
	turret Hide();
	level.fake_turret Show();
	
	thread launch_rope_player( turret );
	waitframe();
												   //   guy 					    anime 									    
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", 0.25 );
	wait( 0.25 );
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
	show_player_arms();
												   //   guy 					    anime 									    
	level.zipline_anim_struct thread anim_single_solo( level.fake_turret		 , "zipline_launcher_fire_player" );
	level.zipline_anim_struct thread anim_single_solo( level.cornered_player_arms, "cornered_zipline_launcher_fire_playerarms" );
	
	flag_set( "player_fired_zipline" );
	wait 1;
	flag_set( "obj_fire_zipline" );
	
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	hide_player_arms();
	level.player Unlink();
	//level.player EnableWeapons();
	level.player _enableWeapon();
	
	if ( GetDvar( "raven_demo" ) == "0" )
	{
		if ( !flag( "double_agent_confirmed" ) )
			maps\cornered_binoculars::give_binoculars();
	}
}

display_zipline_fire_hint()
{
	level endon( "player_fired_zipline" );
	
	while ( true )
	{
		wait( 7.0 );
		
		level.player thread display_hint( "fire_zipline" );
	}

}

turret_moving()
{
	last_aim_vector = level.player GetPlayerAngles();
	
	while ( !flag( "player_fired_zipline" ) )
	{
		aim_vector = level.player GetPlayerAngles();
		
		if ( Distance( last_aim_vector, aim_vector ) > 0.01 )		// ignore changes in movement less than 0.0005
		{
			thread maps\cornered_audio::aud_zipline( "aim", Distance( last_aim_vector, aim_vector ) );
		}
		else
		{
			thread maps\cornered_audio::aud_zipline( "stop_loop" );
		}
		
		last_aim_vector = aim_vector;
		
		waitframe();
	}
}

lerp_fov_to_turret()
{
	level.player LerpFOV( 55, 8 );	
}

//lerp_player_off_turret()
//{
//	lerp_player_view_to_position_accurate( level.player.origin, level.player.angles, 1.0 );
//	
//	//view_pos	  = ( -29282, -4775, 27216 );
//	view_pos	  = ( -29200, -4824, 27216 );
//	//view_angles = ( 1.7, 32.0, 0 );
//	view_angles	  = ( 0, 50, 0 );
//	view_offset	  = view_pos - level.player.origin;
//	lerp_player_view_to_position_accurate( level.player.origin + view_offset, view_angles, 1.0 );
//	level.player Unlink();
//	level.player EnableWeapons();
//}

launch_rope_player( zipline_launcher )
{
	thread maps\cornered_audio::aud_zipline( "rope_shot", ( -29190, -4758, 27276 ) );
	level.zipline_rope Show();
	PlayFXOnTag( level._effect[ "zipline_shot" ]	  , zipline_launcher  , "tag_flash" );
	PlayFXOnTag( level._effect[ "vfx_zipline_tracer" ], level.zipline_rope, "J_zip_1" );
	thread launch_rope( level.zipline_anim_struct, level.zipline_rope, "cornered_zipline_playerline_launched", "cornered_zipline_playerline_at_rest_loop" );
	wait( 5 );
	flag_set( "player_can_use_zipline" );
}

#using_animtree( "player" );
player_viewhands_zipline_launcher( turret, viewhands_model )
{
	level.player endon( "missionend" );
	
	turret UseAnimTree(#animtree );
	turret.animname	 = "zipline_hands";
	turret.has_hands = false;
	turret show_hands( viewhands_model );
	
	turret thread handle_mounting( viewhands_model );
	
	turret SetAnim( %cornered_zipline_aim_idle_playerarms, 1, 0, 1 );
}

handle_mounting( viewhands_model )
{
    turret = self;
    turret endon ( "death" );
    while ( true )
    {
        turret waittill ( "turretownerchange" );
        owner = turret GetTurretOwner();
        if ( !IsAlive( owner ) )
            hide_hands( viewhands_model );
        else
            show_hands( viewhands_model );
    }
}

show_hands( viewhands_model )
{
	turret				= self;
	Assert( turret.code_classname == "misc_turret" );
	Assert( IsDefined( turret.has_hands ) );
    if ( turret.has_hands )
        return;
    turret DontCastShadows();
	turret.has_hands = true;
	turret Attach( viewhands_model, "TAG_ARMS_ATTACH" );
}

hide_hands( viewhands_model )
{
	turret				= self;
	Assert( turret.code_classname == "misc_turret" );
	Assert( IsDefined( turret.has_hands ) );
    if ( ! turret.has_hands )
        return;
	turret CastShadows();
	turret.has_hands = false;
	turret Detach( viewhands_model, "TAG_ARMS_ATTACH" );
}

//#using_animtree( "player" );
//anim_zipline_launcher_hands()
//{
//	level.scr_animtree[ "zipline_hands" ]		   = #animtree;
//	level.scr_model	  [ "zipline_hands" ]		   = "viewhands_player_sas";
//	level.scr_anim[ "zipline_hands" ][ "idle_R"	 ] = %cornered_zipline_aim_idle_playerarms;
//	}

/*QUAKED misc_turret_zipline_sp (1 0 0) (-16 -16 0) (16 16 56) pre-placed
Spawn Flags:
	pre-placed - Means it already exists in map.  Used by script only.

Key Pairs:
	leftarc - horizonal left fire arc.
	rightarc - horizonal left fire arc.
	toparc - vertical top fire arc.
	bottomarc - vertical bottom fire arc.
	yawconvergencetime - time (in seconds) to converge horizontally to target.
	pitchconvergencetime - time (in seconds) to converge vertically to target.
	suppressionTime - time (in seconds) that the turret will suppress a target hidden behind cover
	maxrange - maximum firing/sight range.
	aiSpread - spread of the bullets out of the muzzle in degrees when used by the AI
	playerSpread - spread of the bullets out of the muzzle in degrees when used by the player
	defaultmdl="weapon_zipline_rope_launcher_alt"
	default:"weaponinfo" "zipline_sp"
*/