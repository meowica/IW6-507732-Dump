#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;

init()
{
	if ( isdefined( anim.tank_bc ) )
		return;

	level.tank_chatter_enabled = true;
		
	anim.tank_bc = spawnstruct();  // holds all of our SO-specific bc stuff
	anim.tank_bc.bc_isSpeaking = false;
	
	anim.tank_bc.numTankVoices = 1;
	anim.tank_bc.currentAssignedVoice = 0;
	
	anim.tank_bc.lastAlias = [];
	
	anim.tank_bc.bc_eventTypeLastUsedTime = [];
	anim.tank_bc.bc_eventTypeLastUsedTimePlr = [];
		
	anim.tank_bc.eventTypeMinWait = [];
	anim.tank_bc.eventTypeMinWait[ "same_alias" ]			= 15;
	anim.tank_bc.eventTypeMinWait[ "callout_clock" ]		= 10;
	anim.tank_bc.eventTypeMinWait[ "killfirm" ]				= 3;
	anim.tank_bc.eventTypeMinWait[ "inform_firing" ]		= 10;
	anim.tank_bc.eventTypeMinWait[ "inform_taking_fire" ]	= 30;
	anim.tank_bc.eventTypeMinWait[ "inform_reloading" ]		= 5;
	anim.tank_bc.eventTypeMinWait[ "inform_loaded" ]		= 0.5;
	anim.tank_bc.eventTypeMinWait[ "inform_enemy_hit" ]		= 5;
	anim.tank_bc.eventTypeMinWait[ "inform_enemy_retreat" ]	= 5;
	
	anim.tank_bc.bcPrintFailPrefix = "^3***** BCS FAILURE: ";
}


init_chatter()
{
	if ( isPlayer( self ) )
	{
		self.voiceID = "plr";
		self.bc_isSpeaking = false;
		
		// Player only
		self thread enemy_callout_tracking_plr();
	}
	else
	{
		return; // AI battlechatter not ready
		//self.voiceID = anim.tank_bc.currentAssignedVoice + 1;
		//anim.tank_bc.currentAssignedVoice = ( anim.tank_bc.currentAssignedVoice + 1 )%anim.tank_bc.numHeliVoices;
	}

	self.bc_enabled = true;
	
	// Player and AI
	self thread tank_shoot_tracking();
	self thread take_fire_tracking();
}

tank_shoot_tracking()
{
	self endon( "death" );
	while( 1 )
	{
		self.tank waittill( "firing" );
		event = createEvent( "inform_firing", "inform_firing" );	
		self thread play_chatter( event );
		self.tank waittill( "reloading" );
		event = createEvent( "inform_reloading", "inform_reloading" );	
		self thread play_chatter( event );
		self.tank waittill( "reloaded" );
		event = createEvent( "inform_loaded", "inform_loaded" );	
		self thread play_chatter( event );
	}
}

enemy_death_tracking( enemy )
{
	enemy waittill( "death", attacker );
	wait 0.5;
	if ( isdefined( attacker ) )
	{
		if ( attacker.classname == "misc_turret" )
			attacker = attacker getTurretOwner();
		
		if ( isdefined( attacker ) && isdefined( attacker.bc_enabled ) )
		{			
			event = createEvent( "killfirm", "killfirm" );	
			attacker play_chatter( event );
		}
	}
}

enemy_damage_tracking( enemy )
{
	enemy endon( "death" );
	
	while( isAlive( enemy ) )
	{
		enemy waittill( "damage", amount, attacker );
		if ( isdefined( attacker ) )
		{
			if ( attacker.classname == "misc_turret" )
				attacker = attacker getTurretOwner();
			
			if ( isdefined( attacker ) && isdefined( attacker.bc_enabled ) )
			{	
				event = createEvent( "inform_enemy_hit", "inform_hit" );	
				attacker play_chatter( event );
			}
		}
	}
}

MAX_THREAT_CALLOUT_DIST = 2000;
MIN_THREAT_CALLOUT_REPEAT = 9 * 1000;

enemy_callout_tracking_plr()
{
	self endon( "death" );
	while( 1 )
	{
		target = undefined;
		targets = [];
		vehicles = getvehiclearray();
		
		foreach ( v in vehicles )
		{
			if ( v.script_team != "allies" )
			{
				targets = array_add( targets, v );
			}
		}
		
		targets = sortbydistance( targets, self.origin );
		
		foreach ( t in targets )
		{
			if ( isdefined( t.lastPlayerCalloutTime ) && ( GetTime() - t.lastPlayerCalloutTime < MIN_THREAT_CALLOUT_REPEAT ) )
				continue;
				
			if ( Distance2d( self.origin, t.origin ) > MAX_THREAT_CALLOUT_DIST )
				break;
			
			target = t;
			break;
		}
		
		if ( !isdefined( target ) )
		{
			targets = getAIArray( "axis" );
			targets = array_combine( getAIArray( "team3" ), targets );
			targets = SortByDistance( targets, self.origin );
			foreach ( t in targets )
			{
				if ( isdefined( t.lastPlayerCalloutTime ) && ( GetTime() - t.lastPlayerCalloutTime < MIN_THREAT_CALLOUT_REPEAT ) )
					continue;
					
				if ( Distance2d( self.origin, t.origin ) > MAX_THREAT_CALLOUT_DIST )
					break;
				
				target = t;
				break;
			}
		}
		
		if ( isdefined( target ) )
		{
			event = createEvent( "callout_clock", self getThreatAlias( target ) );
			if ( self play_chatter( event ) )
			{
				if ( isdefined( target ) )
					target.lastPlayerCalloutTime = GetTime();
			}
		}
		wait( 1 );
	}
}

take_fire_tracking()
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "damage", amount, attacker );
		self.request_move = true;
		if ( isdefined( attacker ) )
		{
			if ( !isPlayer( attacker ) )
			{
				event = createEvent( "inform_taking_fire", "inform_taking_fire" );	
				play_chatter( event );
			}
		}
	}
}

createEvent( eventType, alias )
{
	event = SpawnStruct();
	event.eventType = eventType;
	event.alias = alias;
	
	return event;
}

getThreatAlias( threat )
{
	if ( isPlayer( self ) )
		clockface = animscripts\battlechatter::getDirectionFacingClock( self getplayerangles(), self.origin, threat.origin );
	else
		clockface = animscripts\battlechatter::getDirectionFacingClock( self.angles, self.origin, threat.origin );
	str = "callout_targetclock_" + clockface;
	
	if ( cointoss() )
	{
		if ( isAI( threat ) )
		{
			str = str + "_troops";
		}
		if ( threat isVehicle() )
		{
			if ( threat isHelicopter() )
			{
				str = str + "_bird";
			}
			if ( threat isTank() )
			{
				str = str + "_tank";
			}
		}
	}
	
	return str;
}

isTank()
{
	if ( issubstr( self.classname, "t90" ) )
		return true;
	if ( issubstr( self.classname, "t72" ) )
		return true;
	
	return false;
}

play_chatter( event, check_alias )
{
	self endon( "death" );
		
	if( !self can_say_event_type( event.eventType ) )
	{
		return false;
	}

	soundalias = get_team_prefix() + self.voiceID + "_" + event.alias;
	// soundalias = check_overrides( eventType, soundalias );
	
	if( !IsDefined( soundalias ) )
	{
		return false;
	}
	
	if( !SoundExists( soundalias ) )
	{
		PrintLn( anim.tank_bc.bcPrintFailPrefix + "soundalias " + soundalias + " doesn't exist." );
		return false;
	}
	
	if ( !isdefined( check_alias ) )
		check_alias = false;
			
	if ( check_alias && !can_say_soundalias( soundalias ) )
		return false;
	
	if ( isPlayer( self ) )
		self.bc_isSpeaking = true;
	else
		anim.tank_bc.bc_isSpeaking = true;
	iprintln( "tank bcs: " + soundalias );
	self PlaySound( soundalias, "bc_done", true );
	self waittill( "bc_done" );
	if ( isPlayer( self ) )
		self.bc_isSpeaking = false;
	else
		anim.tank_bc.bc_isSpeaking = false;
	
	self update_event_type( event.eventType, event.alias );
	
	return true;
}

can_say_event_type( eventType )
{
	if ( !isdefined( level.tank_chatter_enabled ) || !level.tank_chatter_enabled )
	{
		return false;
	}
	
	if ( !self.bc_enabled )
	{
		return false;
	}
	
	if ( !isPlayer( self ) && anim.tank_bc.bc_isSpeaking )
	{
		return false;
	}
	else if ( isPlayer( self ) && self.bc_isSpeaking )
	{
		return false;
	}
	
	if( isPlayer( self ) && !IsDefined( anim.tank_bc.bc_eventTypeLastUsedTimePlr[ eventType ] ) )
	{
		return true;
	}
	else if( !isPlayer( self ) && !IsDefined( anim.tank_bc.bc_eventTypeLastUsedTime[ eventType ] ) )
	{
		return true;
	}
	
	if ( isPlayer( self ) )
		lastUsedTime = anim.tank_bc.bc_eventTypeLastUsedTimePlr[ eventType ];
	else
		lastUsedTime = anim.tank_bc.bc_eventTypeLastUsedTime[ eventType ];
	
	minWaitTime = anim.tank_bc.eventTypeMinWait[ eventType ] * 1000;
		
	if( ( GetTime() - lastUsedTime ) >= minWaitTime )
	{
		return true;
	}
	
	return false;
}

can_say_soundalias( alias )
{
	if ( isDefined( anim.tank_bc.lastAlias[ "alias" ] ) && anim.tank_bc.lastAlias[ "alias" ] == alias )
	{
		lastUsedTime = anim.tank_bc.lastAlias[ "time" ];
		minWaitTime = anim.tank_bc.eventTypeMinWait[ "same_alias" ] * 1000;
			
		if( ( GetTime() - lastUsedTime ) < minWaitTime )
		{
			return false;
		}
	}
	
	return true;
}

update_event_type( eventType, alias )
{
	if ( isPlayer( self ) )
		anim.tank_bc.bc_eventTypeLastUsedTimePlr[ eventType ] = GetTime();
	else
		anim.tank_bc.bc_eventTypeLastUsedTime[ eventType ] = GetTime();
	
	anim.tank_bc.lastAlias[ "time" ] = GetTime();
	anim.tank_bc.lastAlias[ "alias" ] = alias;
}

check_overrides( soundtype, defaultAlias )
{
	return defaultAlias;
}

get_team_prefix()
{
	return "tank_";
}