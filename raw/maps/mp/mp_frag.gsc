#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	maps\mp\mp_frag_precache::main();
	maps\createart\mp_frag_art::main();
	maps\mp\mp_frag_fx::main();
	
	precache();
	
	level.dynamicSpawns = ::filter_spawn_point;
	
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_frag" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_frag" );
	
	if(!level.console ) // || level.ps4 || level.xb3)
	{
		setdvar( "sm_sunShadowScale", "0.7" );
		setdvar( "r_lightGridEnableTweaks", 1 );
		setdvar( "r_lightGridIntensity", 1.33 );
        setdvar_cg_ng( "r_diffuseColorScale", 1.37, 3.5 );
        setdvar_cg_ng( "r_specularcolorscale", 3, 12 );
	    setdvar( "sm_sunShadowScale", "0.8" ); 
		SetDvar("r_sky_fog_intensity","1");
	    SetDvar("r_sky_fog_min_angle","75");
	    SetDvar("r_sky_fog_max_angle","85");

	}
	else
	{
		if ( level.ps3 )
		{
			setdvar( "sm_sunShadowScale", "0.6" ); // ps3 optimization
		}
		else
		{
			setdvar( "sm_sunShadowScale", "0.7" ); // optimization
		}
	
		setdvar( "r_lightGridEnableTweaks", 1 );
		setdvar( "r_lightGridIntensity", 1.33 );
		setdvar( "r_diffuseColorScale", 1.37 );
	    setdvar( "r_specularcolorscale", 2 );
	    setdvar( "sm_sunShadowScale", "0.8" ); // optimization
		SetDvar("r_sky_fog_intensity","1");
	    SetDvar("r_sky_fog_min_angle","75");
	    SetDvar("r_sky_fog_max_angle","85");
	}
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";

	game[ "allies_outfit" ] = "woodland";
 	game[ "axis_outfit" ] = "arctic";
	
 	flag_init( "chain_broken" );
 	// these next two could probably be combined, but I'm keeping them separate in case we find we want to do something with the middle condition (hopper neither open nor closed while moving)
 	flag_init( "hopper_closed" );
 	flag_init( "hopper_open" );

 	flag_set( "hopper_closed" );

 	hide_ai_sight_brushes();

	level thread use_switch_toggle_multiple();
	level thread pop_up_targets();
	level thread script_mover_connect_watch();
	level thread gate_chain();
	level thread bot_underground_trapped_watch();
}

precache()
{
	PrecacheMpAnim( "mp_frag_metal_door_chain" );
	PrecacheMpAnim( "mp_frag_metal_door_closed_loop" );
	PrecacheMpAnim( "mp_frag_metal_door_open" );		
	PrecacheMpAnim( "mp_frag_metal_door_open_loop" );
	PrecacheMpAnim( "mp_frag_metal_door_open_out" );		
	PrecacheMpAnim( "mp_frag_metal_door_open_out_loop" );	
}

gate_chain()
{
	left_gate  = GetEnt( "left_gate", "targetname" );
	right_gate = GetEnt( "right_gate", "targetname" );
	lock	   = GetEnt( "lock", "targetname" );
	gate_clip  = GetEnt( "gate_clip", "targetname" );
	gate_trigger = GetEnt( "gate_trigger", "targetname" );
	
	gate_anim_node = Spawn( "script_model", left_gate.origin );
	gate_anim_node SetModel( "generic_prop_raven" );
	waitframe();
	gate_anim_node ScriptModelPlayAnim( "mp_frag_metal_door_closed_loop" );
	waitframe();
	
	left_gate LinkTo( gate_anim_node, "j_prop_1" );
	right_gate LinkTo( gate_anim_node, "j_prop_2" );
	
	waitframe();
	gate_clip ConnectPaths();
	add_to_bot_damage_targets( gate_trigger );
	lock ScriptModelPlayAnim( "mp_frag_metal_door_chain" );	
	gate_trigger waittill( "damage", amount, attacker, direction_vec, point, type );

	open_in = ( direction_vec[1] < 0 );
	
	lock Delete();
	remove_from_bot_damage_targets( gate_trigger );
	gate_trigger Delete();
 	flag_set( "chain_broken" );	
	left_gate playsound( "frag_gate_iron_open" );
	
	if( open_in )
	{
//		IPrintLnBold( "ScriptModelPlayAnimDeltaMotion  - mp_frag_metal_door_open" );
		gate_anim_node ScriptModelPlayAnimDeltaMotion( "mp_frag_metal_door_open" );
	}
	else
	{
//		IPrintLnBold( "ScriptModelPlayAnimDeltaMotion  - mp_frag_metal_door_open_out" );
		gate_anim_node ScriptModelPlayAnimDeltaMotion( "mp_frag_metal_door_open_out" );
	}
	
	wait( 0.3 );

	waitframe();
	gate_clip Delete();
}

hide_ai_sight_brushes()
{
	ai_sight_brush_array = GetEntArray( "ai_sight_brush", "targetname" );
	
	foreach( ai_sight_brush in ai_sight_brush_array )
	{
		ai_sight_brush NotSolid();
		ai_sight_brush Hide();
		ai_sight_brush SetAISightLineVisible( false );
	}
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
			case "lever":
				if( !IsDefined( self.levers ) )
				{
					self.levers = [];
				}
				num_levers =  self.levers.size;
				self.levers[ num_levers ]						= target;
				self.levers[ num_levers ].lever_off_angles 		= target.angles;
				self.levers[ num_levers ].lever_on_angles  		= target.angles +( 0, 0, 180 );
				if ( IsDefined( self.levers[ num_levers ].target ) )
				{
					pressed_pos = getstruct( self.levers[ num_levers ].target, "targetname" );
					if ( IsDefined( pressed_pos ) )
						self.levers[ num_levers ].lever_on_angles = pressed_pos.angles;
				}
				break;
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
						if( IsDefined( self.script_noteworthy ) )
						{
							if( self.script_noteworthy == "hopper" )
							{
								self.off_hintString = &"MP_FRAG_MOVE_HOPPER";
								self.on_hintString	= &"MP_FRAG_MOVE_HOPPER";
							}
						}
						else
						{
							self.off_hintString = &"MP_FRAG_OPERATE_DOOR";
							self.on_hintString	= &"MP_FRAG_OPERATE_DOOR";
						}
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
		self.script_delay = 1;

	if ( ( IsDefined( self.levers ) || IsDefined( self.button_toggles ) ) && IsDefined( self.use_triggers ) )
	{
		self use_switch_toggle_wait();
	}
}

toggle_button( button_name )
{
	if( IsEndStr( self.model, "on" ) )
	{
		set_button(button_name, false);
	}
	else
	{
		set_button(button_name, true);
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
pop_up_targets_toggle_buttons()
{
	if( IsDefined( self.button_toggles ) )
	{
		foreach( button in self.button_toggles )
		{
			button toggle_button( "mp_frag_button" );
		}
	}
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

hopper_wheel( initially_clockwise, movetime )
{
	rotation_direction = 1;
	
	if( initially_clockwise )
	{
		rotation_direction = -1;
	}

	self RotateRoll( rotation_direction * 706, movetime ); // wheel diameter: 30; distance travelled is approx 185
}

script_mover_connect_watch()
{
	while(1)
	{
		level waittill("connected", player);
		player thread player_unresolved_collision_watch();
		retrigger_switch_fx();
	}
}

//TODO: I dont thing I should have to do this, but fx are not currently showing up for player that join late.
retrigger_switch_fx()
{
	foreach(button in level.door_buttons)
	{
		if(IsDefined(button.fx_ent))
		{
			triggerfx(button.fx_ent);
		}
	}
}

player_unresolved_collision_watch()
{
//	self endon("death");
	self endon("disconnect");
	
	self.unresolved_collision=undefined;
	self thread player_unresolved_collision_update();
	
	while(1)
	{
		while(!isDefined(self.unresolved_collision))
		{
			wait .05;
		}
		
		unresolved_collision_count = 0;
		
		while(isDefined(self.unresolved_collision))
		{
			unresolved_collision_count++;
			unresolved_collision_kill_count = self.unresolved_collision script_mover_get_num_unresolved_collisions();
			if(unresolved_collision_count>unresolved_collision_kill_count)
			{
				playerNum = self GetEntityNumber();
				moverNum = self.unresolved_collision GetEntityNumber();
				println("Unresolved Collision (" + unresolved_collision_kill_count + ") - Player: " + playerNum + " " + self.origin + " Mover: "+ moverNum + " " + self.unresolved_collision.origin);
				self _suicide();
			}
			self.unresolved_collision = undefined;
			wait .05;
		}
	}
}

script_mover_get_num_unresolved_collisions()
{	
	return 1;
}

player_unresolved_collision_update()
{
//	self endon("death");
	self endon("disconnect");
	while(1)
	{
		self waittill("unresolved_collision", mover);
		if(self IsMantling())
			continue;
		if(mover script_mover_get_num_unresolved_collisions() < 0)
			continue;
		
		self.unresolved_collision=mover;
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

bot_underground_trapped_watch()
{
	level endon( "chain_broken" );
	
	escape_trigger = GetEnt( "gate_trigger", "targetname" );
	underground_volume = GetEnt( "underground_volume", "targetname" );
	
	while( 1 )
	{
		while( flag( "hopper_closed" ) )
		{			
			if( IsDefined( level.participants ) )
			{
				foreach( participant in level.participants )
				{
					if(  IsAI( participant ) && participant IsTouching( underground_volume ) )
					{
						escape_trigger set_high_priority_target_for_bot( participant );
					}
				}
			}						
			wait( 0.5 );
		}
		while( flag( "hopper_open" ) )
		{		
			wait( 0.5 );
		}
	}
}

filter_spawn_point( spawnPoints )
{
	underground_height = 32;
	
	valid_spawns = [];
	foreach( spawnPoint in spawnPoints)
	{
		if( flag( "hopper_closed" ) && ( spawnPoint.origin[2] < underground_height ) )
		{
			continue;
		}
		valid_spawns[valid_spawns.size] = spawnPoint;
	}
		
	return valid_spawns;
}
