#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\las_vegas_code;
#include maps\_hud_util;
#include maps\_player_limp;

#using_animtree( "generic_human" );

//---------------------------------------------------------
// Init
//---------------------------------------------------------
main_init()
{
	if ( IsDefined( level.entrance_main_init ) )
		return;

	// Level Vars
	level.entrance_main_init = true;

	// Clean these up, use flag_count
	level.player_in_bus = 0;
}

//---------------------------------------------------------
// Spawn Function
//---------------------------------------------------------
spawn_functions()
{
	array_spawn_function_noteworthy( "entrance_chopper_unloader", ::postspawn_entrance_chopper_unloader );
	array_spawn_function_noteworthy( "entrance_chopper_shooter", ::postspawn_entrance_chopper_shooter );
	
	array_spawn_function_targetname( "courtyard_chopper", ::postspawn_courtyard_chopper );
}

//---------------------------------------------------------
// Starts
//---------------------------------------------------------
start_entrance()
{
	struct = getstruct( "casino_player_slide_start", "targetname" );
	tarp = GetEnt( "player_slide_tarp", "targetname" );
	tarp.animname = "tarp";
	tarp setanimtree();
	struct thread anim_single_solo( tarp, "casino_player_slide" );
	
	set_start_locations( "entrance_startspot" );
}

start_entrance_combat()
{
//	level.wounded_ai maps\las_vegas_code::disable_wounded_ai();	
	set_start_locations( "entrance_startspot" );
	level.ninja clear_force_color();
	level.leader clear_force_color();
	
	// chopper spawners
	change_chopper_spawner( "entrance_chopper_shooter", "entrance_chopper_shooter_late_start" );
	change_chopper_spawner( "entrance_chopper_unloader", "entrance_chopper_unloader_late_start" );
	
	
}

change_chopper_spawner( name, noteworthy_node )
{
	spawner = GetEnt( name, "script_noteworthy" );
	node = getstruct( noteworthy_node, "script_noteworthy" );
	
	spawner.origin = node.origin;
	target_node = node get_target_ent();
	spawner.angles = VectorToAngles( target_node.origin - node.origin );
	
	guy_spawners = GetEntArray( spawner.target, "targetname" );
	foreach ( guy in guy_spawners )
		guy.targetname = node.targetname;
	
	spawner.target = node.targetname;
}

//---------------------------------------------------------
// Casino Entrance
//---------------------------------------------------------
entrance_init()
{
	if ( IsDefined( level.entrance_init ) )
		return;

	level.entrance_init = true;

	level.wounded_ai enable_wounded_ai(); // This is needed so start points work and initialize ent flags
	level.wounded_ai disable_wounded_ai();

	level.leader battlechatter_off();
	level.wounded_ai battlechatter_off();
	level.ninja battlechatter_off();
}

entrance()
{
	set_vision_set( "lv_fallroom" );

	main_init();
	entrance_init();

	level.leader battlechatter_off();
	level.wounded_ai battlechatter_off();

	thread transient_switch( "las_vegas_transient_hotel_tr", "las_vegas_transient_crasharea_tr" );
	getup();	

	// DISABLING THIS SO I CAN WORK ON COLOR NODES WORKING PROPERLY!
//	level.wounded_ai maps\las_vegas_code::enable_wounded_ai();

//	level.ninja delaythread( 0, ::smart_dialogue, "vegas_kgn_waitwait" );		
//	level.ninja delaythread( 2.4, ::smart_dialogue, "vegas_kgn_now" );
}

getup()
{
	fade_out( 0 );

	level.og_vegas_sun_pos = ( -50, 140, 0 );
	SetSunFlarePosition( ( -52, -95, 0 ) );

//	PreCacheShellShock( "coup_sunblind" );
	level.player DisableWeapons();	
	level.player GiveWeapon( "fraggrenade" );

	level.ninja battlechatter_off();
	battlechatter_off( "axis" );
	array_thread( level.heroes, maps\las_vegas_code::set_ai_name, "" );

//	level.hallway_dust = 0;
	level notify( "casino_player_jumped" );
	level.ninja clear_force_color();
	level.leader clear_force_color();
	
//	thread sand_moment_intro();
	level.wounded_ai delaythread( 1, ::ent_flag_clear, "FLAG_wounded_ai_play_sounds" ); // turn off coughs

	struct = getstruct( "bottom_anim_entrance","targetname" );
	struct.origin += ( 0, 0, 1 );
//	struct.angles = ( 0, 0, 0 );
	level.player_rig = spawn_anim_model( "player_rig", struct.origin );
	level.player_rig.animname ="player_rig";

	wait( 1 ); // Delay everything for a tiny bit
	thread getup_screen_effects();
	thread getup_fx();
	
	level.wounded_ai notify ( "stop_custom_anim_run" );

	foreach ( hero in level.heroes )
	{
		hero clear_force_color();
		hero battlechatter_off();
	}

	battlechatter_off( "axis" );

	arc = 15;
	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, arc, arc, 0, arc, 1 );
	
	thread getup_dialogue();	
//	thread maps\las_vegas_player_hurt::enable_player_hurt( 40 );

	// Testing!
/#
	if ( GetDvarInt( "test_hand_fx" ) )
	{
		struct thread anim_single_solo( level.player_rig, "raid_getup" );
		thread maps\las_vegas_anim::entrance_getup_hand_fx( level.player, true );
		while ( 1 )
		{
			level.player_rig SetAnimTime( level.player_rig getanim( "raid_getup" ), 0.5 );
			wait( 0.05 );
		}
		level waittill( "forever" );
	}
#/
	
	array = array_add( level.heroes, level.player_rig );
	struct anim_single( array, "raid_getup" );
	
	level.player EnableWeapons();
	level.player Unlink();
	level.player_rig Delete();
	array_thread( level.heroes, maps\las_vegas_code::reset_ai_name );

	flag_set( "intro_lines" );
	flag_set( "FLAG_getup_done" );
	
	level notify( "getup_dialogue_continue" );
	
	autosave_by_name( "entrance" );
}

custom_dirt_hud()
{
	array = [];
	array[ array.size ] = [ "fullscreen_dirt_left", -100, 5 ];
	array[ array.size ] = [ "fullscreen_dirt_right", -200, 15 ];

	hud_array = [];
	scale = 1.5;
	foreach ( info in array )
	{
		hud = NewHudElem();
		hud SetShader( info[ 0 ], int( 640 * scale ), int( 480 * scale ) );
		hud.horzAlign = "fullscreen";
		hud.vertAlign = "fullscreen";
		hud.y += info[ 1 ];

		hud FadeOverTime( info[ 2 ] );
		hud.alpha = 0;

		hud_array[ hud_array.size ] = hud;
	}


	sand = NewHudElem();

	sand SetShader( "buried_sand_screen", 640, 480 );
	sand.horzAlign = "fullscreen";
	sand.vertAlign = "fullscreen";
	sand.alpha = 0;
	sand.y = 200;

	level waittill( "buried_sand_screen_increase" );

	sand FadeOverTime( 3 );
	sand.alpha = 1;

	level waittill( "buried_sand_screen_remove" );

	time = 2;
	sand FadeOverTime( time );
	sand.alpha = 0;

	wait( time );

	sand Destroy();
	
	flag_wait( "leaving_entrance" );

	SetSunFlarePosition( level.og_vegas_sun_pos );
}

getup_dialogue()
{
	level endon ( "build_up_to_glass_breaks_stealth" );
//	thread music();
	
//	wait( 11 );
//	level.ninja smart_dialogue( "vegas_kgn_cmonletsgo" );

//	thread start_vo_get_caught();

	level waittill( "getup_dialogue_continue" );

	wait 3;
//	delayThread( 1.7,  ::first_bad_guy_convoy_conversation);
	wait( 2 );
	wait( 7 );

	level.ninja delayThread( 4,  ::smart_dialogue, "vegas_kgn_donttherestoomany" );	
	
	wait( 3 );

	wait 5.2;
	level.ninja delayThread( 0,  ::dialogue_queue, "vegas_kgn_easy" );
}

getup_screen_effects()
{
	thread custom_dirt_hud();

	if ( IsDefined( level.fadein ) )
		level.fadein Destroy();
		
	thread fade_in( 3 );

	level.player ShellShock( "las_vegas_getup", 5 );
	thread getup_screenshake( 5 );

	SetBlur( 30, 0.05 );
	wait( 0.1 );
	maps\_art::dof_enable_script( 1, 499, 10, 500, 600, 10, 0.1 );

	SetBlur( 5, 2 );
	wait( 1 );

	maps\_art::dof_enable_script( 1, 250, 10, level.dof["base"]["current"]["farStart"], level.dof["base"]["current"]["farEnd"], 10, 3.1 );
	wait( 1 );
	
	SetBlur( 0, 5 );
	wait( 5 );
	
	maps\_art::dof_disable_script( 2.5 );
}

getup_screenshake( time )
{
	timer = GetTime() + ( time * 1000 );
	while ( timer > GetTime() )
	{
		EarthQuake( 0.105, 0.2, level.player.origin, 500 );
		wait( 0.1 );
	}
}

getup_fx()
{
	thick = "vfx_thick_falling_stream";
	impact = "vfx_sand_ground_spawn_loop";

	offset = ( -16, 70, 720 );
	thread getup_fx_thread( thick, level.player_rig.origin + offset, "stop_hand_sand_stream" );
	thread getup_fx_thread( impact, groundpos( level.player_rig.origin + offset + ( 0, 0, -500 ) ), "stop_hand_sand_stream" );
}

getup_fx_thread( fx, pos, note )
{
//	thread maps\_debug::drawArrow( pos, ( 0, 0, 0 ), undefined, 50000 );
	fxent = SpawnFX( getfx( fx ), pos, ( 1, 0, 0 ) );
	TriggerFX( fxent, -5 );
	
	if ( IsDefined( note ) )
	{
		level waittill( note );		
		fxent Delete();
	}
}

//---------------------------------------------------------
// Entrance Combat
//---------------------------------------------------------
entrance_combat()
{
	main_init();
	entrance_init();
	
	thread entrance_pursuers();

//	maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "web_two" );

	// cool black and white treatment could be nice.
//	thread maps\las_vegas_adrenaline::player_enable_adrenaline( 3 );

//	PreCacheShellShock( "coup_sunblind" );
	
	battlechatter_off( "axis" );
	
	level.leader thread enable_cqbwalk();
	level.ninja thread enable_cqbwalk();
	
	array_thread( level.heroes, ::set_ignoreall, true );
	foreach ( hero in level.heroes )
	{
		hero.ignoreall = true;
		hero.grenadeawareness = 1;
		hero thread waittill_combat_start();
	}
	
	level.ninja AllowedStances( "crouch" );
	level.leader AllowedStances( "crouch" );

	level.leader thread start_walk( "path_over_chair", "r" );
	level.ninja thread start_walk( "path_switch_to_sniper", "g" );
	
	level.wounded_ai delayThread( 4, ::set_force_color, "r" );

	activate_trigger_with_targetname( "color_post_getup" );
	
	flag_wait( "entrance_combat_start" );

	thread courtyard_battle_think();

//	thread old_pursuers();

	// DISABLING THIS SO I CAN WORK ON COLOR NODES WORKING PROPERLY!
//	level.wounded_ai maps\las_vegas_code::enable_wounded_ai();
//	level.wounded_ai thread move_to_node( "entrance_wounded_node1" );
	
	flag_wait( "out_of_courtyard" );
}

entrance_pursuers()
{
	if ( level.start_point != "entrance_combat" )
	{
		wait( 4 );
	}
	
	spawn_vehicles_from_targetname_and_drive( "entrance_chopper" );
	
//	flag_wait( "entrance_combat_start" );
//	spawn_vehicles_from_targetname_and_drive( "armada" );
}

entrance_enemy_alert_thread()
{
	self.ignoreall = true;
	self enable_cqbwalk();
	og_walkdist = self.walkdist;
	self.walkdist = 1200;
	
	self thread waittill_flag_set( "too_close", "entrance_combat_start" );
	self thread waittill_flag_set( "damage", "entrance_combat_start" );
	self thread waittill_flag_set( "bulletwhizby", "entrance_combat_start" );
	self thread waittill_flag_set( "explode", "entrance_combat_start" );
	
	self thread too_close_to_allies( "too_close", 250, "entrance_combat_start" );
		
	nodes = getstructarray( "entrance_shooter_path", "targetname" );
	nodes = SortByDistance( nodes, self.origin );
	
	follow_node = undefined;
	foreach ( node in nodes )
	{
		if ( IsDefined( node.is_taken ) )
			continue;

		node.is_taken = true;		
		follow_node = node;
		break;
	}
	
	self thread follow_path( follow_node );
	
	flag_wait( "entrance_combat_start" );
	
	self notify( "_utility::follow_path" );
	self.walkdist = og_walkdist;
	self.ignoreall = false;
	self.goalradius = 1024;
}

start_walk( targetname, color )
{
	self set_force_color( color );
	self disable_ai_color();
	
	self walkdist_zero();

	node = getstruct( targetname, "targetname" );
	self follow_path( node, undefined, ::follow_path_node_anim );
	
	self walkdist_reset();
	self enable_ai_color();
}

waittill_combat_start()
{
	flag_wait( "entrance_combat_start" );
	
	
	// TEMP!
	level waittill( "forever" );
	
	self.ignoreme = false;
	self.ignoreall = false;
	
	if ( self.team == "axis" )
	{
		self.goalradius = level.default_goalradius;
	}
}

snipe_close_pursuers( guy )
{
	level waittill( "guy_heading_to_entrance", guy );
	guy waittill_either( "death", "start_follow_path_anim" );
	
	// Keegan take the shot
	level.ninja force_shot_track( guy, 2 );
	
	flag_set( "entrance_combat_start" );
	
	self.ignoreall = false;
}

//---------------------------------------------------------
// Big Combat Area
//---------------------------------------------------------
courtyard_battle_think()
{
	level.courtyard = SpawnStruct();
	level.courtyard.enemy_volume = GetEnt( "courtyard_volume", "targetname" );
	level.courtyard.enemies = [];
	level.courtyard.chopper_shooter_count = 0;
	level.courtyard.chopper_shooter_total = 0;
	level.courtyard.chopper_shooter_holding = 0;
	level.courtyard.next_chopper_shooter = 0;
	
	triggers = GetEntArray( "courtyard_volume_triggers", "targetname" );
	array_thread( triggers, ::enemy_volume_trigger_thread, level.courtyard, "courtyard_battle_done" );
	
	while ( 1 )
	{
		courtyard_chopper_spawn();
		courtyard_chopper_reinforcement();
		courtyard_update_enemy_volume();
		wait( 0.2 );
	}
}

courtyard_update_enemy_volume()
{
	level.courtyard.enemies = array_removeDead_or_dying( level.courtyard.enemies );
	level.courtyard.enemies = array_removeUndefined( level.courtyard.enemies );

	foreach ( guy in level.courtyard.enemies )
	{
		volume = Guy GetGoalVolume();
		if ( !IsDefined( volume ) || volume != level.courtyard.enemy_volume )
		{
			guy thread set_goal_volume( level.courtyard.enemy_volume, RandomFloatRange( 0, 2 ) );
		}
	}
}

courtyard_unload_thread()
{
	self endon( "death" );
	
	level.courtyard.enemies[ level.courtyard.enemies.size ] = self;	

	self waittill( "jumpedout" );

	// little delay for unload animation to finish
	wait( 2 );
	
	self set_goal_volume( level.courtyard.enemy_volume, RandomFloat( 2 ) );
}

courtyard_chopper_spawn()
{
	if ( GetTime() < level.courtyard.next_chopper_shooter )
		return;
	
	if ( level.courtyard.chopper_shooter_holding > 1 )
		return;
		
	structs = getstructarray( "courtyard_chopper_holding", "targetname" );
	struct = get_unused_struct( structs );
	
	if ( !IsDefined( struct ) )
		AssertMsg( "what" );
	
	
	spawner = get_chopper_spawner( "courtyard_chopper" );
	
	if ( !IsDefined( spawner ) )
		return;
	
	chopper = spawner spawn_vehicle_and_gopath();
	
	if ( !IsDefined( chopper ) )
		return;
		
	spawner.is_shooter = true;
	spawner.inuse = true;
	
	level.courtyard.chopper_shooter_holding++;
	level.courtyard.chopper_shooter_total++;

	if ( level.courtyard.chopper_shooter_total > 2 )
		level.courtyard.next_chopper_shooter = GetTime() + 45000;

}

courtyard_chopper_spawn_thread()
{
	self endon( "death" );
	
	self.holding = true;
	self thread chopper_holding_waittill();
	self waittill( "reached_dynamic_path_end" );
	
//	self chopper_shooter_holding_pattern();
	self chopper_shooter_holding();
	
	self notify( "holding_done" );
	level.courtyard.chopper_shooter_count++;

	// Do a little delay before heading to the path	
	struct = getstruct( "courtyard_dyn_path", "targetname" );
	angles = VectorToAngles( struct.origin - self.origin );
	self SetGoalYaw( angles[ 1 ] );
	
	wait( RandomFloatRange( 5, 8 ) );

	self thread chopper_shooter_init( "courtyard_dyn_path" );	
}

chopper_shooter_holding()
{
	self endon( "death" );
	
	structs = get_sorted_structs( "courtyard_chopper_holding", self.origin );
	struct = get_unused_struct( structs );
	
	struct.inuse = true;
	struct thread reset_inuse( self, "holding_done" );
	self SetVehGoalpos( struct.origin, true );
	self waittill_any( "near_goal", "goal" );
	
	switch_angle = false;
	while ( 1 )
	{
		if ( switch_angle )
		{
			switch_angle = false;
			self SetTargetYaw( struct.angles[ 1 ] + 180 );
		}
		else
		{
			switch_angle = true;
			self SetTargetYaw( struct.angles[ 1 ] );
		}
		
		time = GetTime() + ( RandomFloatRange( 5, 10 ) * 1000 );
		while ( time > GetTime() )
		{
			// Time to go onto shooter path
			if ( level.courtyard.chopper_shooter_count < 1 )
			{
				self ClearTargetYaw();
				return;
			}
			
			wait( 0.2 );
		}
	}
}

chopper_holding_waittill()
{
	self waittill_any( "death", "holding_done" );
	level.courtyard.chopper_shooter_holding--;
}

// Dynamic reinforcement Choppers -- called from postspawn*
courtyard_chopper_reinforcement_think()
{
	self waittill( "reached_dynamic_path_end" );
	
	self thread chopper_unload();
	self waittill( "reached_dynamic_path_end" );
	
	self chopper_exit();
}

courtyard_chopper_reinforcement()
{
	axis = GetAiArray( "axis" );
	if ( level.courtyard.enemies.size > 3 )
		return;
	
	spawner = get_chopper_spawner( "courtyard_chopper" );
	
	if ( !IsDefined( spawner ) )
		return;

	vehicle = spawner spawn_vehicle_and_gopath();
	
	if ( IsDefined( vehicle ) )
		spawner.inuse = true;
}

// Train
//---------------------------------------------------------
TRAIN_FALL_MAX_DIST = 1200;
TRAIN_FALL_MIN_DIST = 950;
#using_animtree("script_model" );
train_fall()
{	
	struct = getstruct( "train_fall_spot", "targetname" );
	parts = getentarray( struct.target, "targetname" );
	sparkspots = getentarray( "trainfall_spark_spots", "targetname" );

	foreach( part in parts )
	{
		part.animname = part.script_noteworthy;
		part UseAnimTree( #animtree );
		struct anim_first_frame_solo( part, "vegas_train_fall" );	
	}
	
	train1 = undefined;
	foreach( part in parts )
	{
		part.animname = part.script_noteworthy;
		part UseAnimTree( #animtree );
		struct anim_first_frame_solo( part, "vegas_train_fall" );
		if( part.script_noteworthy == "train1" )
		{
			train1 = part;
			struct thread anim_loop_solo( part, "vegas_train_fall_idle", "stop_anim" );
		}
		
		foreach( spot in sparkspots )
		{
			if( spot.script_noteworthy == part.script_noteworthy )
			{
				//offset = spot.origin - part gettagorigin( "train1_jnt" );
				spot linkto( part, "train1_jnt" );
				part thread train_crash_fx( spot );
			}
		}
	}
	
	flag_wait( "leaving_entrance" );
	
	// Target_IsInCircle
	
	// 1 = impact
	// 2 = spark drip
	// 3 = dust
	
	lookatSpots =  [ ( -29881, -34947, 458 ), ( -29681, -34883, 458 ) ];
	
	while ( 1 )
	{
		wait( 0.1 );
		
		if ( DistanceSquared( level.player.origin, train1.origin ) > squared( TRAIN_FALL_MAX_DIST ) )
		{
			continue;
		}
		
		if( DistanceSquared( level.player.origin, train1.origin ) > squared( TRAIN_FALL_MIN_DIST ) )
		{
				count = 0;
				foreach( spot in lookatSpots )
				{
					if( level.player player_looking_at( spot ) )
						count++;
				}
				
				if( count == 0 )
					continue;
		}
 
		wait( randomfloat( 1 ) );
		flag_set( "FLAG_traincrash_start" );
			
		thread train_quake_crash();
//			for( i=1; i<4; i++ )
//				exploder( i );
			
		struct notify( "stop_anim" );
		struct anim_single( parts, "vegas_train_fall" );
		break;

	}	
}

train_crash_fx( sparkspot )
{
	flag_wait( "FLAG_traincrash_start" );
	
	if( self.script_noteworthy == "train1" )
	{
		sparkspot thread train_crash_fx_sparks( 0, .25 );
		sparkspot thread train_crash_fx_sparks( .6, .2 );
		sparkspot thread train_crash_fx_sparks( 1.2, .6 );
		sparkspot thread train_crash_fx_sparks( 2.2, .6 );
		
		exploder( 3 );
		wait( .6 );
		exploder( "train_fall_track_impact" );
		exploder( 3 );
		wait( 2.2 );
		exploder( 1 );
	}
	else
	{
		sparkspot thread train_crash_fx_sparks( 0, .7 );
		sparkspot thread train_crash_fx_sparks( 1.14, 1.8 );
	}
	
}

train_crash_fx_sparks( waittime, time )
{ 	
	
	wait( waittime );
	
	stime = gettime();
	time = time * 1000;
	
	while( gettime() - stime <= time ) // gettime() - stime >= time
	{
		fwdangles = anglestoforward( ( 0, 90, randomintrange( -360, 360 ) ) );
		playfx( getfx( "vfx_electrical_spark" ), self.origin, fwdangles );
		wait( randomfloatrange( .05, .1 ) );		
	}
}

train_quake_crash()
{
	wait 0.7;
	earthquake( 0.2, 0.5, level.player.origin, 1000 );	
	wait 2.2;
	earthquake( 0.4, 0.8, level.player.origin, 1000 );
}

//music()
//{
//	//wait 3.1;
//	level waittill( "getup_dialogue_continue");
////	thread music_play( "temp_hz_dkrises_underarmy" );
//	thread music_play( "mus_vegas_build_after_slide" );
//	level waittill( "build_up_to_glass_breaks_stealth" );
//	level.player allowsprint( true );
////	wait 5;
//	thread music_crossfade("mus_vegas_build_stinger", 3);	
////	thread music_play( "mus_vegas_build_after_slide" );
//	level waittill( "start_action_music" );
//	wait 2.5;	
//	thread music_crossfade("mus_vegas_outdoor_battle", 1);
//}

off_timed_run_back( enemy_retreaters, wave_four_placement_volume_retreat )
{
	
	foreach( guy in enemy_retreaters )
	{
		guy endon ( "death" );
		wait( RandomFloatRange ( 0.3, 1) );
		guy.ignoreall = true;
		guy SetGoalVolumeAuto( wave_four_placement_volume_retreat );
		guy thread reset_ignore_for_enemy();
	}
	
	
}

attack_if_player_close_when_retreating()
{
	self endon( "death" );
	while( 1 )
	{
		if( distance2D( level.player.origin, self.origin ) <= 300 )
		{
			self.ignoreall = false;
			self SetGoalEntity ( level.player );
			break;
		}
		wait( 0.3 );
	}
}

reset_ignore_for_enemy()
{
	self endon ( "death" );
	self waittill ( "goal" );
	self.ignoreall = false;
	wait 10;
	self.goalradius = 2048;
}

//---------------------------------------------------------
// Vehicles Section
//---------------------------------------------------------
postspawn_entrance_chopper()
{
	self thread vehicle_path_notifies();
	self SetMaxPitchRoll( 60, 40 );
}

postspawn_entrance_chopper_unloader()
{
	self thread postspawn_entrance_chopper();
	
	foreach ( shooter in self.shooters )
	{
		shooter thread entrance_enemy_alert_thread();
	}
}

postspawn_entrance_chopper_shooter()
{
	self thread postspawn_entrance_chopper();
	
	flag_wait( "entrance_combat_start" );

	self SetMaxPitchRoll( 30, 30 );
	self SetHoverParams( 60, 20, 50 );
	
	self waittill( "reached_dynamic_path_end" );
	wait( 0.5 );
	
	level.courtyard.chopper_shooter_count++;
	
	self.shooter_side = "left";	
	self thread chopper_shooter_init( "courtyard_dyn_path" );
}

postspawn_courtyard_chopper()
{
	self thread vehicle_path_notifies();
	
	if ( IsDefined( self.vehicle_spawner.is_shooter ) && self.vehicle_spawner.is_shooter )
	{
		self.vehicle_spawner.is_shooter = false;
		self.vehicle_spawner thread reset_inuse( self, "reached_dynamic_path_end" );	
		self thread courtyard_chopper_spawn_thread();

	}
	else // reinforcement chopper
	{
		self thread courtyard_chopper_reinforcement_think();
		array_thread( self.shooters, ::courtyard_unload_thread );
		
		self.vehicle_spawner thread reset_inuse( self, "exiting" );			
	}
}

//---------------------------------------------------------
// Utility Section 
//---------------------------------------------------------
follow_path_node_anim( node )
{
	if ( !IsDefined( node.animation ) )
	{
		return;
	}
	
	type = "normal";
	if ( IsDefined( node.script_type ) )
	{
		type = node.script_type;
	}
	
	animation = node.animation;
	
	if ( type == "play_once" )
		node.animation = undefined;
	
	arrivals = true;
	if ( IsDefined( node.script_parameters ) )
	{
		if ( node.script_parameters == "no_arrivals" )
		{
			arrivals = false;
		}
	}
	
	if ( !arrivals )
	{
		self disable_arrivals();
		self disable_exits();
	}
	
	node anim_generic_reach( self, animation );

	self notify( "start_follow_path_anim" );
	switch ( type )
	{
		case "run_anim":
			node anim_generic_run( self, animation );
			break;
		case "switch_to_sniper":
			self thread switch_to_sniper( node );
			break;
		default:
			node anim_generic( self, animation );
			break;
	}
	
	if ( !arrivals )
	{
		self enable_arrivals();
		self enable_exits();
	}
}

switch_to_sniper( node )
{
	self OrientMode( "face angle", node.angles[ 1 ] );
	self AnimCustom( ::switch_to_sniper_internal );
}

switch_to_sniper_internal()
{
	animation = self animscripts\utility::lookupAnim( "cqb", "shotgun_pullout" );
	self animscripts\run::ShotgunSwitchStandRunInternal( "sniper_pullout", animation, "gun_2_chest", "none", self.secondaryweapon, "shotgun_pickup" );
}

array_remove_after_index( array, index )
{
	new_array = [];
	for ( i = 0; i < index; i++ )
		new_array[ new_array.size ] = array[ i ];
	
	return new_array;
}

get_script_index()
{
	return self.script_index;
}

//---------------------------------------------------------
// Debug
//---------------------------------------------------------
chopper_crash_loop()
{
	struct = SpawnStruct();
	struct.origin = ( -32000, -36919, 380 );
	struct.angles = ( 0, 0, 0 );

	level.player SetOrigin( groundpos( struct.origin ) );

	chopper = Spawn( "script_model", struct.origin );
	chopper SetModel( "vehicle_aas_72x_destructible" );
	chopper.animname = "chopper";
	chopper setanimtree();

	while ( 1 )
	{
		wait( 2 );
		chopper thread chopper_temp_fx();
		struct anim_single_solo( chopper, "vegas_strip_aas_72x_crash" );

		wait( 2 );
		level notify( "stop_chopper_crash_fx" );
		wait( 1 );
		chopper StopAnimScripted();
		chopper.origin = struct.origin;
	}
}

chopper_temp_fx()
{
	playfx( getfx( "small_vehicle_explosion_new" ), self.origin );

	fxobj = playfxOnTag( getfx( "vfx_dark_sm_emitter" ), self, "tag_body" );
	wait 0.4;
	playfx( getfx( "small_vehicle_explosion_new" ), self.origin );
	wait 1.7;
	playfx( getfx( "small_vehicle_explosion_new" ), self.origin );
	wait 2;
	playfx( getfx( "small_vehicle_explosion_new" ), self.origin );


	level waittill( "stop_chopper_crash_fx" );
	StopFXonTag( getfx( "vfx_dark_sm_emitter" ), self, "tag_body" );
}