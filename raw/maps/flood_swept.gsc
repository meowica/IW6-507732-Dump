#include maps\_utility;
#include common_scripts\utility;
#include maps\flood_util;

section_main()
{
	add_hint_string( "swept_hint", &"FLOOD_SWEPT_MOVE", ::no_swept_hint );

	//"Press movement keys to control slide."
	add_hint_string( "control_slide"		, &"FLOOD_SLIDE_HINT"		, ::no_swept_hint );
	//"Press movement keys to control slide."
	add_hint_string( "control_slide_l"		, &"FLOOD_SLIDE_HINT_L"		, ::no_swept_hint );
	//"&&"BUTTON_MOVE" to control slide."
	add_hint_string( "control_slide_gamepad", &"FLOOD_SLIDE_HINT_GAMEPAD", ::no_swept_hint );
	//"&&"BUTTON_LOOK" to control slide."
	add_hint_string( "control_slide_gamepad_l", &"FLOOD_SLIDE_HINT_GAMEPAD_L", ::no_swept_hint );
}

section_precache()
{
//	PreCacheModel( "flood_waterball_mini" );
	PreCacheRumble( "light_3s" );
	PreCacheRumble( "heavy_2s" );
}

section_flag_inits()
{
	flag_init( "left_pressed" );
	flag_init( "right_pressed" );
	flag_init( "swept_blending_allowed" );
	flag_init( "player_hit_vehicle" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

swept_start()
{
	thread maps\flood_audio::swept_away_scene( "start" );
	
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "swept_start" );
		
	
	// spawn the allies
	maps\flood_util::spawn_allies();
	
	maps\flood_util::setup_default_weapons( true );
	
	// FIX JKU  should I even be doing this? take your primaries when you get swept away
	weaplist = level.player GetWeaponsListPrimaries();
	foreach( weap in weaplist )
		level.player TakeWeapon( weap );

	level.player DisableOffhandWeapons();
	
	// set the gun if we skip here
	level.flood_mall_weapon_model = "weapon_cz_805_bren";
	level.flood_mall_weapon_hidden_tags = [];

	level.cw_waterwipe_above = "waterline_above";
	level.cw_waterwipe_under = "waterline_under";
}

// CF - Removing specific lines but leaving for reference
// was an end of mission call at start of swept away sequence
/*
greenlight_mission_complete()
{
	if( level.start_point == "dam" )
	{
		// CF - adding temp mission end call for greenlight build
		wait 4.5;
		set_audio_zone( "flood_gl_end", 3 );
		wait 1.5;
		nextmission();
	}
}
*/

swept()
{
	// CF - Removing specific lines but leaving for reference
	// CF - adding temp mission end call for greenlight build
	//thread greenlight_mission_complete();

	level.cw_znear_default = GetDvar( "r_znear" );
	SetSavedDvar( "r_znear", 0.7 );

	// only spawn guys if I ragdolled them when the roof collapsed
	if( !IsAlive( level.allies[ 0 ] ) )
	{
		JKUprint( "ally 0 created" );
		level.allies[ 0 ] = maps\flood_util::spawn_ally( "ally_0" );
	}
	if( !IsAlive( level.allies[ 1 ] ) )
	{
		JKUprint( "ally 1 created" );
		level.allies[ 1 ] = maps\flood_util::spawn_ally( "ally_1" );
	}
	if( !IsAlive( level.allies[ 2 ] ) )
	{
		JKUprint( "ally 2 created" );
		level.allies[ 2 ] = maps\flood_util::spawn_ally( "ally_2" );
	}
	
	level.allies[ 0 ].cw_in_rising_water = false;
	level.allies[ 1 ].cw_in_rising_water = false;
	level.allies[ 2 ].cw_in_rising_water = false;
	
	maps\flood_util::allies_move_to_checkpoint_start( "swept", true );

	thread start_swept_control();
	thread swept_water_toggle( "swim", "show" );
	//thread swept_water_toggle( "noswim", "hide" );
	thread swept_water_toggle( "debri_bridge", "hide" );
	
	thread watch_waterlevel();
	thread maps\flood_anim::skybridge_scene_firstframe();
	thread maps\flood_fx::fx_swept_amb_fx();
	thread maps\flood_anim::sweptaway_spawn();
	
	thread maps\flood_fx::set_enter_swept_vf();
	
//	triggers = GetEntArray( "dodamage_car", "targetname" );
//	array_thread( triggers, ::trigger_damage_car );
	
	// first frame antenna
	node = getstruct( "vignette_sweptaway_end_b", "script_noteworthy" );
	level.sweptaway_antenna_01 = spawn_anim_model( "sweptaway_antenna_01" );
	level.sweptaway_antenna_02 = spawn_anim_model( "sweptaway_antenna_02" );

	guys									 = [];
	guys[ "sweptaway_antenna_01" ]			 = level.sweptaway_antenna_01;
	guys[ "sweptaway_antenna_02" ]			 = level.sweptaway_antenna_02;
	node maps\_anim::anim_first_frame( guys, "sweptaway_end_b" );
	
	level.player DisableOffhandWeapons();
	level.player AllowSprint( false );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player AllowMelee( false );
	level.player DisableWeapons();
	level.player HideViewModel();
	SetSavedDvar( "ammoCounterHide", 1 );
	
	thread maps\flood_fx::fx_swept_dunk_bubbles();
	stop_exploder( "mr_sunflare" );
	exploder("swept_sunflare");



	level waittill( "swept_success" );
	
	// FIX JKU are we sure we want to do this here?  Maybe we shouldn't do it at all since you go straight back into a water section????
	SetSavedDvar( "r_znear", level.cw_znear_default );
	
	// hide swept away moment water
//	thread maps\flood_swept::swept_water_toggle( "swim", "hide" );
//	thread maps\flood_swept::swept_water_toggle( "noswim", "show" );
	
	// make sure that you don't enter stealth section underwater
//	thread swept_abovewater();
}

swept_hint()
{
	level.player display_hint_timeout( "swept_hint", 3 );
}

attach_weapon()
{
	self Attach( level.flood_mall_weapon_model, "tag_weapon", true );
}

#using_animtree( "player" );
start_swept_control()
{
	ent = getstruct( "vignette_sweptaway", "script_noteworthy" );
	
	swept_path_rig = spawn_anim_model( "swept_path_rig", ent.origin );
	swept_path_rig.angles = ent.angles;
	hands_rig = spawn_anim_model( "player_rig", ent.origin );
	hands_rig.angles = ent.angles;
	underwater_debris = spawn_anim_model( "swept_start_debris", ent.origin );
	level.swept_path_rig = swept_path_rig;
	level.hands_rig = hands_rig;
	
	hands_rig LinkTo( swept_path_rig, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	level.player PlayerLinkToDelta( hands_rig, "tag_player", 1, 25, 25, 15, 15 );
	level.player SpringCamEnabled( 1, 3.2, 1.6 );
	// use this one when there's player control
//	level.player SpringCamEnabled( 1.5, 2, 1 );

	hands_rig Attach( level.flood_mall_weapon_model, "tag_weapon", true );
	foreach( hidden_tag in level.flood_mall_weapon_hidden_tags )
	{
		hands_rig HidePart( hidden_tag, level.flood_mall_weapon_model );
	}
	
	//thread maps\flood_fx::fx_swept_start_bubble_mass();


	ent thread maps\_anim::anim_single_solo( underwater_debris,"flood_sweptaway_player_start_underwater" );
	//thread maps\flood_fx::fx_kill_swept_bubbles( hands_rig );

	ent thread swept_path_anim( swept_path_rig, hands_rig );
	level.swept_hands_anim = level.hands_rig getanim( "flood_sweptaway" );
	hands_rig SetAnim( level.swept_hands_anim, 1, 0 );
	swept_path_rig Hide();
	
//	waterball = Spawn( "script_model", swept_path_rig.origin );
//	waterball SetModel( "flood_waterball_mini" );
//	waterball LinkTo( swept_path_rig );
	
//	thread building_slide_control_hint();
//	thread swept_hint();
	
	// delay the input so you have a chance to catch your bearings and don't do anything stupid immediately, especially since you start out not able to see
	thread watch_input( swept_path_rig, hands_rig );
	thread player_play_anims( hands_rig );
	// this is removed since control is currently removed
//	thread start_blend_to_endpos();
}

swept_path_anim( swept_path_rig, hands_rig )
{
	level endon( "swept_success" );
	
	node = getstruct( "vignette_sweptaway_end_b", "script_noteworthy" );
	
//	thread swept_end_player_test( node );
	self maps\_anim::anim_single_solo( swept_path_rig, "flood_sweptaway_player_path" );
	thread swept_end_player( node );
	thread swept_end( node );

//	flag_wait( "player_hit_vehicle" );
//
////	IPrintLn( "hit truck" );
//	thread maps\flood_audio::swept_away_scene( "switch" );
//	level notify( "swept_take_control" );
//	level.player DoDamage ( 75, level.player.origin );
//	hands_rig Unlink();
}

swept_end( node )
{
	level notify( "swept_end_vign_start" );
	
	sweptaway_end_man7t = maps\_vignette_util::vignette_vehicle_spawn( "sweptaway_man7t", "sweptaway_end_man7t" ); //"value" (kvp), "anim_name"
	sweptaway_end_opfor_floater = maps\_vignette_util::vignette_actor_spawn( "swept_end_opfor_floater", "sweptaway_end_opfor_floater" ); //"value" (kvp), "anim_name"
	sweptaway_end_opfor_pinned = maps\_vignette_util::vignette_actor_spawn( "swept_end_opfor_pinned", "sweptaway_end_opfor_pinned" ); //"value" (kvp), "anim_name"
	
	// FIX JKU  need to make sure I'm doing the gun removal correctly as I think there's anims that expect it to be present
	level.allies[ 1 ].alertlevel = "noncombat";
	level.allies[ 1 ] gun_remove();

	sweptaway_end_chair	 = spawn_anim_model( "sweptaway_end_chair" );
	sweptaway_end_ibeam	 = spawn_anim_model( "sweptaway_end_ibeam" );
	sweptaway_end_pinned = spawn_anim_model( "sweptaway_end_pinned" );

	if ( !IsDefined( level.skybridge_model ) )
		level.skybridge_model = spawn_anim_model( "sweptaway_skybridge_01" );

	guys									 = [];
	guys[ "sweptaway_antenna_01" ]			 = level.sweptaway_antenna_01;
	guys[ "sweptaway_antenna_02" ]			 = level.sweptaway_antenna_02;
	guys[ "sweptaway_end_man7t"	 ]			 = sweptaway_end_man7t;
	guys[ "vignette_sweptaway_end_b_ally1" ] = level.allies[ 0 ];
	guys[ "sweptaway_end_ibeam"			]	 = sweptaway_end_ibeam;
	guys[ "sweptaway_end_pinned"		]	 = sweptaway_end_pinned;
	guys[ "sweptaway_end_opfor_floater" ]	 = sweptaway_end_opfor_floater;
	guys[ "sweptaway_end_opfor_pinned"	]	 = sweptaway_end_opfor_pinned;
	guys[ "sweptaway_end_chair"			]	 = sweptaway_end_chair;

	thread maps\flood_audio::audio_flood_end_logic();

	level.allies[ 0 ] delayThread( 0.75, ::swept_end_ally_vo );
	node maps\_anim::anim_single( guys, "sweptaway_end_b" );
	level.allies[ 0 ] thread maps\flood_roof_stealth::ally0_main();
	
	sweptaway_end_man7t maps\_vignette_util::vignette_vehicle_delete();
	sweptaway_end_opfor_floater maps\_vignette_util::vignette_actor_delete();
	sweptaway_end_opfor_pinned maps\_vignette_util::vignette_actor_delete();
}

swept_end_player( node )
{
	level.player FreezeControls( true );
	level.cw_no_waterwipe = true;
//	level.swept_path_rig Delete();
	
	guys				 = [];
	guys[ "player_rig" ] = level.hands_rig;
	
	node maps\_anim::anim_single( guys, "sweptaway_end_b" );
	
	level notify( "swept_success" );
	level notify( "swept_player_done" );
	level.player Unlink();
	level.hands_rig Delete();
	level.player FreezeControls( false );
	
	// FIX JKU need to eval this.  bc the player comes out of this vign before your ally, we allow player movement here instead of in the main checkpoint script.
	level.player AllowSprint( true );
	level.player AllowCrouch( true );
	level.player AllowMelee( true );
	level.player EnableWeapons();
	level.player ShowViewModel();
	level.cw_no_waterwipe = false;
	
	// this distance needs to be about 10 feet to keep the player from getting ahead
	JKUprint( Distance2D( level.allies[ 1 ].origin, level.player.origin ) );
	
	level.player AllowSprint( false );
	level.player delayCall( 7.5, ::AllowSprint, true );
	level.player blend_movespeedscale( 0.05 );
	level.player thread blend_movespeedscale_default( 7.5 );
}

swept_end_ally_vo()
{
	self endon( "death" );
	level endon( "stealth_attack_player" );
	
	//Vargas: Walker!
//	self thread dialogue_queue( "flood_vrg_walker" );
	
	wait 3.35;
	
	//Vargas: Hold On!
//	self thread dialogue_queue( "flood_vrg_holdon" );
	
	wait 6.3;
	
	//Vargas: Looks like it's just you and me now, brother.
	self thread dialogue_queue( "flood_vrg_grabmyhandwalker" );
	
	wait 1.5;
	
	//Vargas: I got ya!
	self thread dialogue_queue( "flood_vrg_eliasigotcha" );
}

swept_end_player_test( node )
{
	player_rig = spawn_anim_model( "player_rig" );
	guys				 = [];
	guys[ "player_rig" ] = player_rig;
	
	node maps\_anim::anim_first_frame( guys, "sweptaway_end_b" );
//	node maps\_anim::anim_single( guys, "sweptaway_end_b" );
}

watch_input( swept_path_rig, hands_rig )
{
	level.player endon( "death" );
	level endon( "swept_success" );
	level endon( "swept_end_vign_start" );
	level endon( "swept_take_control" );
	
//	waterball = Spawn( "script_model", vehicle.origin );
//	waterball SetModel( "flood_waterball_mini" );
//	waterball LinkTo( vehicle );
	
	level.swept_allow_movement = false;
	level.swept_path_offset = 0;
	level.swept_allowed_slide = 60;
	level.swept_movement_step = 0;
	thread adjust_movement_step_up( 6, 5 );
	
	// FIX JKU, hmm, this is a little scary, I'm gonna check for input but I need to make sure that the deadzone is correct.  stuck controllers, etc..
	while( 1 )
	{
		analog_input = level.player GetNormalizedMovement();
		if( analog_input[ 1 ] >= 0.15 )
		{
//			IPrintLn( "pressing right" );
//			IPrintLn( Distance2D( hands_rig.origin, swept_path_rig.origin ) );
			flag_clear( "left_pressed" );
			flag_set( "right_pressed" );
			if( level.swept_allow_movement )
			{
				right = AnglesToRight( swept_path_rig.angles );
				new_pos = hands_rig.origin + ( level.swept_movement_step * right );
				if( Distance2D( new_pos, swept_path_rig.origin ) <= level.swept_allowed_slide )
				{
					hands_rig.origin = new_pos;
					hands_rig LinkTo( swept_path_rig, "tag_player" );
//					level.player PlayerLinkToDelta( hands_rig, "tag_player", 1, 25, 25, 15, 15 );
				}
//				else
//					IPrintLn( Distance2D( hands_rig.origin, swept_path_rig.origin ) );
			}
		}
		else if( analog_input[ 1 ] <= -0.15 )
		{
//			IPrintLn( "pressing left" );
//			IPrintLn( Distance2D( hands_rig.origin, swept_path_rig.origin ) );
			flag_clear( "right_pressed" );
			flag_set( "left_pressed" );
			if( level.swept_allow_movement )
			{
				right = AnglesToRight( swept_path_rig.angles );
				new_pos = hands_rig.origin + ( ( level.swept_movement_step * -1 ) * right );
				if( Distance2D( new_pos, swept_path_rig.origin ) <= level.swept_allowed_slide )
				{
					hands_rig.origin = new_pos;
					hands_rig LinkTo( swept_path_rig, "tag_player" );
//					level.player PlayerLinkToDelta( hands_rig, "tag_player", 1, 25, 25, 15, 15 );
				}
//				else
//					IPrintLn( Distance2D( hands_rig.origin, swept_path_rig.origin ) );
			}
		}
		else
		{
			flag_clear( "left_pressed" );
			flag_clear( "right_pressed" );
		}
		waitframe();
	}
}

adjust_movement_step_up( max_movement_step, time )
{
	level.player endon( "death" );
	level endon( "swept_success" );

	game_time = time * 20;
	cur_step = 0;
	step_amt = max_movement_step / ( game_time );
	
//	IPrintLn( step_amt );
	for( i = 0; i < game_time; i++ )
	{
		level.swept_movement_step = cur_step;
		cur_step += step_amt;
//		IPrintLn( cur_step );
		waitframe();
	}
	JKUprint( "full cs" );
	flag_set( "swept_blending_allowed" );
}

start_blend_to_endpos()
{
	level.player endon( "death" );
	level endon( "swept_success" );

	// this is the amount of time we take to blend you to the endpos of the path anim
	blend_to_end_time = 1;
	
	wait GetAnimLength( level.swept_path_rig getanim( "flood_sweptaway_player_path" ) ) - blend_to_end_time;
	
	JKUprint( "no c" );
	level notify( "swept_take_control" );
	level.swept_allow_movement = true;
	
	// FIX JKU hmm, do we need to blend back into the path anim hands before we start the vign?
	initial_offset =  Distance2D( level.swept_path_rig.origin, level.hands_rig.origin );
	// calculate the movement steps -2 frames so we're very likely to finish before we actually hit the end of the path
	movement_step = initial_offset / ( ( blend_to_end_time * 20 ) - 2 );
//	IPrintLn( initial_offset );
//	IPrintLn( movement_step );
//	IPrintLn( level.swept_path_rig.origin[ 0 ] - level.hands_rig.origin[ 0 ] );
	// not sure how close I should try to get you back to center so lets just leave it bigish for now until the anims are finished
	while( IsDefined( level.swept_path_rig ) && IsDefined( level.hands_rig ) && Distance2D( level.swept_path_rig.origin, level.hands_rig.origin ) > 4 )
	{
		// move you left to get back to center
		right = AnglesToRight( level.swept_path_rig.angles );
		if( level.swept_path_rig.origin[ 0 ] - level.hands_rig.origin[ 0 ] > 0 )
		{
//			IPrintLn( "youre right of center: " + Distance2D( level.swept_path_rig.origin, level.hands_rig.origin ) );
			new_pos = level.hands_rig.origin + ( ( movement_step * -1 ) * right );
		}
		// move you right to get back to center
		else
		{
//			IPrintLn( "youre left of center: " + Distance2D( level.swept_path_rig.origin, level.hands_rig.origin ) );
			new_pos = level.hands_rig.origin + ( movement_step * right );
		}
		level.hands_rig.origin = new_pos;
		level.hands_rig LinkTo( level.swept_path_rig, "tag_player" );
//		IPrintLn( Distance2D( level.swept_path_rig.origin, level.hands_rig.origin ) );
		waitframe();
	}
//	IPrintLn( level.player.origin );
}

player_play_anims( hands_rig )
{
	level.player endon( "death" );
	level endon( "swept_success" );
	level endon( "swept_end_vign_start" );
	level endon( "swept_take_control" );
	
	blend_to_swim_time = 0.3;
	blend_to_idle_time = 0.5;
	
	while( 1 )
	{
		if( flag( "left_pressed" ) && flag( "swept_blending_allowed" ) )
		{
//			IPrintLn( "anim left pressed" );
			hands_rig SetAnim( level.hands_rig getanim( "flood_sweptaway_L" ), 1, blend_to_swim_time );
			// what a pain!!! can't turn the default anim to 0 or else it will restart when I try to turn it up again.
			hands_rig SetAnim( level.swept_hands_anim, 0.01, blend_to_swim_time );
			flag_waitopen( "left_pressed" );
//			IPrintLn( "anim left done pressed" );
			hands_rig SetAnim( level.swept_hands_anim, 1, blend_to_idle_time );
			hands_rig SetAnim( level.hands_rig getanim( "flood_sweptaway_L" ), 0, blend_to_idle_time );
		}
		else if( flag( "right_pressed" ) && flag( "swept_blending_allowed" ) )
		{
//			IPrintLn( "anim right pressed" );
			hands_rig SetAnim( level.hands_rig getanim( "flood_sweptaway_R" ), 1, blend_to_swim_time );
			// what a pain!!! can't turn the default anim to 0 or else it will restart when I try to turn it up again.
			hands_rig SetAnim( level.swept_hands_anim, 0.01, blend_to_swim_time );
			flag_waitopen( "right_pressed" );
//			IPrintLn( "anim right done pressed" );
			hands_rig SetAnim( level.swept_hands_anim, 1, blend_to_idle_time );
			hands_rig SetAnim( level.hands_rig getanim( "flood_sweptaway_R" ), 0, blend_to_idle_time );
		}
		else
		{
			flag_wait_any( "left_pressed", "right_pressed" );
		}
		waitframe();
	}
}

start_swept_control_old()
{
	vehicle = GetEnt( "swept_vehicle", "targetname" );
	vehicle = maps\_vehicle::vehicle_spawn( vehicle );

	slider = spawn_tag_origin();
	slider.origin = vehicle.origin;
	slider.angles = vehicle.angles;
	slider LinkTo( vehicle, "", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	ent = getstruct("vignette_sweptaway", "script_noteworthy");
	//ent = GetEnt( "swept_start", "targetname" );
	player_rig = spawn_anim_model( "player_rig", ent.origin );
	player_rig.angles = ent.angles;
//	hands_rig = spawn_anim_model( "player_rig", level.player.origin );
//	hands_rig.angles = level.player.angles;
	// FIX JKU Can't link to the player because it lags
//	player_rig LinkTo( slider, "tag_origin" );
//	hands_rig LinkTo( player_rig, "tag_origin" );
//	player_rig LinkTo( level.player );
//	player_rig LinkTo( level.player, "", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
//	level.player thread maps\_anim::anim_loop_solo( player_rig, "flood_sweptaway" );
	player_rig SetAnim( %flood_sweptaway_player_path, 1, 0 );
//	hands_rig SetAnim( %flood_sweptaway_player, 1, 0 );
//	hands_rig SetAnim( %flood_sweptaway_player_L, 0, 0 );
//	hands_rig SetAnim( %flood_sweptaway_player_R, 0, 0 );
 
	arc = 35;
	arc2 = 15;
//	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc2, arc2 );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc2, arc2 );

//	thread watch_input( slider, vehicle, player_rig );
//	thread player_play_anims( player_rig );
//	thread watch_waterlevel();

	// wait a sec and start you underwater after the mall
	wait 0.7;
//	vehicle maps\_vehicle::gopath();
	
	level waittill( "swept_success" );
	
	level.player Unlink();
	player_rig Delete();
//	hands_rig Delete();
}

watch_input_old( slider, vehicle, player_rig )
{
	level.player endon( "death" );
	level endon( "swept_success" );
	
//	waterball = Spawn( "script_model", vehicle.origin );
//	waterball SetModel( "flood_waterball_mini" );
//	waterball LinkTo( vehicle );
	
	allowed_slide = 121;
	
	// FIX JKU, hmm, this is a little scary, I'm gonna check for input but I need to make sure that the deadzone is correct.  stuck controllers, etc..
	while( 1 )
	{
		analog_input = level.player GetNormalizedMovement();
		if( analog_input[ 1 ] >= 0.15 )
		{
//			IPrintLn( "pressing right" );
			flag_clear( "left_pressed" );
			flag_set( "right_pressed" );
			if( Distance2D( level.player.origin, vehicle.origin ) <= allowed_slide )
			{
				right = AnglesToRight( vehicle.angles );
				new_pos = slider.origin + ( 5 * right );
				if( Distance2D( new_pos, vehicle.origin ) <= allowed_slide )
				{
					slider.origin = new_pos;
					slider LinkTo( vehicle );
//					level.player PlayerLinkToBlend();
				}
//				else
//					IPrintLn( Distance2D( level.player.origin, vehicle.origin ) );
			}
		}
		else if( analog_input[ 1 ] <= -0.15 )
		{
//			IPrintLn( "pressing left" );
			flag_clear( "right_pressed" );
			flag_set( "left_pressed" );
			if( Distance2D( level.player.origin, vehicle.origin ) <= allowed_slide )
			{
				right = AnglesToRight( vehicle.angles );
				new_pos = slider.origin + ( -5 * right );
				if( Distance2D( new_pos, vehicle.origin ) <= allowed_slide )
				{
					slider.origin = new_pos;
					slider LinkTo( vehicle );
				}
//				else
//					IPrintLn( Distance2D( level.player.origin, vehicle.origin ) );
			}
		}
		else
		{
			flag_clear( "left_pressed" );
			flag_clear( "right_pressed" );
		}
 		wait 0.05;
	}
}

trigger_damage_car()
{
	level endon( "swept_success" );
	level endon( "swept_fail" );

	self waittill( "trigger" );
	
	level.player DoDamage ( 50, level.player.origin);
}

swept_water_toggle( water, toggle )
{
	waters = undefined;
	switch( water )
	{
		case "swim":
			waters = GetEntArray( "swept_water_swim", "targetname" );
			break;
		//case "noswim":
			//waters = GetEntArray( "swept_water_noswim", "targetname" );
			//break;
		case "debri_bridge":
			waters = GetEntArray( "debri_bridge_water", "targetname" );
			break;
	}
	
	switch( toggle )
	{
		case "hide":
			foreach( water in waters )
			{
				water Hide();
				water NotSolid();
			}
			break;
		case "show":
			foreach( water in waters )
			{
				water Show();
				water Solid();
			}
			break;
	}
}

watch_waterlevel()
{
	level endon( "swept_player_done" );
	level endon( "swept_fail" );
	
	thread maps\flood_coverwater::setup_player_view_water_fx_source();
	level.player thread player_surface_blur_think( "swept_success" );
	
	// FIX JKU this is pretty shitty but will fix the missing underwater fx at the end of swept due to the tag origin going into solid geo.
	// thread off a script to set the water state
	// a cleaner solution is to fix the tag but the windowsill also overhanges which will cause issues with the dropdown check that swept uses.
	level thread waterlevel_hack();

	previous_surface = "none";
	
	while( 1 )
	{
		// get the players eye pos
		eye_level = level.player GetEye();
		// start a bullet trace above the player eye level to see if he's underwater
		// FIX JKU make sure I'm checking high enough.  200 seems good but who knows...
		trace = BulletTrace( ( eye_level + ( 0, 0, 300 ) ), eye_level, false );
//		IPrintLn( "current surface: " + trace[ "surfacetype" ] );
		// first time going underwater
		if( trace[ "surfacetype" ] == "water" && previous_surface != "water" )
		{
			swept_underwater();
			//thread maps\flood_audio::audio_water_level_logic( "submerge" );
		}
		// coming out of water
		else if( trace[ "surfacetype" ] == "none" && previous_surface != "none" )
		{
			swept_abovewater();
			//thread maps\flood_audio::audio_water_level_logic( "emerge" );
		}
		// still underwater
		else if( trace[ "surfacetype" ] == "water" && previous_surface == "water" )
		{
		}
		// still abovewater
		else if( trace[ "surfacetype" ] == "none" && previous_surface == "none" )
		{
		}
		previous_surface = trace[ "surfacetype" ];
//		IPrintLn( "previous surface: " + previous_surface );
		waitframe();
	}
}

waterlevel_hack()
{
	level endon( "swept_player_done" );
	level endon( "swept_fail" );

	wait 21.85;
	swept_underwater();
}

swept_underwater()
{
	level endon( "swept_success" );
	level endon( "swept_fail" );
	
	// normally set by the coverheight water script but swept is a special case
	level.cw_fog_under = "flood_underwater_murky";
	
//	IPrintLn( "oh shit underwater" );
	flag_clear( "cw_player_abovewater" );
	flag_set( "cw_player_underwater" );
	level.player vision_set_changes( "flood_underwater_murky", 0 );
	level.player fog_set_changes( "flood_underwater_murky", 0 );
	maps\_art::dof_enable_script( 0.1, 20, 4.8, 100, 1000, 10, 0.0 );

	//thread maps\flood_coverwater::fx_waterwipe_under();
	//KillFXOnTag( getfx( "scuba_mask_distortion_warble" ), level.cw_player_view_fx_source, "tag_origin" );
	KillFXOnTag( getfx( "scrnfx_water_splash_low" ), level.cw_player_view_fx_source, "tag_origin");
	//PlayFXOnTag( getfx( "shpg_scuba_bubbles_plr_front_dive" ), level.cw_player_view_fx_source, "tag_origin" );
	//PlayFXOnTag( getfx( "flood_swept_underwater" ), level.cw_player_view_fx_source, "tag_origin" );

	waitframe();
	
	if ( IsDefined( level.hands_rig ) )
	{
		PlayFXOnTag( getfx( "flood_hand_bubbles" ), level.hands_rig, "j_wrist_ri" );
		PlayFXOnTag( getfx( "flood_hand_bubbles" ), level.hands_rig, "j_wrist_le" );
	}

	thread maps\flood_fx::fx_create_bokehdots_source();
	
	KillFXOnTag( GetFX( "waterdrops_3" ), level.flood_source_bokehdots, "tag_origin" );
	waitframe();
	KillFXOnTag( GetFX( "bokehdots_close" ), level.flood_source_bokehdots, "tag_origin" );

	//set_audio_zone( "flood_underwater", 0.1 );
}

swept_abovewater()
{
	level endon( "swept_success" );
	level endon( "swept_fail" );
	
//	IPrintLn( "oh shit abovewater" );
	flag_clear( "cw_player_underwater" );
	flag_set( "cw_player_abovewater" );
	level.player vision_set_changes( level.cw_vision_above, 0 );
	level.player fog_set_changes( level.cw_fog_above, 0 );
	maps\_art::dof_disable_script( 0.0 );
	thread maps\flood_coverwater::fx_waterwipe_above();

	//KillFXOnTag( getfx( "shpg_scuba_bubbles_plr_front_dive" ), level.cw_player_view_fx_source, "tag_origin" );
	KillFXOnTag( getfx( "flood_hand_bubbles" ), level.hands_rig, "j_wrist_ri" );
	KillFXOnTag( getfx( "flood_hand_bubbles" ), level.hands_rig, "j_wrist_le" );

	//level.player SetWaterSheeting( 1, 1 );
	thread maps\flood_fx::fx_bokehdots_close();

	waitframe();
	thread maps\flood_fx::fx_waterdrops_3();
	//PlayFXOnTag( getfx( "scuba_mask_distortion_warble" ), level.cw_player_view_fx_source, "tag_origin" );
	KillFXOnTag( getfx( "flood_swept_underwater" ), level.cw_player_view_fx_source, "tag_origin" );

	PlayFXOnTag( getfx( "scrnfx_water_splash_low" ), level.cw_player_view_fx_source, "tag_origin");

	//set_audio_zone( "flood_swept", 0.01 );
}

player_surface_blur_think( endon_event )
{
	level.player endon( "death" );
	level endon( endon_event );
	
	blur_at_zero = true;
	
	while( 1 )
	{
		eyePos = level.player GetEye();
		range = 1.5;
		max_blur = 25;
		trace = BulletTrace( eyePos + ( 0, 0, range ), eyePos +  ( 0, 0, range * -1 ), false, self );
		if( trace[ "surfacetype" ] == "water" )
		{
			blur_strength = Distance( trace[ "position" ], eyePos ) * ( max_blur / range );
			SetBlur( max_blur - blur_strength, 0.05 );
			blur_at_zero = false;
		}
		else if( !blur_at_zero )
		{
			SetBlur( 0, 0.5 );
			blur_at_zero = true;
		}
		waitframe();
	}
}

no_swept_hint()
{
	if ( !IsAlive( level.player ) )
	{
		return true;
	}
	
	return false;
}

building_slide_control_hint()
{
	config = GetSticksConfig();
	IPrintLn( config );
	
	if ( level.player is_player_gamepad_enabled() )
	{
		if ( config == "thumbstick_southpaw" || config == "thumbstick_legacy" )
			display_hint_timeout( "control_slide_gamepad_l", 3 );
		else
			display_hint_timeout( "control_slide_gamepad", 3 );
	}
	else
	{
		if ( config == "thumbstick_southpaw" || config == "thumbstick_legacy" )
			display_hint_timeout( "control_slide_l", 3 );
		else
			display_hint_timeout( "control_slide", 3 );
	}
}

truck_rumble( guy )
{
	Earthquake( 0.5, 1, level.player.origin, 1600 );
	level.player PlayRumbleOnEntity( "heavy_2s" );
}

antenna_rumble( guy )
{
	Earthquake( 0.15, 0.5, level.player.origin, 1600 );
	level.player PlayRumbleOnEntity( "light_3s" );
}