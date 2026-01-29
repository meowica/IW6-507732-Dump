#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hostmigration;

main()
{
	maps\mp\mp_snow_precache::main();
	maps\createart\mp_snow_art::main();
	maps\mp\mp_snow_fx::main();
	thread maps\mp\_fx::func_glass_handler(); // Text on glass
	
	precache();
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_snow" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_snow" );
	
	//   			dvar_name 		      current_gen_val    next_gen_val   
	setdvar_cg_ng( "r_specularColorScale", 2.3				  	, 20 );
	setdvar_cg_ng( "r_diffuseColorScale" , 1.2			  		, 3 );
	SetDvar( "r_sky_fog_intensity"	, "1" );
	SetDvar( "r_sky_fog_min_angle"	, "74.6766" );
	SetDvar( "r_sky_fog_max_angle"	, "91.2327" );
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_lightGridIntensity"	  , 1.33 );
	
	game[ "attackers"	  ] = "allies";
	game[ "defenders"	  ] = "axis";
	game[ "allies_outfit" ] = "woodland";
	game[ "axis_outfit"	  ] = "arctic";
	 
	flag_init( "satellite_active" );
	flag_init( "satellite_charged" );

	waitframe();
	
	if ( level.gameType == "war" )
	{
		level thread satellite_fall();
//		level thread satellite_loop_for_debugging();
	}
	
	//level thread satellite_loop_for_debugging();
	if ( ( level.gameType == "war" ) || ( level.gameType == "dm" ) || ( level.gameType == "conf" ) )
	{
//		level thread uav_ping_monitor();
		level thread play_scrambler_on_connect();
	}

						 //   targetname    animname 		     min_wait    max_wait   
	level thread group_anim( "buoy"		 , "mp_snow_buoy_sway", 0.2		  , 1.0 );
	level thread group_anim( "boat"		 , "mp_snow_boat_sway", 0.2		  , 1.0 );
	thread play_fx_onConnect();
	
//	level thread rotating_windows();
}


play_fx_onConnect()
{
	obj = GetEnt("lighthouse","targetname");
	obj thread spin_objects();
	
	tag_origin = obj spawn_tag_origin();
	tag_origin show();
	
	tag_origin MoveTo(tag_origin.origin+(0,0,70),.05);
	
	waitframe();
	
	tag_origin thread spin_objects();
	
	while(true)
	{
		level waittill("connected",player);
		player thread play_fx_delay(tag_origin);
	}

}

play_fx_delay(tag_origin)
{
	self thread check_if_spawned(tag_origin);
	foreach(element in level.players)
	{
		element thread check_if_spawned(tag_origin);
	}
}
check_if_spawned(tag_origin)
{
	self waittill("spawned");
	wait .05;
	if(!isDefined(self.lighthouse_fx) || !self.lighthouse_fx)
	{
		self.lighthouse_fx = true;
		PlayFXOnTagForClients(level._effect["vfx_lighthouse_flare"],tag_origin,"tag_origin",self);
	}
}

spin_objects()
{
	self endon("death");
    speed = 25;
    speed_multiplier = 1;
    speed = speed*speed_multiplier;
    
    ang      = self.angles;
    vec      = ( AnglesToRight( self.angles ) * 100 );    // assures normalized vector is length of "1"
    vec      = VectorNormalize( vec );
    
    time = 20000;
    while ( true )
    {
        dot_x      = abs( vectorDot( vec, ( 1, 0, 0 ) ) );
        dot_y      = abs( vectorDot( vec, ( 0, 1, 0 ) ) );
        dot_z      = abs( vectorDot( vec, ( 0, 0, 1 ) ) );

        if ( dot_x > 0.9 )
        {
            self rotatevelocity( ( speed, 0, 0 ), time );
        }
        else if ( dot_y > 0.9 )
        {
            self rotatevelocity( ( speed, 0, 0 ), time );
        }
        else if ( dot_z > 0.9 )
        {
            self rotatevelocity( ( 0, speed, 0 ), time );
        }
        else
        {
            self rotatevelocity( ( 0, speed, 0 ), time );
        }
        wait time;
    }
}

precache()
{
	level._effect[ "satellite_fall" ] 		= loadfx( "vfx/moments/mp_snow/satellite_fall_parent" );
	
	PrecacheMpAnim( "mp_snow_boat_sway" );	
	PrecacheMpAnim( "mp_snow_buoy_sway" );
	PrecacheMpAnim( "mp_snow_tree_fall" );
}
satellite_loop_for_debugging()
{
	tree_broken_stump = GetEnt( "tree_broken_stump", "targetname" );	
	tree_broken_top = GetEnt( "tree_broken_top", "targetname" );	

	anim_ref = spawn( "script_model", tree_broken_stump.origin );
	anim_ref.angles = (0,0,0);
	anim_ref SetModel( "generic_prop_raven" );
	tree_broken_stump Linkto( anim_ref, "j_prop_1" );
	tree_broken_top Linkto( anim_ref, "j_prop_2" );

	
	wait( 30 );	
	
	while( 1 )
	{
		wait( 3 );
		exploder( "1" );
		
		delay_between_exploders = 4.7;
		delay_until_animation = 4.5;
		wait( delay_until_animation );
		
		anim_ref ScriptModelPlayAnim( "mp_snow_tree_fall" );
		
		wait( delay_between_exploders - delay_until_animation );
		exploder( "2" );
		wait(.6);
		exploder( "4" );
		wait(1.4);
		exploder( "3" );
	}		
}
	
satellite_fall()
{
	tree_broken_stump = GetEnt( "tree_broken_stump", "targetname" );	
	tree_broken_top = GetEnt( "tree_broken_top", "targetname" );	

	anim_ref = spawn( "script_model", tree_broken_stump.origin );
	anim_ref.angles = (0,0,0);
	anim_ref SetModel( "generic_prop_raven" );
	tree_broken_stump Linkto( anim_ref, "j_prop_1" );
	tree_broken_top Linkto( anim_ref, "j_prop_2" );
	
	gameFlagWait( "prematch_done" );
	exploder( "1" );
	delay_between_exploders = 4.7;
	delay_until_animation = 4.5;
	wait( delay_until_animation );
	
	anim_ref ScriptModelPlayAnim( "mp_snow_tree_fall" );
	
	wait( delay_between_exploders - delay_until_animation );
	exploder( "2" );
	wait(.6);
	exploder( "4" );
	wait(1.4);
	exploder( "3" );
}

move_satellite( end )
{
	start = self.origin;
	fall_time = 3.0;
	accel_time = 3.0;
	
	while( 1 )
	{
		self MoveTo( end, fall_time, accel_time, 0 );
		wait( fall_time + 3.0 );
		self MoveTo( start, 0.1 );
		wait( 0.1 );
	}
	
}
	
play_scrambler_on_connect()
{
	while( 1 )
	{
		level waittill( "connected", player );
		player thread run_func_after_spawn( ::satellite_scrambler );
	}
	
}


//Self == player
run_func_after_spawn( func )
{
	self endon("disconnect");
	self endon("death");
	
	self waittill("spawned_player");
	
	self thread [[func]]();
}

play_satellite_fx()
{
	satellite_ents = GetEntArray( "satellite_ent", "targetname" );
	foreach( satellite in satellite_ents )
	{
		playfxontagForClients( level._effect[ "satellite_fall" ], satellite, "tag_origin", self );
		wait( 0.3 );
	}
}

group_anim( targetname, animname, min_wait, max_wait )
{
	animating_objects = GetEntArray( targetname, "targetname" );
	foreach( object in animating_objects )
	{
		if( IsDefined( min_wait ) && IsDefined( max_wait ) )
		{
			wait( RandomfloatRange( min_wait, max_wait ) );
		}
		
		anim_ref = spawn( "script_model", object.origin );
		anim_ref.angles = (0,0,0);
		anim_ref SetModel( "generic_prop_raven" );
		object Linkto( anim_ref, "j_prop_1" );
		anim_ref ScriptModelPlayAnim( animname );
		
		// for subobjects linked to the main object
		if( IsDefined( object.target) )
		{
			subobjects = GetEntArray( object.target, "targetname" );
			foreach( subobject in subobjects )
			{
				subobject Linkto( anim_ref, "j_prop_1" );
			}
		}		
	}	
}

uav_ping_monitor()
{
	trigger = GetEnt( "satellite_use_trigger", "targetname" );
	min_on_time = 1.0;
	min_off_time = 3.0;

	
	panel_loc_struct = getstruct( "satellite_use_loc", "targetname" );
	panel = spawn( "script_model", panel_loc_struct.origin );
	panel.angles = panel_loc_struct.angles;
	panel SetModel( "sor_console_objectivepanel" );

	panel thread uav_all_players();
	
	while( true )
	{
		trigger SetHintString( &"MP_SNOW_BIG_BROTHER_ACTIVATE" );
		trigger waittill( "trigger", player );
		trigger SetHintString( "" );
		flag_set( "satellite_active" );
		panel SetModel( "sor_console_objectivepanel_obj" );
		panel playSound( "counter_uav_activate" );
		
		wait( min_on_time );
		
		trigger SetHintString( &"MP_SNOW_BIG_BROTHER_DEACTIVATE" );
		trigger waittill( "trigger", player );
		trigger SetHintString( "" );
		flag_clear( "satellite_active" );
		panel SetModel( "sor_console_objectivepanel" );
		panel playSound( "emp_activate" );

		wait( min_off_time );		
	}
}

uav_all_players()
{	
	pulse_time = 5.0; // duration satellite is active
	recharge_time = 10.0;

	self thread ping_fx();
	
	while( true )
	{
		
		flag_wait( "satellite_active" );
//		iprintlnbold( "Big Brother Active!" );
	
		// TODO: make sure this doesn't override/interfere with whatever the standard killstreak rewards end up being
		while( flag( "satellite_active" ) )
		{
			flag_set( "satellite_charged" );

			foreach( participant in level.participants )
			{
				participant.hasRadar = true;
			}

			self PlaySound( "snow_power_up" );
			
//			iprintlnbold( "Big Brother Scanning!" );
			
			flag_waitopen_or_timeout( "satellite_active", pulse_time );
			flag_clear( "satellite_charged" );
			
			if( flag( "satellite_active" ) )
			{	
				foreach( participant in level.participants )
				{
					participant.hasRadar = false;
				}
	
//				iprintlnbold( "Big Brother Recharging!" );
				self PlaySound( "snow_power_down" );
				flag_waitopen_or_timeout( "satellite_active", recharge_time );

			}
		}

//		iprintlnbold( "Big Brother Deactivated!" );

		foreach( participant in level.participants )
		{
			participant.hasRadar = false;

		}				
	}		
}

ping_fx()
{
	ping_interval = 2.0;
	
	while( 1 )
	{
		wait( ping_interval );
		if( flag( "satellite_active" ) && flag( "satellite_charged" ) )
		{
			PlayFX( level.uavSettings[ "uav_3dping" ].fxId_ping, self.origin );
			self PlaySound( level.uavSettings[ "uav_3dping" ].sound_ping );
		}
	}	
}

// ping all players and show to all other players
uav_3dping_all_players()
{
	// originally taken and modified from _uav.gsc
	uavType = "uav_3dping";

	// every N seconds do a ping of the world and show enemies in red
	pingTime = level.uavSettings[ uavType ].pingTime;
	
	while( true )
	{

		// highlight all players in the world that can't be seen
		foreach( highlighted_player in level.participants )
		{
			if( !isReallyAlive( highlighted_player ) )
				continue;		

				highlighted_player PlayLocalSound( level.uavSettings[ uavType ].sound_ping );				
			
//			if( enemy _hasPerk( "specialty_blindeye" ) )
//				continue;

			modelHighlight = Spawn( "script_model", highlighted_player.origin );
			modelHighlight.angles = highlighted_player.angles;
			modelHighlight SetContents( 0 );
			modelHighlight Hide();

			foreach( observing_player in level.participants )
			{
				if( !isReallyAlive( observing_player ) )
					continue;

				if( level.teamBased && ( observing_player.team == highlighted_player.team ) )
					continue;
				else if( !level.teamBased && ( observing_player == highlighted_player ) )
					continue;

				if( !SightTracePassed( observing_player GetEye(), highlighted_player GetEye(), false, observing_player, highlighted_player ) )
				{
					modelHighlight ShowToPlayer( observing_player );
				}
				

				//PrintLn( "watch3DPing: GetTime() " + GetTime() + " PingTime " + pingTime );
//				PlayFX( level.uavSettings[ uavType ].fxId_ping, observing_player.origin );				
			}

			stance = highlighted_player GetStance();

			switch( stance )
			{
			case "stand":
				modelHighlight SetModel( level.uavSettings[ uavType ].modelHighlightS );
				break;
			case "crouch":
				modelHighlight SetModel( level.uavSettings[ uavType ].modelHighlightC );
				break;
			case "prone":
				modelHighlight SetModel( level.uavSettings[ uavType ].modelHighlightP );
				break;
			}

			fadeTime = level.uavSettings[ uavType ].highlightFadeTime;
/#
			fadeTime = GetDvarFloat( "scr_uav_3dping_highlightFadeTime" );
#/
			modelHighlight thread fadeHighlightOverTime( fadeTime );
		}
/#
		pingTime = GetDvarFloat( "scr_uav_3dping_pingTime" );
		// host migration wipes out this dvar for some reason and causes the loop to continue when it shouldn't
		if( pingTime < 1 )
			pingTime = level.uavSettings[ uavType ].pingTime;
#/
		waitLongDurationWithHostMigrationPause( pingTime );
	}
} 

fadeHighlightOverTime( time ) // self == highlight (model for now)
{
	self endon( "death" );

	wait( time );
	self delete();
}

rotating_windows()
{	
	windows = GetEntArray  ( "rotating_window", "targetname" );
	array_thread( windows, ::rotating_windows_init );	
}

rotating_windows_init()
{
	if ( !IsDefined( self.target ) )
		return;
	
	structs = getstructarray( self.target, "targetname" );
	foreach( struct in structs )
	{
		switch( struct.script_noteworthy )
		{
			case "open_angles":
				self.open_angles = struct.angles;
				break;
			case "closed_angles":
				self.closed_angles = struct.angles;
				break;
			default:
				break;
		}
	}
	
	ents = GetEntArray( self.target, "targetname" );
	self.hide_when_closed = [];
	foreach( ent in ents )
	{
		switch( ent.script_noteworthy )
		{
			case "open_trigger":
				self.open_trigger = ent;
				break;
			case "close_trigger":
				self.close_trigger = ent;
				break;
			case "hide_when_closed":
				self.hide_when_closed[self.hide_when_closed.size] = ent;
				break;
			default:
				break;
		}
	}	
	
	
	self SetCanDamage( false );
	self thread rotating_windows_run();	
}

rotating_windows_run()
{
	window_node = Spawn( "script_model", self.origin );
	window_node.angles = self.open_angles;
	window_node SetModel( "tag_origin" );
	self LinkTo( window_node, "tag_origin" ) ;

	start_closed = false;
	if( IsDefined( self.script_noteworthy ) && ( self.script_noteworthy == "start_closed" ) )
	{
		start_closed = true;
		self.open_trigger trigger_off();
		foreach( hide_me in self.hide_when_closed )
		{
			hide_me Hide();
		}
	}
	else
	{
		self.close_trigger trigger_off();
		foreach( hide_me in self.hide_when_closed )
		{
			hide_me Show();
		}
	}
	
	pitch_rotation = AngleClamp( self.closed_angles[0] - self.open_angles[0] );
	
	while( 1 )
	{
		if( start_closed )
		{
			start_closed = false;
		}
		else
		{
			self.open_trigger trigger_off();
			self.close_trigger trigger_on();
			self.close_trigger waittill( "trigger" );
			foreach( hide_me in self.hide_when_closed )
			{
				hide_me Hide();
			}
			window_node RotatePitch( pitch_rotation, 0.3, 0, 0 );
			wait( 1 );
		}
		
		self.open_trigger trigger_on();
		self.close_trigger trigger_off();

		self.open_trigger waittill( "trigger" );
		window_node RotatePitch( -1 * pitch_rotation, 0.3, 0, 0 );
		wait( 0.3 );
		foreach( hide_me in self.hide_when_closed )
		{
			hide_me Show();
		}
		wait( 0.7 );
	}	
}

satellite_scrambler()
{
	scrambler_loc_struct = getstruct( "satellite_use_loc", "targetname" );
	scrambler = spawn( "script_model", scrambler_loc_struct.origin );
	scrambler.angles = scrambler_loc_struct.angles;
	
	scrambler MakeScrambler( self );	
}