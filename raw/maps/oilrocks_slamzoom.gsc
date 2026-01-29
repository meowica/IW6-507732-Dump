#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;

CONST_SPLINE_SLOMOIN			  = 0.5;
CONST_SPLINE_SLOMO_TRANSITION_OUT = 0.4;

vehicle_spline_cam( noteworthy, slomo_in, blend_to_tag_time, tailflash )
{
	if ( !IsDefined( slomo_in ) )
		slomo_in = CONST_SPLINE_SLOMOIN;
	currVis	   = spline_cam_intro( slomo_in );
	start_node = GetVehicleNode( noteworthy, "targetname" );
	Assert( IsDefined( start_node ) );
	vehicle_camera = SpawnVehicle( "tag_origin", "spline_cam_vehicle", "empty", start_node.origin, start_node.angles );
	vehicle_camera AttachPath( start_node );
	vehicle_camera StartPath();
	vehicle_camera thread play_sound_on_entity( "scn_oilrocks_slamzoom" );
	if ( !IsDefined( blend_to_tag_time ) )
		blend_to_tag_time = 0.4;
	level.player PlayerLinkToBlend( vehicle_camera, "tag_origin", blend_to_tag_time, 0, 0 );
	vehicle_camera waittill ( "reached_end_node" );
	spline_cam_outro( currVis, slomo_in, tailflash );
	vehicle_camera Delete();
}

spline_cam_intro( slomo_in )
{
	if ( !IsDefined( slomo_in ) )
		slomo_in = CONST_SPLINE_SLOMOIN;
	currVis = GetDvar( "vision_set_current" );
	vision_set_changes( "cheat_bw", 0.1 );
	thread digitalFlash( 0.125 );
	SetSlowMotion( 1, slomo_in, CONST_SPLINE_SLOMO_TRANSITION_OUT );	
	level.player EnableInvulnerability();
	stashLoudout();
	return currVis;
}

stashLoudout()
{
	current = level.player GetCurrentPrimaryWeapon();
	if ( ( IsDefined( current ) ) &&  ( current != "none" ) )
		maps\_loadout_code::SavePlayerWeaponStatePersistent( "oilrocks", true );
	level.player TakeAllWeapons();
}

spline_cam_outro( currVis, slomo_in, tailflash )
{
	if ( !IsDefined( slomo_in ) )
		slomo_in = CONST_SPLINE_SLOMOIN;
	level.player Unlink();
	level.player delayCall( 1, ::DisableInvulnerability );
	if( ! maps\_loadout_code::RestorePlayerWeaponStatePersistent( "oilrocks", true, true ) )
		maps\_loadout::give_loadout();

	if ( IsDefined( tailflash ) && tailflash )
		thread digitalFlash( 0.35 );
	SetSlowMotion( slomo_in, 1, CONST_SPLINE_SLOMO_TRANSITION_OUT );
	vision_set_changes( currVis, CONST_SPLINE_SLOMO_TRANSITION_OUT );	
}

digitalFlash( time )
{
	level.player DigitalDistortSetParams( 0.5, 1 );
	wait time;
	level.player DigitalDistortSetParams( 0, 1 );
}

precache_zoom()
{
	PrecacheVehicle( "empty" );
}