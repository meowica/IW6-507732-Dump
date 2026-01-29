#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	thread play_temp_music();
	thread slow_intro_alarms();
}

aud_check( ref )
{
	if ( ref == "slow_intro" )
	{
		//Set_Audio_Zone("intro_part1", 0);
	}
}

aud_intro_seq_lr()
{
	//Set_Audio_Zone("intro_part1", 0);
	wait( 0.3 );
	thread play_sound_in_space("scn_carr_intro_seq_lr", level.player.origin );
}

play_temp_music()
{
//	flag_wait( "heli_ride_music" );
//	music_play( "temp_heli_ride_music" );
//	flag_wait( "heli_ride_music_stop" );
//	music_stop( 4 );
	flag_wait( "victory_music" );
	music_play( "temp_carrier_music" );	//temp_victory_music
	flag_wait( "victory_music_stop" );
	music_stop( 4 );
}

slow_intro_alarms()
{
	flag_wait("slow_intro_alarms");
	slow_intro_alarm_array = GetEntArray( "slow_intro_alarm", "targetname" );
	foreach( alarm in slow_intro_alarm_array )
	{
		alarm thread sound_fade_in( "hangar_alarm", 1.0, 3.0, true );
	}	
	flag_waitopen("slow_intro_alarms");
	array_thread( slow_intro_alarm_array, ::sound_fade_and_delete, 2 );
}

tilt_odin_impact()
{
	level.player PlaySound( "carr_explosion_02" );
	level.player PlaySound( "carr_explosion_echo_01" );
}

tilt_helicopter_destroyed( object )
{
	//thread heli_destroyed_sweeteners();
	object thread play_sound_on_entity( "carr_heli_destroyed" );
	wait( 0.5 );
	object thread play_sound_on_entity( "carr_heli_debris_01" );
	wait( 0.2 );
	level.player PlaySound( "carr_heli_debris_02" );
	level.player PlaySound( "carr_explosion_lfe" );
	object thread play_sound_on_entity( "carr_heli_engine_explosion" );
	wait( 4.5 );
	object thread play_sound_on_tag( "carr_sliding_03", "b_body_back" );
	object thread play_sound_on_tag( "carr_sliding_04", "b_body_front" );
}
