#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;


main()
{
	maps\mp\mp_hashima_precache::main();
	maps\createart\mp_hashima_art::main();
	maps\mp\mp_hashima_fx::main();
	
	precache();
	
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_hashima" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_hashima" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	setdvar( "r_diffuseColorScale", 1.5 );
	setdvar( "r_specularcolorscale", 3 );
	SetDvar("r_sky_fog_intensity","1");
	SetDvar("r_sky_fog_min_angle","50");
	SetDvar("r_sky_fog_max_angle","85");
	
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";	

	game[ "allies_outfit" ] = "woodland";
	game[ "axis_outfit" ] = "urban";
	
	level thread use_switch_toggle_multiple();
	level thread pop_up_targets();
	level thread traps_init();
}

precache()
{
	PreCacheModel( "weapon_clyamore" );
}

use_switch_toggle_multiple()
{
	level.door_buttons = [];
	useSwitch = getstructarray( "switch_toggle", "targetname" );
	array_thread( useSwitch, ::use_switch_toggle_multiple_init );	
}

use_switch_toggle_multiple_init()
{
	targets = GetEntArray( self.target, "targetname" );
	
	foreach ( target in targets )
	{
		if ( !IsDefined( target.script_noteworthy ) )
			continue;
		
		switch ( target.script_noteworthy )
		{
			case "use_trigger":
				if( !IsDefined( self.use_triggers ) )
				{
					self.use_triggers = [];
				}
				self.use_triggers[ self.use_triggers.size ] = target;
				break;
			case "button_toggle":
				if( !IsDefined( self.button_toggles ) )
				{
					self.button_toggles = [];
				}
				num_button_toggles = self.button_toggles.size;
				self.button_toggles[ num_button_toggles ] = target;
				
				level.door_buttons[ level.door_buttons.size ] = target;
				
				
				target.fx_origin = RotateVector( (0,2.5,3), target.angles ) + target.origin;				

				icon_facing_vector = RotateVector( (0,0,1), target.angles );
				icon_angles = VectorToAngles( icon_facing_vector );								
				target.fx_fwd = AnglesToForward( icon_angles );
				target thread door_switch_icon( "use", target.origin+(0,0,6), icon_angles );
				break;				
			default:
				break;
		}
	}

	self.off_hintString = "Turn On";
	self.on_hintString	= "Turn Off";
	self.trigger_list	= [];
	
	if ( IsDefined( self.script_linkTo ) )
	{
		self.trigger_list = get_linked_structs();
		self.trigger_list = array_combine( self.trigger_list, get_linked_ents() );
		foreach ( trig in self.trigger_list )
		{
			if ( IsDefined( trig.targetname ) )
			{
				switch( trig.targetname )
				{
					case "sliding_target":
						self.off_hintString = &"MP_HASHIMA_TRAIN_CAR";
						self.on_hintString	= &"MP_HASHIMA_TRAIN_CAR";
						if( IsDefined( self.script_delay ) )
						{
							trig.script_delay = self.script_delay;
						}
						break;
					default:
						break;
				}
			}
		}
	}
	
	if ( !IsDefined( self.script_delay ) )
	{
		self.script_delay = 1;
	}
	
	if ( ( IsDefined( self.levers ) || IsDefined( self.button_toggles ) ) && IsDefined( self.use_triggers ) )
	{
		self use_switch_toggle_wait();
	}
}

use_switch_toggle_wait()
{
	lever_move_time = 0.2;
	wait_struct = SpawnStruct();
	
	while ( 1 )
	{
		foreach( use_trigger in self.use_triggers )
		{
			use_trigger SetHintString( self.off_hintString );
			use_trigger thread notify_struct_on_use( wait_struct );
		}
		
		self thread pop_up_targets_set_buttons(false);
		
		wait_struct waittill( "trigger", player );
		
		foreach( use_trigger in self.use_triggers )
		{
			use_trigger SetHintString( "" ); //No hint string while rotating
		}
		
		if( IsDefined( self.levers ) )
		{
			foreach( lever in self.levers )
			{
				lever RotateTo( lever.lever_on_angles, lever_move_time );
			}
		}
		
		self thread pop_up_targets_set_buttons(true);
		
		wait lever_move_time;
		
		if( IsDefined( self.levers ) )
		{
			foreach( lever in self.levers )
			{
				lever SetModel( "weapon_light_stick_tactical_green" );
			}
		}
		
		foreach ( thing in self.trigger_list )
		{
			thing notify( "trigger", player );
		}
		
		if ( self.script_delay > 0 )
			wait self.script_delay;
		
		
		foreach( use_trigger in self.use_triggers )
		{
			use_trigger SetHintString( self.on_hintString );
			use_trigger thread notify_struct_on_use( wait_struct );
		}
		
		self thread pop_up_targets_set_buttons(false);
		
		wait_struct waittill( "trigger", player );
	
		foreach( use_trigger in self.use_triggers )
		{
			use_trigger SetHintString( "" ); //No hint string while rotating
		}
		
		if( IsDefined( self.levers ) )
		{
			foreach( lever in self.levers )
			{
				lever RotateTo( lever.lever_off_angles, lever_move_time );
			}
		}

		self thread pop_up_targets_set_buttons(true);
		
		wait lever_move_time;
		
		if( IsDefined( self.levers ) )
		{
			foreach( lever in self.levers )
			{		
				lever SetModel( "weapon_light_stick_tactical_red" );
			}
		}
		
		foreach ( thing in self.trigger_list )
		{
			thing notify( "reset" );
		}
		
		if ( self.script_delay > 0 )
			wait self.script_delay;
	}
}

get_linked_structs()
{
	array = [];

	if ( IsDefined( self.script_linkTo ) )
	{
		linknames = get_links();
		for ( i	  = 0; i < linknames.size; i++ )
		{
			ent = getstruct( linknames[ i ], "script_linkname" );
			if ( IsDefined( ent ) )
			{
				array[ array.size ] = ent;
			}
		}
	}

	return array;
}

notify_struct_on_use( wait_struct )
{
	self waittill( "trigger" );
	wait_struct notify( "trigger" );
}

pop_up_targets()
{	
	targets = GetEntArray  ( "pop_up_target", "targetname" );
	targets = array_combine( targets		, GetEntArray( "sliding_target", "targetname" ) );
	array_thread( targets, ::pop_up_targets_init );	
}


pop_up_targets_init()
{
	if ( !IsDefined( self.target ) )
		return;
	
	self thread killplayer_UnresolvedCollision();
	
	structs = getstructarray( self.target, "targetname" );
	
	end_origin = undefined;
	foreach(struct in structs)
	{
		if(!isDefined(struct.script_noteworthy))
			struct.script_noteworthy = "end_origin";
		
		switch(struct.script_noteworthy)
		{
			case "end_origin":
				end_origin = struct;
				break;
			case "pop_to":
				self.origin = struct.origin;
				if( IsDefined( self.spawnflags ) && (self.spawnflags & 1 ) ) // DYNAMIC_PATH
				{
					self ConnectPaths();
				}
				break;
			default:
				break;
		}
	}
	
	if(!IsDefined(end_origin))
		return;
	
	if( IsDefined( end_origin.target ) )
	{
		start_origin = getstruct( end_origin.target, "targetname" );
		self.start_origin = start_origin.origin;
	}
	else
	{
		self.start_origin = self.origin;
	}
	self.end_origin	  = end_origin.origin;
	self SetCanDamage( false );
	self thread pop_up_targets_run();	
}

pop_up_targets_run()
{
	move_speed = 30;
	
	startSoundTime = 1.5;	
	ai_sight_brush = undefined;
	fx_origin = undefined;
	fx_ent = undefined;
	if( IsDefined( self.script_linkTo ))
	{
		linked_ents = self get_linked_ents();
		
		foreach( ent in linked_ents )
		{
			if( ent.targetname == "ai_sight_brush" )
			{
				ai_sight_brush = ent;
				if( IsDefined( ai_sight_brush.script_noteworthy ) && ( ai_sight_brush.script_noteworthy == "open_first" ) )
				{
					self handle_open_first_ai_sight_brush( move_speed, startSoundTime, ai_sight_brush );
				}
			}
			else if( ent.targetname == "fx_origin" )
			{
				fx_origin = ent;
			}
		}
	}
	

	
	while ( 1 )
	{
		self waittill_any( "trigger", "reset" );

		self PlaySound( "garage_door_start" ); // in multiplayer_requests.csv

		dist = Distance(self.origin, self.end_origin);
		movetime = dist/move_speed;
/*									
		if( IsDefined( self.script_noteworthy ) )
		{
			if( self.script_noteworthy == "clockwise_wheel" )
			{
				initially_clockwise = false;
				self thread hopper_wheel( initially_clockwise, movetime);
			}
			else if( self.script_noteworthy == "counterclockwise_wheel" )
			{
				initially_clockwise = true;
				self thread hopper_wheel( initially_clockwise, movetime);
			}
		}
*/		
		if( IsDefined( ai_sight_brush ) )
		{
			ai_sight_brush Show();
			ai_sight_brush SetAISightLineVisible( true ); // DOOR CLOSED
			ai_sight_brush Solid();
			ai_sight_brush DisconnectPaths();
			ai_sight_brush NotSolid();
		}

		
		self MoveTo( self.end_origin, movetime );
		wait( startSoundTime );
		
		if( !IsDefined( self.script_noteworthy ) || (( self.script_noteworthy != "clockwise_wheel" ) && ( self.script_noteworthy != "counterclockwise_wheel" ) && ( self.script_noteworthy != "no_sound" ) ) )
		{
			self PlayLoopSound( "garage_door_loop" );
		}
		
		if(movetime - startSoundTime > 0)
			wait( movetime - startSoundTime );
		
		self StopLoopSound();
		self PlaySound( "garage_door_end" );

		if( IsDefined( self.script_noteworthy ) )
		{
			if( self.script_noteworthy == "clockwise_wheel" )
			{
				flag_clear( "hopper_closed" );
				flag_set( "hopper_open" );
			}
		}
		
		self waittill_any( "trigger", "reset" );

		
		self PlaySound( "garage_door_start" ); // in multiplayer_requests.csv
/*
		if( IsDefined( self.script_noteworthy ) )
		{
			if( self.script_noteworthy == "clockwise_wheel" )
			{
				initially_clockwise = true;
				self thread hopper_wheel( initially_clockwise, movetime);
			}
			else if( self.script_noteworthy == "counterclockwise_wheel" )
			{
				initially_clockwise = false;
				self thread hopper_wheel( initially_clockwise, movetime);
			}
		}
*/		
		self MoveTo( self.start_origin, movetime);
		
		// play fx when door opens
		if( IsDefined( fx_origin ) )
		{
			fwd = AnglesToForward( fx_origin.angles );
			up	= AnglesToUp( fx_origin.angles );	
			fx_ent = SpawnFx( level._effect[ "vfx_steam_escape" ], fx_origin.origin, fwd, up );
			TriggerFX( fx_ent );
		}
		
		wait( startSoundTime );	
		
		if( !IsDefined( self.script_noteworthy ) || (( self.script_noteworthy != "clockwise_wheel" ) && ( self.script_noteworthy != "counterclockwise_wheel" ) && ( self.script_noteworthy != "no_sound" ) ) )
		{
			self PlayLoopSound( "garage_door_loop" );
		}
		
		if ( movetime - startSoundTime > 0 )
		{
			wait( movetime - startSoundTime );	
		}
		
		self StopLoopSound();
		self PlaySound( "garage_door_end" );		

		if( IsDefined( self.script_noteworthy ) )
		{
			if( self.script_noteworthy == "clockwise_wheel" )
			{
				flag_set( "hopper_closed" );
				flag_clear( "hopper_open" );
			}
		}
		
		if( IsDefined( ai_sight_brush ) )
		{
			ai_sight_brush Hide();
			ai_sight_brush SetAISightLineVisible( false ); // DOOR OPEN
			ai_sight_brush ConnectPaths();
			if( IsDefined( ai_sight_brush.script_linkto ) )
			{
				linked_ents = ai_sight_brush get_linked_ents();
				foreach( ent in linked_ents )
				{
					if( IsDefined( ent.script_noteworthy ) && ( ent.script_noteworthy == "linked_collision" ) )
					{
						ent ConnectPaths();
					}
				}
			}
		}

		if( IsDefined( fx_ent ) )
		{
			fx_ent Delete();
		}
	}
}

handle_open_first_ai_sight_brush( move_speed, startSoundTime, ai_sight_brush )
{
					
	// ugh, I hate this
	self waittill( "trigger" );
	
	dist = Distance(self.origin, self.end_origin);
	movetime = dist/move_speed;

	// TODO: parameterize this in script_parameters
	self PlaySound( "garage_door_start" ); // in multiplayer_requests.csv
	self MoveTo( self.end_origin, movetime );
	wait( startSoundTime );
	
	self PlayLoopSound( "garage_door_loop" );
	
	if(movetime - startSoundTime > 0)
		wait( movetime - startSoundTime );
	
	self StopLoopSound();
	self PlaySound( "garage_door_end" );

	temp_origin = self.end_origin;
	self.end_origin = self.start_origin;
	self.start_origin = temp_origin;
	
	if( IsDefined( ai_sight_brush ) )
	{
		ai_sight_brush Hide();
		ai_sight_brush SetAISightLineVisible( false ); // DOOR OPEN
		ai_sight_brush ConnectPaths();
		if( IsDefined( ai_sight_brush.script_linkto ) )
		{
			linked_ents = ai_sight_brush get_linked_ents();
			foreach( ent in linked_ents )
			{
				if( IsDefined( ent.script_noteworthy ) && ( ent.script_noteworthy == "linked_collision" ) )
				{
					ent ConnectPaths();
				}
			}
		}
	}	
}

door_switch_icon(type, origin, angles, end_ons)
{
	if(level.createFX_enabled)
		return;
	if(!IsDefined(level.door_switch_icon_count))
		level.door_switch_icon_count = 0;
	
	level.door_switch_icon_count++;
	
	icon_id = "door_switch_icon_" + level.door_switch_icon_count;
	
	door_switch_icon_update(type, origin, angles, icon_id, end_ons);
	
	foreach(player in level.players)
	{
		if(IsDefined(player.door_switch_icons) && IsDefined(player.door_switch_icons[icon_id]))
		{
			player.door_switch_icons[icon_id] thread door_switch_icon_fade_out();
		}
	}
}

door_switch_icon_update(type, origin, angles, icon_id, end_ons)
{
	if(IsDefined(end_ons))
	{
		if(isString(end_ons))
			end_ons = [end_ons];
		
		foreach(end_on in end_ons)
			self endon(end_on);
	}
	
	while(!IsDefined(level.players))
		wait .05;

	show_dist = 200;
	icon = "hint_usable";
	pin = false;
	switch(type)
	{
		default:
			break;
	}
	
	dir = undefined;
	if(IsDefined(angles))
	{
		dir = AnglesToForward(angles);
	}
	
	show_dist_sqr = show_dist*show_dist;
	
	while(1)
	{
		foreach(player in level.players)
		{
			if(!IsDefined(player.door_switch_icons))
				player.door_switch_icons = [];
			
			test_origin = player.origin+(0,0,50); //Switches are about 50 units off the ground
			dist_sqr = DistanceSquared(test_origin, origin);
			
			dir_check = true;
			if(IsDefined(dir))
			{
				dir_to_player = VectorNormalize(test_origin - origin);
				dir_check = VectorDot(dir, dir_to_player)>.2;
			}
			
			if(dist_sqr<=show_dist_sqr && dir_check && (!isDefined(self.in_use) || !self.in_use) && !( player isUsingRemote() ) )
			{
				if(!IsDefined(player.door_switch_icons[icon_id]))
				{
					player.door_switch_icons[icon_id] = door_switch_icon_create(player, icon, origin, pin);
					player.door_switch_icons[icon_id].alpha = 0;
				}
				
				player.door_switch_icons[icon_id] notify("stop_fade");
				player.door_switch_icons[icon_id] thread door_switch_icon_fade_in();
			}
			else
			{
				if(IsDefined(player.door_switch_icons[icon_id]))
				{
					player.door_switch_icons[icon_id] thread door_switch_icon_fade_out();
				}
			}
		}
		wait .05;
	}
}

door_switch_icon_create(player, icon, origin, pin)
{
	icon = player createIcon( icon, 16, 16 );
	icon setWayPoint( true, pin );
	icon.x = origin[0];
	icon.y = origin[1];
	icon.z = origin[2];
	return icon;
}
	
door_switch_icon_fade_in()
{
	self endon("death");
	
	if(self.alpha == 1)
		return;
	
	self FadeOverTime(.5);
	self.alpha = 1;
}

door_switch_icon_fade_out()
{
	self endon("death");
	self endon("stop_fade");
	
	if(self.alpha == 0)
		return;
	
	time = .5;
	self FadeOverTime(time);
	self.alpha = 0;
	wait time;

	self Destroy();
}

pop_up_targets_set_buttons(on)
{
	if( IsDefined( self.button_toggles ) )
	{
		foreach( button in self.button_toggles )
		{
			button set_button( "mp_frag_button", on );
		}
	}
}

set_button(button_name, turn_on)
{
	if( turn_on )
	{
		name = button_name + "_on";
	}
	else
	{
		name = button_name + "_off";
	}	
	
	self.in_use = turn_on;
	self SetModel( name );
		
	if(IsDefined(self.fx_ent))
		self.fx_ent Delete();
	
	if(IsDefined(level._effect[name]) && IsDefined(self.fx_origin) && IsDefined(self.fx_fwd))
	{
		self.fx_ent = SpawnFx(level._effect[name], self.fx_origin, self.fx_fwd);
		TriggerFX(self.fx_ent);
	}
}

killplayer_UnresolvedCollision()
{
	self endon( "death" );

	while( 1 )
	{
		self waittill( "unresolved_collision", hitEnt );
		if ( isPlayer( hitEnt ) )
		{
			hitEnt DoDamage( hitEnt.health + 10, hitEnt.origin );
		}
		wait 0.05;
	}
}

traps_init()
{
	level thread tripwire_trap_init();
}

tripwire_trap_init()
{
	tripwire_traps = getstructarray( "tripwire_trap", "targetname" );
	foreach( trap in tripwire_traps )
	{
		linked_items = GetEntArray( trap.target, "targetname" );
		linked_items = array_combine( linked_items, getstructarray( trap.target, "targetname" ) );
									 
		foreach( item in linked_items )
		{
			switch( item.script_noteworthy )
			{
				case "tripwire_trigger":
					if( !IsDefined( trap.use_triggers ) )
					{
						trap.use_triggers = [];
					}
					trap.use_triggers[ trap.use_triggers.size ] = item;					
					break;
				case "trap_damage_trigger":
					if( !IsDefined( trap.damage_triggers ) )
					{
						trap.damage_triggers = [];
					}
					trap.damage_triggers[ trap.damage_triggers.size ] = item;	
					break;
				case "claymore_location":
					if( !IsDefined( trap.claymore_locations ) )
					{
						trap.claymore_locations = [];
					}
					trap.claymore_locations[ trap.claymore_locations.size ] = item;	
					break;
				default:
					break;
			}
		}	

		trap thread tripwire_trap_run();
	}
}

tripwire_trap_run()
{
	assert( IsDefined( self.use_triggers ) );
	assert( IsDefined( self.claymore_locations ) );
	assert( IsDefined( self.damage_triggers ) );
	
	while( 1 )
	{
		//todo: handle multiple triggers?
		
		// waiting to be set
		self.use_triggers[0] MakeUsable();
		self.use_triggers[0] SetHintString( &"MP_HASHIMA_SET_TRAP" );
		self.use_triggers[0] waittill( "trigger", player );
		
		// set, waiting to detonate/disarm
		self.owner = player;
		self.use_triggers[0] SetHintString( "" );
		self trap_spawn_claymores();

		self thread trap_disarm_watch();
		self thread trap_detonate_watch();
		
		self waittill( "trap_reset" );

		self.use_triggers[0] SetHintString( "" );
		self trap_delete_claymores();
		wait( 3.0 );
	}	
	
	
}

trap_spawn_claymores()
{	
	foreach( claymore_location in self.claymore_locations )
	{
		if( !IsDefined( self.claymore_models ) )
		{
			self.claymore_models = [];
		}
		claymore = Spawn( "script_model", claymore_location.origin );
		claymore.angles = claymore_location.angles;
		claymore SetModel( "weapon_claymore" );		
		self.claymore_models[ self.claymore_models.size ] = claymore;
	}
}

trap_delete_claymores()
{
	assert( isdefined( self.claymore_models ) );
	
	foreach( claymore in self.claymore_models )
	{
		claymore Delete();
		self.claymore_models = array_remove( self.claymore_models, claymore );
	}	
}

trap_disarm_watch()
{
	self endon( "trap_reset" );
	self endon( "trap_disarm_disabled" );
	disarm_delay = 3.0;

	wait( disarm_delay );
	self.use_triggers[0] MakeUnusable(); // removeme
	self.use_triggers[0] SetHintString( &"MP_HASHIMA_DISARM_TRAP" );	
	self.use_triggers[0] makeEnemyUsable( self.owner );
	self.use_triggers[0] waittill( "trigger", player );
	self notify( "trap_reset" );
}

trap_detonate_watch()
{
	self endon( "trap_reset" );

	while( 1 )
	{
		self.damage_triggers[0] waittill( "trigger", player );
		if( ( ( !level.teamBased ) && ( player != self.owner ) ) || ( level.teamBased && (player.team != self.owner.team )  ) )
		{
			break;
		}		
	}
	
	self notify( "trap_disarm_disabled" );
	self.use_triggers[0] SetHintString( "" );
	
	foreach( claymore in self.claymore_models )
	{
		claymore playsound ("claymore_activated");
	}	
	
	if ( IsPlayer( player ) && player _hasPerk( "specialty_delaymine" ) )
	{
		wait level.delayMineTime;
	}
	else
	{
		wait level.claymoreDetectionGracePeriod;	
	}
	
	foreach( claymore in self.claymore_models )
	{
		claymore thread play_fx_and_delete( level._effect[ "claymore_explosion" ] );
	}
	
	self.claymore_models[0]  PlaySound( "grenade_explode_metal" );
	
	foreach( participant in level.participants )
	{
		if( participant IsTouching( self.damage_triggers[0] ) )
		{
			participant DoDamage( 100, self.claymore_models[0].origin, self.owner, self.claymore_models[0], "MOD_EXPLOSIVE" );
		}
	}	
	
	self notify( "trap_reset" );
}

play_fx_and_delete( fx )
{
	if( !IsDefined( self.angles ) )
	{
		self.angles = ( 0,0,0 );
	}
	fwd = AnglesToForward( self.angles );
	up	= AnglesToUp( self.angles );	
	fx_ent = SpawnFx( fx , self.origin, fwd, up );
	TriggerFX( fx_ent );
	wait( 2.0 );
	fx_ent Delete();
}
