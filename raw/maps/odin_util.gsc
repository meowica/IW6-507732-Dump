//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Odin Mission Utils											**
//                                                                          **
//    Created: 	2/12/13	Neversoft											**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


// Teleport player to start point with sTargetname
move_player_to_start_point( sTargetname )
{
	Assert( IsDefined( sTargetname ) );
	start = GetEnt( sTargetname, "targetname" );
	level.player SetOrigin( start.origin );

	lookat = undefined;
	if ( IsDefined( start.target ) )
	{
		lookat = GetEnt( start.target, "targetname" );
		Assert( IsDefined( lookat ) );
	}

	if ( IsDefined( lookat ) )
	{
		level.player SetPlayerAngles( VectorToAngles( lookat.origin - start.origin ) );
	}
	else
	{
		level.player SetPlayerAngles( start.angles );
	}
}

// Teleports actor to origin_targetname
actor_teleport( actor, origin_targetname )
{
	org = GetEnt( origin_targetname, "targetname" );

	if ( IsPlayer( actor ) )
	{
		actor SetPlayerAngles( org.angles );
		actor SetOrigin( org.origin );
	}
	else if ( IsAI( actor ) )
	{
		actor ForceTeleport( org.origin, org.angles );
	}
}

// Triggers a trigger of sTargetName
safe_trigger_by_targetname( sTargetName )
{
	trigger = GetEnt( sTargetName, "targetname" );
	
	if ( !IsDefined( trigger ) )
	{
	   	// IPrintLn( "Safe Trigger failed: " + sTargetName );
	   	return;
	}
	
	trigger notify( "trigger" );

	// Handle trigger_once and "touch_once" triggers.
	if( trigger.classname == "trigger_once" || ( isDefined( trigger.spawnflags ) && trigger.spawnflags & 64 ))
	{
		trigger delete();
	}
}

// Triggers a trigger of sNoteworthy
safe_trigger_by_noteworthy( sNoteworthy )
{
	trigger = GetEnt( sNoteworthy, "script_noteworthy" );
	
	if ( !IsDefined( trigger ) )
	{
	   	//IPrintLn( "Safe Trigger failed: " + sNoteworthy );
	   	return;
	}
	
	trigger notify( "trigger" );

	// Handle trigger_once and "touch_once" triggers.
	if( trigger.classname == "trigger_once" || ( isDefined( trigger.spawnflags ) && trigger.spawnflags & 64 ))
	{
		trigger delete();
	}
}

// Generic function to teleport squad members to start point origins and assign them an initial node to move to
//  SAMPLE KVPs:
//		On origin --> ALLY_BRAVO_powerstealth_teleport
//  		On node --> ALLY_BRAVO_powerstealth_node
teleport_squad( checkpoint_name, deltaecho )
{
	if ( !IsDefined( deltaecho ) )
	{
		squad_names = [ "ALLY_ALPHA", "ALLY_BRAVO", "ALLY_CHARLIE", "ALLY_DELTA", "ALLY_ECHO" ];
	}
	else
	{
		squad_names = [ "ALLY_ALPHA", "ALLY_BRAVO", "ALLY_CHARLIE" ];
	}
	
	for ( i = 0; i < squad_names.size; i++ )
	{
		actor_teleport( level.squad[ squad_names[ i ] ], squad_names[ i ] + "_" + checkpoint_name + "_teleport" );
		intro_node = GetNode( squad_names[ i ] + "_" + checkpoint_name + "_node", "targetname" );
		level.squad[ squad_names[ i ] ] SetGoalNode( intro_node );
	}
}

teleport_squadmember( checkpoint_name, squad_name )
{
	actor_teleport( level.squad[ squad_name ], squad_name + "_" + checkpoint_name + "_teleport" );
	intro_node = GetNode( squad_name + "_" + checkpoint_name + "_node", "targetname" );
	level.squad[ squad_name ] SetGoalNode( intro_node );
}

// Safely delete stuff based on targetname
safe_delete_targetname( targetname )
{
	safe_delete_array( getEntArray( targetname, "targetname" ));
}

// Safeley delete stuff based on script_noteworthy
safe_delete_noteworthy( noteworthy )
{
	safe_delete_array( getEntArray( noteworthy, "script_noteworthy" ));
}

// Safely delete one object
safe_delete( object )
{
	if( isDefined( object ))
	{
		object delete();
	}
	else
	{
		//iprintln( "safe_delete error: Tried to delete undefined object" );
	}
}

// Safely deletes a bunch of objects
safe_delete_array( array )
{
	foreach( object in array )
	{
		safe_delete( object );
	}
}

// This is a better version of add_dialog_line.
// It acts like a chat room message feed.
// New messages alway appears at the bottom, and push old messages up
// The old version would put new messages in any free slot, which caused
// messages to appear out of order and sloppy.
add_debug_dialogue( name, msg, name_color )
{
	if ( GetDvarInt( "loc_warnings", 0 ) )
		return;

	if ( !isdefined( level.debug_dialogue_huds ) )
	{
		level.debug_dialogue_huds = [];
	}
	color = "^3";

	if ( IsDefined( name_color ) )
	{
		switch( name_color )
		{
			case "r":
			case "red":
				color = "^1";
				break;
			case "g":
			case "green":
				color = "^2";
				break;
			case "y":
			case "yellow":
				color = "^3";
				break;
			case "b":
			case "blue":
				color = "^4";
				break;
			case "c":
			case "cyan":
				color = "^5";
				break;
			case "p":
			case "purple":
				color = "^6";
				break;
			case "w":
			case "white":
				color = "^7";
				break;
			case "bl":
			case "black":
				color = "^8";
				break;
		}
	}

	// Create the new elem
	hudelem = maps\_hud_util::createFontString( "default", 1.5 );
	hudelem.location = 0;
	hudelem.alignX = "left";
	hudelem.alignY = "top";
	hudelem.foreground = 1;
	hudelem.sort = 20;

	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.5 );
	hudelem.alpha = 1;
	hudelem.x = 40;
	hudelem.y = 325;
	hudelem.label = " " + color + "< " + name + " > ^7" + msg;
	hudelem.color = ( 1, 1, 1 );

	// Add new element at the start of the list
	level.debug_dialogue_huds = array_insert( level.debug_dialogue_huds, hudelem, 0 );

	// Move old elements up
	foreach( i, elem in level.debug_dialogue_huds )
	{
		// Skip the one we just added
		if( i == 0  )
			continue;

		// Move it up
		if( isDefined( elem ))
			elem.y = 325 - i * 18;
	}

	wait( 2 );
	timer = 2 * 20;
	hudelem FadeOverTime( 6 );
	hudelem.alpha = 0;

	for ( i = 0; i < timer; i++ )
	{
		hudelem.color = ( 1, 1, 0 / ( timer - i ) );
		wait( 0.05 );
	}
	wait( 4 );

	hudelem Destroy();
	array_removeUndefined( level.debug_dialogue_huds );

	//level.dialogue_huds[ index ] = undefined;
}


teleport_to_target()
{
	org = self get_target_ent();
	if ( !isdefined( org.angles ) )
		org.angles = self.angles;
	self ForceTeleport( org.origin, org.angles );
}


// Spawns an array of space guys
spawn_odin_actor_array( spawner_targetname, force_spawn )
{
	spawners = GetEntArray( spawner_targetname, "targetname" );
	guys = [];
	foreach( spawner in spawners )
	{
		guys[guys.size] = spawner spawn_odin_actor_internal( force_spawn );
	}
	return guys;
}

// Spawns just one guy
spawn_odin_actor_single( spawner_targetname, force_spawn )
{
	spawner = GetEnt( spawner_targetname, "targetname" );
	if( !isDefined( spawner ))
	{
		//AssertMsg( "spawn_odin_actor_single() invalid spawner - " + spawner_targetname );
		return undefined;
	}
	guy = spawner spawn_odin_actor_internal( force_spawn );
	return guy;
}

// JR-FIXME Backwards compatible support - DELETE THIS
spawn_odin_actor( spawner_targetname, force_spawn )
{
	return spawn_odin_actor_single( spawner_targetname, force_spawn );
}


// Spawn a generic space actor
spawn_odin_actor_internal( spawner_targetname, force_spawn )
{
	if( !isDefined( self ))
	{
		AssertMsg( "spawn_odin_actor_internal() couldnt find spawner (self)" );
		return undefined;
	}
	if( !isDefined( force_spawn ))
	{
		force_spawn = false;
	}
	guy = self spawn_ai( force_spawn );
	guy thread maps\_space_ai::enable_space();

	// Teleport to the target
	org = self get_target_ent();
	if( isDefined( org ))
	{
		if ( !isdefined( org.angles ) )
			org.angles = self.angles;
		guy ForceTeleport( org.origin, org.angles );
	}

	// Initial orientation?
	if( isDefined( self.script_parameters ))
	{
		guy thread maps\_space_ai::init_actor_orientation( self.script_parameters );
	}

	// Do angled nodes
	guy thread maps\_space_ai::handle_angled_nodes();

	// Set an initial target node
	if( isDefined( org.target ))
	{
		default_node = GetNode( org.target, "targetname" );
		if( isDefined( default_node ))
		{
			guy SetGoalNode( default_node );
			guy.goalradius = 4;
		}
	}

	// Force more exposed time
	//guy thread maps\_space_ai::force_more_exposed_time();

	return guy;
}

add_light_to_actor ( actor_team )
{
    actor_light_fx_loc = spawn_tag_origin();
	location = self GetTagOrigin ("tag_eye");
	//actor_light_fx_loc.origin = location;
	actor_light_fx_loc.origin = (location + (-9,0,2));
    actor_light_fx_loc LinkTo (self, "tag_eye");
	//if (!IsDefined (actor_team ))
		actor_light_fx = getfx( "light_blue_steady_FX" );
	if (actor_team == "ally" )
		actor_light_fx = getfx( "light_blue_steady_FX" );
	if (actor_team == "axis" )
		actor_light_fx = getfx( "amber_light_45_beacon_nolight_glow" );
	
	//actor_light_fx = getfx( "glow_red_light_400_strobe" );
	//IPrintLnBold ("playing FX");
	//PlayFXOnTag( actor_light_fx, level.ally, "tag_eye" ); // 
	while ( IsAlive (self) )
	{
		PlayFXOnTag( actor_light_fx, actor_light_fx_loc, "tag_origin" );
		wait 0.2;		
		StopFXOnTag( actor_light_fx, actor_light_fx_loc, "tag_origin" );
		wait 0.8;
	}
	actor_light_fx_loc Delete();
}

// FOV settings for beginning of mission
set_mission_view_tweaks()
{
	
	SetSavedDvar( "cg_fov" , ( 50 ) );
	if (!flag ( "spin_start_dialogue" ))
		lerp_fov_overtime ( 0.05, 50);
	flag_wait( "spin_start_dialogue" );
	lerp_fov_overtime ( 10, 60);
	flag_wait( "end_clear" );
	lerp_fov_overtime ( 5, 65);
	
}

floating_corpses( ragdolls, jolter )
{
    	//flag_wait( "some_flag" );
    	spawners = GetEntArray( ragdolls, "targetname" );
    	foreach( spawner in spawners )
	{
      	guy = spawner spawn_ai( true );
        	if( spawn_failed( guy ) )
        	{
        		continue;
        	}
        
        	guy.team = "neutral";
        	guy.diequietly = true;
        	guy.no_pain_sound = true;
        	
        	// Blood effect on body       	
        	fx = spawn_tag_origin();
        	fx LinkTo( guy );
        	PlayFXOnTag( GetFX( "sp_blood_float_static" ), guy, "tag_origin" );
        	
        	guy.forceRagdollImmediate = true;

        	guy Kill();
    	}
    
    	wait 1.0;

    	// Fire a folt from the ground to get them bodies movin'
    	jolt_org_array = GetEntArray( jolter, "targetname" );
    	vec = randomvector( 0.3 );
//	vec = (-0.0491913, 0.122717, 0.0900787 );  // tagTJ: value produced some decent results.  Might implement an override that allows for a specific number to be input as the vector for more predictable results
    
    	foreach( jolt in jolt_org_array )
    	{
    		PhysicsJolt( jolt.origin, 70, 30, vec );
    	}

    	// Give the player a physics aura
    	count = 0;
    	while( 1 )
    	{
            if ( flag( "odin_escape_start_spinning_room" ) || flag( "spin_clear" ) )
            {
            	return;
            }
            PhysicsExplosionSphere( level.player.origin, 45, 32, 0.15 );
            wait 0.05;
    	}
}


//================================================================================================
// TRANSIENT FILE SCRIPTS
//================================================================================================
load_transient ( file_name )
{
	// TRANSIENTS - CF
	///*
	//iprintlnbold( "unloadalltransients" );
	unloadalltransients();
	//iprintlnbold( "loadtransient: " + file_name );
	loadtransient( file_name );
	//*/
}

sync_transients()
{
	// TRANSIENTS - CF
	///*
	//iprintlnbold( "synctransients" );
	while ( !synctransients() )
	{
		wait 0.05;
	}
	//iprintlnbold( "synctransients completed" );
	//*/
}

//================================================================================================
// Moving Objects Handler
//================================================================================================
//Name: moving_objects_handler( <script_noteworthy> )
//
//Purpose: These two functions handle linking a series of brushmodels to an origin point in order to validate/invalidate path/cover nodes when a moving object passes over.  
//To use, place a prefab with the cover system built in and give it a script_noteworthy.
//
//Example: mover_origin = moving_objects_handler( “floating_crate” );
//
//Call: When you want to define the mover’s origin.
//
//Returns: An origin in the prefab that moves and has everything linked to it.
//
//Arguments: 
//<script_noteworthy>: This string is the script_noteworthy placed on the prefab you want to move
//================================================================================================

moving_objects_handler( area_objects )
{
	connector = undefined;
	disconnector = undefined; 
	system_origin = undefined;
	
	objects = GetEntArray( area_objects , "script_noteworthy" );
	
	foreach( moving_object in objects )
	{
		if( moving_object.script_parameters == "moving_object_origin" )
		{
			system_origin = moving_object;
		}	
	}
	
	foreach( moving_object in objects )
	{
		if( moving_object.script_parameters == "moving_object" )
		{
			moving_object LinkTo( system_origin );
		}	
		if( moving_object.script_parameters == "path_connector" )
		{
			moving_object LinkTo( system_origin );
			system_origin.connector = moving_object;
		}
		if( moving_object.script_parameters == "path_disconnector" )
		{
			moving_object LinkTo( system_origin );
			system_origin.disconnector = moving_object;
		}
	}
	thread path_disconnector( system_origin.disconnector, system_origin.connector );
	return system_origin; 
}


// Disconnects path nodes in front of the platform
path_disconnector( disconnector, connector  )
{
	self endon( "death" );
	self endon( "stop_scripts" );
	
	// Get all the trigger brushes
	triggers = GetEntArray( "moving_platform_path_trigger", "targetname" );
	
	connect_triggers = GetEntArray( "path_connector" , "script_noteworthy" );
	disconnect_triggers = GetEntArray( "path_disconnector" , "script_noteworthy" );
	
//	foreach( trig in connect_triggers )
//	{
//		trig.connected = false;
//		if( !isDefined( trig.script_parameters ))
//		{
//			trig ConnectPaths();
//			trig.connected = true;
//		}
//		trig NotSolid();
//	}
//	
//		foreach( trig in disconnect_triggers )
//	{
//		trig.connected = false;
//		if( !isDefined( trig.script_parameters ))
//		{
//			trig ConnectPaths();
//			trig.connected = true;
//		}
//		trig NotSolid();
//	}

	
	// Watch for the platform to run into each volume
	while( 1 )
	{
		disconnector Solid();
		connector Solid();
		
		disconnector DisconnectPaths();
		connector ConnectPaths();
		
		disconnector NotSolid();
		connector NotSolid();
		
		wait 0.2;
	}
}


//====================================================================
// Sliding door helper scripts
//====================================================================
// name: entity targetname
// time: How long it takes to open
// accel: Movement acceleration and deceleration
// lock_notify: The notify event that will permanently lock the door
// unlock_flag: (Optional) Door will start locked untill this flag is true.
// JR-TODO - This can be improved by separating into 2 version, auto and scripted.
// Scripted version should function based on notifies only, which would work for flags AND true notifies
create_sliding_space_door( name, time, accel, delay, automatic, lock_notify, unlock_flag )
{
	// Get all the ents in the door
	parts = GetEntArray( name, "script_noteworthy" );
	
	if( !isDefined( parts ) || parts.size == 0 )
	{
		iprintln( "create_sliding_space_door failed. No parts" );
		return;
	}

	// Get all the nodes set up
	door_org = undefined;
	door = undefined;
	door_open = undefined;

	foreach( part in parts )
	{
		// Nodes
		if( part.classname == "script_origin" )
		{
			if( isDefined( part.targetname ))
			{
				if( part.targetname == "door_closed_node" )
				{
					door_org = part;
				}
				else if( part.targetname == "door_node" )
				{
					door = part;
				}
				else if( part.targetname == "door_open_node" )
				{
					door_open = part;
				}
			}
		}
	}

	// Connect the nodes to the main piece
	door_org.door = door;
	door_org.door_open = door_open;
	door_org.time = time;
	door_org.accel = accel;
	door_org.delay = delay;
	door_org.automatic = automatic;
	door_org.lock_notify = lock_notify;
	door_org.unlock_flag = unlock_flag;
	door_org.door_name = name;

	// Setup the actual door parts
	door_parts = GetEntArray( door_org.door.target, "targetname" );
	foreach( part in door_parts )
	{
		part linkTo( door_org.door );
	}

	// Setup trigger for automatic door
	door_org.trigger = spawn( "trigger_radius", door_org.origin, 3, door_org.radius, 64 );
	if( isDefined( automatic ) && automatic == true )
	{
		door_org.trigger trigger_on();
		door_org thread automatic_sliding_door_logic();
	}
	// Non automatic scripted control
	else
	{
		door_org thread sliding_door_logic();
	}

	// Start the automatic logic
	door_org thread sliding_door_lock();

	return door_org;
}

// Handles opening and closing the door when actors approach
automatic_sliding_door_logic()
{
	self endon( "death" );
	level endon( self.lock_notify );
	self.state = "open";

	self.trigger.triggered = false;
	self.trigger thread automatic_sliding_door_detector( self.lock_notify );

	while( 1 )
	{
		// Open or stay open
		if( self.trigger.triggered )
		{
			// Check for locked state
			if( isDefined( self.unlock_flag ) && !flag( self.unlock_flag ))
			{
				wait 0.5;
				continue;
			}

			if( self.state == "closing" || self.state == "closed" )
			{
				// at first try to open doors, turning on a transient sync to make sure transient load is complete
				//flag_set( "presat_synctransients");	// JR - This was from Factory

				self.state = "open";
				if( self.delay > 0 )
				{
					wait self.delay;
				}
				self.door moveTo( self.door_open.origin, self.time, self.accel );

				// SFX
				// JR TODO - I turned these off because they are from Factory. Please update.
				//if (self.door_name == "sliding_door_sat_enter_02" || self.door_name == "sliding_door_sat_exit_01")
				//	thread maps\factory_audio::sfx_metal_door_open(self);
				//else
				//	thread maps\factory_audio::sfx_glass_door_open(self);
			}
		}

		// Close or stay closed
		else
		{
			if( self.state == "opening" || self.state == "open" )
			{
				self.state = "closed";
				if( self.delay > 0 )
				{
					wait self.delay;
				}
				self.door moveTo( self.origin, self.time, self.accel );
				
				// SFX
				// JR TODO - I turned these off because they are from Factory. Please update.
				//if (self.door_name == "sliding_door_sat_enter_02" || self.door_name == "sliding_door_sat_exit_01")
				//	thread maps\factory_audio::sfx_metal_door_close(self);
				//else
				//	thread maps\factory_audio::sfx_glass_door_close(self);
			}
		}
		
		wait 0.1;
	}
}

// Loops checking if an actor is near the door
automatic_sliding_door_detector( lock_notify )
{
	self endon( "death" );
	level endon( lock_notify );
	while( 1 )
	{
		self.triggered = false;
		self waittill( "trigger" );
		self.triggered = true;

		wait 0.5;
	}
}

// Opens the door when a flag is set
sliding_door_logic()
{
	self endon( "death" );
	level endon( self.lock_notify );

	// If an unlock flag is set, initialize the door to closed
	if( isDefined( self.unlock_flag ) && !flag( self.unlock_flag ))
	{
		self.state = "closed";
		self.door moveTo( self.origin, 0.1, self.accel );
		flag_wait( self.unlock_flag );
		
		if( self.state == "closing" || self.state == "closed" )
		{
			// at first try to open doors, turning on a transient sync to make sure transient load is complete
			//flag_set( "presat_synctransients");	// JR - This was from Factory

			self.state = "open";
			if( self.delay > 0 )
			{
				wait self.delay;
			}
			self.door moveTo( self.door_open.origin, self.time, self.accel );

			// SFX
			// JR TODO - I turned these off because they are from Factory. Please update.
			//if (self.door_name == "sliding_door_sat_enter_02" || self.door_name == "sliding_door_sat_exit_01")
			//	thread maps\factory_audio::sfx_metal_door_open(self);
			//else
			//	thread maps\factory_audio::sfx_glass_door_open(self);
		}
	}
}

// Turns the door off and locks it shut
sliding_door_lock()
{
	self endon( "death" );

	level waittill( self.lock_notify );

	// Close it
	self.state = "closed";
	if( self.delay > 0 )
	{
		wait self.delay;
	}
	self.door moveTo( self.origin, self.time, self.accel );

	// JR TODO - Turned this off, its from Factory. Please update.
	//thread maps\factory_audio::sfx_glass_door_close(self);

	// Destroy the trigger
	self.trigger trigger_off();
	self.trigger delete();
}

// Takes a value and returns a 0 - 1 float based a min and max
normalize_value( min_val, max_val, val_to_normalize )
{

    if ( val_to_normalize > max_val )
    {
        return 1.0;
    }
    else if ( val_to_normalize < min_val )
    {
        return 0.0;
    }    
    return (( val_to_normalize - min_val ) / ( max_val -  min_val ));
}


// Use a 0 - 1 float to generate a value based on min and max values
// zero is the min value, 1 is the max value, anything in between would be factored.
factor_value_min_max( min_val, max_val, factor_val )
{
    return ( max_val * factor_val ) + ( min_val * ( 1 - factor_val ));
}


//====================================================================
// Input checking function for directions or button presses
//====================================================================
// Returns a bool of true (is being tilted that way) or false
// bDirectionCheck:		A bool that flags if you want to check the direction or a button press
// direction_string:	The direction you want to check ( "up" , "down" "left" "right" );
// example:				bCheck = maps\odin_util::input_check( true , "up" );
input_check( bDirectionCheck , direction_string  )
{
	bInput		= false; 	// This is the value we return to other functions
	tilt_value	= 0; 		//Storing this value for use down below
	
	if( bDirectionCheck == true )
	{ //CHECK FOR A STICK DIRECTION
		input = level.player GetNormalizedMovement();
		switch ( direction_string )	//Switch takes the direction string and converts our input into something checkable (see below)
		{
			case "up":
				tilt_value = input[0] ;
				break;
			
			case "down":
				tilt_value = ( input[0] * -1 ) ;
				break;
				
			case "left":
				tilt_value = ( input[1] * -1 ) ;
				break;
				
			case "right":
				tilt_value = input[1] ;
				break;
		
			default:
				break;
		}
		
		if( tilt_value >= .15 )
		{
			bInput = true;
			return bInput;
		}
		else
		{
			bInput = false;
			return bInput;
		}
	}
	else
	{
		return;
	}
}

//====================================================================
// Check anim time (useful for waiting during anims started form SetAnimKnob
//====================================================================
//  Use in conjunction with while ( !check_anim_time( animname, anime, time  ) )
//
check_anim_time( animname, anime, time )
{
	curr_time = self GetAnimTime( level.scr_anim[ animname ][ anime ] );
	if ( curr_time >= time ) 
	{
		return true;
	}
	
	return false;
 
}

moving_cover_medium()
{
	// Physics vehicle model
	cover_veh = spawn_vehicle_from_targetname( "cover_phys_test" );
	
	cover_model = spawn( "script_origin", cover_veh GetOrigin() );
//	cover_model SetModel( "mp_dart_crate_02" );
	
//	cover_model LinkTo( cover_veh, "tag_origin" );
	

	
	// Non-physics cover model
	cover = GetEnt( "floating_cover_medium_model", "targetname" );
	cover_col = GetEnt( "floating_cover_medium_col", "targetname" );
	cover_col LinkTo( cover );
	
	cover SetCanDamage( true );
	
	cover thread damageListener();
	cover_col thread cover_path_management();
	
	// Set up player to interact with system
//	level.player thread player_push_cover_physics( cover_veh );
	level.player thread player_push_cover_scripted( cover );
	
	cover.angle_rot_rate = [ randomInt( 2 ), randomInt( 1 ), randomInt( 4 ) ];
	cover.old_rot_rate = cover.angle_rot_rate;
	
	while ( 1 )
	{
		cover.angles = ( cover.angles[ 0 ] + cover.angle_rot_rate[ 0 ], cover.angles[ 1 ] + cover.angle_rot_rate[ 1 ], cover.angles[ 2 ] + cover.angle_rot_rate[ 2 ] );
		
//		angle++;
		
		wait 0.05;
	}
}

damageListener()
{
	while ( 1 )
	{
//		self waittill( "damage" );
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		
		self.angles = ( self.angles[ 0 ] + randomInt( 5 ), self.angles[ 1 ] + randomInt( 5 ), self.angles[ 2 ] + randomInt( 5 ) );
		
		self thread cover_impulse( direction_vec, type );
	}
}

PISTOL_IMPULSE = 45;
IMPACT_IMPULSE = 0.1;
CHAR_IMPULSE = 5;

cover_impulse( direction_vec, type )
{
	if ( type == "MOD_PISTOL_BULLET" )
		impulse = PISTOL_IMPULSE;
	else
		impulse = IMPACT_IMPULSE;
	
	self MoveTo( ( self.origin[ 0 ] + ( impulse * direction_vec[ 0 ] ), self.origin[ 1 ] + ( impulse * direction_vec[ 1 ] ), self.origin[ 2 ] + ( impulse * direction_vec[ 2 ] ) ), 3, 0.05, 2.4 );
	
	old_rot_rate = self.angle_rot_rate;
	
	for( i = 8; i > 0; i-- )
	{
		self.angle_rot_rate[ 0 ] = self.angle_rot_rate[ 0 ] + ( i / 100 );
		self.angle_rot_rate[ 1 ] = self.angle_rot_rate[ 1 ] + ( i / 100 );
		self.angle_rot_rate[ 2 ] = self.angle_rot_rate[ 2 ] + ( i / 100 );
		wait 0.2;
	}
	
	for( i = 0; i < 8; i++ )
	{
		self.angle_rot_rate[ 0 ] = ( ( self.old_rot_rate[ 0 ] - self.angle_rot_rate[ 0 ] ) * ( i / 10 ) ) + self.angle_rot_rate[ 0 ];
		self.angle_rot_rate[ 1 ] = ( ( self.old_rot_rate[ 1 ] - self.angle_rot_rate[ 1 ] ) * ( i / 10 ) ) + self.angle_rot_rate[ 1 ];
		self.angle_rot_rate[ 2 ] = ( ( self.old_rot_rate[ 2 ] - self.angle_rot_rate[ 2 ] ) * ( i / 10 ) ) + self.angle_rot_rate[ 2 ];
		wait ( i / 10 ) * 2;
	}
	
	self.angle_rot_rate = self.old_rot_rate;
}

player_push_cover_physics( cover )
{
	// Give the player a physics aura
	while( 1 )
	{
		// Physics version
		PhysicsExplosionSphere( level.player.origin, 45, 32, 0.15 );
		
		wait 0.05;
	}	
}

player_push_cover_scripted( cover )
{
	vol = GetEnt( "vol_phys_cover_medium", "script_noteworthy" );
	
	vol EnableLinkTo();
	
	vol LinkTo( cover );
	
	// Give the player a physics aura
	while( 1 )
	{
		if ( self IsTouching( vol ) )
		{
			IPrintLn( "touching_cover" );
			
			trace = BulletTrace( self.origin, cover.origin, false );
			
			goal = trace[ "position" ];
		
			cover MoveTo( ( cover.origin[ 0 ] + ( ( cover.origin[ 0 ] - goal[ 0 ] ) * CHAR_IMPULSE ), cover.origin[ 1 ] + ( ( cover.origin[ 0 ] - goal[ 0 ] ) * CHAR_IMPULSE ), cover.origin[ 2 ] + ( ( cover.origin[ 0 ] - goal[ 0 ] ) * CHAR_IMPULSE ) ), 3, 0.05, 2.4 );
		}
		
		wait 0.05;
	}	
}

cover_path_management()
{
	while( 1 )
	{
		self DisconnectPaths();
		
		wait 0.2;
		
		self ConnectPaths();
	}
}
