#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;

outro_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//flag inits
	flag_init( "outro_finished" );
	flag_init( "outro_starting" );
	
	//precache
	
	//init arrays/vars
	level.outro_zodiacs = GetEntArray( "outro_zodiac_allies", "targetname" );
	array_thread( level.outro_zodiacs, ::hide_entity );
		
	//hide ents
	level.outro_zodiac_player = getent( "outro_zodiac_player", "targetname" );
	level.outro_zodiac_player hide_entity();
}

setup_outro()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "outro";
	setup_common();
	spawn_allies();
	set_sun_post_heli_ride();
	//thread outro_corpses();
	//thread outro_helis();
	thread vista_tilt();
	thread set_black_fade( 1.0, .05 );

	flag_set( "slow_intro_finished" );
	flag_set( "start_main_odin_strike" );
}

begin_outro()
{
	//--use this to run your functions for an area or event.--
	flag_set( "outro_starting" );
	wait( 3 );
	thread outro_background();
	thread outro_hero_heli();
	thread set_black_fade( 0.0, 2 );
	
	player_rig = spawn_anim_model( "player_rig" );
	driver = spawn_targetname( "zodiac_guy", true );
	driver.animname = "generic";
	
	level.outro_zodiac_player.animname = "zodiac";
	level.outro_zodiac_player SetAnimTree();
	
	guys = [];
	//JMCD: TEMP CHANGED TO HESH TO PREVENT SRE (DUE TO DELETING MERRICK EARLIER)
	guys[ 0 ] = level.hesh;
	guys[ 1 ] = player_rig;
	guys[ 2 ] = driver;
	guys[ 3 ] = level.outro_zodiac_player;
		
	level.outro_zodiac_player show_entity();
	
	level.outro_animnode anim_first_frame( guys, "carrier_outro" );
	
	level.player PlayerLinkToDelta( player_rig, "tag_player", 0, 15, 15, 15, 15 );
	level.player DisableWeapons();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	
	level.outro_animnode thread anim_single( guys, "carrier_outro" );
			
	wait( 18 );
	
	thread set_black_fade( 1.0, 3 );
	
	wait( 3 );
	
	//flag_wait( "outro_finished" );	
	//thread autosave_tactical();
	nextmission();
}

outro_hero_heli()
{
	heli_spawner = GetEnt( "outro_hero_heli", "targetname" );
	heli = heli_spawner spawn_vehicle();
	heli.animname = "outro_blackhawk";
	heli SetAnimTree();
	
	level.outro_animnode anim_single_solo( heli, "carrier_outro_enter_heli" );
	level.outro_animnode thread anim_loop_solo( heli, "carrier_outro_idle_heli" );
}

outro_helis()
{
	heli1_node = getEnt( "outro_animnode_heli1", "targetname" );
	heli2_node = getEnt( "outro_animnode_heli2", "targetname" );
	
	heli1_node LinkTo( level.ocean_water );
	heli2_node LinkTo( level.ocean_water );
	
	flag_wait( "outro_starting" );
	
	heli1 = spawn_vehicle_from_targetname( "outro_heli1" );
	heli1.animname = "outro_blackhawk";
	heli1 SetAnimTree();
	
	heli2 = spawn_vehicle_from_targetname( "outro_heli2" );
	heli2.animname = "outro_blackhawk";
	heli2 SetAnimTree();
	
	heli1_node thread anim_loop_solo( heli1, "carrier_outro_idle_heli" );
	heli2_node thread anim_loop_solo( heli2, "carrier_outro_idle_heli" );
}

outro_background()
{
	array_thread( level.outro_zodiacs, ::show_entity );
	
	spawn_vehicles_from_targetname_and_drive( "ending_planes" );
}

outro_corpses()
{
	corpse_spawner = GetEntArray( "corpse", "targetname" );
	
	foreach ( item in corpse_spawner )
	{
		item thread outro_corpse_anim();
	}
}

outro_corpse_anim()
{
	animnode = self spawn_tag_origin();
	animnode LinkTo( level.ocean_water );
	
	flag_wait( "outro_starting" );
	
	corpse = self spawn_ai( true );
	corpse.animname = "generic";
	corpse gun_remove();
	animnode thread anim_loop_solo( corpse, corpse.animation );
}