#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_stealth_utility;

set_flag_if_not_set( the_flag )
{
	if(!flag( the_flag ) )
		flag_set( the_flag );
	
}

delete_me_on_notifies( notify1, notify2, notify3)
{
	if( !isdefined( notify2 ) && !isdefined( notify3 ) )
	{
		 msg = self waittill_any_return( notify1 );
	}
	
	else if( !isdefined( notify3 ) )
	{
		 msg = self waittill_any_return( notify1, notify2 );
	}
	
	else
	{
		 msg = self waittill_any_return( notify1, notify2, notify3 );
	}
	
	//IPrintLn( "deleting sound ent: " + msg );
	
	if( IsDefined( level.custom_flavorburst_ents ) )
		level.custom_flavorburst_ents = array_remove( level.custom_flavorburst_ents, self );
	
	self delete();	
}

get_random_death_sound()
{
	num = randomintrange(1,8);
	return "generic_death_enemy_" +num;
}

cqb_off_sprint_on()
{
	if( isdefined( self.cqbwalking ) )
	{
		if( self.cqbwalking == true )
		{
			self disable_cqbwalk();
		}
	}
	
	self enable_sprint();	
}

cqb_on_sprint_off()
{
	if( isdefined( self.sprint ) )
	{
		if( self.sprint == true )
		{
			self disable_sprint();
		}
	}
	
	self enable_cqbwalk();	
}

activate_trig_if_not_flag( the_flag )
{
	if( !flag( the_flag ) )
		activate_trigger_with_targetname( the_flag );
}

dog_growl()
{
	//self = dog
	self thread play_sound_on_entity( "anml_dog_attack_miss" );
	
}

waittill_player_moves_or_timeout_controller( timeout )
{
	velocity_limit = 130;
	self thread return_after_time( timeout, "player_moved_ahead" );
	self thread return_on_velocity( velocity_limit );
	self waittill( "returned", msg );
	self notify( "kill" );
	return msg;
}

waittill_player_moves_or_timeout_kb( timeout )
{
	limit_sqd = 200*200;
	self thread return_after_time( timeout, "player_moved_ahead" );
	self thread return_on_movement( limit_sqd );
	self waittill( "returned", msg );
	self notify( "kill" );
	return msg;
}

is_moving()
{
	self endon( "death" );
	current_org = self.origin;
	wait( .20 );
	new_org = self.origin;
	if( current_org == new_org )
		return false;
	return true;	
}

return_on_movement( distsqd_limit )
{
	self endon( "kill" );
	level.player endon( "death" );
	
	start_org = level.player.origin;
	while( 1 )
	{	
		wait( .10 );
		new_org = level.player.origin;
		if( Distance2DSquared( start_org, new_org ) >= distsqd_limit )
		{
			self notify( "returned", "has_moved");
		}		
	}			
}

return_on_velocity( velocity_limit )
{ 
	self endon("kill");
	while(1)
	{
		velocity = level.player GetVelocity();
		if( velocity != (0,0,0) )
		{		
			difference =  distance2d( (0,0,0), velocity );
			if( difference >= velocity_limit || difference <= velocity_limit *-1  )
			{			
				//IPrintLnBold( "player velocity is " +difference+ ". Catching up" );
				self notify( "returned", "player_moved_ahead");
			}
		}
		wait(.5);
	}
}


return_after_time( timeout, _endon )
{
	self endon( "kill" );
	self endon( _endon );
	wait( timeout );
	self notify( "returned", "timed_out");
}

dog_sniff()
{

	self.old_moveplaybackrate = self.moveplaybackrate;
	self.moveplaybackrate = 1;
	self.script_noturnanim = 1;
	self disable_arrivals();
	self disable_exits();
	
	self set_generic_idle_anim( "dog_sniff_idle" );
	self set_generic_run_anim( "dog_sniff_walk" );
}



array_is_greater_than( array, num )
{
	if(!isdefined( array ) )
		return false;
	
	if( isdefined( array.size ) )
		if( array.size > num ) 
			return true;
	
	return false;
}

lerp_player_speed( new_val )
{
	current_val = level.current_speed_percent; 
	
	if( current_val == new_val )
		return;
	
	//need to increase the value ?
	if( new_val > current_val )
	{
		//while new_val is LESS, blend current_val UP to the new_val
		while( new_val >= current_val )
		{
			current_val +=.02;
			//IPrintLn( "increasing " +dvar+  " to " +current_val );
			level.player SetMoveSpeedScale( current_val );
			wait.05;
		}		
		//IPrintLn( "done blending " +dvar );
	}
	
	//need to decrease value ?
	else if( new_val < current_val )
	{
		//while new_val is MORE, blend current_val DOWN to the new_val
		while( new_val <= current_val )
		{
			current_val -=.02;
			//IPrintLn( "decreasing " +dvar+  " to " +current_val );
			level.player  SetMoveSpeedScale( current_val );
			wait.05;
		}		
		//IPrintLn( "done blending " +dvar );
	}
	
	level.player  SetMoveSpeedScale( new_val ); //hard set in case we end up slightly over/under it
	level.current_speed_percent = new_val;	
}

only_take_damage_from_player( _endon )
{
	self endon( "death" );
	player_attacks_until_death = 2;
	times_player_shot_me = 0;
	
	if( isdefined( _endon ) )
		level endon( _endon );
	
	self thread magic_bullet_shield();
	
	while(1)
	{
		self waittill("damage", amount, attacker );
		
		if( isdefined( attacker ) )
		{
			if( attacker == level.player ) 
			{
				times_player_shot_me ++;
				
				if( times_player_shot_me >= player_attacks_until_death )
				{
					self stop_magic_bullet_shield();
					self die();
				}
			}
		}
				
	}
				    
	
	
	
}
set_flag_on_targetname_trigger_by_player( trig_targetname )
{
	if( !flag_exist( trig_targetname ) )
		flag_init( trig_targetname );
	
	trig = getent( trig_targetname, "targetname" );
	
	assert( isdefined( trig ) );
	
	while(1)
	{
		trig waittill( "trigger", who );
		if( IsPlayer( who ) )		
		{
			flag_set( trig_targetname );
			return;
		}		
	}
	
}

hesh_says_on_you()
{	
	if ( cointoss() )
		//Hesh: On you.
		level.hesh smart_dialogue_generic( "deerhunt_hsh_onyou" );
	else
		//Hesh: On your go. 
		level.hesh smart_dialogue_generic( "deerhunt_hsh_onyourgo" );	
}


hesh_radio_aknowledge()
{
	//Hesh: Rog'. Team 2 out.
	//Hesh: Copy that Lifeguard. 
	//Hesh: Team 2 copies all.
	lines = [ "deerhunt_hsh_rogteam2out", "deerhunt_hsh_copythatlifeguard",	 "deerhunt_hsh_team2copiesall" ];
	lines = array_randomize( lines );
	
	level.hesh smart_radio_dialogue( random( lines ) );	
}

music_on_flag( the_flag, music_alias, optional_delay )
{
	flag_wait( the_flag );
	
	if( isdefined( optional_delay ) )	
		wait( optional_delay );
	
	music_play( music_alias );
}

//MikeD Steez
Print3d_on_me( msg ) 
 { 
 /# 
	self endon( "death" );  
	self endon("go_to_new_volume");	
	self notify( "stop_print3d_on_ent" );  
	self endon( "stop_print3d_on_ent" );  
	while( 1 ) 
	{ 
		print3d( self.origin + ( 0, 0, 40 ), msg );  
		wait( 0.05 );  
	} 
 #/ 
 }
 
grenades_by_difficulty()
{
	my_grenade_amount = 0;
	skill = getdifficulty();
	switch( skill )
	{
		case "gimp":
		case "easy":
			my_grenade_amount = 0;
		case "medium":
			my_grenade_amount = 1;
		case "hard":
		case "difficult":
		case "fu":
			my_grenade_amount = 2;
	}	
	
	if( randomint( 100 ) < 33 )
		self.grenadeammo = my_grenade_amount;
	else
		self.grenadeammo = 0;
}

fade_out_in( fade_color, fadeup_notify, time  )
{
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( fade_color, 640, 480 );//"black", "white"
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 1;
	overlay.sort = -2;

	if(isdefined( fadeup_notify ) )
	{
		level waittill( fadeup_notify );
	}
	else
	{	
		wait( time );
	}	

	overlay fadeOverTime( .5 );
	overlay.alpha = 0;	
	wait(1);

	overlay destroy();
}

disable_DontAttackMe()
{
	if( isdefined( self.dontattackme ) )
		self.dontattackme = undefined;	
}

ignore_me_ignore_all()
{
	self.ignoreme = 1;
	self.ignoreall = 1;	
}

ignore_me_ignore_all_OFF()
{
	self.ignoreme = 0;
	self.ignoreall = 0;
	
}

stealth_ai_idle( guy, idle_anim, tag, no_gravity )
{	
	if ( IsDefined( no_gravity ) )
		AssertEx( no_gravity, "no_gravity must be true or undefined" );
	
	guy stealth_insure_enabled();

	spotted_flag = guy maps\_stealth_shared_utilities::group_get_flagname( "_stealth_spotted" );

	if ( flag( spotted_flag ) )
		return;

	ender = "stop_loop";

	guy.allowdeath = true;
	
	if( !isdefined( no_gravity ) )
		self thread maps\_anim::anim_generic_custom_animmode_loop( guy, "gravity", idle_anim, tag );
	else
		self thread maps\_anim::anim_generic_loop( guy, idle_anim, tag );
		
	//guy maps\_stealth_shared_utilities::ai_set_custom_animation_reaction( self, reaction_anim, tag, ender );

	self add_wait( ::waittill_msg, "stop_idle_proc" );
	self add_func( ::stealth_ai_clear_custom_idle_and_react );
	
	self thread do_wait_thread();
}


#using_animtree("generic_human");
shop_door_open( soundalias )
{
	wait( 1.35 );
//
//	if ( IsDefined( soundalias ) )
//		self PlaySound( soundalias );
//	else
//		self PlaySound( "door_wood_slow_open" );

	self RotateTo( self.angles + ( 0, 70, 0 ), 1.5, .7, 0 );
	self ConnectPaths();
	self waittill( "rotatedone" );
	self RotateTo( self.angles + ( 0, 40, 0 ), 2, 0, 2 );
}

is_array_close( array, max_dist_sqd )
{
	foreach( item in array )
	{
		if( Distance2DSquared( self.origin, item.origin ) < max_dist_sqd)
			return true;
	}
	return false;	
}

arm_player( array )
{
	level.player TakeAllWeapons();
	
	foreach( gun in array )
	{
		level.player GiveWeapon( gun );
		level.player GiveMaxAmmo( gun );
	}
	
	level.player SwitchToWeapon( array[0] );	
}

switch_from_cqb_to_creepwalk()
{
	
	//non cqb AI still supported
	if( isdefined( self.cqbwalking ) )
	{
		if( self.cqbwalking == true )
		{
			self disable_cqbwalk();
			self set_archetype( "creepwalk_archetype" );
			
			//self.moveLoopOverrideFunc = ::play_move_transition;
			//self.deerhuntTransitionAnim = %cqb_walk_2_creepwalk;
		}
	}
	else
	
		self set_archetype( "creepwalk_archetype" );
}

switch_from_creepwalk_to_cqb()
{
	self enable_cqbwalk();
	self clear_archetype();
	
	//self.moveLoopOverrideFunc = ::play_move_transition;
	//self.deerhuntTransitionAnim = %creepwalk_2_cqb_walk;
}

play_move_transition()
{
	self ClearAnim( %root, 0.2 );
	self SetFlaggedAnimKnobAllRestart( "deerhunt_transition", self.deerhuntTransitionAnim, %root );
	self animscripts\shared::DoNotetracks( "deerhunt_transition" );
	self ClearAnim( %root, 0.2 );
	
	self.deerhuntTransitionAnim = undefined;
	self.moveLoopOverrideFunc = undefined;
}

switch_from_cqb_to_gundown()
{
	if( isdefined( self.cqbwalking ) )
	{
		if( self.cqbwalking == true )
		{
			self disable_cqbwalk();
		}
	}
	self set_archetype( "gundown_archetype" );

}

switch_from_gundown_to_cqb()
{
	self enable_cqbwalk();
	self clear_archetype();

}
