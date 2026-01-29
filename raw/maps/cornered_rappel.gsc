#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\cornered_code_rappel;
#include maps\cornered_code_rappel_allies;
#include maps\cornered_binoculars;
#include maps\cornered_lighting;
#include maps\player_scripted_anim_util;
//#include maps\_hud_util;

cornered_rappel_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//Rappel movement flags - player
	flag_init( "c_rappel_player_on_rope" );
	flag_init( "c_rappel_jumpdown_allowed" );
	flag_init( "c_rappel_first_jump_done" );
	flag_init( "c_rappel_second_jump_starting" );
	flag_init( "c_rappel_second_jump_done" );
	flag_init( "c_rappel_final_jump_starting" );
	flag_init( "floor_clear" );
	flag_init( "force_jump" );
	flag_init( "player_jumping" );
	flag_init( "c_rappel_player_pressed_jump" );
	flag_init( "stop_manage_player_rappel_movement" );

	//Rappel
	flag_init( "here_they_come" );
	flag_init( "all_rappel_one_enemies_in_front_dead" );
	flag_init( "all_rappel_two_enemies_in_front_dead" );
	flag_init( "start_glass_fx" );
	flag_init( "stop_watch_player_pitch" );
	flag_init( "baker_start_jump" );
	flag_init( "part_one_start" );
	flag_init( "part_one_complete" );
	flag_init( "part_two_complete" );
	flag_init( "p2_second_wave_downstairs_ready_to_spawn" );
	flag_init( "player_has_looked_up" );
	flag_init( "nag_reset" );
	flag_init( "move_into_building" );
	flag_init( "player_has_looked_up_for_count" );
	flag_init( "move_on_from_part_one" );
	
	//Copymachine Event
	//flag_init( "start_copymachine_window_event" );
	//flag_init( "copymachine_window_ai_spawned" );
	flag_init( "stop_dmg_check" );
	flag_init( "copymachine_go" );
	flag_init( "copymachine_anim_done" );
	flag_init( "copymachine_ai_done" );
	
	//Grenade toss event
	flag_init( "grenade_thrown" );
	flag_init( "kill_grenade_anim" );
	flag_init( "grenade_roll_explode" );
	flag_init( "player_is_away_from_grenade" );
	flag_init( "throw_grenade" );
	flag_init( "grenade_thrower_dead" );
	
	//End of Rappel
	flag_init( "rappel_finished" );
	
	//"Press and hold [{+gostand}] to rappel down"
	PreCacheString( &"CORNERED_RAPPEL_DOWN" );
	
	PreCacheModel( "cnd_rappel_railing_obj" );
	PreCacheModel( "cnd_bucket_01" );
	PreCacheModel( "projectile_m67fraggrenade" );
	PreCacheModel( "cnd_garden_glass_entry_ally" );
	PreCacheModel( "cnd_garden_glass_entry_baker" );
	PreCacheModel( "cnd_garden_glass_entry_player" );
	//"Press and hold [{+gostand}] to rappel down"
	add_hint_string( "rappel_down", &"CORNERED_RAPPEL_DOWN", ::player_combat_rappel_is_jumping );
		
	level.copymachine = GetEnt( "photocopier", "script_noteworthy" );
	
	level.grenade_roll_grenade = GetEnt( "grenade_roll_grenade", "targetname" );
	level.grenade_roll_grenade Hide();
	
	level.cnd_rappel_railing_obj = GetEnt( "cnd_rappel_railing_obj", "targetname" );
	level.cnd_rappel_railing_obj Hide();
}

setup_rappel()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	setup_player();
	spawn_allies();
	thread handle_intro_fx();
	
	level.combat_rappel_startpoint = true;
	
	//level.player give_binoculars();
	//level.player binoculars_enable_zoom( false );

	//level.player SwitchToWeapon( "mp5_silencer_eotech" );
	level.player SwitchToWeapon( "kriss+eotechsmg_sp+silencer_sp" );
	
	thread maps\cornered_audio::aud_check( "rappel" );
	
	delete_building_glow();
	
	// falling death anim if player jumps out window
	death_vol = GetEnt( "combat_rappel_fall_volume", "targetname" );
	death_vol thread cornered_falling_death();
	thread fireworks_junction_post();
	
	level.combat_rappel_rope_coil_rorke Show();

	level.combat_rappel_rope_coil_player Show();

	level.combat_rappel_rope_coil_baker Show();

	thread maps\cornered_fx::fx_screen_raindrops();
}

begin_rappel()
{
	//--use this to run your functions for an area or event.--
	thread handle_rappel();
	thread setup_garden_entry();
	flag_wait( "rappel_finished" );	
	thread autosave_now();
}

handle_rappel()
{
	thread battlechatter_on( "allies" );
	thread battlechatter_on( "axis" );
	
	thread rappel_section();
	
	flag_wait( "rappel_finished" );	
}

rappel_section()
{
	thread player_combat_rappel_begin();
	level.allies[ level.const_rorke ] thread allies_to_rappel();
	level.allies[ level.const_baker ] thread allies_to_rappel();
	thread allies_rappel_vo();
	thread combat_rappel_enemies_pt1();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// PLAYER RAPPEL
/////////////////////////////////////////////////////////////////////////////////////////////////

player_combat_rappel_begin()
{
	level.player endon( "death" );

	level.player_start_rappel_struct = getstruct( "player_start_rappel_struct", "targetname" );
	level.player_start_rappel_struct thread anim_first_frame( level.arms_and_legs, "rappel_combat_start" );
	
	// falling death anim if player jumps out window
	//death_vol = getEnt( "combat_rappel_fall_volume", "targetname" );
	//death_vol thread cornered_falling_death();
	
	// ---- Set some variables since we don't know how they were set in the previous rappel.
	//flag_set( "player_can_rappel" );
	level.rappel_max_lateral_dist_right = 300;
	level.rappel_max_lateral_dist_left	= 300;
	level.rappel_max_downward_speed		= 4.0;
	level.rappel_max_upward_speed		= 3.0;
	level.rappel_max_lateral_speed		= 9.0;
	
	// ---- Make rope usable and wait till used.
	//level.cnd_rappel_railing_obj Show();
	//level.cnd_rappel_railing_obj glow();
	level.combat_rappel_rope_coil_player glow();
	
	use_trigger = GetEnt( "player_rappel_trigger", "targetname" );
	use_trigger SetHintString( "Press^3 &&1 ^7to rappel." );
	rope_struct = getstruct( "player_start_rappel_struct", "targetname" );
	//waittill_trigger_activate_looking_at( use_trigger, rope_struct, Cos( 40 ), false );
	waittill_trigger_activate_looking_at( use_trigger, level.combat_rappel_rope_coil_player, Cos( 40 ), false, true );
	flag_set( "c_rappel_player_on_rope" );

	if ( IsDefined( level.player.has_binoculars ) && level.player.has_binoculars == true )
	{
		level.player take_binoculars();
	}
	
	level.combat_rappel_rope_coil_player stopGlow();
	
	//level.cnd_rappel_railing_obj stopGlow();
	level.cnd_rappel_railing_obj Delete();
	
	level.player FreezeControls( true );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player DisableWeapons();
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
		wait 0.8;
	}
	
	//level.player SwitchToWeapon( "mp5_silencer_eotech" );
	level.player SwitchToWeapon( "kriss+eotechsmg_sp+silencer_sp" );
	
	level.player_exit_to_combat_rappel_rope		= spawn_anim_model( "cnd_rappel_tele_rope" );
	level.player_exit_to_combat_rappel_rope Hide();
	level.player_start_rappel_struct thread anim_first_frame_solo( level.player_exit_to_combat_rappel_rope, "rappel_combat_start" );
	
	rope_prop					 = spawn_anim_model( "combat_exit_rope" );
	level.cnd_rappel_player_rope = spawn_anim_model( "cnd_rappel_player_rope" );
	level.cnd_rappel_player_rope Hide();
	level.cnd_rappel_player_rope LinkTo( rope_prop, "j_prop_1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	cnd_plyr_rope_set_idle();
	
	// ---- Animate player onto rope.
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", .6 );
	//wait( 0.6 );
	thread maps\cornered_audio::aud_rappel_combat( "event" );
	thread maps\cornered_audio::aud_junction( "hookup" );
													 //   guys 									   anime 				 
	level.player_start_rappel_struct thread anim_single( level.arms_and_legs					, "rappel_combat_start" );
	level.player_start_rappel_struct thread anim_single_solo( level.player_exit_to_combat_rappel_rope, "rappel_combat_start" );
	level.player_start_rappel_struct thread anim_first_frame_solo( rope_prop, "rappel_combat_start" );
	
	death_vol = GetEnt( "combat_rappel_fall_volume", "targetname" );
	death_vol Delete();
	
	wait( 0.6 );
	
	show_player_arms();
	level.cornered_player_legs Show();
	level.player FreezeControls( false );
	level.player EnableInvulnerability();
	
	wait( 0.2 );
	level.player_exit_to_combat_rappel_rope Show();
	
	//level.player PlayerLinkToDelta( level.arms, "tag_player", 0, 15, 15, 25, 0 );
	
	//wait( 3.1 );
	//level.player LerpViewAngleClamp( 0.75, 0.5, 0, 35, 15, 35, 5 );

	//level.player LerpViewAngleClamp( 0.75, 0.5, 0, 0, 0, 0, 0 );
	
	
	level.cornered_player_arms thread player_exit_to_combat_rappel_notetrack_handler( rope_prop );
	
	wait( 1.5 );
	flag_set( "fx_screen_raindrops" );
	do_specular_sun_lerp( true );
	flag_set( "here_they_come" );
	
	level.combat_rappel_rope_coil_rorke Delete();
	level.combat_rappel_rope_coil_player Delete();
	level.combat_rappel_rope_coil_baker Delete();
	
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	
	rope_prop Delete();
	
	music_play("mus_cornered_explosion");
	flag_set( "c_rappel_first_jump_done" );
}

player_exit_to_combat_rappel_notetrack_handler( rope_prop )
{
	start_prop = false;
	while ( 1 )
	{
		self waittill( "single anim", notetrack );
		switch( notetrack )
		{
			case "start_prop_rope":
				if ( !start_prop )
				{
					level.cnd_rappel_player_rope Show();
					level.player_start_rappel_struct thread anim_single_solo( rope_prop, "rappel_combat_start" );
					start_prop = true;
				}
				break;
			case "delete_player_rope":
				level.player_exit_to_combat_rappel_rope Delete();
				break;
			case "camera_look":
				break;
			case "glass_hit_1":
				level.player PlayRumbleOnEntity( "light_1s" );
				break;
			case "baker_start":
				flag_set( "baker_start_jump" );
				break;
			case "glass_hit_2":
				level.player PlayRumbleOnEntity( "light_1s" );
				break;
			case "gun_up":
				level.player EnableWeapons();
				level.player thread player_flap_sleeves();
				break;
			case "camera_free":	
				thread player_combat_rappel();
				level.player DisableInvulnerability();
				hide_player_arms();
				level.cornered_player_legs Hide();
				flag_set( "part_one_start" );
				break;
		}
		wait( 0.05 );
	}
	
}

//waittill_notetrack_set_flag( notetrack_string, flag_to_set )
//{
//	self waittillmatch( "single anim", notetrack_string );
//	if ( IsDefined( flag_to_set ) )
//	{
//		flag_set( flag_to_set );
//	}
//	if ( notetrack_string == "gun_up" )
//	{
//		level.player EnableWeapons();
//	}
//	if ( notetrack_string == "delete_player_rope" )
//	{
//		level.player_exit_to_combat_rappel_rope Delete();
//	}
//}

#using_animtree( "animated_props" );
player_combat_rappel()
{
	if ( flag( "c_rappel_player_pressed_jump" ) )
	{
		flag_clear( "c_rappel_player_pressed_jump" );
	}
	if ( flag( "c_rappel_jumpdown_allowed" ) )
	{
		flag_clear( "c_rappel_jumpdown_allowed" );
	}
	
	flag_clear( "player_allow_rappel_down" );
	level.player thread unlimited_ammo();

	// ---- PART 1 - "UP" Combat
	rappel_params						  = SpawnStruct();
	rappel_params.right_arc				  = 120; //how far you can look
	rappel_params.left_arc				  = 120;
	rappel_params.top_arc				  = 60;
	rappel_params.bottom_arc			  = 50;
	rappel_params.allow_walk_up			  = true;
	rappel_params.allow_glass_break_slide = true;
	rappel_params.allow_sprint			  = true;
	rappel_params.jump_type				  = "jump_normal";
	rappel_params.show_legs				  = true;
	rappel_params.lateral_plane			  = 2;	 // YZ plane
	rappel_params.rappel_type			  = "combat";
	level.rappel_params					  = rappel_params;
	cornered_start_rappel( "rope_ref_combat", "player_rappel_ground_ref_combat", rappel_params );
	
	thread handle_rope_hitting_enemies();
	
//	foreach ( ally in level.allies )
//		ally ally_rappel_start_rope( rappel_params.rappel_type );
	
	
	flag_set( "player_allow_rappel_down" ); // allow vertical movement
	rappel_limit_vertical_move( 0, 100 );	
		
	// ---- PART 2 - Combat in front, still first floor, need to implement
	
	// ---- Transition PART 2 to PART 3
	flag_wait( "c_rappel_jumpdown_allowed" ); //allowed to jump to next floor
	flag_set( "disable_rappel_jump"	 ); // disallow normal rappel jumping for the moment

	level.player thread display_hint( "rappel_down" );	
	level thread player_wait_for_jump_button();	
	
 	flag_wait( "c_rappel_player_pressed_jump" );
	//thread maps\cornered_audio::aud_rappel_jump_down();
	player_combat_rappel_second_jump( rappel_params ); // animation of jumping down to 2-story
		
	// ---- PART 3 - 2-story combat
	flag_clear( "c_rappel_jumpdown_allowed" );
	flag_clear( "disable_rappel_jump" ); // allow normal rappel jumping again
	rappel_limit_vertical_move( 0, 100 );
	level.rappel_max_lateral_dist_right = 500;
	level.rappel_max_lateral_dist_left	= 500;

	// ---- Transition PART 3 to PART 4
	flag_wait( "c_rappel_jumpdown_allowed" ); //allowed to jump to next floor	
	flag_set( "disable_rappel_jump"	 ); // disallow normal rappel jumping for the moment
	flag_clear( "c_rappel_player_pressed_jump" );
	
	level.player thread display_hint( "rappel_down" );	
	level thread player_wait_for_jump_button();
	
	thread combat_rappel_spawn_garden_entry_enemies();
	
	flag_wait( "c_rappel_player_pressed_jump" );
	flag_set( "c_rappel_final_jump_starting" );
	delayThread( 0.7, maps\cornered_audio::aud_start_garden_events );
	
	//Start ambient FX in garden
	exploder( 1200 );

	// ---- PART 4 - Garden Entry
	combat_rappel_garden_entry();

	flag_clear( "disable_rappel_jump" ); // allow normal rappel jumping again
}

handle_rope_hitting_enemies()
{
	level endon( "c_rappel_final_jump_starting" );
	
	while ( !IsDefined( level.cnd_rappel_player_rope ) )
		waitframe();
		
	while ( true )
	{
		start  = level.cnd_rappel_player_rope GetTagOrigin( "joint9" );
		top	   = level.cnd_rappel_player_rope GetTagOrigin( "joint1" );
		vector = VectorNormalize( top - start );
		end	   = start + ( vector * 400 );
		trace  = BulletTrace( start, end, true, level.player, false, true );
		ent	   = trace[ "entity" ];
		is_ally = IsDefined( ent ) && IsDefined( ent.animname ) && ( ent.animname == "rorke" || ent.animname == "baker" );
		if ( IsDefined( ent ) && IsAI( ent ) && IsAlive( ent ) && !is_ally )
			ent Kill();
			
//		Line( start, end, ( 0, 1, 0 ), 1, 1, 2 );
			
		wait 0.1;
	}
}

player_wait_for_jump_button()
{	
	while ( true )
	{
		wait( 0.05 );		
		if ( level.player JumpButtonPressed() )
		{
			buttonTime = 0;
			while ( level.player JumpButtonPressed() )
			{
				if ( buttonTime >= 0.25 )
					break;
				buttonTime += 0.05;
				wait( 0.05 );
			}
			
			if ( buttonTime < 0.25 )
				continue;
			if ( !flag( "player_jumping" ) )
			{
				flag_set( "c_rappel_player_pressed_jump" );
			}
		}
	}
}

player_combat_rappel_is_jumping()
{
	Assert( IsPlayer( self ) );

	return flag( "c_rappel_player_pressed_jump" );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// ENTRY INTO GARDEN
/////////////////////////////////////////////////////////////////////////////////////////////////

#using_animtree( "animated_props" );
player_combat_rappel_second_jump( rappel_params )
{
	flag_set( "c_rappel_second_jump_starting" ); // this is the jump to the 2-story combat
	
	jump_pos		= SpawnStruct();
	jump_pos.angles = ( 0, -35, 0 );
	jump_pos.origin = ( -24953, 6284, 21677 );
	
	flag_clear( "disable_rappel_jump" );
	level.rappel_lower_limit = undefined;
	player_rappel_force_jump_away( jump_pos );
	waitframe();
	flag_set( "disable_rappel_jump"	 );
	level waittill( "player_force_jump_landed" );

//	thread player_rappel_jump_down( rappel_params );
//
//	RAPPEL_ANIM = %rappel_second_jump_down_player;
//	
//	jump_down_anim_length = GetAnimLength( RAPPEL_ANIM );
//	thread rappel_rope_extend_rope_on_jump_down_anim( level.rpl, rappel_params, jump_down_anim_length );
//	waitframe();
//	waitframe();
//	
//	animate_point = cornered_get_player_jump_anim_origin();
//
//	animate_point SetAnim( RAPPEL_ANIM, 1, 0, 1 );
//	animate_point SetAnimTime( RAPPEL_ANIM, 0 );
//	
//	wait ( jump_down_anim_length );
	
	flag_set( "c_rappel_second_jump_done" );	
}

combat_rappel_garden_entry_should_shift_allies( jump_info )
{
	return ( jump_info.anim_ref != "C" && jump_info.anim_ref != "L1" && jump_info.anim_ref != "R1" );
}

combat_rappel_garden_entry_allies( jump_info )
{
	anim_ref = "rappel_combat_end";
	if ( combat_rappel_garden_entry_should_shift_allies( jump_info ) )
		anim_ref = "rappel_combat_end_shift";
	
	foreach ( ally in level.allies )
	{
		ally ally_rappel_stop_aiming();
		ally Unlink();
		
		ally notify( "stop_loop" );
		level.player_start_rappel_struct thread anim_single_solo( ally, anim_ref );	
	}
}

combat_rappel_garden_entry_ropes( jump_info )
{
	anim_ref = "cornered_combat_rappel_garden_entry_rope_";
	if ( combat_rappel_garden_entry_should_shift_allies( jump_info ) )
		anim_ref = "cornered_combat_rappel_garden_entry_shift_rope_";

	foreach ( ally in level.allies )
	{
		if ( !IsDefined( ally.cnd_rappel_tele_rope ) )
			ally.cnd_rappel_tele_rope = spawn_anim_model( "rope" );

		rappel_anim = anim_ref + ally.animname;
			
		ally.cnd_rappel_tele_rope.animname = "rope";
		
		level.player_start_rappel_struct thread anim_single_solo( ally.cnd_rappel_tele_rope, rappel_anim );
	}
}

combat_rappel_garden_entry_paintcans()
{
	bucketAB_anim_origin = Spawn( "script_model", ( 0, 0, 0 ) );
	bucketAB_anim_origin SetModel( "generic_prop_raven" );
	bucketAB_anim_origin UseAnimTree(#animtree );
	bucketAB_anim_origin.animname = "buckets";

	bucketA = Spawn( "script_model", ( 0, 0, 0 ) );
	bucketA SetModel( "cnd_bucket_01" );
	bucketA LinkTo( bucketAB_anim_origin, "J_prop_1" );

	bucketB = Spawn( "script_model", ( 0, 0, 0 ) );
	bucketB SetModel( "cnd_bucket_01" );
	bucketB LinkTo( bucketAB_anim_origin, "J_prop_2" );
	
	bucketCD_anim_origin = Spawn( "script_model", ( 0, 0, 0 ) );
	bucketCD_anim_origin SetModel( "generic_prop_raven" );
	bucketCD_anim_origin UseAnimTree(#animtree );
	bucketCD_anim_origin.animname = "buckets";

	bucketC = Spawn( "script_model", ( 0, 0, 0 ) );
	bucketC SetModel( "cnd_bucket_01" );
	bucketC LinkTo( bucketCD_anim_origin, "J_prop_1" );
	
	bucketD = Spawn( "script_model", ( 0, 0, 0 ) );
	bucketD SetModel( "cnd_bucket_01" );
	bucketD LinkTo( bucketCD_anim_origin, "J_prop_2" );

														  //   guy 				     anime 											 
	level.player_start_rappel_struct thread anim_single_solo( bucketAB_anim_origin, "cornered_combat_rappel_garden_entry_paintcan1" );
	level.player_start_rappel_struct thread anim_single_solo( bucketCD_anim_origin, "cornered_combat_rappel_garden_entry_paintcan2" );
}

get_tree()
{
	close_spot = getstruct( "garden_baker", "targetname" );
	
	trees = GetEntArray( "garden_entry_tree", "targetname" );
	if ( trees.size == 1 )
		return trees[ 0 ];
	
	closest_tree	= undefined;
	closest_dist_sq = -1;
	
	foreach ( tree in trees )
	{
		dist_sq = DistanceSquared( tree.origin, close_spot.origin );
		if ( closest_dist_sq == -1 || dist_sq < closest_dist_sq )
		{
			closest_dist_sq = dist_sq;
			closest_tree	= tree;
		}
	}
	
	return closest_tree;
}

get_bush()
{
	close_spot = getstruct( "garden_baker", "targetname" );
	
	bushes = GetEntArray( "garden_entry_bush", "targetname" );
	if ( bushes.size == 1 )
		return bushes[ 0 ];

	closest_bush	= undefined;
	closest_dist_sq = -1;
	
	foreach ( bush in bushes )
	{
		dist_sq = DistanceSquared( bush.origin, close_spot.origin );
		if ( closest_dist_sq == -1 || dist_sq < closest_dist_sq )
		{
			closest_dist_sq = dist_sq;
			closest_bush	= bush;
		}
	}
	
	return closest_bush;
}

combat_rappel_garden_entry_tree()
{
	tree = get_tree();
	bush = get_bush();

	tree_anim_origin = Spawn( "script_model", tree.origin );
	tree_anim_origin SetModel( "generic_prop_raven" );
	tree_anim_origin UseAnimTree(#animtree );
	tree_anim_origin.animname = "tree";
	
	bush.origin = tree.origin; // quick way to make sure bush is linked to j_prop_2 with no offset
	tree LinkTo( tree_anim_origin, "j_prop_1" );
	bush LinkTo( tree_anim_origin, "j_prop_2" );
	
	level.player_start_rappel_struct thread anim_single_solo( tree_anim_origin, "cornered_combat_rappel_garden_entry_tree_shake" );
}

combat_rappel_garden_entry_grenades()
{
	grenade_anim_origin = Spawn( "script_model", ( 0, 0, 0 ) );
	grenade_anim_origin SetModel( "generic_prop_raven" );
	grenade_anim_origin UseAnimTree(#animtree );
	grenade_anim_origin.animname = "grenades";

//	grenadeA = Spawn( "script_model", ( 0, 0, 0 ) );
//	grenadeA SetModel( "projectile_m67fraggrenade" );
	grenadeA = level.allies[ 0 ] MagicGrenade( ( 0, 0, 0 ), ( 0, 0, 0 ), 100, false );
	grenadeA LinkTo( grenade_anim_origin, "J_prop_1" );

//	grenadeB = Spawn( "script_model", ( 0, 0, 0 ) );
//	grenadeB SetModel( "projectile_m67fraggrenade" );
	grenadeB = level.allies[ 0 ] MagicGrenade( ( 0, 0, 0 ), ( 0, 0, 0 ), 100, false );
	grenadeB LinkTo( grenade_anim_origin, "J_prop_2" );
	
//	thread draw_entity_bounds( grenadeA, 200, ( 0, 1, 0 ), true );
//	thread draw_entity_bounds( grenadeB, 200, ( 0, 1, 0 ), true );
	
	level.player_start_rappel_struct thread anim_single_solo( grenade_anim_origin, "cornered_combat_rappel_garden_entry_grenades" );
	
	baker = level.allies[ level.const_baker ];
	
	num_grenades_exploded = 0;
	while ( num_grenades_exploded < 2 )
	{
		baker waittill( "single anim", note );

		if ( !IsDefined( note ) )
			continue;
		
		grenade_to_explode = undefined;
		if ( note == "grenade_explode1" )
			grenade_to_explode = grenadeA;
		else if ( note == "grenade_explode2" )
			grenade_to_explode = grenadeB;
			
		if ( !IsDefined( grenade_to_explode ) )
			continue;
			
		num_grenades_exploded++;
		grenade_to_explode Detonate();
	}
}

combat_rappel_spawn_garden_entry_enemies()
{
	num_enemies = 4;
	
	level.garden_entry_enemies = [];
	
	for ( i	= 0; i < num_enemies; i++ )
	{
		if ( i + 1 == 2 ) // remove redshirt 2
			continue;
		
		spawner				 = GetEnt( "garden_entry_enemies", "targetname" );
		spawner.count		 = 1;
		garden_guy			 = spawn_targetname( "garden_entry_enemies", true );
		garden_guy.animname	 = "generic";
		garden_guy.ignoreme	 = true;
		garden_guy.ignoreall = true;
		garden_guy.a.nodeath = true;
		garden_guy.anim_ref	 = "cornered_combat_rappel_garden_entry_redshirt" + ( i + 1 );
		
		level.player_start_rappel_struct thread anim_generic_first_frame( garden_guy, garden_guy.anim_ref );
		
		level.garden_entry_enemies[ level.garden_entry_enemies.size ] = garden_guy;
//		thread draw_entity_bounds( garden_guy, 200, ( 0, 1, 0 ), true );
		waitframe();
	}
}

combat_rappel_garden_entry_enemies()
{
	for ( i	= 0; i < level.garden_entry_enemies.size; i++ )
	{
		garden_guy			= level.garden_entry_enemies[ i ];
		garden_guy.animname = "generic";
		garden_guy.entry	= true;
		
		level.player_start_rappel_struct thread anim_generic( garden_guy, garden_guy.anim_ref );
		
		garden_guy thread combat_rappel_garden_entry_enemy_death();
	}
	
	waittill_dead( level.garden_entry_enemies );
	level.garden_entry_enemies = undefined;
}

combat_rappel_garden_entry_enemy_death()
{
	self endon( "death" );
	
	while ( true )
	{
		self waittill( "single anim", note );

		if ( !IsDefined( note ) )
			continue;
		
		if ( note != "start_ragdoll" && note != "end" )
			continue;
			
		self.a.nodeath = true; // prevent death anim
		
		if ( note == "end" ) // won't happen normally
		{
			self.a.nodeath		   = false;
			self.ragdoll_immediate = true;
		}
		
		self Kill();
		return;
	}
}

combat_rappel_garden_entry_setup_jumpoints()
{
	if ( !IsDefined( level.player_start_rappel_struct ) )
		level.player_start_rappel_struct = getstruct( "player_start_rappel_struct", "targetname" );
	
	node = level.player_start_rappel_struct;

	level.jump_anims	  = [];
	level.jump_anims[ 0 ] = create_jump_point( node, "C" );
	level.jump_anims[ 1 ] = create_jump_point( node, "R1" );
	level.jump_anims[ 2 ] = create_jump_point( node, "R2" );
	level.jump_anims[ 3 ] = create_jump_point( node, "R3" );
	level.jump_anims[ 4 ] = create_jump_point( node, "R4" );
	level.jump_anims[ 5 ] = create_jump_point( node, "L1" );
	level.jump_anims[ 6 ] = create_jump_point( node, "L2" );
	level.jump_anims[ 7 ] = create_jump_point( node, "L3" );
}

create_jump_point( scripted_node, anim_ref )
{
	anim_info			   = SpawnStruct();
	anim_info.anim_ref	   = anim_ref;
	animation			   = level.scr_anim[ "jump_info" ][ anim_ref ];
	anim_info.start_origin = GetStartOrigin( scripted_node.origin, scripted_node.angles, animation );
	anim_info.start_angles = GetStartAngles( scripted_node.origin, scripted_node.angles, animation );
	anim_info.anim_length  = GetAnimLength( animation );

	jump_point		  = spawn_tag_origin();
	jump_point.origin = anim_info.start_origin;
	jump_point.angles = anim_info.start_angles;
	jump_point SetModel( "generic_prop_raven" );
	jump_point UseAnimTree(#animtree );
	jump_point.animname = "jump_info";
	jump_point SetAnim( animation, 1.0, 0, 0 );
	waitframe();
	
	anim_info.start_origin = jump_point GetTagOrigin( "J_prop_1" );
	anim_info.start_angles = jump_point GetTagAngles( "J_prop_1" );
	
	anim_info.rope_origin = jump_point GetTagOrigin( "J_prop_2" );
	anim_info.rope_angles = jump_point GetTagAngles( "J_prop_2" );
	
	return anim_info;
}

get_jump_info()
{
	closest_dist_sq	 = -1;
	chosen_anim_info = undefined;
	
	foreach ( anim_info in level.jump_anims )
	{
		dist_sq = DistanceSquared( level.player.origin, anim_info.start_origin );
		
		if ( dist_sq < closest_dist_sq || closest_dist_sq == -1 )
		{
			closest_dist_sq	 = dist_sq;
			chosen_anim_info = anim_info;
		}
	}
	
	return chosen_anim_info;
}

spawn_jump_point( jump_info )
{
	jump_point		  = spawn_tag_origin();
	jump_point.origin = jump_info.start_origin;
	jump_point.angles = jump_info.start_angles;
	jump_point SetModel( "generic_prop_raven" );
	jump_point UseAnimTree(#animtree );
	jump_point.animname = "jump_info";
	
	return jump_point;
}

combat_rappel_garden_entry_setup_glass()
{
	player_still_glass	= GetEnt( "garden_entry_glass_player_still", "targetname" );
	ally_still_glass	= GetEnt( "garden_entry_glass_ally_still", "targetname" );
	player_still_glass2 = GetEnt( "garden_entry_glass_player_still2", "targetname" );
	
	player_still_glass Hide();
	ally_still_glass Hide();
	player_still_glass2 Hide();
}

combat_rappel_garden_entry_glass()
{
	ally_broken_glass = Spawn( "script_model", ( 0, 0, 0 ) );
	ally_broken_glass SetModel( "cnd_garden_glass_entry_ally" );
	ally_broken_glass UseAnimTree(#animtree );
	ally_broken_glass.animname = "glass";
	ally_broken_glass Hide();
	
	baker_broken_glass = Spawn( "script_model", ( 0, 0, 0 ) );
	baker_broken_glass SetModel( "cnd_garden_glass_entry_baker" );
	baker_broken_glass UseAnimTree(#animtree );
	baker_broken_glass.animname = "glass";
	baker_broken_glass Hide();
	
	player_broken_glass = Spawn( "script_model", ( 0, 0, 0 ) );
	player_broken_glass SetModel( "cnd_garden_glass_entry_player" );
	player_broken_glass UseAnimTree(#animtree );
	player_broken_glass.animname = "glass";
	player_broken_glass Hide();

														  //   guy 				    anime 											   
	level.player_start_rappel_struct thread anim_single_solo( ally_broken_glass	 , "cornered_combat_rappel_garden_entry_ally_glass" );
	level.player_start_rappel_struct thread anim_single_solo( baker_broken_glass , "cornered_combat_rappel_garden_entry_baker_glass" );
	level.player_start_rappel_struct thread anim_single_solo( player_broken_glass, "cornered_combat_rappel_garden_entry_player_glass" );
	
	player_clean_glass	= GetEnt( "garden_entry_glass_player_clean", "targetname" );
	ally_clean_glass	= GetEnt( "garden_entry_glass_ally_clean", "targetname" );
	player_still_glass	= GetEnt( "garden_entry_glass_player_still", "targetname" );
	player_still_glass2 = GetEnt( "garden_entry_glass_player_still2", "targetname" );
	ally_still_glass	= GetEnt( "garden_entry_glass_ally_still", "targetname" );
	
	rorke = level.allies[ level.const_rorke ];
	
	num_windows_shattered = 0;
	while ( num_windows_shattered < 3 )
	{
		rorke waittill( "single anim", note );

		if ( !IsDefined( note ) )
			continue;
		
		if ( note == "show_glass_right" )
		{
			ally_clean_glass Delete();
			ally_still_glass Show();
			ally_broken_glass Show();
			num_windows_shattered++;
			thread maps\cornered_audio::aud_rappel_combat( "window1" );
		}
		else if ( note == "show_glass_left" )
		{
			player_clean_glass Delete();
			player_still_glass Show();
			baker_broken_glass Show();
			num_windows_shattered++;
			thread maps\cornered_audio::aud_rappel_combat( "window2" );
		}
		else if ( note == "show_glass_plyr" )
		{
			player_still_glass Delete();
			player_still_glass2 Show();
			player_broken_glass Show();
			num_windows_shattered++;
			thread maps\cornered_audio::aud_rappel_combat( "window3" );
		}
	}
}

combat_rappel_garden_entry_slowmo()
{
	wait 1.4;
//	level.player thread play_sound_on_entity( "slomo_whoosh" );
//	SetSlowMotion( 1.0, 0.4, 1.0 );
//	level.player SetPerk( "specialty_quickdraw", true, false );
	
	fodder_enemies		= get_living_ai_array( "garden_entry_fodder", "script_noteworthy" );	  // required to kill to end slowmo, given low health
	temp_fodder_enemies = get_living_ai_array( "garden_entry_temp_fodder", "script_noteworthy" ); // given low health, but not required to kill
	foreach ( enemy in fodder_enemies )
		enemy.health = 1;
	foreach ( enemy in temp_fodder_enemies )
		enemy.health = 1;
//	waittill_dead_or_dying( fodder_enemies, fodder_enemies.size, 1.3 );
	
	wait 2.0;
//	SetSlowMotion( 0.4, 1.0, 0.2 );
//	level.player UnSetPerk( "specialty_quickdraw", true );
	
	level.player LerpViewAngleClamp( 0.2, 0, 0, 0, 0, 0, 0 );
	level.player DisableWeapons();
	wait 0.5;
	level.player EnableWeapons();
	level.player LerpViewAngleClamp( 0, 0, 0, 55, 55, 55, 10 );
	
	foreach ( enemy in fodder_enemies )
	{
		if ( IsAlive( enemy ) )
			enemy Kill();
	}
	
	flag_wait( "garden_player_in_garden" );
	
	foreach ( enemy in temp_fodder_enemies )
	{
		if ( IsAlive( enemy ) )
			enemy.health = 150;
	}
}

combat_rappel_garden_entry_first_frame( jump_point, jump_info )
{
	// jump anim (drives the origin)
	level.player_start_rappel_struct anim_first_frame_solo( jump_point, jump_info.anim_ref );
	
	// player arms (drives the angles)
	angles_to_wall					= ( 0, 325, 0 );
	jump_origin						= jump_point GetTagOrigin( "J_prop_1" );
	level.rappel_player_arms		= spawn_anim_model( "player_rappel_arms" );
	level.rappel_player_arms.origin = jump_origin;
	level.rappel_player_arms.angles = angles_to_wall;
	level.rappel_player_arms DontCastShadows();
	level.rappel_player_arms Hide();
	level.rappel_player_arms LinkTo( jump_point, "J_prop_1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	arms_anim = rpl_get_garden_entry_arms_static_anim();
	level.rappel_player_arms SetAnimKnob( arms_anim, 1.0, 0, 0 );
	
	waitframe();
}

combat_rappel_garden_entry_set_small_rotate_jump()
{
	level.rappel_rotate_jump_anim = %rappel_movement_player_small_jump_rotate;
}

#using_animtree( "player" );
combat_rappel_garden_entry()
{
	if ( !IsDefined( level.player_start_rappel_struct ) )
		level.player_start_rappel_struct = getstruct( "player_start_rappel_struct", "targetname" );
	
	thread combat_rappel_garden_entry_setup_weapon();
	level.player EnableInvulnerability();
	
	jump_info  = get_jump_info();
	jump_point = spawn_jump_point( jump_info );
//	thread draw_origins( jump_point );
	combat_rappel_garden_entry_first_frame( jump_point, jump_info );
	combat_rappel_garden_entry_player( jump_point, jump_info );
	
	delayThread( 1.0, ::flag_set, "garden_spawn_first_enemies" );
	delayThread( 1.0, ::flag_set, "rappel_finished" ); //mmajernik added, should probably be fired off when the player smashes through the glass to enter the building
	thread maps\cornered_audio::aud_rappel_combat( "swing" );
	grenade_indicator_offset = GetDvar( "cg_hudGrenadeIconOffset" );
	SetSavedDvar( "cg_hudGrenadeIconOffset", "512" ); // hack to get grenade indictor off of the screen for animation
	
	// Play animations
	thread combat_rappel_garden_entry_enemies();
	thread combat_rappel_garden_entry_allies( jump_info );
	thread combat_rappel_garden_entry_ropes( jump_info );
	thread combat_rappel_garden_entry_paintcans();
	thread combat_rappel_garden_entry_tree();
	thread combat_rappel_garden_entry_grenades();
	thread combat_rappel_garden_entry_glass();
	thread combat_rappel_garden_entry_slowmo();
	level.player_start_rappel_struct anim_single_solo( jump_point, jump_info.anim_ref );	

	thread autosave_now();
	
	level.jump_anims = undefined;
	level.player Unlink();
	level.rappel_player_legs Delete();
	level.rappel_player_arms Delete();
	
	SetSavedDvar( "cg_hudGrenadeIconOffset", grenade_indicator_offset );

	level.player EnableWeapons();
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	level.player AllowMelee( true );
	flag_set( "garden_player_in_garden" );
	
	invulnerable_time = 3.0;
	wait( invulnerable_time );
	level.player DisableInvulnerability();
}

combat_rappel_garden_entry_setup_weapon()
{
	level.player AllowMelee( false );
	
//	// trade out the player's secondary weapon for an m4m203_acog
//	level.player DisableWeapons();
//	wait 0.1;
//	weaponList = level.player GetWeaponsListPrimaries();
//	foreach ( weapon in weaponList )
//	{
//		level.player TakeWeapon( weapon );
//	}
//	level.player GiveWeapon( "m14ebr_acog_silenced_cornered" );
//	level.player GiveWeapon( "ump45_acog" );
//	level.player SwitchToWeapon( "ump45_acog" );
//	wait 0.3;
//	level.player EnableWeapons();	
}

combat_rappel_garden_entry_player( jump_point, jump_info )
{
	jump_origin = jump_point GetTagOrigin( "J_prop_1" );
	jump_angles = jump_point GetTagAngles( "J_prop_1" );
	rope_origin = jump_point GetTagOrigin( "J_prop_2" );
	rope_angles = jump_point GetTagAngles( "J_prop_2" );
	
	if ( !IsDefined( level.rappel_player_legs ) ) // checkpoint
	{
		level.rappel_player_legs		= spawn_anim_model( "player_rappel_legs", jump_origin ); //level.player.origin );
		level.rappel_player_legs.angles = jump_angles;
		level.rappel_player_legs DontCastShadows();
		legs_anim = rpl_get_legs_idle_anim();
		level.rappel_player_legs SetAnim( legs_anim, 1.0, 0, 1.0 );
		level.player PlayerLinkTo( level.rappel_player_legs, "tag_origin", 0, 120, 120, 60, 50, false );
		wait 2;
	}
	
	if ( !IsDefined( level.cnd_rappel_player_rope ) ) // checkpoint
	{
		level.cnd_rappel_player_rope		= spawn_anim_model( "cnd_rappel_player_rope", rope_origin );
		level.cnd_rappel_player_rope.angles = rope_angles;
		cnd_plyr_rope_set_idle();
		waitframe();
	}
	
	if ( !IsDefined( level.start_point ) || level.start_point != "garden" )
		combat_rappel_garden_entry_double_jump( jump_point );
	blend_time = 0.2;
	combat_rappel_garden_entry_blend_to_position( blend_time, jump_point );

	legs_anim = rpl_get_garden_entry_legs_static_anim();
	arms_anim = rpl_get_garden_entry_arms_static_anim();
	
	level.rappel_player_arms SetAnimKnob( arms_anim, 1.0, 0.2, 1.0 );
	level.rappel_player_legs SetAnimKnob( legs_anim, 1.0, 0.2, 1.0 );

	thread combat_rappel_garden_entry_finish_player_rope( jump_info );
}

combat_rappel_garden_entry_double_jump( jump_point )
{
	land_struct		   = SpawnStruct ();
	land_struct.origin = jump_point GetTagOrigin( "j_prop_1" );
	land_struct.angles = jump_point GetTagAngles( "j_prop_1" );
	flag_clear( "disable_rappel_jump" );
	
	rope_origin = jump_point GetTagOrigin( "J_prop_2" );
	rope_angles = jump_point GetTagAngles( "J_prop_2" );
	
	combat_rappel_garden_entry_set_small_rotate_jump();
	combat_rappel_garden_entry_set_small_legs_jump();
	
	percent_of_anim_is_landed = 0.7;
	anim_length				  = GetAnimLength( level.rappel_legs_jump_anim );
	blend_time				  = anim_length * percent_of_anim_is_landed;
	rope_blend_time			  = anim_length * 0.8;

	// connect the player to the legs so they rotate as the legs do and restrict the view
	level.player_torso_offset_origin LinkTo( level.rappel_player_legs, "tag_origin" );
	// stop rotating the rope through the system since we'll lerp it into place
	level.rpl_physical_rope_origin = undefined;
	
	player_rappel_force_jump_away( land_struct );
	thread combat_rappel_garden_entry_rotate_legs( blend_time );
	thread lerp_entity_to_position_accurate( level.cnd_rappel_player_rope, rope_origin, rope_angles, blend_time );
	
	waitframe();
	
	flag_set( "disable_rappel_jump"	 );
	level waittill( "player_force_jump_landed" );
	cornered_stop_rappel();
	level.player player_stop_flap_sleeves();
	level.rappel_legs_jump_anim	  = undefined;
	level.rappel_rotate_jump_anim = undefined;
}

combat_rappel_garden_entry_rotate_legs( blend_time )
{
	num_frames = blend_time / 0.05;
	
	legs_roll			  = level.rappel_player_legs.angles[ 2 ];
	angle_units_per_frame = ( -1 * legs_roll ) / num_frames;
	
	waitframe(); // let the anim start
	
	current_frame = 0;
	
	while ( current_frame < num_frames )
	{
		level.rappel_player_legs Unlink();
		
		new_yaw							= level.rappel_player_legs.angles[ 2 ] + angle_units_per_frame;
		new_angles						= ( level.rappel_player_legs.angles[ 0 ], level.rappel_player_legs.angles[ 1 ], new_yaw );
		level.rappel_player_legs.angles = new_angles;
		
		level.rappel_player_legs LinkTo( level.rpl_plyr_legs_link_ent );
		
		waitframe();
		
		current_frame++;
	}
}

combat_rappel_garden_entry_set_small_legs_jump()
{
	level.rappel_legs_jump_anim = %cnd_rappel_small_jump_playerlegs;
}

combat_rappel_garden_entry_blend_to_position( blend_time, jump_point )
{
	jump_origin = jump_point GetTagOrigin( "J_prop_1" );
	jump_angles = jump_point GetTagAngles( "J_prop_1" );
	rope_origin = jump_point GetTagOrigin( "J_prop_2" );
	rope_angles = jump_point GetTagAngles( "J_prop_2" );

	delayThread( blend_time, ::player_clear_groundref );

										 //   ent 						    origin 	     angles       lerptime   
//	thread lerp_entity_to_position_accurate( level.cnd_rappel_player_rope, rope_origin, rope_angles, blend_time );
	thread lerp_entity_to_position_accurate( level.rappel_player_legs	, jump_origin, jump_angles, blend_time );
	level.player PlayerLinkToBlend( level.rappel_player_arms, "tag_player", blend_time );
	foreach ( ally in level.allies )
		ally ally_rappel_stop_rope();
	wait blend_time;

	level.rappel_player_legs LinkTo( jump_point, "J_prop_1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	level.cnd_rappel_player_rope LinkTo( jump_point, "J_prop_2", ( 0, 0, 0 ), ( 0, 0, 0 ) );
}

combat_rappel_garden_entry_finish_player_rope( jump_info )
{
	anim_length	   = jump_info.anim_length;
	time_to_unlink = 3.8;
	remaining_time = anim_length - time_to_unlink;
	Assert( remaining_time > 0 );
	
	wait time_to_unlink;
	
	level.cnd_rappel_player_rope Unlink();
	
	wait remaining_time;
	
	level.cnd_rappel_player_rope Delete();
}

setup_garden_entry()
{
	combat_rappel_garden_entry_setup_jumpoints();
	combat_rappel_garden_entry_setup_glass();
}

player_clear_groundref()
{
	level.player PlayerSetGroundReferenceEnt( undefined );
	waitframe();
	level.player PlayerLinkToDelta( level.rappel_player_arms, "tag_player", 1, 55, 55, 55, 10, false );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// ALLIES RAPPEL
/////////////////////////////////////////////////////////////////////////////////////////////////

allies_to_rappel()
{
	if ( !IsDefined( self.magic_bullet_shield ) )
    {
    	self magic_bullet_shield();
	}
	
	if ( IsDefined( level.combat_rappel_startpoint ) )
	{	
		level.player_start_rappel_struct thread anim_loop_solo( self, "cornered_junction_c4_idle_" + self.animname, "stop_loop_" + self.animname );
	}
	
	flag_wait( "c_rappel_player_on_rope" );
	self thread allies_rappel_anims();
}

allies_rappel_anims()
{	
	// ---- PART 1 - First "up" combat.  
	if ( self.animname == "rorke" )
	{		
		if ( !IsDefined( level.rorke_and_combat_rappel_rope ) )
		{
		    level.combat_rappel_rope_rorke = spawn_anim_model( "cnd_rappel_tele_rope" );
			level.combat_rappel_rope_rorke.animname = "combat_rappel_exit_rope_rorke";
			
			level.rorke_and_combat_rappel_rope		= [];
			level.rorke_and_combat_rappel_rope[ 0 ] = self;
			level.rorke_and_combat_rappel_rope[ 1 ] = level.combat_rappel_rope_rorke;
			level.player_start_rappel_struct anim_first_frame_solo( level.combat_rappel_rope_rorke, "combat_rappel_building_exit_rorke" );
		}
		
		level.player_start_rappel_struct notify( "stop_loop_rorke" ); //in case they got to the idle above
//		waittillframeend;
		//level.player_start_rappel_struct anim_single_solo( self, "combat_rappel_building_exit_rorke" );
		level.player_start_rappel_struct anim_single( level.rorke_and_combat_rappel_rope, "combat_rappel_building_exit_rorke" );
		level.combat_rappel_rope_rorke Delete();
		self ally_rappel_start_rope( "combat" );
	}
	else
	{
		flag_wait( "baker_start_jump" );
		level.player_start_rappel_struct notify( "stop_loop_baker" ); //in case they got to the idle above
//		waittillframeend;
		self.move_type = "animating"; // so player can't walk through him
		thread die_hard_explosion_fx();
		thread maps\cornered_audio::aud_rappel_combat( "explode" );
		
		rope		= spawn_anim_model( "cnd_rappel_tele_rope" );
		
		rope.animname = "rope";
	
		rope_and_baker		= [];
		rope_and_baker[ 0 ] = self;
		rope_and_baker[ 1 ] = rope;
		
		level.player_start_rappel_struct anim_first_frame( rope_and_baker, "combat_rappel_building_exit_baker" );
		level.player_start_rappel_struct anim_single( rope_and_baker, "combat_rappel_building_exit_baker" );
		rope Delete();
		self ally_rappel_start_rope( "combat" );
	}
	
	
	//flag_wait( "c_rappel_first_jump_done" );
	level.flag_to_check = "all_rappel_one_enemies_in_front_dead";
	
	self thread ally_rappel_start_movement_horizontal( "combat", "one", "c_rappel_second_jump_starting" );

	//flag_wait( "part_one_complete" );
	//level.flag_to_check = "part_two_complete"; 
	
	
	// ---- PART 2 - Combat in front, still first floor, need to implement
	
	//flag_wait( "part_two_complete" );
	
	// ---- Transition PART 2 TO 3 - Waiting for player to jump to two-story combat
	//Commenting this out because it looks weird that they go to idle while there are still enemies shooting at them.
	//A Stevenson on 1/4
	/*
	self notify( "stop_loop" );
	self notify( fire_ender );
	self notify( idle_ender );
	waittillframeend;	
	if( self.animname == "rorke" )
	{
		self thread nag_player_to_jump_down_vo();
	}
   	*/
   	
	// ---- PART 3 - Jump down to two-story combat
	flag_wait( "c_rappel_second_jump_starting" );

	level.flag_to_check = "all_rappel_two_enemies_in_front_dead";
	
	self notify( "stop_loop" );
	waittillframeend;
	ally_rappel_stop_aiming();
	ally_rappel_stop_shooting();
	level.player_start_rappel_struct anim_single_solo( self, "cornered_combat_rappel_jump_down_" + self.animname );
	
	ally_rappel_start_aiming( "combat" );
	ally_rappel_start_shooting();
   	
	self thread ally_rappel_start_movement_horizontal( "combat", "two", "c_rappel_final_jump_starting" );
	
	// ---- PART 4 - Jump down into garden ( handled in cornered_rappel::combat_rappel_garden_entry )
}

die_hard_explosion_fx()
{
	wait( 0.95 );
	exploder( "diehard_explosion" );
	level.player PlayRumbleOnEntity( "heavy_2s" );
	Earthquake( 0.25, 1, level.player.origin, 800 );
  //die_hard_explosion_fx_struct = getstruct( "die_hard_explosion_fx_struct", "targetname" );
  //die_hard_explosion_fx_tag	 = die_hard_explosion_fx_struct spawn_tag_origin();
	//PlayFXOnTag( level._effect["window_explosion_out"], die_hard_explosion_fx_tag, "tag_origin" );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// ALLIES VO
/////////////////////////////////////////////////////////////////////////////////////////////////

allies_rappel_vo()
{
	flag_wait( "here_they_come" );
	
	//Merrick: Here they come!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_heretheycome" );
	
	flag_wait( "c_rappel_first_jump_done" );
	wait( 1.25 );
	//Hesh: Above us!
	thread smart_radio_dialogue_interrupt( "cornered_hsh_aboveus" );
	thread copymachine_falling_vo();
	
	flag_wait( "floor_clear" );
	wait( 1.0 );
	flag_clear( "floor_clear" );
	
	//Merrick: Enemies on the floor below us!
	thread smart_radio_dialogue_interrupt( "cornered_mrk_enemiesonthefloor" );

	flag_set( "c_rappel_jumpdown_allowed" );
	flag_wait( "c_rappel_second_jump_done" );
	wait( 2.0 );
	
	flag_wait( "move_into_building" );
	
	//Hesh: We need to get inside NOW!
	smart_radio_dialogue_interrupt( "cornered_hsh_weneedtoget" );

	flag_set( "c_rappel_jumpdown_allowed" );
}

copymachine_falling_vo()
{
	flag_wait( "copymachine_go" );
	wait( 2 );
	//"Baker: Shit, that was close!"
	//thread smart_radio_dialogue( "cornered_bkr_thatwasclose", 2.0 );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// 1st FLOOR "UP" ENEMIES
/////////////////////////////////////////////////////////////////////////////////////////////////

combat_rappel_enemies_pt1()
{
	// --- floor 0 - junction floor --- // Part 1 guys ( 3 guys )
	// --- floor 1 - pass by floor --- // Part 1 guys ( 3 guys )
	// --- floor 2 - rappel and bounce floor --- // Part 1 guys ( 2 guys )
	// --- floor 3 - land on floor --- // Part 2 guys
	
	// this is so only two guys will do a falling death
	level.balcony_fall_deaths	 = 0;
	level.total_balcony_deaths	 = 0;
	level.last_balcony_death	 = false;
	level.last_balcony_death_idx = 1;
	
	// ---- PART 1 - "UP" combat
	level.enemies_above = [];
	
	flag_wait( "c_rappel_player_on_rope" );
	thread break_enemy_windows(); // sets up windows to break before enemies try to shoot
	thread enemy_drones_junction_hallway();
	thread enemy_drones_pt1_upper();
	thread enemy_drones_pt1_lower();
	
	level.cr_rorke_volume = GetEnt( "cr_rorke_side", "targetname" ); //going to use these to determine what anims AI are allowed
	level.cr_baker_volume = GetEnt( "cr_baker_side", "targetname" );
	
	wait( 5.0 );

	thread enemy_drones_pt1_lower_runners();
	
	flag_wait( "part_one_start" );
	
	wait 1;
	
	level.enemies_above_killed = 0;
								 //   key 						   func 					    
	array_spawn_function_targetname( "enemies_above_lower_floor", ::death_func );
	array_spawn_function_targetname( "enemies_above_lower_floor", ::enemies_pt1_lower_behavior );
	thread randomly_spawn_above_enemies_targetname( "enemies_above_lower_floor" );
	waitframe();
	
								 //   key 						   func 					    
	array_spawn_function_targetname( "enemies_above_upper_floor", ::death_func );
	array_spawn_function_targetname( "enemies_above_upper_floor", ::enemies_pt1_upper_behavior );
	thread randomly_spawn_above_enemies_targetname( "enemies_above_upper_floor" );
	
	waittill_enemies_above_killed( 3, 15 );
	thread copymachine_window_event();
	
	//Stop all ambient FX inside building
	stop_exploder( 12 );
	stop_exploder( 13 );
	stop_exploder( 14 );

	//flag_wait( "copymachine_go" );
	//wait( 0.5 );
								 //   key 						      func 							  
	array_spawn_function_targetname( "enemies_above_junction_floor", ::death_func );
	array_spawn_function_targetname( "enemies_above_junction_floor", ::enemies_pt1_junction_behavior );
	randomly_spawn_above_enemies_targetname( "enemies_above_junction_floor" );
	
//	wait( 1.5 );
	
	level.enemies_above = array_removeDead( level.enemies_above );
	while ( level.enemies_above.size >= 2 )
	{
		level.enemies_above = array_removeDead( level.enemies_above );
		waitframe();
	}
	flag_set( "move_on_from_part_one" );
	flag_set( "part_one_complete" );
	flag_set( "floor_clear" );
	
//	// ---- PART 2 - Combat in front, still first floor, need to implement
//	
//	array_spawn_function_targetname( "enemies_above_ahead_floor", ::enemy_spawner_setup );
//	level.enemies_above_ahead = array_spawn_targetname( "enemies_above_ahead_floor", true );
//	
//	waittill_dead_or_dying( level.enemies_above_ahead, 3, 20 );	
//	array_thread( level.enemies_above_ahead, ::send_to_death_volume );
//	
//	thread player_kills_all_pt2_enemies();
//		
//	flag_set( "part_two_complete" );
//	flag_set( "floor_clear" );
	thread autosave_now();
	
	// ---- PART 3 - 2-story, in next function
	//flag_wait( "c_rappel_second_jump_starting" );
	flag_wait( "c_rappel_player_pressed_jump" );
	//wait( 0.2 );
	thread combat_rappel_enemies_pt2();
}

randomly_spawn_above_enemies_targetname( targetname )
{
	spawners = GetEntArray( targetname, "targetname" );
	AssertEx( spawners.size, "Tried to spawn spawners with targetname " + targetname + " but there are no spawners" );
	spawners = array_randomize( spawners );
	
	foreach ( spawner in spawners )
	{
		if ( level.enemies_above.size > 0 )
		{
			rand_delay = RandomFloatRange( 0.4, 1 );
			wait rand_delay;
		}
		spawner.count = 1;
		
		guy = spawner spawn_ai( true );
		
		level.enemies_above[ level.enemies_above.size ] = guy;
	}
}

enemy_drones_junction_hallway()
{
	junction_runner_drones = GetEntArray( "junction_runner_drones", "targetname" );
	wait( 1.5 );
	array_thread( junction_runner_drones, ::spawn_ai, true );
}

enemy_drones_pt1_upper()
{
	hallway_talker_drone = GetEntArray( "hallway_talker_drone", "targetname" );
	array_spawn_function_targetname( "hallway_talker_drone", ::enemy_drone_anim, undefined, 12.0, true );
	array_thread( hallway_talker_drone, ::spawn_ai, true );
	
	wait( 2.0 );
	hallway_runner_drone = GetEntArray( "hallway_runner_drone", "targetname" );
	array_thread( hallway_runner_drone, ::spawn_ai, true );
}

enemy_drones_pt1_lower()
{
	drones = GetEntArray( "lower_drone", "targetname" );
	array_spawn_function_targetname( "lower_drone", ::enemy_drone_anim, 0, 11.5 );
	array_thread( drones, ::spawn_ai, true );
}

enemy_drones_pt1_lower_runners()
{
	drone_runners = GetEntArray( "lower_drone_runners", "targetname" );
	array_thread( drone_runners, ::spawn_ai, true );
}

enemy_drone_anim( wait_before_anim, wait_before_delete, loop )
{
	if ( IsDefined( wait_before_anim ) && wait_before_anim != 0 )
	{
		wait( wait_before_anim );
	}
	
	if ( IsDefined( loop ) && loop == true )
	{
		self thread anim_generic_loop( self, self.script_animation );
	}
	else
	{
		self thread anim_generic( self, self.script_animation );
	}
	
	if ( IsDefined( wait_before_delete ) && wait_before_delete != 0 )
	{
		wait( wait_before_delete );
	}
	self Delete();
}

enemies_pt1_lower_behavior()
{
	self thread enemy_pt1_setup( "p1_lower_floor_node" );
}

enemies_pt1_upper_behavior()
{
	self thread enemy_pt1_setup( "p1_upper_floor_node" );
}

enemies_pt1_junction_behavior()
{
	self thread enemy_pt1_setup( "p1_junction_floor_node" );
}

enemy_pt1_setup( node_array )
{
	self endon( "death" );
	self endon( "enemy_above_shot" );
	
	self.baseaccuracy = 1;
	self disable_long_death();
	self.animname	= "generic";
	self.allowdeath = true;
	
	goal_nodes		 = GetNodeArray( node_array, "targetname" );
	valid_goal_nodes = eliminate_used_nodes( goal_nodes );
	
	// ---- randomly send AI to one of two nodes closest to them
	closest_nodes = SortByDistance( valid_goal_nodes, self.origin );
	rand		  = RandomInt( 2 );
	if ( rand == 1 )
	{
		closest_node = closest_nodes[ 1 ];
	}
	else
	{
		closest_node = closest_nodes[ 0 ];
	}
	
	// ---- but if the center node right above the player isn't taken, pick that one.
	if ( self.script_noteworthy == "p1_lower" )
	{
		foreach ( node in valid_goal_nodes )
		{
			if ( IsDefined( node.script_noteworthy ) && node.script_noteworthy == "p1_lower_center_node" )
				closest_node = node;
		}
	}
	
	closest_node.chosen = true;

    self ForceTeleport( closest_node.origin, closest_node.angles );
	
    while ( !flag( "move_on_from_part_one" ) )
	{
        self.isAnimating = true;
        self play_random_window_lean_anim( closest_node );
        self.isAnimating = false;
        waitframe();
    }
    
    self send_to_death_volume();
}

play_random_window_lean_anim( goal_node )
{
	self endon( "death" );
	self endon( "enemy_above_shot" );
	
  // anim 1		= look over and fire straight down
  // anim 2		= look over and fire straight down
  // anim 3		= look over and fire to left (player's right) (Rorke)
  // anim 4		= look over and fire to right (player's left) (Baker)
  // anim 5 - 7 = peeks
	
	random_anim_index = RandomIntRange( 1, 8 ); // randomly choose among the anims
	//IPrintLn( self.script_noteworthy + " is " + Distance( self.origin, level.player.origin ) + " from player." );
	
	// make sure guy right near player fires at player
	if ( Distance( self.origin, level.player.origin ) <= 256 )
	{
		random_anim_index = 2;
	}
	// make sure guys to player's right don't fire left at nothing
	if ( self IsTouching( level.cr_rorke_volume ) && random_anim_index == 3 )
	{
		random_anim_index = 4;
	}
	// make sure guys to player's left don't fire right at nothing
	if ( self IsTouching( level.cr_baker_volume ) && random_anim_index == 4 )
	{
		random_anim_index = 3;
	}
		
	goal_node anim_single_solo( self, "enemy_above_" + random_anim_index + "_start" ); //use goal node as struct for intro anim to make sure they always align
	
	self thread anim_loop_solo( self, "enemy_above_" + random_anim_index + "_loop", "stop_loop" );
	if ( random_anim_index == 5 || random_anim_index == 6 || random_anim_index == 7 )
	{
		waittime = RandomFloatRange( 1.0, 2.25 ); //peek anims can idle shorter
	}
	else
	{
		waittime = RandomIntRange( 5, 10 );
	}
	
	wait( waittime );
	self notify( "stop_loop" );
	
	self anim_single_solo( self, "enemy_above_" + random_anim_index + "_end" );
}

eliminate_used_nodes( goal_nodes )
{
	valid_nodes = [];
	
	foreach ( goal_node in goal_nodes )
	{
		if ( !IsDefined( goal_node.chosen ) || !goal_node.chosen )
			valid_nodes[ valid_nodes.size ] = goal_node;
	}
	
	return valid_nodes;
}

//player_kills_all_pt2_enemies()
//{
//	level endon( "c_rappel_second_jump_starting" );
//	
//	level.enemies_above_ahead = array_removeDead( level.enemies_above_ahead );
//	waittill_dead_or_dying( level.enemies_above_ahead );
//	flag_set( "all_rappel_one_enemies_in_front_dead" ); //tells allies to stop combat anims
//	level.flag_to_check = undefined;
//}

/////////////////////////////////////////////////////////////////////////////////////////////////
// 1st FLOOR "AHEAD" ENEMIES
/////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////
// 1st FLOOR EVENTS
/////////////////////////////////////////////////////////////////////////////////////////////////


copymachine_window_event()
{	
	potential_goal_nodes	   = GetNodeArray( "p1_junction_floor_node", "targetname" );
	valid_node				   = getClosest( level.player.origin, potential_goal_nodes );
	level.closest_start_struct = getstruct( valid_node.target, "targetname" );
	waitframe();

								 //   key 		     func 			  
	array_spawn_function_targetname( "copier_dude", ::death_func );
	array_spawn_function_targetname( "copier_dude", ::copymachine_ai );
	waitframe();
	
	copier_enemies		= array_spawn_targetname( "copier_dude", true );
	level.enemies_above = array_combine( copier_enemies, level.enemies_above );
	level.player childthread watch_player_pitch_in_volume( "copymachine_window_event_volume", "copymachine", "stop_watch_player_pitch" );

	flag_wait( "stop_watch_player_pitch" );
	flag_set( "player_has_looked_up" );
	
	//thread maps\cornered_audio::aud_copy_machine( level.copymachine );

	level.copymachine_rig		 = spawn_anim_model ( "copymachine_rig", level.closest_start_struct.origin );
	level.copymachine_rig.angles = level.closest_start_struct.angles;
	waittillframeend;
	level.copymachine LinkTo( level.copymachine_rig, "J_prop_1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	level.copymachine_rig anim_first_frame_solo( level.copymachine_rig, "copymachine_fall" );
	level.copymachine Show();
	level.copymachine_rig thread anim_single_solo( level.copymachine_rig, "copymachine_fall" );
	thread maps\cornered_audio::aud_rappel_combat( "copy", level.copymachine_rig );
	flag_set( "copymachine_go" );

//	thread copymachine_glass_falling_fx();	
	
	copymachine_clip = GetEnt( "copymachine_clip", "targetname" );
	copymachine_clip LinkTo( level.copymachine_rig, "J_prop_1", ( 0, -8, 20 ), ( 0, 0, 0 ) );
	copymachine_clip thread copymachine_hit_detect( "copymachine_anim_done" );

	level.copymachine_rig waittillmatch( "single anim", "end" );
	
	level.copymachine Unlink();
	level.copymachine_rig Delete();
	
	level.copymachine PhysicsLaunchClient();
	flag_set( "copymachine_anim_done" );
	thread copymachine_cleanup();
}

copymachine_hit_detect( endon_flag )
{
	level endon( endon_flag );
	
	flag_clear( "stop_dmg_check" );
	
	dmgamt = level.player.maxhealth * 0.7;
	
	while ( !flag( "stop_dmg_check" ) )
	{
		b_touched_player = self IsTouching( level.player );
		if ( b_touched_player )
		{
			level.player DoDamage( dmgamt, self.origin, self );
			thread maps\cornered_audio::aud_rappel_combat( "hit" );
			flag_set( "stop_dmg_check" );
			return;
		}
		waitframe();
	}
}

copymachine_ai()
{
	self endon( "death" );
	self endon( "enemy_above_shot" );
	
	closest_node_1 = GetNode( level.closest_start_struct.script_noteworthy + "_node_1", "script_noteworthy" );
	self SetGoalNode( closest_node_1 );
	self set_goal_radius( 8 );
	wait( 0.1 );
	
	closest_node_2 = GetNode( closest_node_1.script_linkto, "script_linkname" );
	self SetGoalNode	 ( closest_node_2 );
	//self.goal_node = closest_node_2;
	//self set_goal_radius( 8 );
	//self waittill	   ( "goal" );
	wait( 0.75 );
	
	self ForceTeleport( self.origin, closest_node_2.angles );
	self.animname	= "generic";
	self.allowdeath = true;
	self.ignoreall	= false;

	flag_set( "copymachine_ai_done" );
	while ( !flag( "move_on_from_part_one" ) )
	{
        self.isAnimating = true;
        self play_random_window_lean_anim( closest_node_2 );
        self.isAnimating = false;
    }
}

copymachine_break_glass( copymachine )
{	
	damage_glass_struct			= getstructarray( "p1_upper_glass_damage_struct", "targetname" );
	closest_damage_glass_struct = getClosest( level.closest_start_struct.origin, damage_glass_struct );
	GlassRadiusDamage( closest_damage_glass_struct.origin, 96, 50, 50 );
	
	fx_tag_origin		 = spawn_tag_origin();
	fx_tag_origin.origin = closest_damage_glass_struct.origin; //+ (0,-30,0);
	
	PlayFXOnTag( getfx( "copier_papers_falling" ), fx_tag_origin, "tag_origin" );
	
	wait( 5 );
	fx_tag_origin Delete();
}

//copymachine_glass_falling_fx()
//{
//	level endon( "stop_watch_player_pitch" );
//	
//	level.player thread watch_player_pitch_in_volume( "copymachine_window_event_volume", "fx", "start_glass_fx" );
//	
//	flag_wait( "start_glass_fx" );
  //  damage_glass_struct		  = getstructarray( "p1_junction_glass_damage_struct", "targetname" );
  //  closest_damage_glass_struct = getClosest( level.player.origin, damage_glass_struct );
//	GlassRadiusDamage( closest_damage_glass_struct.origin, 96, 50, 50 );
//	
  //  fx_tag_origin		   = spawn_tag_origin();
  //  fx_tag_origin.origin = level.player.origin + ( 0, 30, 150 );
//	
//	PlayFXOnTag( getfx( "glass_falling_rappel" ), fx_tag_origin, "tag_origin" );
//	
//	wait( 5 );
//	fx_tag_origin Delete();
//}

copymachine_cleanup()
{
	flag_wait( "rappel_finished" );
	if ( IsDefined( level.copymachine ) )
	{
		level.copymachine Delete();
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// 2nd FLOOR ENEMIES
/////////////////////////////////////////////////////////////////////////////////////////////////

combat_rappel_enemies_pt2()
{
	level endon( "rappel_finished" );
	
	// ---- PART 3 - 2-story combat
	array_spawn_function_targetname( "p2_first_wave_downstairs", ::enemy_spawner_setup ); //4 guys
	array_spawn_function_targetname( "p2_first_wave_downstairs", ::enemy_lower_level );
	array_spawn_function_targetname( "p2_first_wave_upstairs", ::enemy_spawner_setup ); //2 guys
	array_spawn_function_targetname( "p2_first_wave_upstairs", ::pt2_upper_enemy_anim );
								 //   key 						   func 			      param1   
	array_spawn_function_targetname( "p2_second_wave_downstairs", ::enemy_spawner_setup );		 //3 guys
	array_spawn_function_targetname( "p2_second_wave_upstairs"	, ::enemy_spawner_setup );		 //1 guy
	
	// --- goal volumes
	level.rappel_combat_two_volume_upstairs	  = GetEnt( "rappel_combat_two_volume_upstairs", "targetname" );
	level.rappel_combat_two_volume_downstairs = GetEnt( "rappel_combat_two_volume_downstairs", "targetname" );
	
	// --- array setup
	level.all_rappel_pt3_enemies			= []; //will monitor this for when to move on
	level.all_rappel_pt3_downstairs_enemies = []; //will monitor this for a grenade thrower
		
	// --- spawn first wave
	p2_first_wave_downstairs				= array_spawn_targetname( "p2_first_wave_downstairs", true );
	level.all_rappel_pt3_downstairs_enemies = p2_first_wave_downstairs;
	
	p2_first_wave_upstairs		 = array_spawn_targetname( "p2_first_wave_upstairs", true );
	level.all_rappel_pt3_enemies = array_combine( p2_first_wave_upstairs, p2_first_wave_downstairs );
	
	thread monitor_deaths_on_dynamic_array( level.all_rappel_pt3_enemies, "move_into_building", 6, 20 ); //checks the dynamic all_rappel_pt3_enemies array for 5 deaths to move on
	
	waittill_dead_or_dying( level.all_rappel_pt3_enemies, 3 );
	
	// --- spawn second wave
	p2_second_wave_downstairs				= array_spawn_targetname( "p2_second_wave_downstairs", true );
	level.all_rappel_pt3_enemies			= array_combine( level.all_rappel_pt3_enemies, p2_second_wave_downstairs );
	level.all_rappel_pt3_downstairs_enemies = array_combine( level.all_rappel_pt3_downstairs_enemies, p2_second_wave_downstairs );
	
	p2_second_wave_upstairs		 = array_spawn_targetname( "p2_second_wave_upstairs", true );
	level.all_rappel_pt3_enemies = array_combine( level.all_rappel_pt3_enemies, p2_second_wave_upstairs );
	
	flag_wait( "move_into_building" ); // this is when the player is allowed to enter the building

	wait( 1.0 );
	thread player_kills_all_pt3_enemies();
	thread kill_pt3_enemies_on_player_jump();	
	
	flag_set( "floor_clear" );
}

enemy_spawner_setup()
{
	self endon( "death" );
	self.baseaccuracy = 0.2;
	self disable_long_death();
}

pt2_upper_enemy_anim()
{
	if ( IsDefined( self.script_animation ) )
	{
		self.allowdeath = true;
		volume			= GetEnt( "rappel_combat_two_volume_upstairs", "targetname" );
		self anim_generic( self, self.script_animation );
		self SetGoalVolumeAuto( volume );
	}
}

enemy_lower_level()
{
	self endon( "death" );
	self endon( "c_rappel_final_jump_starting" );
	
	self.ignoreall = true;
	self waittill( "goal" );
	self.ignoreall = false;
	
//	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "lower_grenade_enemy" )
//	{
//		self thread handle_grenade_roll_ai();
//	}
//	else
//	{	
		self SetGoalVolumeAuto( level.rappel_combat_two_volume_downstairs );
		self waittill( "goal" );
//	}
}

kill_pt3_enemies_on_player_jump()
{
	flag_wait( "rappel_finished" );
	wait( 4.0 );
	
	level.all_rappel_pt3_enemies = array_removeDead( level.all_rappel_pt3_enemies );
	if ( level.all_rappel_pt3_enemies.size > 0 )
	{
		foreach ( dude in level.all_rappel_pt3_enemies )
		{
			if ( IsAlive( dude ) )
			{
				if ( IsDefined( dude.magic_bullet_shield ) && dude.magic_bullet_shield )
				{
					dude stop_magic_bullet_shield();
				}
				dude Kill();
			}
		}
	}
}

player_kills_all_pt3_enemies()
{
	level endon( "c_rappel_final_jump_starting" );
	
	level.all_rappel_pt3_enemies = array_removeDead( level.all_rappel_pt3_enemies );
	waittill_dead_or_dying( level.all_rappel_pt3_enemies );
	flag_set( "all_rappel_two_enemies_in_front_dead" ); //tells allies to stop combat anims
	level.flag_to_check = undefined;
}

monitor_deaths_on_dynamic_array( array, flag_to_set, number, timeout )
{
	self endon( "timeout" );
	
	// tracks count in an array that can be changing over time.  Ex: spawn 5 enemies, wait a while, spawn 3 more and add to array.  You want to move on when 7 have been killed.
	
	AssertEx( IsDefined( array )	, "No array defined for monitor_deaths_on_dynamic_array." );
	AssertEx( IsDefined( flag_to_set ), "No flag defined for monitor_deaths_on_dynamic_array." );
	AssertEx( IsDefined( number )	, "No death count defined for monitor_deaths_on_dynamic_array." );
	if ( !IsDefined( timeout ) )
	{
		timeout = 10;
	}
	
	death_count = 0;
	thread monitor_timeout( timeout, flag_to_set );
	while ( 1 )
	{
		waittill_dead_or_dying( array, 1 );
		death_count++;
		array = array_removeDead( array );
		if ( death_count >= number )
		{
			break;
		}
	}
	
	flag_set( flag_to_set );
}

monitor_timeout( timeoutLength, flag_to_set )
{
	wait( timeoutLength );
	self notify( "timeout" );
	
	if ( !flag( flag_to_set ) )
	{
		flag_set( flag_to_set );
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// 2nd FLOOR EVENTS
/////////////////////////////////////////////////////////////////////////////////////////////////
/*
handle_grenade_roll_ai()
{
	self endon( "death" );
	
	self.animname	= "generic";
	self.allowdeath = true;
	self.ignoreme	= true;
	
	level.grenade_thrower = self;
	
	self thread watch_for_death();
	
	grenade_roll_struct = getstruct( "grenade_roll_struct", "targetname" );
	grenade_roll_struct anim_reach_solo( self, "CornerCrR_alert_idle" );
	grenade_roll_struct thread anim_loop_solo( self, "CornerCrR_alert_idle", "stop_looping_anim" );

	wait( 1 );
	
	level.player childthread watch_player_pitch_in_volume( "grenade_volume", "grenade", "throw_grenade", 3, "c_rappel_final_jump_starting" );
	
	flag_wait( "throw_grenade" );
	grenade_roll_struct notify( "stop_looping_anim" );

	grenade_roll_struct thread anim_single_solo( self, "cornered_rappel_enemy_roll_grenade" );
	
	grenade_roll_struct waittillmatch( "single anim", "end" );
	
	grenade_roll_node		= GetNode( "grenade_roll_node", "targetname" );
	self set_goal_node	( grenade_roll_node );
	self set_goal_radius( 8 );
	self.ignoreme = false;
}

watch_for_death()
{
	self waittill( "death" );
	
	flag_set( "grenade_thrower_dead" );
	
	if ( !flag( "grenade_thrown" ) )
	{
		flag_set( "kill_grenade_anim" );
		MagicGrenade( "fraggrenade", level.grenade_roll_grenade.origin +( 0, 0, 1 ), level.grenade_roll_grenade.origin +( 0, 0, 2 ), 2 );
	}
}

grenade_tossed( grenade )
{
	flag_set( "grenade_thrown" );
	grenade_roll_end_struct = getstruct( "grenade_roll_end", "targetname" );
	//thread watch_player_distance( grenade_roll_end_struct );
	level.grenade_thrower MagicGrenade( level.grenade_thrower GetTagOrigin( "tag_weapon_left" ), grenade_roll_end_struct.origin, 2 );
	wait( 2 );
	//level.grenade_roll_grenade Delete();
	level.player EnableDeathShield( true );
	flag_set( "grenade_roll_explode" );
	distance_between = Distance( level.player.origin, grenade_roll_end_struct.origin );
		
	if ( distance_between <= 250 )
	{
		if ( !flag( "player_jumping" ) )
		{
			thread plyr_rappel_jump_down( level.rappel_params, true );
		}
		wait( 0.5 );
		level.player.health = 80;
	}
	wait( 1 );
	level.player EnableDeathShield( false );
}
*/
/*watch_player_distance( grenade_roll_end_struct )
{
	while ( !flag( "grenade_roll_explode" ) )
	{
		distance_between = Distance( level.player.origin, grenade_roll_end_struct.origin );
		
		if ( distance_between >= 120 )
		{
			if ( !flag( "player_is_away_from_grenade" ) )
			{
				level.player EnableDeathShield( true );
				flag_set( "player_is_away_from_grenade" );
			}
		}
		else
		{
			if ( flag( "player_is_away_from_grenade" ) )
			{
				level.player EnableDeathShield( false );
				flag_clear( "player_is_away_from_grenade" );
			}
		}
		wait( 0.05 );
	}
	
	if ( flag( "player_is_away_from_grenade" ) )
	{
		level.player EnableDeathShield( false );
		level.player.health = 80;
	}
}*/


/////////////////////////////////////////////////////////////////////////////////////////////////
// ENVIRONMENT
/////////////////////////////////////////////////////////////////////////////////////////////////

break_enemy_windows()
{
	wait 10.5;
	
	thread break_window( "p1_upper" );
	wait 0.5;
	thread break_window( "p1_lower" );
}

break_window( which_floor )
{
	for ( i = 1; i <= 8; i++ )
	{
		damage_glass_struct = getstruct( which_floor + "_glass_damage_struct_" + i, "script_noteworthy" );
		if ( IsDefined( damage_glass_struct ) )
			GlassRadiusDamage( damage_glass_struct.origin, 96, 50, 50 );
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// COMMON FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////
/*
watch_player_pitch_in_volume( volume_name, event, flag, time )
{
	self endon( "death" );
	
	volume = GetEnt( volume_name, "targetname" );
	
	count = 0;
	
	while ( !flag( flag ) )
	{
		yaw_current	  = self GetPlayerAngles()[ 1 ];
		pitch_current = self GetPlayerAngles()[ 0 ];
		
		if ( self IsTouching( volume ) )
		{
			if ( event == "copymachine" )
			{
				if ( pitch_current < -30 )
				{
					//if ( abs( 0 - yaw_current ) < 40 )
					if ( yaw_current < 25 && yaw_current > -110 )
					{
						flag_set( flag );
					}
				}
			}
			else if ( event == "player_has_looked_up_for_count" )
			{
				if ( pitch_current < -30 )
				{
					if ( yaw_current < 50 && yaw_current > -30 )
					{
						if ( count == time )
						{
							flag_set( flag );
						}
						else
						{
							count++;
						}
					}
					else
					{
						if ( count > 0 )
						{
							count = 0;	
						}
					}
				}
			}
			else if ( event == "fx" )
			{
				if ( pitch_current > -30 )
				{
					flag_set( flag );
				}
			}
			else if ( event == "grenade" )
			{
				if ( pitch_current > -30 )
				{
					if ( yaw_current > -45 && yaw_current < -15 )
					{
						if ( count == time )
						{
							flag_set( flag );
						}
						else
						{
							count++;
						}
					}
					else
					{
						if ( count > 0 )
						{
							count = 0;	
						}
					}
				}
			}
		}
		wait( 0.01 );
	}
}

*/
/////////////////////////////////////////////////////////////////////////////////////////////////
// COMMON AI FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////

send_to_death_volume()
{
	self endon( "death" );
	
	volume = undefined;
	
	if ( IsAlive( self ) && self.script_noteworthy == "p1_upper" )
	{
		volume = GetEnt( "p1_upper_volume", "targetname" );
	}
	else if ( ( IsAlive( self ) && self.script_noteworthy == "copymachine_ai" ) || ( IsAlive( self ) && self.script_noteworthy == "p1_junction" ) )
	{
		volume = GetEnt( "p1_junction_volume", "targetname" );
	}
	else if ( IsAlive( self ) && self.script_noteworthy == "p1_lower" )
	{
		volume = GetEnt( "p1_lower_volume", "targetname" );
	}
	else if ( IsAlive( self ) && self.script_noteworthy == "p1_ahead" )
	{
		volumes = GetEntArray	( "p1_ahead_volume", "targetname" );
		volumes = SortByDistance( volumes		   , self.origin );
		volume	= volumes[ 0 ];
	}
	
	Assert( IsDefined( volume ) );
	
	if ( IsAlive( self ) )
	{
		self SetGoalVolumeAuto( volume );
		self waittill_notify_or_timeout( "goal", 5 );
		self notify( "stop_death_func" );
	}
	if ( IsAlive( self ) )
	{
		if ( IsDefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
			self stop_magic_bullet_shield();
		self Kill();
	}
}

//send_to_volume( dude_array, volume )
//{
//	foreach ( dude in dude_array )
//	{
//		dude SetGoalVolumeAuto( volume );
//	}
//}