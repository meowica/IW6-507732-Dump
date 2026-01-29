#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{

}

audio_set_initial_ambience()
{
	wait 0.1;
	set_audio_zone ( "loki_intro" );
	//level.player SetClientTriggerAudioZone ( "loki_intro", 0.2 );
}	