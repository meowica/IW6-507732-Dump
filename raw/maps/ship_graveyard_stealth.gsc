#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

/* 
 * SIMPLE STEALTH FOR UNDERWATER
 * because I don't want to deal with _stealth + underwater animations
 * 
 * Carlos
 * */

stealth_init()
{
	flag_init( "stealth_spawn" );
	flag_init( "_stealth_spotted" );
	flag_init( "_stealth_spotted_punishment" );
	flag_init( "_stealth_enabled" );
	
	level.stealth_ally_accu = 5;
	
	level.global_callbacks[ "_autosave_stealthcheck" ] 		= ::_autosave_stealthcheck;	
	level.underwater_visible_dist[ "hidden" ] = 600;
	level.underwater_visible_dist[ "spotted" ] = 2000;
	level.underwater_visible_dist[ "trigger" ] = undefined;
	flag_set( "stealth_spawn" );
	
	array_thread( getentarray( "sight_adjust_trigger", "targetname" ), ::sight_trigger_think );
	
	thread stealth_logic_loop();
	
	
}

stealth_disable()
{
	flag_clear( "stealth_spawn" );
	flag_set( "_stealth_spotted" );
	ai = getAIArray( "axis" );
	foreach( guy in ai )
	{
		if ( guy ent_flag_exist( "_stealth_spotted" ) )
			guy ent_flag_set( "_stealth_spotted" );
	}
	waitframe();
	level notify( "disable_stealth" );
	flag_set( "_stealth_spotted" );
	flag_clear( "_stealth_enabled" );
}

ai_stealth_init()
{
	if ( !isAI( self ) )
		return;
	
	if ( self.type == "dog" )
		return;
	
	self.baseaccuracy = 0.85;
	self set_battlechatter( false );
	if ( !flag( "stealth_spawn" ) )
	{
		self.moveplaybackrate = 1.25;
		self.moveTransitionRate = self.moveplaybackrate;
		//if ( self.team == "allies" )
		//	self set_battlechatter( true );
		return;
	}
	
	self ClearEnemy();
	switch( self.team )
	{
		case "axis":
			self thread enemy_stealth();
		break;
		case "allies":
			self thread friendly_stealth();
		break;
	}
}

stealth_logic_loop()
{
	level endon( "disable_stealth" );
	
	while( 1 )
	{
		flag_wait( "_stealth_spotted" );
		/#
		// iprintln( "spotted" );
		#/
		while( 1 )
		{
			if ( enemies_alerted() || flag( "_stealth_spotted_punishment" ) )
				wait( 0.2 );
			else
				break;
		}
		
		wait( 0.5 );
		
		flag_waitopen( "_stealth_spotted_punishment" );
		flag_clear( "_stealth_spotted" );
		/#
		// iprintln( "back to normal" );
		#/
	}
}

enemies_alerted()
{
	ais = getAIArray( "axis" );
	foreach ( ai in ais )
	{
		if ( ai ent_flag_exist( "_stealth_spotted" ) && ai ent_flag( "_stealth_spotted" ) )
			return true;
	}
	
	return false;
}

enemy_stealth()
{
	level endon( "disable_stealth" );
	self endon( "death" );
	
	if ( isdefined( self.script_stealthgroup ) )
		self.script_stealthgroup = 0;
	
	self childthread ai_alert_loop();
	
	ent_flag_init( "_stealth_spotted" );
	
	self.dontattackme = true;
	self.combatmode = "no_cover";
	self.dieQuietly = true;
	self.fovcosine = .5;// 60 degrees to either side...120 cone...2 / 3 of the default
	self.fovcosinebusy = .1;	
	self StopAnimScripted();
	
	if ( !flag( "_stealth_spotted" ) )
	{
		ent_flag_wait( "_stealth_spotted" );
		wait( RandomFloatRange( 1.5, 2.5 ) ); // play a reaction animation here
	}
	else
		ent_flag_set( "_stealth_spotted" );
	
	self notify( "stop_path" );
	self.dontattackme = undefined;
	self.combatmode = "cover";
	self.fovcosine = .01;// 90 degrees to either side...180 cone...default view cone
	self.dieQuietly = false;
	
	self.goalradius = 800;
	self.goalheight = 256;
	self.moveplaybackrate = 1.25;
	self.moveTransitionRate = self.moveplaybackrate;
	
	/*
	if ( Distance2d( self.origin, level.player.origin ) > self.goalradius )
	{
		self setGoalEntity( level.player );
		self waittill( "goal" );
	}
	*/
	node = self FindBestCoverNode();
	if ( isdefined( node ) )
	{
		self.goalradius = 32;
		self.goalheight = 96;
		self setGoalNode( node );
		self waittill( "goal" );
		self.goalradius = 800;
	}
}

ai_alert_loop()
{
	self endon( "_stealth_spotted" );
	
//	self addAIEventListener( "grenade danger" );
	self addAIEventListener( "gunshot" );
	self addAIEventListener( "gunshot_teammate" );
	self addAIEventListener( "silenced_shot" );
	self addAIEventListener( "bulletwhizby" );
	self addAIEventListener( "projectile_impact" );
	
	self ClearEnemy();
	msg = self waittill_any_return( "ai_event", "damage", "corpse", "enemy" );
	
	wait( 1 ); // time to recover
	
	self thread alert_team();
}

alert_team()
{
	self ent_flag_set( "_stealth_spotted" );
	flag_set( "_stealth_spotted" );
	ais = getaiarray( "axis" );
	foreach( ai in ais )
	{
		if ( isalive(ai) && ai.script_stealthgroup == self.script_stealthgroup && !(ai ent_flag("_stealth_spotted")) )
		{
			ai ent_flag_set( "_stealth_spotted" );
			if ( cointoss() )
				wait( RandomFloatRange( 0.1, 0.3 ) );
		}
	}
}

friendly_stealth()
{
	level endon( "disable_stealth" );
	self endon( "death" );
	
	while( 1 )
	{
		self set_battlechatter( false );
		self.ignoreme = true;
		self.alertlevel = "noncombat";
		self.moveplaybackrate = 1;
		self.moveTransitionRate = self.moveplaybackrate;
		flag_wait( "_stealth_spotted" );
		//self set_battlechatter( true );
		self.baseaccuracy = level.stealth_ally_accu;
		self.ignoreme = false;
		self.ignoreall = false; // just in case
		self.moveplaybackrate = 1.25;
		self.moveTransitionRate = self.moveplaybackrate;
		flag_waitopen( "_stealth_spotted" );
	}
}

player_stealth()
{
	level endon( "disable_stealth" );
	self endon( "death" );

	flag_set( "_stealth_enabled" );
	
	self childthread player_flashlight_toggle();
	
	while( 1 )
	{
		self.maxVisibleDist = level.underwater_visible_dist[ "hidden" ];
		flag_wait( "_stealth_spotted" );
		
		self.maxVisibleDist = level.underwater_visible_dist[ "spotted" ];
		flag_waitopen( "_stealth_spotted" );
	}
}

player_flashlight_toggle()
{
	while( !self ent_flag_exist( "flashlight_on" ) )
		wait( 0.05 );
	
	while( 1 )
	{
		self ent_flag_wait( "flashlight_on" );
		self.maxVisibleDist = level.underwater_visible_dist[ "spotted" ];
		
		self ent_flag_waitopen( "flashlight_on" );
		if ( flag( "_stealth_spotted" ) )
			self.maxVisibleDist = level.underwater_visible_dist[ "spotted" ];
		else if ( isdefined( level.underwater_visible_dist[ "trigger" ] ) )
			self.maxVisibleDist = level.underwater_visible_dist[ "trigger" ];
		else
			self.maxVisibleDist = level.underwater_visible_dist[ "hidden" ];
	}
}

sight_trigger_think()
{
	level endon( "disable_stealth" );
	self endon( "death ");
	
	while( !level.player ent_flag_exist( "flashlight_on" ) )
		wait( 0.05 );
	
	while( 1 )
	{
		self waittill( "trigger" );
		if ( flag( "_stealth_spotted" ) || level.player ent_flag( "flashlight_on" ) )
			continue;
		
		level.player.maxVisibleDist = self.script_faceenemydist;
		level.underwater_visible_dist[ "trigger" ] = self.script_faceenemydist;
		
		while( level.player isTouching( self ) && !flag( "_stealth_spotted" ) && !( level.player ent_flag( "flashlight_on" )) )
		{
			wait( 0.05 );
		}
		if ( flag( "_stealth_spotted" ) || level.player ent_flag( "flashlight_on" ) )
			level.player.maxVisibleDist = level.underwater_visible_dist[ "spotted" ];
		else
			level.player.maxVisibleDist = level.underwater_visible_dist[ "hidden" ];
		if ( isdefined( level.underwater_visible_dist[ "trigger" ] ) && level.underwater_visible_dist[ "trigger" ] == self.script_faceenemydist )
			level.underwater_visible_dist[ "trigger" ] = undefined;
	}
}

_autosave_stealthcheck()
{
	if( flag( "_stealth_spotted" ) && flag( "stealth_spawn" ) )
		return false;
	if ( flag( "shark_eating_player" ) )
		return false;
	
	vehicles = getentarray( "destructible", "classname" );
	foreach ( vehicle in vehicles )
	{
		if ( isDefined( vehicle.healthDrain ) )
			return false;
	}
	
	return true;
}

stealth_idle( node, anime )
{
	self endon( "death" );
	self endon( "damage" );
	self endon( "_stealth_spotted" );
	
	proplist[ "weld" ] = "torch";
	proplist[ "bangstick" ] = "bangstick";
	
	hasprop = isdefined( proplist[ anime ] );
	self.animname = "generic";
	
	node anim_reach_solo( self, anime );
	animating = [ self ];
	if ( hasprop )
	{
		prop = proplist[ anime ];
		self.prop = spawn_anim_model( prop, self.origin );
		if ( isdefined( level.scr_anim[ prop ] ) && isdefined( level.scr_anim[ prop ][ anime + "_idle" ] ) )
			animating = array_add( animating, self.prop );
		else
		{
			self.prop linkTo( self, "tag_inhand", (0,0,0), (0,0,0) );
		}
	}
	
	self thread stealth_idle_ender( node, anime, self.prop );
	self.allowdeath = true;
	self.allowpain = true;
	foreach ( a in animating )
	{
		node thread anim_loop_solo( a, anime + "_idle" );
	}
}

stealth_idle_ender( node, anime, prop )
{
	msg = self waittill_any_return( "_stealth_stop_idle", "_stealth_spotted", "death", "damage" );
	
	if ( isdefined( prop ) )
		thread prop_drop( prop );
	
	node notify( "stop_loop" );
	self StopAnimScripted();
	prop StopAnimScripted();
}

prop_drop(prop)
{
	prop unlink();

	can_trace = true;
	
	prop moveto(prop.origin - (0,0,1000), 60, 0, 60);
	
	if (prop.animname == "bangstick")
		prop thread bang_stick_rotate();
	else if (prop.animname == "torch")
	{
		prop thread torch_rotate();
		
		if (prop.welding)
			thread maps\ship_graveyard_anim::weld_fx_off(prop);
	}

		
	while (can_trace)
	{
		can_trace = BulletTracePassed (prop.origin, prop.origin - (0,0,10), true, self);
		wait 0.05;
	}
	
	prop notify ("stopped_dropping");
	prop moveto(prop.origin - (0,0,1), 1, 0, 1);
	
	wait 100;
	while (level.player can_see_origin(prop.origin))
		wait 1;
	
	prop delete();
}

bang_stick_rotate()
{
	self waittill ("stopped_dropping");
	
	rotatetime = 7;
	movetime = 7;
	if (self.animname == "bangstick")
	{
		self moveto ((342, -63295, -53), movetime, movetime/2,movetime/2);
		self RotateTo((354.461, 26.61, 160.045), rotatetime, rotatetime - 0.1, 0.1);
	}
}

torch_rotate()
{
	rotatetime = 10;
	self RotateBy((RandomIntRange(1,180), RandomIntRange(1,180), RandomIntRange(1,180)), rotatetime, 0, rotatetime);
	self waittill ("stopped_dropping");
	self RotateTo(self.angles, 0.1);
}