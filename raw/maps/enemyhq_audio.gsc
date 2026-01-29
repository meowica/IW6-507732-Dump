#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	aud_init_globals();
	aud_ignore_timescale();
}

aud_init_globals()
{
	
}

aud_ignore_timescale()
{
	SoundSetTimeScaleFactor( "norestrict2d", 0 );
	SoundSetTimeScaleFactor( "local3", 0 );
}

aud_truck_ext_idle_loop()
{
	ent = spawn( "script_origin", ( 2918, 7212, -420 ) );
	ent PlayLoopSound( "truck_ride_ext_idle_loop" );
	flag_wait( "FLAG_player_enter_truck" );
	wait(4.3);
	ent sound_fade_and_delete( 1.5 );
}

aud_enter_truck()
{
	level.player delayCall( 0.9, ::PlaySound, "truck_ride_open" );
	thread aud_truck_ride_idle();
		
	ent2 = Spawn( "script_origin", ( 2906, 7254, -385 ) );
	ent2 LinkTo( level.player );
	level.allies[1] PlaySound( "truck_ride_gear" );
	
	wait(2);
	ent = spawn( "script_origin", level.player.origin );
	ent LinkTo( level.player );
	ent PlaySound( "truck_ride", "sounddone" );
	ent waittill( "sounddone" );
	ent delete();
	
}

aud_truck_ride_idle()
{
	wait(3);
	ent = Spawn( "script_origin", level.player.origin );	
	ent LinkTo( level.player );
	ent SetVolume( 0 );
	ent PlayLoopSound( "truck_ride_idle_loop" );
	ent ScaleVolume( 1, 2 );
	ent ScaleVolume( 0, 4 );
	
	wait(8);
	ent StopLoopSound();
	
	waitframe();
	ent delete();
}

aud_blow_vehicle(ent)
{
	ent PlaySound("car_explode");
}

aud_bust_windshield()
{
	wait(0.6);
	level.player PlaySound("truck_glass_smash");
}

aud_bumpy_ride()
{
	wait(4.5);
	level.player PlaySound( "truck_ride_bumpy" );
}

aud_bust_thru()
{
	thread aud_end_truck();
	wait(2.3);
	level.player PlaySound("truck_ride_bust_thru");
}

aud_end_truck()
{
	wait(3);
	
	ent2 = spawn("script_origin", level.player.origin);
	ent2 LinkTo(level.player);
	
	ent2 SetVolume(0);
	ent2 PlayLoopSound("truck_ride_idle_loop");
	ent2 ScaleVolume(1, 4);
	
	flag_wait("FLAG_player_exit_truck");
	wait(1);
	ent2 ScaleVolume(0, 1);
	
	thread play_loopsound_in_space("truck_ride_ext_idle_loop", (8264, -3445, -285));
	
	wait(1);
	ent2 StopLoopSound();
	ent2 delete();
}
	
aud_timer()
{
	for (i = 0; i < 60; i++)
	{
		IPrintLnBold(i);
		wait(1);
	}
}