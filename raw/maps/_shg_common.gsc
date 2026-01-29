#include common_scripts\utility;
#include animscripts\utility;
#include maps\_utility_code;
#include maps\_utility;
#include maps\_anim;
#include maps\_hud_util;
#include maps\_audio;

/*
=============
///ScriptDocBegin
"Name: move_player_to_start( struct_targetname )"
"Summary: attempts to move the player to the struct with the targetname"
"MandatoryArg: <struct_targetname>: "
"the targetname of the struct you want the player to be moved to (and match angles if they are set)"
"Example: return move_player_to_start( player_berlin_chopper_crash )"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
move_player_to_start( struct_targetname )
{
	assert( isdefined( struct_targetname ) );
	start = getstruct( struct_targetname, "targetname" );
	level.player SetOrigin( start.origin );
	
	lookat = undefined;
	if ( isdefined( start.target ) )
	{
		lookat = getent( start.target, "targetname" );
		assert( isdefined( lookat ) );
	}
	
	if ( isdefined( lookat ) )
		level.player setPlayerAngles( vectorToAngles( lookat.origin - start.origin ) );
	else
		level.player setPlayerAngles( start.angles );
}

/*
=============
///ScriptDocBegin
"Name: tank_fire_at_enemies(noteworthy_enemy_name)"
"Summary: have a vehicle target and kill objects with a script_noteworthy of noteworthy_enemy_name"
"MandatoryArg: <noteworthy_enemy_name>: "
"the script_noteworthy of the list of objects you want killed by the vehicle"
"Example: tank tank_fire_at_enemies(bridge_enemies)"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

tank_fire_at_enemies(noteworthy_enemy_name)
{
	self endon("death");
	self endon("stop_random_tank_fire");
	target = undefined;
	while(1)
	{		
		if(isdefined(target)&& target.health > 0)
		{
			self setturrettargetent( target , (randomintrange(-64, 64),randomintrange(-64, 64),randomintrange(-16, 100)));
			
			if(SightTracePassed(self.origin + (0,0,100), target.origin + (0,0,40), false, self ))
			{	
				self.tank_think_fire_count++;
				self fireweapon();
				if(self.tank_think_fire_count >= 3)
				{
					//dont try annd kill things that shouldn't die
					if((!isdefined(target.damageShield) || target.damageShield == false) 
						&& (!isdefined(target.magic_bullet_shield) || target.magic_bullet_shield == false))
						{
							target notify("death");
						}
				}
				wait(randomintrange(4,10));//short timer so we can just see the tanks firing
			}
			else
			{
				target = undefined;
				wait(1);
			}	
		}
		else
		{	
			if(!isAlive(self))
				break;
			target = self get_tank_target_by_script_noteworthy(noteworthy_enemy_name);
			self.tank_think_fire_count = 0;
			wait(1);
		}
		wait(RandomFloatRange(0.05, .5));
	}
}

get_tank_target_by_script_noteworthy(script_noteworthy_name)
{
	guys = getentarray(script_noteworthy_name, "script_noteworthy");
	if(isdefined(guys))
	{
		possibletarget = random(guys);
		if(isdefined(possibletarget) && !isSpawner(possibletarget) && possibletarget.health > 0)
		{
			target = possibletarget;
			self notify("new_target");
			
			//self thread draw_tank_target_line(self, target, (1,1,1));
			//target thread show_tank_target(self);
			
			return target;
		}
		else
		{
			return undefined;
		}
	}
	return undefined;
}

/*
=============
///ScriptDocBegin
"Name: spawn_friendlies(thing)"
"Summary: spawn friendlies at a target and possibly call replace_on_death on them"
"MandatoryArg: <struct_targetname>: target name of the struct loction to teleport them to"
"MandatoryArg: <friendly_noteworthy>: script_noteworthy name of the array of spawners to use"
"OptionalArg: <bShouldReplaceOnDeath>: if the ai should have replace_on_death called on them"
"OptionalArg: <limit>: maximum number of spawns we should do"
"Example: spawn_friendlies( player_start_berlin, little_bird_friendlies, false )"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
spawn_friendlies( struct_targetname, friendly_noteworthy, bShouldReplaceOnDeath, limit )
{
	if(!isdefined(bShouldReplaceOnDeath))
		bShouldReplaceOnDeath = true;
	entarr = getentarray(friendly_noteworthy, "script_noteworthy");
	spawner_arr = [];
	ent_count = 0;
	guy_arr = [];
	
	
	foreach(ent in entarr)
	{
		if( isSpawner(ent) )
		{
			spawner_arr[spawner_arr.size] = ent;
		}
	}
	
	loc = getstruct( struct_targetname, "targetname");
	
	count = 0;
	foreach(spawner in spawner_arr)
	{
		new_guy = spawner spawn_ai( true );
		if(bShouldReplaceOnDeath)
			new_guy thread replace_on_death();
		new_guy forceTeleport( loc.origin, loc.angles );
		new_guy setgoalpos( new_guy.origin );
		guy_arr = array_add(guy_arr, new_guy);
		count++;
		if(isdefined(limit) && count >= limit)
			return guy_arr;
	}
	return guy_arr;
}

/*
=============
///ScriptDocBegin
"Name: SetUpPlayerForAnimations()"
"Summary: prepare the player for getting animations played on them (opposite call to SetUpPlayerForGamePlay)"
call when you're setting up to plan an animation on the player
"Example: SetUpPlayerForAnimations()"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

SetUpPlayerForAnimations()
{
	if( level.player IsThrowingGrenade() )
	{
		wait( 1.2 );	
	}
	
	level.player allowMelee(false);
	level.player DisableOffhandWeapons();
	level.player allowCrouch(false);
	level.player allowProne(false);
	level.player allowSprint(false);
		
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
		wait( 0.4 );
	}
}

/*
=============
///ScriptDocBegin
"Name: SetUpPlayerForGamePlay()"
"Summary: prepare the player for gameplay after animations have been called (opposite call to SetUpPlayerForAnimations)"
call after you're done playing animations on the player
"Example: SetUpPlayerForGamePlay()"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

SetUpPlayerForGamePlay()
{
	level.player allowSprint(true);	
	level.player allowProne(true);
	level.player allowCrouch(true);
	level.player EnableOffhandWeapons();
	level.player allowMelee(true);
}

/*
=============
///ScriptDocBegin
"Name: ForcePlayerWeapon_Start()"
"Summary: force the player to take a given weapon and set it to current"
call after youve set level.force_weapon
"Example: ForcePlayerWeapon_Start()"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

ForcePlayerWeapon_Start(bEnableWeapons)
{
	assert( isdefined(level.force_weapon) );
	assert( !isdefined(level.old_force_weapon) );
	
	if(!isdefined(bEnableWeapons))
		bEnableWeapons = true;
	
	level.old_force_weapon = level.player GetCurrentWeapon();
	level.player giveWeapon( level.force_weapon );
	level.player givemaxammo( level.force_weapon );
	level.player SwitchToWeaponImmediate( level.force_weapon );
	if(bEnableWeapons)
	{
		level.player EnableWeapons();
	}
	level.player DisableWeaponSwitch();
}

/*
=============
///ScriptDocBegin
"Name: ForcePlayerWeapon_End()"
"Summary: return the player back to normal after ForcePlayerWeapon_Start()"
call after you're done with the special weapon from ForcePlayerWeapon_Start
"Example: ForcePlayerWeapon_End()"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

ForcePlayerWeapon_End(bEnableWeapons)
{
	assert( isdefined(level.force_weapon) );
	assert( level.player HasWeapon(level.force_weapon) );
	assert( level.player GetCurrentWeapon() == level.force_weapon );
	
	if(!isdefined(bEnableWeapons))
		bEnableWeapons = true;
	
	//give the player back his gun
	level.player takeweapon( level.force_weapon );
	
	if(isdefined( level.old_force_weapon ))
		level.player switchToWeapon( level.old_force_weapon );
	
	if(bEnableWeapons)
	{
		level.player EnableWeapons();	
		level.player EnableWeaponSwitch();
	}
	
	level.old_force_weapon = undefined;
}


/*
=============
///ScriptDocBegin
"Name: monitorScopeChange()"
"Summary: monitor weapon usage for changing the magnification of weapons while in ads"
call this as a thread from your level and specify the names of any number of weapons in the level.variable_scope_weapons array
"Example: thread monitorScopeChange()"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
monitorScopeChange()
{
	foreach( p in level.players )
	{
		/*
		if ( !isdefined( p.sniper_mag_hud) )
		{
			p.sniper_mag_hud = p createClientFontString( "default", 2 );
			p.sniper_mag_hud setPoint( "BOTTOM", undefined, 0, -50 );
			p.sniper_mag_hud.label = &"VARIABLE_SCOPE_SNIPER_MAG";
			p.sniper_mag_hud.alpha = 0;
			p.sniper_mag_hud.sort = 0.5;
			p.sniper_mag_hud.foreground = 1;
		}
		*/
		if ( !isdefined( p.sniper_zoom_hint_hud) )
		{
			p.sniper_zoom_hint_hud = p createClientFontString( "default", 1.75 );
			p.sniper_zoom_hint_hud.horzAlign = "center";
			p.sniper_zoom_hint_hud.vertAlign = "top";
			p.sniper_zoom_hint_hud.alignX = "center";
			p.sniper_zoom_hint_hud.alignY = "top";
			p.sniper_zoom_hint_hud.x = 0;
			p.sniper_zoom_hint_hud.y = 20;
			p.sniper_zoom_hint_hud SetText(&"VARIABLE_SCOPE_SNIPER_ZOOM");
			p.sniper_zoom_hint_hud.alpha = 0;
			p.sniper_zoom_hint_hud.sort = 0.5;
			p.sniper_zoom_hint_hud.foreground = 1;
		}
		
		p.fov_snipe = 1;
	  	//p.sniper_mag_hud setValue( convert_FOV_string(p.fov_snipe) );
	}

	was_using_ads = false;
	
	level.players[0].sniper_dvar = "cg_playerFovScale0";
	if(level.players.size == 2)
		level.players[1].sniper_dvar = "cg_playerFovScale1";

//	thread monitorZoomIn();
//	thread monitorZoomOut();
	foreach (p in level.players)
	{
		p thread monitorMagCycle();
		p thread DisableVariableScopeHudOnDeath();
	}
	
	if(!isdefined(level.variable_scope_weapons))
		level.variable_scope_weapons = [];

	match_player = undefined;
	last_match_player = undefined;
	while( 1 )
	{
		match = false;
		last_match_player = match_player;
		match_player = undefined;
		foreach( wep in level.variable_scope_weapons )
		{
			foreach( p in level.players )
			{
				if( p getcurrentweapon() == wep && IsAlive(p) )
				{
					match = true;
					match_player = p;
					break;
				}
			}
			
			if( match )
				break;
		}
				
		if( match && !match_player IsReloading() && !match_player isswitchingweapon() )
		{
			if( match_player isADS() && match_player ADSButtonPressed() )
			{
				match_player TurnOnVariableScopeHud(was_using_ads);
				
				was_using_ads = true;

				if(isdefined(level.variable_scope_shadow_center))
				{
					//find the closest override location and use it
					best_loc = undefined;
					best_dot = undefined;
					player_forward = AnglesToForward(match_player GetPlayerAngles());
					player_org = match_player.origin;
					foreach( org in level.variable_scope_shadow_center)
					{			
						to_vec = AnglesToForward(VectorToAngles(org - player_org));
						dot = VectorDot( player_forward, to_vec );
						if(!isdefined(best_loc) || dot > best_dot)
						{
							best_loc = org;
							best_dot = dot;
						}
					}
					
					if(isdefined(best_loc))
					{
						SetSavedDVar( "sm_sunShadowCenter", best_loc );
					}
				}
			}
			else if( was_using_ads )
			{
				//once we've entered the scope and turned on the hud we need to turn it off first chance we get
				was_using_ads = false;
				
				if( isdefined( match_player ) )
					match_player TurnOffVariableScopeHud();
				SetSavedDVar( "sm_sunShadowCenter", "0 0 0" );
			}
		}
		else if( was_using_ads )
		{
			//once we've entered the scope and turned on the hud we need to turn it off first chance we get
			was_using_ads = false;
			
			if(isdefined(last_match_player))
				last_match_player TurnOffVariableScopeHud();
			SetSavedDVar( "sm_sunShadowCenter", "0 0 0" );
		}
		wait(0.05);
	}
}

TurnOnVariableScopeHud( prev )
{
	//has entered ADS on the correct weapon
	self DisableOffhandWeapons();
	setsaveddvar( self.sniper_dvar, self.fov_snipe );
	//self.sniper_mag_hud.alpha = 1;
	self.sniper_zoom_hint_hud.alpha = 1;

	if( !prev )
		level notify("variable_sniper_hud_enter");	
}

TurnOffVariableScopeHud()
{
	level notify("variable_sniper_hud_exit");	
	
	self EnableOffhandWeapons();
	
	setsaveddvar( self.sniper_dvar, 1 );
//	turn this line back on to make the scope reset every time you exit it
//	self.fov_snipe = 1;
	//self.sniper_mag_hud setValue( convert_FOV_string(self.fov_snipe) );
	//self.sniper_mag_hud.alpha = 0;		
	self.sniper_zoom_hint_hud.alpha = 0;			
}

monitorMagCycle()
{
	notifyOnCommand( "mag_cycle", "+melee_zoom" );
	notifyOnCommand( "mag_cycle", "+sprint_zoom" );
	
	while(1)
	{
		self waittill( "mag_cycle" );
		
		if(self.sniper_zoom_hint_hud.alpha) //dont change the zoom unless we're in the view
		{
			//1 , 0.5
			assert(self.fov_snipe == 0.5 || self.fov_snipe == 1);
			if(self.fov_snipe == 0.5)
				self.fov_snipe = 1;
			else
				self.fov_snipe = 0.5;
			//self.sniper_mag_hud setValue( convert_FOV_string(self.fov_snipe) );
		}
	}
}


DisableVariableScopeHudOnDeath()
{
	self waittill("death");

	self TurnOffVariableScopeHud();
}

/*
monitorZoomIn()
{
	notifyoncommand( "zoom_in", "+actionslot 2" );
	
	while(1)
	{	
		level.player waittill( "zoom_in" );
		level.fov_snipe += 0.1;
		level.fov_snipe = clamp( level.fov_snipe, 0.2, 2.0 );
		level.sniper_mag_hud setValue( convert_FOV_string(level.fov_snipe) );
	}
}

monitorZoomOut()
{
	notifyoncommand( "zoom_out", "+actionslot 1" );
	
	while(1)
	{
		level.player waittill( "zoom_out" );
		
		level.fov_snipe -= 0.1;
		level.fov_snipe = clamp( level.fov_snipe, 0.2, 2.0 );
		level.sniper_mag_hud setValue( convert_FOV_string(level.fov_snipe) );
	}
}
*/
convert_FOV_string(fov)
{
	if(fov == 0.5)
		return 10;
	if(fov == 1)
		return 5;
	assert(0);
	return 5;
}

/#

draw_point_a_while( origin, size, colr, time )
{
	while ( time > 0 )
	{
		draw_point( origin, size, colr );
		wait 0.05;
		time = time - 0.05;
	}
}


draw_point( origin, size, colr )
{
	x = (size, 0, 0);
	line( origin - x, origin + x, colr );
	y = (0, size, 0);
	line( origin - y, origin + y, colr );
	z = (0, 0, size);
	line( origin - z, origin + z, colr );
}


draw_axis_a_while( origin, angles, time )
{
	while ( time > 0 )
	{
		draw_axis( origin, angles );
		wait 0.05;
		time = time - 0.05;
	}
}


draw_axis( origin, angles )
{
	red = (1, 0, 0);
	grn = (0, 1, 0);
	blu = (0, 0, 1);
	axis =[];
	axis[0] = anglestoforward( angles );
	axis[1] = anglestoright( angles );
	axis[2] = anglestoup( angles );
	size = 16;
	line( origin, origin + (size * axis[0]), red );
	line( origin, origin + (size * axis[1]), grn );
	line( origin, origin + (size * axis[2]), blu );
}


draw_debug_sphere( ent, center, radius, colr )
{
	axis =[];
	if (isdefined(ent))
	{
		axis[0] = anglestoforward( ent.angles );
		axis[1] = anglestoright( ent.angles );
		axis[2] = anglestoup( ent.angles );
	}
	else
	{
		axis[0] = anglestoforward( (0,0,0) );
		axis[1] = anglestoright( (0,0,0) );
		axis[2] = anglestoup( (0,0,0) );
	}
	points =[];
	points[0] = center + (radius * axis[0]);
	points[1] = center - (radius * axis[0]);
	points[2] = center + (radius * axis[1]);
	points[3] = center - (radius * axis[1]);
	points[4] = center + (radius * axis[2]);
	points[5] = center - (radius * axis[2]);

	line( points[0], points[2], colr );
	line( points[0], points[3], colr );
	line( points[0], points[4], colr );
	line( points[0], points[5], colr );

	line( points[1], points[2], colr );
	line( points[1], points[3], colr );
	line( points[1], points[4], colr );
	line( points[1], points[5], colr );

	line( points[2], points[4], colr );
	line( points[4], points[3], colr );
	line( points[3], points[5], colr );
	line( points[5], points[2], colr );
}


#/

/*
=============
///ScriptDocBegin
"Name: CreateDebugTextHud( <name>, <x>, <y>, [color], [text], [fontsize] )"
"Summary: Creates a debug HUD element that can be used to display debug text"
"CallOn: Nothing"
"MandatoryArg: <name>: The name used for this element."
"MandatoryArg: <x>: The x location in screen space (0-639)."
"MandatoryArg: <y>: The y location in screen space (0-479)."
"OptionalArg: [color]: The color of the text (defaults to (1,1,1))"
"OptionalArg: [text]: The text used for this element (defaults to empty string)"
"OptionalArg: [fontsize]: The size of the text used for this element (defaults to 2.0)"
"Example: CreateDebugTextHud( name, x, y, color, text )"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
CreateDebugTextHud( name, x, y, color, text, fontsize )
{
	assert( !isdefined( level.debug_text_hud ) || !isdefined( level.debug_text_hud[ name ] ) );
	
	size = 2.0;
	if (isdefined(fontsize))
		size = fontsize;
			
	hud = level.player createClientFontString( "default",  size );
	
	hud.x = x;
	hud.y = y;
	hud.sort = 1;
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha = 1.0;
	if (!isdefined(color))
		color = (1,1,1);
	hud.color = color;
	if (isdefined(text))
		hud.label = text;
	level.debug_text_hud[ name ] = hud;
}

/*
=============
///ScriptDocBegin
"Name: PrintDebugTextHud( <name>, <value> )"
"Summary: Sets the value for the debugTextHud name (CreateDebugTextHud needs to have been previously called)"
"CallOn: Nothing"
"MandatoryArg: <name>: The name used for this element."
"MandatoryArg: <value>: The value used for this element. (must be a number)"
"Example: PrintDebugTextHud( "my name", 0.5 )"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
PrintDebugTextHud( name, val )
{
	assert( isdefined( level.debug_text_hud[ name ] ) );
	level.debug_text_hud[ name ] SetValue( val );
}

/*
=============
///ScriptDocBegin
"Name: PrintDebugTextStringHud( <name>, <text> )"
"Summary: Sets the text for the debugTextHud name (CreateDebugTextHud needs to have been previously called)"
"CallOn: Nothing"
"MandatoryArg: <name>: The name used for this element."
"MandatoryArg: <text>: The text used for this element. (must be a string)"
"Example: PrintDebugTextHud( name, "value="+value )"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
PrintDebugTextStringHud( name, text )
{
	assert( isdefined( level.debug_text_hud[ name ] ) );
	level.debug_text_hud[ name ] SetText( text );
}

/*
=============
///ScriptDocBegin
"Name: ChangeDebugTextHudColor( <name>, <color> )"
"Summary: Sets the color for the debugTextHud name (CreateDebugTextHud needs to have been previously called)"
"CallOn: Nothing"
"MandatoryArg: <name>: The name used for this element."
"MandatoryArg: <color>: The color used for this element. (must be a vector)"
"Example: ChangeDebugTextHudColor( name, (1,0,0) )"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
ChangeDebugTextHudColor( name, color )
{
	assert( isdefined( level.debug_text_hud[ name ] ) );
	level.debug_text_hud[ name ].color = color;
}

/*
=============
///ScriptDocBegin
"Name: DeleteDebugTextHud( <name> )"
"Summary: Deletes the debugTextHud with name"
"CallOn: Nothing"
"MandatoryArg: <name>: The name used for this element."
"Example: DeleteDebugTextHud( name )"
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
DeleteDebugTextHud( name )
{
	assert( isdefined( level.debug_text_hud[ name ] ) );
	level.debug_text_hud[ name ] Destroy();
	level.debug_text_hud[ name ] = undefined;
}

/*
=============
///ScriptDocBegin
"Name: dialogue_reminder( <character>, <while_flag>, <lines>, [min_delay], [max_delay] )"
"Summary: This function will perdiodically play reminder dialog while the <while_flag> is not true (IE - a nag if the player takes too long to do his current objective).  Lines are chosen randomly from <lines>.  Lines will not play twice in a row.  Random wait between [delay_min] and [delay_max] between lines.  "
"CallOn: Nothing"
"MandatoryArg: <character>: The name of the character to play the lines.  If "radio" is passed in as <character> the line is played with radio_dialogue rather than dialogue_queue"
"MandatoryArg: <while_flag>: Reminder dialog will continue to play until this flag is set to true."
"MandatoryArg: <lines>: an array of lines to choose from.  No lines will repeat back to back"
"OptionalArg: [delay_min]: Min delay to wait between lines - defaults to 10"
"OptionalArg: [delay_max]: Max delay to wait between lines - defaults to 20"
"Example: dialogue_reminder ( level.sandman, "bomb_planted", lines, 10, 20 ); "
"Module: shg_common"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
dialogue_reminder ( character, while_flag, lines, delay_min, delay_max )
{
	level endon ( "stop_reminders" );
	level endon ( "missionfailed" );
	//assertex ( ( isdefined ( character ) ) && ( isai ( character ) ), "Character is not properly defined" );
	//assertex ( ( isdefined ( lines ) && isarray ( lines ) ), "Lines is undefined, or is not an array" );
	last_line = undefined;
	if ( !isdefined ( delay_min ) )
		delay_min = 10;
	if ( !isdefined ( delay_max ) )
		delay_max = 20;
		
	while (!flag ( while_flag ) )
	{
		rand_delay = RandomfloatRange ( delay_min, delay_max );
		rand_line = random ( lines );
		
		if ( isdefined ( last_line ) && rand_line == last_line )
			continue;
		else
		{
			last_line = rand_line;
			wait rand_delay;
			
			if ( !flag ( while_flag ) ) 
			{
				if ( IsString ( character ) && character == "radio" )
				{
					conversation_start();
					radio_dialogue ( rand_line );
					conversation_stop();
				}					
				else 
				{
					conversation_start();
					character dialogue_queue ( rand_line );
					conversation_stop();
				}
			}
			
		}
		
	}
	
}


// call this when you're just about to start several consequetive dialogeu lines 
// it will handle ducking the mix for the entire time, and also will sequence conversations
// in case you have some random points at which these are triggered.
conversation_start()
{
	if (!flag_exist("flag_conversation_in_progress"))
	{
		flag_init("flag_conversation_in_progress");
	}
	/#
	if(flag("flag_conversation_in_progress"))
	{
		if(GetDebugDvarInt("developer") != 0)
	{
		IPrintLn("conversation_start(): conversation is being delayed by another conversation.");	
	}	
	}
	#/
	
	flag_waitopen("flag_conversation_in_progress");
	flag_set("flag_conversation_in_progress");
	
	/#
	thread conversation_debug_timeout();
	#/
}

// make sure you always call this after calling conversation_begin()
conversation_stop()
{
	flag_clear("flag_conversation_in_progress");	
}


/#
conversation_debug_timeout()
{
	flag_waitopen_or_timeout("flag_conversation_in_progress", 60);
	if(flag("flag_conversation_in_progress"))
	{
		AssertEx(false, "A conversation lasted > 60 seconds, and other dialogue might be waiting.  Possible misplaced conversation_begin()?");	
	}
}
#/

/* 
 ============= 
//ScriptDocBegin
"Name: array_find( <array> , <item> )"
"Summary: Searches for the first occurrence of item in array and returns the key.  Returns undefined if not found"
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : array to search"
"MandatoryArg: <item> : item to search for"
"Example: founditem = array_find( array, item );"
"SPMP: both"
///ScriptDocEnd
 ============= 
 */ 
/*
 * MOVED TO _utlity.gsc	
 * 
array_find( array, item )
{
	foreach (idx, test in array)
	{
		if (test == item)
		{
			return idx;
		}
	}
	return undefined;
}
*/
 /* 
 ============= 
///ScriptDocBegin
"Name: array_combine_unique( <array1> , <array2> )"
"Summary: Combines the two arrays and returns the resulting array. This function doesn't duplicate any entries."
"Module: Array"
"CallOn: "
"MandatoryArg: <array1> : first array"
"MandatoryArg: <array2> : second array"
"Example: combinedArray = array_combine_unique( array1, array2 );"
"SPMP: both"
///ScriptDocEnd
 ============= 
 */ 
array_combine_unique( array1, array2 )
{
	array3 = [];
	foreach ( item in array1 )
	{
		if (!isdefined(array_find(array3, item)))
			array3[ array3.size ] = item;
	}
	foreach ( item in array2 )
	{
		if (!isdefined(array_find(array3, item)))
			array3[ array3.size ] = item;
	}
	return array3;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///laser designator
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

laser_targeting_device( player )
{
	player endon( "remove_laser_targeting_device" );
	
	player.lastUsedWeapon = undefined;
	
	assert(!isdefined(player.laserForceOn));
	player.laserForceOn = false;
	player setWeaponHudIconOverride( "actionslot4", "dpad_laser_designator" );
	player thread CleanUpLaserTargetingDevice();
	
	player notifyOnPlayerCommand( "use_laser", "+actionslot 4" );
	player notifyOnPlayerCommand( "fired_laser", "+attack" );
	player notifyOnPlayerCommand( "fired_laser", "+attack_akimbo_accessible" );	// support accessibility control scheme
	
	player.laserAllowed = true;
	player.laserCoolDownAfterHit = 20;
	
	player childthread monitorLaserOff();

	for ( ;; )
	{
		player waittill( "use_laser" );
		
		if ( player.laserForceOn || !player.laserAllowed || player ShouldForceDisableLaser())
		{
			player notify( "cancel_laser" );
			player laserForceOff();
			player.laserForceOn = false;
			player AllowADS( true );
			wait 0.2;
			player allowFire( true );			
		}
		else
		{
			player laserForceOn();
			player allowFire( false );
			player.laserForceOn = true;		
			player AllowADS( false );
			player thread laser_designate_target();
		}
	}
}

ShouldForceDisableLaser()
{
	weap = self GetCurrentWeapon();
	if(weap == "rpg")
		return true;
	if(string_starts_with(weap, "gl"))
		return true;
	if(isdefined(level.laser_designator_disable_list) && isarray(level.laser_designator_disable_list))
	{
		foreach( w in level.laser_designator_disable_list)
			if(weap == w)
				return true;
	}
	
	if( self IsReloading() )
	{
		return true;
	}
	
	if( self IsThrowingGrenade() )
	{
		return true;
	}
	
	return false;
}

CleanUpLaserTargetingDevice()
{
	self waittill( "remove_laser_targeting_device" );
	self setWeaponHudIconOverride( "actionslot4", "none" );
	
	//force shut down the laser if on when we turn the system off
	self notify( "cancel_laser" );
	self laserForceOff();
	self.laserForceOn = undefined;
	self allowFire( true );
	self AllowADS( true );
}

monitorLaserOff()
{
	while(1)
	{
		if(ShouldForceDisableLaser() && isdefined(self.laserForceOn) && self.laserForceOn)
		{
			self notify( "use_laser" );
			wait(2.0);
		}
		wait(0.05);
	}
}

laser_designate_target()
{
	self endon( "cancel_laser" );
	
	while(1)
	{
		self waittill( "fired_laser" );
	
		trace = self get_laser_designated_trace();
		viewpoint = trace[ "position" ];
		entity = trace[ "entity" ];
		
		level notify( "laser_coordinates_received" );
			
		// Check if we are supposed to be targeting for artillery now
		laser_target = undefined;
		
		if(isdefined(level.laser_targets) && isdefined(entity) && array_contains(level.laser_targets, entity))
		{
				laser_target = entity;
				level.laser_targets = array_remove(level.laser_targets, entity);
		}
		else
		{
			laser_target = GetTargetTriggerHit(viewpoint);
		}
		
		if ( isdefined( laser_target ) )
		{
			thread laser_artillery( laser_target );
				
			//play a rumble for feedback here?
			
			//notify level that target has been painted to remove objective dots.
			level notify("laser_target_painted");
			
			//add a delay to prevent the gun from firing
			wait(0.5);
			// take away laser on a hit
			self notify( "use_laser" );		
		}
	}
}

GetTargetTriggerHit(viewpoint)
{
	if(!isdefined(level.laser_triggers) || level.laser_triggers.size == 0)
		return undefined;
	foreach( trigger in level.laser_triggers)
	{
		d = distance2d( viewpoint, trigger.origin );
		h = viewpoint[2] - trigger.origin[2];
		if(!isdefined(trigger.radius))
			continue;
		if(!isdefined(trigger.height))
			continue;
		if ( d <= trigger.radius && h <= trigger.height && h >= 0)
		{
			level.laser_triggers = array_remove(level.laser_triggers, trigger);
			return getent(trigger.target, "script_noteworthy");
		}
	}
	return undefined;
}

get_laser_designated_trace()
{
	eye = self geteye();
	angles = self getplayerangles();
	
	forward = anglestoforward( angles );
	end = eye + ( forward * 7000 );
	trace = bullettrace( eye, end, true, self );
	
	//thread draw_line_for_time( eye, end, 1, 1, 1, 10 );
	//thread draw_line_for_time( eye, trace[ "position" ], 1, 0, 0, 10 );
	
	entity = trace[ "entity" ];
	if ( isdefined( entity ) )
		trace[ "position" ] = entity.origin;
	
	return trace;
}

//add objects to the level.laser_targets list
//for triggers:
//we use trigger.target = obj.script_notworthy
//how we tag geo targetname and script_group
//explosion group should be script_index on the entity

laser_artillery(target_ent)
{
	level.player endon( "remove_laser_targeting_device" );//so we can disable laser during cool down.
	level.player.laserAllowed = false;
	self setWeaponHudIconOverride( "actionslot4", "dpad_killstreak_hellfire_missile_inactive" );
	flavorbursts_off( "allies" );
	
	soundEnt = level.player;
	
	wait 2.5;
	
	//assert is commented out until we get the data updated
	if(!isdefined(target_ent.script_index))
		target_ent.script_index = 99;

	wait 1;
	
	// swap the geo
	if(isdefined(target_ent.script_group))
	{
		before = get_geo_group( "geo_before", target_ent.script_group );
		if( before.size > 0 )
			array_call( before, ::hide );
			
		after = get_geo_group( "geo_after", target_ent.script_group );
		if( after.size > 0 )
			array_call( after, ::show );
	}
	
	//laser cooldown
	wait(level.player.laserCoolDownAfterHit);
	level.player.laserAllowed = true;
	self setWeaponHudIconOverride( "actionslot4", "dpad_laser_designator" );
}

get_geo_group( targetname, groupNum )
{
	ents = getentarray( targetname, "targetname" );
	returnedEnts = [];
	foreach( ent in ents )
	{
		if ( isdefined(ent.script_group) && ent.script_group == groupNum )
			returnedEnts[ returnedEnts.size ] = ent;
	}
	return returnedEnts;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: vision_change_multiple_init()"
"Module: SP/MP"
"CallOn: level"
"Example: vision_change_multiple_init()"
"SPMP: both"
///ScriptDocEnd
 ============= 
 */ 


//call this in your level to get all trigger multiples that have a targetname of shg_vision_multiple_trigger to work correctly.
//while a player is standing in this trigger it sees which script struct they are closest to looking at then read the sun shadow params from the struct and apply them
//lets us set settings while the player is looking off a building in berlin and stop using those settings if they look backwards
vision_change_multiple_init()
{
	trigs = GetEntArray( "shg_vision_multiple_trigger", "targetname" );
	
	foreach(t in trigs)
		 t thread vision_change_multiple_internal();
}

vision_change_multiple_internal()
{
	assert(isdefined(self));
	assert(isdefined(self.target));
	lookat_arr = GetStructArray(self.target, "targetname");
	assert(isdefined(lookat_arr));
	assert(lookat_arr.size > 0);
	
	//assume the trigger and its objects dont move
	foreach(l in lookat_arr)
	{
		l_for = VectorNormalize(self.origin - l.origin);
		assert(!isdefined(l.forward_for_vision_change ));
		l.forward_for_vision_change = l_for;
	}

	
	while(1)
	{
		self waittill("trigger", guy);
		if(isplayer(guy))
		{
			p_for = AnglesToForward(guy GetPlayerAngles());
			best = undefined;
			best_val = 0;
			foreach(l in lookat_arr)
			{
				assert(isdefined(l.forward_for_vision_change));
				dot = VectorDot(p_for, l.forward_for_vision_change);
				if(!isdefined(best) || dot < best_val)
				{
					best = l;
					best_val = dot;
				}
			}
			
			assert(isdefined(best));
			duration = 1;
			if ( IsDefined( best.script_duration ) )
				duration = best.script_duration;
			best maps\_lights::set_sun_shadow_params( duration );
			wait(duration);
		}
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: change_character_model()"
"Summary: SetModel will make all weapon tags visible on an ai.  this function re-hides all the weapon tags"
"Module: SP/MP"
"CallOn: the ai you want to change the model on"
"MandatoryArg: <model_name> : the model we're switching to"
"Example: level.sandman change_character_model("birthday_suit")"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

change_character_model( model_name )
{
	assert( isdefined( model_name ) );
	assert( isai( self ) );
	assert( IsAlive( self ) );
	
	self SetModel( model_name );
	
	update_weapon_tag_visibility( self.weapon );
//	update_weapon_tag_visibility( self.secondaryweapon );
//	update_weapon_tag_visibility( self.sidearm );
}


 /* 
 ============= 
///ScriptDocBegin
"Name: update_weapon_tag_visibility()"
"Summary: Make sure to hide all the correct tags on a weapon"
"Module: SP"
"CallOn: the object whos weapon needs to be updated"
"MandatoryArg: <weapon> : the weapon we're updating"
"OptionalArg: <weapon_model_override> : if youre using a _obj model you should pass in the real model name"
"Example: level.sandman update_weapon_tag_visibility( self.primaryweapon )"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
update_weapon_tag_visibility( weapon, weapon_model_override )
{
	if( isdefined( weapon ) && weapon != "none")
	{
		hideTagList = GetWeaponHideTags( weapon );
		assert( isdefined( hideTagList ) );
		
		variant = 0;
		weapon_model = getWeaponModel( weapon, variant );
		if( isdefined( weapon_model_override ) )
			weapon_model = weapon_model_override;
		
		assert( isdefined( weapon_model ) );
		
		for ( i = 0; i < hideTagList.size; i++ )
		{
			self HidePart( hideTagList[ i ], weapon_model );
		}
	}	
}

/* Supports multiple lines in facial animation tagged with "dialogue_line" */
multiple_dialogue_queue( scene )
{
	bcs_scripted_dialogue_start();

	AssertEx( IsDefined( scene ), "Tried to do multiple_dialogue_queue without passing a scene name" );

	if ( IsDefined( self.last_queue_time ) )
	{
		wait_for_buffer_time_to_pass( self.last_queue_time, 0.5 );
	}
	
	guys = [];
	guys[0] = [ self, 0 ];

	function_stack( ::anim_single_end_early, guys, scene );

	if ( IsAlive( self ) )
		self.last_queue_time = GetTime();
}

/*
	This version of anim_single allows animations of different entities to end at different times.  It will only
	  return when all animations are finished playing.  It will also notify each entity of "anim_ended" when their 
	  animation has completed.

	guys_structs - pass in an array of pairs.  The pair's first item is the entity to animate, the second item is how much time
	                 to end the entity's animation early by.  0 being to play the animation fully.
	anime - animation scene name
	tag - the tag on self to play the animation relative to
*/
anim_single_end_early( guys_structs, anime, tag )
{
	entity = self;

	guys = [];
	foreach ( i, guy_struct in guys_structs )
	{
		guys[ i ] = guy_struct[0];
	}

	/#
	thread anim_single_failsafe( guys, anime );
	#/
	// disable BCS if we're doing a scripted sequence.
	foreach ( guy in guys )
	{
		if ( !isdefined( guy ) )
			continue;
		if ( !isdefined( guy._animActive ) )
			guy._animActive = 0;// script models cant get their animactive set by init
		guy._animActive++;
	}

	pos = get_anim_position( tag );
	org = pos[ "origin" ];
	angles = pos[ "angles" ];

	anim_string = "single anim";

	ent = SpawnStruct();
	waittills = 0;
	foreach ( i, guy in guys )
	{
		doFacialanim = false;
		doDialogue = false;
		doAnimation = false;
		doText = false;

		dialogue = undefined;
		facialAnim = undefined;

		animname = guy.animname;

		/#
		guy assert_existance_of_anim( anime, animname );
		#/

		if ( ( IsDefined( level.scr_face[ animname ] ) ) &&
			( IsDefined( level.scr_face[ animname ][ anime ] ) ) )
		{
			doFacialanim = true;
			facialAnim = level.scr_face[ animname ][ anime ];
		}

		if ( ( IsDefined( level.scr_sound[ animname ] ) ) &&
			( IsDefined( level.scr_sound[ animname ][ anime ] ) ) )
		{
			doDialogue = true;
			dialogue = level.scr_sound[ animname ][ anime ];
		}

		if ( ( IsDefined( level.scr_anim[ animname ] ) ) &&
			( IsDefined( level.scr_anim[ animname ][ anime ] ) ) &&
			( !isAI( guy ) || !guy doingLongDeath() ) )
			doAnimation = true;

		if ( IsDefined( level.scr_animSound[ animname ] ) &&
			 IsDefined( level.scr_animSound[ animname ][ anime ] ) )
		{
			guy PlaySound( level.scr_animSound[ animname ][ anime ] );
		}

		/#
		if ( GetDebugDvar( "animsound" ) == "on" )
		{
			guy thread animsound_start_tracker( anime, animname );
		}
		#/


		/#
		if ( ( IsDefined( level.scr_text[ animname ] ) ) &&
			( IsDefined( level.scr_text[ animname ][ anime ] ) ) )
			doText = true;
		#/

		if ( doAnimation )
		{
			guy last_anim_time_check();
			if ( isPlayer( guy ) )
			{
//				guy ForceTeleport( org, angles );

				root_animation = level.scr_anim[ animname ][ "root" ];
				guy SetAnim( root_animation, 0, 0.2 );

				animation = level.scr_anim[ animname ][ anime ];
				guy SetFlaggedAnim( anim_string, animation, 1, 0.2 );
				
			}
			else
			if ( guy.code_classname == "misc_turret" )
			{
				animation = level.scr_anim[ animname ][ anime ];
				guy SetFlaggedAnim( anim_string, animation, 1, 0.2 );
			}
			else
			{
				// ai and models use animscripted
				guy AnimScripted( anim_string, org, angles, level.scr_anim[ animname ][ anime ] );
			}
			
			thread start_notetrack_wait( guy, anim_string, anime, animname );
			thread animscriptDoNoteTracksThread( guy, anim_string, anime );
		}


		if ( ( doFacialanim ) || ( doDialogue ) )
		{
			if ( doFacialAnim )
			{
				if ( doDialogue )
					guy thread doFacialDialogue( anime, doFacialanim, dialogue, level.scr_face[ animname ][ anime ] );
				AssertEx( !doanimation, "Can't play a facial anim and fullbody anim at the same time. The facial anim should be in the full body anim. Occurred on animation " + anime );
				thread anim_facialAnim( guy, anime, level.scr_face[ animname ][ anime ] );
			}
			else
			{
				/#
				println("**dialog alias playing locally: " + dialogue );
				#/
			
				if ( IsAI( guy ) )
				{
					if ( doAnimation )
						guy animscripts\face::SaySpecificDialogue( facialAnim, dialogue, 1.0 );
					else
					{
						guy thread anim_facialFiller( "single dialogue" );
						guy animscripts\face::SaySpecificDialogue( facialAnim, dialogue, 1.0, "single dialogue" );
					}
				}
				else
				{
					guy thread play_sound_on_entity( dialogue, "single dialogue" );
				}
			}
		}
		AssertEx( doAnimation || doFacialanim || doDialogue || doText, "Tried to do anim scene " + anime + " on guy with animname " + animname + ", but he didn't have that anim scene." );

		/#
		if ( doText && !doDialogue )
		{
			IPrintLnBold( level.scr_text[ animname ][ anime ] );
			wait 1.5;
		}
		#/
		
		if ( doAnimation )
		{
			animtime = GetAnimLength( level.scr_anim[ animname ][ anime ] );
			ent thread anim_end_early_deathNotify( guy, anime );
			ent thread anim_end_early_animationEndNotify( guy, anime, animtime, guys_structs[ i ][ 1 ] );
			waittills++;
		}
		else if ( doFacialAnim )
		{
			ent thread anim_end_early_deathNotify( guy, anime );
			ent thread anim_end_early_facialEndNotify( guy, anime, facialAnim );
			waittills++;
		}
		else if ( doDialogue )
		{
			ent thread anim_end_early_deathNotify( guy, anime );
			ent thread anim_end_early_dialogueEndNotify( guy, anime );
			waittills++;
		}
	}

	while ( waittills > 0 )
	{
		ent waittill( anime, guy );
		waittills--;
		
		if ( !isdefined( guy ) )
			continue;
		
		if ( isPlayer( guy ) )
		{	
			animname = guy.animname;

			// is there an animation?
			if ( isdefined( level.scr_anim[ animname ][ anime ] ) )
			{
				root_animation = level.scr_anim[ animname ][ "root" ];
				guy setanim( root_animation, 1, 0.2 );

				animation = level.scr_anim[ animname ][ anime ];
				guy ClearAnim( animation, 0.2 );
			}
		}

		guy._animActive--;
		guy._lastAnimTime = GetTime();
		Assert( guy._animactive >= 0 );
	}

	self notify( anime );
}

anim_end_early_deathNotify( guy, anime )
{
	guy endon( "kill_anim_end_notify_" + anime );
	guy waittill( "death" );
	self notify( anime, guy );
	guy notify( "kill_anim_end_notify_" + anime );
}

anim_end_early_facialEndNotify( guy, anime, scriptedFaceAnim )
{
	guy endon( "kill_anim_end_notify_" + anime );
	time = getanimlength( scriptedFaceAnim );
	wait( time );
//	guy waittillmatch( "face_done_" + anime, "end" );
	self notify( anime, guy );
	guy notify( "kill_anim_end_notify_" + anime );
}

anim_end_early_dialogueEndNotify( guy, anime )
{
	guy endon( "kill_anim_end_notify_" + anime );
	guy waittill( "single dialogue" );
	self notify( anime, guy );
	guy notify( "kill_anim_end_notify_" + anime );
}

anim_end_early_animationEndNotify( guy, anime, animationTime, anim_end_time )
{
	guy endon( "kill_anim_end_notify_" + anime );
	animationTime -= anim_end_time;
	if ( anim_end_time > 0 && animationTime > 0 )
	{
		guy waittill_match_or_timeout( "single anim", "end", animationTime );
		guy StopAnimScripted();
	}
	else
	{
		guy waittillmatch( "single anim", "end" );
	}
	
	guy notify( "anim_ended" );
	self notify( anime, guy );
	guy notify( "kill_anim_end_notify_" + anime );
}

doFacialDialogue( anime, doAnimation, dialogue, animationName )
{
	if ( doAnimation )
	{
		AssertEx( AnimHasNotetrack( animationName, "dialogue_line" ), "animation is missing expected dialogue_line notetrack" );
		
		self thread notify_facial_anim_end( anime );
		self thread warn_facial_dialogue_unspoken( anime );
		self thread warn_facial_dialogue_too_many( anime );
		
		dialogue_lines = [];
		if ( !IsArray( dialogue ) )
		{
			dialogue_lines[0] = dialogue;
		}
		else
		{
			dialogue_lines = dialogue;
		}

		foreach ( dialogue_line in dialogue_lines )
		{
			// not using priming.  just add VO line to RAM in order to sync to anim
			//self thread aud_prime_stream( dialogue_line );
			self waittillmatch( "face_done_" + anime, "dialogue_line" );
			//AssertEx( self aud_is_stream_primed( dialogue_line ), "dialogue line was not primed!" );
			/#
			println("**dialog alias playing locally: " + dialogue_line );
			#/
			self animscripts\face::SaySpecificDialogue( undefined, dialogue_line, 1.0 );
		}
		
		self notify( "all_facial_lines_done" );
	}
	else
	{
		self animscripts\face::SaySpecificDialogue( undefined, dialogue, 1.0, "single dialogue" );
	}
}

notify_facial_anim_end( anime )
{
	self endon( "death" );
	self waittillmatch( "face_done_" + anime, "end" );
	self notify( "facial_anim_end_" + anime );
}

warn_facial_dialogue_unspoken( anime )
{
	self endon( "death" );
	self endon( "all_facial_lines_done" );
	self waittill( "facial_anim_end_" + anime );
	AssertEx( false, "Lines did not finish playing. Not enough notetracks in facial animation or too many lines in dialogue array." );
}

warn_facial_dialogue_too_many( anime )
{
	self endon( "death" );
	self endon( "facial_anim_end_" + anime );
	self waittill( "all_facial_lines_done" );
	self waittillmatch( "face_done_" + anime, "dialogue_line" );
	AssertEx( false, "Too many notetracks in facial animation or not enough lines in dialogue array." );
}
