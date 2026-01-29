#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\skyway_util;
#include maps\skyway_util_ai;
#include maps\skyway_vignette;

//*******************************************************************
//																	*
//																	*
//*******************************************************************

section_flag_inits()
{
	flag_init( "flag_hangar_door_open" );
	flag_init( "flag_hangar_end" );
}

section_precache()
{
}

section_post_inits()
{	
	player_start = GetEnt( "player_start_hangar", "targetname" );
	
	if( IsDefined( player_start ))
	{		
		level._hangar = SpawnStruct();		

		// Load start points		
		level._hangar.player_start = player_start;
		level._hangar.ally_start = GetEnt( "ally1_start_hangar", "targetname" );					
		
		// Intro parts		
		node = GetEnt( "origin_hangar_intro", "targetname" );				
		wall = spawn_anim_model( "hangar_wall" );		
		tv_broken = GetEnt( "brush_hangar_pip_screen_broken", "targetname" );
		
		// Hide broken tv
		tv_broken HideNoShow();
		
		// Door
		door_brush = GetEnt( "brush_hangar_door", "targetname" );		
		door = spawn_anim_model( "hangar_door", door_brush.origin );
		door.angles = door_brush.angles;		
		door_brush LinkTo( door, "tag_origin", (0,0,100), (0,0,0) );
		
		// First frame the parts
		node anim_first_frame( [ door, wall ], "hangar_intro" );
		
		// Load intro parts into globals
		level._hangar.intro_node = node;
		level._hangar.intro_door = door;
		level._hangar.intro_wall = wall;
		level._hangar.intro_tv_broken = tv_broken;		
	}
}

start()
{
	IPrintLn( "hangar" );
	
	// Player
	player_start( level._hangar.player_start );		
	
	// Allies
	level._allies[ 0 ] ForceTeleport( level._hangar.ally_start .origin, level._hangar.ally_start .angles );
	level._allies[ 0 ] set_force_color( "r" );
}

main()
{
	// setup triggers
	array_call( level._train.cars[ "train_hangar" ].trigs, ::SetMovingPlatformTrigger );	
	
	// Wait for introscreen
	if( !IsDefined( level.debug_no_move ) || !level.debug_no_move )
		flag_wait( "introscreen_complete" );
	
	// Events
	thread event_intro();		
	thread event_sat_1_rog_hit();
	
	flag_wait( "flag_hangar_end" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_intro()
{
	// Pip scene
	thread event_intro_tv_pip();
	
	// Setup Player
	setup_player_for_animated_sequence();
	level.player_rig thread player_anims();
	
	// Get things for scene
	node = level._hangar.intro_node;
	ally = level._allies[ 0 ];
	door = level._hangar.intro_door;
	wall = level._hangar.intro_wall;		
		
	// Spawn enemies for scene
	enemy_spawners = GetEntArray( "actor_hangar_enemy_intro", "targetname" );
	array_thread( enemy_spawners , ::add_spawn_function, ::spawnfunc_intro );
	enemies = array_spawn( enemy_spawners, true );	
	
	// Give a frame for the ally to pickup the mesh
	wait( 0.1 );
	
	//TODO Scripted events that will eventually be controlled by notetracks
	thread temp_timing_stuff( ally, enemies );
	
	// Group actors, link them
	actors = array_combine( [ door, wall, ally, level.player_rig ], enemies );
	actors ignore_everything();	
	array_thread( actors, ::LinkToTrain, "train_hangar" );	
	
	// Start main hangar car scene	
	node vignette_single( actors, "hangar_intro" );
	
	//
	// End
	//	
	
	// Enable ally colors after scene
	ally Unlink();	
	ally enable_ai_color();
	activate_trigger_with_targetname( "trig_ally_hangar" );
}

event_intro_tv_pip()
{
	node = GetStruct( "struct_hangar_pip", "targetname" );
	boss = level._boss;
	camera = spawn_anim_model( "hangar_pip_camera" );
	tv_broken = level._hangar.intro_tv_broken;
	
	// Enemy	
	enemy_spawner = GetEnt( "actor_hangar_enemy_pip", "targetname" );
	enemy_spawner add_spawn_function( ::spawnfunc_intro );
	enemy = enemy_spawner spawn_ai( true );
	
	// Group actors, link them, and start PIP scene
	actors = [ boss, camera, enemy ];	
	actors ignore_everything();	
	node thread anim_single( actors, "hangar_intro" );
	
	// Create PIP    
	level.pip = level.player NewPIP();   
	
	// PIP options
	level.pip.x						  = 0;
	level.pip.y						  = 0;
	level.pip.width					  = 128;
	level.pip.height				  = 96;
	level.pip.freeCamera			  = true;
	level.pip.fov					  = 30;
	level.pip.enableShadows			  = true;
	level.pip.origin				  = camera.origin;
	level.pip.entity				  = camera;
	level.pip.tag					  = "tag_origin";
//	level.pip.VisionSetNaked		  = "skyway_pip";
//	level.pip.activevisionset		  = "skyway_pip";
	level.pip.renderToTexture		  = true;
	level.pip.enable				  = true;
	
	// Fuzz	
	tv_origin = GetEnt( "origin_hangar_tv_static", "targetname" );
	tv = tv_origin spawn_tag_origin();
	tv LinkToTrain( "train_hangar" );	
//	PlayFX( GetFX( "pip_static" ), camera.origin, AnglesToForward( camera.angles ), AnglesToUp( camera.angles ) );
	PlayFXOnTag( GetFX( "pip_static" ), tv, "tag_origin" );
    
	//
	// End
	//	
	
    flag_wait( "flag_hangar_door_open" );
    
    // Show broken tv
    tv_broken show();  
    GetEnt( "brush_hangar_pip_screen", "targetname" ) delete();
        
    // Clean up
	level.pip.enable = false;
	level.pip.entity = undefined;		
    camera delete();
    enemy delete(); 
    tv delete();
    tv_origin delete();
}          

spawnfunc_intro()
{
	self.animname = self.script_parameters;	
	self.v.invincible = true;
	self.v.silent_script_death = true;
	self.v.death_on_end = true;
}

player_anims()
{
	self waittill( "msg_vignette_end" );
	player_animated_sequence_cleanup();
}

temp_timing_stuff( ally, enemies )
{
	// Hanger door opens
	anim_length = GetAnimLength( ally GetAnim( "hangar_intro" ) );
	DelayThread( anim_length - 5.75, ::flag_set, "flag_hangar_door_open" );
	
	// Kill floor enemies to fix collision with player
	foreach( enemy in enemies )
		if( IsSubStr( enemy.animname, "1" ) )
			enemy thread DelayThread( 3, ::vignette_end );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

event_sat_1_rog_hit()
{
	satellites = level._sat.satellites;	
	car = level._train.cars[ "train_sat_1" ].body;		
	rog_hits = [];
	
	// Setup FX points for Rod of God
	for( i = 0; i < 3; i++ )
		rog_hits[ i ] = getent( "model_rog_hit_ref_" + (i + 1), "targetname" );
	
	// Vision transition
	DelayThread( 2, ::vision_set_fog_changes, "skyway", 2 );
	
	// Wait for player to go around corner
	flag_wait( "flag_hangar_door_open" );	
	
	//wait a second so the rogs are coming down at the right time
	wait 2.6;
	
	// Wait for player to look (use mode_rog_hit_ref_4)
	rog_hits[ 0 ] waittill_player_lookat( 0.5, 0, true, 2 );
	
	
	time_between_hits = 1.5;
	//sequential magnitude of quakes
	quake_mag = [ 0.35, 0.3, 0.22 ];
	for( i = 0; i < rog_hits.size; i++ )
		thread DelayThread( (i * time_between_hits ), ::event_sat_1_rog_impact, rog_hits[ i ], quake_mag[ i ] );
	
//	wait( 2.5 );
//	
//	// Shockwave hits train
//	level._train thread maps\skyway_util::train_overlay( "sathit_1" );	
//	for( i = 1; i < satellites.size; i++ )
//		satellites[ i ] SetAnim( level.scr_anim[ "model_sat_1_satellite_" + i ][ "sathit_1" ] );
//		
//	wait( 0.5 );
//	
//	// Shockwave hits player
//	if( IsDefined( level.debug_no_move ) && !level.debug_no_move )
//		thread player_sway_bump( 0.2, 1.2, 5, 1.0 );
//	Earthquake( 0.3, 1.2, level.player.origin, 2000 );
//	level.player PlayRumbleOnEntity( "grenade_rumble");	
	
}

event_sat_1_rog_impact( rog, quake_mag )
{
	// Rod of God fires	
	PlayFXOnTag( getfx( "sathit_rog_huge" ), rog, "tag_explode" );
	
	// Rod of God strikes ground
	wait( 2.4 );	
	Earthquake( quake_mag, 1.5, level.player.origin, 100000 );
	level.player PlayRumbleOnEntity( "damage_heavy");	
	thread vision_hit_transition( "skyway_rogstrike", "skyway", 0.2, 0.1, 1.3 );
	//PlayFXOnTag( getfx( "sathit_rog_shockwave" ), obj_shockwave, "tag_origin" );
}