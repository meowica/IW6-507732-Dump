#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\deer_hunt_util;
#include maps\_vehicle;


jeep_ride_setup()
{
	
	flag_clear("introscreen_complete");
	//level.introScreen.lines = [ &"DEER_HUNT_JEEP_INTROLINE_1", &"DEER_HUNT_JEEP_INTROLINE_2", &"DEER_HUNT_JEEP_INTROLINE_3" ];
	//thread maps\_introscreen::introscreen(1, 5 );	
	thread fade_out_in( "black", "player_in_jeep" );
	clean_up();
	thread setup_gate_ai();
	
	delaythread( 6,  ::music_play, "mus_jeep_ride" );
	
	thread spawn_and_put_player_in_jeep();
	thread spawn_friendlies_and_put_in_jeep();
	thread scripted_vehicles();
	thread setup_house();
//	flag_wait_all("jeep_ai_spawned", "player_in_jeep", "friendlies_in_jeep" );
//	battlechatter_off( "allies" );
//	flavorbursts_off( "allies" );

	
}

clean_up()
{
	foreach( ai in getaiarray() )
		ai thorough_delete();	
}


thorough_delete()
{
	if( IsDefined( self.magic_bullet_shield ) )
		self stop_magic_bullet_shield();
	self notify( "deleted" );
	self notify( "death" );
	self delete();
}

spawn_and_put_player_in_jeep()
{	
	level.player DisableWeapons();
	level.player FreezeControls( true );
	
	if( GetDvarInt( "steve", 1 ) )
		vehicle = "matv";
	else
		vehicle = "jeep";
	
	level.jeep = spawn_vehicle_from_targetname( vehicle );
	level.jeep thread jeep_speed_control();
	
	level.player.linker = level.player spawn_tag_origin();
	linker = level.player.linker;
	
	player_tag = undefined;
	if( level.jeep.classname == "script_vehicle_matv" )
		player_tag = "tag_player";
	else
		player_tag = "tag_player2";//placeholder jeep
	
	
	linker.origin = level.jeep GetTagOrigin( player_tag );
	wait(.05);
	linker.angles = level.jeep GetTagAngles( player_tag );
	wait(.05);
	linker linkto( level.jeep );
	level.player SetOrigin( linker.origin );
	level.player SetPlayerAngles( linker.angles );

	level.player PlayerLinkTo( linker, "tag_origin", .9 );
	
	//flag_set("player_in_jeep");
	
	flag_wait("jeep_ai_spawned");
	
	level notify( "player_in_jeep" );	
	level.jeep gopath();
	level.player FreezeControls( false );
	level thread jeep_exit_logic();
	
}

spawn_friendlies_and_put_in_jeep()
{
	getent( "hesh", "targetname").count = 1;
	getent( "dog", "targetname").count = 1;
	
	level.hesh = spawn_targetname( "hesh", 1 );
	level.dog = spawn_targetname( "dog", 1 );	
	level.driver = spawn_targetname( "driver", 1 );

	level.squad = [level.hesh, level.dog, level.driver ];
	
	while(!IsDefined( level.jeep ) )
		wait .05;
	
	level.driver.script_startingposition = 0;
	level.jeep.dontunloadonend = true; //manually unload hesh. Driver stays. 
	level.hesh.script_startingposition = 1;
	
	level.jeep maps\_vehicle_aianim::guy_enter( level.hesh );
	level.jeep maps\_vehicle_aianim::guy_enter( level.driver );
	
	flag_set("friendlies_in_jeep");
	
	
	level.jeep waittill("reached_end_node");
	flag_set("jeep_arrived");
	level.jeep maps\_vehicle_aianim::guy_unload( level.hesh, 1 );
	
	spot = ( 26432.5, 8072.2, -145 );
	level.dog ForceTeleport( spot );
	wait .10;
	spot = drop_to_ground( spot );
		
	level.hesh thread hesh_navigation_logic();
	level.dog thread dog_navigation_logic();

	
}

hesh_navigation_logic()
{
	self.goalradius = 40;
	start_struct = getstruct( "hesh_house_start", "targetname" );
	self thread set_archetype( "creepwalk_archetype" );
	self follow_path_and_animate( start_struct, 350 );

}

dog_navigation_logic()
{	
	_goalradius = 80;	
	safedist = _goalradius * .75;
	self.goalradius = _goalradius;
	self.animname = "dog";
	self SetDogHandler( level.hesh );
	//self SetGoalEntity( level.hesh, 3000 );
	
	self set_dog_walk_anim();
	self set_run_anim( "sniff" );

	time = 4;
	
	while(1)
	{
		
		if( DistanceSquared( self.origin, level.hesh.origin ) > _goalradius*_goalradius )
		{
			self SetGoalEntity( level.hesh );
			
			while( DistanceSquared( self.origin, level.hesh.origin ) > safedist * safedist ) 
				wait .10;
			
			self setGoalPos( self.origin );
			
		}
		wait time;
	}
	
}

jeep_exit_logic()
{
	level.jeep waittill("reached_end_node");
	level.player_rig = spawn_anim_model( "player_rig", level.jeep.origin );
	level.player_rig.angles = level.jeep.angles;
	
	level.player unlink();
	level.jeep thread anim_single_solo( level.player_rig, "intro_jeep_exit_player", "tag_player2" );
	level.player PlayerLinkToBlend( level.player_rig, "tag_player", 0.6, 0.2, 0.4 );	
	
	level.jeep waittill( "intro_jeep_exit_player" );
	level.player_rig hide();
	level.player unlink();
	level.player_rig delete();
	
	//TODO: restore players last weapon in LA River ( this will happen automatically when the evens connect most likely)
	level.player EnableWeapons();
	
}

jeep_speed_control()
{
	self Vehicle_SetSpeed( 10, 10 );
	
}

setup_gate_ai()
{
	array_spawn_function_targetname( "patrol_jog_guys", ::patrol_jog_guys_logic );
	//TODO more anims to add civilian_ stuff from sniper proto
	
	gate_patrollers = array_spawn_targetname( "jeep_patroller", 1 );
	road_guys = array_spawn_targetname( "road_guys", 1 );
	patrol_jog_guys = array_spawn_targetname( "patrol_jog_guys", 1 );
	
	spawner = getent("gate_spawner", "targetname" );
	structs = getstructarray( "jeep_anims", "targetname" );
	
	spawn_ai_for_structs( spawner, structs );
	
//	spawner = getent("gate_civ", "targetname" );
//	structs = getstructarray( "civ", "targetname" );
//	
//	spawn_ai_for_structs( spawner, structs );
	
	flag_set("jeep_ai_spawned");
	thread custom_flavor_bursts();
}

spawn_ai_for_structs( spawner, structs )
{
	foreach( struct in structs )
	{
		anims = StrTok( struct.script_parameters, " " );
		if( !isdefined( struct.angles ) )
			struct.angles = (0,0,0);
		foreach( scene in anims )
		{
			spawner.count = 1;
			actor = spawner StalingradSpawn();
			wait(.05);
			actor thread play_anim_off_me( struct, scene );
		}	
	}
	
}

play_anim_off_me( ent, scene )
{
	if( isdefined( ent.script_noteworthy ) )
		if( ent.script_noteworthy == "gun_hide" ) 
			self gun_remove();

	//self set_battlechatter( true );
	//flag_wait( "introscreen_complete");
	self.animname = "generic";
	ent thread anim_single_solo( self, scene );
	
	if( isdefined( ent.script_delay ) ) //used to FastForward to a specific part of the anim
	{
		wait.05;
	   	time = ent.script_delay;
	   	self setAnimtime( getanim(scene), time );
	}
	
	//wait for anim to finish
	ent waittill( scene );
	
	//guys with targets should go to them
	if( !isdefined( self.target ) )	
	{
		self.goalradius = 32;
		self setgoalpos( self.origin );
		
	}

	
}

patrol_jog_guys_logic()
{
	self.animname = "generic";
	self set_run_anim( "patrol_jog" );
	struct = getstruct( self.target, "targetname" );
	
	self thread follow_path_and_animate( struct, 100000 );
	
}

custom_flavor_bursts()
{
	//ENDON!!!!!!
	//self = level
	MAX_FLAVORBURST_GUYS = 3;	
	MAX_FLAVORBURST_DIST = 800;
	
	while(!isdefined( level.squad ) )
		wait .05;
	
	battlechatter_off( "allies" );
	flavorbursts_off( "allies" );
	
	while(1)
	{
		guys = GetAIArray("allies" );
		close_guys = get_array_of_closest( level.player.origin, guys, level.squad, MAX_FLAVORBURST_GUYS, MAX_FLAVORBURST_DIST );
		array_thread( close_guys, ::custom_flavor_burst_on_me );
		
		wait( 6 );
			
	}
		
}
custom_flavor_burst_on_me()
{
	//self = dude playing sound
	self endon("death");
	
	if(!isdefined( level.custom_flavorburst_ents ) )
		level.custom_flavorburst_ents = [];
				  	
	wait( randomfloatrange( .5, 2 ) );
	
	if( isdefined( self.sound_ent ) )
		self.sound_ent notify("sounddone");	
	
	//taken from flavorburst system!
	nationality = self.voice;
	burstID = animscripts\battlechatter::getFlavorBurstID( self, nationality );
	aliases = animscripts\battlechatter::getFlavorBurstAliases( nationality, burstID );
	
	//self thread Print3d_on_me( "*" );
	//play the alias on the guy
	if( isdefined( aliases.size ) )
	{
		if( aliases.size > 0 )
		{
			self.sound_ent = spawn( "script_origin", self geteye() );
			self.sound_ent linkto( self );
			level.custom_flavorburst_ents = add_to_array( level.custom_flavorburst_ents, self.sound_ent );
			self.sound_ent thread delete_me_on_notifies( "sounddone" );
			self.sound_ent playsound( random( aliases ), "sounddone" );
		}
	}

}



scripted_vehicles()
{
	//trying to do as much vehicles as possible in radiant, here are the exceptions
	thread back_alley_humvee();

	
	
}

back_alley_humvee()
{
	spawner = getvehiclespawner( "back_alley_humvee" );
	level endon( "jeep_arrived" );
	while(1)
	{
		vehicle = spawner spawn_vehicle_and_gopath();
		wait( .05 );
		vehicle Vehicle_SetSpeed( randomintrange( 6, 12 ), 10, 5 );
		vehicle waittill("death");
		wait( randomintrange( 2, 4) );
	}
		
}

setup_house()
{
	//house ai and anims here
	
	
}