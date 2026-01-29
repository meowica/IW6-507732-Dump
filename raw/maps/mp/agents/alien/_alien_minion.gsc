#include maps\mp\agents\alien\_alien_think;
#include common_scripts\utility;

ALIEN_MINION_EXPLODE_DISTANCE = 80;
ALIEN_MINION_EXPLODE_RADIUS = 200;
EXPLODE_ATTACK_START_SOUND = "alien_minion_attack";
ALIEN_MINION_CHARGE_SOUND = "alien_minion_alert";
ALIEN_MINION_CHATTER_SOUND = "alien_minion_idle";
CHATTER_MIN_INTERVAL = 8.0;
CHATTER_MAX_INTERVAL = 15.0;

minion_init()
{
	self thread minion_chatter_monitor();
	self thread minion_death_monitor();
}

minion_chatter_monitor()
{
	self endon( "death" );
	
	while( true )
	{
		chatterInterval = RandomFloatRange( CHATTER_MIN_INTERVAL, CHATTER_MAX_INTERVAL );
		wait chatterInterval;
		self playSound( ALIEN_MINION_CHATTER_SOUND );
	}	
}

minion_death_monitor()
{
	level endon( "game_ended" );
	
	self waittill( "death" );
	minion_explode_on_death();
}

minion_approach( enemy, attack_counter )
{
	/# debug_alien_ai_state( "default_approach" ); #/
	/# debug_alien_attacker_state( "attacking" ); #/
	
	self.attacking_player = true;
	self.bypass_max_attacker_counter = false;
		
	swipe_chance = 0.0; //self.swipeChance;
	should_swipe = ( RandomFloat( 1.0 ) < swipe_chance );
		
	if ( should_swipe )
	{
		return go_for_swipe( enemy );
	}
	
	self playSound( ALIEN_MINION_CHARGE_SOUND );
	approach_node = approach_enemy( ALIEN_MINION_EXPLODE_DISTANCE, enemy, 3 );
	return "explode";	
}

explode_attack( enemy )
{
	/# debug_alien_ai_state( "swipe_melee" ); #/
	self.melee_type = "explode";
	alien_melee( enemy );
}

explode( enemy )
{
	self playSound( EXPLODE_ATTACK_START_SOUND ); 
	
	self ScrAgentSetAnimMode( "anim deltas" );
	
	anim_rate = 1.25;
	
	self SetAnimState( "minion_explode", 0, anim_rate );
	wait GetAnimLength( self GetAnimEntry( "minion_explode", 0 ) ) * ( 1 / anim_rate );

	playFxOnTag( level._effect[ "alien_minion_preexplode" ], self, "tag_origin" );
	self Suicide();
}

load_minion_fx()
{
	level._effect[ "alien_minion_explode" ] 		= Loadfx( "fx/explosions/alien_minion_explosion" );
	level._effect[ "alien_minion_preexplode" ]	 	= loadfx( "vfx/gameplay/alien/vfx_alien_minion_preexplosion");
}

minion_explode_on_death()
{
	PlayFx( level._effect[ "alien_minion_explode" ], self.origin + (0,0,32) );
	RadiusDamage( self.origin, 200, level.alien_types[ "minion" ].attributes[ "explode_max_damage" ], level.alien_types[ "minion" ].attributes[ "explode_min_damage" ], self );
}