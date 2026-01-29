#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;



trigger_moveTo( parent_trigger )
{
	if ( !isdefined( level.mover_candidates ) )
	{
		level.mover_candidates = getentarray( "script_brushmodel", "classname" );
		level.mover_candidates = array_combine( level.mover_candidates, getentarray( "script_model", "classname" ) );
		level.mover_object = spawn_Tag_origin();
	}
	
	volumes = getentarray( self.target, "targetname" );
	array_thread( volumes, ::moveTo_volume_think, self );
}

moveTo_volume_think( parent_trigger )
{	
	movers = [];
	
	touch_test = self;
	foreach( m in level.mover_candidates )
	{
		level.mover_object.origin = m.origin;
		if ( level.mover_object isTouching( touch_test ) )
		{
			level.mover_candidates = array_remove( level.mover_candidates, m );
			movers = array_add( movers, m );
		}
	}
	
	mover = undefined;
	
	foreach( m in movers )
	{
		if (
			( isdefined(m.script_noteworthy)  && m.script_noteworthy == "mover" )
			|| ( isdefined( m.targetname ) && m.targetname == "mover" )
				)
		{
			mover = m;
			break;
		}
	}

	assertex( isdefined( mover ), "need a thing with 'mover' as 'script_noteworthy' on trigger at " + self.origin );

	foreach( m in movers )
	{
		if ( mover != m )
		{
			m linkTo( mover );
		}
	}
	
	mover_target = self get_target_ent();
	
	if ( !isdefined( mover_target.angles ) )
		mover_target.angles = ( 0, 0, 0 );
	
	mover.origin = mover_target.origin;
	mover.angles = mover_target.angles;

	quake = undefined;
	duration = 5;
	accel = 0;
	decel = 0;
	
	if ( isdefined( mover_target.script_duration ) )
		duration = mover_target.script_duration;
	if ( isdefined( mover_target.script_accel ) )
		accel = mover_target.script_accel;
	if ( isdefined( mover_target.script_decel ) )
		decel = mover_target.script_decel;		
	if ( isdefined( mover_target.script_earthquake ) )
		quake = mover_target.script_earthquake;
	
	parent_trigger waittill( "trigger" );
	
	mover_target script_delay();
	
	if ( isdefined( mover_target.target ) )
		mover_target = mover_target get_target_ent();
	else
		mover_target = undefined;
	
	while( isdefined( mover_target ) )
	{
		if ( isdefined( quake ) )
		{
			if ( issubstr( quake, "constant" ) )
			{
				mover thread constant_quake( quake );
			}
		}
		if ( !isdefined( mover_target.angles ) )
			mover_target.angles = ( 0, 0, 0 );
	
		mover moveTo_rotateTo( mover_target, duration, accel, decel );
		mover notify( "stop_constant_quake" );
		
		duration = 5;
		accel = 0;
		decel = 0;
		quake = undefined;
		
		mover_target script_delay();
		
		if ( isdefined( mover_target.script_duration ) )
			duration = mover_target.script_duration;
		if ( isdefined( mover_target.script_accel ) )
			accel = mover_target.script_accel;
		if ( isdefined( mover_target.script_decel ) )
			decel = mover_target.script_decel;		
		if ( isdefined( mover_target.script_earthquake ) )
			quake = mover_target.script_earthquake;
		
		linked = mover_target get_linked_ents();
		if ( linked.size > 0 )
		{
			if ( issubstr( linked[0].classname, "trigger" ) )
			    linked[0] waittill( "trigger" );
		}

		if ( isdefined( mover_target.target ) )
			mover_target = mover_target get_target_ent();
		else
			mover_target = undefined;
	}
	
}

constant_quake( quake )
{
	self endon( "stop_constant_quake" );
	while( 1 )
	{
		thread do_earthquake( quake, self.origin );
		wait( RandomFloatRange( 0.1, 0.2 ) );
	}
}

moveTo_rotateTo_speed( node, rate, accel, decel )
{
	point = node.origin;
	
	start_pos = self.origin;
	dist = Distance( start_pos, point );
	time = dist / rate;
	
	if ( !isdefined( accel ) )
		accel = 0;
	if ( !isdefined( decel ) )
		decel = 0;
	
//	iprintlnbold( time );
	
	self rotateTo( node.angles, time, time*accel, time*decel );
	self moveTo( point, time, time*accel, time*decel );
	self waittill( "movedone" );
}

moveTo_rotateTo( node, time, accel, decel )
{
	self moveTo( node.origin, time, accel, decel );
	self rotateTo( node.angles, time, accel, decel );
	self waittill( "movedone" );
}

set_start_positions( targetname )
{
	start_positions = getstructarray( targetname, "targetname" );
	foreach ( pos in start_positions )
	{
		switch ( pos.script_noteworthy )
		{
			case "player":
				level.player SetOrigin( pos.origin );
				level.player SetPlayerAngles( pos.angles );
				break;
		}
	}
}
