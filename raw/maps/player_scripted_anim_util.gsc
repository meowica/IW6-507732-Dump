#include maps\_utility;
#include common_scripts\utility;
	
/*
=============
///ScriptDocBegin
"Name: waittill_trigger_activate_looking_at( <trigger> , <look_at_obj> , <dot> , <do_trace> , <delete_trigger> )"
"Summary: Use this to wait before starting a player scripted animation. Used with a 'trigger_use_touch'. It requires the player to be looking at a point before they can trigger it."
"Module: Utility"
"CallOn: Level"
"MandatoryArg: <trigger>: a 'trigger_use_touch' where the player stands."
"MandatoryArg: <look_at_obj>: a struct or entity where the origin is at the spot you want the player to look."
"OptionalArg: <dot>: cosine of angle used to determine if trigger is active (default 0.8)."
"OptionalArg: <do_trace>: do a trace if there is a possibility of something blocking the look_at_obj (default false)."
"OptionalArg: <delete_trigger>: delete the trigger after the player triggers it (default false)."
"OptionalArg: <ent_player_linked_to>: if the player is linked pass the entity here to correctly calculate view angles."
"Example: waittill_trigger_activate_looking_at( trigger, look_pos, Cos( 40 ), false, true, ent_linked_to );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
waittill_trigger_activate_looking_at( trigger, look_at_obj, dot, do_trace, delete_trigger, ent_player_linked_to )
{
	Assert( IsDefined( trigger ) );
	Assert( IsDefined( look_at_obj ) && IsDefined( look_at_obj.origin ) );
	
	trigger endon( "valid_trigger" );
	
	dot_only = true;
	
	if ( !IsDefined( dot ) )
		dot = 0.8;
		
	if ( IsDefined( do_trace ) && do_trace )
		dot_only = undefined;
	
	delete_after_use = IsDefined( delete_trigger ) && delete_trigger;
	trigger thread _trigger_handle_triggering( delete_after_use );
	
	while ( true )
	{
		if ( level.player player_looking_at_relative( look_at_obj.origin, dot, dot_only, level.player, ent_player_linked_to ) )
			trigger trigger_on();
		else
			trigger trigger_off();
		
		wait 0.1;
	}
}

_trigger_handle_triggering( delete_after_use )
{
	self endon( "death" );
	
	while ( true )
	{
		self waittill( "trigger" );
		if ( !level.player IsMeleeing() )
			break;
	}
	
	self notify( "valid_trigger" );
	
	if ( delete_after_use )
		self Delete();
	else
		self trigger_off();
}

/*
=============
///ScriptDocBegin
"Name: player_looking_at_relative( <org>, <dot> )"
"Summary: Checks to see if the player can dot and trace to a point.  If the player is linked, specify level.ent_player_linked_to to calculate relative angles."
"Module: Utility"
"MandatoryArg: <org>: The position you're checking if the player is looking at"
"OptionalArg: <dot>: Optional override dot"
"OptionalArg: <dot_only>: If true, it will only check FOV and not tracepassed"
"Example: if ( player_looking_at( org.origin ) )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
player_looking_at_relative( start, dot, dot_only, ignore_ent, ent_player_linked_to )
{
	if ( !isdefined( dot ) )
		dot = 0.8;
	player = get_player_from_self();

	end = player GetEye();

	angles = VectorToAngles( start - end );
	forward = AnglesToForward( angles );
	player_angles = player GetPlayerAngles();
	if ( IsDefined( ent_player_linked_to ) )
		player_angles = CombineAngles( ent_player_linked_to.angles, player_angles );
	player_forward = AnglesToForward( player_angles );

	new_dot = VectorDot( forward, player_forward );
	if ( new_dot < dot )
	{
		return false;
	}

	if ( IsDefined( dot_only ) )
	{
		AssertEx( dot_only, "dot_only must be true or undefined" );
		return true;
	}

	trace = BulletTrace( start, end, false, ignore_ent );
	return trace[ "fraction" ] == 1;
}
