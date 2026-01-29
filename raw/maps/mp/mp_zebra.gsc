#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	maps\mp\mp_zebra_precache::main();
	maps\createart\mp_zebra_art::main();
	maps\mp\mp_zebra_fx::main();
	
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_zebra" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_zebra" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";	

	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit" ] = "desert";
	
	zebra_door_system( "door_switch" );
}

// ZEBRA DOOR STATS
CONST_ZEBRA_DOOR_MOVE_TIME_SEC	= 3.0;
CONST_ZEBRA_DOOR_PAUSE_TIME_SEC = 1.0;

// ZEBRA DOOR STATES
STATE_DOOR_CLOSED  = 0;
STATE_DOOR_CLOSING = 1;
STATE_DOOR_OPEN	   = 2;
STATE_DOOR_OPENING = 3;
STATE_DOOR_PAUSED  = 4;

// Door logic for Zebra. If this is desired for other levels I'll pull it out into a common script - JC
zebra_door_system( buttonName )
{
	buttons = GetEntArray( buttonName, "targetname" );
	
	foreach ( button in buttons )
	{
		button zebra_door_setup();
	}
	
	foreach ( button in buttons )
	{
		button thread zebra_door_think();
	}
}

zebra_door_setup()
{
	button = self;
	
	// Setup door references
	AssertEx( IsDefined( button.target ), "zebra_door_setup() found switch without at least one door target." );
	
	button.doors = [];
	
	targetEnts = GetEntArray( button.target, "targetname" );
	foreach ( ent in targetEnts )
	{
		if ( IsSubStr( ent.classname, "trigger" ) )
		{
			button.trigBlock = ent;
		}
		else if ( ent.classname == "script_brushmodel" || ent.classname == "script_model" )
		{
			if ( IsDefined( ent.script_noteworthy ) && IsSubStr( ent.script_noteworthy, "light" ) )
			{
				if ( IsSubStr( ent.script_noteworthy, "light_on" ) )
				{
					button.light_on = ent;
					button.light_on Hide();
				}
				else if ( IsSubStr( ent.script_noteworthy, "light_off" ) )
				{
					button.light_off = ent;
					button.light_off Hide();
				}
				else
				{
					AssertMsg( "Invalid light ent with script_noteworthy of: " + ent.script_noteworthy );
				}
			}
			else
			{
				button.doors[ button.doors.size ] = ent;
			}
		}
		else if ( ent.classname == "script_origin" )
		{
			button.entSound = ent;
		}
	}
	
	if ( !IsDefined( button.entSound ) && button.doors.size )
	{
		button.entSound = SortByDistance( button.doors, button.origin )[ 0 ];
	}
	
	foreach ( door in button.doors )
	{
		AssertEx( IsDefined( door.target ), "zebra_door_setup() found door without a close position struct target." );
		door.posClosed = door.origin;
		door.posOpen   = getstruct( door.target, "targetname" ).origin;
		door.distMove  = Distance( door.posOpen, door.posClosed );
		
		door.origin = door.posOpen;
	}
}

zebra_door_think()
{
	button = self;
	
	button zebra_door_state_change( STATE_DOOR_OPEN );
	
	while ( 1 )
	{
		button.stateDone		= undefined;
		button.stateInterrupted = undefined;
		
		button waittill_any( "zebra_door_state_done", "zebra_door_state_interrupted" );
		
		// Prefer state done over state interrupted
		if ( IsDefined( button.stateDone ) && button.stateDone )
		{
			stateNext = button zebra_door_state_next( button.stateCurr );
			button zebra_door_state_change( stateNext );
		}
		else if ( IsDefined( button.stateInterrupted ) && button.stateInterrupted )
		{
			button zebra_door_state_change( STATE_DOOR_PAUSED );
		}
		else
		{
			AssertMsg( "state finished without being flagged as done or interrupted." );
		}
	}
}

zebra_door_state_next( state )
{
	button = self;
	stateNext = undefined;
	
	switch ( state )
	{
		case STATE_DOOR_CLOSED:
			stateNext = STATE_DOOR_OPENING;
			break;
		case STATE_DOOR_OPEN:
			stateNext = STATE_DOOR_CLOSING;
			break;
		case STATE_DOOR_CLOSING:
			stateNext = STATE_DOOR_CLOSED;
			break;
		case STATE_DOOR_OPENING:
			stateNext = STATE_DOOR_OPEN;
			break;
		case STATE_DOOR_PAUSED:
			AssertEx( IsDefined( button.statePrev ), "zebra_door_state_next() was passed STATE_DOOR_PAUSED without a previous state to go to." );
			stateNext = button.statePrev;
			break;
		default:
			AssertMsg( "Unhandled state value of: " + state );
	}
	
	return stateNext;
}

zebra_door_state_update()
{
	button = self;
	
	button endon( "zebra_door_state_interrupted" );
	
	button.stateDone = undefined;
	
	switch ( button.stateCurr )
	{
		case STATE_DOOR_CLOSED:
		case STATE_DOOR_OPEN:
		{
			PlaySoundAtPos( button.entSound.origin, "garage_door_end" );

			if ( IsDefined( button.light_on ) )
			{
				button.light_on Show();
			}
			
			foreach ( door in button.doors )
			{
				if ( button.stateCurr == STATE_DOOR_CLOSED )
				{
					door DisconnectPaths();
				}
				else
				{
					door ConnectPaths();
				}
			}
			
			hintString = ter_op( button.stateCurr == STATE_DOOR_CLOSED, &"MP_DOOR_USE_OPEN", &"MP_DOOR_USE_CLOSE" );			
			button SetHintString( hintString );
			button MakeUsable();
			button waittill( "trigger" );
			break;
		}
		case STATE_DOOR_CLOSING:
		case STATE_DOOR_OPENING:
		{
			if ( IsDefined( button.light_off ) )
			{
				button.light_off Show();
			}
			
			button MakeUnusable();
			
			if ( button.stateCurr == STATE_DOOR_CLOSING )
			{
				button thread zebra_door_state_on_interrupt();
			}
			
			// Give the interrupt thread time to stop the door before a move starts
			wait 0.1;
			
			button childthread zebra_door_state_update_sound( "garage_door_start", "garage_door_loop" );
			
			timeMax = undefined;
			foreach ( door in button.doors )
			{
				posGoal = ter_op( button.stateCurr == STATE_DOOR_CLOSING, door.posClosed, door.posOpen );
				
				if ( door.origin != posGoal )
				{
					time = max( 0.1, Distance( door.origin, posGoal ) / door.distMove * CONST_ZEBRA_DOOR_MOVE_TIME_SEC );
					timeEase = max( time * 0.25, 0.05 );
					door MoveTo( posGoal, time,	timeEase, timeEase );
					
					if ( !IsDefined( timeMax ) || time > timeMax )
					{
						timeMax = time;
					}
				}
			}
			
			if ( IsDefined( timeMax ) )
			{
				wait timeMax;
			}
			break;
		}
		case STATE_DOOR_PAUSED:
		{
			foreach ( door in button.doors )
			{
				door MoveTo( door.origin, 0.05, 0.0, 0.0 );
			}
			
			AssertEx( IsDefined( button.statePrev ) && ( button.statePrev == STATE_DOOR_CLOSING || button.statePrev == STATE_DOOR_OPENING ), "zebra_door_state_init() called with pause state without a valid previous state." );
			
			// Make sure the light's off state remains on during pause
			if ( IsDefined( button.light_off ) )
			{
				button.light_off Show();
			}
			
			button.entSound StopLoopSound();
			playSoundAtPos( button.entSound.origin, "garage_door_interupt" );
			
			wait CONST_ZEBRA_DOOR_PAUSE_TIME_SEC;
			break;
		}
		default:
			AssertMsg( "Unhandled state value of: " + button.stateCurr );
	}
	
	button.stateDone = true;
	button notify( "zebra_door_state_done" );
}

zebra_door_state_update_sound( soundStart, soundLoop )
{
	button = self;
	
//	button.entSound PlaySound( soundStart, "sound_door_notify" );
	playSoundAtPos( button.entSound.origin, soundStart );
//	button.entSound waittill( "sound_door_notify" );
	
	button.entSound PlayLoopSound( soundLoop );
}

zebra_door_state_change( state )
{
	button = self;
	if ( IsDefined( button.stateCurr ) )
	{
		zebra_door_state_exit( button.stateCurr );
		button.statePrev = button.stateCurr;
	}
	
	button.stateCurr = state;
	
	button thread zebra_door_state_update();
}

zebra_door_state_exit( state )
{
	button = self;
	
	switch ( state )
	{
		case STATE_DOOR_CLOSED:
		case STATE_DOOR_OPEN:
			if ( IsDefined( button.light_on ) )
			{
				button.light_on Hide();
			}
			break;
		case STATE_DOOR_CLOSING:
		case STATE_DOOR_OPENING:
			if ( IsDefined( button.light_off ) )
			{
				button.light_off Hide();
			}
//			button.entSound notify( "sound_door_notify" );
			button.entSound StopLoopSound();
			break;
		case STATE_DOOR_PAUSED:
			break;
		default:
			AssertMsg( "Unhandled state value of: " + state );
	}
}

zebra_door_state_on_interrupt()
{
	button = self;
	
	button endon( "zebra_door_state_done" );
	
	trig = button.trigBlock;
	
	trig waittill( "trigger" );
	
	button.stateInterrupted = true;
	button notify( "zebra_door_state_interrupted" );
}
