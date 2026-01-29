#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

/*
 * Dog States:
 * 		ally_dog_guard_owner:	stays near their owner, attack nearby threats attaking our owner.
 * 		ally_dog_attack_free:	attack any enemies they are aware of- no restrictions on distances etc. Also failsafe state if owner dies.
 *		ally_dog_scripted:		pause any thinking whilst we run animations, stay in place etc.
 * 
 * 	

	// main init code- owner could potentially be an AI, though it would probably crash horiffically if you tried that right now.
	init_ally_dog( owner, dog, use_commands )

	//Clients need to init the dog_hud in their code- this the action slot icons etc. 0 starts with no icons active, 1 starts in guard mode.
	thread handle_dog_hud( 0 );

	//If clients want the picture in picture display, they need to call:
	pip_init();
	
	the csv also needs these hud icons, fx etc.-
	material,hud_dog_attack_active
	material,hud_dog_attack_inactive
	material,hud_dog_guard_active
	material,hud_dog_guard_inactive
	fx,misc/ui_flagbase_gold
	fx,misc/ui_a10_green_line_short
	sound,animal_dog,<YOUR_LEVEL_NAME>,all_sp
	
	
	//Need to precache:
	precacheShader( "hud_dog_attack_inactive" );
	precacheShader( "hud_dog_attack_active" );
	precacheShader( "hud_dog_guard_inactive" );
	precacheShader( "hud_dog_guard_active" );
	
	To take advantage of the dog's automatic reaction to volumes, the client must call:
	
	watch_active_zones( owner, zone_names ) // where zone_names is the targetname of all your volumes.

	Volume Settings:
	===============
	
	Volumes can become active either by the dog touching them, or the player pointing into them and sending the dog- by default volumes respond to either one.
	To limit how they become active set:
		
		script_parameters- "dog_touch" or "dog_aim" to make them only react to that type of event.
		
	To set the type of volume, use:
	
		script_noteworthy:	"dog_point" - goes the node targetted by the volume, and has him point in the direction of the node.
							"dog_point_sniff" 	- same as dog_point, but sniffs his way to the node
							"dog_path"  - follows the path of nodes targetted by the volume. Uses the same logic when guys spawn in on a path
										  so you can script_flag_wait, script_delay, script_flag_set etc. along the path. Waits at the end of the path
							"dog_path_sniff"	- same as dog_path, but sniffs when moving
										  
	Dog Marker settings: When the player points into a volume, you will get a marker either at the script struct that matches script_linkto / linkname, or the volumes target.



Utility functions for the Dog
=============================

// Make it so the dog won't receive command input, such as during a scripted sequence
lock_player_control()

// Allow the dog to receive command input again, such as after a scripted sequence
unlock_player_control()

//only owner is required- the sound defaults to a bark.
dog_force_talk( owner, sound, wait_if_blocked )

(These are in _utility.gsc)
//make him run.
clear_run_anim()
//make him walk
set_dog_walk_anim()







Controlling the Dog in script
=============================

To force the dog to attack a particular target:
	
	Set     level.override_dog_enemy        equal to the entity you want him to attack- this overrides getting the location from where the player is looking
	
	Then you can either wait for the player to hit the attack button (an actionslot dpad action)    
	
	or you can send the dog to attack straight away using one of two priorities:

		If he must do the action regardless of any commands the player has given him, use:
			level.player notify( "dog_attack_override" );
		
		If you only want him to follow the scripted action if the player isn't directly controlling him, use:	
			level.player notify( "dog_attack" );

To script normal actions on the dog and pause any of this logic:

	Call set_dog_scripted_mode( owner );
	
	To cancel scripted mode, either set him to a new mode or dog notify( "dog_scripted_end" );
	



To call the dog back to heel for guard mode, you can:

		level.player notify( "dog_guard_me" );
						or
		set_dog_guard_owner( owner );
		
To have the dog move to a specific location and point in a direction:

	Get the node you want to send him to (it will need a direction on it in the map), and assign it to level.dog_guard_override:
	
		level.dog_guard_override = GetNode( "dog_point_ambush", "targetname" );
		
	Tell the dog (via its owner) that it needs to go to a pointing state
	
		level.player notify( "dog_guard_owner_pointing" );
		
		
	And if you want to know when the dog has arrived, use this:
	
		level.player_dog waittill( "pointing_at_target" );
		
	NOTE: YOU MUST CLEAR OUT "dog.force_dog_look_point" , which is the dog's version of level.dog_guard_override, WHEN YOU ARE DONE WITH IT.
	
		** OR ** you can set these two values, and they will be cleaned up when the dog stops guarding.

		DOG.clear_override_node = true;
		DOG.clear_this_node = same_node_that_you_set_level_dog_guard_override_to ; // Makes sure we don't clear someone else / a different override.


	
 *  
 * 
 * 
 * 
 */

pip_init()
{
	level.pip = level.player newpip();
	level.pip.enable = 0;
}

// temporary hack function until Simon adds new sniff pathing stuff
GOAL_RADIUS_ATTACK_DOG = 64;
ally_dog_sniff_mode(active)
{
	self.sniff_mode = active;
}

ally_dog_bark_not_growl(active)
{
	if (isDefined(active) && active)
	{
		self.script_bark_not_growl = active;
	}
	else
	{
		self.script_bark_not_growl = undefined;
	}
}


init_ally_dog( owner, dog, use_commands, use_pip )
{
	flag_init( "dog_no_draw_locator" );
	flag_init( "dog_forever" );
	flag_init( "pip_lockout" );
	flag_init( "dog_active_zone");
	flag_init( "dog_control_lockout");
/*
	// Dog FX
	level._effect[ "cairo_pointer" ] 								= loadfx( "misc/ui_flagbase_gold" );
	level._effect[ "cairo_point_3" ] 								= loadfx( "misc/ui_dog_goto" );
	level._effect[ "dog_bite" ][1]									= loadfx( "misc/blood_head_kick" );
	level._effect[ "dog_bite" ][2]									= loadfx( "misc/blood_hyena_bite" );
	level._effect[ "dog_bite" ][4]									= loadfx( "misc/blood_throat_stab" );
		*/
	dog.goalradius = 64;
	dog.goalheight = 128;
	dog.pathenemyfightdist = 0;
//	dog.fixednode = true;
//	dog SetDogHandler(level.player);
	dog SetDogAttackRadius(128);


	
	if( !IsDefined( level.ally_dogs ) )
	{
		level.ally_dogs = [];
	}

	level.ally_dogs[ level.ally_dogs.size ] = dog;
	dog.ally_dog_guardpoint_radius = 64;
	
	
//	dog magic_bullet_shield();
	
	if( IsDefined( use_pip ) )
		dog.use_pip = use_pip;	
	else
		dog.use_pip = false;	
	
	dog.pip_active = false;

	dog.ally_owner = owner;
	dog.team = owner.team;
	dog.ally_current_state = ::ally_dog_guard_owner ;
	dog.ally_new_state = ::ally_dog_guard_owner ;
	dog.meleeAlwaysWin = true;
	dog.ignoresuppression = true;
	dog.suppressionwait = 0;
	dog.pitch_changed = 0;
	dog.active_force_dog_talk = false;
	dog.guard_goal_radius = 128;
	dog.guard_nodes = [];
	dog thread monitor_guard_nodes( owner );	
	//dog thread dog_manage_damage(  owner );
	level.last_dog_attack = 0;
	dog.clear_override_node = false;
	dog.clear_this_node = undefined ;
	dog.disableBulletWhizbyReaction = true;
    dog.nododgemove = true;
    dog.dontavoidplayer = true;
    dog.return_fail_los = false;
    dog.laser_active = false;
    dog.dog_marker = spawn_tag_origin();
    
    dog ent_flag_init( "watch_los_to_owner" );
	dog ent_flag_set( "watch_los_to_owner" );
	dog.curr_interruption = "inactive";
	
	if( IsDefined( use_commands ) && use_commands )
	{
		dog thread ally_listen_dog_commands( owner );
//		dog thread watch_view_dogcam_fullscreen(owner);

	}
	
	
	
	
	if( !IsDefined( level.ally_dog_guardpoint_radius ) )
		level.ally_dog_guardpoint_radius = 512;
	if( !IsDefined( level.ally_dog_search_radius ) )
		level.ally_dog_search_radius = 256;
	level.dog_active_zones = [];

	thread handle_dog_hud( 1 );

	dog.debug_spew = false;
/#
	if ( !IsDefined( dog.debug_spew ) )
		dog.debug_spew = false;
	
	dog thread handle_dog_debug_spew();
#/		
	dog thread ally_dog_think( owner );
}
set_dog_arrow( location, ent )
{
	if(isdefined(level.aim_arrow))
	{
		StopFXOnTag( getfx( "target_marker_yellow" ), level.aim_arrow, "tag_origin" );
		StopFXOnTag( getfx( "target_marker_red" ), level.aim_arrow, "tag_origin" );
		level notify( "kill_dog_arrow_wait" ); // only one wait active at a time.
		wait 0.05;
	}
	else	/* CREATE aim_arrow fx */
	{
		level.aim_arrow = Spawn( "script_model", location );
		level.aim_arrow SetModel( "tag_origin" );
	}

	
	if( flag( "dog_no_draw_locator" ) )
	{
		return;
	}
	
	level.aim_arrow.origin=location;
	
	if( IsDefined( ent ) )
	{
		level.aim_arrow linkTo( ent, "tag_origin", (0,0,0), (-90,0,-90) );
		wait( 0.05 );
		PlayFXOnTag( getfx( "target_marker_red" ), level.aim_arrow, "tag_origin" );
	}
	else
	{
		level.aim_arrow.origin= location;
		level.aim_arrow.angles = (-90,0,-90);
		wait( 0.05 );
 		PlayFXOnTag( getfx( "target_marker_yellow" ), level.aim_arrow, "tag_origin" );

	}
	
	level timed_remove_arrow( 10, ent );
	if( isdefined( level.aim_arrow ) )
	{
		level.aim_arrow Unlink();
		StopFXOnTag( getfx( "target_marker_yellow" ), level.aim_arrow, "tag_origin" );
		StopFXOnTag( getfx( "target_marker_red" ), level.aim_arrow, "tag_origin" );

	}

}

timed_remove_arrow( seconds, ent )
{
	level notify( "kill_dog_arrow_wait" ); // only one wait active at a time.
	level endon( "kill_dog_arrow_wait" );
	
	if( IsDefined( ent ) )
	{
		ent waittill( "death" );
	}
	else
	{
		wait seconds;
	}
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//		Handle listening for and giving the dog commands.
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//self is the dog.
ally_listen_dog_commands( owner )
{
	self endon( "death" );
	
	self nothread_listen_dog_commands( owner );
	// if our owner dies, or we want to stop taking commands, this ensures that the dog will still attack enemies etc. Might want to make it guard its dead owner instead?
	self.ally_current_state = ::ally_dog_attack_free ;
	self notify( "ally_dog_state_change" );
	
}
nothread_listen_dog_commands( owner )
{
	owner endon( "death" );
	self endon( "stop_watching_dog_commands" );
	self endon( "death" );
	
	// Regular dog commands.
//	owner notifyOnPlayerCommand( "dog_guard_me", "+actionslot 2" );
	owner notifyOnPlayerCommand( "fired_laser", "+frag" );
//	owner notifyOnPlayerCommand( "dog_attack_laser", "+actionslot 1" );

	self thread watch_guard_me( owner );
	self thread watch_attack( owner );
	self thread watch_laser( owner );

	
	

	//Main message pump, listing out for change state messages sent by the threads created above.	
	
	while( 1 )
	{
		owner waittill( "ally_dog_check_new_state" );
		
		if( self.clear_override_node )
		{
			self.clear_override_node = false;
			if(IsDefined( self.clear_this_node ) && IsDefined( self.force_dog_look_point ) && self.clear_this_node == self.force_dog_look_point  )
				self.force_dog_look_point  = undefined;
		}

		
		self.ally_current_state = self.ally_new_state;
		self notify( "ally_dog_state_change" );
	}
	
}




watch_guard_me( owner )
{
	owner endon( "death" );
	self endon( "stop_watching_dog_commands" );
	self endon( "death" );
	
	while(1)
	{
		owner waittill( "dog_guard_me" );
		//		//IPrintLnBold( "dpad dog_guard_me" );
		self.ally_new_state = ::ally_dog_guard_owner ;
		owner notify( "ally_dog_check_new_state" );
		wait 1;
	}
}
	
watch_laser( owner )
{
	while( 1 )
	{
		owner waittill( "fired_laser" );
		if(	!flag( "dog_control_lockout" ) )
		{
				
			owner notify( "dog_attack_command" );
		}
	}
}
	
notify_on_designate( owner )
{
	owner endon( "cancel_designate" );
	owner waittill( "fired_laser" );
	owner notify( "dog_attack_command" );
	
	//Turn us off now.
	owner notify( "dog_attack_laser" );
	
}
	
watch_attack( owner )
{
	owner endon( "death" );
	self endon( "stop_watching_dog_commands" );
	self endon( "death" );

	while(1)
	{
		command = owner waittill_any_return( "dog_attack", "dog_attack_command", "dog_attack_override" );

		//figure out if this attack should really be allowed to pass through.
		allow_attack = false;
		if(command == "dog_attack_override" )
			allow_attack = true;
		else if(command == "dog_attack_command" && owner.dog_hud_visible[ 0 ] && (!flag( "dog_control_lockout" ) ) )
			allow_attack = true;
		else if( self.ally_current_state != ::ally_dog_attack_free )
			allow_attack = true;
			
		if( allow_attack )
		{
			self setup_colors_for_attack();
			self.ally_new_state = ::ally_dog_attack_free ;
			if(IsDefined( level.pip_watch_flag ) )
				flag_set( level.pip_watch_flag );
			level.last_dog_attack = GetTime();
						
			owner set_dog_hud_attack();
			owner notify( "ally_dog_check_new_state" );
			wait 1;
		}

	}
	
}
	
	

ally_dog_think( owner )
{
	self endon( "death" );
	//func = self.ally_current_state;
	while( 1 )
	{
		self dispatch_dog_think( owner );
		wait 0.1;
	}
	
}



/* /////////////////////////////////////////////////////////////////////////////////////////////
 * 
 * 
 * 
 * 
 * 
 *			 the states that the dog can be in- basically function pointers.
 * 
 * 
 * 
 * 
 ///////////////////////////////////////////////////////////////////////////////////////////// */


// Done as a separate function so that every state think function doesn't have to remember the end on conditions
dispatch_dog_think( owner )
{
	// Make sure that any previously running thinks get terminated.
	self notify( "new_dispatch_dog_think" );
	self endon( "new_dispatch_dog_think" );
	
	self endon( "ally_dog_state_change" );
	[[ self.ally_current_state]] ( owner);
}




// analagous to the player pressing the dpad in the guard direction.
set_dog_guard_owner( owner )
{

		self.ally_new_state = ::ally_dog_guard_owner ;
		owner notify( "ally_dog_check_new_state" );
		owner set_dog_hud_guard();
		if(IsDefined( level.pip_watch_flag ) )
			flag_clear( level.pip_watch_flag );
}

set_dog_scripted_mode( owner )
{

		self.ally_new_state = ::ally_dog_scripted ;
		owner notify( "ally_dog_check_new_state" );
}

dog_using_colors()
{
	return ( isdefined( self.script_forcecolor ) || isdefined( self.script_old_forcecolor ) );
}

setup_colors_for_attack()
{
	on_color_system = dog_using_colors();
	if ( on_color_system  && isdefined( self.script_forcecolor ) )
	{
		self.script_old_forcecolor = self.script_forcecolor;
		self disable_ai_color();
	}
	return on_color_system;
}
reset_colors_start_guard()
{
	on_color_system = dog_using_colors();
	if ( on_color_system && isdefined( self.script_old_forcecolor ) )
	{
		self enable_ai_color();
		self.script_old_forcecolor = undefined;
		self.old_path = undefined;
	} 
	return on_color_system;
}

watch_color_change_on_guard(owner)
{
	self notify( "end_watch_color_guard");
	self endon( "end_watch_color_guard");
	self waittill("done_setting_new_color");
//	IPrintLnBold("watch_color_change_on_guard GOT ENABLECOLOR");
	set_dog_guard_owner( owner ); //force the dog through to restart guarding, so it will latch as dog is now on color.
	
}

monitor_guard_nodes( owner )
{
	self endon( "death");
	owner endon( "death");	

	//try and get at least one good node to start with.
	nodes = GetNodesInRadiusSorted( self.origin, 256, 0, 72, "Path" );
	if( nodes.size > 0 )
	{
		self.guard_nodes[ 0 ] = nodes [ 0 ];
		self.guard_nodes[ 1 ] = nodes [ 0 ];
	}
	self.dog_node = 0;
	self.dog_go_to = self.dog_node;
	
	while( 1 )
	{
		
	
		
		nodes = GetNodesInRadiusSorted( owner.origin, 256, 0, 64, "Path" );
		if( nodes.size > 0 && self.guard_nodes[ self.dog_node ] != nodes[ 0 ] )
		{
			self.dog_go_to = self.dog_node;// make sure that the dog is always going to one node behind the player.
			self.dog_node++;
			if( self.dog_node > 1 )
				self.dog_node = 0;
			self.guard_nodes[ self.dog_node ] = nodes [ 0 ];
			//debug_cross( (nodes [ 0 ].origin + (0,0,50 ) ), 200, (1,1,1) );
		}
		
		
		
		if(dog_using_colors())
			wait 3;
		else 
			wait 0.1;
	}
	
}


ally_dog_scripted( owner )
{
	self.goalradius = GOAL_RADIUS_ATTACK_DOG;
	self waittill( "dog_scripted_end" );
	set_dog_guard_owner( owner );
}

//stays near their owner, attack nearby threats attacking our owner.

//dog_using_colors
//don't guard if using colors.


ally_dog_guard_owner( owner)
{

// if we are doing colors, gracefully handle colors being disabled by allowing this wait to fall through 
// note, by  the time a dog state like tries to disable colors, this thread will be long dead.
	if( self reset_colors_start_guard() )
	{
		while( IsDefined(self.script_forcecolor))
		{
			self waittill( "stop_color_move" );
		}
//		IPrintLnBold("guard got a stop color move.");
	}
	self childthread watch_color_change_on_guard(owner);
	self ClearEnemy();

	self.goalradius = self.guard_goal_radius;
	self set_goal_node( self.guard_nodes[ self.dog_go_to ] );
	last_node = self.guard_nodes[ self.dog_go_to ];
	wait 1;
	changed_goal = false;
	
	too_far_away = 0;
	
	while( 1 )
	{
		enemies = self get_dog_enemies( owner );
		
		//If there are any enemies nearby the player, attack them as a priority.
		best_target = undefined;
		//clump = get_within_range( owner.origin, enemies, 1024 );
		clump = get_array_of_closest( owner.origin, enemies, undefined, undefined, 1024 );

		marked_target = undefined;
		
		//Whizz through the array looking for marked targets.
		
		for( i = 0; i < clump.size; i++ )
		{
			closest = clump[ i ];
			
			if( IsDefined( closest.script_noteworthy ) && closest.script_noteworthy == "good_dog_target" )
			{
				marked_target = closest;
				break;
			}
		}

		
		
		for( i = 0; i < clump.size; i++ )
		{
			closest = clump[ i ];
					
			dist = Length( (closest.origin - owner.origin ));
			
			attacking_player = ( IsDefined( closest.enemy ) &&  closest.enemy == owner && dist < 600 );
			best_enemy = ( IsDefined( closest.enemy ) &&  closest.enemy == owner && dist < 400 );
			last_stand = (closest.a.special == "dying_crawl" );
			marked =  ( IsDefined( closest.script_noteworthy ) && closest.script_noteworthy == "good_dog_target" );
			
			if( best_enemy || last_stand || attacking_player || marked )
			{
				//Don't go after this enemy if he is fairly far away, and he has lots of other enemies near him.
				if( dist < 250 || self check_enemy_clump( owner, closest ) )
				{
					// Make sure we aren't choosing this guy over someone that has marked above.
					if( IsDefined( marked_target ) && marked_target != closest )
					{
						//so now we have a good close to the player target, AND a marked target- choose between them.
						marked_dist = Length( marked_target.origin - owner.origin );
						if( dist > 250 && ( dist / marked_dist ) > 0.7 )
						{
							//Choose the marked target instead.
							closest = marked_dist;
						}
					}
					best_target = closest;
					if( best_target.a.special == "dying_crawl" )
						self.goalradius = 75;
					else
						self.goalradius = GOAL_RADIUS_ATTACK_DOG;
	/#	
					if( IsDefined( marked_target ) && marked_target == closest )
						self.debug_string = "Choosing marked target (guard player) " ;
					if( last_stand )
						self.debug_string = "Found enemy in last stand (guard player) " + dist;
					else if( attacking_player )
						self.debug_string = "Found enemy with player as its target(guard player) " + dist;
					else if( best_enemy )
						self.debug_string = "Found enemy nearby player.(guard player) " + dist;
	#/				
				break; 
				}
			}
				
		}
		// if no one is near the player, is anyone near the dog?
		if ( !IsDefined( best_target ) )
		{
			clump = get_within_range( self.origin, enemies, 300 );
			if( clump.size > 0 )
			{
				best_target = clump[ 0 ];
				if( best_target.a.special == "dying_crawl" )
					self.goalradius = 75;
				else
					self.goalradius = GOAL_RADIUS_ATTACK_DOG;
				
/#				
				self.debug_string = "Found enemy nearby dog.(guard player)";
#/				

			}
		}
		
		if ( IsDefined( best_target ) )
		{
			self.ignoreall = false;
			self clear_run_anim();
			self SetGoalEntity( best_target );
			best_target notify( "dog_has_ai_as_goal" );
//			self.enemy = best_target;
			no_enemy_time = 0;
		}

		if( IsDefined ( best_target ) )
		{
			monitor_dog_enemy( best_target );
			
			continue; // see if there are other enemies I need to be more interested in rather continuing on to the guard code.
		}

		self.goalradius = self.guard_goal_radius;
		
		if( self.ignoreall )
		{
			dist_owner = LengthSquared( (self.origin - self.guard_nodes[ self.dog_go_to ].origin) );
			if( dist_owner < 65536 )
				self.ignoreall = false;
		}
		if( ! self WithinApproxPathDist( 350 ) )
		{
			too_far_away = GetTime() + 2000;
			self clear_run_anim();
			
			////IPrintLnBold( "WithinApproxPathDist TOO FAR." );
		}
		if(	too_far_away < GetTime() )
		{
			if( IsAlive( self.enemy ) )
				self clear_run_anim();
			else
				self set_dog_walk_anim();
		}
		if( last_node != self.guard_nodes[ self.dog_go_to ] )
		{
			self set_goal_node( self.guard_nodes[ self.dog_go_to ] );
			last_node = self.guard_nodes[ self.dog_go_to ] ;
		}
			
	
		wait 0.1;
	}
	
	
}

check_enemy_clump( owner, enemy_center ) 
{
	enemies = self get_dog_enemies( owner );
	
	clump = get_within_range( enemy_center.origin, enemies, 350 );
	
	//There will always be at least 1 guy in the array- enemy_center
	
	
	if(clump.size >= 3 )
	{
		return false;
	}
	return true;
}



//attack any enemies they are aware of- no restrictions on distances etc. Also failsafe state if owner dies.
ally_dog_attack_free( owner )
{
	
	self endon( "new_attack_started" );
	self clear_run_anim();

	trace = self get_owner_pointing_info( owner, true, true );
	
	//This means we hit a volume, and are off processing that instead.
	if(!IsDefined( trace ) )
		self waittill( "forever" ); // let this get terminated by the endons.

	
	closest = undefined;
	do_arrow = true;
	if( IsDefined( level.override_dog_enemy ) )
	{
		trace[ "enemy" ] = level.override_dog_enemy;
		level.override_dog_enemy = undefined;
		do_arrow = false;
		
	}
	if( !IsDefined( trace[ "enemy" ] ) )
	{
		if( !IsDefined( trace[ "node" ] ) )
		{
			self set_dog_guard_owner( owner );
			
//				//IPrintLnBold( "No nearby enemies OR nodes- returning to guard" );
			wait 4; //make sure we don't run any other logic before we can be changed over to a guard node.
			return;
		}
		self.goalradius = 32; // don't want to aggro on anyone, just get to the nearby node.
		node = trace[ "node" ];
		self SetGoalPos( node.origin );
		if( do_arrow )
		{
			arrow_pos = ( trace[ "position" ][0],trace[ "position" ][1], node.origin[2]);
			thread set_dog_arrow( arrow_pos);
		}
		if( do_arrow )
			self wait_for_notify_or_timeout( "goal", 10 );
		self.goalradius = 512;
	}
	else 
	{
		closest = trace[ "enemy" ];
		closest notify( "dog_has_ai_as_goal" );

		//
		self.goalradius = GOAL_RADIUS_ATTACK_DOG;
		self SetGoalEntity( closest );
		if( do_arrow )
		{
			arrow_pos = ( trace[ "position" ][0],trace[ "position" ][1], closest.origin[2]);
			thread set_dog_arrow( closest.origin,closest);
			//thread set_dog_arrow( trace[ "position" ] );
			//thread set_dog_arrow( closest.origin );

		}
		if( IsDefined( closest.ignoreme ) && closest.ignoreme )
		{
			closest set_ignoreme( false );
		}

		monitor_dog_enemy( closest );
		
//		self wait_for_notify_or_timeout( "goal", 10 );
//		self.goalradius = 512;
	}
	
	self set_dog_guard_owner( owner );
}

// watch the dogs enemy so that if it dies whilst Cairo is on the way, he'll still go there and check the dude out.

monitor_dog_enemy( target )
{
	target_pos = target.origin;
	starttime = GetTime();
//	IPrintLnBold( "monitoring for dead enemy at " + (starttime/1000) );
	while( IsAlive( target ) )
	{
		tot_time = (GetTime() - starttime);
		
//		if( tot_time >10000)
//			IPrintLnBold( "monitoring for dead enemy for " + (tot_time/1000) );
		
		wait 0.2;
	}
	tot_time = (GetTime() - starttime)/1000;
	//IPrintLnBold( "Enemy died after " + tot_time );
	


}

volume_holding_state( owner )
{
		flag_wait( "dog_forever" );
}

//done like this in case we ever want it to work in mp etc.
get_dog_enemies( owner )
{
	enemies = GetAIArray( "axis" );
	return enemies;
	
}

get_owner_pointing_info( owner, include_node, include_enemy )
{
	MAX_SEND = 1536;
	start = owner GetEye();
	angles = owner GetPlayerAngles();
	looking = AnglesToForward( angles );
	end = start + ( looking * (MAX_SEND +128));
	trace = BulletTrace( start, end , true , owner );
	trace_ent = undefined;
	endpos = 	trace[ "position" ];
	
	//Early bail if distance is miles away.
	if( LengthSquared( start - endpos) > (MAX_SEND*MAX_SEND) )
	{
		trace[ "entity" ] = undefined;
		return trace;
	}
	
	zone = self check_against_active_zones( start, endpos );
	if( IsDefined( zone ) )
	{
		return undefined;
	}
	
	if( include_node )
	{
		nodes = GetNodesInRadiusSorted( endpos, 128, 0, 72 );
		if( nodes.size > 0 )
		{
			trace[ "node" ] = nodes[0];
			nendpos = nodes[0].origin;
//			Line( nendpos - (32,0,0), nendpos + (32,0,0), (1,0,0), 1, 0, 10 );
//			Line( nendpos - (0,32,0), nendpos + (0,32,0), (1,0,0), 1, 0, 10 );
		}
	}
	if( include_enemy )
	{
	
		if( isdefined( trace[ "entity" ] ) )
		{
			trace_ent = trace[ "entity" ];
			if( IsSentient( trace_ent ) && IsEnemyTeam( trace_ent.team, self.team ) )
			{
				trace[ "enemy" ] = trace_ent;
//				IPrintLnBold(" trace hit sentient AI" + trace_ent.classname );
			}
		}
		else
		{
			enemy = get_enemy_from_active_zone( start, endpos );
			if( IsDefined( enemy ) )
			{
				trace[ "enemy" ] = enemy;
//				IPrintLnBold(" found enemy in active zone: " + enemy.classname );
			}
			else
			{
				clump = get_dog_enemies( owner );
				enemy = get_closest_living( endpos, clump, 256 );
				if( IsDefined( enemy ) )
				{
					trace[ "enemy" ] = enemy;
//					IPrintLnBold(" picking nearest enemy: " + enemy.classname );
				}
			}
		}
		if( IsDefined( trace[ "enemy" ] ) )
		{
			enemy = trace[ "enemy" ];
			nendpos = enemy.origin;
//			Line( nendpos - (32,0,0), nendpos + (32,0,0), (1,0,0), 1, 0, 10 );
//			Line( nendpos - (0,32,0), nendpos + (0,32,0), (1,0,0), 1, 0, 10 );
		}
	}
	
//	Line( start - (0,0,28), endpos, (1,1,1), 1, 0, 10 );
	
//	Line( endpos - (64,0,0), endpos + (64,0,0), (1,1,1), 1, 0, 10 );
//	Line( endpos - (0,64,0), endpos + (0,64,0), (1,1,1), 1, 0, 10 );

	return trace;
}

dog_force_talk( owner, sound, wait_if_blocked )
{
	if( !IsDefined( wait_if_blocked ))
		wait_if_blocked = false;

	if(	self.active_force_dog_talk == true ) 	// Holding area for dog talk requests, if one is already running.
	{
		if( !wait_if_blocked )
			return;
	
		self waittill( "force_dog_talk_continue" );
		if(	self.active_force_dog_talk == true ) // this is to catch the case where multiple force talks are stacked, to make sure only the next one waiting will get activated.
			return;		

	}
	
	if( !IsDefined( sound ) )
		sound = "anml_dog_bark";
		
	self.active_force_dog_talk = true;
	//self thread animscripts\dog\dog_move::dogPlaySoundAndNotify( sound, "force_dog_talk" );
	self waittill( "force_dog_talk" );
	self.active_force_dog_talk = false;
	self notify( "force_dog_talk_continue" ); // makes sure that if multiple sounds are stacked, only one will get through and we won't get a cacophony.
		
}



//Debug only functions.
/#

notify_watcher( notify_watch )
{
	while( 1 )
	{
		self waittill( notify_watch );
		IPrintLnBold( "GOT "+ notify_watch + " for " + self.animname);
	}
}
	
notify_watchers()
{
	thread notify_watcher( "new_dispatch_dog_think" );
	thread notify_watcher( "ally_dog_state_change" );
	thread notify_watcher( "new_attack_started" );
}
	
	
handle_dog_debug_spew()
{
	rad = self.goalradius;
	enemy = undefined;

	if ( self.debug_spew )
		thread notify_watchers();

	
	while ( 1 )
	{
		if ( !self.debug_spew )
		{
			wait 1;
			continue;
		}
		
		
		if ( IsDefined ( self.debug_string ) )
		{
			IPrintLn ( self.debug_string );
			self.debug_string = undefined;
		}
		wait 0.05;
		
		op = " ";
		do_op = false;
		diff = false;
		if( IsDefined( enemy ) && !IsDefined( self.enemy ) )
			diff = true;
		else if( !IsDefined( enemy ) && IsDefined( self.enemy ) )
			diff = true;
		else if( !IsDefined( enemy ) && !IsDefined( self.enemy ) )
			diff = false;
		else if( enemy != self.enemy )
			diff = true;
		if( diff )
		{	
			if( IsDefined( enemy ) )
				op += "Enemy was " + enemy.classname;
			else 
				op += "Enemy was UNdef";
			if( IsDefined ( self.enemy ) )
				op +=". New En is " + self.enemy.classname ;
			else
				op +=". New En is UNdef";
			
			do_op = true;
			enemy = self.enemy;
		}

		if( rad != self.goalradius )
		{	
			op += "Old Rad:" + rad + " New Rad:" + self.goalradius;
			rad = self.goalradius;
			do_op = true;
		}
		if(do_op)
		{
			IPrintLnBold( op );
			wait( 0.5 );
			
		}
		
		if( self.ignoreall )
		{
			op = op + "IGNOREALL on.";
			IPrintLnBold( op );
		}
		
		
		dostring = false;
		
		
		
	}


}
#/		

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//			Anything to do with active zones for the dog.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////




// Make it so the dog won't receive command input, such as during a scripted sequence
lock_player_control_until_flag( flag )
{
	
	if(!IsDefined(level.dog_lock_check) )
		level.dog_lock_check = 0;
	
	level.dog_lock_check++;
	if( level.dog_lock_check > 1 )
	{
//		IPrintLnBold( "Started another lock whilst one is already happening. Curr Locks:"+ level.dog_lock_check );
	}
	
	
	flag_set( "dog_control_lockout" );
	self.ally_owner.dog_hud_active [ 0 ] = false;
	
	// if we have a laser active, cancel it to the scripted one.
	level.player notify( "cancel_designate" );
	
	IPrintLn( "Locking dog Flag:" + flag );
	
	if( !Flag( flag ) )
	{
//		IPrintLn( "Waiting for unlock on Flag:" + flag );
		
		flag_wait( flag );
//		IPrintLn( "UNLOCKING AUTOMATICALLY for " + flag );
		unlock_player_control();
	}
	else
	{
		IPrintLnBold( "Flag already set:" + flag );
	}
	level.dog_lock_check--;
	self.ally_owner.dog_hud_active [ 0 ] = true;
	
	if( level.dog_lock_check > 0 )
	{
//		IPrintLnBold( "FINISHING lock flag func with another one already active. Curr Locks:"+ level.dog_lock_check + " :" + flag );
	}
	
}


// Make it so the dog won't receive command input, such as during a scripted sequence
lock_player_control( unlock_at_end )
{
	
	if(!IsDefined(level.dog_lock_check) )
		level.dog_lock_check = 0;
	

	if(!IsDefined(level.dog_lock_level) )
		level.dog_lock_level = 1;
	mylock = level.dog_lock_level;
	level.dog_lock_level++;

	level.dog_lock_check++;
	if( level.dog_lock_check > 1 )
	{
//		IPrintLnBold( "Started another lock whilst one is already happening. Curr Locks:"+ level.dog_lock_check );
	}
	
	
	flag_set( "dog_control_lockout" );
	// if we have a laser active, cancel it to the scripted one.
	level.player notify( "cancel_designate" );
	self.ally_owner.dog_hud_active [ 0 ] = false;
	
	IPrintLn( "Locking dog controls Ref Num:" + mylock );
	
	if( IsDefined( unlock_at_end ) && unlock_at_end )
	{
//		IPrintLn( "Waiting for unlock on Ref:" + mylock );
		
		waittill_either( "finished_dog_path", "pointing_at_target" );
//		IPrintLn( "UNLOCKING AUTOMATICALLY for Ref:" + mylock );
		
		unlock_player_control();
	}
	else
	{
		IPrintLn( "No wait for lock with Ref:" + mylock );
	}
	level.dog_lock_check--;
	if( level.dog_lock_check > 0 )
	{
//		IPrintLnBold( "FINISHING lock func with another one already active. Curr Locks:"+ level.dog_lock_check );
	}
	
}
// Allow the dog to receive command input again, such as after a scripted sequence
unlock_player_control()
{
	flag_clear( "dog_control_lockout" ) ;
	self.ally_owner.dog_hud_active [ 0 ] = true;
}









watch_active_zones( owner, zone_names )
{
	self endon( "death" );
	level.dog_active_zones = GetEntArray( zone_names, "targetname" );
	//AssertEx( level.dog_active_zones.size > 0, "no active zones for targetname " + zone_names ); // This should be perfectly legal.
	level.dog_tag_origin = spawn_tag_origin();
	
	//go through the actives and see if we have any that activate when the dog goes in them.
	level.dog_active_touch_zones = [];
	level.dog_active_aim_zones = [];
	foreach( zone in level.dog_active_zones )
	{
		zone.dogs_touching = [];
		if( !IsDefined( zone.script_parameters ) )
		{
			level.dog_active_touch_zones[ level.dog_active_touch_zones.size ] = zone;
			level.dog_active_aim_zones[ level.dog_active_aim_zones.size ] = zone;
		}
		else if( IsDefined( zone.script_parameters ) && zone.script_parameters == "dog_touch" )
			level.dog_active_touch_zones[ level.dog_active_touch_zones.size ] = zone;
		else if( IsDefined( zone.script_parameters ) && IsSubStr( zone.script_parameters, "dog_aim" ) )
			level.dog_active_aim_zones[ level.dog_active_aim_zones.size ] = zone;
	}
	
	//watch to see if the dog goes into any of our active touch volumes.
	while( 1 )
	{
		foreach( zone in level.dog_active_touch_zones )
		{
			if( (check_zone_flags( zone )) && (! self check_already_touching( zone ) ) )
			{
				if( self IsTouching( zone ) )
				{
					self add_to_zone( zone );
					self notify( "touched_zone", zone);	  //specific touch notification
					self notify( "activated_zone", zone); //could have touched or aimed at it to get this notification.
					level.dog_active_aim_zones = array_remove( level.dog_active_aim_zones, zone );
					level.dog_active_touch_zones = array_remove( level.dog_active_touch_zones, zone );
					level.dog_active_zones = array_remove( level.dog_active_zones, zone );

					self thread dispatch_activated_zone( zone );
					
					// We just touched a zone- do whatever it is that this zone expects us to do.
				}
				else
				{
					if( self remove_if_touching( zone ) )
					{
						// We just left a zone- let the dog know in case someone is waiting on it.
						self notify( "left_zone", zone);
					}
				}
			}
			
		}
		wait 0.25;
	}
	
}


check_zone_flags( zone )
{
	if ( IsDefined( zone.script_flag_false ) )
	{
		tokens = strtok( zone.script_flag_false, " " );

		// stay off unless all the flags are false
		foreach ( token in tokens )
		{
			if ( flag( token ) )
			{
				return false;
			}
		}
	}
	
	if ( IsDefined( zone.script_flag_true ) )
	{
		tokens = strtok( zone.script_flag_true, " " );

		foreach ( token in tokens )
		{
			if ( !flag( token ) )
			{
				return false;
			}
		}
	}
	// if all our flag checks passed, the zone is active.
	return true;
	
}

add_to_zone( zone )
{
/#
	AssertEx( !array_contains( zone.dogs_touching, self ), "Zone already contained this dog- should never happen" );
#/
	zone.dogs_touching[ zone.dogs_touching.size ] = self;
}

remove_if_touching( zone )
{
	foreach( dog in zone.dogs_touching )
	{
		if( dog == self )
		{
			zone.dogs_touching = array_remove( zone.dogs_touching, self );
			return true;
		}
	}
	return false;
}


check_already_touching( zone )
{
	foreach( dog in zone.dogs_touching )
	{
		if( dog == self )
			return true;
	}
	return false;
}

cleanup_zone_arrays( zone )
{
	self remove_if_touching( zone );
	
	
}


// Figures out what we are trying to get the dog to do, and handles it.
dispatch_activated_zone( zone )
{
	
	self dispatch_activated_zone_thread( zone );
	self cleanup_zone_arrays( zone );
	
}

dispatch_activated_zone_thread( zone )
{
	// We can only be running one zone at a time, so make sure we interrupt any previous action.

	type =   zone.script_noteworthy;
	if( !IsDefined( type ) )
		return;
	
	self notify( "activated_new_zone" );


	self endon(  "activated_new_zone" );
	target = zone.target;
	node = GetNode( target, "targetname" );
	self.last_zone = zone;
	
	self.sniff_mode = false;
	
	switch( type )
	{
		case "dog_point_sniff":
			self.sniff_mode = true;
		case "dog_point":
			level.dog_guard_override = node;

			//iprintlnBold( "got zone activation for dog point." );
			//Tell the dog (via its owner) that it needs to go to a pointing state
			self.ally_owner notify( "dog_guard_owner_pointing" );
			self.curr_interruption = "make_active";
			wait 0.1;
			self.clear_override_node = true;
			self.clear_this_node = node ;

			self waittill( "forever" );
		break;
		
		case "dog_path_sniff":
			self.sniff_mode = true;
		case "dog_path":
			self.ally_new_state = ::volume_holding_state ;
			self.ally_owner notify( "ally_dog_check_new_state" );
			self.curr_interruption = "make_active";
			
			//IPrintLnBold("Got dog_path to ", target );
			self thread maps\_spawner::go_to_node( node );
			//IPrintLnBold( "waiting for path_end" );
			self waittill( "reached_path_end" );
			self notify( "finished_dog_path" );
			//IPrintLnBold( "GOT path_end" );
			self waittill( "forever" );
			
			break;
	}
}



check_against_active_zones( startpos, endpos )
{
	target = undefined;
	
	if( !IsDefined( level.dog_active_touch_zones ))
	{
		return target;
	}
	   
	
	
	level.dog_tag_origin.origin = endpos;
	
	foreach( zone in level.dog_active_aim_zones )
	{
		if( check_zone_flags( zone ) && ( ! self check_already_touching( zone ) ) )
		{
			if( level.dog_tag_origin IsTouching( zone ) )
			{
				target = zone;
				break;
			}
	
			//see if the trace intersected with the volume (this isn't exact, but should be accurate enough for most simple volume shapes		
			middle = zone GetCentroid();
			nearest_point = PointOnSegmentNearestToPoint(startpos,endpos, middle);
			level.dog_tag_origin.origin = nearest_point;
			if( level.dog_tag_origin IsTouching( zone ) )
			{
				target = zone;
				break;
			}
		}
	}
	
	//Process the zone if we found a valid one
	if( IsDefined( target) )
	{

		if( IsDefined( target.script_flag_set ) )
			flag_set( target.script_flag_set );
		
		level.dog_active_aim_zones = array_remove( level.dog_active_aim_zones, target );
		level.dog_active_touch_zones = array_remove( level.dog_active_touch_zones, target );
		level.dog_active_zones = array_remove( level.dog_active_zones, target );

		self add_to_zone( target );
		self notify( "aimed_zone", target );	  //specific touch notification
		self notify( "activated_zone", target ); //could have touched or aimed at it to get this notification.
		//IPrintLnBold( "BEFORE CALL dispatched activated target." );
		self thread dispatch_activated_zone( target );
		//IPrintLnBold( "dispatched activated target." );
		
		//Do the spinny locator if the volume has a target.
		ent = undefined;
		if( IsDefined( target.script_linkto ) )
		{
			ent = getstruct( target.script_linkto, "script_linkname" );
		}
		else if( IsDefined( target.target ) )
		{
			ent = target get_target_ent();
		}
		if( IsDefined( ent ) )
		{
			thread set_dog_arrow( ent.origin );
		}
	}
	
	return target;
}

get_enemy_from_active_zone( startpos, endpos )
{
	target = undefined;
	zone = self check_against_active_zones( startpos, endpos );
	if( IsDefined( zone ) )
	{
//		IPrintLnBold(" got point inside an active zone.: " + zone.targetname );
		
		targets = zone get_ai_touching_volume( "axis" );
		target = getClosest( endpos, targets );
	}
	
	return target;
}












/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//			Anything to do with displaying information on the HUD, such as the dog's active state.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////











handle_dog_hud( start_active )
{
	level.player endon( "death" );
	
	level notify( "stop_dog_hud" );
	level endon( "stop_dog_hud" );
	
	level.player.dog_hud_visible = [];
	level.player.dog_hud_active = [];
	
	level.player.dog_hud_visible[ 0 ] = false;
	level.player.dog_hud_visible[ 1 ] = false;
	
	level.player.dog_hud_active [ 0 ] = false;
	level.player.dog_hud_active [ 1 ] = false;
	
	if( start_active )
	{
		level.player.dog_hud_visible[ 1 ] = true;
		level.player.dog_hud_visible[ 0 ] = true;
		//set_dog_hud_attack();
	}
		
		
}


set_dog_hud_guard()
{
	set_dog_hud_attack();
	/*
	
	level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_melee" );
//	level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_attack_inactive" );
//	level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_active" );
	level.player.dog_hud_active [ 0 ] = false;
	level.player.dog_hud_active [ 1 ] = true;

	RefreshHudAmmoCounter();
	*/
}

set_dog_hud_attack()
{
	/*
	level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_melee" );
//	level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_attack_active" );
//	if( level.player.dog_hud_visible[ 1 ] )
//		level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_inactive" );
	level.player.dog_hud_active [ 0 ] = true;
	level.player.dog_hud_active [ 1 ] = false;

	RefreshHudAmmoCounter();
	*/
}
set_dog_hud_disabled()
{
	/*
	level.player.dog_hud_visible[ 0 ] = false;
	level.player.dog_hud_visible[ 1 ] = false;
	level.player setWeaponHudIconOverride( "actionslot1", "none" );
	level.player setWeaponHudIconOverride( "actionslot2", "none" );

	RefreshHudAmmoCounter();
	*/
}

set_dog_hud_enabled()
{
	level.player.dog_hud_visible[ 0 ] = true;
	level.player.dog_hud_visible[ 1 ] = true;
	
	set_dog_hud_guard();
	
	RefreshHudAmmoCounter();
	
}
set_dog_hud_for_intro()
{
	set_dog_hud_for_intro_loop();
	
//	level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_melee" );
}
set_dog_hud_for_intro_loop()
{
	level.player endon( "dog_attack" );
	level.player endon( "dog_command_attack" );
	level.player endon( "cancel_dog_hud" );
	
//	level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_melee" );
	level.player.dog_hud_visible[ 0 ] = true;
	level.player.dog_hud_active [ 0 ] = false;
	level.player.dog_hud_active [ 1 ] = false;
//	RefreshHudAmmoCounter();
	i = 0;
	/*
	while( 1 )
	{
		wait 0.25;
		if( i % 2 )
			level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_melee" );
		else
			level.player setWeaponHudIconOverride( "actionslot1", "hud_dog_melee" );
		RefreshHudAmmoCounter();
		i++;
	}
	*/
}

set_dog_hud_for_guard()
{
	/*
	set_dog_hud_for_guard_loop();
	level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_active" );
//	level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_active" );
*/
	
}
set_dog_hud_for_guard_loop()
{
	/*
	level.player endon( "dog_guard_me" );
	level.player endon( "cancel_dog_hud" );
	
	level.player.dog_hud_visible[ 0 ] = true;
	level.player.dog_hud_visible[ 1 ] = true;
	level.player.dog_hud_active [ 1 ] = false;
//	level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_inactive" );
	
	RefreshHudAmmoCounter();
	i = 0;
	while( 1 )
	{
		wait 0.25;
		if( i % 2 )
			level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_inactive" );
//			level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_inactive" );
		else
			level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_active" );
//			level.player setWeaponHudIconOverride( "actionslot2", "hud_dog_guard_active" );
		RefreshHudAmmoCounter();
		i++;
	}
*/
}


























debug_cross( loc, dur, color )
{
	if( !IsDefined( dur ) )
		dur = 10;
	if( !IsDefined( color ) )
		color = ( 1, 1, 1 );
	
	

	Line( loc - (32,0,0), loc + (32,0,0), color, 1, 0, dur );
	Line( loc - (0,32,0), loc + (0,32,0), color, 1, 0, dur );
	Line( loc - (0,0,32), loc + (0,0,32), color, 1, 0, dur );

}












/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//			Doggy pain management.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

dog_manage_damage( owner )
{
	if( IsDefined( self.can_die ) && self.can_die == false )
		return;
	self.damage_level = 0;
	
	self.last_damage_time = GetTime();
	self thread dog_damage_reduction();
	
	while( 1 )
	{
		self waittill( "took_pain" );
		//don't let us take too much pain instantly- give it a couple of seconds between each one.
		
		
		if( self.last_damage_time + 2000 < GetTime() && self.ally_current_state != ::ally_dog_guard_owner)
		{
			self.damage_level++;
//			IPrintLnBold( "Dog took damage:" + self.damage_level );
			self.last_damage_time = GetTime();
			if( self.damage_level == 2 )
			{
				//thread intro_hud_help( level.player, "remove_hint", "Cairo is injured- Use ^3 [{+actionslot 2}] ^7to recall Cairo to safety." );
				
			}
			
			if( self.damage_level >= 3 )
			{
				IPrintLnBold( "Killing dog / player- damage level is:" + self.damage_level );
				if( IsPlayer( owner ) )
					owner Kill();
			}
		}
		
	}

}

dog_damage_reduction()
{
	while( 1 )
	{
		wait 1;
		if( self.damage_level > 0 )
		{
			if( self.last_damage_time + 10000 < GetTime() )
			{
				self.damage_level--;
				self.last_damage_time =   GetTime() - 6000 ; // subsequent damage is effectively quicker to reduce than the first batch.
//				IPrintLnBold( "Reduced dog damage level to " + self.damage_level );
			}
			
		}
		
		
	}
	
}










