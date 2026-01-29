#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	toy_lv_slot_machine( false );
}

toy_lv_slot_machine( flicker )
{
	if ( flicker )
	{
		dest_type = "toy_lv_slot_machine_flicker";
		dest_fn = ::toy_lv_slot_machine_FlashLights;
		fxName = "fx/explosions/tv_flatscreen_explosion";
		screenSound	= "dst_slot_machine_sparks";
		billboardSound = "dst_slot_machine_sign_sparks";
	}
	else
	{
		dest_type = "toy_lv_slot_machine";
		dest_fn = ::toy_lv_slot_machine_SwitchLightsOff;
		fxName = "fx/explosions/tv_flatscreen_explosion_off";
		screenSound = "dst_slot_machine";
		billboardSound = "dst_slot_machine_sign";
	}
	
	destructible_create( dest_type, "tag_origin", 0 );	// First state change happens on load, just to load the destroyed version and start the lights flashing
			destructible_attachmodel( undefined, "lv_slot_machine_destroyed" ); 
			destructible_function( dest_fn );
		destructible_state();
	destructible_part( "tag_origin_intact", undefined, 100 );	// Main part will spew tokens if damaged, then swap models if blown up
			destructible_damage_threshold( 100 );
			destructible_fx( "tag_tokens", "fx/props/lv_slot_machine_chips_fall" );
		destructible_state( "tag_origin_intact", undefined, 400, undefined, undefined, "splash" );
			destructible_damage_threshold( 400 );	// The visual change from regular to destroyed is a pretty big one, so make sure it only happens in big explosions.
			destructible_notify( "stop flashing" );
		destructible_state( "tag_origin_d" );
	destructible_part( "tag_screen", undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_notify( "stop flashing" );
			destructible_sound( screenSound, undefined, 0 );	// There are two things that could happen here: either just the screen smashes, or the screen 
			destructible_sound( screenSound, undefined, 1 );	// smashes and tokens come out of the slot.  Both need the screen smashing FX and sound.
			destructible_sound( "dst_slot_machine_coins", undefined, 1 );
			destructible_fx( "tag_screen", fxName, true, undefined, 0 );
			destructible_fx( "tag_screen", fxName, true, undefined, 1 );
			destructible_fx( "tag_tokens", "fx/props/lv_slot_machine_chips_fall", true, undefined, 1 );
		destructible_state( "tag_screen_d" );
	destructible_part( "tag_billboard", undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_notify( "stop flashing" );
			destructible_sound( billboardSound, undefined, 0 );
			destructible_sound( billboardSound, undefined, 1 );
			destructible_sound( "dst_slot_machine_coins", undefined, 1 );
			destructible_fx( "tag_billboard", fxName, true, undefined, 0 );
			destructible_fx( "tag_billboard", fxName, true, undefined, 1 );
			destructible_fx( "tag_tokens", "fx/props/lv_slot_machine_chips_fall", true, undefined, 1 );
		destructible_state( "tag_billboard_d" );
	destructible_part( "tag_light", undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_notify( "stop flashing" );
			destructible_fx( "tag_light", fxName );
			destructible_sound( screenSound );
		destructible_state( "tag_light_d" );
		
	level._interactive[ "lv_slot_machine_flashing_tags" ] = [];
	level._interactive[ "lv_slot_machine_flashing_tags" ][0] = "tag_lit_billboard";
	level._interactive[ "lv_slot_machine_flashing_tags" ][1] = "tag_lit_buttons";
	level._interactive[ "lv_slot_machine_flashing_tags" ][2] = "tag_lit_light";
	if ( flicker )
	{
		thread toy_lv_slot_machine_LightsTimer();
	}
}

// A level-wide timer that turns the slot machine lights on and off
toy_lv_slot_machine_LightsTimer()
{
	AssertEx( !IsDefined( level._interactive[ "lv_slot_machine_LightsTimer_running"] ), "toy_lv_slot_machine script assumes that this function is only called once.  Please tell Boon he's wrong about how it works." );
	level._interactive[ "lv_slot_machine_LightsTimer_running"] = true;
	longPause = true;
	while(1)
	{
		if ( longPause )
			longPause = ( RandomInt( 100 ) < 50 );
		else
			longPause = ( RandomInt( 100 ) < 20 );			
		if ( longPause )
			wait( RandomFloatRange( 1, 4 ) );
		else
			wait( RandomFloatRange( 0.4, 1 ) );
		
		level notify( "toy_lv_slot_machine_LightsOn" );
		wait( RandomFloatRange( 0.05, 1 ) );
		level notify( "toy_lv_slot_machine_LightsOff" );
	}
}

// Waits for the level-wide timer to tell it to turn the lights on and off, then waits a short random period before obeying.
toy_lv_slot_machine_FlashLights()
{
	self endon ( "stop flashing" );
	self thread toy_lv_slot_machine_StopFlashing();
	
	reliability = 50 + RandomInt( 50 );
	
	// Look for linked lights
	self destructible_get_my_breakable_light( 128 );
	
	while(1)
	{
		notifyString = level common_scripts\utility::waittill_any_return( "toy_lv_slot_machine_LightsOn", "toy_lv_slot_machine_LightsOff" );
		if ( IsDefined( notifyString ) )
		{
			if ( notifyString == "toy_lv_slot_machine_LightsOn" )
			{
				toy_lv_slot_machine_SwitchLightsOn( reliability, self.breakable_light );
			}
			else
			{
				toy_lv_slot_machine_SwitchLightsOff( reliability, self.breakable_light );
			}
		}
	}
}

toy_lv_slot_machine_StopFlashing( light )
{
	self waittill ( "stop flashing" );
	foreach( tagname in level._interactive[ "lv_slot_machine_flashing_tags" ] )
		self HidePart( tagname );
	if ( IsDefined( light ) )
		light SetLightIntensity( 0 );
}

toy_lv_slot_machine_SwitchLightsOn( reliability, light )
{
	level endon( "toy_lv_slot_machine_LightsOff" );
	
	if ( RandomInt(100) > reliability )
		wait( RandomFloat( 0.3 ) );
	foreach( tagname in level._interactive[ "lv_slot_machine_flashing_tags" ] )
		self ShowPart( tagname );
	if ( IsDefined( light ) )
		light SetLightIntensity( 1 );
	if(common_scripts\utility::isSP())
	{
		self PlaySound( "dst_slot_machine_light_flkr_on", "lightsSound", true );
	}
	else
	{
		self PlaySound( "dst_slot_machine_light_flkr_on" );
	}
}

toy_lv_slot_machine_SwitchLightsOff( reliability, light )
{
	level endon( "toy_lv_slot_machine_LightsOn" );
	
	if ( IsDefined( reliability ) && RandomInt(100) > reliability )
		wait( RandomFloat( 0.1 ) );
	foreach( tagname in level._interactive[ "lv_slot_machine_flashing_tags" ] )
		self HidePart( tagname );
	if ( IsDefined( light ) )
		light SetLightIntensity( 0 );
	if(common_scripts\utility::isSP())
	{
		self PlaySound( "dst_slot_machine_light_flkr_off", "lightsSound", true );
	}
	else
	{
		self PlaySound( "dst_slot_machine_light_flkr_off" );
	}
}