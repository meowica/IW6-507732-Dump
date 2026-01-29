#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

DEBUG_ON = false;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// VIGNETTE

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_setup( anim_name, accessory )
{	
	// Does the actor already have a vignette structure?
	if( !IsDefined( self.v ))
		self.v = SpawnStruct();
	
    // Keeps track of if vignette is active
    self.v.active = false;
    
    //
    // Default customizable parameters to affect behavior of AI (set these after vignette_setup() / vignette_spawn() is run!!)
	//		    
	self.v.instant_death		  = vignette_IsDefined( self.v.instant_death, true );			// One bullet will kill enemy, otherwise break out and into normal AI
	self.v.nogun				  = vignette_IsDefined( self.v.nogun, false );					// Remove gun for anim (returned at end)
	self.v.invincible			  = vignette_IsDefined( self.v.invincible, false );				// Make guy invincible (for more custom interruptions)
	self.v.death_anim_anytime	  = vignette_IsDefined( self.v.death_anim_anytime, false );		// Will play custom death anim immediately when killed, otherwise generic death anim
	self.v.death_on_self		  = vignette_IsDefined( self.v.death_on_self, false );			// Play custom death anim on self (instead of node)
	self.v.death_on_end			  = vignette_IsDefined( self.v.death_on_end, false );			// Kill guy at end of vignette if still alive
	self.v.silent_script_death	  = vignette_IsDefined( self.v.silent_script_death, false );	// Make sure no death anims are played (custom or generic)
	self.v.delete_on_end		  = vignette_IsDefined( self.v.delete_on_end, false );			// Delete guy at end
	self.v.ignoreall_on_end		  = vignette_IsDefined( self.v.ignoreall_on_end, false );		// Keeps ignore everything active at end of vignette
	self.v.interrupt_level		  = vignette_IsDefined( self.v.interrupt_level, false );		// Sends an interrupt to the level if enemy is interrupted
	self.v.interrupt_all_notifies = vignette_IsDefined( self.v.interrupt_all_notifies, false ); // All notifies will interrupt enemy (not just damage)
		    
	// Apply animname	
	if ( IsDefined( anim_name ) )
		self.animname = anim_name;
	
	// Add prop 
    if( IsDefined( accessory ))
    	self.v.prop = accessory; 
	
	self.v.current_state = "none";
}

vignette_IsDefined( var, default_val )
{
	if( IsDefined( var ))
		return var;
	else
		return default_val;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_single( guys, start_anim, idle_anim, idle_break_anim, death_anim )
{	
	foreach( guy in guys )
		self thread vignette_single_solo( guy, start_anim, idle_anim, idle_break_anim, death_anim );										
	
	// Wait until all guys complete their vignettes
	while( self._vignette_active > 0 )
		wait( 0.05 );
}

vignette_single_solo( guy, start_anim, idle_anim, idle_break_anim, death_anim )
{	
	Assert( self != level );

	// Setup vignette stuff if not done already	
	if( !IsDefined( guy.v ) || !IsDefined( guy.v.active ) )
		guy vignette_setup();	
	
	// Keep track of how many vignettes are active on an entity
	if( !IsDefined( self._vignette_active ) )
		self._vignette_active = 1;
	else
		self._vignette_active++;
	
	guy endon( "death" );	
	guy endon( "msg_vignette_interrupt" );
	guy endon( "msg_stop_vignette_scripts" );

	//
	// Setup
	//
	
	if( IsAI( guy ) )
	{
		// Make sure this guy is invincible (if he isn't already) and ignoring everything	
		guy vignette_ignore_everything();
	
		if( !IsDefined( guy.magic_bullet_shield ) || !guy.magic_bullet_shield )
	    	guy thread magic_bullet_shield(); 
	}
	
	// Set node
	guy.v.anim_node = self;
	
	// Add prop to array
	if( IsDefined( guy.v.prop ))
		guys = [ guy, guy.v.prop ];
	else
		guys = [ guy ];

	// Start Anim
	if( IsDefined( start_anim ))
		guy.v.start_anim = start_anim;
	
	// Idle Anim
	if( IsDefined( idle_anim ))
		guy.v.idle_anim = idle_anim;
	
	// Idle Break Anim
	if( IsDefined( idle_break_anim ))
		guy.v.idle_break_anim = idle_break_anim;			
	
	// Death anim
	if( IsDefined( death_anim ))
	{
		guy.v.death_anim = death_anim;
		guy.a.nodeath = true;
	}
		
	// If guy is interrupted during anim
	guy thread vignette_interrupt_watcher( guys );
	
	// 
	// Start anims
	//
	
	guy.v.active = true;		
	
	if( IsDefined( start_anim ))
	{
		// Play single play anim
		guy vignette_state( "start" );		
		guy.v.anim_node anim_single( guys, start_anim );
		guy notify( "msg_vignette_start_anim_done" );
	}	
		
	if( IsDefined( idle_anim ))
	{
		// Play idle anim
		guy vignette_state( "idle" );
		guy.v.anim_node thread anim_loop( guys, idle_anim );
		
	}
	else
	{
		// No idle anim, guy exits vignette
		guy thread vignette_end();	
	}
}

// Call this to interrupt the vignette
vignette_interrupt( interrupt_msg, attacker )
{
	thread vignette_interrupt_solo( interrupt_msg, attacker );
}

// Call this to kill the enemy
vignette_kill( attacker )
{
	thread vignette_end( true, attacker );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_interrupt_solo( interrupt_msg, attacker )
{
	self notify( "msg_vignette_interrupt" );
	
	// If this entity is not the level
	if( self != level )
	{		
		// Debug stuff
		/#
			msg = "";
			if( IsDefined( interrupt_msg ))
				msg = interrupt_msg;		
			self.v.debug_interrupt = "interrupt" + msg;
		#/
		
		// Stop any loops
		self.v.anim_node notify( "stop_loop" );
		
		// Idle break anim
		if( IsDefined( self.v.idle_break_anim ))
		{
			// Add prop to array
			if( IsDefined( self.v.prop ))
				guys = [ self, self.v.prop ];
			else
				guys = [ self ];			
			
			// Break animation
			self vignette_state( "idle_break" );
			self.v.idle_break_anim_active = true;		
			self.v.anim_node anim_single( guys, self.v.idle_break_anim );
			self.v.idle_break_anim_played = true;
			self notify( "msg_vignette_interrupt_break_done" );
		}
		
		// Run end script
		if( IsDefined( attacker ))
			self vignette_kill( attacker );
		else
			self thread vignette_end();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_end( bool_kill, attacker )
{			
	self notify( "msg_stop_vignette_scripts" );
	
	// Notify all other entities in the vignette to interrupt
	if( self.v.interrupt_level )
		level notify( "msg_vignette_interrupt" );
	
	if( self.v.active )
	{						
		// Stop any loops
		self.v.anim_node notify( "stop_loop" );		
	
		// Death anims		
		if( self.v.silent_script_death )
		{
			// Skip deathanim and custom death anims
			self.a.nodeath = true;
		}
		else
		{
			if( ( ( IsDefined( bool_kill ) && bool_kill ) || self.v.death_on_end ) && IsDefined( self.v.death_anim ) )
			{						
				if( self.v.current_state == "idle" || self.v.death_anim_anytime )
				{																
					self notify( "msg_vignette_death_anim_start" );	
					
					self vignette_state( "death_anim" );
					// Add prop to array
					if( IsDefined( self.v.prop ))
						guys = [ self, self.v.prop ];
					else
						guys = [ self ];					
					
					// Play death anim either on the guy or on the node
					if( self.v.death_on_self )
						self anim_single( guys, self.v.death_anim );
					else
						self.v.anim_node anim_single( guys, self.v.death_anim );
										
					self.v.death_anim_played = true;
					self.a.nodeath = true;					
				}	
				else
				{
					// Death anim isn't being played.  Make sure default death enabled.
					self.a.nodeath = false;
				}
			}
			
			// If for some reason guy is still playing an anim, kill it
			if( !IsDefined( self.v.idle_break_anim_played ) && !IsDefined( self.v.death_anim_played ) && self._animactive )
			{
				self StopAnimScripted();
				self.a.nodeath = false;
			}
		}
		
		if( IsDefined( self.v.prop ) && !IsDefined( self.v.death_anim_played ) && !IsDefined( self.v.idle_break_anim_played ))
		{			
			// If no death anim or idle break anim played, launch the prop
			self.v.prop StopAnimScripted();
			self.v.prop PhysicsLaunchClient( self.v.prop.origin, (0,0,0) );		
		}
		
		self vignette_state( "none" );
		
		// Remove magic bullet shield
		if( !IsDefined( self.hero ) && IsDefined( self.magic_bullet_shield ) )
			self stop_magic_bullet_shield();
							
		// Give back their gun
		if( !IsDefined( bool_kill ) && !self.v.death_on_end && !self.v.delete_on_end && IsDefined( self.v.nogun ) && self.v.nogun )
			self gun_recall();
		
		// Unignore everything
		if( !IsDefined( bool_kill ) && IsAI( self ) && !self.v.ignoreall_on_end )
			self vignette_unignore_everything();
		
		self.v.active = false;	
	}
	
	// Notify the end of the vignette, decrement vignette counter
	self notify( "msg_vignette_end", attacker );		
	self.v.anim_node._vignette_active--;
	
	if( ( IsDefined( bool_kill ) && bool_kill ) || self.v.death_on_end )
	{	
		self.allowdeath = true;
		self kill();
	}	
	
	// Delete guy
	if( self.v.delete_on_end )
		self delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_interrupt_watcher( guys )
{		
	self endon( "death" );
	self endon( "msg_stop_vignette_scripts" );
	
	// If invincible, skip normal interrupt logic
	if( !self.v.invincible )
	{
		// Interrupt by damage
		self thread vignette_interrupt_watcher_damage();

		if( self.v.interrupt_all_notifies )
		{
			// Interrupt by other notifies
			self thread vignette_interrupt_watcher_other( "bulletwhizby", level.player );
			self thread vignette_interrupt_watcher_other( "flashbang" );
			self thread vignette_interrupt_watcher_other( "grenade danger" );			
			self thread vignette_interrupt_watcher_other( "playerclose" );										
		}
		
		// Interrupt by level-wide interrupt
		level waittill( "msg_vignette_interrupt" );
		self vignette_interrupt( "level" );
	}
}

vignette_interrupt_watcher_damage()
{
	self endon( "death" );
	self endon( "msg_vignette_end" );	
	self endon( "msg_vignette_death_anim_start" );
	
	while( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );		
		
		// He's invincible 
		if( self.v.invincible )
			continue;
			
		// Die immediately if damage is high enough		
		if( ( self.v.instant_death && ( type != "MOD_IMPACT" )) || ( damage >= self.health ))
		{
			self vignette_kill( attacker );			
			return;
		}
		
		// Instant death guy, skip death stuff
		if( self.v.instant_death )
			continue;
			
		// Stop magic bullet shield 
		if( !IsDefined( self.hero ) && IsDefined( self.magic_bullet_shield ))
			self stop_magic_bullet_shield();
		
		self DoDamage( damage, direction_vec, attacker );							
		self vignette_interrupt( "damage" );
	}
}

vignette_interrupt_watcher_other( msg, value1 )
{
	self endon( "death" );
	self endon( "msg_stop_vignette_scripts" );
	self endon( "msg_vignette_interrupt" );
	
	while( 1 )
	{
		self waittill( msg, var1 );
		
		if( IsDefined( value1 ) && ( var1 != value1 ))			
			continue;
		
		// Give a couple of frames to let damage logic go through
		wait( 0.1 );
				
		self vignette_interrupt( msg );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_stop_anims()
{
	// Stop loops
	self.v.anim_node notify( "stop_loop" );

	// If no death anim and anim is playing, kill anim
	if( 
	   !self.v.invincible && 
	   self.v.current_state != "death_anim"  &&	   
	   self._animActive 
	)
	{
		self StopAnimScripted();
		
		if( IsDefined( self.v.prop ))
		{
			// Props
			self.v.prop StopAnimScripted();
			self.v.prop PhysicsLaunchClient( self.v.prop.origin, (0,0,0) );		
		}
	}
}

vignette_state( state )
{
	Assert( self != level );
	self.v.current_state = state;
	
	if( DEBUG_ON )
	{
		guy_name = "";
		if( IsDefined( self.animname ))
			guy_name = " (" + self.animname + ")";
		iprintln( "VIGNETTE" + guy_name + ": " + state );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_ignore_everything()
{		
	// Looks like vignette_unignore_everything wasn't called, clear first
	if( IsDefined( self._ignore_settings_old ))
		self vignette_unignore_everything();
	
	self._ignore_settings_old = [];
	
	self.disableplayeradsloscheck = vignette_set_ignore_setting( self.disableplayeradsloscheck, "disableplayeradsloscheck", true );
	self.ignoreall				  = true;
	self.ignoreme				  = true;
	self.grenadeAwareness		  = vignette_set_ignore_setting( self.grenadeAwareness, "grenadeawareness", 0 );
	self.ignoreexplosionevents	  = vignette_set_ignore_setting( self.ignoreexplosionevents, "ignoreexplosionevents", true );
	self.ignorerandombulletdamage = vignette_set_ignore_setting( self.ignorerandombulletdamage, "ignorerandombulletdamage", true );
	self.ignoresuppression		  = vignette_set_ignore_setting( self.ignoresuppression, "ignoresuppression", true );
	self.dontavoidplayer		  = vignette_set_ignore_setting( self.dontavoidplayer, "dontavoidplayer", true );
	self.newEnemyReactionDistSq	  = vignette_set_ignore_setting( self.newEnemyReactionDistSq, "newEnemyReactionDistSq", 0 );
	
	self.disableBulletWhizbyReaction = vignette_set_ignore_setting( self.disableBulletWhizbyReaction, "disableBulletWhizbyReaction", true );
	self.disableFriendlyFireReaction = vignette_set_ignore_setting( self.disableFriendlyFireReaction, "disableFriendlyFireReaction", true );
	self.dontMelee					 = vignette_set_ignore_setting( self.dontMelee, "dontMelee", true );
	self.flashBangImmunity			 = vignette_set_ignore_setting( self.flashBangImmunity, "flashBangImmunity", true );
	
	self.doDangerReact			 = vignette_set_ignore_setting( self.doDangerReact, "doDangerReact", false );	
	self.neverSprintForVariation = vignette_set_ignore_setting( self.neverSprintForVariation, "neverSprintForVariation", true );
	
	self.a.disablePain = vignette_set_ignore_setting( self.a.disablePain, "a.disablePain", true );
	self.allowPain	   = vignette_set_ignore_setting( self.allowPain, "allowPain", false );
	
	self PushPlayer( true );
}

vignette_set_ignore_setting( old_value, string, new_value )
{
	Assert( self != level );	
	Assert( IsDefined( string ));	
	
	if( IsDefined( old_value ))
		self._ignore_settings_old[ string ] = old_value;	
	else
		self._ignore_settings_old[ string ] = "none";
	
	return new_value;
}

vignette_unignore_everything( dont_restore_old )
{
	// Don't restore old settings
	if( IsDefined( dont_restore_old ) && dont_restore_old )
		if( IsDefined( self._ignore_settings_old ))
			self._ignore_settings_old = undefined;
			
	self.disableplayeradsloscheck = vignette_restore_ignore_setting( "disableplayeradsloscheck", false );
	self.ignoreall				  = false;
	self.ignoreme				  = false;
	self.grenadeAwareness		  = vignette_restore_ignore_setting( "grenadeawareness", 1 );
	self.ignoreexplosionevents	  = vignette_restore_ignore_setting( "ignoreexplosionevents", false );
	self.ignorerandombulletdamage = vignette_restore_ignore_setting( "ignorerandombulletdamage", false );
	self.ignoresuppression		  = vignette_restore_ignore_setting( "ignoresuppression", false );
	self.dontavoidplayer		  = vignette_restore_ignore_setting( "dontavoidplayer", false );
	self.newEnemyReactionDistSq	  = vignette_restore_ignore_setting( "newEnemyReactionDistSq", 262144 );
	
	self.disableBulletWhizbyReaction = vignette_restore_ignore_setting( "disableBulletWhizbyReaction", undefined );
	self.disableFriendlyFireReaction = vignette_restore_ignore_setting( "disableFriendlyFireReaction", undefined );
	self.dontMelee					 = vignette_restore_ignore_setting( "dontMelee", undefined );
	self.flashBangImmunity			 = vignette_restore_ignore_setting( "flashBangImmunity", undefined );
	
	self.doDangerReact			 = vignette_restore_ignore_setting( "doDangerReact", true );
	self.neverSprintForVariation = vignette_restore_ignore_setting( "neverSprintForVariation", undefined );
	
	self.a.disablePain = vignette_restore_ignore_setting( "a.disablePain", false );
	self.allowPain	   = vignette_restore_ignore_setting( "allowPain", true );
	
	self PushPlayer( false );		
		
	self._ignore_settings_old = undefined;
}

vignette_restore_ignore_setting( string, default_val )
{
	Assert( self != level );	
	Assert( IsDefined( string ));		
	                                                
	if( IsDefined( self._ignore_settings_old )) 
	{
		// Check to see if original value exists
		if( IsString( self._ignore_settings_old[ string ] ) && ( self._ignore_settings_old[ string ] == "none" ))
			return default_val;
		else
			return self._ignore_settings_old[ string ];
	}
	
	return default_val;
}