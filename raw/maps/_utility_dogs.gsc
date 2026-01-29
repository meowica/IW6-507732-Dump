#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

#using_animtree( "dog" );

init_dog_anims()
{
	if ( isdefined( level.dog_anims_initialized ) )
		return;
	
	level.dog_anims_initialized = true;
	
	level.scr_anim[ "generic" ][ "dog_sniff_idle" ][ 0 ] = %iw6_dog_sniff_idle;
	level.scr_anim[ "generic" ][ "dog_sniff_walk" ] = %iw6_dog_sniff_walk;
	
	level.scr_anim[ "generic" ][ "dog_sneak_idle" ][ 0 ] = %iw6_dog_sneak_stand_idle;
	level.scr_anim[ "generic" ][ "dog_sneak_walk" ] = %iw6_dog_sneak_walk_forward;
}

dog_follow_path_func( parameter, node )
{
	init_dog_anims();
	
	if ( self.type != "dog" )
		return;
	
	switch( parameter )
	{
		case "enable_sniff":
			self dyn_sniff_disable();
			self enable_dog_sniff();
			break;
		case "disable_sniff":
			self dyn_sniff_disable();
			self disable_dog_sniff();
			break;
		case "enable_dyn_sniff":
			self dyn_sniff_enable();
			break;
		case "disable_dyn_sniff":
			self dyn_sniff_disable();
			break;
	}
}

enable_dog_sniff()
{
	init_dog_anims();
	
	self.old_moveplaybackrate = self.moveplaybackrate;
	self.moveplaybackrate = 1;
	self.script_noturnanim = 1;
	self.script_nostairs = 1;
	self disable_arrivals();
	self disable_exits();
	self.run_overrideSound = "anml_dog_sniff_walk";
	self.customIdleSound = "anml_dog_sniff_idle";
	self set_generic_idle_anim( "dog_sniff_idle" );
	self set_generic_run_anim( "dog_sniff_walk" );
}

disable_dog_sniff()
{
	if ( isdefined(self.old_moveplaybackrate) )
		self.moveplaybackrate = self.old_moveplaybackrate;
	
	self.script_noturnanim = undefined;
	self.script_nostairs = undefined;
	self enable_arrivals();
	self enable_exits();
	self.run_overrideSound = undefined;
	self.customIdleSound = undefined;
	self clear_generic_idle_anim();
	self clear_generic_run_anim();
}

enable_dog_sneak()
{
	init_dog_anims();

	self.run_overrideSound = undefined;
	self.customIdleSound = undefined;
	
	self.old_moveplaybackrate = self.moveplaybackrate;
	self.moveplaybackrate = 1;
	self.script_noturnanim = 1;
	self.script_nostairs = 1;
	self disable_arrivals();
	self disable_exits();
	
	self set_generic_idle_anim( "dog_sneak_idle" );
	self set_generic_run_anim( "dog_sneak_walk" );
}

disable_dog_sneak()
{
	if ( isdefined(self.old_moveplaybackrate) )
		self.moveplaybackrate = self.old_moveplaybackrate;

	self.run_overrideSound = undefined;
	self.customIdleSound = undefined;
	
	self.script_noturnanim = undefined;
	self.script_nostairs = undefined;
	self enable_arrivals();
	self enable_exits();
	
	self clear_generic_idle_anim();
	self clear_generic_run_anim();
}

#using_animtree( "dog" );

dog_lower_camera()
{
	self setAnim( %iw6_dog_camera_down_add, 1, 0.75, 1 );
}

dog_raise_camera()
{
	self setAnim( %iw6_dog_camera_down_add, 0, 0.75, 1 );
}

dyn_sniff_enable( maxdist, mindist )
{
	self endon( "death" );
	self endon( "dynsniff_off" );
	
	if ( isdefined( self.dyn_sniff ) )
		return;
	
	self.dyn_sniff = true;
	
	if ( !isdefined( maxdist ) )
		maxdist = 400;
	
	if ( !isdefined( mindist ) )
		mindist = 200;
	
	self.old_moveplaybackrate = self.moveplaybackrate;
	
	while( 1 )
	{
		player_behind_me = self player_is_behind_me();
		playerdist = Distance( self.origin, level.player.origin );
		if ( player_behind_me && playerdist > maxdist )
		{
			self maps\_utility_dogs::enable_dog_sniff();
			/#
			iprintln( "sniffing" );
			#/
			wait( 4 );
			
			while  ( (self player_is_behind_me()) && Distance( self.origin, level.player.origin ) > mindist )
				wait( 0.1 );
			
			self maps\_utility_dogs::disable_dog_sniff();
			/#
			iprintln( "resuming speed" );
			#/
			wait( 6 );
		}
		wait( 0.3 );
	}

}

dyn_sniff_disable()
{
	self notify( "dynsniff_off" );
	self maps\_utility_dogs::disable_dog_sniff();
	self.dyn_sniff = undefined;
}

player_is_behind_me()
{
	a = ( self.angles[0], self.angles[1], 0 );
	my_forward = AnglesToForward( a );
	org = self.origin - (0,0,self.origin[2]);
	org2 = level.player.origin - (0,0,level.player.origin[2]);
	forward = VectorNormalize( org2 - org );
	dot = VectorDot( forward, my_forward );
	
	return ( dot < -0.1 );
}