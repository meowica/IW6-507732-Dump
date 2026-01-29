#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

#include maps\youngblood_util;

main()
{
	template_level( "youngblood" );
	
	// jrote - Moved the earthquake init into a seperate script call so they can be called from Prologue	
	youngblood_earthquake_setup();

	maps\createart\youngblood_art::main();
	maps\youngblood_fx::main();
	maps\youngblood_precache::main();
	
	add_start( "start_deer"			 , ::start_deer			 , undefined );
	add_start( "start_woods"		 , ::start_woods		 , undefined );
	add_start( "start_neighborhood"	 , ::start_neighborhood	 , undefined );
	add_start( "start_mansion_ext"	 , ::start_mansion_ext	 , undefined );
	add_start( "start_mansion"	 	 , ::start_mansion	 	 , undefined );
	add_start( "start_chaos_a"	 	 , ::start_chaos_a	 	 , undefined );
	add_start( "start_chaos_b"	 	 , ::start_chaos_b	 	 , undefined );
	add_start( "start_test"			 , ::start_test			 , undefined );
	add_start( "start_test_area_a"	 , ::start_test_area_a	 , undefined );
	add_start( "start_test_area_b"	 , ::start_test_area_b	 , undefined );
		
	maps\_load::main();
	maps\youngblood_audio::main();
	
	// jrote - Moved these scripts into a seperate script call so they can be called from Prologue
	youngblood_script_setup();
}

// jrote - I moved youngblood earthquake init into this script, so it can be called from Prologue
// Prologue won't run anything in youngblood::main
youngblood_earthquake_setup()
{
	add_earthquake( "small_long", 0.15, 10, 2048 );
	add_earthquake( "small_med", 0.15, 5, 2048 );
	add_earthquake( "small_short", 0.15, 1, 2048 );
	add_earthquake( "medium_medium", 0.25, 3, 2048 );
	add_earthquake( "large_short", 0.45, 1, 2048 );
}


// jrote - I moved youngblood script init into this script, so it can be called from Prologue
// Prologue won't run anything in youngblood::main
youngblood_script_setup()
{
	maps\_drone_deer::init();
	array_thread( getentarray( "move_trigger", "targetname" ), ::trigger_moveTo );
	array_thread( getentarray( "player_speed_trigger", "targetname" ), ::player_speed );
	level.player SetMoveSpeedScale(1);
	level thread deer_stampede_logic();
}

player_speed()
{
	while( true )
	{
		self waittill( "trigger", triggerer );
		
		spd = float(self.script_speed) * 0.01;
		
		level.player SetMoveSpeedScale( spd );
		
		while( triggerer isTouching( self ) )
			  wait( 0.05 );
			  
		level.player SetMoveSpeedScale(1);
		wait( 0.05 );
	}
}

deer_stampede_logic()
{
	flag_wait ( "deer_stampede" );
	
	exploder( "deer_stampede_a" );
	
	spawners = GetEntArray ( "deer_stampede_target", "targetname" );
	foreach ( spawner in spawners)
	{
				deer = maps\_drone_deer::deer_dronespawn( spawner );
				deer.drone_run_speed = 360;
	}
}


start_common()
{
//	level.player TakeAllWeapons();
//	level.player GiveWeapon( "noweapon_youngblood" );

	
}
	
start_test()
{
	start_common();
	set_start_positions( "start_test" );
}

start_test_area_a()
{
	start_common();
	set_start_positions( "start_test_area_a" );
}

start_test_area_b()
{
	start_common();
	set_start_positions( "start_test_area_b" );
}

start_deer()
{
	start_common();
	set_start_positions( "start_deer" );
	
	exploder( "deer_rumble_a" );
	
	spawners = GetEntArray ( "deer_hut_rumble_target", "targetname" );
	foreach ( spawner in spawners)
	{
				deer = maps\_drone_deer::deer_dronespawn( spawner );
				deer.drone_run_speed = 360;
				deer thread deer_rumble_movewait();
	}
	
	
}

deer_rumble_movewait()

{
	wait 1.75 ;
	self notify("move");
}


start_woods()
{
	start_common();
	set_start_positions( "start_woods" );
}

start_neighborhood()
{
	start_common();
	set_start_positions( "start_neighborhood" );
}

start_mansion_ext()
{
	start_common();
	set_start_positions( "start_mansion_ext" );
}

start_mansion()
{
	start_common();
	set_start_positions( "start_mansion" );
}

start_chaos_a()
{
	start_common();
	set_start_positions( "start_chaos_a" );
}

start_chaos_b()
{
	start_common();
	set_start_positions( "start_chaos_b" );
}