#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\flood_util;

section_main()
{
}

section_precache()
{
	PreCacheModel("vehicle_coupe_green_destroyed");
	PreCacheModel("com_plastic_crate_pallet");
	PreCacheModel("com_trashcan_metal_with_trash");
	PreCacheModel("com_folding_chair");
	PreCacheModel("com_trashbin01");
	PreCacheModel("com_barrel_green");
	PreCacheModel("vehicle_van_mica_destroyed");
	PreCacheModel("flood_crate_plastic_single02");
	PreCacheModel("com_cardboardboxshortclosed_1");
	PreCacheModel("com_trash_bin_sml01");
	PreCacheModel("cardboard_box9");
	PreCacheModel("com_pallet_2");
	PreCacheModel("vehicle_coupe_green_destroyed");
	PreCacheModel("vehicle_van_mica_destroyed");
	
	//models used for mallroof collapse
	PreCacheModel("ac_unit_1_lrg_scaled");
	PreCacheModel("ac_unit_2_box1");
	PreCacheModel("ac_unit_2_wide_scaled");
	PreCacheModel("com_plasticcase_beige_rifle");
	PreCacheModel("maintenance_box");
	PreCacheModel("pb_weaponscase");
	PreCacheModel("flood_debris_small");
	PreCacheModel("pipe_metal_thick_straight_16_black");
	PreCacheModel("pipe_metal_thick_joint_90_medium_black");
	PreCacheModel("pipe_metal_thick_joint_2way_black");
	PreCacheModel("pipe_metal_thick_straight_64_black");
	PreCacheModel("debris_rubble_pile_02");
	PreCacheModel("vehicle_mini_destructible_blue");
	PreCacheModel("vehicle_mini_destructible_gray");
	PreCacheModel("vehicle_mini_destructible_red");
	PreCacheModel("vehicle_coupe_gold_destructible");
	PreCacheModel("flood_antenna_mobile_2");
}

section_flag_inits()
{
	flag_init( "player_on_mall_roof" );
	flag_init( "mall_attack_player" );
	flag_init( "rocket_event" );
	flag_init( "ally0_breach_ready" );
	flag_init( "ally2_breach_ready" );
	flag_init( "breach_door_open" );
	flag_init( "event_quaker_big" );
	flag_init( "mall_rooftop_heli_flyaway" );
	flag_init( "mall_rooftop_sfx_fadeout" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mall_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "mall_start" );
	
	VisionSetNaked("flood_warehouse", 0);
	fog_set_changes( "flood_warehouse", 0);
 	level.cw_vision_above = "flood_warehouse";
	level.cw_fog_above = "flood_warehouse";

	// spawn the allies
	maps\flood_util::spawn_allies();
	maps\flood_util::allies_move_to_checkpoint_start( "mall", true );
	
	level.allies[ 0 ] thread ally0_mall();
	level.allies[ 1 ] thread ally1_mall();
//	level.allies[ 1 ] thread maps\flood_flooding::hallway_blocker();
	level.allies[ 2 ] thread ally2_mall();
	
	//set_audio_zone( "flood_stairwell");

	// set the water height in the stairwell
	thread maps\flood_flooding::start_coverheight_water_rising( 2, true, "coverwater_warehouse" );
	// start checking if the player is in water
	thread maps\flood_coverwater::register_coverwater_area( "coverwater_warehouse", "swept_away" );
	level.cw_player_in_rising_water = false;
	// default time the player is allowed to be underneath cover water
	level.cw_player_allowed_underwater_time = 1;

	// spawn the rooftop door and first frame it
	thread mall_roof_door_firstframe();
		
	maps\flood_util::setup_default_weapons();

	// roof spanish vo
	thread maps\flood_flooding::enemy_spanish_vo();
	
	//cleaning up audio
	thread maps\flood_audio::sfx_flood_int_alarm_stop();
	thread maps\flood_streets::delete_ent_by_script_noteworthy("streets_helicopter_crash_location");
}

mall()
{
	// CF - Just removing GL specific lines
	// was autosave hitch removal for GL
	// temp for greenlight
	//if( level.start_point != "dam" )
	level thread autosave_now();
	
	battlechatter_off( "allies" );
	
	flag_clear( "cw_player_no_speed_adj" );
	
	//Audio: Water emitter cleanup
	thread maps\flood_audio::sfx_stop_stairwell_water();
	thread maps\flood_audio::sfx_mall_water();
//	thread maps\flood_swept::swept_debug_hands();

//	thread mall_roof_collapse();	
	thread toggle_mall_door_clip( "hide" );
	thread watch_player();
//	thread watch_glass();
//	thread watch_glass_shot();
	thread watch_goalvolume();
	thread enemy_setup_vign();
	thread enemy_twitch();
	thread mall_rootop_event();
	thread mall_rooftop_pickup_heli();
	thread mall_rooftop_flyby_helis();
	// random quakes when you're on the roof.  removed for now
//	thread event_quaker_outdoor();
	thread trigger_player_mall_rooftop();
    thread maps\flood_fx::fx_mall_roof_water_show();
    thread maps\flood_fx::fx_mall_roof_amb_fx();
   	thread maps\flood_fx::fx_mall_rooftop_debris();
   	//thread maps\flood_fx::fx_show_mr_clip_effects();
   	// FIX JKU need to figure out how to re-enable this
//	thread maps\flood_util::setup_bokehdot_volume( "mall_bokehdot" );
	stop_exploder( "alley_flares" );
	exploder( "mr_sunflare" );

	// FIX JKU turn this on to debug collision hacks.  make sure this is off when we ship!
//	wait 5;
//	level.player thread block_until_ground_collapse();
    
	thread mall_door_temp_collision();
    
	level waittill( "swept_away" );
	
	// tagDK<temp> - clean up all enemies from previous checkpoints
	thread maps\flood_util::kill_all_enemies();
	
	// Audio: Water emitter cleanup
	thread maps\flood_audio::sfx_stop_mall_water();
	
	// take your primaries when you get swept away
	weaplist = level.player GetWeaponsListPrimaries();
	foreach( weap in weaplist )
		level.player TakeWeapon( weap );
	
	maps\flood_util::player_move_to_checkpoint_start( "swept_start" );

	battlechatter_off( "allies" ); 
	battlechatter_off( "axis" ); 
}

block_until_ground_collapse( ground_too_far_point )
{
	self endon( "death" );
	level endon( "swept_away" );
	
	floor_clip = GetEnt( "mall_floor", "targetname" );
	
	if( !IsDefined( ground_too_far_point ) )
		ground_too_far_point = 8;
	
	trace1_passed = undefined;
	trace2_passed = undefined;
		
	while( 1 )
	{
		// this trace needs to happen from above the players origin as there are things sticking up above the clip
		trace1 = BulletTrace( self.origin + ( 0, 0, 12 ), self.origin - ( 0, 0, 1024 ), false, floor_clip );
		trace2 = BulletTrace( self.origin + ( 0, 6, 12 ), self.origin - ( 0, 6, 1024 ), false, floor_clip );
		
		// check to see if either trace passes
		if( IsDefined( trace1[ "entity" ] ) && IsDefined( trace1[ "entity" ].targetname ) )
		{
			if( trace1[ "entity" ].targetname == "flood_mallroof_center" || trace1[ "entity" ].targetname == "flood_mallroof_back" || trace1[ "entity" ].targetname == "acbox_obj" )
			{
				trace1_passed = true;
			}
			else
			{
				trace1_passed = false;
			}
		}
		else
			{
			trace1_passed = false;
		}

		if( IsDefined( trace2[ "entity" ] ) && IsDefined( trace2[ "entity" ].targetname ) )
		{
			if( trace2[ "entity" ].targetname == "flood_mallroof_center" || trace2[ "entity" ].targetname == "flood_mallroof_back" || trace2[ "entity" ].targetname == "acbox_obj" )
			{
				trace2_passed = true;
			}
			else
			{
				trace2_passed = false;
			}
		}
		else
		{
			trace2_passed = false;
		}
		
		// do something based on the results of the trace detection above.
		if( trace1_passed )
		{
			if( IsPlayer( self ) )
			{
				if( abs( self.origin[ 2 ] - trace1[ "position" ][ 2 ] ) > ground_too_far_point && self IsOnGround() )
				{
					JKUprint( "PLAYER FALLING! " + trace1[ "surfacetype" ] + " " + ( self.origin[ 2 ] - trace1[ "position" ][ 2 ] ) );
					player_ground_collapse();
					break;
				}
			}
			else
			{
				if( abs( self.origin[ 2 ] - trace1[ "position" ][ 2 ] ) > ground_too_far_point )
				{
					JKUprint( "AI FALLING! " + trace1[ "surfacetype" ] + " " + ( self.origin[ 2 ] - trace1[ "position" ][ 2 ] ) );
					break;
				}
			}
		}
		else if( trace2_passed )
		{
			if( IsPlayer( self ) )
			{
				if( abs( self.origin[ 2 ] - trace2[ "position" ][ 2 ] ) > ground_too_far_point && self IsOnGround() )
				{
					JKUprint( "PLAYER FALLING! " + trace2[ "surfacetype" ] + " " + ( self.origin[ 2 ] - trace2[ "position" ][ 2 ] ) );
					player_ground_collapse();
					break;
				}
			}
			else
			{
				if( abs( self.origin[ 2 ] - trace2[ "position" ][ 2 ] ) > ground_too_far_point )
				{
					JKUprint( "AI FALLING! " + trace2[ "surfacetype" ] + " " + ( self.origin[ 2 ] - trace2[ "position" ][ 2 ] ) );
					break;
				}
			}
		}
		else
		{
			Line( self.origin + ( 0, 0, 12 ), self.origin - ( 0, 0, 1024 ), ( 255, 0, 0 ), 1.0, false, 5000 );
			Line( self.origin + ( 0, 6, 12 ), self.origin - ( 0, 6, 1024 ), ( 0, 255, 0 ), 1.0, false, 5000 );

			if( IsPlayer( self ) )
			{
				AssertMsg( "Player falling failed!!!" );
				player_ground_collapse();
				break;
			}
			else if( IsAI( self ) )
			{
				AssertMsg( "AI: " + self.animname + " falling failed!!!" );
				break;
			}
		}
		waitframe();
	}
}

player_ground_collapse()
{
	flag_set( "mall_rooftop_sfx_fadeout" );
	level.swept_away = 1;
	Earthquake( .3, 1, level.player.origin, 1600 );
}

watch_player()
{
	level endon( "swept_away" );
	level endon( "mall_attack_player" );
	
	flag_wait( "breach_door_open" );
//	flag_wait( "player_on_mall_roof" );
//	level waittill( "breach_start" );
	
	timer = 0;
	timeup = RandomFloatRange( 10, 12.5 );
	
	while( 1 )
	{

		grenade_owned_by_player = undefined;
		grenade_owned_by_player_model = undefined;
		grenades = GetEntArray( "grenade", "classname" );
		foreach( grenade in grenades )
		{
			if( GetMissileOwner( grenade ) == level.player )
			{
				grenade_owned_by_player = true;
				grenade_owned_by_player_model = grenade.model;
				break;
			}
		}

//		if( timer >= timeup )
//		{
//			break;
//		}
		if( IsDefined( grenade_owned_by_player ) && grenade_owned_by_player )
		{
			// wait a sec to let the grenade get in the air
			if( grenade_owned_by_player_model == "projectile_m67fraggrenade" || grenade_owned_by_player_model == "projectile_m84_flashbang_grenade" )
			{
				wait 0.75;
			}
			break;
		}
		else if( level.player AttackButtonPressed() )
		{
			break;
		}
//		timer += 0.1;
		waitframe();
	}
//	IPrintLn( "busted for shooting" );
	thread mall_attack_player();
}

watch_glass()
{
	level endon( "swept_away" );
	level endon( "mall_attack_player" );
	
	flag_wait( "mall_breach_start" );
//	flag_wait( "player_on_mall_roof" );
//	level waittill( "breach_start" );
	
	glass_array = GetGlassArray( "mall_roof_glass" );
	glass_broken = false;
	
	while( !glass_broken )
	{
		foreach( piece in glass_array )
		{
			if( IsGlassDestroyed( piece ) )
			{
				glass_broken = true;
			}
		}
		waitframe();
	}

	thread mall_attack_player();
}

watch_player_pos()
{
	// early out if they are already attacking
	if( flag( "mall_attack_player" ) )
		return;
	
	self endon( "death" );
	level endon( "swept_away" );
	level endon( "mall_attack_player" );
	
	flag_wait( "player_on_mall_roof" );
//	level waittill( "breach_start" );
	
	cant_see_player = true;
	while( cant_see_player )
	{
//		IPrintLn( "looking for player pos" );
		time = GetTime();
//		while( self CanShoot( ( level.player GetEye() - ( 0, 0, 8 ) ) ) )
		// FIX JKU is this acceptable?  CanShoot was better but doesn't work with the vignette setup
		while( self CanSee( level.player ) )
		{
//			IPrintLn( "I see you: " + self.animname );
			if( ( GetTime() - time ) > 2000 )
			{
				cant_see_player = false;
				break;
			}
			waitframe();
		}
		waitframe();
	}
	
//	IPrintLn( "I see you: " + self.animname );
	self.spotter = true;
	level.allies[ 0 ] thread dialogue_queue( "flood_bkr_spottedus" );

	thread mall_attack_player();
}

watch_player_onroof_timer()
{
	// early out if they are already attacking
	if( flag( "mall_attack_player" ) )
		return;

	level endon( "swept_away" );
	level endon( "mall_attack_player" );
	
	flag_wait( "player_on_mall_roof" );
	//Baker: Go hot on Rook's mark.
	wait 0.5;
	//Price: Go hot on Elias's mark.
	radio_dialogue( "flood_bkr_hotonrooksmark" );
	wait 1;
	//Price: We can get the jump on them.
	radio_dialogue( "flood_bkr_thejump" );
	
//	// nagging player to break stealth
//	wait 3;
//	//Baker: Waiting on your mark, Rook.
//	level.allies[ 0 ] dialogue_queue( "flood_bkr_waiting" );
//	wait 1;
//	//Baker: Rook, they're bound to notice us.
//	level.allies[ 0 ] dialogue_queue( "flood_bkr_bountdtonotice" );

	// player dumb, allies breaking stealth
	wait 3;
	//Price: We can't wait any longer.
	radio_dialogue( "flood_bkr_cantwait" );
	wait 0.5;
	//Baker: Weapons Free!
	level.allies[ 0 ] dialogue_queue( "flood_bkr_weaponsfree" );
	battlechatter_on( "allies" ); 
	battlechatter_on( "axis" ); 
//	wait 0.5;
//	//Diaz: Tangos in the open! Open fire.
//	level.allies[ 1 ] thread dialogue_queue( "flood_diz_tangosintheopen" );
	
	level.allies[ 0 ].ignoreall = 0;
	level.allies[ 1 ].ignoreall = 0;
	level.allies[ 2 ].ignoreall = 0;
	
	// delay to get the allies shooting before we unleash the enemies
	wait 2;
	
	thread mall_attack_player();
}

// watch where the player is and move the enemies around accordingly
watch_goalvolume()
{
	level endon( "swept_away" );
	level endon( "roofcollapse_start" );
	
	flag_clear( "enemies_use_left" );
	flag_clear( "enemies_use_main" );
	
	while( 1 )
	{
		flag_wait( "enemies_use_left" );
		flag_clear( "enemies_use_main" );
//		IPrintLn( "left" );
		guys = get_ai_group_ai( "mall_ai" );
		maps\flood_util::reassign_goal_volume( guys, "mall_goalvolume_left" );
		
		flag_wait( "enemies_use_main" );
		flag_clear( "enemies_use_left" );
//		IPrintLn( "main" );
		guys = get_ai_group_ai( "mall_ai" );
		maps\flood_util::reassign_goal_volume( guys, "mall_goalvolume_main" );
	}
}

// spawn guys after the rocket event but before walkway
// this should allow for some dudes to fight along with a longer delay for the walkway event
flood_spawner( event, count, volume )
{
	level endon( "swept_away" );
	level endon( event );

	spawners	  = [];
	spawners[ 0 ] = GetEnt( "mall_ai_rocket_jumprail"	, "targetname" );
	spawners[ 1 ] = GetEnt( "mall_ai_rocket_farbalc"	, "targetname" );
	spawners[ 2 ] = GetEnt( "mall_ai_rocket_backwalkway", "targetname" );
	spawners[ 3 ] = GetEnt( "mall_ai_walkway_a"			, "targetname" );
	spawners[ 4 ] = GetEnt( "mall_ai_walkway_b"			, "targetname" );
	
	while( 1 )
	{
//		IPrintLn( "flood spawner: " + event + count + " alive" );
		baddies = get_living_ai_array( "mall_ai", "script_noteworthy" );
//		IPrintLn( baddies.size );
		if( baddies.size <= count )
		{
			// only spawn guys at the close area if you're not up in the close volume
			if( flag( "enemies_use_main" ) )
				spawner = spawners[ RandomInt( spawners.size ) ];
			else
				spawner = spawners[ RandomInt( ( spawners.size - 2 ) ) ];
			
			spawner remove_spawn_function( ::mall_enemy_spawn_func );
			spawner add_spawn_function( ::mall_enemy_spawn_func, volume );
			spawner spawn_ai( true );	
//			IPrintLn( "flooding a dude in: " + event );
			// don't flood dudes ontop of eachother
			wait 1;
		}
		waitframe();
	}
}

weapon_make_fall()
{
	self endon( "death" );
	
//	IPrintLn( "weapon checking for fall" );
	
	flag_wait( "ally_area_falling" );
	
	// pretty sure the above flag set by a notetrack is safe as that's the only area you could drop a weapon???
	// this notetrack is currently timed to when the crates and ally area starts falling
//	self block_until_ground_collapse( 1 );
	
	// can't put a dropped weapon under gravity so spawn a script model and link it to it
	gravity_hack = Spawn( "script_model", self.origin );
	gravity_hack thread event_gravity();
	self LinkTo( gravity_hack );
	
	wait 1;
    
	self Delete();
	gravity_hack Delete();
}

mall_delete_warehouse_ents()
{
	// still need to hide some if the interior warehouse geo before you get to the rooftop
	ents = GetEntArray( "mall_ware_brush_hide", "targetname" );
	array_delete( ents );

	// these are the rooftop ents in the mall_rooftop_map file
	ents = GetEntArray( "mall_brush_hide", "targetname" );
	array_delete( ents );
	
	// these are the warehouse light ray thingies
	ents = GetEntArray( "warevolumes", "targetname" );
	array_delete( ents );

	// kill the false ceiling inside the warehouse
	ents = GetEntArray( "mall_ware_model_hide", "targetname" );
	array_delete( ents );
	
	// get rid of the warehouse doors
	ent = GetEntArray( "warehouse_door_burst1", "targetname" );
	array_delete( ent );
	ent = GetEntArray( "warehouse_door_burst2", "targetname" );
	array_delete( ent );
	ent = GetEntArray( "warehouse_door_burst3", "targetname" );
	array_delete( ent );
}

mall_delete_rooftop_ents()
{
	// all the stuff that was spawned and linked to tags
	ents = GetEntArray( "mall_cleanup", "targetname" );
	array_delete( ents );

	// all the stuff that was spawned and linked to tags
	ents = GetEntArray( "acbox_obj", "targetname" );
	array_delete( ents );

	ents = GetEntArray( "mall_bokehdot", "targetname" );
	array_delete( ents );

	ents = GetEntArray( "mall_cleanup", "script_noteworthy" );
	array_delete( ents );

	// spawners
	ents = GetEntArray( "mall_ai", "script_noteworthy" );
	array_delete( ents );
	
	ent = GetEntArray( "mall_rooftop_heli", "targetname" );
	array_delete( ent );
	ent = GetEntArray( "mall_rooftop_heli_flyby1", "targetname" );
	array_delete( ent );
	ent = GetEntArray( "mall_rooftop_heli_flyby2", "targetname" );
	array_delete( ent );
	ent = GetEntArray( "mall_rooftop_heli_flyby3", "targetname" );
	array_delete( ent );
}

mall_rootop_event()
{
	level.player endon( "death" );
	level endon( "swept_away" );
	
	mallroof_firstframe();
	// play looping idle, currently on for the impact object
	level.mallroof_struct thread maps\_anim::anim_loop_solo( level.mallroof_impact, "mallroof_idle", "stop_loop" );

	// create the xmodels for the crates and shit
	level.mallroof_acboxes thread maps\flood_util::spawn_and_link_models_to_tags( "acbox_obj" );
	level.mallroof_smallrubble thread maps\flood_util::spawn_and_link_models_to_tags( "acbox_obj" );
	
	// FIX JKU does this belong here? 
	// this may seem like a weird place for this but this is also when I close the doors and you cant go back underwater and see the missing stuff.
	mall_delete_warehouse_ents();
	exploder( "mr_dust_slight" );

	// get rid of the light flare inside the warehouse
	Stop_exploder( "wh_randomfan_01" );

	// show the faux wall
	ents = GetEntArray( "mall_ware_brush_show", "targetname" );
	foreach( ent in ents )
		ent Show();

	flag_wait( "mall_attack_player" );

	// play vo because you've been spotted
	vign_pos = GetEnt( "flood_mall_roof_opfor", "targetname" );
    vign_pos.animname = "generic";
	switch( RandomInt( 2 ) )
	{
		case 0:
			//Venezuelan Soldier 2: Americans!
			vign_pos thread dialogue_queue( "flood_vz2_americans" );
			break;
		case 1:
			//Venezuelan Soldier 2: We're not alone up here!
			vign_pos thread dialogue_queue( "flood_vz2_notalone" );
			break;
	}
	
	// jumps down into your area
	spawner = GetEnt( "mall_ai_rocket_backwalkway", "targetname" );
	spawner add_spawn_function( ::mall_enemy_spawn_func, "mall_goalvolume_main", "mall_enemy_cover_close" );
	spawner spawn_ai( true );	
	
	// goes to the middle balcony
	spawner = GetEnt( "mall_ai_rocket_farbalc", "targetname" );
	spawner add_spawn_function( ::mall_enemy_spawn_func, "mall_goalvolume_main", "mall_enemy_cover_balc" );
	spawner spawn_ai( true );	
	
	// jumps the railing and runs the to the far planter
	spawner = GetEnt( "mall_ai_rocket_jumprail", "targetname" );
	spawner add_spawn_function( ::mall_enemy_spawn_func, "mall_goalvolume_main", "mall_enemy_cover_farplant" );
	spawner spawn_ai( true );	
	
	flag_wait( "player_on_mall_roof" );
	
	thread flood_spawner( "rocket_event", 4, "mall_goalvolume_main" );

	// FIX JKU need to talk to the sound stuff about all these extra waits and how to better time them.
	// this wait simulates how long the hole making event takes
	event_wait_time = 8.0; 
	//level.player delaycall( ( event_wait_time - 0.936 ), ::PlaySound, "scn_flood_mall_rumble_01" );
	wait event_wait_time;
	
//	IPrintLn( "cool down" );

	thread ally_roof_collapse_vo();
	exploder( "mall_roof_dust" );

	event_wait_time2 = 5.0;
	//level.player delaycall( ( event_wait_time2 - 0.238 ), ::PlaySound, "scn_flood_mall_rumble_02" );
	wait event_wait_time2;
	stop_exploder( "mr_dust_slight" );
	exploder( "mall_roof_dust" );

	exploder( "mr_dust_freguent" );
	exploder("mr_updust");

	// FIX JKU extra waits to extend the combat now that we're not delaying between the roof fall anim
	wait 3;
	
//	IPrintLn( "sec: 1" );
	
	// retreat!  this turns off the script reassigning enemies goal volumes based on where you're standing
	level notify( "roofcollapse_start" );

	// kill off the spawner
	// FIX JKU THIS MUST STAY!  ALLY ALSO MAY CREATE A FLOOD SPAWNER
	// DK IS USING THIS FOR THE CHOPPER TIMING
	flag_set( "rocket_event" );

	guys = get_ai_group_ai( "mall_ai" );
	
	foreach( guy in guys )
	{
		guy.ignoreall = 1;
		guy set_ignoreSuppression( true );
		guy thread ramp_down_accurracy( 3, 0 );
	}
	
	maps\flood_util::reassign_goal_volume( guys, "mall_goalvolume_roofcollapse" );
	
	foreach( guy in guys )
		guy thread roofcollapse_retreat();
		
	// new flood spawner that only uses the back goal volume
	thread flood_spawner( "swept_away", 4, "mall_goalvolume_roofcollapse" );
	
	// FIX JKU extra waits to extend the combat now that we're not delaying between the roof fall anim
	exploder("mr_updust");
	wait 3;

	// START ROOF FALLING VIGNETTE
	// FIX JKU maybe we should play this off a notetrack when the pieces you can actually stand on start falli//ng?
	level.mallroof_struct notify( "stop_loop" );
	level.mallroof_struct thread maps\_anim::anim_single( level.mallroof_array, "mallroof_collapse" );
	//thread maps\flood_fx::fx_rooftop_collapse_fx();
	thread maps\flood_audio::sfx_rooftop_collapse();
	//thread maps\flood_fx::fx_rooftop_crush_dust();
	thread event_quaker_collapse();
	exploder( "mall_roof_dust" );
	//IPrintLnBold( "updust" );

	// how long until a piece of the roof a dead enemy could be on starts falling
	flag_wait( "enemy_area_falling" );
	
//	IPrintLn( "locking corpses" );

	// generate an array of all the tags for the far section of the mall
	// these will be used to link the corpses to
	mallroof_far_bones = [];
	model_name = level.scr_model[ level.mallroof_far.animname ];
	num_tags = GetNumParts( model_name );
	for( i = 0; i < num_tags; i++ )
	{
		tag_name = GetPartName( model_name, i );
		tag_name_preifx = GetSubStr( tag_name, 0, tag_name.size - 3 );
		if( tag_name_preifx == "tag_corpse" )
		{
			mallroof_far_bones[ mallroof_far_bones.size ] = level.mallroof_far GetTagOrigin( tag_name );
//			JKUprint( tag_name );
//			JKUprint( mallroof_far_bones[ i ] );
		}
		else
		{
			mallroof_far_bones[ mallroof_far_bones.size ] = ( 99999, 99999, 99999 );
		}
//		waitframe();
	}
	
	// FIX JKU need to do this the right way?  Note tracks to tell me when to ragdoll  or use angles?
	corpse_array = GetCorpseArray();
	corpse_fall_volume = GetEnt( "corpse_fall_volume", "targetname" );
	
	// bones we want to do collision checks from
	trace_bones = [];
	trace_bones[ trace_bones.size ] = "j_mainroot";
	trace_bones[ trace_bones.size ] = "j_neck";
	trace_bones[ trace_bones.size ] = "j_ankle_le";
	trace_bones[ trace_bones.size ] = "j_ankle_ri";

	foreach( corpse in corpse_array )
	{
		// spawn some ents on corpses so we can use istouching and only do collision checks on corpses in volume
		corpse_ent = corpse spawn_tag_origin();
		if( corpse_ent IsTouching( corpse_fall_volume ) )
		{
//			Print3d( corpse_ent.origin + ( 0, 0, 12 ), "touching", ( 1, 1, 1 ), 1, 1, 1000 );
			// create an array of positions where the collision check hit the right model
			good_trace_positions = [];
			foreach( bone in trace_bones )
			{
				bonetrace = maps\flood_util::bullet_trace_debug( corpse GetTagOrigin( bone ) + ( 0, 0, 12 ), corpse GetTagOrigin( bone ) - ( 0, 0, 60 ), false, "white", 200, false );
				if( IsDefined( bonetrace[ "entity" ] ) && IsDefined( bonetrace[ "entity" ].targetname ) && bonetrace[ "entity" ].targetname == "flood_mallroof_far" )
					good_trace_positions[ good_trace_positions.size ] = bonetrace[ "position" ];
			}
			
			// create an array for the closest bones and their distances
			if( good_trace_positions.size > 0 )
			{
				closest_bone_positions =[];
				foreach( pos in good_trace_positions )
					closest_bone_positions[ closest_bone_positions.size ] = get_closest_point( pos, mallroof_far_bones );
				
				bone_distances =[];
				foreach( pos in good_trace_positions )
					bone_distances[ bone_distances.size ] = Distance2D( pos, closest_bone_positions[ bone_distances.size ] );
	
				// find the lowest distance
				// is there no util script for this???
				closest_bone_dist = bone_distances[ 0 ];
				closest_bone_dist_entry = 0;
				for( i = 0; i < bone_distances.size; i++ )
				{
					if( bone_distances[ i ] < closest_bone_dist )
						closest_bone_dist_entry = i;
				}
				
				// draw a debug line that is what was used to determine the tag we link to
//				line( good_trace_positions[ closest_bone_dist_entry ] + ( 0, 0, 12 ), good_trace_positions[ closest_bone_dist_entry ], ( 0, 255, 0 ), 1, false, 200 );
				
				corpse LinkTo( level.mallroof_far, GetPartName( model_name, array_find( mallroof_far_bones, closest_bone_positions[ closest_bone_dist_entry ] ) ) );
//				Print3d( corpse.origin, GetPartName( model_name, array_find( mallroof_far_bones, closest_bone_positions[ closest_bone_dist_entry ] ) ), ( 1, 1, 1 ), 1, 1, 1000 );
			}
			
			// thread something off to check verticality and ragdoll
			// FIX JKU this doesn't quite work because the corpses are under ai and I can't just ragdoll them....
			corpse thread corpse_ragdoll_when_vertical();
		}
		corpse_ent Delete();
	}

	// how long until a piece of the roof you could be standing on starts to fall
	flag_wait( "player_area_falling" );

//	IPrintLn( "no jump and thread weapons falling" );
	thread ally_roof_collapsing_vo();
	thread player_disallow_jump();
	
	// don't really like this but need to keep you from picking up weapons that may be about to fall
	level.player DisableWeaponPickup();
	
	// drop any weapon on the ground around you
	weapon_fall_volume = GetEnt( "weapon_fall_volume", "targetname" );
	// doesn't work???
//	weapons = GetWeaponArray();
	weapons = getallweapons();
	foreach( weapon in weapons )
	{
		if( weapon IsTouching( weapon_fall_volume ) )
		{
			weapon thread weapon_make_fall();
		}
	}
	stop_exploder("mall_floating_debri_med");
	delete_exploder("mall_floating_debri_med");
	
// do glass
//	ents = GetEntArray( "mall_roof_glass_breaker", "script_noteworthy" );
//	foreach( ent in ents )
//	{
//		glass = GetGlass( ent.target );
//		DestroyGlass( glass );
//		ent Delete();
//		waitframe();
//		DeleteGlass( glass );
//	}
	
	level.player block_until_ground_collapse();
	
	// kill off any grenades before we drop you
	grenades = GetEntArray( "grenade", "classname" );
	foreach( grenade in grenades )
	{
//		IPrintLn( "grenade killed" );
		grenade delete();
	}
	
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player DisableWeapons();
	level.player HideViewModel();
	
	slowmo_start();
	slowmo_setspeed_slow( 0.5 );
	slowmo_setlerptime_in( 0.1 );
	slowmo_lerp_in();
	
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	player_rig.angles = level.player.angles;
	thread smooth_player_link( player_rig, 0.25 );
//	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 15, 15, 15, 15, 1 );
	level.player thread maps\_anim::anim_single_solo( player_rig, "mall_roofcollapse_player01" );
	//thread maps\flood_coverwater::setup_player_view_water_fx_source();

	level.flood_mall_weapon_model = GetWeaponModel( level.player GetCurrentWeapon() );

	player_rig Attach( level.flood_mall_weapon_model, "tag_weapon", true );

	level.flood_mall_weapon_hidden_tags = GetWeaponHideTags( level.player GetCurrentWeapon() );
	foreach( hidden_tag in level.flood_mall_weapon_hidden_tags )
	{
		player_rig HidePart( hidden_tag, level.flood_mall_weapon_model );
	}
	
	while( 1 )
	{
		trace = BulletTrace( level.player.origin + ( 0, 0, 52 ), level.player.origin + ( 0, 0, 100 ), false, self );
		if( trace[ "surfacetype" ] == "water" )
		{
			thread maps\flood_swept::swept_underwater();
			break;
		}
		waitframe();
	}
	
	level.player notify( "noHealthOverlay" );
	level.cover_warnings_disabled = 1;

	thread maps\flood_audio::swept_away_scene( "beginning" );
	
	slowmo_setlerptime_out( 0.5 );
	slowmo_lerp_out();
	slowmo_end();
	
	level.player Unlink();
	player_rig Delete();
	
	level.player EnableWeaponPickup();
	level.player FreezeControls( false );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player EnableWeapons();
	level.player ShowViewModel();
	level.player AllowJump( true );
	
	thread maps\flood_audio::kill_sfx_dam_sirens();
	level notify( "swept_away" );
}

ramp_down_accurracy( time, final_accuracy )
{
	self endon( "death" );

	time = time * 1000;
	server_frames = time / 50;
	step_amount = ( self.baseaccuracy ) / server_frames;
	
	for( i = 0; i < server_frames; i++ )
	{
		self.baseaccuracy -= step_amount;
		waitframe();
	}
	
	self.baseaccuracy = final_accuracy;
}

corpse_ragdoll_when_vertical()
{
	self endon( "death" );
	level endon( "swept_away" );
	
	corpse_angles = self GetTagAngles( "tag_origin" );
	while( abs( corpse_angles[ 2 ] ) < 35 )
	{
//		IPrintLn( "checking corpses" );
		corpse_angles = self GetTagAngles( "tag_origin" );
		waitframe();
	}
	
	JKUprint( "vertical" );
	self Unlink();
//	self.ragdoll_immediate = true;
	// FIX JKU hmm, do I need to clean up these tag origins?
	tag_hack = self spawn_tag_origin();
	self LinkTo( tag_hack );
	tag_hack MoveGravity( ( 0, 0, -100 ), 3 );
	wait 3;
	tag_hack Delete();
}

player_disallow_jump()
{
//	IPrintLn( "jump turned off" );
	level.player AllowJump( false );
}

smooth_player_link( player_rig, blendtime )
{              
	level.player SetStance( "stand" );
	level.player PlayerLinkToBlend( player_rig, "tag_player", blendtime );
	wait( blendtime );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 15, 15, 15, 15, 1 );
}

mall_rooftop_flyby_helis()
{
	trigger = GetEnt( "player_mall_rooftop", "targetname" );
	Assert( IsDefined( trigger ));
	
	trigger waittill( "trigger" );

	thread mall_rooftop_flyby_heli1();
	thread mall_rooftop_flyby_heli2();
	thread mall_rooftop_flyby_heli3();
}

mall_rooftop_flyby_heli1()
{
	chopper = spawn_vehicle_from_targetname_and_drive( "mall_rooftop_heli_flyby1" );
	Assert( IsDefined( chopper ));
	
	chopper Vehicle_TurnEngineOff();
	thread maps\flood_audio::sfx_chopper_4_play( chopper );
	chopper SetHoverParams( 10, 10, 20 );
	chopper SetMaxPitchRoll( 30, 30 );
	chopper Vehicle_SetSpeed( 30, 10, 10 );
	
	heli_hover_node = GetStruct( "mall_rooftop_heli_flyby1_hover", "targetname" );
	Assert( IsDefined( heli_hover_node ));
	while( DistanceSquared( heli_hover_node.origin, chopper.origin ) > 400000 )
	{
		wait( 0.05 );
	}
	
	chopper thread vehicle_detachfrompath();
	
	heli_flyaway_node = GetStruct( "mall_rooftop_heli_flyby1_flyaway", "targetname" );
	Assert( IsDefined( heli_flyaway_node ));
	
	chopper SetVehGoalPos( heli_flyaway_node.origin, true );
	chopper Vehicle_SetSpeed( 20 );
	
	wait 8.0;
	
	chopper thread vehicle_paths( heli_flyaway_node );
	
	level waittill( "swept_away" );
	
	if( IsDefined( chopper ) )
	{
		chopper Delete();
	}
}

mall_rooftop_flyby_heli2()
{
	wait 15.0;
	
	chopper = spawn_vehicle_from_targetname_and_drive( "mall_rooftop_heli_flyby2" );
	chopper Vehicle_TurnEngineOff();
	thread maps\flood_audio::sfx_chooper_wait_and_play( chopper );
	
	Assert( IsDefined( chopper ));
	
	chopper SetMaxPitchRoll( 30, 30 );
	//chopper Vehicle_SetSpeed( 30, 10, 2 );
	
	level waittill( "swept_away" );
	
	if( IsDefined( chopper ) )
	{
		chopper Delete();
	}
}

mall_rooftop_flyby_heli3()
{
	wait 25.0;
	
	chopper = spawn_vehicle_from_targetname_and_drive( "mall_rooftop_heli_flyby3" );
	Assert( IsDefined( chopper ));
	
	chopper SetMaxPitchRoll( 30, 30 );
	//chopper Vehicle_SetSpeed( 30, 10, 2 );
	
	level waittill( "swept_away" );
	
	if( IsDefined( chopper ) )
	{
		chopper Delete();
	}
}

mall_rooftop_pickup_heli()
{	
	flag_wait( "mall_attack_player" );
	
	wait 6.0;
	
	chopper = spawn_vehicle_from_targetname_and_drive( "mall_rooftop_heli" );
	chopper Vehicle_TurnEngineOff();
	thread maps\flood_audio::sfx_play_chopper_5( chopper );
	
	Assert( IsDefined( chopper ));
	
//	struct = GetStruct( "mall_rooftop_heli_death_spot", "targetname" );
//	Assert( IsDefined( struct ));
	
	chopper SetMaxPitchRoll( 30, 60 );
	chopper SetYawSpeedByName( "slow" );
	chopper SetHoverParams( 50, 10, 20 );
	chopper.path_gobbler = true;
	//chopper.script_vehicle_selfremove = true;
//	chopper.perferred_crash_location = struct;

//	chopper thread mall_rooftop_heli_damage_watcher();
	
	chopper endon( "death" );
	
	heli_hover_node = GetStruct( "mall_rooftop_heli_hover", "targetname" );
	Assert( IsDefined( heli_hover_node ));
	while( DistanceSquared( heli_hover_node.origin, chopper.origin ) > 4000 )
	{
		wait( 0.05 );
	}
	
	chopper_lookat = Spawn( "script_model", ( 2176, -6784, 672 ) );
	chopper SetlookAtEnt( chopper_lookat );
	
	flag_set( "mall_rooftop_heli_flyaway" );
	
	chopper thread vehicle_detachfrompath();
	
	heli_flyaway_node = GetStruct( "mall_rooftop_heli_flyaway", "targetname" );
	Assert( IsDefined( heli_flyaway_node ));
	
	chopper Vehicle_SetSpeed( 2 );
	chopper SetVehGoalPos( heli_flyaway_node.origin, true );
	
	//level waittill( "swept_away" );
	flag_wait( "rocket_event" );
	
	wait 7.0;

	chopper.script_vehicle_selfremove = true;
	chopper ClearLookAtEnt();
	chopper thread vehicle_paths( heli_flyaway_node );
	
	wait 2.0;
	
	chopper SetYawSpeed( 100, 15 );
	
//	if( IsDefined( chopper ) )
//	{
//		chopper Delete();
//	}
}

mall_rooftop_heli_damage_watcher()
{
	self endon( "death" );
	
	hits = 0;
	while( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
		
		if( attacker == level.player )
		{
			hits++;
		}
		
		if( hits > 15 )
		{
			if( !flag( "mall_rooftop_heli_flyaway" ) )
			{
				self thread vehicle_detachfrompath();
				
				heli_hover_node = GetStruct( "mall_rooftop_heli_hover", "targetname" );
				Assert( IsDefined( heli_hover_node ));
				
				self Vehicle_SetSpeed( 2 );
				self SetVehGoalPos( heli_hover_node.origin, true );
			}
			
			wait 2.5;
			
			thread maps\flood_audio::sfx_kill_chopper_sound();
			self Kill();
			break;
		}
	}
}

event_quaker_big( guy )
{ 
	flag_set( "event_quaker_big" );
	
	level.player playsound("scn_flood_mall_rumble_shake_int_lg");
	wait 1.893;
	Earthquake( 0.5, 1.5, level.player.origin, 1600 );
	exploder("stairwell_dust");
	
	//Flicker light in stairway
	lightFlicker = GetEntArray("mall_flicker_light", "script_noteworthy");
	
	foreach (ent in lightFlicker)
	{

		{		    
			ent thread lightFlicker();
		}
		
		
	}
	
		
	//JL: Had to move the event_quaker_indoor thread here because it was causing multiple sounds to play at the same time. Will need a better solution when there is time.
	wait 2.0;
	thread event_quaker_indoor();
}

lightFlicker()
	{

		{		    
			self SetLightIntensity(.01);
		    wait .25;		    
		    self SetLightIntensity(4);
		}
		
		self maps\_lights::generic_flickering();
		wait 5;
		self notify("stop_dynamic_light_behavior");
		self SetLightIntensity(4);
	}

event_quaker_indoor()
{
	level endon( "swept_away" );
	level endon( "player_on_mall_roof" );
	
	while( 1 )
	{
		level.player playsound("scn_flood_mall_rumble_shake_int");
		thread maps\flood_audio::sfx_mall_ceiling_debris();
		Earthquake( RandomFloatRange( 0.05, 0.175 ), RandomFloatRange( 0.5, 1 ), level.player.origin, 1600 );
		exploder("stairwell_dust");
		wait RandomFloatRange( 4, 7 );
	}
}

event_quaker_outdoor()
{
	level endon( "swept_away" );
	level endon( "roofcollapse_start" );
	
	flag_wait( "player_on_mall_roof" );
	
	while( 1 )
	{
		//level.player playsound("scn_flood_mall_rumble_shake");
		Earthquake( RandomFloatRange( .075, .2 ), RandomFloatRange( 2, 3 ), level.player.origin, 1600 );
		exploder("mall_roof_dust");
		wait RandomFloatRange( 3, 7 );
	}
}

event_quaker_collapse()
{
	level endon( "swept_away" );
	
	// subtle for when the building is about to rip away up until you fall in the watre
	Earthquake( 0.15, 11, level.player.origin, 1600 );
	wait 4;
	// building falls and hits the ground
	Earthquake( 0.4, 1, level.player.origin, 1600 );
	wait 1;
	// noticeable chunks of roof start getting displaces
	Earthquake( 0.25, 1, level.player.origin, 1600 );
	wait 2.5;
	// building hits end before getting washed away
	Earthquake( 0.5, 1, level.player.origin, 1600 );
	wait 1.5;
}

event_gravity()
{
	self endon( "death" );
	
	range_min = -105;
	range_max = 105;
	
	self MoveGravity( ( RandomFloatRange( range_min, range_max ), RandomFloatRange( range_min, range_max ), RandomFloatRange( range_min, range_max ) ), 5 );
}

event_debris_fall()
{
	fall_time = 2;
	self RotateVelocity( ( RandomFloatRange( -200, 200 ), RandomFloatRange( -200, 200 ), RandomFloatRange( -200, 200 ) ), 3000 );
	self MoveTo( ( self.origin + ( 0, 0, -300 ) ), fall_time );
	
	fxtag = Spawn( "script_model", self.origin );
	fxtag SetModel( "tag_origin" );
	PlayFXOnTag( level._effect[ "giant_water_splash" ], fxtag, "tag_origin" );
	wait fall_time;
	StopFXOnTag( level._effect[ "giant_water_splash" ], fxtag, "tag_origin" );
	self Delete();
}

roofcollapse_retreat()
{
	self endon( "death" );
	
	self waittill( "goal" );
	self.ignoreall = 0;
	self set_ignoreSuppression( false );
}

mall_enemy_spawn_func( volume, goal_node )
{
	self endon( "death" );
	
	// different goal volume if you're camping in the hallway
	if( !flag( "player_on_mall_roof" ) )
	{
//		IPrintLn( "using other volume" );
		if( RandomInt( 2 ) == 0 )
			goalvolume = GetEnt( "mall_goalvolume_camper1", "targetname" );
		else
			goalvolume = GetEnt( "mall_goalvolume_camper2", "targetname" );
	}
	else
	{
//		IPrintLn( "using good volume" );
		goalvolume = GetEnt( volume, "targetname" );
	}
	
	self SetGoalVolumeAuto( goalvolume );
	self.animname = "generic";
	self.noragdoll = true;
	self.dropweapon = 0;
	self.grenadeammo = 0;
	
	// don't give everyone grenades and if we do don't give them a lot
//	if( RandomInt( 2 ) == 0 )
//		self.grenadeammo = 1;
//	else
//		self.grenadeammo = 0;
	
	if( IsDefined( goal_node ) && flag( "player_on_mall_roof" ) )
	{
		// would it be better to use goalpos here incase the node is taken.  that way they'd still get close the the node???
		self.goalradius = 8;
		node = GetNode( goal_node, "targetname" );
		self SetGoalNode( node );
		self waittill( "goal" );
		self.goalradius = 2048;
	}
	
//    self thread watch_player_pos();
    
	flag_wait( "mall_attack_player" );
	
	self.ignoreall = 0;
	
//	IPrintLn( "spawned guy with this goalvolume: " + volume );
}

enemy_setup_vign()
{
    pos = GetEnt( "flood_mall_roof_opfor", "targetname" );
	
	// start another script to deal with the small pieces we want to fall as soon as you walk out onto the roof.
    thread enemy_setup_vign_floor( pos );
	
    hanging_floor = spawn_anim_model( "mall_roof_opfor_geo", pos.origin );

    spawner = GetEnt( "mall_help_hanging_guy", "targetname" );
    help_hanging_guy = spawner spawn_ai( true );
    help_hanging_guy.animname = "opfor_1";
   	help_hanging_guy SetGoalVolumeAuto( GetEnt( "mall_goalvolume_main", "targetname" ) );
	help_hanging_guy.noragdoll = true;
	help_hanging_guy.health = 1;
	help_hanging_guy.grenadeammo = 0;
	help_hanging_guy gun_remove();
	help_hanging_guy.spotter = false;
    help_hanging_guy thread watch_player_pos();

	spawner = GetEnt( "mall_hanging_guy", "targetname" );
    hanging_guy = spawner spawn_ai( true );
    hanging_guy.animname = "opfor_2";
    hanging_guy.ignoreme = 1;
	hanging_guy.grenadeammo = 0;

	guys = [];
	guys["opfor_1"] = help_hanging_guy;
	guys["opfor_2"] = hanging_guy;
	guys["mall_roof_opfor_geo"] = hanging_floor;
	
    pos thread maps\_anim::anim_loop( guys, "flood_mall_roof_opfor", "stop_loop" );
	thread enemy_hanging_guy_vo( help_hanging_guy, hanging_guy );
    
	flag_wait( "mall_attack_player" );
    
	pos notify( "stop_loop" );
	help_hanging_guy StopAnimScripted();
	
	help_hanging_guy thread kill_help_hanging_guy();
	
	guys = [];
	guys["opfor_2"] = hanging_guy;
	guys["mall_roof_opfor_geo"] = hanging_floor;
    pos maps\_anim::anim_single( guys, "flood_mall_roof_opfor_shot" );
    
	hanging_guy.a.nodeath = true;
	hanging_guy.allowdeath = true;
	hanging_guy kill();
}

enemy_setup_vign_floor( pos )
{
	hanging_falling_floor = GetEnt( "roof_collapse_faling_floor_vign1", "targetname" );
	hanging_falling_floor Show();
	hanging_falling_floor.animname = "mall_roof_opfor_geo_vign";
	hanging_falling_floor assign_animtree();

	model_name = level.scr_model[ hanging_falling_floor.animname ];
	num_tags = GetNumParts( model_name );
	for( i = 0; i < num_tags; i++ )
	{
		tag_name = GetPartName( model_name, i );
		part_name = GetSubStr( tag_name, 4, tag_name.size - 4 );

		if( tag_name == "tag_ac_unit_2_wide_scaled_01 " )
		{
			acunit_obj = Spawn( "script_model", hanging_falling_floor GetTagOrigin( tag_name ) );
			acunit_obj SetModel( part_name );
			acunit_obj.angles = hanging_falling_floor GetTagAngles( tag_name );
			acunit_obj.targetname = "acbox_obj";
			acunit_obj LinkTo( hanging_falling_floor, tag_name );
		}
		waitframe();
	}
	
//	hanging_falling_floor = spawn_anim_model( "mall_roof_opfor_geo_vign", pos.origin + ( 562.4, -3492.4, 340.2 ) );
	
//	hanging_falling_floor.origin = ( 200.5, -2160.5, 392 );
	pos thread maps\_anim::anim_first_frame_solo( hanging_falling_floor, "flood_mall_roof_opfor_vign1" );

	flag_wait_any( "player_on_mall_roof", "mall_attack_player" );

	thread maps\flood_audio::sfx_mall_hanging_falling_floor();
	pos thread maps\_anim::anim_single_solo( hanging_falling_floor, "flood_mall_roof_opfor_vign1" );
}

kill_help_hanging_guy()
{
	pos = self.origin;
	
	while( IsAlive( self ) )
	{
//		MagicBullet( "mp5", ( 340, -1798, 284 ), self.origin + ( 0, 0, 32 ) );
//		wait 0.2;
		wait RandomFloatRange( 0.5, 1 );
		pos = self.origin;
		MagicBullet( "microtar", self.origin, self.origin + ( 0, 0, 32 ) );
	}

	// extra bullet so you get 2 shots and it seems less like a sniper kill
	wait 0.1;
	MagicBullet( "microtar", ( 340, -1798, 284 ), pos + ( 0, 0, 36 ) );
}

enemy_hanging_guy_vo( help_hanging_guy, hanging_guy )
{
	hanging_guy endon( "death" );
	help_hanging_guy endon( "death" );
//	level.lookat_hanging_guy endon( "death" );
	level endon( "mall_attack_player" );
	
	flag_wait( "player_on_mall_roof" );
	
	wait 0.5;
	//Venezuelan Soldier 4: Hold On!
	help_hanging_guy dialogue_queue( "flood_vs4_holdon" );
	//Venezuelan Soldier 5: I am holding on!
	hanging_guy dialogue_queue( "flood_vs5_holdingon" );
	//Venezuelan Soldier 5: Pull me up!
	hanging_guy dialogue_queue( "flood_vs5_pullmeup" );
	//Venezuelan Soldier 4: I can't get any leverage!
	help_hanging_guy dialogue_queue( "flood_vs4_getanyleverage" );
	//Venezuelan Soldier 5: I'm slipping! I'm slipping!
	hanging_guy dialogue_queue( "flood_vs5_imslipping" );

	wait RandomFloatRange( 2, 3 );
	while( 1 )
	{
		switch( RandomInt( 4 ) )
		{
			case 0:
				//Venezuelan Soldier 4: Hold On!
				help_hanging_guy dialogue_queue( "flood_vs4_holdon" );
				break;
			case 1:
				//Venezuelan Soldier 5: Pull me up!
				hanging_guy dialogue_queue( "flood_vs5_pullmeup" );
				break;
			case 2:
				//Venezuelan Soldier 4: I can't get any leverage!
				help_hanging_guy dialogue_queue( "flood_vs4_getanyleverage" );
				break;
			case 3:
				//Venezuelan Soldier 5: I'm slipping! I'm slipping!
				hanging_guy dialogue_queue( "flood_vs5_imslipping" );
				break;
		}
		wait RandomFloatRange( 1, 2 );
	}
}

enemy_twitch()
{
	flag_wait( "player_on_mall_roof" );

	spawner = GetEnt( "mall_lookat_hanging_guy", "targetname" );
	guy = spawner spawn_ai( true );
	
	guy SetGoalVolumeAuto( GetEnt( "mall_goalvolume_main", "targetname" ) );
	guy.animname = "generic";
	guy.allowdeath = true;
	guy.health = 150;
	guy.noragdoll = true;
	guy.spotter = false;
	guy.grenadeammo = 0;
	
	guy thread watch_player_pos();
	guy thread enemy_stop_vign_and_attack();
	guy thread enemy_twitch_runstumble();
}

enemy_twitch_runstumble()
{
	self endon( "death" );
    level endon( "mall_attack_player" );

	flag_wait( "player_on_mall_roof" );
	
	if( !flag( "mall_attack_player" ) )
	{
		ent = getstruct( "runstumble_runstumble", "targetname" );
	
		ent maps\_anim::anim_reach_solo( self, "run_react_stumble_non_loop" );
	    ent maps\_anim::anim_generic_run( self, "run_react_stumble_non_loop" );
	    self maps\_anim::anim_generic( self, "run_trans_2_readystand_1" );
	    self thread maps\_anim::anim_generic_loop( self, "readystand_idle_twitch_1", "stop_loop" );
	}
}

enemy_stop_vign_and_attack()
{
	self endon( "death" );
		
	flag_wait( "mall_attack_player" );
	
	self notify( "stop_loop" );
	self StopAnimScripted();
	self.ignoreall = 0;
}

enemy_rnd_runner()
{
	self endon( "death" );
	
	nodes = GetNodeArray( "mall_rnd_runner", "targetname" );
	old_node = nodes[ RandomInt( nodes.size ) ];
	rnd_node = nodes[ RandomInt( nodes.size ) ];
	self.fixednode = 1;
	self thread enable_cqbwalk();
	
	while( !flag( "mall_attack_player" ) )
	{
		while( Distance2D( old_node.origin, rnd_node.origin ) < 300 )
		{
			rnd_node = nodes[ RandomInt( nodes.size ) ];
			wait 0.05;
		}
		self.goalradius = 96;
		self SetGoalPos( rnd_node.origin );
		self waittill( "goal" );
		old_node = rnd_node;
//    	maps\_anim::anim_generic( self, "see_player" );
		wait RandomFloatRange( .75, 2 );
	}
	
	self thread disable_cqbwalk();
	self.goalradius = 2048;
	self.ignoreall = 0;
	self.fixednode = 0;
}

ally_make_fall()
{
	self endon( "death" );

	flag_wait( "ally_area_falling" );
	
	self thread maps\_anim::anim_single_solo( self, "flood_mall_roof_fall" );
	
	// if we let the allies move around again we'll need to re-enabled the ground checks
////	self block_until_ground_collapse();
//	self PushPlayer( false );
//    self.ragdoll_immediate = true;
//    self stop_magic_bullet_shield();
//    self.diequietly = true;
//    self kill();
}

ally0_mall()
{
	self.ignoreall = 1;
	self clear_force_color();
	self.goalradius = 8;
	self PushPlayer( true );
	self thread enable_cqbwalk();

	node = getstruct( "mall_breach_origin", "targetname" );
	node maps\_anim::anim_reach_solo( self, "flood_mall_roof_door" );
	node thread maps\_anim::anim_loop_solo( self, "flood_mall_roof_door_loop", "stop_loop" );
	//Price: Guns ready.
	self thread dialogue_queue( "flood_diz_gunsready" );
	flag_set( "ally0_breach_ready" );
	
	level waittill( "breach_start" );

	node notify( "stop_loop" );
	node maps\_anim::anim_single_solo( self, "flood_mall_roof_door" );
	self PushPlayer( true );
	self thread ally_make_fall();

	self.goalradius = 256;
	node = GetNode( "ally0_breach_goal", "targetname" );
	self SetGoalNode( node );
	self waittill( "goal" );

	// start telling the player to break stealth
	self thread watch_player_onroof_timer();
	
	flag_wait( "mall_attack_player" );
	
	// clear all the ignore setting used to run away from the water
	self maps\flood_flooding::ally_clear_flee_behavior();

//	self.fixednode = false;
	self.ignoreall = 0;
}

ally1_mall()
{
	// this is here to get the position of where the door vign starts.
	// if the position changes in the anim, this will need to be run again to get the new pos to move the node to.
//	node = getstruct( "mall_breach_origin", "targetname" );
//	startorg = GetStartOrigin( node.origin, node.angles, level.scr_anim[ "ally_1" ][ "flood_mall_roof_door" ] );
//	IPrintLn( startorg );
	
	self.ignoreall = 1;
	self clear_force_color();
	self.goalradius = 8;
	self PushPlayer( true );
	self thread enable_cqbwalk();

	node = getstruct( "mall_breach_origin", "targetname" );
	node maps\_anim::anim_reach_solo( self, "flood_mall_roof_door" );
	node thread maps\_anim::anim_loop_solo( self, "flood_mall_roof_door_loop", "stop_loop" );
	
	flag_wait( "mall_breach_start" );
	flag_wait_all( "ally0_breach_ready", "ally2_breach_ready" );

	node notify( "stop_loop" );
	
	exploder( "warehouse_wall_explode" );

	delaythread( 2.4, maps\flood_audio::stop_sfx_dam_siren_int);
	delaythread( 2.4, maps\flood_audio::start_sfx_dam_siren_ext, 0.3, 0.75);
	exploder( "mr_doorglow" );

	level notify( "breach_start" );
	thread maps\flood_audio::sfx_flood_int_door();
	
	// FIX JKU notetrack?
	//Vargas: At least five tangos. 10 meters.
	self delayThread( 4, ::dialogue_queue, "flood_diz_tangosoutthere" );
	//Price: Stay alert.
	self delayThread( 6, ::dialogue_queue, "flood_diz_staylowandquiet" );
	// FIX JKU notetrack?
	// remove clip plane that keeps you from getting stuck in the allies
	delayThread( 6, ::remove_hall_clip );
	// delay when the flag is set that the door is open.  this is for when we should start checking if the player is shooting
	maps\flood_util::flag_set_delayed( "breach_door_open", 6 );
	node thread maps\_anim::anim_single_solo( level.flood_mall_roof_door_model, "flood_mall_roof_door" );
	node maps\_anim::anim_single_solo( self, "flood_mall_roof_door" );
	
	// turn off door collision when it starts moving
	// FIX JKU this was disabled bc of a JIRA bug about no bullet decals and I think it's been safe to remove for a while since this
	// is left from the old way collision was done on the door.  still be careful that this doesn't cause any other problems
//	thread mall_door_temp_collision( "show" );
//	ents = GetEntArray( "mall_roof_door", "targetname" );
//	foreach( ent in ents )
//		ent NotSolid();
	
	self.goalradius = 96;
	node thread maps\_anim::anim_loop_solo( self, "flood_mall_roof_door_open_loop", "stop_loop" );
	
	nags	  = [];
	nags[ 0 ] = "flood_diz_outthererook";
	nags[ 1 ] = "flood_diz_bespotted";
	self delayThread( 8.0, maps\flood_util::play_nag, nags, "player_on_mall_roof", 5, 30, 1, 4 );
	
	flag_wait( "player_on_mall_roof" );
	self notify( "stop nags" );
	
	node notify( "stop_loop" );
	thread maps\flood_audio::sfx_mall_exit_door();
	thread rooftop_door_outdoor( node );
	node maps\_anim::anim_single_solo( self, "flood_mall_roof_door_outdoor" );
	self PushPlayer( true );
	self thread ally_make_fall();
	
//	self delayThread( 2, maps\flood_util::push_player, false );
	self.goalradius = 256;
	node = GetNode( "ally1_breach_goal", "targetname" );
	self SetGoalNode( node );
	self waittill( "goal" );
	
	flag_wait( "mall_attack_player" );

//	self set_force_color( "r" );

	// clear all the ignore setting used to run away from the water
	self maps\flood_flooding::ally_clear_flee_behavior();

	self.ignoreall = 0;
}

rooftop_door_outdoor( node )
{
	node maps\_anim::anim_single_solo( level.flood_mall_roof_door_model, "flood_mall_roof_door_outdoor" );
	
	// turn door collision back off now that it's closed
	thread mall_door_temp_collision();
	ents = GetEntArray( "mall_roof_door", "targetname" );
	foreach( ent in ents )
		ent Solid();
}

ally2_mall()
{
	self.flood_hasmantled = true;
	self.ignoreall = 1;
	self clear_force_color();
	self.goalradius = 8;
	self PushPlayer( true );
	self thread enable_cqbwalk();

	// get to door sooner bc he's delayed at the bottom....
	self.moveplaybackrate = 1.1;
	self.movetransitionrate = 1.1;
	self.animplaybackrate = 1.1;

	node = getstruct( "mall_breach_origin", "targetname" );
	node maps\_anim::anim_reach_solo( self, "flood_mall_roof_door_walkup" );
	node maps\_anim::anim_single_solo( self, "flood_mall_roof_door_walkup" );
	node thread maps\_anim::anim_loop_solo( self, "flood_mall_roof_door_loop", "stop_loop" );
	flag_set( "ally2_breach_ready" );
	
	self.moveplaybackrate = 1;
	self.movetransitionrate = 1;
	self.animplaybackrate = 1;

	level waittill( "breach_start" );
	
	thread maps\flood_audio::change_zone_stairwell();
	
	node notify( "stop_loop" );
	node maps\_anim::anim_single_solo( self, "flood_mall_roof_door" );
	self PushPlayer( true );
	self thread ally_make_fall();
	
//	blocker = GetEnt( "flooding_hallway_blocker2", "targetname" );
//	// FIX JKU should investigate why I need to do this isdefined check.  works fine w/o it from the checkpoint but not through progression
//	if( IsDefined( blocker ) )
//		blocker Delete();

	self.goalradius = 256;
	node = GetNode( "ally2_breach_goal", "targetname" );
	self SetGoalNode( node );
	self waittill( "goal" );
//	self set_force_color( "r" );
	
	flag_wait( "mall_attack_player" );
	
	// clear all the ignore setting used to run away from the water
	self maps\flood_flooding::ally_clear_flee_behavior();

//	self.fixednode = false;
	self.ignoreall = 0;
}

ally_roof_collapse_vo()
{
	level.player endon( "death" );
	level endon( "swept_away" );
	

	level.player maps\flood_audio::sfx_mall_first_screen_shake();
	Earthquake( .5, 1, level.player.origin, 1600 );
	
	//Vargas: This roof isn't holding together!
	level.allies[ 1 ] dialogue_queue( "flood_kgn_keepmoving" );
	//Merrick: What do you want to do about it? We're getting shot at!
	level.allies[ 2 ] dialogue_queue( "flood_diz_gettingshotat" );
	//Price: Just keep engaging targets!
	level.allies[ 0 ] dialogue_queue( "flood_diz_engagingtargets" );
}

ally_roof_collapsing_vo()
{
	level.player endon( "death" );
	level endon( "swept_away" );

	//Merrick: Half the roof's gone!
	level.allies[ 2 ] dialogue_queue( "flood_mrk_halftheroofsgone" );
	//Price: Well, I hope you can swim!
	level.allies[ 0 ] dialogue_queue( "flood_pri_wellihopeyou" );
}

trigger_player_mall_rooftop()
{
	trigger = GetEnt( "player_mall_rooftop", "targetname" );
	trigger waittill( "trigger" );
	
	flag_set( "player_on_mall_roof" );
	
	JKUprint( "player on mall roof" );
	
	// FIX JKU can't remember why I'm doing this???
	thread toggle_mall_door_clip( "show" );
	
	// hide warehouse interior water
	warehouse_layers = GetEntArray( "coverwater_warehouse", "targetname" );
	warehouse_layers_above = GetEnt( "coverwater_warehouse_above", "targetname" );
	warehouse_layers_under = GetEnt( "coverwater_warehouse_under", "targetname" );
	warehouse_layers = array_add( warehouse_layers, warehouse_layers_above );
	warehouse_layers = array_add( warehouse_layers, warehouse_layers_under );
	foreach( ent in warehouse_layers )
	{
		ent Hide();
		ent NotSolid();
	}
}

toggle_mall_door_clip( toggle )
{
	ent = GetEnt( "mall_door_clip", "targetname" );
	
	switch( toggle )
	{
		case "show":
			ent Show();
			ent Solid();
			break;
		case "hide":
			ent Hide();
			ent Notsolid();
			break;
	}
}

breach_door_open()
{
	breach_door = GetEnt( "mall_door_roof", "targetname" );
	parts = GetEntArray( breach_door.target, "targetname" );
	array_call( parts, ::LinkTo, breach_door );
	door_open_time = 1;
	breach_door RotateYaw( -65, door_open_time, 0.1, 0.1 );
	wait door_open_time;
	breach_door ConnectPaths();
}

breach_door_close()
{
	breach_door = GetEnt( "mall_door_roof", "targetname" );
	parts = GetEntArray( breach_door.target, "targetname" );
	array_call( parts, ::LinkTo, breach_door );
	door_open_time = 0.2;
	breach_door RotateYaw( 65, door_open_time, 0.1, 0.1 );
	wait door_open_time;
	breach_door DisconnectPaths();
}

breach_door_open_close()
{
	breach_door = GetEnt( "mall_door_roof", "targetname" );
	parts = GetEntArray( breach_door.target, "targetname" );
	array_call( parts, ::LinkTo, breach_door );
	breach_door RotateYaw( 125, 0.2, 0.1, 0.1 );
	breach_door ConnectPaths();

	// close the door back.  prob should find a better place to do this
	wait 0.3;
	breach_door RotateYaw( -125, 0.2, 0.1, 0.1 );
	wait 0.3;
	breach_door DisconnectPaths();
}

ally_breach_goal( target )
{
	self.ignoreall = 1;
	node = GetNode( target, "targetname" );
	self SetGoalNode( node );
	self waittill( "goal" );
	
	wait RandomFloatRange( 6, 7 );
	self.ignoreall = 0;
}

mall_rooftop_floor_splash()
{
	level endon( "swept_away" );
	
	splash_pos = GetEnt( "mall_under_rooftop_splash", "targetname" );
	dummy = spawn( "script_model", splash_pos.origin );
	dummy SetModel("tag_origin");
	
	wait( 0.1 );
	
	while( 1 )
	{
		PlayFXOnTag( level._effect[ "giant_water_splash" ], dummy, "tag_origin"  );
		
		wait RandomFloatRange( 4.5, 10.0 );
	}

}

mall_breach_enemy_1()
{
    spawner = getent( "mall_breacher_1", "targetname" );
    guy = spawner spawn_ai( true );
    guy thread mall_breach_enemy_setup();
    anim_pos = getstruct( "mall_breach_enemy_loc1", "targetname" );
    anim_pos maps\_anim::anim_generic( guy, "mall_breach_enemy_1" );
}

mall_breach_enemy_2()
{
    spawner = GetEnt( "mall_breacher_2", "targetname" );
    guy1 = spawner spawn_ai( true );
    guy1 thread mall_breach_enemy_setup();
    //guy1 thread control_mbs( 1.5 );
    guy1.animname = "breacher2";
    
    spawner = GetEnt( "mall_breacher_3", "targetname" );
    guy2 = spawner spawn_ai( true );
    guy2 thread mall_breach_enemy_setup();
    //guy2 thread control_mbs( 2.25 );
    guy2.animname = "breacher3";

    guys = make_array( guy1, guy2 );
    
    anim_pos = getstruct( "mall_breach_enemy_loc2", "targetname" );
    anim_pos maps\_anim::anim_single( guys, "mall_breach_enemy_2" );
}

mall_breach_enemy_ragdoll_on_death()
{
    // need to check.  think this is only used by the guy charging you in the sub.  probably because it would look funny if he ragdolled immediately
	self endon( "breach_enemy_cancel_ragdoll_death" );

    // cause death.gsc to do StartRagdollFromImpact() for us
    self.ragdoll_immediate = true;

    msg = self waittill_any_return( "death", "finished_breach_start_anim" );

    if ( msg == "finished_breach_start_anim" )
    {
        self.ragdoll_immediate = undefined;
    }
}

mall_breach_enemy_setup()
{
    self thread mall_breach_enemy_ragdoll_on_death();
    self.grenadeammo = 0;
    self.allowdeath = true;
    self.health = 10;
    self.baseaccuracy = 5000;
}

watch_glass_shot()
{
	ents = GetEntArray( "mall_roof_glass_breaker", "script_noteworthy" );
	foreach( ent in ents )
	{
		// break some panes at the start so you can better see what's going on
		if( ent.target == "mall_roof_glass_2a" ||  ent.target == "mall_roof_glass_3b" || ent.target == "mall_roof_glass_4a" || ent.target == "mall_roof_glass_4b" || ent.target == "mall_roof_glass_6b" || ent.target == "mall_roof_glass_9b" )
		{
			glass = GetGlass( ent.target );
			DestroyGlass( glass );
			ent Delete();
		}
		else
		{
			ent thread wait_for_bullet();
		}
	}
}

wait_for_bullet()
{
	level endon( "swept_away" );
	
//	flag_wait( "player_on_mall_roof" );
	level waittill( "breach_start" );

	self SetCanDamage( true );
	self waittill( "damage", damage, attacker, impact_vec, point, damageType, modelName, tagName );
	
	glass = GetGlass( self.target );
//	IPrintLn( "breaking: " + self.target );
	DestroyGlass( glass );
	
	thread mall_attack_player();

	self Delete();
}

mall_roof_door_firstframe()
{
	level.flood_mall_roof_door_model = spawn_anim_model( "flood_mall_roof_door_model" );
	node = getstruct( "mall_breach_origin", "targetname" );
	node thread maps\_anim::anim_first_frame_solo( level.flood_mall_roof_door_model, "flood_mall_roof_door" );
//	flood_mall_roof_door_collision = GetEnt( "mall_door_collision", "targetname" );
	ents = GetEntArray( "mall_roof_door", "targetname" );
	foreach( ent in ents )
		ent LinkTo( level.flood_mall_roof_door_model );
}

remove_hall_clip()
{
	ent = GetEnt( "mall_roof_door_hall_clip", "targetname" );
	ent Hide();
	ent NotSolid();
}

mallroof_firstframe( state )
{
	level.mallroof_back = GetEnt( "flood_mallroof_back", "targetname" );
	level.mallroof_back.animname = "mallroof_back";
	level.mallroof_back assign_animtree();
	
	level.mallroof_center = GetEnt( "flood_mallroof_center", "targetname" );
	level.mallroof_center.animname = "mallroof_center";
	level.mallroof_center assign_animtree();
	
	level.mallroof_far = GetEnt( "flood_mallroof_far", "targetname" );
	level.mallroof_far.animname = "mallroof_far";
	level.mallroof_far assign_animtree();
	
	level.mallroof_impact = GetEnt( "flood_mallroof_impact", "targetname" );
	level.mallroof_impact.animname = "mallroof_impact";
	level.mallroof_impact assign_animtree();
	
	level.mallroof_rafters1 = GetEnt( "flood_mallroof_rafters1", "targetname" );
	level.mallroof_rafters1.animname = "mallroof_rafters1";
	level.mallroof_rafters1 assign_animtree();
	
	level.mallroof_rafters2 = GetEnt( "flood_mallroof_rafters2", "targetname" );
	level.mallroof_rafters2.animname = "mallroof_rafters2";
	level.mallroof_rafters2 assign_animtree();
	
	level.mallroof_acboxes = GetEnt( "flood_mallroof_acboxes", "targetname" );
	level.mallroof_acboxes.animname = "mallroof_acboxes";
	level.mallroof_acboxes assign_animtree();
	
	level.mallroof_smallrubble = GetEnt( "flood_mallroof_smallrubble", "targetname" );
	level.mallroof_smallrubble.animname = "mallroof_smallrubble";
	level.mallroof_smallrubble assign_animtree();
	
	level.mallroof_cables = GetEnt( "flood_mallroof_cables", "targetname" );
	level.mallroof_cables.animname = "mallroof_cables";
	level.mallroof_cables assign_animtree();
	
	level.mallroof_struct = getstruct( "mallroof_collapse", "targetname" );

	level.mallroof_array						   = [];
	level.mallroof_array[ "mallroof_back"		 ] = level.mallroof_back;
	level.mallroof_array[ "mallroof_center"		 ] = level.mallroof_center;
	level.mallroof_array[ "mallroof_far"		 ] = level.mallroof_far;
	level.mallroof_array[ "mallroof_impact"		 ] = level.mallroof_impact;
	level.mallroof_array[ "mallroof_rafters1"	 ] = level.mallroof_rafters1;
	level.mallroof_array[ "mallroof_rafters2"	 ] = level.mallroof_rafters2;
	level.mallroof_array[ "mallroof_acboxes"	 ] = level.mallroof_acboxes;
	level.mallroof_array[ "mallroof_smallrubble" ] = level.mallroof_smallrubble;
	level.mallroof_array[ "mallroof_cables"		 ] = level.mallroof_cables;
		
	if( IsDefined( state ) && state == "hide" )
	{
		foreach( mallroof in level.mallroof_array )
			mallroof Hide();
		
		hanging_falling_floor = GetEnt( "roof_collapse_faling_floor_vign1", "targetname" );
		hanging_falling_floor Hide();
	}
	else
	{
		level.mallroof_struct thread maps\_anim::anim_first_frame( level.mallroof_array, "mallroof_collapse" );
		
		self delayThread( 0.5, ::mallroof_firstframe_show_objects );
	}
}

mallroof_firstframe_show_objects()
{
	foreach( mallroof in level.mallroof_array )
		mallroof Show();	
}

mall_door_temp_collision( state )
{
	door_temp = GetEnt( "mall_door_temp_collision", "targetname" );
	
	if( !IsDefined( state ) )
	{
		door_temp Hide();
		door_temp NotSolid();
		door_temp ConnectPaths();
	}
	else
	{
		door_temp Show();
		door_temp Solid();
		door_temp DisconnectPaths();
	}
}

mall_attack_player()
{
	flag_set( "mall_attack_player" );
	level notify( "mall_attack_player" );
	
	level.allies[ 1 ] notify( "stop nags" );
	
	//Baker: Weapons Free!
	level.allies[ 0 ] thread dialogue_queue( "flood_bkr_weaponsfree" );
	battlechatter_on( "allies" ); 
	battlechatter_on( "axis" ); 
	
	// hide the hack blocker to give you temp safe cover in the start area
	ent = GetEnt( "mall_start_cover_hack", "targetname" );
	ent Hide();
	ent NotSolid();
}