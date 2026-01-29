#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\skyway_util;

//*******************************************************************
//																	*
//																	*
//*******************************************************************
section_flag_inits()
{
	flag_init( "flag_loco_end" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
section_precache()
{
	add_hint_string( "hint_plant_charge", "Press ^3[{+activate}]^7 to Plant Charge", ::hint_loco_plant_charge_func );
	add_hint_string( "hint_breach_init", "Press ^3[{+activate}]^7 to Breach", ::hint_loco_breach_init_func );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
section_post_inits()
{
	level._loco = SpawnStruct();
	level._loco.ally_start1 = GetEnt( "ally1_start_loco1", "targetname" );
	level._loco.player_start1 = GetEnt( "player_start_loco1", "targetname" );
	level._loco.ally_start2 = GetEnt( "ally1_start_loco2", "targetname" );
	level._loco.player_start2 = GetEnt( "player_start_loco2", "targetname" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
start_loco()
{
	IPrintLn( "locomotive" );	
	
	// Player
	player_start( level._loco.player_start1 );	
	
	// Allies	
	level._allies[ 0 ] ForceTeleport( level._loco.ally_start1.origin, level._loco.ally_start1.angles );
	level._allies[ 0 ] set_force_color( "r" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
start_breach()
{
	IPrintLn( "locomotive_breach" );
	
	level.cos45 = Cos( 45 );
	
	// Player
	player_start( level._loco.player_start2 );	
	
	// Allies	
	level._allies[ 0 ] ForceTeleport( level._loco.ally_start2.origin, level._loco.ally_start2.angles );
	level._allies[ 0 ] set_force_color( "r" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
main_loco()
{
	level.cos45 = Cos( 45 );
	level.bombs_remaining = 4;
		
	thread loco_bombplace_hesh();
	thread loco_bombplace_player();
	
	while ( level.bombs_remaining )
	{
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
loco_bombplace_hesh()
{
	hesh_bombplace_1 = getstruct( "vignette_heshbombplace1", "targetname" );
	hesh_bombplace_2 = getstruct( "vignette_heshbombplace2", "targetname" );
	
	hesh_bombplace_1 anim_reach_solo( level._allies[0], "loco_bombplace_1" );
	hesh_bombplace_1 anim_single_solo( level._allies[0], "loco_bombplace_1" );
	
	level.bombs_remaining--;
	
	if ( level.bombs_remaining > 2 )
	{
		level waittill( "notify_loco_bombplace_hesh_move" );
	}
	
	hesh_bombplace_2 anim_reach_solo( level._allies[0], "loco_bombplace_2" );
	hesh_bombplace_2 anim_single_solo( level._allies[0], "loco_bombplace_2" );
	
	level.bombs_remaining--;
	
	if ( level.bombs_remaining > 0 )
	{
		level waittill( "notify_loco_bombplace_hesh_move" );
	}
	
	loco_breach_ally_cover_node = GetNode( "loco_breach_ally_cover_node", "targetname" );
	level._allies[0] set_fixednode_false();
	level._allies[0] UseCoverNode( loco_breach_ally_cover_node );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
loco_bombplace_player()
{
	player_bombplace_1 = getstruct( "vignette_playerbombplant1", "targetname" );
	player_bombplace_2 = getstruct( "vignette_playerbombplant2", "targetname" );
	
	for ( i = 0; i < 2; i++ )
	{
		switch ( i )
		{
			case 0:
				level.loco_plant_charge_org = player_bombplace_1;
				break;
				
			case 1:
				level.loco_plant_charge_org = player_bombplace_2;
				break;
		}
		
		level.loco_plant_charge_org.hint_active = false;
		
		thread loco_trigger_logic( level.loco_plant_charge_org, "hint_plant_charge" );
		
		level.loco_plant_charge_org waittill( "trigger" );
		
		// Need to do some blending magic ---
		blend_time = 1.0;
		maps\skyway_util::player_animated_sequence_restrictions();
		level.player_rig = spawn_anim_model( "player_rig" );
		level.player_rig.origin = level.player.origin;
		level.player_rig.angles = level.player.angles;
		level.player_rig Hide();
		level.loco_plant_charge_org thread anim_single_solo( level.player_rig, "loco_bombplace" );
		level.player PlayerLinkToBlend( level.player_rig, "tag_player", blend_time );
		// ---
		
		wait blend_time;
		level.player_rig Show();
		
		while ( !( level.player_rig maps\skyway_util::check_anim_time( "player_rig", "loco_bombplace", 1.0 ) ) )
		{
			wait level.TIMESTEP;
		}
		
		level.bombs_remaining--;
		
		maps\skyway_util::player_animated_sequence_cleanup();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
main_loco_breach()
{
	loco_breach_init_vars();
	
	thread loco_trigger_logic( level.loco_breach_org, "hint_breach_init" );
	
	thread loco_breach_logic();
	
	thread loco_breach_slowmo();
	
	// Trigger detection loco start
//	array_call( level._train.cars[ "train_loco" ].trigs, ::SetMovingPlatformTrigger );
	flag_wait( "flag_loco_end" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
loco_breach_init_vars()
{
	level.loco_breach_org = getstruct( "loco_breach_org", "targetname" );
	level.loco_breach_org.hint_active = false;
	level.loco_breach_anim_node = getstruct( "vignette_vargasstandoff", "targetname" );
	
	level.slowmo_breach_player_speed = 0.2;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
loco_trigger_logic( org, hint )
{
	while ( 1 )
	{
		if ( !IsDefined( org ) )
			return;
		
		if ( !org.hint_active )
		{
			dist = Distance2D( level.player GetEye(), org.origin );
		
			if ( ( dist < 100 ) && within_fov_2d( level.player GetEye(), level.player.angles, org.origin, level.cos45 ) )
			{
				org.hint_active = true;
				
				// tagBR< wtf? >: Apparently you need to call display_hint_timeout() to display a hint that will NOT timeout
				// ...as display_hint(), by default, will timeout after 30 seconds...
				display_hint_timeout( hint );
			}
		}
		
		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hint_loco_plant_charge_func()
{
	dist = Distance2D( level.player GetEye(), level.loco_plant_charge_org.origin );
	
	if ( ( dist < 100 ) && within_fov_2d( level.player GetEye(), level.player.angles, level.loco_plant_charge_org.origin, level.cos45 ) )
	{
		if ( level.player UseButtonPressed() )
		{
			level.loco_plant_charge_org notify( "trigger" );
			return true;
		}
	}
	else
	{
		level.loco_plant_charge_org.hint_active = false;
		return true;
	}
	
	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hint_loco_breach_init_func()
{
	dist = Distance2D( level.player GetEye(), level.loco_breach_org.origin );
	
	if ( ( dist < 100 ) && within_fov_2d( level.player GetEye(), level.player.angles, level.loco_breach_org.origin, level.cos45 ) )
	{
		if ( level.player UseButtonPressed() )
		{
			level.loco_breach_org notify( "trigger" );
			return true;
		}
	}
	else
	{
		level.loco_breach_org.hint_active = false;
		return true;
	}
	
	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
loco_breach_logic()
{
	ally_setup();
	enemy_setup();

	// Wait until breach is triggered
	level.loco_breach_org waittill( "trigger" );
	level.loco_breach_org = undefined;
	
	// We need to save off the player's weapon
	pre_breach_weapon = level.player GetCurrentPrimaryWeapon();
	
	// top off weapon on lower difficulties
	if ( level.gameskill <= 1 )
	{
		clipSize = WeaponClipSize( pre_breach_weapon );
		
		if ( level.player GetWeaponAmmoClip( pre_breach_weapon ) < clipSize )
		{
			level.player SetWeaponAmmoClip( pre_breach_weapon, clipSize );
		}
	}
	
	// Breach Anims ---
	level.loco_breach_anim_node thread anim_single_solo( level._allies[0], "loco_breach" );
	
	level.loco_breach_anim_node thread anim_single( level.loco_breach_enemies, "loco_breach" );
	level.loco_breach_anim_node thread anim_single_solo( level.vargas, "loco_breach" );
	
	// Need to do some blending magic ---
	blend_time = 1.0;
	maps\skyway_util::player_animated_sequence_restrictions();
	blend_player_rig = spawn_anim_model( "player_rig" );
	blend_player_rig.origin = level.player.origin;
	blend_player_rig.angles = level.player.angles;
	blend_player_rig Hide();
	level.loco_breach_anim_node thread anim_single_solo( blend_player_rig, "loco_breach" );
	level.player PlayerLinkToBlend( blend_player_rig, "tag_player", blend_time );
	// ---
	
	level waittill( "notify_loco_breach_door_explode" );
	
	// tagBR< todo >: Eventually it will animate
	loco_breach_door = GetEnt( "loco_breach_door", "targetname" );
	loco_breach_door Hide();
	
	// Destroy the temp rig, create a new one (need LinkToDelta())
	level.player Unlink();
	player_setup( 60, blend_player_rig.origin, blend_player_rig.angles );
	
	// Sync up the anim time
	anim_time = blend_player_rig GetAnimTime( level.scr_anim[ "player_rig" ][ "loco_breach" ] );
	level.loco_breach_anim_node thread anim_single_solo( level.player_rig, "loco_breach" );
	level.player_rig SetAnimTime( level.scr_anim[ "player_rig" ][ "loco_breach" ], anim_time );
	
	blend_player_rig Delete();
	
	thread open_up_fov( 0.2, level.player_rig, "tag_player", 45, 45, 90, 45 );
	
	// Pull out weapon
	level.player EnableWeapons();
	level.player SwitchToWeaponImmediate( pre_breach_weapon );
	
	while ( !( level.player_rig maps\skyway_util::check_anim_time( "player_rig", "loco_breach", 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}
	
	// Standoff Anims ---
	level.loco_breach_anim_node thread anim_single_solo( level._allies[0], "loco_standoff" );
	
	// last frame the enemies
	foreach( dude in level.loco_breach_enemies )
	{
		level.loco_breach_anim_node thread anim_last_frame_solo( dude, "loco_breach" );
	}
	
	level.loco_breach_anim_node thread anim_single_solo( level.vargas, "loco_standoff" );
	
	level.loco_breach_anim_node thread anim_single_solo( level.player_rig, "loco_standoff" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_setup( clamp_angles, rig_origin, rig_angles )
{
	if ( !IsDefined( clamp_angles ) )
	{
		clamp_angles = 60;
	}
	
	maps\skyway_util::setup_player_for_animated_sequence( true, clamp_angles, rig_origin, rig_angles, false, undefined );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ally_setup()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
enemy_setup()
{
	level.vargas = GetEnt( "vargas", "targetname" );
	level.vargas = level.vargas spawn_ai( true );
	level.vargas prepare_enemy_for_breach();
	level.vargas.animname = "vargas";
	
	spawners = GetEntArray( "loco_breach_enemy", "targetname" );
	
	guys = array_spawn( spawners );
	
	for ( i = 0; i < guys.size; i++ )
	{
		guy = guys[i];
	
		guy prepare_enemy_for_breach();
		
		guy.animname = "opfor" + ( i + 1 );
	}
	
	level.loco_breach_enemies = guys;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
prepare_enemy_for_breach()
{
	// self is the enemy
	self set_battlechatter( false );
	self.combatmode = "no_cover";
	self.ignoreall = true;
	self.ignoreme = true;

	self.newEnemyReactionDistSq_old = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
	self.grenadeammo = 0;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// see maps\_slowmo_breach::slowmo_begins()
loco_breach_slowmo()
{
	level waittill( "notify_loco_breach_slowmo_start" );
	
	slomoLerpTime_in = 0.5;
	slomoLerpTime_out = 0.75;

	level.player thread play_sound_on_entity( "slomo_whoosh" );
	level.player thread player_heartbeat();

	//thread slomo_breach_vision_change( ( slomoLerpTime_in * 2 ), ( slomoLerpTime_out / 2 ) );

	thread slowmo_difficulty_dvars();
	flag_clear( "can_save" );
	//slowmo_start();
	
	slowmo_setspeed_slow( 0.25 );
	slowmo_setlerptime_in( slomoLerpTime_in );
	slowmo_lerp_in();
	
	level.player SetMoveSpeedScale( level.slowmo_breach_player_speed );

	// called after the player weapons are force - changed, so this is cool to put here
	//player thread catch_weapon_switch();

	//player thread catch_mission_failed();

	// These are used if we want to break slowmo when player reloads or switches weapon
	//reloadIgnoreTime = 500;// ms
	//switchWeaponIgnoreTime = 1000;
	
	level waittill( "notify_loco_breach_slowmo_end" );

	level notify( "slowmo_breach_ending", slomoLerpTime_out );
	level notify( "stop_player_heartbeat" );

	level.player thread play_sound_on_entity( "slomo_whoosh" );
	slowmo_setlerptime_out( slomoLerpTime_out );
	slowmo_lerp_out();
	
	//slowmo_end();
	flag_set( "can_save" );
	
	level.player slowmo_player_cleanup();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_heartbeat()
{
	// self is player
	
	level endon( "stop_player_heartbeat" );
	
	while ( true )
	{
		self PlayLocalSound( "breathing_heartbeat" );
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
slowmo_difficulty_dvars()
{
	// Get current viewKick values
	old_bg_viewKickScale = GetDvar( "bg_viewKickScale" ); 	// 0.8
	old_bg_viewKickMax = GetDvar( "bg_viewKickMax" );		// 90
	SetSavedDvar( "bg_viewKickScale", 0.3 );		// make the view kick a little easier
	SetSavedDvar( "bg_viewKickMax", "15" );			// make the view kick a little easier

	SetSavedDvar( "bullet_penetration_damage", 0 ); // Disable bullet penetration damage so that hostages are less likely to be shot through enemies

	level waittill( "slowmo_breach_ending" );
	
	// Restore all values when slomo is over
	
	SetSavedDvar( "bg_viewKickScale", old_bg_viewKickScale );	// set view kick back to whatever it was
	SetSavedDvar( "bg_viewKickMax", old_bg_viewKickMax );		// set view kick back to whatever it was
	
	wait( 2 );	//wait a few seconds before resetting bullet dvar
	SetSavedDvar( "bullet_penetration_damage", 1 ); 			// Re - enable bullet penetration
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
slowmo_player_cleanup()
{
	// self is player
	
	AssertEx( IsPlayer( self ), "slowmo_player_cleanup() called on a non-player." );

	if ( IsDefined( level.playerSpeed ) )
		self SetMoveSpeedScale( level.playerSpeed );
	else
		self SetMoveSpeedScale( 1 );
}
