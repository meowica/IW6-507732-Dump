#include common_scripts\utility;
#include maps\mp\alien\_persistence;
#include maps\mp\_utility;

//============================================
//				Traps
//============================================

// ======== cost =======
// <NOTE JC> These costs are likely to be replaced by some table lookup through some kind of init process that Colin is setting up
CONST_FENCE_COST				= 1000; // currency cost to enable fence
CONST_FENCE_COST_SMALL			= 750;
CONST_FENCE_COST_MED			= 1000;
CONST_FENCE_COST_LARGE			= 1500;

CONST_TURRET_COST				= 200; // currency cost to use a turret
CONST_TANK_COST					= 750; //cost to operate Remote Tank
CONST_VANGUARD_COST				= 1000; //cost to operate Vanguard

traps_init()
{
	electric_fence_init();
	
}

// ========= electric fence constants ========
CONST_GENERATOR_POWER 			= 10; 	// number of shock attacks for max capacity
CONST_FENCE_SHOCK_DAMAGE 		= 200; 	// damage per shock

CONST_SHOCK_INTERVAL			= 0.25; // time delay between shocks
CONST_ACTIVATION_DURATION		= 5.0;	// Duration of a single button press activation

CONST_FENCE_CURRENCY			= 1000;

electric_fence_init()
{
	level.electric_fences = [];
	
	generators = getentarray( "fence_generator", "targetname" );
	
	if ( !isdefined( generators ) || generators.size == 0 )
		return;

	foreach ( generator in generators )
	{
		generator.damagefeedback = false;
		fence = setup_electric_fence( generator );
		
		level.electric_fences[ level.electric_fences.size ] = fence;
		
		fence thread run_electric_fence();
	}
}

setup_electric_fence( generator )
{
	fence = SpawnStruct();

	fence.cost = CONST_FENCE_COST;
	fence.hintString = &"ALIEN_COLLECTIBLES_ACTIVATE_FENCE_MED";
	
	// cost override from radiant setup
	if ( isdefined( generator.script_noteworthy ) )
	{
		if ( generator.script_noteworthy == "small" )
		{
			fence.cost = CONST_FENCE_COST_SMALL;
			fence.hintString = &"ALIEN_COLLECTIBLES_ACTIVATE_FENCE_SMALL";
		}
		if ( generator.script_noteworthy == "medium" )
		{
			fence.cost = CONST_FENCE_COST_MED;
			fence.hintString = &"ALIEN_COLLECTIBLES_ACTIVATE_FENCE_MED";
		}
		if ( generator.script_noteworthy == "large" )
		{
			fence.cost = CONST_FENCE_COST_LARGE;
			fence.hintString = &"ALIEN_COLLECTIBLES_ACTIVATE_FENCE_LARGE";
		}
	}
	
	// setup generator for use
	fence.generator = generator;
	fence.generator SetCursorHint( "HINT_NOICON" );
	fence.generator SetHintString( fence.hintString );
	fence.generator MakeUsable();
	//fence.generator make_entity_sentient_mp( "allies" );
	
	// setup fence corners
	top_left 					= getstruct( generator.target, 		"targetname" );
	bottom_left 				= getstruct( top_left.target, 		"targetname" );
	bottom_right 				= getstruct( bottom_left.target, 	"targetname" );
	top_right					= getstruct( bottom_right.target, 	"targetname" );
	
	fence.fence_top_left_angles	= top_left.angles;
	fence.fence_top_left 		= top_left.origin;
	fence.fence_top_right 		= top_right.origin;
	fence.fence_bottom_left 	= bottom_left.origin;
	fence.fence_bottom_right 	= bottom_right.origin;
	fence.fence_height 			= fence.fence_top_left[ 2 ] - fence.fence_bottom_left[ 2 ];
	fence.fence_center			= get_center( top_left.origin, top_right.origin, bottom_left.origin, bottom_right.origin );
	
	// setup damage trigger
	fence.shock_trig			= getent( top_right.target, "targetname" );
	fence.optimal_height		= 150; // should be tweaked based on geo
	
	// scaled based on height, shorter the fence the stronger the shock, sinse aliens touch it less
	fence.shock_damage			= CONST_FENCE_SHOCK_DAMAGE * ( fence.optimal_height / fence.fence_height );
	fence.shock_interval		= CONST_SHOCK_INTERVAL * ( fence.fence_height / fence.optimal_height );
	
	// setup fence fx
	fence.shock_fx[ "ambient" ]		= LoadFX( "vfx/moments/alien/fence_lightning_ambient" );
	fence.shock_fx[ "shock" ]		= LoadFX( "vfx/moments/alien/fence_lightning_shock" );
	fence.shock_fx[ "turn_on" ]		= LoadFX( "vfx/moments/alien/fence_lightning_turn_on" );
	
	fence.shock_fx[ "sparks" ]		= loadfx( "fx/explosions/transformer_sparks_b_sound" );
	fence.shock_fx[ "sparks_sm" ]	= loadfx( "fx/explosions/transformer_sparks_f_sound" );
	//fence.shock_fx[ "bar" ]		= LoadFX( "vfx/gameplay/alien/vfx_alien_fence_bolt_horizontal" );
	
	fence.shock_bar_fx_ent		= spawn( "script_origin", fence.fence_center );
	fence.shock_bar_fx_ent 		setmodel( "tag_origin" );

	// setup fence initial values
	fence.running 				= false;
	fence.capacity				= CONST_GENERATOR_POWER;
	fence.max_capacity			= CONST_GENERATOR_POWER;
	
	return fence;
}

get_center( vec0, vec1, vec2, vec3 )
{
	x = ( vec0[ 0 ] + vec1[ 0 ] + vec2[ 0 ] + vec3[ 0 ] ) / 4;
	y = ( vec0[ 1 ] + vec1[ 1 ] + vec2[ 1 ] + vec3[ 1 ] ) / 4;
	z = ( vec0[ 2 ] + vec1[ 2 ] + vec2[ 2 ] + vec3[ 2 ] ) / 4;
	
	return ( x, y, z );
}

ambent_shocks()
{
	// self is fence struct
	self 	endon( "death" );
	self 	endon( "disable_fence" );
	level 	endon( "game_ended" );	
	
	ambient_on = false;
	
	while ( 1 )
	{
		while ( !self.running )
		{
			ambient_on = false;
			StopFXOnTag( self.shock_fx[ "ambient" ], self.shock_bar_fx_ent, "tag_origin" );
			self waittill( "fence_turned_on" );
		}
		
		if ( !ambient_on )
		{
			PlayFXOnTag( self.shock_fx[ "ambient" ], self.shock_bar_fx_ent, "tag_origin" );
			ambient_on = true;
		}
		
		fence_hp_ratio 	= self.capacity / self.max_capacity;
		height 			= self.fence_height * fence_hp_ratio;
		end_pos_left	= self.fence_bottom_left + ( 0, 0, height );
		end_pos_right	= self.fence_bottom_right + ( 0, 0, height );
		end_pos_center 	= ( self.fence_center[ 0 ], self.fence_center[ 1 ], end_pos_right[ 2 ] );
		
		playfx( self.shock_fx[ "sparks_sm" ], end_pos_left );
		wait 0.3;
		playfx( self.shock_fx[ "sparks_sm" ], end_pos_center );
		wait 0.3;
		playfx( self.shock_fx[ "sparks_sm" ], end_pos_right );

		debug_fence_print( self.generator.origin, "Power: " + fence_hp_ratio, ( 0.5, 0.5, 1 ), 0.75, 3, 3 );

		waittill_any_timeout( RandomIntRange( 2, 3 ), "fence_turned_on" );
	}
}

run_electric_fence()
{
	// self is fence struct
	self 	endon( "death" );
	self 	endon( "disable_fence" );
	level 	endon( "game_ended" );

	// shows health of fence
	self thread ambent_shocks();
	
	while ( isdefined( self ) )
	{
		// [off] - wait for activate
		while ( !self.running )
		{
			self.generator waittill( "trigger", owner );

			if ( owner can_activate_generator( self ) )
			{
				self.owner = owner;
				
				self.generator SetHintString( "" );
				self.generator MakeUnUsable();
				self.capacity 	= self.max_capacity;
				
				// cost the activator
				owner take_player_currency( self.cost );
				owner setLowerMessage( "fence help", &"ALIEN_COLLECTIBLES_FENCE_HELP", 4 );
				
				self thread fence_damage_enemies();
				owner thread fence_activated( self );
				
				// break into [on]
				break;
			}
			else
			{
				wait 0.05;
				owner iprintlnBold( "Electric Fence costs $" + self.cost );
				continue;
			}
		}
		
		self waittill( "fence_exhausted" );
		
		// padding
		wait 0.5;
		
		self thread play_fence_off_fx();
		self.owner = undefined;
		self.running = false;
		self.generator SetHintString( self.hintString );
		self.generator MakeUsable();

		
		// ^ loop ^
	}
}

fence_damage_enemies()
{
	self endon( "fence_exhausted" );
	while ( 1 )
	{
		self waittill( "fence_turned_on" );		
		self fence_damage_enemies_activated();
	}	
}

fence_damage_enemies_activated()
{
	self endon( "fence_turned_off" );

	// [on] - wait for victim
	while ( 1 )
	{
		self.shock_trig waittill( "trigger", victim );
		
		if ( isAgent( victim ) && isalive( victim ) )
		{
			// only run one shock thread per victim
			if ( isdefined( victim.shocked ) && victim.shocked )
			{
				wait 0.05;
				continue;
			}
			
			// fence_shock() takes time
			self thread fence_shock( victim );
		}
	}
}
		
fence_activated( fence )
{
	self endon( "death" );
	self thread cleanup_fence_on_death( fence );
	// sfx loop for fence ambient hum
	fence.shock_trig playLoopSound( "alien_fence_hum_lp" );
	
	// sfx loop for generator running
	fence.generator playLoopSound( "alien_fence_gen_lp" );	
		
	while ( fence.capacity > 0 )
	{
		if ( self SecondaryOffhandButtonPressed() )
		{
			fence run_generator();
			fence.capacity--;
		}	
		
		wait 0.05;
	}
		
	fence.generator playSound( "alien_fence_gen_off" );
	fence notify( "fence_turned_off" );
	fence notify( "fence_exhausted" );
	fence fence_clean_up();
}

cleanup_fence_on_death( fence )
{
	fence endon( "fence_exhausted" );
	self waittill( "death" );
	fence fence_clean_up();
	fence notify( "fence_exhausted" );
}

fence_clean_up()
{
	// self is fence struct
	self 	endon( "death" );
	level 	endon( "game_ended" );
	
	while ( true )
	{
		self waittill( "disable_fence" );
		self.generator stopLoopSound( "alien_fence_gen_lp" );
		self.shock_trig stopLoopSound( "alien_fence_hum_lp" );
	}
}

run_generator()
{
	self notify( "fence_turned_on" );
	
	self.running 	= true;
	self thread play_fence_on_fx();
	
	wait CONST_ACTIVATION_DURATION;
	
	self.running = false;
	
	self thread play_fence_off_fx();
	self notify( "fence_turned_off" );
}

play_fence_off_fx()
{
	playfx( self.shock_fx[ "shock" ], 	self.fence_top_left );
	playfx( self.shock_fx[ "sparks" ], 	self.fence_top_left );
	
	playfx( self.shock_fx[ "shock" ], 	self.fence_top_right );
	playfx( self.shock_fx[ "sparks" ], 	self.fence_top_right );
	
	count = 3;
	while ( count > 0 )
	{
		playfx( self.shock_fx[ "shock" ], 	self.generator.origin );
		playfx( self.shock_fx[ "sparks" ], 	self.generator.origin );
		
		count--;
		wait 0.2;
	}
}

play_fence_on_fx()
{
	playfx( self.shock_fx[ "shock" ], 	self.fence_top_left );
	playfx( self.shock_fx[ "sparks" ], 	self.fence_top_left );

	playfx( self.shock_fx[ "shock" ], 	self.fence_top_right );
	playfx( self.shock_fx[ "sparks" ], 	self.fence_top_right );
}

fence_shock( victim )
{
	victim endon( "death" );
	
	// self is fence struct
	victim.shocked = true;
	
	if ( !isalive( victim ) )
		return;

	debug_fence_print( victim.origin, "hp:" + victim.health, ( 0.5, 0.5, 1 ), 0.75, 2, 1 );
	
	assert( isdefined( self.owner ) );
	
	victim.pain_registered = true; // no pain logic when shocked, for now
	wait 0.05;
	victim DoDamage( self.shock_damage, victim.origin, self.owner, self.generator, "MOD_EXPLOSIVE" );
	
	// fx on victim
	playfx( self.shock_fx[ "shock" ], 	victim.origin + ( 0, 0, 32 ) );
	playfx( self.shock_fx[ "sparks" ], 	victim.origin + ( 0, 0, 32 ) );
	
	// sfx for fence shock
	playSoundAtPos( victim.origin, "alien_fence_shock" );
	
	if ( !isalive( victim ) )
	{
		pos = victim wait_for_ragdoll_pos();
		if ( isdefined( pos ) )
		{
			wait 0.1;
			PhysicsExplosionSphere( pos, 300, 150, 5 );
			playfx( self.shock_fx[ "shock" ], 	pos );
			playfx( self.shock_fx[ "sparks" ], 	pos );
		}
	}
	
	wait RandomFloatRange( self.shock_interval/2, self.shock_interval*1.5 );
	
	// TODO: need to slow down alien during traversal when shocked
	/*
	// slow down victim while shocked
	shock_time 			= 1.5; //sec
	original_move_rate 	= victim.moveplaybackrate;
	original_anim_rate 	= victim.animplaybackrate;

	while ( shock_time > 0 && isalive( victim ) )
	{
		victim.moveplaybackrate = 0.25;
		victim.animplaybackrate = 0.25;
		
		shock_time -= 0.05;
		wait 0.05;
	}
	
	// restore victims playrates
	if ( isalive( victim ) )
	{
		victim.moveplaybackrate = original_move_rate;
		victim.animplaybackrate = original_anim_rate;
	}
	*/

	// wait for shock again
	victim.shocked = false;
}

wait_for_ragdoll_pos()
{
	self endon( "ragdoll_timed_out" );
	
	self thread ragdoll_timeout( 1 );
	self waittill( "in_ragdoll", pos );
	
	return pos;
}

ragdoll_timeout( time )
{
	wait time;
	
	if ( isdefined( self ) )
		self notify( "ragdoll_timed_out" );
}

can_activate_generator( generator )
{
	// self is player	
	return self player_has_enough_currency( generator.cost );
}


debug_fence_print( pos, string, color, alpha, scale, time )
{
	/#
	if ( GetDvarInt( "debug_fence" ) == 1 )
	{
		thread debug_fence_print_raw( pos, string, color, alpha, scale, time );
	}
	#/
}

debug_fence_print_raw( pos, string, color, alpha, scale, time )
{
	level endon ( "game_ended" );
	while ( time > 0 )
	{
		Print3d( pos, string, color, alpha, scale, 1 );
		
		time -= 0.05;
		wait( 0.05 );
	}
}
//============================================
//				Turrets
//============================================
CONST_TURRET_BULLET_LIMIT       = 300; // turret will be disabled after this many bullets fired

turret_monitorUse()
{
	level endon( "game_ended" );
		
	self SetCursorHint( "HINT_NOICON" );
	self MakeUsable();

	disable_turret();
	
	while ( true )
	{
		self waittill ( "trigger", player );
		
		if ( !isPlayer ( player ) )
			continue;
		
		if ( !is_turret_enabled() )  // player tries to buy the turret
		{
			if ( player can_activate_turret() )
			{
				player take_player_currency( CONST_TURRET_COST );
				enable_turret();
			}
			else
			{
				player iprintlnBold( "Turret costs $" + CONST_TURRET_COST );
			}
		}
		else   // player uses the turret
		{
			self.owner = player;
			wait_for_disable_turret();
			disable_turret();
		}
	}
}

wait_for_disable_turret()
{
	thread watch_bullet_fired();

	self waittill ( "disable_turret" );
}

watch_bullet_fired()
{
	self endon ( "disable_turret" );
	
	bullet_fired = 0;
	
	while ( true )
	{
		self waittill ( "turret_fire" );
		
		bullet_fired++;
		
		if ( bullet_fired > CONST_TURRET_BULLET_LIMIT )
			break;
	}
	
	self.owner iprintlnBold ( "Turret out off ammo" );
	self notify ( "disable_turret" );
}

is_turret_enabled()
{
	return self.enabled;
}

disable_turret()
{
	self.enabled = false;
	self SetHintString( &"ALIEN_COLLECTIBLES_ACTIVATE_TURRET" );
	self TurretFireDisable();
	self makeTurretInoperable();
}

enable_turret()
{
	self.enabled = true;
	self SetHintString( "" );
	self TurretFireEnable();
	self makeTurretOperable();
}

can_activate_turret()
{
	// self is player
	return self player_has_enough_currency( CONST_TURRET_COST );
}

//*****************************************************************
//					Remote Tank
//*****************************************************************

tank_monitorUse()
{
	self SetCursorHint( "HINT_NOICON" );
	self MakeUsable();
	self SetHintString( &"ALIEN_COLLECTIBLES_ACTIVATE_TANK" );
	lifeid = -1;	
	while ( true )
	{
		self waittill ( "trigger", player );
		
		if ( !isPlayer ( player ) )
			continue;
	
		if ( player can_activate_tank() )
		{
			player take_player_currency( CONST_TANK_COST );
			player  maps\mp\killstreaks\_remotetank::givetank( lifeId, "remote_tank" );
		}
		else
		{
			player iprintlnBold( "Tank costs $" + CONST_TANK_COST );
		}
	}
}

can_activate_tank()
{
	// self is player
	return self player_has_enough_currency( CONST_TANK_COST );
}

//*****************************************************************
//					Vanguard
//*****************************************************************

vanguard_monitorUse()
{
	self SetCursorHint( "HINT_NOICON" );
	self MakeUsable();
	self SetHintString( &"ALIEN_COLLECTIBLES_ACTIVATE_VANGUARD" );
	lifeid = -1;	
	while ( true )
	{
		self waittill ( "trigger", player );
		
		if ( !isPlayer ( player ) )
			continue;
	
		if ( player can_activate_vanguard() )
		{
			player take_player_currency( CONST_VANGUARD_COST );
			player  maps\mp\killstreaks\_vanguard::giveCarryRemoteUAV( lifeId, "remote_uav" );
		}
		else
		{
			player iprintlnBold( "Vanguard costs $" + CONST_VANGUARD_COST );
		}
	}
}

can_activate_vanguard()
{
	// self is player
	return self player_has_enough_currency( CONST_VANGUARD_COST );
}

