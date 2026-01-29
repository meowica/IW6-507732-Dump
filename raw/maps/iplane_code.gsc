#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\iplane;

zerog()
{
	time_min = 12;
	time_max = 16;
	time	 = 6;
	//	thread plane_ground_reference_rotate( time, time_min, time_max );

	level endon( "kill_free_fall" );
	level waittill ( "start_freefall" );
	//level.player playerSetGroundReferenceEnt( level.org_view_roll );
	//thread plane_ground_reference_rotate();
	
	level.zerog_origin = getstruct( "all_plane_origin", "targetname" );
	//	flag_wait( "zero_g_trig" );
	rand = RandomFloatRange( 0.25, 0.75 );
	wait rand;
	level.player DisableWeapons();
	wait( 0.25 );
	//flag_set( "stop_rocking" );
	//	level notify("stop_rocking");
	//	flag_set( "stop_constant_shake" );
	//	level.hallway_roller notify( "stop_hallway_shake" );
	
	/*level.commander disable_ai_color();
	level.hero_agent_01 disable_ai_color();
	level.president disable_ai_color();
	
	level.commander hide();
	
	battlechatter_off( "axis" );*/
	
	//	aud_send_msg("zero_g_start");
	// thread pre_zerog_cleanup();
	thread zerog_player_anim();
	//	thread zerog_anims();
	// thread zerog_props();
	// thread zerog_physics();``
	
	wait( 0.5 );

	SetSavedDvar( "phys_gravityChangeWakeupRadius", 3200 );
	SetSavedDvar( "ragdoll_max_life"			  , 3600000 );
}

in_air_sequence()
{
}

player_on_back() // send player backwards sequence
{	
	player_on_back_pre_one = GetEnt( "player_on_back_pre_one", "targetname" );
	
	player_on_back_one = GetEnt( "player_on_back_one", "targetname" );
	
	player_climb_one = GetEnt( "r_plane_player_climb_one", "targetname" );
	
	start_fall_spots = GetEntArray( "player_on_back", "targetname" );
	
	start_spot = getClosest( level.player.origin,  start_fall_spots, 1000 );
	
	start_spot_model = Spawn( "script_model", start_spot.origin );
	start_spot_model SetModel( "tag_origin" );
	start_spot_model LinkTo( level.plane_core );
	
	level.player EnableSlowAim( 0.4, 0.4 );
	level.player DisableWeapons();
	
	level.chair_vargas_2.reference anim_stopanimscripted();
	level.vargas AllowedStances( "crouch" );
	
	flag_set( "ground_rotate_ref" );
	
	
	level.fadein thread maps\_hud_util::fade_over_time( 0, 0.5 );

	wait 3.4;
	left_wing = GetEnt( "c17_left_wing", "targetname" );
	PlayFX( getfx( "explosion_1" ), left_wing.origin + ( 0, -200, -40 ) );
	level.player ShellShock( "hijack_minor", 4.0 ); // minor
	Earthquake( 0.4, 1.3, level.player.origin, 5000 );
	wait 1.3;
	
	Earthquake( 0.2, 0.5, level.player.origin, 5000 );

	wait 1.7;
	
	thread anim_first_roll_everyone();
	
	level.ground_brush.origin = level.plane_core.origin + ( 0, 0, -6000 );
	
	//level.new_org = spawn ( "script_origin", level.plane_core.origin );
	
	//level.ground_brush linkto( level.new_org );
	
	wait 4.3;
	
	level notify( "start_second_enemy_plane" );
	
//	Earthquake( 0.3, 6, level.player.origin, 5000 );	
	level.plane_core thread batman_rotate_plane();

	//level.new_org rotateto( ( -90, 0, 0 ), 8, 6, 1 );
	
	//	thread fake_rotate_of_ai();
	
	//	level.new_org rotateto(  ( 30, 90, 120 ), 4 ); // 4
	
	wait 4;

	wait 1.3;
	
	//Earthquake( 0.6, 1, level.player.origin, 50000 );
	//playfx( getfx(  "big" ), level.chair_vargas.origin );
	
	//level.player ShellShock( "hijack_airplane", 1.5); //  hijack_minor
	//Earthquake( 0.6, 3, level.player.origin, 50000 );
	
	wait 1.5;
	
	//	level.vargas LinkToBlendToTag( ref_bad_guy_kick_player, "tag_origin" );
	//	level.player PlayerLinkToDelta( player_on_back_pre_one, "", 170, 180, 180, 180, 180 );
	
	//	level.c17_left_wing moveto( c17_left_wing_end_spot.origin, 7, 3, 3 ) ;
	//	z_random_one = getrandomfloatrange( 40, 300 );
	//	level.c17_left_wing rotateto( ( -70, -50, z_radnom_one ), 3 );
	
	wait 3;
	
	//	level.vargas AllowedStances( "stand" );
	//	level.vargas.allowpain = false

	//  level.player_rig LinkToBlendToTag( level.player, "tag_origin" );
	//	level.player_rig Hide();
	//	level.player PlayerLinkToBlend( player_climb_one, "", 1.3, 1.2, 1 );
	//	wait 1;
		//level.player_rig delete();
	//	level.player playerlinktodelta( player_on_back_one, "", 0.3, 0.4, 0.1, true );
	//	wait 0.5;	
	//	level.player ShellShock( "hijack_airplane", 1.5 );
	//	level.player PlayerLinkToDelta( player_climb_one, "", 1, 180, 180, 180, 180, true );
	
//	Earthquake( 0.7, 1.4, level.player.origin, 50000 );
	
//		time_min = 12;
//		time_max = 16;
//		time	 = 6;
//		flag_clear( "ground_rotate_ref" );
	//	thread plane_ground_reference_rotate( time, time_min, time_max );
	
	// move price to position next to player.
	// move origin up while the anim loops
	
	//	level.player DisableSlowAim();
	//	level.player TakeAllWeapons();
		
//		starttimescale	= 1;  //0.15
//		endTimescale_to = 0.2;//1
//		time			= 1.5;//1.8
//		slow_mo_think( starttimescale, endTimescale_to, time );
	
	//	thread give_player_p99_back();
	
	wait 2;

//		starttimescale	= 0.5;//0.15
//		endTimescale_to = 1;  //1
//		time			= 1.8;//1.8
//		slow_mo_think( starttimescale, endTimescale_to, time );
	wait 1.8;
}

anim_first_roll_everyone()
{		
	level.mccoy_anim_org anim_stopanimscripted();
	level.kersey_anim_org anim_stopanimscripted();
	level.knees_two_anim_org anim_stopanimscripted();
	level.knees_one_anim_org anim_stopanimscripted();
	
	level.price Hide();
	level.mccoy Hide();
	level.kersey Hide();
	level.knees_one Hide();
	level.knees_two Hide();
	
	level.price_origin		  = Spawn( "script_origin", level.price.origin );
	level.price_origin.origin = level.price_origin.origin + ( 0, 0, 90 );
	
	level.mccoy_anim_org.origin		= level.mccoy_anim_org.origin + ( 120, 0, 150 );
	level.kersey_anim_org.origin	= level.kersey_anim_org.origin + ( 20, 0, 70 );
	level.knees_two_anim_org.origin = level.knees_two_anim_org.origin + ( 0, 30, 65 );
	level.knees_one_anim_org.origin = level.knees_one_anim_org.origin + ( 90, 190, 89 );
	
//	level.chair_vargas Unlink();
//	level.chair_vargas.origin = level.chair_vargas.origin + ( 0, 0, 70 );
	
//	level.price_origin thread anim_single_solo( level.price, "zerog_two" );
//	level.mccoy_anim_org thread anim_single_solo( level.mccoy, "zerog_one" );
//	level.kersey_anim_org thread anim_single_solo( level.kersey, "zerog_two" );		
//	level.knees_two_anim_org thread anim_single_solo( level.knees_two, "zerog_four" );
//	level.knees_one_anim_org thread anim_single_solo( level.knees_one, "zerog_three" );
	
}

plane_ground_reference_rotate( time, time_min, time_max )
{
	//	level endon ( "ground_rotate_ref" );
	
	//ent = getent( "player_on_back_pre_one", "targetname" );
	
	ent = Spawn( "script_origin", ( 0, 0, 0 ) );
	level.player PlayerSetGroundReferenceEnt( ent );
	
	while ( !flag ( "ground_rotate_ref" ) )
	{
		wait( time );
		time_to_turn = RandomFloatRange( time_min, time_max );
		//ent RotateRoll( -12, time );
		ent RotateTo( ( 0, 0, -12 ), time_to_turn );
		time_to_turn = RandomFloatRange( time_min, time_max );
		wait( time );
		//ent RotateRoll( 12, time );
		ent RotateTo( ( 0, 0, 12 ), time_to_turn );
	}
}

give_player_p99_back()
{
	wait 0.6;
	level.player GiveWeapon( "p99" );
	level.player SetWeaponAmmoClip( "p99", 5 );
	level.player SetWeaponAmmoStock( "p99", 5 );
	level.player EnableWeapons();
	level.player SwitchToWeapon( "p99" );
	
}

move_primary_light( light )
{
	thread move_with_plane( light );
	light SetLightIntensity( 1.5 );
	
	//	wait( 25 );
	//	intensity = light GetLightIntensity();
	//	while ( intensity > 0 )
	//	{
	//		intensity -= 0.1;
	//		light SetLightIntensity( intensity );
	//		wait( 0.05 );
	//	}
	////	light notify( "kill_light" );
	//	wait( 0.05 );
	//	light SetLightIntensity( 0 );
}

move_with_plane( light )
{
	follow_ent = Spawn( "script_origin", light.origin );
	follow_ent LinkTo( level.plane_core );
	light endon( "kill_light" );
	//	offset = ( light.origin - level.plane_core.origin );
	
	while ( 1 )
	{
		light MoveTo( follow_ent.origin, 0.05 );
	//		light MoveTo( level.plane_core.origin + offset, 0.05 );
		wait( 0.05 );
	}
}

#using_animtree( "generic_human" );
zerog_player_anim() //  
{	
	//	level waittill( "start_zerog" );
	
	level.player SetStance( "stand" );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player EnableDeathShield( true );
	//level.player EnableInvulnerability();
	
	if ( level.console )
	{
		SetSavedDvar( "aim_aimAssistRangeScale", "1" );
		SetSavedDvar( "aim_autoAimRangeScale"  , "0" );
	}
	level.player EnableSlowAim( 0.4, 0.4 );

	weaponlist	  = level.player GetWeaponsListAll();
	currentweapon = level.player GetCurrentWeapon();
	

	
	waittillframeend;
	weaponlist	  = level.player GetWeaponsListAll();
	currentweapon = level.player GetCurrentWeapon();
	
	level.zerog_player_rig = spawn_anim_model( "test_body", level.zerog_origin.origin );
	level.player PlayerSetGroundReferenceEnt( level.zerog_player_rig );
	
	level.player PlayerLinkToBlend( level.zerog_player_rig, "tag_origin", .5, 0, 0 );
	
	end_wait = GetAnimLength( %hijack_zero_g_player );
	
	//end_wait = level.zerog_player_rig GetAnimLength( level.zerog_player_rig getanim ( "zero_g_player" ) );
	thread kill_angles_when_anim_done( end_wait );

	level.zerog_origin thread anim_single_solo( level.zerog_player_rig, "zero_g_player" );
	
	//turn the player slightly before he hits the floor.
	playerAnim			= %hijack_zero_g_player;
	animlength			= GetAnimLength( playeranim );
	hit_floor_notetrack = GetNotetrackTimes( playerAnim, "player_hit_floor" )[ 0 ];
	time				= ( animlength * hit_floor_notetrack );
	
	wait( 0.5 );
	//level.player PlayerLinkToDelta(player_rig, "tag_origin", 1, 180, 180, 60, 60);

	wait( 1 );
	//DELETING PRE-ZEROG GUYS SO THEY DON'T RAGDOLL ALL OVER THE PLACE.
	// pre_guys = GetEntArray( "pre_zerog_terrorists", "script_noteworthy");
	// foreach(terrorist in pre_guys)
	//{
	//	terrorist delete();
	//}
	
	wait( time - 2.5 );
	level.player PlayerLinkToBlend( level.zerog_player_rig, "tag_origin", 1, 0, 0 );
	
	level.zerog_player_rig waittillmatch( "single anim", "player_hit_floor" );
	
	SetSavedDvar( "phys_gravityChangeWakeupRadius", level.orig_WakeupRadius );
	SetSavedDvar( "ragdoll_max_life"			  , level.orig_ragdoll_life );
	
	level.player DisableWeapons();
	//level.player ShellShock( "hijack_airplane", 3.0);
	level.player PlayerSetGroundReferenceEnt( level.org_view_roll );
	//	aud_send_msg("zero_g_bodyslam1");
	//	level.player thread play_sound_on_entity( "hijk_explosion_lfe" );
	level.player.ignoreme = false;
	//Earthquake( 0.5, 2.0, level.player.origin, 6000 );
	if ( level.console )
	{
		SetSavedDvar( "aim_aimAssistRangeScale", "1" );
		SetSavedDvar( "aim_autoAimRangeScale"  , "1" );
	}
	level.player DisableSlowAim();
	level.player EnableDeathShield( false );
	level.player DisableInvulnerability();
	
	level.zerog_player_rig waittillmatch( "single anim", "end" );
	
	weaponlist	  = level.player GetWeaponsListAll();
	currentweapon = level.player GetCurrentWeapon();
	
	
	waittillframeend;
	weaponlist	  = level.player GetWeaponsListAll();
	currentweapon = level.player GetCurrentWeapon();
	
	//	allEnts = GetEntArray( "weapon_ak74u_zero_g", "classname" );
	//	foreach( ent in allEnts )
	//	{
	//		ent delete();
	//	}
	
	//	thread zerog_swap_destruct_fx();
	//	thread constant_rumble();
	
	level.player Unlink();
	level.zerog_player_rig Delete();
	level.player EnableWeapons();
	level.player AllowSprint( true );
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	
	//	wait(2);
	//thread autosave_by_name( "post_zero_g" );
	//	autosave_now();
}

kill_angles_when_anim_done( end_wait )
{
	wait( end_wait );
	level.player PlayerSetGroundReferenceEnt( undefined );
}

zerog_firsthit( guy )
{
	// PLANE LURCHES
	//-- AFFECT PLAYER --
	//level.player PlayRumbleOnEntity( "hijack_plane_large" );
	level.player DisableWeapons();	
	Earthquake( 0.15, 0.6, level.player.origin, 6000 );
	level.player ShellShock( "hijack_minor", 1.5 );
	
	//-- AFFECT PROPS & RAGDOLL --
	// array_thread( level.aRollers, ::rotate_rollers_to, (0, 0, 12.0), 1, 0, 0 );
	//setPhysicsGravityDir( (0, 0, -1) );
	LerpSunAngles( ( -5, 114, 0 ), ( -24, 96, 0 ), 1 );
		
	wait( 0.4 );
	physicspush = GetEntArray( "zerog_physics", "targetname" );
	foreach ( object in physicspush )
	{
		PhysicsExplosionSphere( object.origin, 64, 32, .45 );
	}
	
	wait ( 0.3 );
	SetPhysicsGravityDir( ( 0.00, 0.00, -0.02 ) );
	//	aud_send_msg("zero_g_bodyslam2");
	wait( 0.7 );
	
	// PLANE LEVELS	OFF
	//level.player ShellShock( "hijack_slowview", 5);
	//array_thread( level.aRollers, ::rotate_rollers_to, (0, 0, 0), .75, 0, 0 );
	SetPhysicsGravityDir( ( 0, -0.02, -1 ) ); //moving to right of plane
}

zerog_flyup( guy )
{
	level endon( "plane_roll_right" );
	// THROW PLAYER IN AIR
	//-- AFFECT PLAYER --
	Objective_Delete( obj( "move_president" ) );
	//	thread player_physics_explosion();
	SetPhysicsGravityDir( ( 0.02, -0.01, 0.08 ) ); //moving to front and right of plane
	
	//-- AFFECT PROPS & RAGDOLL --
	SetSavedDvar( "phys_gravity"		, -5 );
	SetSavedDvar( "phys_gravity_ragdoll", -100 );
	//wait(2.5);
	wait( 2.0 );
	
	wait( 0.5 );
	
	level.player PlayerLinkToDelta( level.zerog_player_rig, "tag_origin", 1, 180, 180, 60, 60 );
	level.player EnableWeapons();
}

zerog_planedive( guy )
{
	// PLANE STARTS TO DIVE
	//-- AFFECT PROPS & RAGDOLL --
	level.player EnableInvulnerability();
	// array_thread( level.aRollers, ::rotate_rollers_to, (-35, 0, 0), 4, 0, 2 );
	LerpSunAngles( ( -24, 96, 0 ), ( -11, 60, 0 ), 3 );
	wait( 1.75 );
	SetPhysicsGravityDir( ( 0.03, 0.0, 0.05 ) ); //moving to front of plane
	
	wait( 3.6 );
	//We're losing altitude!
	//	thread radio_dialogue( "hijack_plt_losingaltitude" );
}

zerog_secondhit( guy )
{
	// THROW PLAYER IN AIR
	//-- AFFECT PLAYER --
	Earthquake( 0.25, 1.5, level.player.origin, 6000 );
	level.player ShellShock( "hijack_airplane", 2.5 );
	//	aud_send_msg("zero_g_bodyslam3");
	wait( 2.5 );
	//level.player ShellShock( "hijack_slowview", 30);
}

zerog_planerollright( guy )
{
	// PLANE ROLLS RIGHT
	//-- AFFECT PROPS & RAGDOLL --
	level.player DisableInvulnerability();
	level endon( "plane_roll_left" );
	flag_set( "plane_roll_right" );
	// array_thread( level.aRollers, ::rotate_rollers_to, (-35, 0, -20), 3, 1, 1 );
	LerpSunAngles( ( -11, 60, 0 ), ( 2, 95, 0 ), 5 );
	SetPhysicsGravityDir( ( 0.00, -0.01, 0.01 ) ); //moving to front and right of plane
}

zerog_bigshake( guy )
{
	// TURBULANCE
	//-- AFFECT PLAYER --
	Earthquake( 0.45, 2.0, level.player.origin, 6000 );
	// level.player thread play_sound_on_entity( "hijk_zero_g_bigshake" );
}

zerog_planerollleft( guy )
{
	// PLANE ROLLS LEFT, PULLS UP
	//-- AFFECT PROPS & RAGDOLL --
	level endon( "plane_levels" );
	flag_set( "plane_roll_left" );
	//array_thread( level.aRollers, ::rotate_rollers_to, (15, 0, 15), 2.75, 0, .25 );
	LerpSunAngles( ( 2, 95, 0 ), ( -23, 65, 0 ), 3.75 );
	SetPhysicsGravityDir( ( -0.02, 0.03, 0.01 ) ); //moving to back and left of plane
}

zerog_thirdhit( guy )
{
	// PLANE ROLLS LEFT, PULLS UP
	//-- AFFECT PLAYER --
	level.player EnableInvulnerability();
	flag_set( "plane_third_hit" );
	Earthquake( 0.25, 2.0, level.player.origin, 6000 );
	SetPhysicsGravityDir( ( 0.0, 0.0, 0.0 ) ); // moving to bottom of plane
	level.player ShellShock( "hijack_airplane", 2.5 );
	level.player DisableWeapons();
	//	aud_send_msg("zero_g_bodyslam4");
	wait( 2.5 );
	//level.player ShellShock( "hijack_slowview", 15);
	level.player EnableWeapons();
}

zerog_planelevelout( guy )
{
	// PLANE LEVELS, ZERO-G DONE
	//-- AFFECT PROPS & RAGDOLL --
	flag_set( "plane_levels" );
	//array_thread( level.aRollers, ::rotate_rollers_to, (0, 0, 0), 3, 0, 0 );
	LerpSunAngles( ( -23, 65, 0 ), level.orig_sundirection, 5, 0, 1 );
	SetPhysicsGravityDir( ( 0, 0, -1 ) ); // moving to bottom of plane
	SetSavedDvar( "phys_gravity"		, level.orig_phys_gravity );
	SetSavedDvar( "phys_gravity_ragdoll", level.orig_ragdoll_gravity );
	joltOrigin = ( -27290, 12784, 7340 );
//	PhysicsJitter( joltOrigin, 500, 450, .1, .2, 1 );
//	PhysicsJolt( joltOrigin, 500, 450, (.00, .00, -.05));
	//	zerog_jolt_weapons( joltOrigin, 500, (.00, .00, -.05));
	//	aud_send_msg("zero_g_debris_crash");
}

rotate_rollers_roll( angle, time, accel_time, decel_time )
{
	self RotateRoll( angle, time, accel_time, decel_time );
}

rotate_rollers_pitch( angle, time, accel_time, decel_time )
{
	self RotatePitch( angle, time, accel_time, decel_time );
}

rotate_rollers_to( angles, time, accel_time, decel_time )
{
	self RotateTo( angles, time, accel_time, decel_time );
}

gravity_shift( x, y, z )
{
	SetSavedDvar( "phys_gravityChangeWakeupRadius", 1600 );
	
	SetPhysicsGravityDir( ( x, y, z ) );
}

alliesTeletoStartSpot( spotarray )
{
	foreach ( spot in spotarray )
	{
		if ( spot.script_noteworthy == "player" )
			level.player TeletoSpot( spot );
		else
		{
			foreach ( ai in level.heroes )
			{
				if ( spot.script_noteworthy == ai.script_noteworthy )
					ai TeletoSpot( spot );
			}
		}
	}
}

TeletoSpot( spot )
{
	if ( IsPlayer( self ) )
	{
		self SetOrigin( spot.origin );
		self SetPlayerAngles( spot.angles );
	}
	else
		self ForceTeleport( spot.origin, spot.angles );
}

Earthquake_rumble()
{
//	while ( 1 ) // if something else, then do another thing that is bigger.
//	{
//		intensity = RandomFloatRange( 0.06, 0.3 );
//		time	  = RandomFloatRange( 0.4, 0.7 );
//		Earthquake( intensity, time, level.player.origin, 1000 );
//		wait ( time );
//		wait RandomFloatRange( 0.6, 3.5 );
//		
//	}
}

Earthquake_rumble2()
{
	while ( 1 ) //
	{
		intensity = RandomFloatRange( 0.08, 0.13 );
		time	  = RandomFloatRange( 7, 9.5 );
		Earthquake( intensity, time, level.player.origin, 1000 );
		wait ( time );
	}
}

slow_mo_think( starttimescale, endTimescale_to, time )
{
	SetSlowMotion( starttimescale, endTimescale_to, time );
}

pause_smoke_fx()
{
	fx	   = [];
	//	fx = getfxarraybyID( "after_math_embers" );
	//	fx = array_combine( fx, getfxarraybyID( "horizon_fireglow" ));
	fx	   = array_combine( fx, getfxarraybyID( "interior_ceiling_smoke" ) );
	fx	   = array_combine( fx, getfxarraybyID( "interior_ceiling_smoke2" ) );
	fx	   = array_combine( fx, getfxarraybyID( "interior_ceiling_smoke3" ) );
	//	fx = array_combine( fx, getfxarraybyID( "hijack_firelp_med_pm" ));
	//	fx = array_combine( fx, getfxarraybyID( "firelp_large_pm_nolight" ));
	//	fx = array_combine( fx, getfxarraybyID( "hijack_megafire" ));
	//	fx = array_combine( fx, getfxarraybyID( "fire_trail_60" ));
	//	fx = array_combine( fx, getfxarraybyID( "firelp_med_pm_nolight" ));
	//	fx = array_combine( fx, getfxarraybyID( "banner_fire" ));
	//	fx = array_combine( fx, getfxarraybyID( "banner_fire_nodrip" ));
	//	fx = array_combine( fx, getfxarraybyID( "firelp_small_pm_nolight" ));
	//	fx = array_combine( fx, getfxarraybyID( "powerline_runner_cheap_hijack" ));
	//	fx = array_combine( fx, getfxarraybyID( "field_fire_distant2" ));
	//	fx = array_combine( fx, getfxarraybyID( "plane_gash_volumetric" ));

	//wait( 0.1 ); // must wait until fx are started	
	level waittill( "volumetrics_setup" );
	for ( ;; )
	{
		flag_wait( "pause_plane_fx" );
		//iprintln( "FX: Tarmac effects paused." );
		foreach ( oneshot in fx )
			oneshot pauseEffect();
		flag_waitopen( "pause_plane_fx" );
		//iprintln( "FX: Tarmac effects restarted." );
		foreach ( oneshot in fx )
			oneshot restartEffect();
	}
}

fake_rotate_of_ai()
{	
	//	foreach ( ai in level.heroes )
	//	{
	//		level.heroes
	//	}
	//	
	//		
	//	foreach ( ai in level.enemies )
	//	{
	//		level.enemies
	//	}
}

physics_of_objects_in_plane()
{
	level.orig_phys_gravity = GetDvar( "phys_gravity" );
	//	SetSavedDvar( "phys_gravity", -5 );
		
	//	joltOrigin = ( 15200.8, 4646.2, 2074.43 );
	//	PhysicsJitter( joltorigin, 500, 450, .1, .2, 1 );
	//	Physicsjolt( joltorigin, 500, 450, ( .00, .00, -.05)  );
		
	//	wait 3;
	phys_objects = GetEntArray( "zerog_physics", "targetname" );
	foreach ( object in phys_objects )
	{
		PhysicsExplosionSphere( object.origin, 64, 32, .01 ); // The magnitude was .45
		//PhysicsExplosionSphere( object.origin, 32, 15, 0.1 );
		//PhysicsExplosionSphere( object.origin, 64, 32, .04 ); // The magnitude was .45
	}
	
	//	while( 1 )
	//	{
	//			wait 1;
			SetPhysicsGravityDir( ( 0.00, 0.00, -0.02 ) ); // this sends stuff up..
			wait 0.3;
			SetPhysicsGravityDir( ( 0.02, 0.05, -1 ) );
			wait 2;
			SetPhysicsGravityDir( ( 0.05, -0.05, 1 ) );
	//			wait 1;
	//	}
	

	num = 0;			
	SetSavedDvar( "phys_gravity", 0 );			
	while ( 1 )
	{
		SetSavedDvar( "phys_gravity", -5 );
		time = RandomFloatRange( 1.3, 3.3 );
		num++;
		//num = 0;
		//num = RandomFloatRange( 0, 5 );
		if ( num == 1 )
		{
			SetPhysicsGravityDir( ( -0.02, 0.03, 0.01 ) ); //moving to back and left of plane
		}
		
		if ( num == 2 )
		{
			SetPhysicsGravityDir( ( 0.00, 0.00, -1 ) ); // sends to the bottom
		}
		
		if ( num == 3 )
		{
			SetPhysicsGravityDir( ( 0.00, -0.01, 0.01 ) ); //moving to front and right of plane
		}
		
		if ( num == 4 )
		{
			SetSavedDvar( "phys_gravity", level.orig_phys_gravity );
		}
		
		if ( num == 5 )
		{
			num = 0;
			SetPhysicsGravityDir( ( 0.03, 0.0, 0.05 ) ); //moving to front of plane
		}
			
		foreach ( object in phys_objects )
		{
			PhysicsExplosionSphere( object.origin, 150, 75, .01 ); // The magnitude was .45
		}
		wait ( time );
	}
}

//lerp_timescale_over_time( to, time )
//{
//	if ( !IsDefined( level._current_timescale ) )
//		level._current_timescale = 1.0;
//		
//	from = level._current_timescale;
//	incs = Int( time / 0.05 );
//	rate = ( to - from ) / incs;
//	
//	t	  = from;
//	count = 0;
//	while ( count < incs )
//	{
//		SetTimeScale( t );
//		level._current_timescale = t;
//		t += rate;
//		count++;
//		wait( 0.05 );
//	}
//	SetTimeScale( to );
//	level._current_timescale = to;
//}
//
//lerp_timescale_over_time( to, time )
//{
//	if( !IsDefined( level._current_timescale ) ) 
//		level._current_timescale = 1.0;
//	
//	from = level._current_timescale;
//	incs = Int( time / 0.05 );
//	rate = ( to - from ) / incs;
//	
//	
//	t	  = from;
//	count = 0;
//	while( count < incs )
//	{
//		set
//}

// hurt player if he does not move while climbing out.
hurt_player( num, anim_time )
{
	if ( !isdefined( anim_time ) )
		anim_time = 0.5;

	fx = getfx( "no_effect" );

	if ( IsDefined( self.hurt_player_fx ) )
		fx = getfx( self.hurt_player_fx );

//	knife = maps\af_chase_knife_fight_code::get_knife();
//	PlayFXOnTag( fx, knife, "TAG_FX" );

	level notify( "new_hurt" );
	level endon( "new_hurt" );
	if ( IsDefined( self.override_anim_time ) )
		anim_time = self.override_anim_time;



	//level.player SetNormalHealth( 1 );
	pos = level.player.origin + randomvector( 1000 );
//	level.player DoDamage( num / level.player.damagemultiplier, pos );

	blur = num * 2.9;
	time = num * 0.25;
	SetBlur( blur, 0 );
	SetBlur( 0, time );

	quake_time = num * 0.05;
	quake_time = clamp( quake_time, 0, 0.4 );
	quake = num * 0.02;
	quake = clamp( quake, 0, 0.25 );

	duration = clamp( num, 0, 0.85 );
//	Earthquake( quake, duration, level.player.origin, 5000 );

	min_time = 0.2;
	max_time = 1.5;
	time_range = abs( min_time - max_time );
	anim_range = 1 - anim_time;

	vision_blend_time = anim_range * time_range + min_time;
	halt_time = anim_time * 2;
	halt_time = clamp( halt_time, 0.5, 2.0 );
	recover_time = RandomFloatRange( 0.2, 0.6 );

	//vision_set = "aftermath_hurt";
	if ( halt_time > 1.35 )
		//vision_set = "aftermath_dying";
	IPrintLnBold( "play vision of the player slowly losing control" );
	//set_vision_set( vision_set, vision_blend_time );

	if ( RandomInt( 100 ) > 70 )
	{
		// sometimes do quick recover
		wait( 0.15 );
		recover_time = RandomFloatRange( 0.16, 0.22 );
		IPrintLnBold( "play vision of the player recovering" );
		//set_vision_set( "aftermath_walking", recover_time );
	}
	wait halt_time;
	IPrintLnBold( "play vision with halt time recovering" );
	//set_vision_set( "aftermath_walking", recover_time );
}


//level.occumulator = occumulator;

//player_fails_if_does_not_occumulate()
//{
//	level.occumulator endon( "stop" );
//
//	wait( 3 );// some time to learn
//
//	overlay = get_black_overlay();
//
//	fail_count = 0;
//
//	deathcount = -80;
//
//	for ( ;; )
//	{
//		pressed_enough = level.occumulator.presses.size >= 2;
//		if ( pressed_enough )
//			fail_count += 2;
//		else
//			fail_count -= 1;
//
//		if ( fail_count <= deathcount )
//			break;
//
//		fail_count = clamp( fail_count, deathcount, 20 );
//
//		alpha = fail_count;
//		alpha /= deathcount;
////		alpha *= -1;
//		alpha = clamp( alpha, 0, 1 );
//
//		overlay FadeOverTime( 0.2 );
//		overlay.alpha = alpha;
//		wait( 0.05 );
//	}
//
//	overlay FadeOverTime( 0.2 );
//	overlay.alpha = 1;
//	wait( 0.2 );
//	missionFailedWrapper();
//}

timescale_does_not_effect_sound()
{
//	channels = maps\_equalizer::get_all_channels();
//	foreach ( channel in channels )
//	{
//		SoundSetTimeScaleFactor( channel, 0 );
//	}
}

button_wait( button_alt, button_track, button_index )
{
	time = GetTime();
	button_hint_time =  							time + 300;
	button_player_hurt_pulse = 						time + 2150;
	button_failure_time = 							time + 4000;

	button_hinted = false;
	hurt_pulsed = false;

	if ( button_index == 0 )
	{
		button_hint_time =  							time + 1400;
		button_player_hurt_pulse = 						time + 4150;
		button_failure_time = 							time + 7000;
	}

	if ( button_index > 2 )
	{
		button_hint_time =  							time + 1400;
		button_player_hurt_pulse = 						time + 2150;
		button_failure_time = 							time + 4000;
	}

	while ( 1 )
	{
		button_pressed = level.player [[ button_alt[ button_index ] ]]();
		needs_to_release = button_needs_to_release( button_track, button_index );

		if ( button_hint_time < GetTime() && ! button_hinted )
		{
			button_hinted = true;
			display_hint( button_track.button_hints[ button_index ] );
		}

		if ( button_player_hurt_pulse < GetTime() && ! hurt_pulsed )
		{

			hurt_pulsed = true;
			thread crawl_hurt_pulse();
		}

		if ( button_failure_time < GetTime() )
		{
			// Price was killed.
			// SetDvar( "ui_deadquote", &"AF_CHASE_FAILED_TO_CRAWL" );
			//missionFailedWrapper();
			IPrintLnBold( "missin fail for waiting to long" );
			level waittill( "never" );
		}
		if ( button_pressed && ! needs_to_release )
		{
			level notify( "clear_hurt_pulses" );
			return;
		}
		wait .05;
	}
}

crawl_hurt_pulse()
{
//	fade_out( 2 );
	SetBlur( 4, 4 );
	IPrintLnBold( "crawl_hurt_pulse" );
	//set_vision_set( "aftermath_hurt", 4 );
	thread crawl_breath_start();
	level waittill( "clear_hurt_pulses" );
	IPrintLnBold( "af_chase_ending_noshock" );
	//set_vision_set( "af_chase_ending_noshock", .5 );
//	thread crawl_breath_recover();
	SetBlur( 0, .5 );
//	fade_in( .23 );
}

track_buttons( button_track, button_alt, button_hints )
{
	buttons = [];
	for ( i = 0; i < button_alt.size; i++ )
		buttons[ i ] = GetTime();
	button_track.button_last_release = buttons;
	button_track.button_hints = button_hints;

	while ( 1 )
	{
		foreach ( index, button_func in button_alt )
		{
			if ( ! level.player [[ button_func ]]() )
				button_track.button_last_release[ index ] = GetTime();
		}
		wait .05;
	}
}

button_needs_to_release( button_track, index )
{
	timediff = GetTime() - button_track.button_last_release[ index ];
	return timediff > 750;
}

crawl_breath_recover()
{
	level notify( "crawl_breath_recover" );
//	level.player thread play_sound_on_entity( "breathing_better" );

}

crawl_breath_start()
{
	level endon( "crawl_breath_recover" );
	level.player play_sound_on_entity( "breathing_hurt_start" );
	while ( 1 )
	{
		wait RandomFloatRange( .76, 1.7 );
		level.player play_sound_on_entity( "breathing_hurt" );
	}
}

light_follow_plane( plane_org ) // threaded by the light
{
	self endon( "kill_light" );
	offset = ( self.origin - plane_org.origin );
	while ( 1 )
	{
		self MoveTo( plane_org.origin + offset, 0.05 );
		wait( 0.05 );
	}
}