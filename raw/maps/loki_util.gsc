#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_move_to_checkpoint_start( node_targetname )
{
	// Move player to start
	node = GetEnt( node_targetname, "targetname" );
	level.player setOrigin( node.origin );
	level.player setPlayerAngles( node.angles );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies_move_to_checkpoint_start( checkpoint, reset )
{
	// Move allies to start points
	for ( i = 0; i < 3; i++ )
	{
		struct_targetname = checkpoint + "_ally_" + i;
		struct			  = GetStruct( struct_targetname, "targetname" );
		level.allies[ i ] ForceTeleport( struct.origin, struct.angles );
		if( IsDefined( reset ) )
		{
			level.allies[ i ] clear_force_color();
			level.allies[ i ] SetGoalPos( struct.origin );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_allies()
{
	level.allies					  = [];
	level.allies[ level.allies.size ] = spawn_ally( "ally_0" );
	level.allies[ level.allies.size ] = spawn_ally( "ally_1" );
	level.allies[ level.allies.size ] = spawn_ally( "ally_2" );
	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_ally( allyName, overrideSpawnPointName )
{
	spawnname = undefined;
	if ( !IsDefined( overrideSpawnPointName ) )
	{
		spawnname = level.start_point + "_" + allyName;
	}
	else
	{
		spawnname = overrideSpawnPointName + "_" + allyName;
	}

	ally = spawn_targetname_at_struct_targetname( allyName, spawnname );
	if ( !IsDefined( ally ) )
	{
		return undefined;
	}
	ally make_hero();
	if ( !IsDefined( ally.magic_bullet_shield ) )
	{
		ally magic_bullet_shield();
		ally.animname = allyName;
	}

	return ally;	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_targetname_at_struct_targetname( tname, sname )
{
	spawner = GetEnt( tname, "targetname" );
	sstart	= getstruct( sname, "targetname" );
	if ( IsDefined( spawner ) && IsDefined( sstart ) )
	{
		spawner add_spawn_function( maps\_space_ai::enable_space );
		spawned = spawner spawn_ai();

		if( !IsDefined( sstart.angles ) )
			sstart.angles = level.player.angles;
		spawned ForceTeleport( sstart.origin, sstart.angles );		

		return spawned;
	}
	if ( IsDefined( spawner ) )
	{
		spawner add_spawn_function( maps\_space_ai::enable_space );
		spawned = spawner spawn_ai();
		IPrintLnBold( "Add a script struct called: " + sname + " to spawn him in the correct location." );
		spawned Teleport( level.player.origin, level.player.angles );
		return spawned;
		
	}
	IPrintLnBold( "failed to spawn " + tname + " at " + sname );

	return undefined;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_space_ai( spawner, instant )
{
	ai = spawner spawn_ai( true );
	ai thread maps\_space_ai::enable_space();
	
	AssertEx( IsDefined( spawner.target ), "Spawner at " + spawner.origin + " must be linked to a struct or ent where you want the spawned to teleport to." );
	org = spawner get_target_ent();
	if ( !IsDefined( org.angles ) )
		org.angles = spawner.angles;
	ai ForceTeleport( org.origin, org.angles );
	
	if( IsDefined( instant ) && instant )
	{
		AssertEx( IsDefined( org.target ), "No node to spawn instantly at!" );
		node = GetNode( org.target, "targetname" );
		ai ForceTeleport( node.origin, node.angles );
	}

	if( IsDefined( org.target ) )
	{
		ai set_space_goal_node( org );
		ai.goalradius = 4;
	}

	return ai;
}

set_space_goal_node( org )
{
	goalnode = GetNode( org.target, "targetname" );
	if( IsDefined( goalnode ) )
	{
		//don't want to set goal node the frame we are created...
		waitframe();
		self SetGoalNode( goalnode );
	}
}

spawn_space_ai_from_targetname( tname, instant )
{
	if( !IsDefined( instant ) )
		instant = false;
	
	spawner = GetEnt( tname, "targetname" );
	ai = spawn_space_ai( spawner, instant );

	return ai;
}

spawn_space_ais_from_targetname( tname, instant )
{
	if( !IsDefined( instant ) )
		instant = false;
	
	spawners = GetEntArray( tname, "targetname" );
	ais = [];

	foreach( spawner in spawners )
	{
		ai = spawn_space_ai( spawner, instant );
		ais[ ais.size ] = ai;
	}

	return ais;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// TEST WEAPONS
xm25_destroy_hud( hud )
{
	if(!IsDefined(hud))
		return;
		
	if ( IsDefined( hud.data_value ) )
	{
		hud.data_value Destroy();
	}

	if ( IsDefined( hud.data_value_suffix ) )
	{
		hud.data_value_suffix Destroy();
	}

	hud Destroy();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cleanup_ADS_at_death()
{
	self waittill( "death" );
    if(IsDefined(self.hud0))
		xm25_destroy_hud(self.hud0);
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

watchWeaponSwitch( overlay_weapon )
{
	self endon ( "death" );
	while (true)
	{
		self waittill("weapon_switch_started");
	    if(IsDefined(self.hud0))
			xm25_destroy_hud(self.hud0);
		if (!self.cg_drawBreathHint && ( self GetCurrentWeapon() != overlay_weapon ))
		{
			SetSavedDvar("cg_drawBreathHint", true );
			self.cg_drawBreathHint = true;
		}
		if ( self GetCurrentWeapon() == overlay_weapon )
			self.weapon_change_timer = 20;	// we are switching from the xm25, so wait
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

watchADS( overlay_weapon )
{
	thread cleanup_ADS_at_death();
	self endon ( "death" );
	self.cg_drawBreathHint = true;
	self.weapon_change_timer = 0;
	self thread watchWeaponSwitch( overlay_weapon );

	for(;;)
	{
		newADSState = self AdsButtonPressed();
		curweapon = self GetCurrentWeapon();
		if (curweapon == overlay_weapon)
		{	// manually disabling breath hint, since code will automatically give us a hint if we use a crosshairs without scope
			// note that this method shouldn't be used for MP/SO
			if (newADSState || (self PlayerAds() >= 0))
			{
				SetSavedDvar("cg_drawBreathHint", false );
				self.cg_drawBreathHint = false;
			}
			else
			{
				SetSavedDvar("cg_drawBreathHint", true );
				self.cg_drawBreathHint = true;
			}
		}
		if( !newADSState || curweapon != overlay_weapon || self IsReloading() || !IsAlive( self ) )
		{	// destroy the temp hud.
		    if(IsDefined(self.hud0))
				xm25_destroy_hud(self.hud0);
		    if(IsDefined(self.hud1))
				xm25_destroy_hud(self.hud1);
		}
		if ( curweapon == overlay_weapon && newADSState && 
			 self PlayerAds() >= .75 && !IsDefined(self.hud) && (self.weapon_change_timer <= 0) )
		{	// bring up the temp hud!
			if(!IsDefined(self.hud0))
				self.hud0 = create_hud_xm25_screen( 1, 1, self );
			if(!IsDefined(self.hud1))
				self.hud1 = create_hud_xm25_scanlines( 1, 1 );
		}
		
		if(IsDefined(self.hud1))
		{
			self.hud1.y += 1;
			if(self.hud1.y > 8)
				self.hud1.y = -4;
		}
		self.weapon_change_timer--;
		if (self.weapon_change_timer == 0)
		{	// getting ammo from an ammo box initiates a weapon change to the same weapon, so ensure the breath draw is correct
			if ( curweapon == overlay_weapon )
			{
				SetSavedDvar("cg_drawBreathHint", false );
				self.cg_drawBreathHint = false;
			}
			else
			{
				SetSavedDvar("cg_drawBreathHint", true );
				self.cg_drawBreathHint = true;
			}
		}
		wait (.05);
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

create_hud_xm25_screen( sortOrder, alphaValue, client )
{
	overlay = "hud_xm25_temp";
	hud = NewClientHudElem( client );
	hud.x = 0;
	hud.y = 0;
	hud.sort = sortOrder;
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha = alphaValue;
	hud SetShader( overlay, 640, 480 );

	return hud;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

create_hud_xm25_scanlines( sortOrder, alphaValue )
{
	overlay = "hud_xm25_scanlines";
	hud = NewHudElem();
	hud.x = 0;
	hud.y = 0;
	hud.sort = sortOrder;
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha = alphaValue;
	hud SetShader( overlay, 640, 480 );

	return hud;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

JKUline( start, end, color, alpha, depthTest, duration )
{
	if( IsDefined( level.JKUdebug ) && level.JKUdebug )
	{
		if( !IsDefined( color ) )
			Line( start, end );
		else if( !IsDefined( alpha ) )
			Line( start, end, color );
		else if( !IsDefined( depthTest ) )
			Line( start, end, color, alpha );
		else if( !IsDefined( duration ) )
			Line( start, end, color, alpha, depthTest );
		else
			Line( start, end, color, alpha, depthTest, duration );
	}
}

JKUprint( msg, unique_tag )
{
	if( IsDefined( level.JKUdebug ) && level.JKUdebug )
	{
		IPrintLn( msg );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

reassign_goal_volume( guys, volume_name )
{
	Assert( IsDefined( guys ) );

	if ( !IsArray( guys ) )
	{
		guys = make_array( guys );
	}
	
	guys = array_removeDead_or_dying( guys );
	vol	 = GetEnt( volume_name, "targetname" );

	foreach ( guy in guys )
	{
		guy SetGoalVolumeAuto( vol );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemy_marker()
{
	follow_icon = NewHudElem();
	follow_icon SetShader( "apache_target_lock", 1, 1 );
	follow_icon.alpha = 0.0;
	follow_icon.color = ( 1, 0, 0 );
//	follow_icon SetTargetEnt( self );
	follow_icon SetWayPoint( true );
	
	clip_amount = self.bulletsinclip;
	LOS = false;
	timer = 1.00;
	time_step = .18;
	flicker = true;
	state = 0;
	state_off = 0;
	state_flicker = 1;
	state_on = 2;
	FOV_check = .2;
	weapon_firing = false;
	center_of_view = false;
	check_LOS = true;
	check_FOV = false;
	check_gunfire = false;
//	flicker = 0.0;
	while( IsAlive( self ) && IsAlive( level.player ) )
	{
		follow_icon.x = self GetTagOrigin( "j_spinelower" )[ 0 ];
		follow_icon.y = self GetTagOrigin( "j_spinelower" )[ 1 ];
		follow_icon.z = self GetTagOrigin( "j_spinelower" )[ 2 ];
		
		if(check_FOV)
		{
			if( level.player PlayerAds() == 1 )
			{
				FOV_check = .997;
			}
			else
			{
				FOV_check = .95;
			}
			
			if(player_looking_at(self.origin, FOV_check, true))
			{
				center_of_view = true;
			}
			else
			{
				center_of_view = false;
			}
		}
		
		if(check_LOS)
		{
			if(player_looking_at(self.origin, .2))
			{
				LOS = true;
			}
			else
			{
				LOS = false;
			}
		}
		
		if(check_gunfire)
		{
			if(self.bulletsinclip != clip_amount)
			{
				weapon_firing = true;
			}
			else
			{
				weapon_firing = false;	
			}
			clip_amount = self.bulletsinclip;
		}
		
		if(state == state_off)
		{
			if(LOS && ((center_of_view && check_FOV) || (weapon_firing && check_gunfire)))
			{
				state = state_flicker;
				timer = 1.00;
				flicker = true;
			}
			else
			{
				if(LOS && check_LOS)
				{
					state = state_on;
				}
				else
				{
					follow_icon.alpha = 0.00;	
				}
			}
		}

//if we want icon to flicker when enemy fires weapon
		if(state == state_flicker)
		{
			if(!LOS && check_LOS)
			{
				state = state_off;
			}
			else
			{
				if(timer > 0)
				{
					state = state_flicker;
					if(flicker)
					{
						follow_icon.alpha = 0.00;
						timer = timer - time_step;
						flicker = false;
					}
					else
					{
						follow_icon.alpha = 0.25;
						timer = timer - time_step;
						flicker = true;
					}
				}
				else
				{
					state = state_on;
				}
			}
		}
		
		if(state == state_on)
		{
			if(!LOS && check_LOS)
			{
				state = state_off;
			}
			else
			{
				if(weapon_firing && check_gunfire)
				{
					state = state_flicker;
					timer = 1.00;
				}
				else
				{
					state = state_on;
					follow_icon.alpha = 0.25;
				}
			}
		}

		
		waitframe();
	}

//	if(!IsAlive( self ))
//	{
//		level thread spawn_enemy_death_hud_element((follow_icon.x,follow_icon.y,follow_icon.z));
//	}
	
	follow_icon Destroy();
}

spawn_enemy_death_hud_element(hud_origin)
{
//	IPrintLn("trying to spawn death hud element");
	follow_icon = NewHudElem();
	follow_icon SetShader( "veh_hud_target_invalid", 1, 1 );
	follow_icon.alpha = 0.25;
	follow_icon.color = ( 1, 0, 0 );
	follow_icon.x = hud_origin[0];
	follow_icon.y = hud_origin[1];
	follow_icon.z = hud_origin[2];
	follow_icon SetWayPoint( true );
//	follow_icon.width = follow_icon.width * 2;
//	follow_icon.height= follow_icon.height * 2;
//	follow_icon ScaleOverTime(0.1, follow_icon.width * 2,follow_icon.height * 2);
	wait(1.0);
	follow_icon Destroy();	
	
	
}


