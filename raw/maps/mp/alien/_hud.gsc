#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\alien\_persistence;
#include maps\mp\alien\_perk_utility;

//<TODO JC> When ship, all of those HUD elements should be replaced/handled by LUA

HUD_MAX_NUM_PLAYERS = 4; //The maximum number of players that the health bar HUD system supports

CONST_BONUS_HUD_DEFAULT_FONTSCALE = 1.25;
CONST_BONUS_HUD_FLASH_FONTSCALE = 1.75;
BONUS_HUD_DEFAULT_COLOR = ( 0, 0.5, 0 );
BONUS_HUD_FLASH_COLOR = ( 0.5, 1, 0 );


createPainOverlay()
{
	self.pain_overlay_left = makePainOverlay( "fullscreen_bloodsplat_left" );
	self.pain_overlay_right = makePainOverlay( "fullscreen_bloodsplat_right" );
}

makePainOverlay( shader)
{
	if ( IsAI( self ) )
		return;
	
	overlay = NewClientHudElem( self );
	overlay.x = 0;
	overlay.y = 0;
	overlay SetShader( shader, 640, 480 );
	overlay.splatter = true;
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 1;
	overlay.foreground = 0;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 0;
	
	return overlay;
}

create_hud_loot_count( xpos, ypos, label, scale )
{
	if( !IsDefined( scale ) )
	{
	   	scale = 1.0;
	}
	hud_counter = self maps\mp\gametypes\_hud_util::createFontString( "objective", scale );
	hud_counter maps\mp\gametypes\_hud_util::setPoint( "RIGHT", "CENTER", xpos, ypos );
	hud_counter.alpha = 1;
	hud_counter.color = (1,1,0);
	hud_counter.glowAlpha = 1;
	hud_counter.sort = 1;
	hud_counter.hideWhenInMenu = true;
	hud_counter.archived = true;
	hud_counter.label = label;
	
	return hud_counter;
}

create_gain_credit_hud( xpos, ypos, label )
{
	if ( isDefined ( self.gain_credit_message ) )
		return;
	
	self.gain_credit_message = create_hud_loot_count( xpos, ypos, label, 1.15 );
	self.gain_credit_message.alpha = 0;
}

update_self_revives_collected( xpos, ypos, loot_ref, label )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( !isdefined( self.hud_self_revives_count ) )
	{
		self.hud_self_revives_count = create_hud_loot_count( xpos, ypos, label );
	}
	
	// reset
	self.hud_self_revives_count setvalue( 0 );
	
	while ( true )
	{
		self waittill_any( "loot_pickup", "loot_removed" );
		
		count = self maps\mp\alien\_collectibles::get_loot_count( loot_ref );
		
		self.hud_self_revives_count setvalue( count );
	}
}

update_yellow_eggs_collected( xpos, ypos, loot_ref, label )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( !isdefined( self.hud_yellow_egg_count ) )
	{
		self.hud_yellow_egg_count = create_hud_loot_count( xpos, ypos, label, 1 );
	}
	
	// reset
	self.hud_yellow_egg_count setvalue( 0 );
	
	while ( true )
	{
		self waittill_any( "loot_pickup", "loot_removed" );
		
		count = self maps\mp\alien\_collectibles::get_loot_count( loot_ref );
		
		self.hud_yellow_egg_count setvalue( count );
	}
}

update_health_packs_collected( xpos, ypos, loot_ref, label )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( !isdefined( self.hud_health_pack_count ) )
	{
		self.hud_health_pack_count = create_hud_loot_count( xpos, ypos, label, 1 );
	}
	
	// reset
	self.hud_health_pack_count setvalue( 0 );
	
	while ( true )
	{
		self waittill_any( "loot_pickup", "loot_removed" );
		
		count = self maps\mp\alien\_collectibles::get_loot_count( loot_ref );
		
		self.hud_health_pack_count setvalue( count );
	}
}

update_red_eggs_collected( xpos, ypos, loot_ref, label )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( !isdefined( self.hud_red_egg_count ) )
	{
		self.hud_red_egg_count = create_hud_loot_count( xpos, ypos, label );
	}
	
	// reset
	self.hud_red_egg_count setvalue( 0 );
	
	while ( true )
	{
		self waittill_any( "loot_pickup", "loot_removed" );
		
		count = self maps\mp\alien\_collectibles::get_loot_count( loot_ref );
		
		self.hud_red_egg_count setvalue( count );
	}
}

update_purple_eggs_collected( xpos, ypos, loot_ref, label )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( !isdefined( self.hud_purple_egg_count ) )
	{
		self.hud_purple_egg_count = create_hud_loot_count( xpos, ypos, label );
	}
	
	// reset
	self.hud_purple_egg_count setvalue( 0 );
	
	while ( true )
	{
		self waittill_any( "loot_pickup", "loot_removed" );
		
		count = self maps\mp\alien\_collectibles::get_loot_count( loot_ref );
		
		self.hud_purple_egg_count setvalue( count );
	}
}

update_blue_eggs_collected( xpos, ypos, loot_ref, label )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( !isdefined( self.hud_blue_egg_count ) )
	{
		self.hud_blue_egg_count = create_hud_loot_count( xpos, ypos, label );
	}
	
	// reset
	self.hud_blue_egg_count setvalue( 0 );
	
	while ( true )
	{
		self waittill_any( "loot_pickup", "loot_removed" );
		
		count = self maps\mp\alien\_collectibles::get_loot_count( loot_ref );
		
		self.hud_blue_egg_count setvalue( count );
	}
}

update_shock_ammo_collected( xpos, ypos, loot_ref, label )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( !isdefined( self.hud_shock_ammo ) )
	{
		self.hud_shock_ammo = create_hud_loot_count( xpos, ypos, label );
	}
	
	// reset
	self.hud_shock_ammo setvalue( 0 );
	
	while ( true )
	{
		self waittill_any( "loot_pickup", "loot_removed" );
		
		count = self maps\mp\alien\_collectibles::get_loot_count( loot_ref );
		
		self.hud_shock_ammo setvalue( count );
	}
}

playPainOverlay( damage_direction )
{
	if ( isDefined ( damage_direction ) )
	{
		damage_direction *= -1;  //change direction to be based on the player's view
		self_right = anglesToRight( self.angles );
		
		damage_from_right = VectorDot( damage_direction, self_right ) > 0;
	}
	else
	{
		damage_from_right = common_scripts\utility::cointoss();
	}
		
	if ( damage_from_right )
		play_right_pain_overlay();
	else
		play_left_pain_overlay();	
}

play_right_pain_overlay()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self notify( "kill_right_pain" );
	self endon( "kill_right_pain" );
	
	self.pain_overlay_right.alpha = 1;
	self.pain_overlay_right fadeOverTime( 2 );
	self.pain_overlay_right.alpha = 0;
}

play_left_pain_overlay()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self notify( "kill_left_pain" );
	self endon( "kill_left_pain" );
	
	self.pain_overlay_left.alpha = 1;
	self.pain_overlay_left fadeOverTime( 2 );
	self.pain_overlay_left.alpha = 0;
}

makeFriendlyHeadIcon()
{
	friendiconParams = SpawnStruct();
	friendiconParams.showTo = self.team;
	friendiconParams.icon = "cb_compassping_aliens_friendly";
	friendiconParams.offset = ( 0, 0, 64 );
	friendiconParams.width = 1;
	friendiconParams.height = 1;
	friendiconParams.archived = false;
	friendiconParams.delay = 0.05;
	friendiconParams.constantSize = false;
	friendiconParams.pinToScreenEdge = true;
	friendiconParams.fadeOutPinnedIcon = false;
	friendiconParams.is3D = false;
	self.friendiconParams = friendiconParams;
	
	self maps\mp\_entityheadIcons::setHeadIcon( 
		friendiconParams.showTo, 
		friendiconParams.icon, 
		friendiconParams.offset, 
		friendiconParams.width, 
		friendiconParams.height, 
		friendiconParams.archived, 
		friendiconParams.delay, 
		friendiconParams.constantSize, 
		friendiconParams.pinToScreenEdge, 
		friendiconParams.fadeOutPinnedIcon,
		friendiconParams.is3D );
}

//===========================================
// 			lastStandTimerAlien
//===========================================
lastStandTimerAlien( bleedout_time )
{	
	timer_offset = 90;
	if ( !issplitscreen() )
		timer_offset = 135;

	timer = self maps\mp\gametypes\_hud_util::createTimer( "hudsmall", 1.2 );
	timer maps\mp\gametypes\_hud_util::setPoint( "CENTER", undefined, 0, timer_offset );
	timer setTimer( bleedout_time - 1 );
	
	self thread lastStandTimerCleanupAlien( timer );
	
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "revive" );
	level endon( "game_ended" );
	
	wait( bleedout_time );
	
	lastStandTimerDestroyAlien( timer );
}

//===========================================
// 			lastStandTimerCleanupAlien
//===========================================
lastStandTimerCleanupAlien( timer )
{
	self thread lastStandTimerCleanupLevelAlien( timer );
	level endon( "game_ended" );
	self waittill_any( "death", "disconnect", "revive" );
	lastStandTimerDestroyAlien( timer );
}

//===========================================
// 			lastStandTimerCleanupLevelAlien
//===========================================
lastStandTimerCleanupLevelAlien( timer )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "revive" );
	level waittill( "game_ended" );
	lastStandTimerDestroyAlien( timer );
}

//===========================================
// 			lastStandTimerDestroyAlien
//===========================================
lastStandTimerDestroyAlien( timer )
{
	if ( !IsDefined( timer ) )
		return;
	
	timer notify( "destroying" );
	timer destroyElem();
}

//===========================================
// 			lastStandUpdateReviveIconColorAlien
//===========================================
lastStandUpdateReviveIconColorAlien( reviveEnt, reviveIcon, bleedOutTime )
{
	self endon( "disconnect" );
	self endon( "revive" );
	level endon( "game_ended" );
	
	self playDeathSound();

	wait bleedOutTime / 3;
	reviveIcon.color = (1.0, 0.64, 0.0);
	
	while ( reviveEnt.inUse )
		wait ( 0.05 );
	
	self playDeathSound();	
	
	wait bleedOutTime / 3;
	reviveIcon.color = (1.0, 0.0, 0.0);

	while ( reviveEnt.inUse )
		wait ( 0.05 );

	self playDeathSound();
}

makeReviveIcon( color )
{
	reviveIcon = newTeamHudElem( self.team );
	reviveIcon setShader( "waypoint_alien_revive", 8, 8 );
	reviveIcon setWaypoint( true, true );
	reviveIcon SetTargetEnt( self );
	reviveIcon.color = color;
	
	reviveIcon thread deleteReviveIcon( self );
	
	return reviveIcon;
}

deleteReviveIcon( owner )
{
	self endon ( "death" );
	
	owner waittill_any( "disconnect", "revive" );
	self ClearTargetEnt();
	self destroy();
}

createBonusInfoHUD()
{
	createTeamBonusInfoHUD();
	createPersonalBonusInfoHUD();
	createTotalBonusInfoHUD();
}

createTeamBonusInfoHUD()
{
	if ( isDefined ( self.team_bonus_info ) )
		return;
	
	self.team_bonus_info = create_bonus_info_hud( 185, 10, &"ALIEN_COLLECTIBLES_TEAM_BONUS", CONST_BONUS_HUD_DEFAULT_FONTSCALE );
}

createPersonalBonusInfoHUD()
{
	if ( isDefined ( self.personal_bonus_info ) )
		return;
	
	self.personal_bonus_info = create_bonus_info_hud( 150, 27, &"ALIEN_COLLECTIBLES_PERSONAL_BONUS", CONST_BONUS_HUD_DEFAULT_FONTSCALE );
}

createTotalBonusInfoHUD()
{
	if ( isDefined ( self.total_bonus_info ) )
		return;
	
	self.total_bonus_info = create_bonus_info_hud( 180, 44, &"ALIEN_COLLECTIBLES_TOTAL_BONUS", CONST_BONUS_HUD_DEFAULT_FONTSCALE );
}

create_bonus_info_hud( xpos, ypos, label, scale )
{
	hud_counter = self maps\mp\gametypes\_hud_util::createFontString( "objective", scale );
	hud_counter maps\mp\gametypes\_hud_util::setPoint( "LEFT", "TOP", xpos, ypos );
	hud_counter.alpha = 0;
	hud_counter.color = BONUS_HUD_DEFAULT_COLOR;
	hud_counter.glowAlpha = 1;
	hud_counter.sort = 1;
	hud_counter.hideWhenInMenu = true;
	hud_counter.archived = true;
	hud_counter.label = label;
	
	return hud_counter;
}

show_team_bonus( value )
{
	childthread flash_bonus( value, self.team_bonus_info, true );
}

show_personal_bonus( value )
{
	childthread flash_bonus( value, self.personal_bonus_info, true );
}

show_total_bonus( value )
{
	childthread flash_bonus( value, self.total_bonus_info, false );
}

flash_bonus( value, hud_element, back_to_original_color )
{
	hud_element setValue( value );
	hud_element.fontscale = CONST_BONUS_HUD_DEFAULT_FONTSCALE;
	hud_element.color = BONUS_HUD_DEFAULT_COLOR;
	hud_element.alpha = 1;
	wait( 0.2 );
	hud_element.fontscale = CONST_BONUS_HUD_FLASH_FONTSCALE;
	hud_element.color = BONUS_HUD_FLASH_COLOR;
	wait( 0.6 );
	hud_element.fontscale = CONST_BONUS_HUD_DEFAULT_FONTSCALE;
	
	if ( back_to_original_color )
		hud_element.color = BONUS_HUD_DEFAULT_COLOR;
}

hide_all_bonus()
{
	self.team_bonus_info.alpha = 0;
	self.personal_bonus_info.alpha = 0;
	self.total_bonus_info.alpha = 0;
}

wait_for_impact()
{
	level endon( "game_ended" );
	
	self waittill( "death" );
	
	level notify( "rod_of_god_impact" );
}

display_all_bonus()
{
	team_bonus = maps\mp\alien\_gamescore::get_team_bonus();
	foreach( player in level.players )
	{
		personal_bonus = player maps\mp\alien\_gamescore::get_personal_bonus(); 
		
		player thread show_all_bonus( team_bonus, personal_bonus );
		total_bonus = team_bonus + personal_bonus;
		
		player maps\mp\alien\_gamescore::givePlayerScore( total_bonus );
		
		player thread give_xp_and_currency( total_bonus );
	}
}

give_xp_and_currency( total_bonus )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self waittill_any_timeout( 10, "total_bonus_displayed" );
	
	// give XP
	self give_player_xp( int(total_bonus) );
	
	// give money
	self give_player_currency( int(total_bonus * perk_GetCurrencyScalePerHive()) );
}

show_all_bonus( team_bonus, personal_bonus )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	level waittill_any_timeout( 5.0, "rod_of_god_impact" ); 
	childthread show_team_bonus( team_bonus );
	
	level waittill_any_timeout( 5.0, "rod_of_god_impact" ); 
	childthread show_personal_bonus( personal_bonus );

	level waittill_any_timeout( 5.0, "rod_of_god_impact" ); 
	childthread show_total_bonus( team_bonus + personal_bonus );
	
	self notify( "total_bonus_displayed" );
	
	wait( 5.0 );
	maps\mp\alien\_hud::hide_all_bonus();
}

create_drill_timer_hud( hud_ref, text, slot )
{
	level.drill_HUD[ hud_ref ] = createServerTimer( "objective", 1.4 );	
	level.drill_HUD[ hud_ref ].label = text;
	
	y_offset = slot * 20;
	
	if ( level.splitscreen )
		level.drill_HUD[ hud_ref ] setPoint( "TOPLEFT", "TOPLEFT", 10, y_offset );
	else
		level.drill_HUD[ hud_ref ] setPoint( "TOPLEFT", "TOPLEFT", 45, 5 + y_offset );
	
	level.drill_HUD[ hud_ref ].color = ( 1, 1, 1 );
	level.drill_HUD[ hud_ref ].alpha = 0;
	level.drill_HUD[ hud_ref ].archived = false;
	level.drill_HUD[ hud_ref ].hideWhenInMenu = true;

	thread hideHudElementOnGameEnd( level.drill_HUD[ hud_ref ] );
}


hideHudElementOnGameEnd( hudElement )
{
	level waittill("game_ended");
	if ( isDefined( hudElement ) )
		hudElement.alpha = 0;
}
