#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	//temporarily commenting this out as it was causing an error
	//audio_set_initial_ambience();
}

audio_set_initial_ambience()
{
	wait 0.1;
	set_audio_zone("odin_intro");
	//SetDvarIfUninitialized( "music_enable", "1" );
	//if ( GetDvar( "music_enable" ) == "1" )
	//music_play("mus_odin_intro");
}

sfx_distant_explo( position )
{
	wait 0.3;
	position playsound( "odin_distant_explo" );
}

sfx_play_shuttle_crash()
{
	//level.player playsound( "scn_odin_pod_explosion" );
}

sfx_odin_decompress()
{
	level.player playsound( "scn_odin_decompression_lr_ss" );
}

sfx_odin_decompress_explode()
{
	level.airlockexplode = Spawn( "script_origin", ( -160, -3602, -65748 ) );
	level.airlockexplode playsound( "scn_odin_decompression_explode_ss" );
}