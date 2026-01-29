#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;
#include maps\iplane_code;

// todo
// finish fail condition when the player does not climb
// add geo the back sides of the panels that get ripped out.

main()
{
	template_level( "iplane" );
	maps\createart\iplane_art::main();
	maps\iplane_fx::main();
	maps\iplane_precache::main();
	
	thread precache_items();
	
		   //   msg 	    func 							   loc_string    optional_func 					  
	add_start( "opening" , maps\iplane::start_opening_setup , "opening"	  , maps\iplane::start_opening_main );
	add_start( "breach"	 , maps\iplane::start_breach_setup	, "breach"	  , maps\iplane::start_breach_main );
	add_start( "escape"	 , maps\iplane::start_escape_setup	, "escape"	  , maps\iplane::start_escape_main );
	add_start( "p_out"  , maps\iplane::start_out_parachute_setup	, "p_out"	  , maps\iplane::start_out_parachute_main );
	
	init_level_flags();

	maps\_load::main();
	maps\iplane_anim::main();
	//	maps\iplane_script::main();
	maps\iplane_audio::main();
	
	level.orig_phys_gravity	   = GetDvar( "phys_gravity" );
	level.orig_ragdoll_gravity = GetDvar( "phys_gravity_ragdoll" );
	level.orig_WakeupRadius	   = GetDvar( "phys_gravityChangeWakeupRadius" );
	level.orig_ragdoll_life	   = GetDvar( "ragdoll_max_life" );
	level.orig_sundirection	   = ( -14, 114, 0 ); //GetMapSunAngles(); this won't work since this area of plane is in a "stage" volume.
	
	level.org_view_roll = GetEnt( "org_view_roll", "targetname" );
	Assert( IsDefined( level.org_view_roll ) );
	level.aRollers = [];
	level.aRollers = array_add( level.aRollers, level.org_view_roll );
	
	thread init_mainAI();
	
	level.player NotifyOnPlayerCommand( "melee_button_pressed", "+melee" );
	level.player NotifyOnPlayerCommand( "melee_button_pressed", "+melee_breath" );
	level.player NotifyOnPlayerCommand( "melee_button_pressed", "+melee_zoom" );
}

precache_items()
{
	precache( "viewmodel_base_viewhands" ); // viewhands_player_fso	
	PreCacheShellShock( "hijack_minor" );
	PreCacheShellShock( "hijack_airplane" );
	PreCacheShellShock( "iplane_slowview" );
	PreCacheItem( "p99" );
	PreCacheItem( "ending_knife" );
	PreCacheModel( "vehicle_Y_8" );
	PreCacheModel( "com_folding_chair" );
	PreCacheModel( "viewhands_player_fso" );
	PreCacheModel( "viewhands_player_gs_hostage" );
}

init_level_flags()
{
	// beggninglevel.heroes
	flag_init( "plane_roll_right" );
	flag_init( "plane_roll_left" );
	flag_init( "plane_levels" );
	flag_init( "plane_third_hit" );
	flag_init( "ground_rotate_ref" );
	flag_init( "player_in_position_to_climb" );
	flag_init( "succesfull_climb" );
	flag_init( "player_has_climbed" );
	flag_init( "player_is_now_connected_to_the_plane" );
	flag_init( "stop_climb_out" );
	flag_init( "large_crate_movement" );
	flag_init( "rip_tail_off" );
	flag_init( "player_activated_ramps_open" );
	flag_init( "raise_enemy_plane" );
	flag_init( "start_explosion_breach" );
	flag_init( "player_in_position_to_see_wing_enemies" );
	flag_init( "open_bay_doors" );
	flag_init( "start_fling0" );
}

init_mainAI()
{
	level.enemies = [];
	
	spawner_bad_guys = GetEntArray( "evil", "targetname" );
	foreach ( spawner in spawner_bad_guys )
	{
		ai_2 = spawner spawn_ai( true, true );
		
		level.enemies[ level.enemies.size ] = ai_2;
		
		if ( !IsDefined( ai_2.script_noteworthy ) )
			continue;
		
		else if ( ai_2.script_noteworthy == "vargas" )
		{
			 level.vargas		   = ai_2;
			 level.vargas.animname = "vargas";
		}
		else if ( ai_2.script_noteworthy == "knees_one" )
		{
			level.knees_one			 = ai_2;
			level.knees_one.animname = "knees_one";
		}	
		
		else if ( ai_2.script_noteworthy == "knees_two" )
		{
			level.knees_two			 = ai_2;
			level.knees_two.animname = "knees_two";
		}		
	}
	
	level.heroes = [];
	
	spawners_heroes = GetEntArray( "heroes", "targetname" );
	foreach ( spawner in spawners_heroes )
	{
		
		ai = spawner spawn_ai( true, true );
		
		level.heroes[ level.heroes.size ] = ai;
		
		if ( !IsDefined( ai.script_friendname ) )
			continue;
		
		else if ( spawner.script_friendname == "price" )
		{
			level.price			 = ai;
			level.price.animname = "price";
		}
		else if ( spawner.script_friendname == "mccoy" )
		{
			level.mccoy			 = ai;
			level.mccoy.animname = "mccoy";
		}
		else if ( spawner.script_friendname == "kersey" )
		{
			level.kersey		  = ai;
			level.kersey.animname = "kersey";
		}		
		
		ai.script_friendname = spawner.script_friendname;
		ai.animname			 = spawner.script_friendname;
		
		ai make_hero();
		ai.ignoreSuppression = true;
		ai.suppressionwait	 = 0;
		ai disable_surprise();
		ai.IgnoreRandomBulletDamage = true;
		ai.disableplayeradsloscheck = true;
		ai.grenadeAwareness			= 0;
		ai.ignoreall				= 1;
		ai.ignoreme					= 1;
		ai.script_grenades			= 0;
		ai.originalbasaccuracy		= ai.baseaccuracy;
	}
}

start_opening_setup()
{	
	setup();
	
	thread sound_test();
	thread spawn_trigger_wait_open_doors();
	thread init_player();
	thread physics_of_objects_in_plane();
	thread window_god_rays();
	thread create_smoke_and_ambience();
	thread setup_chair();
	thread primary_light_control();
	thread do_tarps();
	thread rotate_camera_pre_crash_one();
	
	wait 0.7;
	
	thread moving_jeeps_and_crates();
	fake_stuff = GetEnt( "r_plane_player", "targetname" );

	// rotate the world back to place to show the plane turning.
	level.ground_brush RotateTo( ( 0, -15, -30 ), 0.1 );
	
	level.ground_brush RotateTo( ( 0, 0, 0 ), 15, 4, 4 );
	//level.ground_brush moveto( level.fly_away_or.origin, 75 );
	
	flag_wait( "player_activated_ramps_open" );
	
	thread ramp_red_light();
	
	wait 2.3;
	
	level.bay_door_lower thread lower_bottom_bay_door();
	level.bay_door_upper thread raise_top_bay_door();

			 //   timer    func 		     param1 	      param2   
	delayThread( 2.5	, ::set_vision_set, "coup_sunblind", 4 );
	delayThread( 4.9	, ::set_vision_set, "iplane"	   , 4 );
	//	delaythread( 11.1, ::send_notify, "price_cut_cord_one" );
	
	thread enemy_plane_behind();
	
	flag_wait( "start_explosion_breach" );
	
	player_on_back();
	thread rotate_plane();
	//	thread fx_climb_out_test();
	flag_set( "large_crate_movement" );
	//thread sound_test();
	wait 1;	
	level waittill ( "start_parachute_out" );
	
	//	flag_set( "stop_climb_out" );
		
	level.new_org anim_stopanimscripted();
		
	level.player unlink();
	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_one, "", 1 );
	Earthquake( 0.6, 0.3, level.player.origin, 50000 );
	Earthquake( 0.2, 12, level.player.origin, 50000 );

	wait 1;
	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_two, "", 9 );
	//	wait 3;
	//	level.fadein thread maps\_hud_util::fade_over_time( 1, 7 );
}

setup()
{
	
	level.fadein = create_client_overlay( "black", 1, level.player );
	
	bad_plane = GetEnt( "baddy_plane", "targetname" );
	bad_plane Hide();
	
	level.fly_away_or = Spawn( "script_origin", ( -560, 4696, -1968 ) );
	
	level.sky_brush	= GetEnt( "jungle_sky_model_ent", "targetname" );
	
	level.ground_brush = GetEnt( "ground_brush", "targetname" );
	
	level.ground_brush_two = GetEnt( "ground_brush_two", "targetname" );
	
	level.sky_brush LinkTo( level.ground_brush );
	level.ground_brush_two LinkTo( level.ground_brush );
	
	level.ent_parachute_from_plane_one = GetEnt( "parachute_from_plane_one", "targetname" );
	level.ent_parachute_from_plane_two = GetEnt( "parachute_from_plane_two", "targetname" );
	
	level.fadein thread maps\_hud_util::fade_over_time( 0, 0 ); // was 3
	
	white_light = GetEnt( "rear_primary_light", "targetname" );
	white_light delayThread( 0.7, ::light_blink );

	level.bay_door_lower = GetEnt( "door_lower", "targetname" );
	level.bay_door_upper = GetEnt( "door_upper", "targetname" );
	
	level.chair_vargas = GetEnt( "vargas_chair", "targetname" );
	
	level.chair_vargas Hide();
	
	level.plane_tail = GetEnt( "plane_tail", "targetname" );
	
	level.plane_core = GetEnt( "plane_fuselage", "targetname" );
	level.plane_core SetModel( "tag_origin" );
	
	level.plane_tail LinkTo( level.plane_core );
			
	level.plane_test_origin = Spawn( "script_model", level.plane_core.origin );
	level.plane_test_origin SetModel( "tag_origin" );	
	
	metal_clip = GetEnt( "metal_clip", "targetname" );
	metal_clip LinkTo( level.plane_core );

	
	vision_set_fog_changes( "iplane", .10 );
	
	level.ent_parachute_from_plane_one LinkTo( level.plane_core ); // this was linked to the world, I need to add another type of movement to this.
	level.ent_parachute_from_plane_two LinkTo( level.plane_core );
	
	thread wing_break_off();
	
	brush_models = GetEntArray ( "brush_model", "script_noteworthy" );
	foreach ( brush in brush_models )
	{
		brush LinkTo( level.plane_core );
	}
	
	ai_total = array_combine( level.enemies, level.heroes );
	foreach ( dude in ai_total )
	{
		dude LinkTo( level.plane_core );
	}
	
	mid_prim_l		   = GetEnt( "m_p_l", "targetname" );
	mid_prim_l_tracker = GetEnt( "m_p_l_tracker", "targetname" );
	
	middle_light_red		 = GetEnt( "m_p_l_r", "targetname" );
	middle_light_red_tracker = GetEnt( "m_p_l_r_tracker", "targetname" );
	
	middle_light_red thread light_follow_plane( middle_light_red_tracker );
	mid_prim_l thread light_follow_plane( mid_prim_l_tracker );
	
	l_m_tail = GetEntArray( "link_me_tail", "script_noteworthy" );
	foreach ( tail_obj in l_m_tail )
	{
		tail_obj LinkTo ( level.plane_tail );
	}
	
	level.kersey_anim_org = GetEnt( "kersey_anim_start", "targetname" );
	level.mccoy_anim_org  = GetEnt( "mccoy_anim_start", "targetname" );
	
	level.knees_one_anim_org = GetEnt( "on_knees_one", "targetname" );
	level.knees_two_anim_org = GetEnt( "on_knees_two", "targetname" );
	
	level.chair_vargas_2 = Spawn( "script_model", level.vargas.origin );
	level.chair_vargas_2 SetModel( "com_folding_chair" );
	level.chair_vargas_2.animname = "chair_real";
	level.chair_vargas_2 SetAnimTree();
	
	level.chair_vargas_2.reference = Spawn( "script_model", level.vargas.origin );
	level.chair_vargas_2.reference SetModel( "tag_origin" );
	
	level.bay_door_upper_model = Spawn( "script_model", level.bay_door_upper.origin );
	level.bay_door_upper_model SetModel( "tag_origin" );
	
	level.bay_door_lower_model = Spawn( "script_model", level.bay_door_lower.origin );
	level.bay_door_lower_model SetModel( "tag_origin" );
}

setup_plane_for_ripping()
{
	// outside on the left first area
	left_dmg_three = GetEnt( "left_dmg_three", "targetname" );
	left_dmg_three hide();
		
	// outside on the right first area
	dmg_right_one = GetEnt( "dmg_right_one", "targetname" );
	dmg_right_one hide();
		
	// middle outside top area	
	dmg_top_two_c = GetEnt( "dmg_top_two_c", "targetname" );
	dmg_top_two_c hide();
		
	// last outside area
	dmg_top_two_b = GetEnt( "dmg_top_two_b", "targetname" );
	dmg_top_two_b hide();
	
	//-------------------------------------
	//
	// All top pieces have been hiddin now.
	//
	//-------------------------------------
	
	// first inside area to the left of the player
	left_dmg_one = GetEnt( "left_dmg_one", "targetname" );
	left_dmg_one hide();
		
//	left_dmg_two = GetEnt( "left_dmg_two", "targetname" );
//	left_dmg_two hide();
		
	dmg_left_one_light = GetEnt( "dmg_left_one_light", "targetname" );
	dmg_left_one_light hide();
	
	// dmg on the left side	
	dmg_right_two	= GetEnt( "dmg_right_two", "targetname" );
	dmg_right_two hide ();
	
	dmg_right_three = GetEnt( "dmg_right_three", "targetname" );
	dmg_right_three hide();
	
	dmg_right_four	= GetEnt( "dmg_right_four", "targetname" );
	dmg_right_four hide();
		
	// middle inside big piece
	dmg_top_one = GetEnt( "dmg_top_one", "targetname" );
	dmg_top_one hide();
	
	//-----------------------------------------------------------
	//
	// Animated small parts in plane that don't get sucked out
	//
	//-----------------------------------------------------------
	
	mov_pipe0 = getent( "mov_pipe_left_red", "targetname" );
	mov_pipe1 = getent( "mov_pipe_left_red_two", "targetname" );
	
	mov_pipe0 thread plane_pieces_fake_jitter_small();
	mov_pipe1 thread plane_pieces_fake_jitter_small();

	go_to		 = Spawn( "script_origin", ( 15278, 4637, 100 ) );
	end_up_mid	 = Spawn( "script_origin", ( -7912, 816, 100 ) );
	end_up_right = Spawn( "script_origin", ( -4864, 10056, 100 ) );
	end_up_left	 = Spawn( "script_origin", ( -3560, -9360, 100 ) );
	
	next_brush = GetEnt( "dmg_left_epic_four", "targetname" );
	
	dmg_top_two_b = GetEnt( "dmg_top_two_b", "targetname" );
	dmg_top_two_b Hide();
	
	flag_wait( "start_fling0" );
	
	num = 0;
	while ( 1 )
	{	
		next_brush Unlink();
		wait 0.07;
		
		next_brush thread fling_object();
		
		if ( !IsDefined( next_brush.target ) )
		{
			break;
		}
		next_brush = next_brush get_target_ent();
	}
}

get_fling_forward( forward, base, x )
{
	return ( forward * pow( base, x ) );
}

get_fling_up( up, base, x )
{
	return ( up * ( 1 - pow( base, x ) ) );
}

fling_object()
{
	plane = GetEnt( "plane_fuselage", "targetname" );

	plane_angles  = plane.angles + ( 0, 180, 0 );
	plane_forward = AnglesToForward( plane_angles );
	min_point	  = plane.origin + ( plane_forward * -2000 );
	max_point	  = plane.origin + ( plane_forward * 2000 );
	focal_point	  = PointOnSegmentNearestToPoint( min_point, max_point, self.origin );
	
	start_origin = self.origin;

	count		 = 10;
	forward		 = AnglesToForward( plane_angles + ( 0, RandomIntRange( -7, 7 ), 0 ) ) * 20; // 20 changes the spacing of the dots along the forward direction
	angles		 = VectorToAngles( start_origin - focal_point );
	up			 = AnglesToForward( angles ) * 900;											 // 900 is the max height the object will go
	forward_base = 2;
	up_base		 = 0.94;																	 // this cannot be higher than 1, changes how tight the curve is
	
	//	level thread fling_debug( start_origin, forward, forward_base, up, up_base, focal_point );

	x = RandomIntRange( -500, -300 );
	y = RandomIntRange( -30, 30 );
	z = RandomIntRange( -50, 50 );
	self RotateVelocity( ( x, y, z ), 100 );
	move_time = 0.15;
	for ( i = 1; i < count; i++ )
	{
		origin = start_origin + get_fling_forward( forward, forward_base, i ) + get_fling_up( up, up_base, i );
		self MoveTo( origin, move_time );
		wait( move_time - 0.05 );
	}
	
	self Delete();
}

fling_debug( start_origin, forward, forward_base, up, up_base, focal_point )
{
	self endon( "death" );
	
	while ( 1 )
	{
		wait( 0.05 );
		
		Print3d( start_origin, ".", ( 1, 1, 0 ) );
		Print3d( focal_point, ".", ( 1, 0, 0 ) );

		last_origin = start_origin;		
		for ( i = 1; i < 10; i++ )
		{
			origin = start_origin + get_fling_forward( forward, forward_base, i ) + get_fling_up( up, up_base, i );
			Line( last_origin, origin );
			last_origin = origin;
			
			Print3d( origin, "." );
			Line( level.player.origin, ( 0, 0, -100000 ) );
		}
	}
}

window_god_rays()
{
	level.godrays = GetEntArray( "god_ray_emitter", "targetname" );
	
	foreach ( obj in level.godrays )
	{
		//play our own fx attached to entities, so we can rotate them.
		ent		   = spawn_tag_origin();
		ent.origin = obj.origin;
		ent.angles = obj.angles;
		
		if ( obj.script_noteworthy == "window_volumetric_open_l" )
			continue;
		
		
		if ( obj.script_noteworthy == "window_volumetric_open" )
		{
			PlayFXOnTag( getfx( "window_volumetric" ), ent, "tag_origin" );
		}
		else if ( obj.script_noteworthy == "window_volumetric_blinds" )
		{
			PlayFXOnTag( getfx( "window_volumetric_l" ), ent, "tag_origin" );
		}
		
		//attach *that* entity to one with zero rotation.
		entZeroRot		  = spawn_tag_origin();
		entZeroRot.origin = ent.origin;
		ent LinkTo( entZeroRot );
  // level.volumetric_window_fx_ents[level.volumetric_window_fx_ents.size] = ent;
  // level.volumetric_window_fx[level.volumetric_window_fx.size]		   = entZeroRot;
	}
	
	//level.aRollers = array_combine( level.aRollers, level.volumetric_window_fx );
}

create_smoke_and_ambience()
{	
	amb_rear = Spawn( "script_model", ( 15128, 4744, -352 ) );
	amb_rear SetModel( "tag_origin" );
	
	amb_front = Spawn( "script_model", ( 15470, 4742, -352 ) );
	amb_front SetModel( "tag_origin" );
	
	amb_mid = Spawn( "script_model", ( 15288, 4738, -352 ) );
	amb_mid SetModel( "tag_origin" );	
	
	amb_door = Spawn( "script_model", ( 14856, 4750, -330 ) );
	amb_door SetModel( "tag_origin" );
	
//	PlayFXOnTag( getfx( "smoke_ambience" ), amb_front, "tag_origin" );
//	PlayFXOnTag( getfx( "smoke_ambience" ), amb_rear, "tag_origin" );
//	PlayFXOnTag( getfx( "smoke_ambience" ), amb_door, "tag_origin" );
//	PlayFXOnTag( getfx( "smoke_ambience" ), amb_mid, "tag_origin" );
	
 	// clouds
 	// level._effect[ "smoke" ] = loadfx( "fx/maps/hijack/conference_room_smoke" ); 
	// level._effect[ "smoke_ambience" ] = loadfx( "fx/smoke/fog_ground_200_red_rvn" );
}

move_flaps()
{
	level endon( "player_in_position_to_see_wing_enemies" );
	
	// be sure to move the angles of the wing to the right position.
	
	//flag_wait( "player_in_position_to_see_wing_enemies" );
	// start at opposite angles sinse the plane is turning.
	while ( 1 )
	{
		wait 11;
		self RotatePitch( -3, 11 );
		wait 11;;
		self RotatePitch( 3, 11 );
	}
}

lower_bottom_bay_door()
{	
	self LinkTo( level.bay_door_lower_model );
	level.bay_door_lower_model LinkTo ( level.plane_core );
	
	//level.price linkto( level.bay_door_lower_model );

	level.bay_door_lower_model.animname = "bottom_ramp";	
	level.bay_door_lower_model SetAnimTree();
	
	level.bay_door_lower_model thread anim_single_solo( level.bay_door_lower_model, "plane_bottom_ramp_down" );

	// this was level.plane_core
	
	thread vargas_down_with_ramp();	
}

ramp_red_light()
{
	red_light = GetEnt( "rear_primary_light", "targetname" );
	
	small_red_lights = GetEntArray( "little_lights", "script_noteworthy" );
	
	tail_script_models = GetEntArray( "tail_lights_script_models", "script_noteworthy" );
	
	red_off_one_model	= GetEntArray( "tail_lights_red_off_one_model", "targetname" );
	red_off_two_model	= GetEntArray( "tail_lights_red_off_two_model", "targetname" );
	red_off_three_model = GetEntArray( "tail_lights_red_off_three_model", "targetname" );
	
	foreach ( light in tail_script_models )
	{	
		light LinkTo( level.plane_tail );
		light.light_model = Spawn( "script_model", light.origin );
		light.light_model SetModel( "tag_origin" );
		light.light_model LinkTo( level.plane_tail );
	}
	
	foreach ( light in small_red_lights )
	{	
		light LinkTo( level.plane_tail );
		light.light_model = Spawn( "script_model", light.origin );
		light.light_model SetModel( "tag_origin" );
		light.light_model LinkTo( level.plane_tail );
	}
	
	red_off_one	  = GetEntArray( "tail_lights_red_off_one", "targetname" );
	red_off_two	  = GetEntArray( "tail_lights_red_off_two", "targetname" );
	red_off_three = GetEntArray( "tail_lights_red_off_three", "targetname" );
	
	num = 0;
	
	tail_d_lights = GetEntArray( "tail_d_lights", "targetname" );
	
	foreach ( tail_light in tail_d_lights )
	{
		tail_light LinkTo( level.plane_core );
		tail_light SetModel( "tag_origin" );
	}
	
	
	while ( num <= 2 )
	{
		wait 0.1;
		num++;
		foreach ( light in tail_script_models )
		{	
//			playfxontag( getfx( "red_small_front" ), light.light_model, "tag_origin" );
//			playfxontag( getfx( "red_large_glow" ), light.light_model, "tag_origin" );
			
			PlayFXOnTag( getfx( "green_new_2" ), light.light_model, "tag_origin" );
//			playfxontag( getfx( "green_large_glow" ), light.light_model, "tag_origin" );
			
		}
		
		foreach ( tail_light in tail_d_lights )
		{
			PlayFXOnTag( getfx( "dlight_glow_medium_green" ), tail_light, "tag_origin" );
		}
		
//		foreach( light in tail_script_models )
//		{
//			playfxontag( getfx( "red_large_glow" ), light.light_model, "tag_origin" );
//		}
		
		wait 0.3;
		
		foreach ( light in tail_script_models )
		{
			
			StopFXOnTag( getfx( "green_new_2" ), light.light_model, "tag_origin" );		
//			stopfxontag( getfx( "red_large_glow" ), light.light_model, "tag_origin" );
			
//			stopfxontag( getfx( "green_small_front" ), light.light_model, "tag_origin" );
//			stopfxontag( getfx( "green_large_glow" ), light.light_model, "tag_origin" );
		}
		
		foreach ( tail_light in tail_d_lights )
		{
			StopFXOnTag( getfx( "dlight_glow_medium_green" ), tail_light, "tag_origin" );
		}

//		foreach( light in tail_script_models )
//		{
//			stopfxontag( getfx( "red_large_glow" ), light.light_model, "tag_origin" );
//		}
		
		wait 0.3;
	}
	
	//wait 999;
	
	num = 0;
	
	num1 = 0;
	
	// a flag is not tru
	while ( !flag ( "raise_enemy_plane" ) )
	//while( num <= 30 ) // was 30
	{	
		num++;
		foreach ( light in red_off_one )
		{
			
			PlayFXOnTag( getfx( "green_new_2" ), light.light_model, "tag_origin" );
			//playfxontag( getfx( "green_large_glow" ),light.light_model, "tag_origin" );	
				
			
//			playfxontag( getfx( "red_small_front" ), light.light_model, "tag_origin" );
//			playfxontag( getfx( "red_large_glow" ),light.light_model, "tag_origin" );
		}
		
		foreach ( tail_light in tail_d_lights )
		{
			PlayFXOnTag( getfx( "dlight_glow_medium_green" ), tail_light, "tag_origin" );
		}
		
		wait 0.3;
		
		foreach ( light in red_off_two )
		{
			
			
			PlayFXOnTag( getfx( "green_new_2" ), light.light_model, "tag_origin" );
			//playfxontag( getfx( "green_large_glow" ),light.light_model, "tag_origin" );	
			
			
//			playfxontag( getfx( "red_small_front" ), light.light_model, "tag_origin" );
//			playfxontag( getfx( "red_large_glow" ), light.light_model, "tag_origin" );
		}
		
		wait 0.3;
		
		foreach ( light in red_off_three )
		{
			
			PlayFXOnTag( getfx( "green_new_2" ), light.light_model, "tag_origin" );
			//playfxontag( getfx( "green_large_glow" ),light.light_model, "tag_origin" );	
			
			
//			playfxontag( getfx( "red_small_front" ), light.light_model, "tag_origin" );
//			playfxontag( getfx( "red_large_glow" ), light.light_model, "tag_origin" );
		}
		
		wait 0.5;
	
		foreach ( light in small_red_lights )
		{
			
			StopFXOnTag( getfx( "green_new_2" ), light.light_model, "tag_origin" );
			//stopfxontag( getfx( "green_large_glow" ), light.light_model, "tag_origin" );
			
			
//			stopfxontag( getfx( "red_small_front" ), light.light_model, "tag_origin" );
//			stopfxontag( getfx( "red_large_glow" ), light.light_model, "tag_origin" );
		}
		
		foreach ( tail_light in tail_d_lights )
		{
			StopFXOnTag( getfx( "dlight_glow_medium_green" ), tail_light, "tag_origin" );
		}
		
		
		wait 0.5;
	}
	
	wait 0.3;

	foreach ( light in small_red_lights )
	{
		StopFXOnTag( getfx( "green_new_2" ), light.light_model, "tag_origin" );
	}
	
	foreach ( tail_light in tail_d_lights )
	{
		StopFXOnTag( getfx( "dlight_glow_medium_green" ), tail_light, "tag_origin" );
	}
	
	
	num = 0;
	
	thread mid_dlight();
	
	while ( num <= 100 )
	{
		wait 0.1;
		num++;
		foreach ( light in small_red_lights )
		{	
			PlayFXOnTag( getfx( "red_small_front" ), light.light_model, "tag_origin" );
		}

		wait 0.3;
		
		foreach ( light in small_red_lights )
		{		
			StopFXOnTag( getfx( "red_small_front" ), light.light_model, "tag_origin" );			
		}
		
		wait 0.3;
	}
}

mid_dlight()
{
	
	middle_reds = GetEntArray( "middle_d_lights", "targetname" );
	tail_light	= GetEntArray( "tail_d_lights", "targetname" );
	
	combined_lights = array_combine( middle_reds, tail_light );
	
	foreach ( blink_red_light in combined_lights )
	{
		blink_red_light LinkTo( level.plane_core );
		blink_red_light SetModel( "tag_origin" );
	}
	
	while ( 1 )
	{
			wait 0.1;
			foreach ( blink_red_light in combined_lights )
			{
				 PlayFXOnTag( getfx( "red_large_glow" ), blink_red_light, "tag_origin" );
			}
			
			wait 0.3;
			
			foreach ( blink_red_light in combined_lights )
			{
				 StopFXOnTag( getfx( "red_large_glow" ), blink_red_light, "tag_origin" );
			}	
			
			wait 0.3;
	}
}

core_lights_red()
{
	lights_fuselage = GetEntArray( "lights_red_fuselage", "targetname" );
		
	foreach ( light in lights_fuselage )
	{	
		light LinkTo( level.plane_core );
		light SetModel( "tag_origin" );
	}
	
	num = 0;
	while ( num <= 100 )
	{
		wait 0.1;
		num++;
		foreach ( light in lights_fuselage )
		{		
			PlayFXOnTag( getfx( "red_small_front" ), light, "tag_origin" );
		}
		
		wait 0.3;
		
		foreach ( light in lights_fuselage )
		{
			StopFXOnTag( getfx( "red_small_front" ), light, "tag_origin" );
		}
		wait 0.3;
	}
}

light_blink()
{
	num = 0;
	while ( num <= 19 )
	{	
		num++;
		time	  = RandomFloatRange( 0.05, 0.1 );
		intensity = RandomFloatRange( 0.4, 1.6 );
		
		self SetLightIntensity( intensity );
		wait ( time );
		self SetLightIntensity( intensity );
		wait ( time );
	}
	
	wait 0.9;
	
	num = 0;
	while ( num <= 3 )
	{	
		num++;
  //time	  = RandomFloatRange( 0.05, 0.1 );
  //intensity = RandomFloatRange( 0.4, 1.6 );
		
		wait ( 0.1 );
		self SetLightIntensity( 1.2 );
		wait ( 0.05 );
	}

	self SetLightIntensity( 1.6 );
}

raise_top_bay_door()
{	
	self LinkTo( level.bay_door_upper_model );
	level.bay_door_upper_model LinkTo ( level.plane_core );

	level.bay_door_upper_model.animname = "top_ramp";	
	level.bay_door_upper_model SetAnimTree();
	
	level.bay_door_upper_model anim_single_solo( level.bay_door_upper_model, "top_ramp_up" );
}

rip_tail_off()
{
	// level.plane_tail	
	level.bay_door_upper_model LinkTo( level.plane_tail );
	level.bay_door_lower_model LinkTo( level.plane_tail );
	
	level.plane_tail_model = Spawn( "script_model", level.plane_tail.origin );
	level.plane_tail_model SetModel( "tag_origin" );
	
	level.plane_tail_model_dummy = Spawn( "script_model", level.plane_tail.origin );
	level.plane_tail_model_dummy SetModel( "tag_origin" );
	//level.plane_tail_model_dummy.angles = level.plane_tail.angles;
	
	level.plane_tail LinkTo( level.plane_tail_model );
	level.plane_tail_model LinkTo ( level.plane_core );

	level.plane_tail_model.animname = "tail";	
	level.plane_tail_model SetAnimTree();
	
	
	level.plane_tail_model_dummy anim_single_solo( level.plane_tail_model, "tail_ripoff" );
}

rip_left_wing_off()
{
	// level.left_wing 
	
	left_wing = GetEnt( "c17_left_wing", "targetname" );
	
	left_wing_flap		  = GetEnt( "c17_left_wing_flap", "targetname" );
	left_wing_flap.angles = left_wing_flap.angles + ( 0, 0, 0 );
	left_wing_flap thread move_flaps();
	
	
	left_wing_model = Spawn( "script_model", left_wing.origin );
	left_wing_model SetModel( "tag_origin" );
	
	left_wing LinkTo( left_wing_model );
	
	left_wing_model LinkTo ( level.plane_core );
	left_wing_model.animname = "wing_L";	
	left_wing_model SetAnimTree();
	left_wing_flap LinkTo( left_wing );
	
	left_wing_model anim_single_solo( left_wing_model, "wing_L_ripoff" );
	
	left_wing_model Hide();
}

batman_rotate_plane()
{
	// level.plane_core
	
	level.plane_core_model = Spawn( "script_model", level.plane_core.origin );
	level.plane_core_model SetModel( "tag_origin" );
	
	level.plane_core_model_dummy = Spawn( "script_model", level.plane_core.origin );
	level.plane_core_model_dummy SetModel( "tag_origin" );
	level.plane_core_model_dummy.angles = level.plane_core.angles;
		
	self LinkTo( level.plane_core_model );
	//level.plane_core_model linkto ( level.plane_core ); 

	level.plane_core_model.animname = "plane_body";	
	level.plane_core_model SetAnimTree();
	
	level.chair_vargas_2 anim_stopanimscripted();
	level.chair_vargas_2.reference anim_stopanimscripted();
	level.plane_core anim_stopanimscripted();
	level.vargas anim_stopanimscripted();

	level.vargas Unlink();
	
													  //   guy 				     anime 			 
	level.plane_core_model_dummy thread anim_single_solo( level.vargas		  , "vargas_fall_1" );
	level.plane_core_model_dummy thread anim_single_solo( level.chair_vargas_2, "chair_fall" );
		
	thread player_rotate_plane();
	level.plane_core_model_dummy thread anim_single_solo( level.plane_core_model, "body_turn_up" );
//	thread enemy_rotate_with_plane();
//	level.chair_vargas_2 Unlink(); 
	
	wait 2;
	middle_light_red = GetEnt( "m_p_l_r", "targetname" );
	middle_light_red SetLightIntensity( 1.6 );
}

enemy_rotate_with_plane()
{
	level.plane_core thread anim_single_solo( level.chair_vargas_2, "chair_fall", "tag_origin" );
	level.plane_core anim_single_solo( level.vargas, "vargas_fall_1" );
	//level.plane_core anim_last_frame_solo( level.vargas, "vargas_fall_1" );
}

rotate_camera_pre_crash_one()
{	
	level endon( "player_in_position_to_see_wing_enemies" );
	
	org_view_roll_ent = GetEnt( "org_view_roll", "targetname" );
	level.player PlayerSetGroundReferenceEnt( org_view_roll_ent );
	org_view_roll_ent RotateTo( ( 0, 0, 0 ), 0.1 );	
	org_view_roll_ent waittill( "rotatedone" );
	
	while ( 1 )
	{
		time = RandomFloatRange( 10, 14 );
		org_view_roll_ent RotateTo( ( 0, 0, -5 ), time );	
		wait ( time );
	
		org_view_roll_ent RotateTo( ( 0, 0, 5 ), time );
		wait ( time );
	}
}

rotate_camera_pre_crash_two()
{	
	org_view_roll_ent = GetEnt( "org_view_roll", "targetname" );
	level.player PlayerSetGroundReferenceEnt( org_view_roll_ent );
	org_view_roll_ent RotateTo( ( 0, 0, 0 ), 0.1 );	
	org_view_roll_ent waittill( "rotatedone" );
	
	while ( 1 )
	{
		time = RandomFloatRange( 1.3, 2.5 );
		org_view_roll_ent RotateTo( ( 0, 0, -7 ), time );	
		wait ( time );
	
		org_view_roll_ent RotateTo( ( 0, 0, 7 ), time );
		wait ( time );
	}
}

rotate_camera_fast( ent_to_rotate )
{	
	//level.player PlayerSetGroundReferenceEnt( org_view_roll_ent );
//	org_view_roll_ent RotateTo( ( 0, 0, 0 ), 0.1 );	
//	org_view_roll_ent waittill( "rotatedone" );
	
	while ( 1 )
	{
		time = RandomFloatRange( 0.3, 1.3 );
		ent_to_rotate RotateTo( ( 0, 0, -7 ), time );	
		wait ( time );
	
		ent_to_rotate RotateTo( ( 0, 0, 7 ), time );
		wait ( time );
	}
}

ground_movement()
{
	wait 15;
//	while( 1 )
//	{
//		level.ground_brush moveto( level.ground_brush.origin + ( 0, 0, 500 ), 25, 5, 5  );
//		level.ground_brush waittill( "movedone" );
//		
//		level.ground_brush moveto( level.ground_brush.origin + ( 0, 0, -500 ), 25, 5, 5 );
//		level.ground_brush waittill( "movedone" );
//	}
}

init_player()
{
	level.player DisableWeapons();
}

start_breach_setup()
{
	setup();
	
	thread sound_test();
	thread spawn_trigger_wait_open_doors();
	thread init_player();
	thread physics_of_objects_in_plane();
	thread window_god_rays();
	thread create_smoke_and_ambience();
	thread setup_chair();
	thread primary_light_control();
	thread do_tarps();
	thread rotate_camera_pre_crash_one();
	
	waitframe();
	
	thread moving_jeeps_and_crates();
	fake_stuff = GetEnt( "r_plane_player", "targetname" );
	
	thread ramp_red_light();	
	
	wait 2.3;
	
	level.bay_door_lower thread lower_bottom_bay_door();
	level.bay_door_upper thread raise_top_bay_door();
	
	
	flag_set( "raise_enemy_plane" );
	thread enemy_plane_behind();
	
	flag_wait( "start_explosion_breach" );
	
	player_on_back();
	thread rotate_plane();
	//	thread fx_climb_out_test();
	flag_set( "large_crate_movement" );
	//thread sound_test();
	wait 1;	
	level waittill ( "start_parachute_out" );
	
	//	flag_set( "stop_climb_out" );
		
	//	level.new_org anim_stopanimscripted();
		
	//	level.player unlink();
	//	
	//	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_one, "", 1 );
	//	Earthquake( 0.6, 0.3, level.player.origin, 50000 );
	//	
	//	Earthquake( 0.2, 12, level.player.origin, 50000 );
	//	
	//	wait 1;
	//	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_two, "", 9 );
	//	
	//	wait 3;
	//	
	//	level.fadein thread maps\_hud_util::fade_over_time( 1, 7 );
}

start_escape_setup()
{	
	setup();
	
	thread sound_test();
	thread spawn_trigger_wait_open_doors();
	thread init_player();
	thread physics_of_objects_in_plane();
	thread window_god_rays();
	
	level.fadein = create_client_overlay( "black", 0, level.player );
	
	bad_plane = GetEnt( "baddy_plane", "targetname" );
	bad_plane Hide();
	
	tarps = GetEntArray( "tarps0", "targetname" );
	foreach ( cloth in tarps )
	{
		cloth Hide();
	}
	
	metal_clip = GetEnt( "metal_clip", "targetname" );
	metal_clip LinkTo( level.plane_core );
	
	vision_set_fog_changes( "iplane", .10 );
	
	level.ent_parachute_from_plane_one LinkTo( level.plane_core );
	level.ent_parachute_from_plane_two LinkTo( level.plane_core );
	
	left_wing = GetEnt( "c17_left_wing", "targetname" );
	left_wing Hide();
	
	full_engine	= GetEnt( "full_engine", "targetname" );
	full_engine Hide();
	engine_top = GetEnt( "engine_top", "targetname" );
	engine_top Hide();
	
	engine_bottom = GetEnt( "engine_bottom", "targetname" );
	engine_bottom Hide();
	
	c17_right_wing = getent( "c17_right_wing", "targetname" );
	c17_right_wing hide();
	
	c17_right_wing_engines = GetEnt( "c17_right_wing_engines", "targetname" );
	c17_right_wing_engines Hide();
	
	c17_right_wing_flap = GetEnt( "c17_right_wing_flap", "targetname" );
	c17_right_wing_flap Hide();
	
	end_right_holder = GetEnt( "end_right_holder", "targetname" );
	end_right_holder Hide();

	end_left_holder = GetEnt( "end_left_holder", "targetname" );
	end_left_holder Hide();
						   
	engine_fan_one = GetEnt( "engine_fan_one", "targetname" );
	engine_fan_one LinkTo( engine_top );
	engine_fan_one Hide();
	
	engine_top LinkTo ( left_wing );
	engine_top Hide();

	engine_moving_fan = GetEnt( "engine_moving_fan", "targetname" );
	engine_moving_fan LinkTo ( full_engine );
	engine_moving_fan Hide();
	
	level.plane_tail Hide();
	level.bay_door_lower Hide();
	level.bay_door_upper Hide();
	
	l_m_tail = GetEntArray( "link_me_tail", "script_noteworthy" );
	foreach ( tail_obj in l_m_tail )
	{
		tail_obj Hide ();
	}
	
	ai_total = array_combine( level.enemies, level.heroes );
	foreach ( dude in ai_total )
	{
		dude LinkTo( level.plane_core );
	}
	
	wait 0.7;
	
	thread Earthquake_rumble(); // to low for climb out
	thread moving_jeeps_and_crates();
	fake_stuff = GetEnt( "r_plane_player", "targetname" );

	thread rotate_plane();
	wait 3;
	
	flag_set( "player_is_now_connected_to_the_plane" );
	
	
	level notify( "start_second_enemy_plane" );
	thread anim_first_roll_everyone();
	level.plane_core thread batman_rotate_plane();

	//	thread fx_climb_out_test();
	//thread sound_test();
	level waittill ( "start_parachute_out" );
	
	flag_set( "stop_climb_out" );
		
	level.new_org anim_stopanimscripted();
	level.new_org.angles = level.new_org.org_angles;
		
	level.player Unlink();
		
	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_one, "", 1 );
	Earthquake( 0.6, 0.3, level.player.origin, 50000 );
	Earthquake( 0.2, 12 , level.player.origin, 50000 );
		
	wait 1;
	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_two, "", 9 );
	
	//	wait 3;
	//	
	//	level.fadein thread maps\_hud_util::fade_over_time( 1, 7 );
}

start_out_parachute_setup()
{
	setup();
	
	level.player DisableWeapons();
		
	metal_clip = GetEnt( "metal_clip", "targetname" );
	metal_clip LinkTo( level.plane_core );
	
	level.tail_lights = GetEntArray( "lights_off_rear", "targetname" );
	
	vision_set_fog_changes( "iplane", .10 );
	
	level.ent_parachute_from_plane_one LinkTo( level.plane_core );
	level.ent_parachute_from_plane_two LinkTo( level.plane_core );
	
	
	tail_script_models = GetEntArray( "tail_lights_script_models", "script_noteworthy" );
	
	foreach ( light in tail_script_models )
	{	
		light hide();
	}
	
	left_wing = GetEnt( "c17_left_wing", "targetname" );
	left_wing Hide();
	
	full_engine	= GetEnt( "full_engine", "targetname" );
	full_engine Hide();
	engine_top = GetEnt( "engine_top", "targetname" );
	engine_top Hide();
	
	engine_bottom = GetEnt( "engine_bottom", "targetname" );
	engine_bottom Hide();
	
	c17_right_wing = getent( "c17_right_wing", "targetname" );
	c17_right_wing hide();
	
	c17_right_wing_engines = GetEnt( "c17_right_wing_engines", "targetname" );
	c17_right_wing_engines Hide();
	
	c17_right_wing_flap = GetEnt( "c17_right_wing_flap", "targetname" );
	c17_right_wing_flap Hide();
	
	end_right_holder = GetEnt( "end_right_holder", "targetname" );
	end_right_holder Hide();

	end_left_holder = GetEnt( "end_left_holder", "targetname" );
	end_left_holder Hide();
						   
	engine_fan_one = GetEnt( "engine_fan_one", "targetname" );
	engine_fan_one LinkTo( engine_top );
	engine_fan_one Hide();
	
	engine_top LinkTo ( left_wing );
	engine_top Hide();

	engine_moving_fan = GetEnt( "engine_moving_fan", "targetname" );
	engine_moving_fan LinkTo ( full_engine );
	engine_moving_fan Hide();
	
	level.plane_tail Hide();
	level.bay_door_lower Hide();
	level.bay_door_upper Hide();
	
	l_m_tail = GetEntArray( "link_me_tail", "script_noteworthy" );
	foreach ( tail_obj in l_m_tail )
	{
		tail_obj Hide ();
	}
	
	ai_total = array_combine( level.enemies, level.heroes );
	foreach ( dude in ai_total )
	{
		dude LinkTo( level.plane_core );
		dude hide();
	}
	
	wait 0.7;
	

	//thread rotate_plane();
	wait 3;
	
	flag_set( "player_is_now_connected_to_the_plane" );
	
	level.plane_core_model = Spawn( "script_model", level.plane_core.origin );
	level.plane_core_model SetModel( "tag_origin" );
	level.plane_core_model.animname = "plane_body";	
	level.plane_core_model SetAnimTree();
	
	
	level.plane_core_model_dummy = Spawn( "script_model", level.plane_core.origin );
	level.plane_core_model_dummy SetModel( "tag_origin" );
	level.plane_core_model_dummy.angles = level.plane_core.angles;
		
	level.plane_core LinkTo( level.plane_core_model );
	
	level.plane_core_model_dummy thread anim_single_solo( level.plane_core_model, "body_turn_up" );	
	
	wait 2;	
	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_one, "", 1 );
	Earthquake( 0.6, 0.3, level.player.origin, 50000 );
	Earthquake( 0.2, 12 , level.player.origin, 50000 );
		
	wait 1;
	level.player PlayerLinkToBlend( level.ent_parachute_from_plane_two, "", 9 );
		
		
}

start_out_parachute_main()
{
}

#using_animtree( "vehicles" );
moving_jeeps_and_crates()
{
	level.jeeps_plane = GetEntArray( "jeeps_on_plane", "targetname" );
	
	level.moving_crates_plane = GetEntArray( "moving_crates", "targetname" );
	
	level.lights_on	 = GetEntArray( "lights_on", "targetname" );
	level.lights_off = GetEntArray( "lights_off", "targetname" );
	
	level.fire_ext_models = GetEntArray( "fire_ext", "targetname" );
	
	level.tail_lights = GetEntArray( "lights_off_rear", "targetname" );
	
	lights_off_non_moving = GetEntArray( "lights_off_non_moving", "targetname" );
	lights_on_non_moving  = GetEntArray( "lights_on_non_moving", "targetname" );
	
	net_f_r = GetEnt( "netting_front_r", "targetname" );
	net_f_l = GetEnt( "netting_front_l", "targetname" );
	net_m	= GetEnt( "netting_middle", "targetname" );
	net_r	= GetEnt( "netting_rear", "targetname" );
	
	
	lights_new = array_combine( lights_off_non_moving, lights_on_non_moving );
	
	foreach ( crate in level.moving_crates_plane )
	{
		//		crate_anim_model = spawn( "script_model", crate.origin );
		//crate self_func( "useanimtree", #animtree );
		//		crate_anim_model self_func( "useanimtree", #animtree );
  //crate.animname					= "hummer";
  //	  crate_anim_model.animname = "hummer";
		//		crate_anim_model setmodel( "tag_origin" );
		//		crate setmodel( "tag_origin" );
		//crate linkto( level.plane_core  );
		//		crate_anim_model linkto( level.plane_core );

		
		//crate thread plane_pieces_fake_jitter_small();
		crate LinkTo ( level.plane_core );
	//	crate thread animate_crate();
	}
	
	foreach ( light_on in level.lights_on )
	{
		light_on LinkTo( level.plane_core );
	}
	
	foreach ( light_off in level.lights_off )
	{
		light_off LinkTo( level.plane_core );
	}
	
	foreach ( jeep in level.jeeps_plane )
	{
		//jeep self_func( "useanimtree", #animtree );
		//jeep.animname = "hummer";
		//jeep linkto( level.plane_core );
		
		 //jeep thread animate_crate();
		
		//jeep thread plane_pieces_fake_jitter_small();
		jeep LinkTo ( level.plane_core );
	}
	
	foreach ( ext in level.fire_ext_models )
	{
		ext LinkTo( level.plane_core );
	}
	
	foreach ( tail_light in level.tail_lights )
	{
		tail_light LinkTo ( level.plane_tail );
	}
	
	foreach ( light in lights_new )
	{
		light LinkTo( level.plane_core );
	}
}

animate_crate()
{
		wait RandomFloatRange( 0.1, 0.5 );
		self anim_single_solo ( self, "hummer_large_rocking" );
}

#using_animtree( "generic_human" );
setup_chair()
{
	//level.vargas teleport_ai( level.chair_vargas );
	//hostage_chair_twitch_idle
	
	thread cut_chair_sequence();
	
	// 15012 4698 -380
	level.chair_vargas_2.reference.angles = level.chair_vargas.angles + ( -10, 0, 0 );	// fake setup till this is riggerd properly.
	level.chair_vargas_2.reference.origin = level.chair_vargas.origin + ( 7, 3, -1.7 ); // fake setup till this is riggerd properly.
	level.chair_vargas_2.reference LinkTo ( level.chair_vargas );
	
	level.chair_vargas_2.origin = level.chair_vargas.origin;
	level.chair_vargas_2.angles = level.chair_vargas.angles;
	level.chair_vargas_2 LinkTo ( level.chair_vargas );

	level.vargas thread hide_weapon();
	
	thread loop_guy_in_chair_beg();
	
//	level.mccoy_anim_org thread anim_single_solo( level.mccoy, "rescue_chair_untie_soldier_idle", undefined ); // "cafe_chair3_lod0" 
	
//	level.kersey_anim_org thread anim_single_solo( level.kersey, "rescue_chair_untie_soldier_idle", undefined ); // "cafe_chair3_lod0" 
	
	level.knees_one thread hide_weapon();
	level.knees_one_anim_org thread anim_loop_solo( level.knees_one, "hostage_knees_loop", undefined ); // "cafe_chair3_lod0" 
	
	level.knees_two thread hide_weapon();
	level.knees_two_anim_org thread anim_loop_solo( level.knees_two, "hostage_knees_loop", undefined ); // "cafe_chair3_lod0" 	
}

//#using_animtree( "script_model" );
cut_chair_sequence()
{	
	chair_position_one	 = GetEnt( "chair_position_one_origin", "targetname" );
	chair_position_two	 = GetEnt( "chair_position_two_origin", "targetname" );
	chair_position_three = GetEnt( "chair_position_three_origin", "targetname" );
	
	chair_position_one LinkTo( level.bay_door_lower );
	chair_position_two LinkTo( level.bay_door_lower );
	chair_position_three LinkTo( level.bay_door_lower );
	
	level.player AllowMelee( false );
	

	
	level waittill ( "price_cut_cord_one" );
	
	level.chair_vargas_2 anim_stopanimscripted();
	level.chair_vargas_2.reference anim_stopanimscripted();
	level.plane_core anim_stopanimscripted();
	level.vargas anim_stopanimscripted();
	
	thread loop_guy_in_chiar_one();
	//  IPrintLnBold( "Vargas in chair begins to shake" );
	
	//	level.chair_vargas unlink();
	//	level.chair_vargas_2.angles = ( 359.203, 10.215, 8.05643 );
	//	level.chair_vargas moveto( chair_position_one.origin, 0.2 );
	
	thread knife_cutting();
	
	level.player EnableWeapons();
	level.player GiveWeapon( "ending_knife" );
	level.player SwitchToWeapon( "ending_knife" );
	
	
	level waittill ( "player_cut_cord_two" );
	
	level.chair_vargas_2 anim_stopanimscripted();
	level.chair_vargas_2.reference anim_stopanimscripted();
	level.plane_core anim_stopanimscripted();
	level.vargas anim_stopanimscripted();
	
	thread loop_guy_in_chiar_two();
	//	level.chair_vargas unlink();
	//	level.chair_vargas moveto( chair_position_two.origin, 0.2 );
	//	level.chair_vargas_2.angles = ( 359.203, 55.215, 8.05643 );
	
	//IPrintLnBold( "Vargas is looser and shakes even more");
	
	level waittill ( "player_cut_cord_three" );	
	
	
	//	level.chair_vargas unlink();
	//	level.chair_vargas_2.angles = ( 359.203, 180.215, 8.05643 );
	//	level.chair_vargas moveto( chair_position_three.origin, 0.2 );
	
	flag_set( "raise_enemy_plane" );
	//IPrintLnBold( "Vargas shakes violently" );
}

loop_guy_in_chair_beg()
{
	waitframe();
//	level.vargas linkto ( level.chair_vargas_2.reference );
	
	level.plane_core thread anim_loop_solo( level.vargas, "vargas_sit_idle", undefined, "tag_origin" );
	
	level.plane_core thread anim_loop_solo( level.chair_vargas_2, "chair_idle", undefined, "tag_origin" );
	//level.chair_vargas_2.reference thread anim_loop_solo( level.vargas, "vargas_sit_idle", undefined, "tag_origin" );
}

vargas_down_with_ramp()
{	
	level.plane_core thread anim_single_solo( level.vargas, "hostage_ramp_down", "tag_origin" ); // move vargas with chair and ramp
	
	level.plane_core anim_single_solo( level.chair_vargas_2, "chair_down_ramp", "tag_origin" );
	
	level notify ( "price_cut_cord_one" );
}

loop_guy_in_chiar_one()
{
	anim_length = GetAnimLength( %plane_hostage_idle_to_grab );

	level.plane_core thread anim_loop_solo( level.vargas, "vargas_sit_shake_1", undefined, "tag_origin" );
	
	level.plane_core thread anim_loop_solo( level.chair_vargas_2, "chair_shake_1", undefined, "tag_origin" );
}

loop_guy_in_chiar_two()
{
	level.plane_core thread anim_loop_solo( level.vargas, "vargas_sit_shake_2", undefined, "tag_origin" ); // "cafe_chair3_lod0"
	
	level.plane_core thread anim_loop_solo( level.chair_vargas_2, "chair_shake_2", undefined, "tag_origin" );
}	

print_dialogue()
{
	//wait 1;
	
//	add_dialogue_line( "Vargas", "So it's come down to this" );
	//thread add_dialogue_line( "Price", "Open the bay doors, now!" );
	
//	flag_set ( "open_bay_doors" );
	
	wait 4;
	
//	add_dialogue_line( "Price", "Where are you building Odin? " );
//	add_dialogue_line( "Vargas", "May, 18th, weds, 2010, Damn, 1800 hours. Remember, you left me. " );
	
	//	level waittill ( "price_cut_cord_one" );
	
//	add_dialogue_line( "Price", "Tell me where it is?" );
//	add_dialogue_line( "Vargas", "July ,6th, sat, 2024, Santa Monica, 0900 hours. You should have seen the look in his eyes when he saw me." );
	
	level waittill ( "player_cut_cord_two" );
	
	
//	add_dialogue_line( "Price", "I don't think you understand what's gonna happen here" );
//	add_dialogue_line( "Price", "WHERE ARE THEY REBUILDING ODIN" );
	
	level waittill ( "player_cut_cord_three" );
	
	//	add_dialogue_line( "Vargas", "Imagine leaving someone behind, left for dead. Then years later seeing that person show up at your door. It's odd, he didn't even fight. He just closed his eyes and I did the rest." );
	//	wait 6;
			
//	add_dialogue_line( "Price", "Arrrghghghgh!!!! cut this f****** loose!!!" );
	
	
//	add_dialogue_line( "Price", "Player, close the bay doors!!!!" );
	
	
	level waittill( "player_prompted_to_climb_out" );
}

knife_cutting()
{
	cut_trigger = Spawn( "trigger_radius", level.vargas.origin, 0, 100, 100 );
	// don't allow the player to melee friendlies

	player_cut = 0;
	
	while ( 1 )
	{
		if ( level.player IsTouching( cut_trigger ) )
		{
			level.player AllowMelee( true );
			level.player waittill ( "melee_button_pressed" );
		
			player_cut++;
			
			if ( player_cut == 1 )
				level notify ( "player_cut_cord_two" );	
			
			else if ( player_cut == 2 )
			{
				level notify ( "player_cut_cord_three" );
				break;
			}
		}
		wait 0.05;
	}
	// only work if the player is close 
}

hide_weapon()
{
	self HidePart( "tag_eotech" );
	self HidePart( "tag_silencer" );
	self HidePart( "tag_flash" );
	self HidePart_AllInstances( "tag_weapon" );
	self HidePart_AllInstances( "tag_clip" );
	weapon_model = GetWeaponModel( self.weapon );
	hideTagList	= GetWeaponHideTags( self.weapon );
	for ( i		= 0; i < hideTagList.size; i++ )
		self HidePart( hideTagList[ i ], weapon_model );
}

start_opening_main()
{
}

start_breach_main()
{
}

start_fight_main()
{
}

start_scramble_main()
{
}

start_escape_main()
{
}

spawn_wing_guys()
{
	spawner_bad_guyS = GetEntArray( "evil_wing_guys", "targetname" );
	foreach ( spawner in spawner_bad_guyS )
	{
		ai_2		   = spawner spawn_ai( true, true );
		ai_2.ignoreall = true;
		ai_2.ignoreme  = true;
		ai_2 ClearEnemy();
		ai_2 HidePart_AllInstances( "tag_weapon" );
		ai_2 HidePart_AllInstances( "tag_clip" );
		
		if ( IsDefined( ai_2.script_noteworthy ) && ai_2.script_noteworthy == "wing_guy_one" )
		{
			 level.wing_guy_one = ai_2;			
			 level.wing_guy_one Hide();

  //		   level.wing_guy_one.animname = "generic";
  //		   level.wing_guy_one.name	   = "planter";
			 
			// level.wing_guy_one thread wing_guy_anim_two();
			// level.wing_guy_one thread wing_guy_anims();
		}		
		
		if ( IsDefined( ai_2.script_noteworthy ) && ai_2.script_noteworthy == "wing_guy_two" )
		{
			 level.wing_guy_two			 = ai_2;
			 level.wing_guy_two.animname = "generic";
			 level.wing_guy_two.name	 = "planter_support";
			 level.wing_guy_two thread wing_guy_anim_two();
			// level.wing_guy_two thread wing_guy_anims();
		}	
	}
	thread trigger_wing_guys();
}

wing_guy_anims()
{
	self AllowedStances ( "crouch" );
	
	flag_wait( "player_in_position_to_see_wing_enemies" );
	
	if ( IsDefined( self.name ) && self.name == "planter" )
	{
		wait RandomFloatRange( 1.3, 3 );
	}
	else
		wait RandomFloatRange( 1, 1.3 );
		
//	jumper	
	self thread anim_single_solo( self, "jump_off_wing" );
	wait 0.5;
	self anim_stopanimscripted();
	
	org = Spawn( "script_origin", self.origin );
	self LinkTo ( org );
	self thread anim_single_solo( self, "wingsuit_idle" );
	
	flyto_org = Spawn ( "script_origin", ( 12440, 6048, 240 ) );
	
	z_radnom_one = RandomFloatRange( 50, 250 );
	org RotateTo( ( -70, -50, z_radnom_one ), 0.9 );
	
	z_random_two = RandomFloatRange( -1000, 1000 );
	org MoveTo ( flyto_org.origin + ( 0, 0, z_random_two ), 5, 2, 2 );
	
	if ( IsDefined( self.name ) && self.name == "planter_support" )
	{
	   wait 2.3;
	   flag_set ( "start_explosion_breach" );
	}
}

wing_guy_anim_two()
{
	node_test = GetEnt( "jumper", "targetname" );
	
	flag_wait( "player_in_position_to_see_wing_enemies" );
	//level.player PlayerSetGroundReferenceEnt( undefined );
	
	node_anim = GetEnt( "jumper", "targetname" );
	
	if ( IsDefined( self.name ) && self.name == "planter" )
	{
		wait RandomFloatRange( 1.3, 3 );
	}
	
	node_test thread anim_single_solo( self, "plane_bomb_on_plane" );
	
	if ( IsDefined( self.name ) && self.name == "planter_support" )
	{
	   wait 2.3;
	   flag_set( "start_explosion_breach" );
	}
}

wing_break_off()
{
	left_wing = GetEnt( "c17_left_wing", "targetname" );
	
	full_engine	  = GetEnt( "full_engine", "targetname" );
	engine_top	  = GetEnt( "engine_top", "targetname" );
	engine_bottom = GetEnt( "engine_bottom", "targetname" );
	
	c17_right_wing_engines = GetEnt( "c17_right_wing_engines", "targetname" );
	
	engine_fan_one = GetEnt( "engine_fan_one", "targetname" );
	engine_fan_one LinkTo( engine_top );
	
	engine_top LinkTo ( left_wing );

	
	
	engine_moving_fan = GetEnt( "engine_moving_fan", "targetname" );
	engine_moving_fan LinkTo ( full_engine );
	engine_moving_fan thread rotate_fan_on_engine();
	
	full_engine LinkTo ( left_wing );
	
	end_left_holder	 = GetEnt( "end_left_holder", "targetname" );
	end_right_holder = GetEnt( "end_right_holder", "targetname" );
	end_left_holder LinkTo( left_wing );
	end_right_holder LinkTo( left_wing );
	
	thread setup_engine_fx( engine_bottom, c17_right_wing_engines );
	
	thread setup_contrails();
	
	flag_wait( "player_in_position_to_see_wing_enemies" );
	
	wait 6.3; // time_for_wing

	
	//wait 8; // original working time.

	// wait 10; // good testing time to watch it right away.

 	thread rip_left_wing_off();

	wait 2.4;
	
  //  engine_go_to_one	 = Spawn( "script_origin", ( 9936.5, 4246.5, -694 ) );
  //  engine_go_to_two	 = Spawn( "script_origin", ( 8827, 4527.5, -694	 ) );
  //  engine_go_to_three = Spawn( "script_origin", ( 11664, 2512, -594	   ) );
//	
//	full_engine.origin = full_engine.origin + ( 0, 0, -20 ); // 15232 5280 -296
//	
//	engine_top.origin = engine_top.origin + ( 0, 0, 100 ); // 15136 5472 -288
//	
//	engine_bottom.origin = engine_bottom.origin + ( -400, -400, -70 ); // 15040 5472 -296
//	
//	engine_moving_fan Show();
//	engine_fan_one Show();	
//	full_engine Show();
//	engine_top Show();	
//	engine_bottom Show();
//	
//	//wait ( 999 );
//	
//	full_engine MoveTo( engine_go_to_three.origin, 5 );
//	full_engine thread rotate_engine();
//	wait 1.4;
//	
//	engine_bottom MoveTo( engine_go_to_three.origin + ( 0, -500, -200 ), 5 );
//	engine_bottom thread rotate_engine();
//	
//	wait 0.3;
//
//	engine_top MoveTo( engine_go_to_three.origin + ( 0, 500, -400 ), 5 );
//	engine_top thread rotate_engine();
	
}

setup_engine_fx( engine_bottom, c17_right_wing_engines )
{
	engine_heat_left_side = Spawn( "script_model", ( 15592, 5426, -340 ) ); // 5416
	engine_heat_left_side SetModel( "tag_origin" );
	engine_heat_left_side.angles = engine_heat_left_side.angles + ( 0, 180, 0 );
	engine_heat_left_side LinkTo( engine_bottom );
	
	engine_heat_left_side_two = Spawn( "script_model", ( 15730, 5116, -322 ) ); // 5416
	engine_heat_left_side_two SetModel( "tag_origin" );
	engine_heat_left_side_two.angles = engine_heat_left_side_two.angles + ( 0, 180, 0 );
	engine_heat_left_side_two LinkTo( engine_bottom );
	
	engine_heat_right_side = Spawn( "script_model", ( 15592, 4010, -340 ) ); // 4024
	engine_heat_right_side SetModel( "tag_origin" );
	engine_heat_right_side.angles = engine_heat_right_side.angles + ( 0, 140, 0 );
	engine_heat_right_side LinkTo( c17_right_wing_engines );

	engine_heat_right_side_two = Spawn( "script_model", ( 15726, 4312, -322 ) ); // 4024
	engine_heat_right_side_two SetModel( "tag_origin" );
	engine_heat_right_side_two.angles = engine_heat_right_side_two.angles + ( 0, 140, 0 );
	engine_heat_right_side_two LinkTo( c17_right_wing_engines );
	
	PlayFXOnTag( getfx( "jet_engine" ), engine_heat_left_side, "tag_origin" );
	PlayFXOnTag( getfx( "jet_engine" ), engine_heat_right_side, "tag_origin" );
	
	PlayFXOnTag( getfx( "jet_engine" ), engine_heat_left_side_two, "tag_origin" );
	PlayFXOnTag( getfx( "jet_engine" ), engine_heat_right_side_two, "tag_origin" );
}

setup_contrails()
{
	c17_left_wing_brush = GetEnt( "c17_left_wing", "targetname" );
	
	contrail_left_model = Spawn( "script_model", ( 15232, 5844, -280 ) );
	contrail_left_model SetModel( "tag_origin" );
	contrail_left_model LinkTo( c17_left_wing_brush );
	
	c17_right_wing_brush = GetEnt( "c17_right_wing", "targetname" );
	
	contrail_right_model = Spawn( "script_model", ( 15232, 3590, -280 ) );
	contrail_right_model SetModel( "tag_origin" );
	contrail_right_model LinkTo( c17_right_wing_brush );
	
	PlayFXOnTag( getfx( "contrail" ), contrail_left_model, "tag_origin" );
	PlayFXOnTag( getfx( "contrail" ), contrail_right_model, "tag_origin" );
}

rotate_fan_on_engine()
{
	while ( 1 )
	{
		self RotatePitch( 360, 1, 0.5, 0.5 );
		wait( 1 );
	}
}

rotate_engine()
{
	self.angles = self.angles + ( -10, -3, 13 );
	
	if ( IsDefined( self.targetname ) && self.targetname == "engine_top" )	
	{
		self.angles = self.angles + ( 40, 60, 70 );
	}
	if ( IsDefined( self.targetname ) && self.targetname == "engine_bottom" )
	{
		self.angles = self.angles + ( -120, -60, -120 );
	}
	
	while ( 1 )
	{
		if ( !IsDefined( self.targetname ) )
			continue;
			
		if ( self.targetname == "engine_top" )	
		{
			self RotateTo( ( 0, 0, 10 ), 1 );
			self waittill( "rotatedone" );
			
			self RotateTo( ( 0, 230, 40 ), 1 );
			self waittill( "rotatedone" );	
		}
		
		else if ( self.targetname == "engine_bottom" )
		{
			self RotateTo( ( 0, 0, 10 ), 0.1 );
			self waittill( "rotatedone" );
			
			self RotateTo( ( 0, 230, 40 ), 0.1 );
			self waittill( "rotatedone" );	
		}
		else
		
		self RotateTo( ( 0, 0, 10 ), 10 );
		self waittill( "rotatedone" );
			
		self RotateTo( ( 0, 230, 40 ), 1 );
		self waittill( "rotatedone" );
	}
}

trigger_wing_guys()
{
	fake_org = GetEnt( "look_out_window", "targetname" );
	
	wait 1;
	
	trig = Spawn( "trigger_radius", ( 15226, 4860, -334 ), 0, 50, 50 );
	
	while ( 1 )
	{
		if ( level.player IsTouching( trig ) )
		{
			flag_set( "player_in_position_to_see_wing_enemies" );
			thread player_press_button();
			wait 0.7;
			break;
		}			
		wait 0.3;	
	}
}

#using_animtree( "player" );
player_press_button()
{
	look_out_org = GetEnt( "look_out_org", "targetname" );
	
	re_align_player		   = Spawn( "script_model", ( 15216, 4840, -384 ) );
	re_align_player.angles = re_align_player.angles + ( 0, 90, 0 );
	
	level.player_rig = spawn_anim_model( "player_rig", look_out_org.origin );
	
	level.player_rig.angles = level.player_rig.angles +( 0, 70, 0 );
	level.player DisableWeapons();
	
	level.player_rig thread anim_single_solo( level.player_rig, "player_press_button", "tag_origin" );
 	level.player PlayerLinkToBlend( level.player_rig, "tag_player" );
 	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, 30, 30, 30, 30, true );
 	
 	wait 5.7;
 	
 	level.player PlayerLinkToBlend( re_align_player, "", 0.3, 0.3, 0.1 );
 	wait 0.5;
 	
 	level.player EnableWeapons();
 	level.player Unlink();
 	level.player_rig Delete();
}

spawn_trigger_wait_open_doors()
{	
	button_light_ref	   = GetEnt( "ramp_button", "targetname" );
	button_light_ref_model = Spawn ( "script_model", button_light_ref.origin );
	button_light_ref_model SetModel( "tag_origin" );

	
	button_on		= GetEnt( "button_model_on", "targetname" );
	button_on_model = Spawn ( "script_model", button_on.origin );
	button_on_model SetModel( "tag_origin" );
	
	button_off		 = GetEnt( "button_model_off", "targetname" );
	button_off_model = Spawn ( "script_model"	, button_off.origin );
	button_off_model SetModel( "tag_origin" );
	
	PlayFXOnTag( getfx( "red_small_front" ), button_off_model, "tag_origin" );
//	playfxontag( getfx( "red_large_glow" ), button_light_ref_model, "tag_origin" );
	
	button_on Hide();
	
	button = GetEnt( "ramp_button_trigger", "targetname" );
	
	
	button waittill( "trigger" );
	
	button_light_ref_model LinkTo( level.plane_core );
	button_on_model LinkTo( level.plane_core );
	button_off_model LinkTo( level.plane_core );
	

	StopFXOnTag( getfx( "red_small_front" ), button_off_model	, "tag_origin" );
	StopFXOnTag( getfx( "red_large_glow" ), button_light_ref_model, "tag_origin" );

	PlayFXOnTag( getfx( "green_new" ), button_on_model, "tag_origin" );
//	playfxontag( getfx( "green_large_glow" ), button_light_ref_model, "tag_origin" );
	
	button_off Delete();
	
	flag_set( "player_activated_ramps_open" );
	
	button_on Show();
	//	button_off hide();
}

rotate_plane()
{	
	level.new_org		   = Spawn ( "script_model", level.plane_core.origin );
	level.new_org.animname = "sky_anim";
	level.new_org.org_angles = level.new_org.angles;
	
	level.ground_brush LinkTo( level.new_org );
	
	flag_set( "player_is_now_connected_to_the_plane" );
	
	Earthquake( 1.1, 0.8, level.player.origin, 50000 );
	//	playfx( getfx( "explosion_1" ), level.plane_tail.origin );
	level.player DisableWeapons();
	
	
	level notify( "player_prompted_to_climb_out" );
	
	// this is how I will rotate the sun.
	// LerpSunAngles( (-5, 114, 0), (-24, 96, 0) , 1);
		
		foreach ( tail_light in level.tail_lights )
		{
			tail_light Hide ();
		}
}

plane_pieces_fall_off_when_close()
{
	self.before = true;
	num			= 0;
	
	while ( 1 )
	{
		wait 0.05;
		if ( Distance ( level.player.origin, self.origin ) < 400 )
		{
			
			while ( num <= 9 )
			{
				num++;
				time = RandomFloatRange( 0.01, 0.02 );		
				
				y = RandomFloatRange( -3, 3 );
				x = RandomFloatRange( -3, 3 );
				z = RandomFloatRange( -3, 3 );
				
				self RotateTo( ( y, x, z ), time );
				self waittill( "rotatedone" );
			}
			self MoveTo( self.origin + ( 0, 0, 5000 ), 7 );
			self waittill( "movedone" );
			self Hide();
			break;
		}
	}
	
}

plane_rip_apart_cowbell()
{
	// pull apart in order to simulate falling apart.
//	wait 4;
//	foreach(  part in level.epic_fall_apart_pieces )
//	{
//		wait RandomFloatRange( 0.2, 0.4 );
//		part hide();
//	}	
}

plane_pieces_fake_jitter()
{
	self.before = false;
		
	while ( self.before == false )
	{
		time = RandomFloatRange( 0.1, 0.2 );		
		
		y = RandomFloatRange( -0.35, 0.35 );
		x = RandomFloatRange( -0.35, 0.35 );
		z = RandomFloatRange( -0.35, 0.35 );
		
		self RotateTo( ( y, x, z ), time, 0.05, 0.05 );
		self waittill( "rotatedone" );
	}
}

plane_pieces_fake_jitter_small()
{	
	while ( 1 )
	{
		if ( !flag( "large_crate_movement" ) )
		 {
		
			time = RandomFloatRange( 0.1, 0.15 );		
			
			y = RandomFloatRange( -0.01, 0.01 );
			x = RandomFloatRange( -0.01, 0.01 );
			z = RandomFloatRange( -0.01, 0.01 );
			
			self RotateTo( self.angles + ( y, x, z ), time, 0.05, 0.05 );
			self waittill( "rotatedone" );
			
			y = RandomFloatRange( -0.01, 0.01 );
			x = RandomFloatRange( -0.01, 0.01 );
			z = RandomFloatRange( -0.01, 0.01 );
			
			self RotateTo( self.angles + ( y, x, z ), time, 0.05, 0.05 );
			self waittill( "rotatedone" );
		}
		else
			
			time = RandomFloatRange( 0.1, 0.2 );		
			
			y = RandomFloatRange( -0.75, 0.75 );
			x = RandomFloatRange( -0.75, 0.75 );
			z = RandomFloatRange( -0.75, 0.75 );
			
			self RotateTo( self.angles + ( y, x, z ), time, 0.05, 0.05 );
			self waittill( "rotatedone" );	
			
	}
}

#using_animtree( "player" );
climb_up()
{
	level endon( "stop_climb_out" );
	
	player_on_cieling = GetEnt( "r_plane_player_climb_thirteen", "targetname" );
	
	thread Earthquake_rumble2();
	thread climb_controls();
	//	thread play_anim_climbing_up_tracking_both_hands();
	
	thread physics_of_objects_in_plane();
	
	anim_time = 1.5;
	
	anim_time_two = 0.3;
	
	flag_wait( "player_is_now_connected_to_the_plane" );
	
	thread play_anim_climbing_up_tracking_both_hands();
	
	waitframe();
	IPrintLnBold( "use the left or right trigger to climb" );
	
	flag_wait( "player_has_climbed" );
	//	flag_set( "player_in_position_to_climb" );
	
	//	level.player_rig linktoblendtotag( r_plane_player_climb_one,  );
	
	next_point = GetEnt( "r_plane_player_climb_one", "targetname" );
	
	level.player SetStance( "stand" );
	
	num = 0;
	while ( 1 )
	{
		if ( IsDefined( next_point.speed ) )
		{
			time = Distance( level.player_anim_origin, next_point.origin ) / next_point.speed;
		}
		else
		{
			time = anim_time_two;
		}
		
		level.player_anim_origin MoveTo( next_point.origin, time );
		//level.player_anim_origin.angles = ( 180, 0, 180 );
		
		// change this to show you are on the side of the plane.
		// level.player_anim_origin.angles = ( 180, 0, 180 );
		
		num++;
//		if( num == 1 )
//			level.player_anim_origin.origin = level.player_anim_origin.origin + ( 0, 0, -50 );
		
		wait( time - 0.05 );
		
		if ( IsDefined( next_point.script_earthquake ) )
		{
			quake = next_point.script_earthquake;
			if ( quake == "big" )
			{
				Earthquake( 0.6, 0.3, level.player.origin, 50000 );
			}
		}
		
		if ( IsDefined( next_point.script_index ) )
		{
			if ( next_point.script_index == 1 )
			{
				level.player PlayerSetGroundReferenceEnt( player_on_cieling );
 				//level.player_anim_origin.angles = ( 270, 180, -180 );
				level.player_anim_origin.angles	  = ( 270, 168, 178 );
			}
		}
		
		if ( IsDefined( next_point.script_index ) )
		{
			if ( next_point.script_index == 2 )
			{
				Earthquake( 0.6, 01.1, level.player.origin, 1000 );
				flag_set( "start_fling0" );
			}
		}
		
		if ( IsDefined( next_point.script_index ) )
		{
			if ( next_point.script_index == 3 )
			{
				thread setup_plane_for_ripping();
			}
		}
		
		if ( IsDefined( next_point.script_index ) )
		{
			if ( next_point.script_index == 4 )
			{
				Earthquake( 0.4, 1.1, level.player.origin, 1000 );
				brush = getent( "dmg_top_two", "targetname" );
				brush thread fling_object();
			}
		}
		
		if ( IsDefined( next_point.script_index ) )
		{
			if ( next_point.script_index == 5 )
			{
				Earthquake( 0.4, 1.1, level.player.origin, 1000 );
				brush = GetEnt( "left_dmg_two", "targetname" );
				brush thread fling_object();
			}
		}
		
		stop_node = true;
		if ( IsDefined( next_point.script_stopnode ) )
		{
			stop_node = next_point.script_stopnode;
		}
		
		if ( stop_node )
		{
			flag_wait( "player_has_climbed" );
		}
		
		if ( !IsDefined( next_point.target ) )
		{
			break;
		}
		
		next_point = next_point get_target_ent();
	}
	
	level notify ( "start_parachute_out" );
}

climb_controls()
{
	level endon( "stop_climb_out" );
	//	level.player allowfire( true );
	level.used_right_hand = 0;
	level.used_left_hand  = 0;

	for ( ;; )
	{
		wait 0.001;
		
		if ( !flag ( "player_has_climbed" ) )
		{
			if ( level.player uselefthand() )
			{
				level.used_left_hand = 1;
			}
			
			if ( level.player userighthand() )
			{
				level.used_right_hand = 1;
			}
		}
	}	
}

player_rotate_plane()
{
	//wait 4;
	//////////////////////////////////////////////////////////////////////////////////////////
	/// 		debug
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*	
	// look at the anim dump to see what is starting and stopping is non stop.
	
	level.plane_core_model = Spawn( "script_model", level.plane_core.origin );
	level.plane_core_model setmodel( "tag_origin" );
	
	level.plane_core linkto( level.plane_core_model );
	//level.plane_core_model linkto ( level.plane_core ); 

	level.plane_core_model.animname = "plane_body";	
	level.plane_core_model SetAnimTree();
	
	level.plane_core thread anim_single_solo( level.plane_core_model, "body_turn_up" );
	*/
	//////////////////////////////////////////////////////////////////////////////////////////
	/// 		debug
	//////////////////////////////////////////////////////////////////////////////////////////
	
	level.player_rig = spawn_anim_model( "player_rig" );
	level.player_rig Hide();
	
	anim_length = GetAnimLength( %plane_player_fall );
	
	level.player DisableWeapons();
	
	level.plane_core thread anim_single_solo( level.player_rig, "player_fall", "tag_origin" );
	
	wait( 1.333 );
	
	level.player_rig Show();
		
	delayThread( 5, ::screen_effects_middle );

	level.player PlayerLinkToBlend( level.player_rig, "tag_player", 1.666 );
	wait( anim_length - 1.333 ); // need a notetrack for when to link the player to the airplane.
	level.player_rig LinkTo( level.plane_core );
	
	wait 6.7;
	thread fall_test_2();
	thread slow_mo_catch();
}

elias_grab()
{
	level.price Unlink();
	level.price Show();
	level.plane_core anim_single_solo( level.price, "helper_fall_2", "tag_origin" );
}

fall_test_2()
{

/* test	
	level.plane_core LinkTo( level.plane_core_model );
	level.plane_core_model linkto ( level.plane_core ); 

	level.plane_core_model.animname = "plane_body";	
	level.plane_core_model SetAnimTree();

	
	thread player_rotate_plane();
	thread enemy_rotate_with_plane();
	level.chair_vargas_2 Unlink();
	level.plane_core thread anim_single_solo( level.plane_core_model, "body_turn_up" );

	level.player_rig = spawn_anim_model( "player_rig", level.player.origin );
	level.player_rig SetModel( "viewhands_player_fso" );
	
	level.player PlayerLinkToBlend( level.player_rig, "tag_player", 0.01 );
	waitframe();
	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, 10, 20, 10, 10, true );	


	wait 9;
*/	

	level.plane_core anim_stopanimscripted();	
	level.price Show();	

	// need this fake origin for the how the anim was done.
	
	wait 2;
	// will probably make this blink
	mid_prim_l = GetEnt( "m_p_l", "targetname" );
	mid_prim_l SetLightIntensity( 1.6 );
	
	level.plane_test_origin thread anim_single_solo( level.player_rig, "player_fall_2", "tag_origin" );
	level.plane_test_origin anim_single_solo( level.price, "helper_fall_2", "tag_origin" );
	player_on_back = GetEnt( "player_on_back_one", "targetname" );
	level.player PlayerSetGroundReferenceEnt( player_on_back );
	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, 30, 30, 100, 10, true );
	
	level.new_org SetAnimTree();
	// level.new_org SetAnimtime( %plane_skybox_spin, 0.1 );
	level.new_org SetModel( "jungle_sky_model" );
	level.new_org thread anim_loop_solo( level.new_org, "sky_spin_one" );

	wait 1;
	thread climb_up();
}

slow_mo_catch()
{
	wait 2.7; // 2.4
	

//	maps\_art::dof_enable_script( 1, 1, 4, 40, 70, 4, 0.1 );
	
	thread screen_effects_close();
	
	wait 0.2;
	
	starttimescale	= 1;   //0.15
	endTimescale_to = 0.1; //1
	time			= 0.3; //1.8
	slow_mo_think( starttimescale, endTimescale_to, time );
	
	wait 0.3;

	starttimescale	= 0.1; //0.15
	endTimescale_to = 1;   //1
	time			= 0.5; //1.8
	slow_mo_think( starttimescale, endTimescale_to, time );
}

#using_animtree( "player" );
play_anim_climbing_up_tracking_both_hands()
{	
	level endon( "stop_climb_out" );
	
	level.player Unlink();
	on_back_one = GetEnt( "r_plane_player_climb_one", "targetname" );
	
	//level.player_rig.angles = level.player_rig.angles + ( 180, -180, 0 );
	
	player_on_back = GetEnt( "r_plane_player_climb_one", "targetname" );
	level.player PlayerSetGroundReferenceEnt( player_on_back );
	//thread rotate_camera_fast( player_on_back );
	
  //angles						  = ( 0, 180, 0 );
	level.player_anim_origin		= Spawn( "script_model", on_back_one.origin );
	level.player_anim_origin.angles = on_back_one.angles;
  //level.player.origin			  = level.player.origin + (0, 0, -72 );
	level.player_anim_origin SetModel( "tag_origin" );
	
	thread fx_climb_out_test();
//`	level.player setstance( "prone" );
	
	//	origin = ( 16002.5, 4710.5, -326 );
	
  //  level.player_rig.origin = origin;
  //  level.player_rig.angles = angles;

	// level.player PlayerLinkToBlend( level.player_anim_origin, "tag_player" );
	// level.player.origin = level.player_anim_origin.origin + ( 0, 0, -300) ;
	
	//wait 999;
	
	waitframe();
	
	if ( IsDefined( level.player_rig ) )
		level.player_rig Delete();
	
	waitframe();
	 
//	level.player_rig = spawn_anim_model( "player_rig", on_back_one.origin );
//	level.player_rig SetModel( "viewhands_player_fso" );	
  //  level.player_anim_origin.angles = ( 0, 0, 0 );
  //  level.player_rig.angles		  = ( 270, 359.906, 0.0937648 ); // 0, 180, 0

	waitframe();
	
	level.used_left_hand = 1;

	level.player PlayerLinkToBlend( level.player_anim_origin, "tag_origin" );
	level.player PlayerLinkToDelta( level.player_anim_origin, "tag_origin", 1, 50, 50, 70, 35, true );
	
//	level.player_rig LinkTo( level.player_anim_origin, "tag_origin", ( 0, 0, 0), ( 0, 0, 0 ) );
//	level.player PlayerLinkToBlend( level.player_rig, "tag_player" );
//	level.player playerlinktodelta( level.player_rig, "tag_player", 1, 30, 30, 180, 0, true );
	
	level.scr_anim[ "player_rig" ] [ "hand_climb_right" ] = %plane_player_climb_R;
	level.scr_anim[ "player_rig" ] [ "hand_climb_left"	] = %plane_player_climb_L;
	
	left_anim_length  = GetAnimLength( %plane_player_climb_L );
	right_anim_length = GetAnimLength( %plane_player_climb_R );
	
	short_anim_length = 0.3;

	for ( ;; )
	{
		wait 0.01;
		
		if ( level.used_left_hand == 1 )
		{
			level.player_anim_origin anim_stopanimscripted();
			flag_set( "player_has_climbed" );
			waitframe();
			flag_clear( "player_has_climbed" );
			
	//		level.player_anim_origin anim_single_solo( level.player_rig, "hand_climb_left" );
			wait( short_anim_length );
			level.used_left_hand = 0;
		}
		
		if ( level.used_right_hand == 1 )
		{
			level.player_anim_origin anim_stopanimscripted();
			flag_set( "player_has_climbed" );
			waitframe();
			flag_clear( "player_has_climbed" );
			
		//	level.player_anim_origin anim_single_solo( level.player_rig, "hand_climb_right" );
			wait( short_anim_length );
			level.used_right_hand = 0;
		}
	}
}

uselefthand()
{
	if ( level.Console )
	return level.player AttackButtonPressed();
	else
	return level.player ButtonPressed( "mouse1" );
}

userighthand()
{
	if ( level.Console )
	return level.player AdsButtonPressed();
	else
	return level.player ButtonPressed( "mouse2" );
}

loop_right_hand()
{	
	level.player_anim_origin anim_loop_solo( level.player_rig, "plane_player_climb_idle_R" );
}

loop_left_hand()
{
	level.player_anim_origin anim_loop_solo( level.player_rig, "plane_player_climb_idle_R" );
}

link_player_and_move_him_up()
{
	// attach the player and then detach him he is holding on to each trigger.	
}

control_movement_on_climb()
{
	
	flag_set( "player_in_position_to_climb" );
	flag_clear( "player_in_position_to_climb" );
}

screen_effects_close()
{
//	dof_see_knife				 = [];
//	dof_see_knife[ "nearStart" ] = 1;
//	dof_see_knife[ "nearEnd"   ] = 1;
//	dof_see_knife[ "nearBlur"  ] = 4;
//	dof_see_knife[ "farStart"  ] = 40;
//	dof_see_knife[ "farEnd"	   ] = 70;
//	dof_see_knife[ "farBlur"   ] = 4;
	
	maps\_art::dof_enable_script( 1, 1, 4, 40, 70, 4, 0 );
	wait( 1.5 );
	maps\_art::dof_disable_script( 0.4 );
}

screen_effects_middle( )
{
//	dof_see_knife				 = [];
//	dof_see_knife[ "nearStart" ] = 1;
//	dof_see_knife[ "nearEnd"   ] = 1;
//	dof_see_knife[ "nearBlur"  ] = 6;
//	dof_see_knife[ "farStart"  ] = 60;
//	dof_see_knife[ "farEnd"	   ] = 120;
//	dof_see_knife[ "farBlur"   ] = 6;

	maps\_art::dof_enable_script( 1, 1, 6, 60, 120, 6, 2.5 );
	wait( 5.3 );
	maps\_art::dof_disable_script( 0.1 );
}

screen_effects_far( blend_time0, blend_time1, hold_time )
{
	// blur goes on and off as you climb out	
	
	normal = level.dofDefault;
	
	dof_see_knife				 = [];
	dof_see_knife[ "nearStart" ] = 1;
	dof_see_knife[ "nearEnd"   ] = 1;
	dof_see_knife[ "nearBlur"  ] = 4;
	dof_see_knife[ "farStart"  ] = 40;
	dof_see_knife[ "farEnd"	   ] = 70;
	dof_see_knife[ "farBlur"   ] = 4;
}

#using_animtree( "script_model" );
enemy_plane_behind()
{
	flag_wait( "raise_enemy_plane" );
	
	thread core_lights_red();
	
	wait 2;
	
	thread friends_reaction_to_enemy_plane();
	thread knock_player_with_raise();
	
	thread friends_ignoreall_toggle();
	
	
	plane = Spawn( "script_model", ( 15589, 4711, -2171 ) ); // 12576, 4608, -2536 // far 10774, 4094, -1792
	plane SetModel ( "vehicle_Y_8" );
	plane.animname = "enemy_plane";
	plane SetAnimTree();
	
	fake_gun_fire_ai = GetEnt( "fake_gun_fire", "targetname" );

	ai_enemy_plane = fake_gun_fire_ai spawn_ai( true, true );
	ai_enemy_plane Teleport( plane.origin );
	waitframe();
	ai_enemy_plane LinkTo ( plane, "tag_body", ( 0, 0, -100 ), ( 0, 0, 0 ) ); //.origin + ( 0, 0, -2000 )
	
	level.plane_core anim_single_solo( plane, "y8_reveal" ); // rotation is off by 90 degrees
	
	thread spawn_wing_guys();
	thread wing_break_off();
	
	/*
	plane moveto( ( plane.origin - ( 30, 50,  150) ), 2.7, 1.2, 1.5 );
	plane waittill( "movedone" );
	plane thread plane_rotate();	
	
	plane moveto( ( plane_goal_one.origin ), 5, 2.5, 2.5 );
	
	plane waittill( "movedone" );
	
	plane moveto( plane_goal_one.origin + ( 0, 3000, 5000), 10, 5, 5 ); //  5000
	*/
	
	level waittill( "start_second_enemy_plane" );
	
  //  level.mccoy.ignoreall	 = 1;
  //  level.kersey.ignoreall = 1;
  //  level.price.ignoreall	 = 1;
	
	plane_start_two_origin = Spawn ( "script_origin", ( 13588, 4726, 3528 ) ); // close 13088, 4400, -2584
	
	plane_batman_fly_origin = Spawn( "script_origin", ( 17634, 5292, 3428 ) ); // close 13312, 5376, 3284 // 16962, 5132, 3228 
	
	plane.origin = plane_start_two_origin.origin;
	waitframe();
	plane Show();
	
//	plane rotateto( ( -90, 0, 0 ), 0.1 );
	plane MoveTo( plane_batman_fly_origin.origin, 13, 5, 5 );
	plane waittill( "movedone" );
	plane Hide();
}

friends_ignoreall_toggle()
{
	wait 2.5;
	level.mccoy.ignoreall = 0;
	level.mccoy.accuracy  = 0;
	
	level.kersey.ignoreall = 0;
	level.kersey.accuracy  = 0;
	
	level.price.ignoreall = 0;
	level.price.accuracy  = 0;
}

friends_reaction_to_enemy_plane()
{
	level.mccoy_anim_org anim_stopanimscripted();
	level.kersey_anim_org anim_stopanimscripted();
		
	wait 1;
	
	level.price forceUseWeapon( "p99", "secondary" );
	level.mccoy forceUseWeapon( "p99", "secondary" );
	level.kersey forceUseWeapon( "p99", "secondary" );
	
//	level.price AllowedStances( "crouch" );
	
//	wait 0.3;
	
//	level.mccoy AllowedStances( "crouch" );
//	level.kersey AllowedStances( "crouch" );
}

knock_player_with_raise()
{
	wait 0.5;
	
	thread violent_plane_shake();
	Earthquake( 0.34, 1, level.player.origin, 10000 );
	wait 0.5;
//	level.player ShellShock( "hijack_airplane", 3.5 );
	wait 0.5;
	Earthquake( 0.17, 16, level.player.origin, 10000 );
	wait 0.3;
//	SetTimeScale( 0.7 );
	wait 0.7;
//	level.player ShellShock( "iplane_slowview", 5 );
	
	
//	wait 3.5;
//	SetTimeScale( 1 );
	
	// now rotate the plane from left to the right.
}

violent_plane_shake()
{
}

plane_rotate()
{
	for ( ;; )
	{
		//wait( RandomFloatRange( 1, 3.3) );
		angle_new = RandomFloatRange( 2, 7 );
		
		self RotateTo( self.angles + ( 0, 0, angle_new ), 3.7, 2, 1.7 );
		self waittill ( "rotatedone" );
		
		self RotateTo( self.angles - ( 0, 0, angle_new ), 3.7, 2, 1.7 );
		self waittill( "rotatedone" );
	}
}

stop_looped_sound( time )
{
	wait( time );
	self StopLoopSound();
}

sound_test()
{	
	level.sound_org = Spawn( "script_origin", level.player.origin );
	level.sound_org PlayLoopSound( "hijk_jet_air_rl" );
	
	level.sound_org_three = Spawn( "script_origin", level.player.origin );
	
	level.sound_org_four = Spawn( "script_origin", level.player.origin );
	
	wait 5.4;
	
	level.sound_org_radio_com = Spawn( "script_origin", level.player.origin );
	level.sound_org_radio_com PlayLoopSound( "hijk_radio_com_intro" );
	
	//flag_wait( "open_bay_doors" );
	flag_wait( "player_activated_ramps_open" );
	
	level.bay_door_lower PlayLoopSound ( "emt_mach_distant_mechanical1" );
	level.bay_door_upper PlayLoopSound ( "emt_mach_noise_close" );
	
	wait 8;
	
	level.bay_door_lower StopLoopSound();
	level.bay_door_upper StopLoopSound();

	flag_wait( "start_explosion_breach" );	
	wait 3.5;
	level.sound_org_three PlaySound( "hijk_failing_quad" );
	//level.sound_org_three playsound( "hijk_tilt_stress_01" );
	wait 2;
	level.sound_org_four PlaySound( "hijk_tilt_stress_01" );
	wait 9;	
	level.sound_org_three PlaySound( "hijk_tilt_stress_02" );	
	
	
	
	flag_wait( "player_is_now_connected_to_the_plane" );
	wait 1;

	level.sound_org StopLoopSound();
	level.sound_org_radio_com StopLoopSound();
	
	level.sound_org Delete();
	level.sound_org_radio_com Delete();
	
	
	level.sound_org_five = Spawn( "script_origin", level.player.origin );
	level.sound_org_five PlayLoopSound( "hijk_window_whistle" ); // climbing out sound
	level.sound_org_five LinkTo( level.player );
	

	level waittill ( "start_parachute_out" );
	
	level.sound_org_three Delete();
	level.sound_org_four Delete();
	
	//level waittill(  );
}

fx_climb_out_test()
{	
	level endon ( "start_parachute_out" );
	
//	wait 2.1;
	
	f_tag = Spawn( "script_model", level.player GetEye() );
	f_tag SetModel( "tag_origin" );
	f_tag LinkTo( level.player_anim_origin );
	
	player_on_back_one = GetEnt( "r_plane_player_climb_one", "targetname" );
	test_fx_ent		   = Spawn( "script_model", player_on_back_one.origin );
	test_fx_ent SetModel( "tag_origin" );
	
//	PlayFX( getfx( "escape_dust_hijack0" ), player_on_back_one.origin, AnglesToForward( player_on_back_one.angles )  );		
//	PlayFX( getfx( "escape_dust_hijack0" ), level.player.origin, AnglesToForward( level.player.angles ) );
	
	PlayFXOnTag( getfx( "escape_dust_hijack1" ), level.player_anim_origin, "tag_origin" );
	PlayFXOnTag( getfx( "dirt_two" ), level.player_anim_origin, "tag_origin" );

	//wait 10;
	
	//stopFXontag( getfx( "escape_dust_hijack0" ), f_tag, "tag_origin" );
	//stopFXontag( getfx( "dirt_two" ), f_tag, "tag_origin" );
	
// this is what I was using!	
//	PlayFX( getfx( "dirt_two" ), player_on_back_one.origin, AnglesToForward( player_on_back_one.angles ) );
//	PlayFXontag( getfx( "dirt_two" ), level.player GetEye(), AnglesToForward( level.player.angles + ( -90, 0, 0) ) );	
	
	
//	PlayFX( getfx( "metal" ), player_on_back_one.origin, AnglesToForward( player_on_back_one.angles ) );
	
//	PlayFXOnTag( getfx( "escape_dust_hijack0" ),test_fx_ent, "tag_origin" );
	
	

	
//	PlayFX( getfx( "metal" ), level.player Geteye(), ( 90, 0, 0 ), ( 1, 0, 0 ) );
//	PlayFX( getfx( "escape_dust_hijack0" ), level.player Geteye(),  ( 0, 0, 1 ), ( 1, 0, 0 ) );
//	PlayFX( getfx( "metal" ), level.player GetEye(), ( 90, 0, 0 ), ( 1, 0, 0 ) );
	
	level.sound_org_three.origin = level.player.origin + ( 30, -50, 50 );
	level.sound_org_four.origin	 = level.player.origin + ( 0, 50, -50 );
	
	level.sound_org_three LinkTo( level.player );
	level.sound_org_four LinkTo ( level.player );
	
	num = 0;
	while ( 1 )
	{
		wait 6;
		switch( num )
		{
			case 0:
			level.sound_org_three PlaySound( "hijk_tilt_stress_01" );
			break;
			
			case 1:
			level.sound_org_four PlaySound( "hijk_tilt_stress_02" );
			break;
		}
	}
}

primary_light_control()
{
  //  middle_red_light = GetEnt( "middle_primary_light", "targetname" );
  //  rear_red_light   = GetEnt( "rear_primary_light", "targetname" );
	//	
	//	middle_red_light SetLightIntensity( 0 );
	// add flicker
}

#using_animtree( "animated_props" );
do_tarps()
{
	tarps = GetEntArray( "tarps0", "targetname" );
	
	flag_wait( "player_activated_ramps_open" );
	
	
	wait 2.3;
	
	foreach ( tarp in tarps )
	{
		tarp.animname = "taprs0_rock";
		tarp LinkTo ( level.plane_tail );
		tarp SetAnimTree();
		tarp thread anim_loop_solo( tarp, "taprs0_anim" );
	}
	
	tarps1 = GetEntArray( "tarps1", "targetname" );
	
//	foreach( tarp in tarps1 )
//	{
//		tarp.animname = "taprs1_rock";
//		tarp linkto ( level.plane_tail );
//		tarp setanimtree();
//		tarp thread anim_loop_solo( tarp, "taprs1_anim" );
//	}
	
  //  level.scr_animtree[ "taprs0" ]		 = #animtree;
  //  level.scr_model	[ "taprs0" ]		 = "mp_cement_tarp4";
  //  level.scr_anim[ "taprs0" ][ "taprs0" ] = %mp_cement_tarp4_anim_a;

}