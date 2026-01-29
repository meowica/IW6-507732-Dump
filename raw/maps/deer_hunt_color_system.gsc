#include maps\_utility;
#include common_scripts\utility;

/*-=-=-=-=-=-=
COLOR-TRIG / ENEMY GOAL VOLUME SYSTEM:

This system has enemies auto retreat when a friendly color trig is hit.
It also hits the color trig for you when X enemies are left in the current enemy volume. 
It supports the player moving up and hitting the trig as well. 
-=-=-=-=-=-=-*/

init_enemy_color_volumes()
{
	//Level must set level.color_trig_targetname_prefix = "color_line_"; //all trigs need an prefix + starting number( "color_line_1" )		
	level.current_enemy_vol = undefined;
	level.current_color_line  = 0;
	level.time_before_checking_enemy_count = 10;
	level.enemy_count_when_clear = 1;
	level.color_volume_enemies = [];
	
	//these can all be changed as needed
	level.color_trig_targetname_prefix = "color_line_";	
	level thread debug_color_system_hud();
	//update_debug_hud( level.hud2, level.current_color_line );
			
	trigs = getentarray(  "color_trig", "script_noteworthy" );
	array_thread ( trigs, ::color_trig_moves_enemies );

}	

color_trig_moves_enemies()
{
	//self = color trig		
	//Keeps track if its been hit by player/script. Doesnt move up enemies unnesasarily
	self ent_flag_init ("script_activated");
	self ent_flag_init ("player_activated");
		
	while(1)
	 { 
	 	self waittill( "trigger", who );
	 		 	
	 	//was trig hit from player, or through script? 	
	 	if( who == level.player )
	 	{
	 		//have we run this logic yet?
	 		if ( !self ent_flag( "player_activated" ) )
	 		{
	 			//print the fact that a color trig is being triggered 
	 			if(isdefined( self.targetname ) )
	 				msg = "player in color trig " +self.targetname;
	 			else
	 				msg = "Player in color trig with no targetname at: " +self.origin;
	 			color_debug_println( msg );
	 			
	 			//if the trig hasnt been activated through script already, increment level.current_color_line 
	 			if(!self ent_flag("script_activated") )
	 			{ 				
	 				self ent_flag_set("player_activated");
	 				level.current_color_line++;
	 				update_debug_hud( level.hud2, level.current_color_line);
	 				color_debug_println("Player hit color trig.");
	 			}
	 		}	
	 	}
	 		 		
	 	assertex( isdefined( self.target ), "Color trig at " +self.origin+ " has no volume targeted to it" );	 		
	 	if( isdefined( self.target ) )
	 	{ 	 						
	 		//level.current_enemy_vol isnt defined yet, create it for the first time
	 		if( !isdefined( level.current_enemy_vol ) )
	 		{	
	 			set_new_enemy_volume( self ); 	
	 			
	 			//only increment the color line if player hasnt hit the trig already
	 			if(!self ent_flag("player_activated") )
	 			{ 		 				
		 			self ent_flag_set ("script_activated");
		 			update_debug_hud( level.hud2, level.current_color_line);		 			
		 		}	
	 		}	
	 		//Make sure the the targeted volume isnt the current level.current_enemy_vol
	 		if( isdefined( level.current_enemy_vol.targetname ) &&  level.current_enemy_vol.targetname != self.target )
	 		{
	 			//if its not, set the new one 		
				set_new_enemy_volume( self ); 	 			
	 			//only increment the color line if the player hasnt hit the trig already
	 			if(!self ent_flag("player_activated") )
	 			{ 				 				
		 			self ent_flag_set ("script_activated");
		 			update_debug_hud( level.hud2, level.current_color_line);		
		 			color_debug_println("Script activated color trig.");
		 		}		 		
	 		}
	 		
	 	}
	 	self thread temp_trigger_off();	
	 	wait(1);
	 }		
}	


set_new_enemy_volume( friendly_color_trig )
{
	level notify ("new_volume");
	level.current_enemy_vol = getent( friendly_color_trig.target, "targetname" );	 			
	update_debug_hud (level.hud1, level.current_enemy_vol.targetname);	 				 		 	
 	level thread notify_baddies_to_retreat();
	level.current_enemy_vol thread enemy_volume_logic(); 	
}

temp_trigger_off()
{
	if( isdefined( self.targetname ) )
		msg = "Turning off trig " +self.targetname;
	else
		msg = "Turning off trig with no target name at: " +self.origin;
	
	color_debug_println( msg );
	
	self trigger_off();	 
	
	wait 30;
	
	if( isdefined( self.targetname ) )
		msg = "Restoring trig " +self.targetname;
	else
		msg = "Restoring trig with no target name at: " +self.origin;
	
	color_debug_println( msg );
	
	self trigger_on();		
}	


notify_baddies_to_retreat()
{
	//incrementally tell baddies to retreat so it looks like theyre covering each other
	level endon("new_volume");
	//baddies = getaiarray("axis");
	baddies = array_removeDead_or_dying( level.color_volume_enemies );
	if( baddies.size == 0)
		return;
	
	baddies = array_randomize( baddies );
	time = 1;
	first_guy = 0;
	//INCREMENTALLY TELLS BADDIES TO RETREAT. first guy provides covering fire
	foreach(guy in baddies)
	{
		if(isalive( guy ) )
		{
			wait( time );
			if(!first_guy)
			{
				if(!isdefined(guy.a.doinglongdeath)&& isalive(guy) )
				{
					guy thread first_guy_leap_frog_logic();
					first_guy = 1;
					continue;
				}	
			}
			guy notify ("go_to_new_volume");
		}			
	}		
}	

first_guy_leap_frog_logic()
{
	//self = enemy
	self endon("death");	
	self notify ("go_to_new_volume");	
	wait(.5); //time to get new node assigned
	self.ignoreme = true;
	self endon("go_to_new_volume");	
	half_way = undefined;
	my_goal = undefined;
	
	//store where the enemy is going to and get the halfway point
	if( isdefined( self.node ) )
	{
		half_way = distance(self.origin, self.node.origin) *.5;	
		my_goal = self.node.origin;
	}
	else if( isdefined( self.goalpos ) )	
	{
		half_way = distance(self.origin, self.goalpos) *.5;	
		my_goal = self.goalpos;
	}
	
	assertex( isdefined( half_way ), "Enemy has no goalnode or goalpos to calculate halfway point from" );	 		
	
	//wait for enemy to get to halfway point
	while( distance( self.origin, my_goal ) > half_way )
	{
		wait(.5);	
	}	
	
	//Clear his current goal
	self cleargoalvolume();	

	//stay put!
	self.goalradius = 200;
	//spot = self.origin +( 1, 1, 0 );
	self.old_fightdist = self.pathenemyfightdist;
	self.pathenemyfightdist = 8;
	self setgoalpos( self.origin );
	self allowedstances( "crouch", "prone" );
	//self thread Print3d_on_me( "Covering Fire!" );
	
	//camp for a bit
	wait( randomintrange( 8, 14 ) );
	
	//get back and go to the volume
	self.pathenemyfightdist = self.old_fightdist;
	self.ignoreme = false;
	self notify( "stop_print3d_on_ent" );
	self allowedstances("stand", "crouch", "prone" );
	self setgoalvolumeauto( level.current_enemy_vol );
}	

enemy_color_volume_logic()
{
	//run this on all enemies you want to use this sytem
	self endon( "death" );
	level.color_volume_enemies = add_to_array( level.color_volume_enemies, self );
	self.goalradius = 32;
	if(isdefined( level.current_enemy_vol ) )
	{
		self setgoalvolumeauto( level.current_enemy_vol );
	}	
		
	while(1)
	{
		self waittill ("go_to_new_volume");
		self allowedstances("stand", "crouch", "prone" );
		self setgoalvolumeauto( level.current_enemy_vol );
	}	
		
}	


enemy_volume_logic()
{		
	//checks for baddies in volume. Activated color trig when clear. 
	level endon( "new_volume" );	
	
	wait_for_at_least_one_enemy_to_spawn(); //dont want to check the current volume for baddy count until some more have spawned
	
	msg = "Waiting " + level.time_before_checking_enemy_count+ " secs before monitoring volume for baddies";
	color_debug_println( msg );
	
	wait( level.time_before_checking_enemy_count );
	guys = self get_ai_touching_volume( "axis" );
	msg	 = guys.size + " baddies in volume";
	color_debug_println( msg );
	
	color_debug_println("Monitoring Enemy count." );
	
	while( guys.size > level.enemy_count_when_clear )
	{
		wait(1);
		guys = self get_ai_touching_volume( "axis" );
		msg = guys.size +" baddies in volume";
		color_debug_println( msg );
	}
	
	//incremement the color line then hit the color trig
	level.current_color_line++;
	color_debug_println("One guy left, moving up friendlies" );
	
	if(!isdefined( getent( level.color_trig_targetname_prefix +level.current_color_line, "targetname" ) ) )
	{
		msg = "NO COLOR TRIG TO ACTIVATE ( " +level.color_trig_targetname_prefix +level.current_color_line +" )";
		color_debug_println( msg );
		return;
	}
		
	activate_trigger( level.color_trig_targetname_prefix +level.current_color_line, "targetname", level );
	update_debug_hud( level.hud2, level.current_color_line);
}	

wait_for_at_least_one_enemy_to_spawn()
{
	level endon( "new_volume" );	
	
	thread color_debug_println( "Waiting for at least one enmey to spawn" );
	
	while(1)
	{	
		current_axis = getaiarray("axis");
		wait .25;
		updated_axis = GetAIArray( "axis" );
		
		if( updated_axis.size > current_axis.size )
		{
			thread color_debug_println( "Am enemy spawned." );
			return;		
		}
	}
}

/*=-=-=-=-=-=-
 * Debug
  =-=-=-=-=-=-=*/

debug_color_system_hud()
{
/#
	while( !isdefined( level.current_enemy_vol ) )
		wait 1;
	
	while ( 1 )
	{
		wait( 1 );
		check_debug_hud_dvar();
	}
#/
}

color_debug_println( message )
{
/#	
	if( GetDvarInt( "steve", 1 ) )
	   IPrintLn( "    ^5" +message );	
#/	
}

check_debug_hud_dvar()
{
/#
	dvar = GetDvarInt( "steve" );
	if ( dvar > 0 )
	{
		create_color_debug_hud();
	}
	else if( dvar == 0 )
	{
		destroy_color_debug_hud();
	}
#/
}

create_color_debug_hud()
{
	/#
	if( isdefined( level.hud1 ) )
		level.hud1 destroy();
	
	x = 600;
	y = 100;
	size = 1.5;
	level.hud1 = newhudelem();
	level.hud1.x = x;
	level.hud1.y = y;
	level.hud1.alignX = "right";
	level.hud1.alignY = "middle";
	level.hud1.fontscale = size;
	level.hud1.label = "Current Enemy Vol:  ";
	
	if( isdefined( level.hud2 ) )
		level.hud2 destroy();
	
	level.hud2 = newhudelem();
	level.hud2.x = x;
	level.hud2.y = y + 15;
	level.hud2.alignX = "right";
	level.hud2.alignY = "middle";
	level.hud2.label = "Current color line :  ";
	level.hud2.fontscale = size;
	#/
}

update_debug_hud( hud_elem, the_string )
{
	/#
	if( isdefined( hud_elem ) )
	{
		hud_elem SetText( the_string );	
	}
	#/
}

destroy_color_debug_hud()
{
	/#
	if( isdefined( level.hud1 ) )
		level.hud1 Destroy();
	if( isdefined( level.hud2 ) )
		level.hud2 Destroy();
	#/	
}


/*-=-=-=-=-=-
END OF ENEMY COLOR VOLUME CODE
-=-=-=-=-=-=*/