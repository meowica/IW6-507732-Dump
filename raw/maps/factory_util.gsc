//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Factory Mission Utils										**
//                                                                          **
//    Created: 	8/5/12	Neversoft											**
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
	self SetOrigin( start.origin );

	lookat = undefined;
	if ( IsDefined( start.target ) )
	{
		lookat = GetEnt( start.target, "targetname" );
		Assert( IsDefined( lookat ) );
	}

	if ( IsDefined( lookat ) )
	{
		self SetPlayerAngles( VectorToAngles( lookat.origin - start.origin ) );
	}
	else
	{
		self SetPlayerAngles( start.angles );
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

// Add an ally character to the squad
squad_add_ally( script_name, spawner_targetname, animname )
{
	if ( !IsDefined( level.squad ) )
		level.squad = [];
	spawner			= GetEnt( spawner_targetname, "targetname" );
	ally			= spawner spawn_ai();
	ally.animname	= animname;

	ally thread deletable_magic_bullet_shield();
	//ally.ai_color = ally.script_forcecolor;
	//ally ai_color_reset();
	ally.hero = true;
	ally make_hero();
	ally.disable_sniper_glint = 1;
	ally.awareness = 1;
	ally.has_no_ir = true;
	
	// Assign unique heads
	if( isDefined( spawner.script_parameters ))
	{
		// ally maps\factory_util::swap_head( spawner.script_parameters );
	}

	// ally forceUseWeapon( "mp5_silencer_eotech", "primary" );

	level.squad[ script_name ] = ally;

	return ally;
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

	// JR - Not checking this in because it could break existing scripts that relied on it being broken
	// Handle trigger_once and "touch_once" triggers.
	//if( trigger.classname == "trigger_once" || ( isDefined( trigger.spawnflags ) && trigger.spawnflags & 64 ))
	//{
		//trigger delete();
		//iprintlnbold( "deleted once trigger" );
	//}
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

	// JR - Not checking this in because it could break existing scripts that relied on it being broken	
	// Handle trigger_once and "touch_once" triggers.
	//if( trigger.classname == "trigger_once" || ( isDefined( trigger.spawnflags ) && trigger.spawnflags & 64 ))
	//{
		//trigger delete();
		//iprintlnbold( "deleted once trigger" );
	//}
}

// Breaks some glass in a certain direction
break_glass( glass_name, direction )
{
	glass_array = GetGlassArray( glass_name );
	foreach( glass in glass_array )
	{
		DestroyGlass( glass, direction );
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
		maps\factory_util::actor_teleport( level.squad[ squad_names[ i ] ], squad_names[ i ] + "_" + checkpoint_name + "_teleport" );
		intro_node = GetNode( squad_names[ i ] + "_" + checkpoint_name + "_node", "targetname" );
		level.squad[ squad_names[ i ] ] SetGoalNode( intro_node );
	}
}

teleport_squadmember( checkpoint_name, squad_name )
{
	maps\factory_util::actor_teleport( level.squad[ squad_name ], squad_name + "_" + checkpoint_name + "_teleport" );
	intro_node = GetNode( squad_name + "_" + checkpoint_name + "_node", "targetname" );
	level.squad[ squad_name ] SetGoalNode( intro_node );
}

// For when you really want the AI to do something right now
disable_awareness()
{
	if( !isDefined( self.awareness ))
	{
		self.awareness = 0;
	}
	self.awareness = 0;
	self.ignoreall = true;
	//self.dontmelee = true;
	self.ignoreSuppression = true;
	//self.suppressionwait_old = self.suppressionwait;
	//self.suppressionwait = 0;
	self disable_surprise();
	self.IgnoreRandomBulletDamage = true;
	self disable_bulletwhizbyreaction();
	self disable_pain();
	//self disable_danger_react();
	self.grenadeawareness = 0;
	//self.ignoreme = 1;
	self enable_dontevershoot();
	//self.disableFriendlyFireReaction = true;
}

has_awareness()
{
	return self.awareness;
}

enable_awareness()
{
	if( !isDefined( self.awareness ))
	{
		self.awareness = 1;
	}
	self.awareness = 1;
	self.ignoreall = false;
	self.dontmelee = undefined;
	self.ignoreSuppression = false;
	//assert(isdefined(self.suppressionwait_old));
	//self.suppressionwait = self.suppressionwait_old;
	//self.suppressionwait_old = undefined;
	self enable_surprise();
	self.IgnoreRandomBulletDamage = false;
	self enable_bulletwhizbyreaction();
	self enable_pain();
	self.grenadeawareness = 1;
	//self.ignoreme = 0;
	self disable_dontevershoot();
	//self.disableFriendlyFireReaction = undefined;
}

// Thread this to repurpose standard trigger multiples as flag_set triggers
check_trigger_flagset( targetname )
{
	trigger = GetEnt( targetname, "targetname" );
	
	trigger waittill( "trigger" );

	if ( IsDefined( trigger.script_flag_set ) )
	{
		flag_set( trigger.script_flag_set );
	}
}

playerseek()
{
	self ClearGoalVolume();
	self SetGoalEntity( level.player );
	self.aggressivemode = true;
}

// Swaps the head on an actor
swap_head( model )
{
	if( IsDefined( self.headmodel ) )
		self Detach( self.headmodel , "" );
	self Attach( model, "", true );
	self.headmodel = model;
}

// JR - set_ignoreme doesnt safety check self, so using this instead
factory_set_ignoreme( val )
{
	if( isDefined( self ) && IsAlive( self ) && IsSentient( self ))
	{
		self.ignoreme = val;
	}
}

// Waits for the guys to finish what they're doing, then gives them a new goal volume
safe_set_goal_volume( guys, volume_targetname )
{
	volume = GetEnt( volume_targetname, "targetname" );

	// Safety check the volume
	if ( !IsDefined( volume ) )
	{
		AssertMsg( "Error: safe_set_goal_volume() failed to find volume" );
		return;
	}
	
	// Safety check array
	if( !isArray( guys ))
	{
		guys = [ guys ];
	}
	
	foreach ( guy in guys )
	{
		if ( IsDefined( guy ) && IsAlive( guy ) )
		{
			guy thread safe_set_goal_volume_single( volume );
		}
	}
}

safe_set_goal_volume_single( volume )
{
	self endon( "death" );
	self waittill( "goal" );
	self SetGoalVolumeAuto( volume );
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

// Safeley delete stuff based on script_linkname
// script_linkname is just a third KVP for grabbing ents, if targetname and script_noteworthy are used
safe_delete_linkname( parameters )
{
	safe_delete_array( getEntArray( parameters, "script_linkname" ));
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

// Makes a guy notify when he reaches a node in a scripted path
// Use this as an "optional_arrived_at_node_func" for go_to_node()
notify_targetname_on_goal( node )
{
	if( isDefined( node ) && isDefined( node.targetname ))
	{
		self notify( node.targetname );
	}
}


//================================================================================================
//	THERMAL
//================================================================================================
thermal_vision()
{
	self endon ( "end_thermal" );
	self NotifyOnPlayerCommand( "use_thermal", "+actionslot 4" );
	self SetWeaponHudIconOverride( "actionslot4", "hud_icon_nvg" );
	self.thermal = false;
	self.active_anim = false;
	self.thermal_anim_active = false;
	level.show_thermal_hint = true;
	level.show_thermal_off_hint = true;

	while ( 1 )
	{
		wait 0.05;

		self waittill ( "use_thermal" );
		self toggle_thermal_vision();
	}
}

// Toggle thermal
toggle_thermal_vision()
{
	// Safety check for overlapping anims
	if( self.active_anim || flag( "player_using_camera" ))
	{
		//iprintlnbold( "NOPE" );
		return;
	}

	// Turn it on
	if( self.thermal == false )
	{
		self turn_on_thermal_vision();
	}
	// Turn it off
	else
	{
		self turn_off_thermal_vision();
	}
}

// On
turn_on_thermal_vision()
{
	Assert(IsPlayer(self));

	if ( self.throwinggrenade == true )
		return;

	self disableWeaponPickup();

	self.thermal_anim_active = true;
	current_weapon = level.player GetCurrentWeapon();
	self ForceViewmodelAnimation( current_weapon, "nvg_down" );
	wait( 0.6 );

	self.thermal = true;
	self maps\_load::thermal_EffectsOn();

	SetHUDLighting( true );

	// Show the scope overlay
	if( !isDefined( self.gasmask_hud_elem ))
	{
		self.gasmask_hud_elem = NewClientHudElem( self );
		self.gasmask_hud_elem.x = 0;
		self.gasmask_hud_elem.y = 0;
		self.gasmask_hud_elem.alignX = "left";
		self.gasmask_hud_elem.alignY = "top";
		self.gasmask_hud_elem.horzAlign = "fullscreen";
		self.gasmask_hud_elem.vertAlign = "fullscreen";
		self.gasmask_hud_elem.foreground = false;
		self.gasmask_hud_elem.sort = -10; // trying to be behind introscreen_generic_black_fade_in	
		self.gasmask_hud_elem SetShader("nightvision_overlay_goggles", 650, 490);
		self.gasmask_hud_elem.archived = true;
		self.gasmask_hud_elem.hidein3rdperson = true;
		self.gasmask_hud_elem.alpha = 1.0;
	}

	self ThermalVisionOnShadowOff();
	self VisionSetThermalForPlayer( "default_night_mp", 0 );
	self PlaySound( "item_thermalvision_on" );

	level.show_thermal_hint = false;

	wait 1.0;

	self enableWeaponPickup();
	self.thermal_anim_active = false;
}

// Off
turn_off_thermal_vision()
{
	Assert(IsPlayer(self));

	if ( self.throwinggrenade == true )
		return;

	self disableWeaponPickup();

	level.show_thermal_off_hint = false;

	self.thermal_anim_active = true;
	current_weapon = level.player GetCurrentWeapon();
	self ForceViewmodelAnimation( current_weapon, "nvg_up" );

	// Allow time for the anim
	wait 0.5;

	self.thermal = false;
	level.show_thermal = true;

	self maps\_load::thermal_EffectsOff();

	self ThermalVisionOff();
	self PlaySound( "item_thermalvision_off" );
		
	// Turn on reddot and turn off laser
	//self SetEmpJammed( false );
	
	if(IsDefined(self.gasmask_hud_elem))
	{
		self.gasmask_hud_elem Destroy();
		self.gasmask_hud_elem = undefined;
	}

	SetHUDLighting( false );

	wait 1.1;

	self enableWeaponPickup();
	self.thermal_anim_active = false;
}

// Forces thermal off and disables its use
thermal_disable()
{
	// Turn it off
	if( self.thermal == true )
	{
		self notify( "use_thermal" );
		self turn_off_thermal_vision();
	}

	// Disable it
	self notify( "end_thermal" );
	self SetWeaponHudIconOverride( "actionslot4", "none" );
}


apc_firing_logic( target, spread, end_flag, always_miss )
{
	self endon ("death");
	self endon ("stop_firing");
	
	if ( isDefined ( spread ))
	{
		self.mgturret[0] SetAISpread ( spread );	
	}
	
	if ( isDefined ( always_miss ))
	{
		forward = AnglesToForward( target.angles );
		forwardfar = ( forward* 50 );
		miss_vec = forwardfar + randomvector( 50 );
		self.mgturret[0] SetAISpread ( 0 );
    }
	else
	{
		miss_vec = ( 0,0,0);
	}
	
	burstsize = randomintrange( 4, 6 );
	burstfrequency = 2.5;
	fireTime = .5;
	while ( 1 )
	{
		for ( i = 0; i < burstsize; i++ )
		{
			
			if ( IsDefined ( end_flag ))
			{
				if ( flag ( end_flag))
					self notify ("stop_firing");
			}
			
			offset = randomvector( 15 ) + miss_vec;
			//println( "           offset: " + offset );
			//thread draw_line_for_time( self.origin+(0,0,128), player.origin+offset, 0, 0, 1, 2 );
			//thread draw_line_for_time( player.origin+offset+(0,0,4), player.origin+offset, 0, 0, 1, 2 );
			self setturrettargetent( target, offset );
			self fireweapon();
			wait fireTime;
		}
		wait burstfrequency;

	}
}

// Nag line generator and associated functions
nag_line_generator( lines, ender, radio )
{
	level endon( "stop_nag" );
	level endon ( ender );
	
	delay	  = 8;
	max_delay = 20;
	random_min = 0.5;
	random_max = 1.5;
	
	if ( !IsDefined ( lines ) )
	{
		//Merrick: Hurry up, Rook!
		//Merrick: Come on!
		//Merrick: Rook, what's the hold up!?
		lines = randomizer_create( [ "factory_bkr_hurryuprook", "factory_bkr_comeon", "factory_bkr_theholdup" ] );
	}
	else
	{
		lines = randomizer_create( lines );
	}
	
	while ( 1 )
	{	
		wait delay + RandomFloatRange( -2.0, 2.0 );
		line = lines randomizer_get_no_repeat();
		
		if( isDefined( radio ))
		{
			smart_radio_dialogue( line );
		}
		else
		{
			self thread smart_dialogue( line );
		}

		if ( delay < max_delay )
		{
			delay += RandomFloatRange( random_min, random_max );
		}
	}
}

randomizer_create(array)
{
	Assert(array.size != 0);
	randomizer = SpawnStruct();
	randomizer.array = array;	
	return randomizer;
}

randomizer_get_no_repeat()
{
	Assert(self.array.size > 0);
	
	index = undefined;
	if(self.array.size > 1 && IsDefined(self.last_index))
	{
		index = RandomInt(self.array.size - 1);
		if(index >= self.last_index)
			index++;
	}
	else
	{
		index = RandomInt(self.array.size);
	}
	self.last_index = index;
	return self.array[index];
}

// Nag generator for temp dialog text, copied from TJ's nag script
// Meant to come AFTER the initial instruction VO
nag_line_generator_text( lines, ender, character_name, color )
{
	level endon( "stop_nag" );
	self endon ( ender );
	
	delay = 10;
	max_delay = 20;
	random_min = 0.5;
	random_max = 1.5;
	
	lines = maps\factory_util::randomizer_create ( lines );
	
	while ( 1 )
	{
		wait delay + RandomFloatRange( -2.0, 2.0 );
		line = lines maps\factory_util::randomizer_get_no_repeat();
		thread add_debug_dialogue( character_name, line, color );
		if ( delay < max_delay )
		{
			delay += RandomFloatRange( random_min, random_max );
		}
	}
}

//====================================================================
// Rotating door helper scripts
//====================================================================
// Create door, save it in level, return pivot
create_door( targetname, angles )
{
	if( !isDefined( level.doors ))
	{
		level.doors = [];	// Doesn't exist, create the array to store them
	}

	// See if this door already exists
	if( isDefined( level.doors[ targetname ] ))
	{
		return level.doors[ targetname ];
	}

	// Get the node
	pivot_node = GetEnt( targetname, "targetname");
	level.doors[ targetname ] = pivot_node;
	level.doors[ targetname ].path_connectors = [];

	// Get the parts
	door_ents = GetEntArray( pivot_node.target, "targetname" );

	// Attach
	foreach( part in door_ents )
	{
		part linkTo( pivot_node );
		if( isDefined( part.script_parameters ) && part.script_parameters == "path_connector" )
		{
			level.doors[ targetname ].path_connectors[ level.doors[ targetname ].path_connectors.size ] = part;
		}
	}
	
	return pivot_node;
}

// Opens a door created by create_door
open_door( targetname, angles, time, connect )
{
	door = create_door( targetname, angles );

	// Safety check
	if( !isDefined( door ))
	{
		AssertMsg( "Error: open_door failed - " + targetname );
		return;
	}

	// Connect paths on old door position
	if( isDefined( connect ) && connect == true )
	{
		foreach( connector in door.path_connectors )
		{
			connector ConnectPaths();
		}
	}

	wait 0.01;

	// Do the rotate
	door RotateYaw( angles, time, 0.1, 0.1 );

	// Disconnect paths that intersect the new door position
	if( isDefined( connect ) && connect == true )
	{
		door waittill( "rotatedone" );
		foreach( connector in door.path_connectors )
		{
			connector DisconnectPaths();
		}
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
create_automatic_sliding_door( name, time, accel, lock_notify, unlock_flag )
{
	// Get all the ents in the door
	parts = GetEntArray( name, "script_noteworthy" );
	
	if( !isDefined( parts ) || parts.size == 0 )
	{
		iprintln( "create_automatic_sliding_door failed. No parts" );
		return;
	}

	// Get all the nodes set up
	door = undefined;
	left = undefined;
	left_open = undefined;
	right = undefined;
	right_open = undefined;
	
	foreach( part in parts )
	{
		// Nodes
		if( part.classname == "script_origin" )
		{
			if( isDefined( part.targetname ))
			{
				if( part.targetname == "door_node" )
				{
					door = part;
				}
				else if( part.targetname == "right_door_node" )
				{
					right = part;
				}
				else if( part.targetname == "left_door_node" )
				{
					left = part;
				}
				else if( part.targetname == "right_open_node" )
				{
					right_open = part;
				}
				else if( part.targetname == "left_open_node" )
				{
					left_open = part;
				}
			}
		}
	}

	// Connect the nodes to the main piece
	door.left = left;
	door.left_open = left_open;
	door.right = right;
	door.right_open = right_open;
	door.time = time;
	door.accel = accel;
	door.lock_notify = lock_notify;
	door.unlock_flag = unlock_flag;
	door.door_name = name;

	// Setup the RIGHT door
	right_parts = GetEntArray( door.right.target, "targetname" );
	foreach( part in right_parts )
	{
		part linkTo( door.right );
	}

	// Setup the LEFT door
	left_parts = GetEntArray( door.left.target, "targetname" );
	foreach( part in left_parts )
	{
		part linkTo( door.left );
	}

	// Setup trigger
	door.trigger = spawn( "trigger_radius", door.origin, 3, 128, 64 );
	door.trigger trigger_on();

	// Start the automatic logic
	door thread automatic_sliding_door_logic();
	door thread automatic_sliding_door_lock();

	return door;
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
				flag_set( "presat_synctransients");
				self.state = "open";
				self.left moveTo( self.left_open.origin, self.time, self.accel );
				self.right moveTo( self.right_open.origin, self.time, self.accel );
				
				if (self.door_name == "sliding_door_sat_enter_02" || self.door_name == "sliding_door_sat_exit_01")
					thread maps\factory_audio::sfx_metal_door_open(self);
				else
					thread maps\factory_audio::sfx_glass_door_open(self);
			}
		}

		// Close or stay closed
		else
		{
			if( self.state == "opening" || self.state == "open" )
			{
				self.state = "closed";
				self.left moveTo( self.origin, self.time, self.accel );
				self.right moveTo( self.origin, self.time, self.accel );
				if (self.door_name == "sliding_door_sat_enter_02" || self.door_name == "sliding_door_sat_exit_01")
					thread maps\factory_audio::sfx_metal_door_close(self);
				else
					thread maps\factory_audio::sfx_glass_door_close(self);
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

// Turns the door off and locks it shut
automatic_sliding_door_lock()
{
	self endon( "death" );

	level waittill( self.lock_notify );

	// Close it
	self.state = "closed";
	self.left moveTo( self.origin, self.time, self.accel );
	self.right moveTo( self.origin, self.time, self.accel );
	thread maps\factory_audio::sfx_glass_door_close(self);

	// Destroy the trigger
	self.trigger trigger_off();
	self.trigger delete();
}

// Dont run shit over!
forklift_run_over_monitor( ignore_vehicle )
{
	self endon( "death" );
	level endon( "presat_locked" );
	blocked = false;
	default_speed = 4.5;
	
	fov = cos( 35 );
	
	while( IsAlive( self ) )
	{
		wait 0.1;
		
		// Is the player or ai nearby?
		closest = get_closest_ai( self.origin );
		d = distance( closest.origin, self.origin );
		d2 = distance( level.player.origin, self.origin );
		d3 = 9999;

		// Check for other vehicles
		vehs = Vehicle_GetArray();
		foreach( veh in vehs )
		{
			if( veh == self )
			{
				continue;
			}

			if( isDefined( ignore_vehicle ))
			{
				ignore_veh = get_vehicle( ignore_vehicle, "targetname" );
				if( isDefined( ignore_veh ) && ignore_veh == veh )
				{
					continue;
				}
			}

			d3 = distance( veh.origin, self.origin );
			if( d3 < d )
			{
				d = d3;
				closest = veh;
			}
		}

		if( !isDefined( d ) || !isDefined( d2 ))
		{
			iprintln( "Error: forklift_run_over_monitor couldn't get valid distances" );
			return;
		}

		// Whichever is closer...
		if( d2 < d )
		{
			d = d2;
			closest = level.player;
		}
		
		if ( d > 145 )
		{
			if( blocked )
			{
				// Reset the speed
				self Vehicle_SetSpeed( default_speed );
				blocked = false;
			}
			else
				continue;
		}
		else if( d < 95 )
		{
			blocked = true;
		}
		else
		{
			// Is player in front of the vehicle and about to get ran over?
			withinFOV = within_fov( self.origin, self.angles, closest.origin, fov );
			
			if ( !withinFOV )
			{
				if( blocked )
				{
					// Reset the speed
					self Vehicle_SetSpeed( default_speed );
					blocked = false;
				}
				else
					continue;
			}
			else
			{
				blocked = true;
			}
		}
		
		// Halt for a bit
		if( blocked )
		{
			self Vehicle_SetSpeed( 0, 10 );
			wait 2;
		}
	}
}

// generic rain start and end call
make_it_rain( rain_type, kill_flag )
{
	level endon( kill_flag );
	while( 1 )
	{
		PlayFX( GetFX( rain_type ), level.player.origin );
		wait 0.1;
	}
}


// Ally quick kill - from London Docks
quick_kill( shooters, enemy, shots, delay_func )
{
	if ( !IsDefined( enemy ) || !IsAlive( enemy ) )
	{
		return;
	}

	array_thread( shooters, ::cqb_aim, enemy );

	if ( IsDefined( delay_func ) )
	{
		[[ delay_func ]]( shooters, enemy );
	}

	if ( !IsDefined( enemy ) || !IsAlive( enemy ) )
	{
		array_thread( shooters, ::cqb_aim, undefined );
		return;
	}

	enemy.dontattackme = undefined;

	if ( shots == 1 )
	{
		enemy.health = 1;
	}

	// TODO: use GetMuzzlePos instead of getting tag_flash
	start_pos = shooters[ 0 ] GetTagOrigin( "tag_flash" );
	end_pos = enemy GetTagOrigin( "j_head" );
	trace = BulletTrace( start_pos, end_pos, true );

	if ( shooters.size > 1 )
	{
		if ( IsDefined( trace[ "entity" ] ) && trace[ "entity" ] == level.player )
		{
			shooters = array_reverse( shooters );
		}
	}

	// Play Fire anim
	num = RandomInt( shooters[ 0 ].a.array[ "single" ].size );
	fireanim = shooters[ 0 ].a.array[ "single" ][ num ];
	rate = 0.1 / WeaponFireTime( shooters[ 0 ].weapon );

	if ( !IsAlive( enemy ) )
	{
		array_thread( shooters, ::cqb_aim, undefined );		
		return;
	}

	for ( i = 0; i < shots; i++ )
	{
		if ( IsAlive( enemy ) )
		{
			end_pos = enemy GetTagOrigin( "j_head" );

			// On the last shot, make sure we kill him.
			if ( shots - i == 1 )
			{
				enemy.health = 1;
			}
		}

		offset = ( 0, 0, 0 );
		if ( shots - i > 1 )
		{
			offset = ( 0, 0, RandomFloatRange( 5, 15 ) * -1 );
		}

		shooters[ 0 ] SetFlaggedAnimKnobRestart( "fire_notify", fireanim, 1, 0.2, rate );
		shooters[ 0 ] waittillmatch_or_timeout( "fire_notify", "fire", 0.2 );

		start_pos = shooters[ 0 ] GetTagOrigin( "tag_flash" );
		
		// Safe magic bullet should be in the util file
		shooters[ 0 ] maps\factory_powerstealth::safe_magic_bullet( start_pos, end_pos + offset );
	
		if ( shots - i > 1 )
		{
			wait( 0.15 + RandomFloat( 0.1 ) );
		}
	}

	if ( IsAlive( enemy ) )
	{
		if ( IsDefined( enemy.magic_bullet_shield ) )
		{
			enemy stop_magic_bullet_shield();
		}

		enemy Kill();
	}

	array_thread( shooters, ::cqb_aim, undefined );
}

waittillmatch_or_timeout( note1, note2, time )
{
	self notify( "waittillmatch_timeout" );

	self thread waittillmatch_timeout( time );
	self endon( "waittillmatch_timeout" );
	self endon( "death" );
	self waittillmatch( note1, note2 );

	self notify( "waittillmatch_timeout" );
}

waittillmatch_timeout( time )
{
	self endon( "waittillmatch_timeout" );
	wait( time );
	self notify( "waittillmatch_timeout" );
}
// Vehicle Animations

// The starting vehicle node should be positioned close to where the animation begins
// But far enough ahead that the vehicle can path to it
// Ask the animator who created the scene what the start and end speeds are
// The end speed should be reflected in the node closest to where the animation ends

#using_animtree( "vehicles" );
animate_vehicle_from_path( scene , vehicle_node_noteworthy, anim_node_noteworthy, speed )
{
	self UseAnimTree( #animtree );
	animation = self  getanim( scene );

	node = GetVehicleNode( vehicle_node_noteworthy, "script_noteworthy" );
	
	anim_point = GetEnt( anim_node_noteworthy, "script_noteworthy" );
	
	anim_struct = SpawnStruct();
	anim_struct.origin = GetStartOrigin( anim_point.origin, anim_point.angles, animation );
	anim_struct.angles = GetStartAngles( anim_point.origin, anim_point.angles, animation );
	
	node waittill( "trigger" );
	
	// thread draw_line_for_time ( self.origin, anim_struct.origin, 256, 0, 0, 3 );

 	self Vehicle_OrientTo( anim_struct.origin, anim_struct.angles, speed , 0.0 );
 	self waittill( "orientto_complete" );
	
	thread animated_script_model( self, anim_point, #animtree, animation );
	
	self AnimScripted( "vehicle_animation", anim_point.origin, anim_point.angles, animation );		
	wait(GetAnimLength(animation));
}

animated_script_model( vehicle, struct, animtree, animation )
{
	if ( GetDvarInt( "show_script_model" ) == 0 )
	{
		return;
	}

	offset = ( 0, -300, 0 );
	ent = Spawn( "script_model", struct.origin );
	ent SetModel( vehicle.model );
	ent UseAnimTree( animtree );

	ent AnimScripted( "blah", struct.origin + offset, struct.angles, animation );
	
	vehicle waittill( "death" );
	wait( 1 );
	ent Delete();
}

// Use for determining the orientation of a vehicle during animations
veh_origin_angles_printout()
{
	while(1)
	{
		IPrintLn( "origin = " + self.origin );
		IPrintLn( "angles = " + self.angles );
		wait .25;
	}
}

// JR - Prints out how many enemies were killed by the (player) / (allies) / (cleanup)
// Helps track how deadly the allies are
debug_kill_counter_enable()
{
	level.ally_kill_count = 0;
	level.player_kill_count = 0;
	level.auto_kill_count = 0;
	spawners = GetSpawnerArray();
	array_spawn_function( spawners, ::debug_who_killed_me );
	iprintlnbold( "Tracking kills for " + spawners.size + " enemies" );
}


// JR - Debug script to help track how often allies kill enemies
debug_who_killed_me()
{
	self waittill( "death", attacker, cause );
	
	if( isDefined( attacker ))
	{
		if( attacker.classname == "worldspawn" )
		{
			level.auto_kill_count++;
			iprintlnbold( "Auto kill +1 (" + level.player_kill_count + ") / (" + level.ally_kill_count + ") / (" + level.auto_kill_count + ")" );
		}
		else if( attacker == level.player )
		{
			level.player_kill_count++;
			iprintlnbold( "Player kill +1 (" + level.player_kill_count + ") / (" + level.ally_kill_count + ") / (" + level.auto_kill_count + ")" );
		}
		else if( isDefined( attacker.hero ) && attacker.hero == true )
		{
			level.ally_kill_count++;
			iprintlnbold( "Ally kill +1 (" + level.player_kill_count + ") / (" + level.ally_kill_count + ") / (" + level.auto_kill_count + ")" );
		}
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


// Press left shoulder button to trigger slow-motion.
/*
test_slowmovermode()
{
	level.player DisableOffhandWeapons();
	while ( 1 )
	{
		while ( !self ButtonPressed ( "BUTTON_LSHLDR" ))
		{
			wait .1;
		}
		SetSlowMotion( 1.0, 0.25, 0.5 );
		while ( self ButtonPressed ( "BUTTON_LSHLDR" ))
		{
			wait .1;
		}
		SetSlowMotion( 0.25, 1, 0.5 );
	}
}
*/

/***************************************************************
 * TRANSIENT FILE SCRIPTS
 **************************************************************/

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



/***************************************************************
 * GOD RAY FILE SCRIPTS
 **************************************************************/

god_rays_from_world_location ( source_origin, start_flag, end_flag, start_vision_set, end_vision_set )
{
	if ( is_gen4() )
	{
		// CHAD TESTS FOR PC GOD RAYS from STATIC LOCATION!!!!!
		if ( IsDefined ( start_flag ) )
			flag_wait ( start_flag );
		
		//IPrintLnBold ("starting world location god rays");
		ent1=0;
		ent2=0;
		if ( IsDefined ( start_vision_set ) )
			maps\_utility::vision_set_fog_changes( start_vision_set, 5 );
		ent = maps\_utility::create_sunflare_setting( "default" );
		while (1)
		{
			//get cylindrical coordinate angles
			ent1 = ATan ( (level.player.origin[2] - source_origin[2])/sqrt( squared((level.player.origin[0] - source_origin[0]))+(squared( (level.player.origin[1] - source_origin[1]) ) ) ) );
			if (level.player.origin[0] < source_origin[0])
			{
				ent2 = ATan ((level.player.origin[1] - source_origin[1])/(level.player.origin[0] - source_origin[0]));
			}
			else
			{
				ent2 = (180+ATan ((level.player.origin[1] - source_origin[1])/(level.player.origin[0] - source_origin[0])));
			}
				
			//set new sunflare angles
			ent.position = (ent1, ent2, 0);
			maps\_art::sunflare_changes( "default", 0 );
			wait 0.05;
			if ( IsDefined ( end_flag ) )
			{
				if (flag ( end_flag ))
			    break;
			}
		}
		//IPrintLnBold ("stopping world location god rays");
		if ( IsDefined ( end_vision_set ) )
		{
			maps\_utility::vision_set_fog_changes( end_vision_set, 5 );
			wait 5;
			maps\_utility::vision_set_fog_changes( "", 1 );
		}
	}
}

god_rays_from_moving_source ( object, tag_origin, start_flag, end_flag, start_vision_set, end_vision_set  )
{
	if ( is_gen4() )
	{
		// CHAD TESTS FOR DYNAMIC PC GOD RAYS!!!!!
		if ( IsDefined ( start_flag ) )
			flag_wait ( start_flag );
		
		//IPrintLnBold ("starting moving source god rays");
		ent1=0;
		ent2=0;
		if ( IsDefined ( start_vision_set ) )
			maps\_utility::vision_set_fog_changes( start_vision_set, 1 );
		ent = maps\_utility::create_sunflare_setting( "default" );
		while (1)
		{
			//get location of light origin
			if ( IsDefined ( tag_origin ) )
				object_location = object GetTagOrigin ("tag_flash");
			else
				object_location = object.origin;
				
			//get cylindrical coordinate angles
			ent1 = ATan ( (level.player.origin[2] - object_location[2])/sqrt( squared((level.player.origin[0] - object_location[0]))+(squared( (level.player.origin[1] - object_location[1]) ) ) ) );
			if (level.player.origin[0] < object_location[0])
			{
				ent2 = ATan ((level.player.origin[1] - object_location[1])/(level.player.origin[0] - object_location[0]));
			}
			else
			{
				ent2 = (180+ATan ((level.player.origin[1] - object_location[1])/(level.player.origin[0] - object_location[0])));
			}
				
			//set new sunflare angles
			ent.position = (ent1, ent2, 0);
			maps\_art::sunflare_changes( "default", 0 );
			wait 0.05;
			if ( IsDefined ( end_flag ) )
			{
				if (flag ( end_flag ))
			    break;
			}
		}
		//IPrintLnBold ("stopping moving source god rays");
		if ( IsDefined ( end_vision_set ) )
		{
			maps\_utility::vision_set_fog_changes( end_vision_set, 1 );
			wait 1;
			maps\_utility::vision_set_fog_changes( "", 1 );
		}
	}
}



god_rays_intro()
{
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_intro");
		maps\_utility::vision_set_fog_changes( "factory_intro_godray", 0 );
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (-26.4928, 7.46195, 0);
		maps\_art::sunflare_changes( "default", 0 );
		wait 1.5;
		//IPrintLnBold ("god_rays_intro_off");
		maps\_utility::vision_set_fog_changes( "factory_intro", 5 );
		wait 5;
		maps\_utility::vision_set_fog_changes( "", 0 );
		//resetting godray position
		//IPrintLnBold ("resetting godray position");
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (-1.80725, -89.6621, 0);
		maps\_art::sunflare_changes( "default", 0 );
	}
}

god_rays_trainyard()
{
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_trainyard");
		god_rays_from_world_location ( (3233,4790,579), "first_enemy_dead", "factory_exterior_reveal", undefined, undefined );
	}
}

god_rays_factory_awning()
{
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_awning");
		god_rays_from_world_location ( (4208,4299,263), "factory_exterior_reveal_between_trains", "player_entered_awning", undefined, undefined );
	}
}

god_rays_factory_open()
{
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_factory_open");
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (-1.24146, -65.8795, 0);
		maps\_art::sunflare_changes( "default", 0 );
		maps\_utility::vision_set_fog_changes( "factory_interior_godray", 1 );
		wait 3;
		//IPrintLnBold ("god_rays stop");
		maps\_utility::vision_set_fog_changes( "factory_interior", 7 );
		wait 7;
		maps\_utility::vision_set_fog_changes( "", 4 );
	}
}

god_rays_round_door_open()
{
	if ( is_gen4() )
	{
		wait 8;
		//flag_wait ("presat_open_revolving_door");
		//IPrintLnBold ("god_rays_round_door_open");
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (-15.24146, -80.8795, 0);
		maps\_art::sunflare_changes( "default", 0 );
		maps\_utility::vision_set_fog_changes( "factory_interior_godray_2", 3 );
		wait 6;
		//IPrintLnBold ("god_rays stop");
		maps\_utility::vision_set_fog_changes( "factory_interior", 10 );
		wait 10;
		maps\_utility::vision_set_fog_changes( "", 4 );
	}
}

god_rays_car_chase_01()
{
	if ( is_gen4() )
	{
		IPrintLnBold ("god_rays_car_chase_01");
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (-1.71387, 1.49415, 0);
		maps\_art::sunflare_changes( "default", 0 );
	}
}

god_rays_car_chase_02()
{
	if ( is_gen4() )
	{
		IPrintLnBold ("god_rays_car_chase_02");
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (-1.90063, -58.1012, 0);
		maps\_art::sunflare_changes( "default", 0 );
	}
}

god_rays_car_chase_03()
{
	if ( is_gen4() )
	{
		IPrintLnBold ("god_rays_car_chase_03");
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (-1.90063, -58.1012, 0);
		maps\_art::sunflare_changes( "default", 0 );
	} 
}

