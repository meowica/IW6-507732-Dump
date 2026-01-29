#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_audio;
#include maps\_audio_code;
#include maps\_audio_ambient;
#include maps\_vehicle;
#include maps\skyway_util;


main()
{
	play_rail_sfx();
	//train_rail_sfx_ents = getEntArray( "train_rail_sfx", "targetname" );
	//wait 0.1;
	//foreach( train_rail_sfx_ent in train_rail_sfx_ents )
	//	train_rail_sfx_ent PlaySound( "emt_skyway_train_rail" );
	
	// Ambient audio
	level.ambient_int = "skyway_train_int";
    level.ambient_ext = "skyway_train_ext";
	DelayThread( 0.1, ::trig_watcher, "skyway_amb", ::play_ambient_sfx_int, ::play_ambient_sfx_ext );

}

play_rail_sfx()
{
	level.train_rail_sfx_ents = [];
	train_rail_sfx_ents = getEntArray( "train_rail_sfx", "targetname" );
	foreach( train_rail_sfx_ent in train_rail_sfx_ents )
	{
		train_rail_sfx_ent PlayLoopSound( "emt_skyway_train_rail" );
	}
	
}

play_ambient_sfx_int()
{
	level.player SetClientTriggerAudioZone( level.ambient_int, 2 );
}

play_ambient_sfx_ext()
{
	level.player SetClientTriggerAudioZone( level.ambient_ext, 0.5 );
}
