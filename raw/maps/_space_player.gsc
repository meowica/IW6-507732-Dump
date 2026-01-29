#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

init_player_space()
{
	PreCacheShellShock( "underwater_swim" );
	PreCacheModel( "shpg_viewmodel_scuba_mask" );
	PreCacheModel( "viewhands_us_lunar" ); // Required by attach_audio_points_to_player()
	
	flag_init( "spacesprint" );
	flag_init( "boostAnim" );
	
	flag_init( "wall_push_flag_left" );
	flag_init( "floor_push" );
	flag_init( "stop_wall_pushing" );
	
	flag_init( "set_player_interior_speed" );
	flag_init( "set_player_exterior_speed" );
	
	flag_init( "clear_to_tweak_player" );
	flag_init( "enable_player_thruster_audio" );
	
	//audio global variables to use with thrusters
	level.looping_thruster_sfx = Spawn( "script_origin", ( 0,0,0 ) );
	level.thruster_timer = 1;
	level.thruster_oneshot = Spawn( "script_origin", ( 0,0,0 ) );

}

#using_animtree( "generic_human" );
init_player_space_anims()
{
	// anims
	player_space_anims();
	level.scr_anim[ "generic" ][ "space_fwd" ][0] = %ny_harbor_wetsub_npc_swim_fwd;
	
	level.scr_anim[ "playerlegs" ][ "space_fwd" ][0] = %ny_harbor_wetsub_npc_swim_fwd;
	level.scr_anim[ "playerlegs" ][ "space_lt" ][0] = %ny_harbor_wetsub_npc_swim_lt;
	level.scr_anim[ "playerlegs" ][ "space_rt" ][0] = %ny_harbor_wetsub_npc_swim_rt;
	level.scr_animtree[ "playerlegs" ] 	= #animtree;
	level.scr_model[ "playerlegs" ] 	= "body_seal_udt_dive_a";
}

shellshock_forever()
{
	/*
	self notify( "underwater_shellshock" );
	self endon( "underwater_shellshock" );
	while( 1 )
	{
		self shellshock( "underwater_swim", 9999 );
		wait( 9998 );
	}
	*/
}

enable_player_space()
{
	SetSavedDvar( "cg_footsteps", 0 );
	SetSavedDvar( "cg_equipmentSounds", 0 );
	SetSavedDvar( "cg_landingSounds", 0 );

	self thread shellshock_forever();
	
	self EnableSlowAim( 0.5, 0.5 );
	
	// Global for water current
	level.water_current = (0,0,0);

	// Global for drift vectors
	level.drift_vec = (0,0,0);

	// Flags for water movement
	thread moving_water();
	thread impulse_push();
	level.player thread player_recoil();
	
	//Turn off sprint
//	level.player AllowSprint( false );
	
	self.player_mover = self spawn_tag_origin();
	
	// Audio
	self thread maps\_space::player_space();
	thread space_thruster_audio();
	
	// Enable space
	SetSavedDvar( "player_spaceEnabled", "1" );

	// Enable swim
	self allowSwim( true );
	
	level.space_speed = 90;
	space_accel = 75;
	//DVARS to modify swim into feeling like space movement
	SetSavedDvar( "player_swimFriction" , 1 );  			//This sets the "space" feel of momentum.  Adjust to throttle how much the player drifts. 	 DEFAULT 15
	SetSavedDvar( "player_swimAcceleration" , space_accel );//This sets the player's acceleration in space												 DEFAULT 75
	SetSavedDvar( "player_swimVerticalFriction" , 50 );		//Sets the amount of momentum retained vertically											 DEFAULT 50
	SetSavedDvar( "player_swimVerticalSpeed" , 60 );		//Sets the max vertical speed																 DEFAULT 60 
	SetSavedDvar( "player_swimVerticalAcceleration" , 85 );	//Sets the max vertical acceleration														 DEFAULT 85
	SetSavedDvar( "player_swimSpeed" , level.space_speed );
	
	thread direction_change_smoothing(  );
//	thread space_sprint( space_accel );
	setSavedDvar( "player_sprintUnlimited", "1" );
	
	wait 1;
	
	//Check to see if the player has the anims or not.  See function below for details!
	if ( IsDefined( level.player.has_pushanims ) && level.player.has_pushanims == true ) 

	{
		player_rig = spawn_anim_model( "player_rig" );
		player_rig.origin = level.player.origin ;
		player_rig.angles = level.player.angles;
		player_rig LinkToPlayerView( level.player , "tag_origin" , ( 0 , 0 , 0 ) , ( 0 , 0 , 0 ) , true );
		player_rig Hide();
		
		thread wall_push(player_rig);

		thread speed_direction_check();
	}
}

// Turns off space
// Call on player
disable_player_space()
{
	level notify( "disable_space" );
	self notify( "disable_space" );

	//iprintlnbold( "Disable Player Space" );
	
	SetSavedDvar( "cg_footsteps", 1 );
	SetSavedDvar( "cg_equipmentSounds", 1 );
	SetSavedDvar( "cg_landingSounds", 1 );

	// Remove HUD
	self thread maps\_space::player_space_helmet_disable();
	self thread maps\_space::space_hud_enable( false );

	self DisableSlowAim( 0.5, 0.5 );

	//Turn off sprint
	level.player AllowSprint( true );

	self allowSwim( false );
}


player_location_check( location )
{
	if( !IsDefined( location ) )
	{
		return;	
	}
	switch( location )
	{
		case "exterior" :
			level.space_speed = level.space_speed * 1.5;
			SetSavedDvar( "player_swimSpeed" , level.space_speed );
			break;
		case "interior" : 
			level.space_speed = level.space_speed / 1.5;
			SetSavedDvar( "player_swimSpeed" , level.space_speed );
			break;			
	}
}

//TODO:  Clean up push stuff - DS
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// This block of code controls the player push-off animations.
// If the player touches a volume, has been moving forward at
// 40% speed or greater, and has been moving for 1 second (at 
// least), there is a % chance that they will play an animation
// where the push off of the wall.
//	
//
// None of this gets called unless the push animations are 
// added to the level's CSV and level.player.has_pushanims set
// to TRUE.
////////////////////////////////////////////////////////////////////////////////////////////////////

//Each wall_push(degree) corresponds to a flag referencing an
//origin set to a cardinal direction


wall_push( player_rig )
{
	level endon( "wall_push_over" );
	thread stop_space_push( player_rig );

	while( !flag( "stop_wall_pushing" ) )
	{
		// Wait for the trigger
        flag_wait( "wall_push_flag" );
        
        closestDist = undefined;
        closest = undefined;
        
        // Get all the wall_push origins in the level
        orgs = GetEntArray( "wall_push_org", "targetname" );
        
        // Find the closest one
        foreach ( org in orgs )
        {
            d = distanceSquared( level.player.origin, org.origin );
            
            if ( !isdefined( closestDist ) || ( d < closestDist ) )
            {
	            closestDist = d;
	            closest 	= org;
            }
        }
        
        // Extract the direction
        switch( closest.script_parameters )
        {
            case "left":
	            random_player_wall_push( closest , player_rig);
	            break;
            case "up":
                
                break;
            case "down":
                random_player_wall_pushDOWNUP( closest , player_rig);
                break;
        }

	
		
		wait.1;
	}
	player_rig Unlink();
	player_rig Delete();

}

stop_space_push( player_rig )
{
	flag_wait( "stop_wall_pushing" );
	level notify( "wall_push_over" );
	player_rig Unlink();
	player_rig Delete();
}


//Checks how long the player has been traveling forward
speed_direction_check()
{
	level endon( "disable_space" );
	level.timeCheck = 0;
	
	while(1)
	{
		movement = level.player GetNormalizedMovement();
		if( movement[0] > .4 )
		{
			wait .1;
			level.timeCheck = level.timeCheck + .1;
						
		}
		else
		{
			level.timeCheck = 0;
			wait .1;
		}
	}
}

//Checks the degree offset of the player vs. the reference and then,
//potentially, plays the animation
#using_animtree( "player" );
random_player_wall_push( refOrigin , player_rig)
{	
	guys = [];
	guys["player_rig"] = player_rig;
	
	testVar = refOrigin.angles[1];
	circleVar = 0;
	
	checkDegree = 20;
	if( testVar <= 0 )
	{
		testVar = testVar + 360;
	}
	bCheck = false;
	
	
	while( flag( "wall_push_flag" ))
	{
		bRandom = RandomIntRange( 1 , 10 );
		analog_input = level.player GetNormalizedMovement();
		level.player anim_first_frame( guys, "viewmodel_space_l_arm_sidepush");	
		player_angle = level.player.angles[1];
		
		if( player_angle <= 0 )
		{
			player_angle = player_angle + 360;
		}
		
		if( (testVar + checkDegree) > 360)
		{
			circleVar = (testVar + checkDegree	) - 360;
			if( player_angle > testVar || player_angle < circleVar )
			{
				bCheck = true;	
			}	
		}
		else
		{
			if( player_angle > testVar && player_angle < ( testVar + checkDegree ))
			{
				bCheck = true;
			}
		}
		
		if( bRandom < 6 )
		{
//			bCheck = false;
//			wait 3;
		}
		speed_rate = 1 ;
		if( flag( "spacesprint") )
		{
			speed_rate = 1.1;
		}
		
		if( bCheck == true && analog_input[0] > .4 && level.timeCheck > 1 )
		{
			player_rig show();
			//level.player thread anim_single ( guys , "viewmodel_space_l_arm_sidepush");
			player_rig SetAnimRestart( %viewmodel_space_l_arm_sidepush , 1 , 0 , speed_rate );
			flag_set( "wall_push_tweak_player" );
			wait 1;
			thread anim_boost();
			wait .67;
			player_rig hide();
			wait 1;  //This is so we don't get one anim RIGHT after the other.
		}
		bCheck = false;

		wait .05;		
	}
}

random_player_wall_pushDOWNUP( refOrigin , player_rig)
{	
	guys = [];
	guys["player_rig"] = player_rig;
	
	testVar = refOrigin.angles[1];
	circleVar = 0;
	
	checkDegree = 20;
	if( testVar <= 0 )
	{
		testVar = testVar + 360;
	}
	bCheck = false;
	
	
	while( flag( "wall_push_flag" ))
	{
		bRandom = RandomIntRange( 1 , 10 );
		analog_input = level.player GetPlayerAngles();
		level.player anim_first_frame( guys, "viewmodel_space_l_arm_downpush");	
		player_angle = level.player.angles[1];
		
		if( player_angle <= 0 )
		{
			player_angle = player_angle + 360;
		}
		
		if( (testVar + checkDegree) > 360)
		{
			circleVar = (testVar + checkDegree	) - 360;
			if( player_angle > ( testVar - checkDegree ) || player_angle < circleVar )
			{
				if( analog_input[0] > -10 && analog_input[0] < 30 )
					{
						bCheck = true;
					}	
			}	
		}
		else
		{
			if( player_angle > ( testVar - checkDegree ) && player_angle < ( testVar + checkDegree ))
			{
				if( analog_input[0] > -20 && analog_input[0] < 30 )
					{
						bCheck = true;
					}	
			}
		}
		
		if( bRandom < 6 )
		{
//			bCheck = false;
//			wait 3;
		}
		
		speed_rate = 1;	
		if( flag( "spacesprint") )
		{
			speed_rate = 1.1;
		}
		
		if( bCheck == true && analog_input[0] > .4 && level.timeCheck > 1 )
		{
			player_rig show();
			//level.player thread anim_single ( guys , "viewmodel_space_l_arm_downpush" );
			player_rig SetAnimRestart( %viewmodel_space_l_arm_downpush , 1 , 0 , speed_rate );
			flag_set( "wall_push_tweak_player" );
			wait 1;
			thread anim_up_down_boost();
			wait .67;
			player_rig hide();
			wait 1;  //This is so we don't get one anim RIGHT after the other.
		}
		bCheck = false;

		wait .05;		
	}
}
anim_up_down_boost()
{
	flag_set( "boostAnim" );
	wait .7;
	flag_clear( "boostAnim" );
}

anim_boost()
{
	flag_set( "boostAnim" );
	wait .5;
	flag_clear( "boostAnim" );
}

///////////////////
//End of wall push script
///////////////////


moving_water()
{
	moving_water_flags = GetEntArray( "moving_water_flags", "script_noteworthy" );
	foreach( flag in moving_water_flags )
	{
		thread moving_water_flag( flag );
	}
}

moving_water_flag( flag_ent )
{
	level endon( "disable_space" );

	CURRENT_STRENGTH = 40;
	
	water_direction_ent = GetEnt( flag_ent.target, "targetname" );
	water_direction_vec = AnglesToForward( water_direction_ent.angles ) * CURRENT_STRENGTH; 

	while( 1 )
	{
		flag_wait( flag_ent.script_flag );
		level.water_current = water_direction_vec;
		flag_waitopen( flag_ent.script_flag );
		level.water_current = (0,0,0);
	}
}

#using_animtree( "player" );
player_space_anims()
{
	level.scr_anim[ "playerhands" ][ "space_idle" ][0] = %scuba_player_idle;
	level.scr_anim[ "playerhands" ][ "space_forward" ][0] = %scuba_player_forward;
	level.scr_anim[ "playerhands" ][ "space_idle2forward" ] = %scuba_player_idle2forward;
	level.scr_anim[ "playerhands" ][ "space_forward2idle" ] = %scuba_player_forward2idle;	
	
	level.scr_animtree[ "playerhands" ] 	= #animtree;
	level.scr_model[ "playerhands" ] 	= "viewhands_player_udt";
}




//Give the player finer control so they can move between cover more easily
direction_change_smoothing()
{
	level endon( "disable_space" );

	analog_input 	= level.player GetNormalizedMovement();
	previous_input 	= analog_input;
	
	// Wall friction setup
	if( !isDefined( level.wall_friction_enabled ))
	{
		level.wall_friction_enabled = true;
	}
	if( !isDefined( level.wall_friction_trace_dist ))
	{
		level.wall_friction_trace_dist = 5;
	}
	if( !isDefined( level.wall_friction_offset_dist ))
	{
		level.wall_friction_offset_dist = 2;
	}

	while(1)
	{
		analog_input 	= level.player GetNormalizedMovement();

		////////////////////////////////
		//ESTABLISH WHERE THE STICK IS//
		////////////////////////////////
		if( analog_input[ 0 ] > .15 )
		{
			analogY = "positive";	
		}
		else
		{
			analogY = "neutral";	
		}
		
		if( analog_input[ 1 ] > .15 )
		{
			analogX = "positive";	
		}
		else
		{
			analogX = "neutral";	
		}
		
		if( analog_input[ 0 ] < -.15 )
		{
			analogY = "negative";	
		}

		if( analog_input[ 1 ] < -.15 )
		{
			analogX = "negative";	
		}

		/////////////////////////////////
		//ESTABLISH WHERE THE STICK WAS//
		/////////////////////////////////
		if( previous_input[ 0 ] > .15 )
		{
			p_analogY = "positive";	
		}
		else
		{
			p_analogY = "neutral";	
		}
		
		
		if( previous_input[ 1 ] > .15 )
		{
			p_analogX = "positive";	
		}
		else
		{
			p_analogX = "neutral";	
		}
		
		if( previous_input[ 0 ] < -.15 )
		{
			p_analogY = "negative";	
		}

		if( previous_input[ 1 ] < -.15 )
		{
			p_analogX = "negative";	
		}

		wall_collision_detected = false;
		if( level.wall_friction_enabled )
		{
			// Check for wall collision
			vel = VectorNormalize( level.player GetVelocity());
			right = AnglesToRight( vectorToAngles( vel ));
			up = AnglesToUp( vectorToAngles( vel ));
			ofs = level.wall_friction_offset_dist;
			right_up_sideOffset = ( level.player.origin + ( right[0] * ofs, right[1] * ofs, right[2] * ofs ));
			right_up_sideOffset = ( right_up_sideOffset + ( up[0] * ofs, up[1] * ofs, up[2] * ofs ));

			left_down_sideOffset = ( level.player.origin - ( right[0] * ofs, right[1] * ofs, right[2] * ofs ));
			left_down_sideOffset = ( left_down_sideOffset - ( up[0] * ofs, up[1] * ofs, up[2] * ofs ));

			// Test right side
			ofs = level.wall_friction_trace_dist;
			testPos = right_up_sideOffset + ( vel[0] * ofs, vel[1] * ofs, vel[2] * ofs );
			endPos = level.player AIPhysicsTrace( right_up_sideOffset, testPos );
			//thread animscripts\utility::showDebugProc( right_up_sideOffset, testPos, (1,0,0), 0.1 );

			if( testPos != endPos )
			{
				wall_collision_detected = true;
			}
			else
			{
				// Test left side
				testPos = left_down_sideOffset + ( vel[0] * ofs, vel[1] * ofs, vel[2] * ofs );
				endPos = level.player AIPhysicsTrace( left_down_sideOffset, testPos );
				//thread animscripts\utility::showDebugProc( left_down_sideOffset, testPos, (1,0,0), 0.1 );

				if( testPos != endPos )
				{
					wall_collision_detected = true;
				}
			}
		}
		

		/////////////////////////////////////
		//WALL COLLISION FRICTION
		/////////////////////////////////////
		if( level.wall_friction_enabled && wall_collision_detected == true )
		{
			// If colliding with wall - set high friction to reduce "sliding"
			SetSavedDvar( "player_swimFriction" , 120 );
			wait 0.15;
		}
		
		/////////////////////////////////////
		//CHECK ONE STICK AGAINST THE OTHER//
		/////////////////////////////////////
		else if( (							  analogX == "neutral"  && analogY == "neutral"	 						 ) ||
		  	(p_analogX == "positive" && p_analogY == "positive" && analogX == "positive" && analogY == "positive") ||
			(p_analogX == "negative" && p_analogY == "negative" && analogX == "negative" && analogY == "negative") ||   
			(p_analogX == "negative" && p_analogY == "positive" && analogX == "negative" && analogY == "positive") ||
			(p_analogX == "positive" && p_analogY == "negative" && analogX == "positive" && analogY == "negative")  )
		{
			SetSavedDvar( "player_swimFriction" , 1 );  			//This sets the "space" feel of momentum.  Adjust to throttle how much the player drifts. 	 DEFAULT 15
			SetSavedDvar( "player_swimAcceleration" , 66 );			//This sets the player's acceleration in space											 	 DEFAULT 75
		}

		else
		{
			SetSavedDvar( "player_swimFriction" , 120 );  			//This sets the "space" feel of momentum.  Adjust to throttle how much the player drifts. 	 DEFAULT 15
			SetSavedDvar( "player_swimAcceleration" , 200 );			//This sets the player's acceleration in space											 	 DEFAULT 75	
			wait .1;
		}
		
		if( analogY != "neutral" && analogX != "neutral " )
		{
			previous_input = analog_input;	
		}
		
		wait .05;		
	}
}

//Allow our guy to "sprint" without having arm flailing, head bobbing action
space_sprint( space_accel )
{
	level endon( "disable_space" );

	time = GetTime();
	sprint_time = 4000;
	bWasSprinting = false;
	iSprintFade = 2.0;

	while(1)
	{
		input = level.player GetNormalizedMovement();
		bCheck = false ;
		if( (level.player ButtonPressed( "BUTTON_LSTICK" ) || level.player ButtonPressed( "sprint" ) ) && input[0] > .15 && input[1] > -.35 && input[1] < .35 )
		{
			level notify( "sprinting" );
			while( bCheck == false )
			{
				input = level.player GetNormalizedMovement();
				SetSavedDvar( "player_swimSpeed" , level.space_speed * iSprintFade );
				if( input[0] > .15 && input[1] > -.35 && input[1] < .35 )
				{
					
					//IPrintLnBold( "SPRINTING" );
				}
				else  
				{
					//IPrintLnBold( "FADING" );
					bCheck = true;	
					thread sprint_fade( iSprintFade );
				}
				wait .01;
			}
		}
		wait .05;
	}	
}

sprint_fade( iSprintFade )
{
	level endon( "sprinting" );
	while(1)
	{
		if( iSprintFade > 1 )
		{
			SetSavedDvar( "player_swimSpeed" , level.space_speed * iSprintFade );	
			iSprintFade = iSprintFade - .05;
		}
		else
		{
			//IPrintLnBold( "FADE COMPLETE" );
			return;	
		}
		wait .05;
	}
}

//////////////////////////////////
//Damage impacts push the player//
//////////////////////////////////

impulse_push()
{
	level endon( "disable_space" );

	while(1)
	{
		level.player waittill( "damage", amount, attacker, direction_vec, point, type ); 
		flag_clear( "clear_to_tweak_player" );
		
		CURRENT = [];
		CURRENT[0] = direction_vec[0];
		CURRENT[1] = direction_vec[1];
		CURRENT[2] = direction_vec[2];
		
		SEVERITY = .25;		//How much we reduce the amount of damage by
		RESTRAINT = 3000;  	//Number between 1 and 20k -- Determines how high we want to let the current numbers go
							//Anything over ~5k is VERY noticeable
		wait_time = 1;		//How long before the current is reset
		
		if( type == "MOD_EXPLOSIVE" || type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" )
		{
			SEVERITY = .5;	
			RESTRAINT = 7000;
			wait_time = 1;
		}
		
		for( i = 0 ; i < 3 ; i++)
		{
			CURRENT[i] = (CURRENT[i] * .25 ) * ( amount * SEVERITY );
			
			if(CURRENT[i] > RESTRAINT )
			{
				CURRENT[i]	= RESTRAINT;
			}
			
			if(CURRENT[i] < ( 0 - RESTRAINT ))
			{
				CURRENT[i]	= ( 0 - RESTRAINT );
			}
		}

		SetSavedDvar("player_swimWaterCurrent", (CURRENT[0],CURRENT[1],CURRENT[2]));
		wait wait_time;
		for( i = 0 ; i < 3 ; i++ )
		{
			for( i = 0 ; i < 3 ; i++)
			{
				current[i] = current[i] * .5;
			}
			SetSavedDvar("player_swimWaterCurrent", (CURRENT[0],CURRENT[1],CURRENT[2]));
			wait wait_time * .25;
		}
		
		SetSavedDvar("player_swimWaterCurrent", (0,0,0));
		flag_set( "clear_to_tweak_player" );
		
	}
}

player_recoil()
{
	while ( 1 )
	{
		self waittill( "weapon_fired" );
		
		flag_clear( "clear_to_tweak_player" );
		
		aim = self GetPlayerAngles();
		angles = AnglesToForward( aim );
		
		CURRENT = [];
		CURRENT[0] = angles[0];
		CURRENT[1] = angles[1];
		CURRENT[2] = angles[2];
		
		SEVERITY = 2500;
		
		wait_time = 1;
		
		for( i = 0 ; i < 3 ; i++)
		{
			CURRENT[i] = CURRENT[i] * SEVERITY * -1;
		}
		
		SetSavedDvar( "player_swimWaterCurrent", ( CURRENT[0], CURRENT[1], CURRENT[2] ) );
		
		wait wait_time;
		
		for( i = 0 ; i < 3 ; i++ )
		{
			for( i = 0 ; i < 3 ; i++)
			{
				CURRENT[i] = CURRENT[i] * 0.5;
			}
			
			SetSavedDvar( "player_swimWaterCurrent", ( CURRENT[0], CURRENT[1], CURRENT[2] ) );
			
			wait wait_time * .25;
		}
		
		SetSavedDvar( "player_swimWaterCurrent", (0,0,0) );
		
		flag_set( "clear_to_tweak_player" );
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//dvar debug_low_start_frac
//dvar debug_med_start_frac
//dvar debug_thruster_server_frames_delta
THRUSTER_TOP	= 0;
THRUSTER_BOTTOM = 1;
THRUSTER_FRONT	= 2;
THRUSTER_LEFT	= 3;
THRUSTER_RIGHT	= 4;
THRUSTER_BACK	= 5;

THRUSTER_INTESITY_OFF  = 0;
THRUSTER_INTESITY_LOW  = 1;
THRUSTER_INTESITY_MED  = 2;
THRUSTER_INTESITY_HIGH = 3;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

space_thruster_audio()
{
	level endon( "disable_space" );
	flag_set( "enable_player_thruster_audio" );

	SetDvarIfUninitialized( "debug_low_start_frac", 0.1 );
	SetDvarIfUninitialized( "debug_med_start_frac", 0.4 );
	SetDvarIfUninitialized( "debug_thruster_server_frames_delta", 4 );
	//GetDvarFloat( "gpad_stick_deadzone_min" );

	level._thruster_ents = [];

	level.player thread attach_audio_points_to_player();
	level.player thread player_thruster_logic();

	//level thread debug_test_thruster_audio();

	level waittill( "kill_thrusters" );

	foreach( thruster in level._thruster_ents )
	{
		thruster notify( "stop" );
		thruster StopLoopSound();
		thruster Delete();
	}
	level._thruster_rig Delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

attach_audio_points_to_player()
{
	level endon( "kill_thrusters" );

	while( true )
	{
		flag_wait( "enable_player_thruster_audio" );

		level._thruster_rig = Spawn( "script_model", ( 0, 0, 0 ) );
		level._thruster_rig.origin = self.origin;
		level._thruster_rig.angles = self.angles;
		level._thruster_rig SetModel( "viewhands_us_lunar" );
		level._thruster_rig Hide();
		level._thruster_rig LinkToPlayerView( self, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
	
		for( index = 0; index < 6; index++ )
		{
			thruster = Spawn( "script_model", ( 0, 0, 0 ) );
			thruster SetModel( "tag_origin" );
	
			if ( index == THRUSTER_TOP )
			{
				thruster.origin = level._thruster_rig GetTagOrigin( "tag_jet_top" );
				thruster LinkTo( level._thruster_rig, "tag_jet_top", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			}
			else if ( index == THRUSTER_BOTTOM )
			{
				thruster.origin = level._thruster_rig GetTagOrigin( "tag_jet_bottom" );
				thruster LinkTo( level._thruster_rig, "tag_jet_bottom", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			}
			else if ( index == THRUSTER_FRONT )
			{
				thruster.origin = level._thruster_rig GetTagOrigin( "tag_jet_front" );
				thruster LinkTo( level._thruster_rig, "tag_jet_front", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			}
			else if ( index == THRUSTER_LEFT )
			{
				thruster.origin = level._thruster_rig GetTagOrigin( "tag_jet_left" );
				thruster LinkTo( level._thruster_rig, "tag_jet_left", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			}
			else if ( index == THRUSTER_RIGHT )
			{
				thruster.origin = level._thruster_rig GetTagOrigin( "tag_jet_right" );
				thruster LinkTo( level._thruster_rig, "tag_jet_right", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			}
			else if ( index == THRUSTER_BACK )
			{
				thruster.origin = level._thruster_rig GetTagOrigin( "tag_jet_back" );
				thruster LinkTo( level._thruster_rig, "tag_jet_back", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			}
	
			//level thread wtf_is_it( thruster, ( 50, 0, 0 ) );
			thruster thread thruster_audio_logic( index );
			level._thruster_ents[ index ] = thruster;
		}

		flag_waitopen( "enable_player_thruster_audio" );

		foreach( thruster in level._thruster_ents )
		{
			thruster notify( "stop" );
			thruster Delete();
		}
		level._thruster_rig Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

thruster_audio_logic( id )
{
	self endon( "stop" );

	self.prev_intensity = 0;

	while( true )
	{
		self waittill( "thruster_update", value );

		if( value != self.prev_intensity )
		{
			//text = debug_thruster_text( id, value );
			//IPrintLn( "THRUSTER " + text[ 0 ] + ": setting to " + text[ 1 ] );

			self thread play_thruster_loop_audio( id, Int( value ) );
		}
		self.prev_intensity = value;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

play_thruster_loop_audio( id, value )
{
	self notify( "play_looping_audio" );
	self endon( "play_looping_audio" );
	if ( level.thruster_timer > 0 )
	{
		switch( value )
		{
			case 0:
				level.looping_thruster_sfx StopLoopSound();
				break;
			case 1:
				//self PlaySound( "space_jetpack_boost_start_small" );
				//level.looping_thruster_sfx StopLoopSound();
				//level.looping_thruster_sfx PlayLoopSound( "space_jetpack_boost_lp" );
				break;
			case 2:
				self PlaySound( "space_jetpack_boost_start_small" );
				
				thread thruster_timer_logic();
				level.looping_thruster_sfx StopLoopSound();
				level.thruster_oneshot StopSounds();
				level.looping_thruster_sfx PlayLoopSound( "space_jetpack_boost_lp" );
				level.thruster_oneshot PlaySound( "space_jetpack_boost_oneshot" );
				break;
			case 3:
				self PlaySound( "space_jetpack_boost_start_large" );
				thread thruster_timer_logic();
				level.looping_thruster_sfx StopLoopSound();
				level.thruster_oneshot StopSounds();
				level.looping_thruster_sfx PlayLoopSound( "space_jetpack_boost_lp_sprint" );
				level.thruster_oneshot PlaySound( "space_jetpack_boost_oneshot" );
				break;
		}	
	}
}

thruster_timer_logic()
{
	level.thruster_timer = 0;
	wait 0.25;
	level.thruster_timer = 1;	
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_thruster_logic()
{
	level endon( "kill_thrusters" );
	self endon( "death" );

	while( true )
	{
		flag_wait( "enable_player_thruster_audio" );

		prev_dir_and_state		= [];
		prev_dir_and_state[ 0 ] = 0.0;
		prev_dir_and_state[ 1 ] = 0.0;
		prev_dir_and_state[ 2 ] = 0.0;

		while( flag( "enable_player_thruster_audio" ) )
		{
			dir_and_state = self parse_input_data_for_thruster();

			if( dir_and_state[ 0 ] != prev_dir_and_state[ 0 ] || dir_and_state[ 1 ] != prev_dir_and_state[ 1 ] || dir_and_state[ 2 ] != prev_dir_and_state[ 2 ] )
			{
				set_player_thruster_data( dir_and_state, prev_dir_and_state );
			}
			prev_dir_and_state = dir_and_state;

			wait ( 0.05 * GetDvarInt( "debug_thruster_server_frames_delta" ) );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

parse_input_data_for_thruster()
{
	current = [];

	// parse inputs
	stick = self GetNormalizedMovement();
	for( index = 0; index < 2; index++ )
	{
		if( abs( stick[ index ] ) < GetDvarFloat( "debug_low_start_frac" ) )
		{
			current[ index ] = THRUSTER_INTESITY_OFF;
		}
		else if( abs( stick[ index ] ) >= GetDvarFloat( "debug_low_start_frac" ) && abs( stick[ index ] ) < GetDvarFloat( "debug_med_start_frac" ) )
		{
			current[ index ] = THRUSTER_INTESITY_LOW;
		}
		else
		{
			current[ index ] = THRUSTER_INTESITY_MED;
		}

		if( current[ index ] > 0 && flag( "spacesprint" ) )
		{
			current[ index ] = THRUSTER_INTESITY_HIGH;
		}
		
		if( stick[ index ] < 0 )
		{
			current[ index ] *= -1;
		}
	}

	current[ 2 ] = 0;
	if( self JumpButtonPressed() || self FragButtonPressed() )
	{
		if( flag( "spacesprint" ) )
		{
			current[ 2 ] += THRUSTER_INTESITY_HIGH;
		}
		else
		{
			current[ 2 ] += THRUSTER_INTESITY_MED;
		}
	}
	// MJS <TODO> need to figure out correct button checks for stance change
	if( self ButtonPressed( "BUTTON_CROUCH" ) || self ButtonPressed( "BUTTON_PRONE" ) || self SecondaryOffhandButtonPressed() )
	{
		if( flag( "spacesprint" ) )
		{
			current[ 2 ] -= THRUSTER_INTESITY_HIGH;
		}
		else
		{
			current[ 2 ] -= THRUSTER_INTESITY_MED;
		}
	}

	return current;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

set_player_thruster_data( new, old )
{
	Assert( IsArray( new ) && IsArray( old ) );

	for( index = 0; index < new.size; index++ )
	{
		if ( new[ index ] != old[ index ] )
		{
			thrusters = get_thrusters_by_axis( index, new[ index ] );
			foreach ( thruster in thrusters )
			{
				level._thruster_ents[ thruster ] notify( "thruster_update", abs( new[ index ] ) );
			}
			if( ( new[ index ] < 0 && old[ index ] > 0 ) || ( new[ index ] > 0 && old[ index ] < 0 ) )
			{
				thrusters = get_thrusters_by_axis( index, old[ index ] );
				foreach ( thruster in thrusters )
				{
					level._thruster_ents[ thruster ] notify( "thruster_update", 0 );
				}
			}
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_thrusters_by_axis( axis, sign )
{
	thrusters = [];
	switch ( axis )
	{
		case 0:
			if( sign >= 0 )
			{
				thrusters[ thrusters.size ] = THRUSTER_BACK;
			}
			if( sign <= 0 )
			{
				thrusters[ thrusters.size ] = THRUSTER_FRONT;
			}
			break;

		case 1:
			if( sign >= 0 )
			{
				thrusters[ thrusters.size ] = THRUSTER_LEFT;
			}
			if( sign <= 0 )
			{
				thrusters[ thrusters.size ] = THRUSTER_RIGHT;
			}
			break;

		case 2:
			if( sign >= 0 )
			{
				thrusters[ thrusters.size ] = THRUSTER_BOTTOM;
			}
			if( sign <= 0 )
			{
				thrusters[ thrusters.size ] = THRUSTER_TOP;
			}
			break;

		default:
			AssertMsg( "invalid axis" );

	}

	return thrusters;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debug_thruster_text( loc_index, intensity_index )
{
	msgs = [];

	if( IsDefined( loc_index ) )
	{
		if( THRUSTER_TOP == loc_index )
		{
			msgs[ msgs.size ] = "TOP";
		}
		else if ( THRUSTER_BOTTOM == loc_index )
		{
			msgs[ msgs.size ] = "BOTTOM";
		}
		else if ( THRUSTER_FRONT == loc_index )
		{
			msgs[ msgs.size ] = "FRONT";
		}
		else if ( THRUSTER_LEFT == loc_index )
		{
			msgs[ msgs.size ] = "LEFT";
		}
		else if ( THRUSTER_RIGHT == loc_index )
		{
			msgs[ msgs.size ] = "RIGHT";
		}
		else if ( THRUSTER_BACK == loc_index )
		{
			msgs[ msgs.size ] = "BACK";
		}
	}
	else
	{
		msgs[ msgs.size ] = "";
	}

	if( IsDefined( intensity_index ) )
	{
		if( THRUSTER_INTESITY_OFF == intensity_index )
		{
			msgs[ msgs.size ] = "OFF";
		}
		else if ( THRUSTER_INTESITY_LOW == intensity_index )
		{
			msgs[ msgs.size ] = "LOW";
		}
		else if ( THRUSTER_INTESITY_MED == intensity_index )
		{
			msgs[ msgs.size ] = "MEDIUM";
		}
		else// if ( THRUSTER_INTESITY_HIGH == intensity_index )
		{
			msgs[ msgs.size ] = "HIGH";
		}
	}
	else
	{
		msgs[ msgs.size ] = "";
	}

	return msgs;
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debug_test_thruster_audio()
{
	while( true )
	{
		for( j = 1; j < 4; j++ )
		{
			for( i = 0; i < level._thruster_ents.size; i++ )
			{
				text = debug_thruster_text( i, j );
				IPrintLn( "Playing thruster " + text[ 0 ] + "'s " + text[ 1 ] + " burst audio" );
	
				//level._thruster_ents[ i ] notify( "thruster_update", j );
				switch( j )
				{
					case 1:
						level._thruster_ents[ i ] PlaySound( "space_jetpack_boost_start_small" );
						break;
					case 2:
						level._thruster_ents[ i ] PlaySound( "space_jetpack_boost_start_med" );
						break;
					case 3:
						level._thruster_ents[ i ] PlaySound( "space_jetpack_boost_start_large" );
				}			
				wait( 2.0 );
			}
		}
	
		for( j = 0; j < 2; j++ )
		{
			for( i = 0; i < level._thruster_ents.size; i++ )
			{
				text = debug_thruster_text( i, j );
	
				switch( j )
				{
					case 0:
						IPrintLn( "Playing thruster " + text[ 0 ] + "'s loop audio" );
						//level._thruster_ents[ i ] PlayLoopSound( "space_jetpack_boost_lp" );
						break;
					case 1:
						IPrintLn( "Playing thruster " + text[ 0 ] + "'s sprint loop audio" );
						//level._thruster_ents[ i ] PlayLoopSound( "space_jetpack_boost_lp_sprint" );
						break;
				}
				wait( 2.0 );
				level._thruster_ents[ i ] StopLoopSound();
				wait( 1.0 );
			}
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

wtf_is_it( ent, color )
{
	while( true )
	{
		start = level.player.origin;//level.player GetEye();
		if ( IsDefined ( color ) )
		{
			Line( start, ent.origin, color, 1.0, false, 10 );
		}
		else
		{
			Line( start, ent.origin, ( 0, 0, 50 ), 1.0, false, 10 );
		}
		wait( 1.0 );
	}
}