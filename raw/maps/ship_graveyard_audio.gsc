#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	//do a startpoint check here to set the correct ambient
	//set_audio_zone( "ship_graveyard_abovewater" );
	level.player SetClientTriggerAudioZone( "ship_graveyard_abovewater", 0.1 );		
	thread start_overhead_waves();
}


start_overhead_waves()
{
	waitframe();
	flag_wait( "start_swim" );
	//set_audio_zone( "ship_graveyard_intro" );
	level.player ClearClientTriggerAudioZone(0.8);
	level.panfront = 1;
	self endon ("stop_waves");	
	wait (0.5);	
	//this while loop will spawn objects above the player and slowly move them, tracking with the player so that the waves sound like they are passing by overhead from one direction to another		
	while (1)
	{				
		thread start_individual_wave();
		if (level.panfront == 1)
			level.panfront = 0;
		else
			level.panfront = 1;					
		wait (6);
	}
	
	
}

start_individual_wave()	
{
		//spawn an object relative to the current player at 650 inches above 0
		
		//front one, then back one
		
		if (level.panfront == 1)
		{
			forwardness = randomintrange(350, 550);
			//iprintlnbold ("playing wave front");
		}
		else
		{
			forwardness = randomintrange(-600, -500);
			//iprintlnbold ("playing wave rear");
		}
		
		wavesound = Spawn( "script_origin", level.player.origin + (800, forwardness, (level.water_level_z - level.player.origin[2])) );		
		
		//play a sound on that object
		wavesound playsound ("elm_waves_pass_by");
		wavesound MoveTo( wavesound.origin + (-1600, 650 , 0 ), 13);		
		
		//move the object XY relative
		//wait 12 seconds
		wait (21);
		//stop the sound and kill the object			
		wavesound stopsounds();
		wavesound delete();
		//optional, not sure if needed - update the position of the wave in relation to the player's position - update every frame
		
}


stop_overhead_waves()
{	
	//this will stop the while loop from start_overhead_waves	
	level notify ("stop_waves");	
}

