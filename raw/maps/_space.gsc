#include common_scripts\utility;
#include maps\_hud_util;

precache()
{
	PreCacheShader( "scubamask_overlay_delta" );
	PreCacheShader( "hud_space_helmet_overlay" );
	// PrecacheShader( "hud_xm25_temp" );
}

set_zero_gravity()
{
	//-- AFFECT PROPS & RAGDOLL --
	//SetSavedDvar( "phys_gravity", 0 );
	//SetSavedDvar( "phys_gravity_ragdoll", 0 );

	/*
	// This is some hacks right here. FOr the real deal, we'll probably want a code solution to microgravity ragdolls.
	SetSavedDvar ( "Ragdoll_max_life", 60000 );
	while ( 1 )
	{
		SetPhysicsGravityDir( (0,0, 0.01) );	
		wait 0.05;	
		SetPhysicsGravityDir( (0,0, -0.01) );	
		wait 0.05;	
	}
	*/
}

friendly_bubbles()
{
	self endon( "death" );
	self notify( "stop_friendly_bubbles" );
	self endon( "stop_friendly_bubbles" );
	self thread friendly_bubbles_cleanup();
	self thread friendly_bubbles_cleanup_on_death();
	
	tag = "TAG_EYE";
	self.scuba_org = spawn_tag_origin();
	self.scuba_org linkto( self, "tag_eye", (5,0,-6), (-90,0,0) );
	
	while ( true )
	{
		wait( 3.5 + randomfloat( 3 ) );
		playfxOnTag( getfx( "scuba_bubbles_friendly" ), self.scuba_org, "tag_origin" );
	}
}

friendly_bubbles_stop()
{
	self notify( "stop_friendly_bubbles" );
	self.scuba_org delete();
}

friendly_bubbles_cleanup_on_death()
{
	self waittill_either( "death", "stop_friendly_bubbles" );
	self.scuba_org delete();
}

friendly_bubbles_cleanup()
{
	self endon("death");
	self waittillmatch( "single anim", "surfacing" );
	self notify ( "stop_friendly_bubbles" );
}

player_space()
{
	//if coop splitscreen, only play scuba sound for player1 to avoid sound overlap
	if ( !isSplitscreen() )
		self thread player_space_breathe_sound();
	else
	{
		if ( self == level.player )
			self thread player_space_breathe_sound();
	}
	self thread player_scuba_bubbles();
}

player_space_breathe_sound()
{
	self endon("death");
	self endon( "disable_space" );
	self notify( "start_space_breathe" );
	self endon( "start_space_breathe" );
	self endon( "stop_space_breathe" );
	while ( true )
	{
		wait( 0.05 );
		self notify( "space_breathe_sound_starting" );
		//self playLocalSound( "scuba_breathe_player", "space_breathe_sound_done" );
		self waittill( "space_breathe_sound_done" );
	}
}

stop_player_space()
{
	self notify( "stop_space_breathe" );
	self stopLocalSound( "scuba_breathe_player" );
}

debug_org()
{
	while( true )
	{
		print3d( self.origin + ( 0, 0, 0 ), "ORG", ( 1, 1, 1 ), 1, 0.5 );
		wait( 0.5 );
	}
	
}

player_scuba_bubbles()
{
	self endon("death");
	self endon( "disable_space" );
	self endon( "stop_space_breathe" );
	waittillframeend;
	self.playerFxOrg = spawn( "script_model", self.origin + ( 0, 0, 0 ) );
	self.playerFxOrg setmodel( "tag_origin" );
	self.playerFxOrg.angles = self.angles;
	self.playerFxOrg.origin = self getEye() - ( 0,0,10 );
	self.playerFxOrg LinkToPlayerView( self, "tag_origin", ( 5, 0, -55 ), ( 0, 0, 0 ), true );

	self thread scuba_fx_cleanup( self.playerFxOrg );
	//self.playerFxOrg thread debug_org();
	while ( true )
	{
		self waittill( "space_breathe_sound_starting" );
		wait( 2.1 );
		//self thread player_bubbles_fx( self.playerFxOrg );
		if ( cointoss() )
			self waittill( "space_breathe_sound_starting" );
		/*
		wait( 6.2 );
		self thread player_bubbles_fx( self.playerFxOrg );
		wait( 6.5 );
		self thread player_bubbles_fx( self.playerFxOrg );
		wait( 7.5 );
		self thread player_bubbles_fx( self.playerFxOrg );
		wait( 6.8 );
		self thread player_bubbles_fx( self.playerFxOrg );
		wait( 6.5 );
		self thread player_bubbles_fx( self.playerFxOrg );
		self waittill( "space_breathe_sound_starting" );
		*/
	}
}

scuba_fx_cleanup( playerFxOrg )
{
	self waittill( "stop_space_breathe" );
	playerFxOrg UnlinkFromPlayerView( self );
	playerFxOrg delete();
}

player_bubbles_fx( playerFxOrg )
{
	self endon( "stop_space_breathe" );
	playfxontag( getfx( "scuba_bubbles" ), playerFxOrg, "TAG_ORIGIN" );
}

space_hud_enable( bool )
{
	wait 0.05;
	if ( bool == true )
	{
		//setsaveddvar( "ui_hidemap", 1 );
		SetSavedDvar( "hud_showStance", "0" );
		SetSavedDvar( "compass", "0" );
		//SetDvar( "old_compass", "0" );
		//SetSavedDvar( "ammoCounterHide", "1" );
		//setsaveddvar( "g_friendlyNameDist", 0 );
		//SetSavedDvar( "hud_showTextNoAmmo", "0" ); 
	}
	else
	{
		//setsaveddvar( "ui_hidemap", 0 );
		setSavedDvar( "hud_drawhud", "1" );
		SetSavedDvar( "hud_showStance", "1" );
		SetSavedDvar( "compass", "1" );
		//SetDvar( "old_compass", "1" );
		//SetSavedDvar( "ammoCounterHide", "0" );
		//setsaveddvar( "g_friendlyNameDist", 15000 );
		//SetSavedDvar( "hud_showTextNoAmmo", "1" ); 
	}
}

player_space_helmet( helmet_overlay )
{
	SetHUDLighting( true );
	
	//if ( IsDefined( helmet_overlay ) )
	{
		self.hud_space_helmet_rim = self create_client_overlay( "scubamask_overlay_delta", 1, self );
		self.hud_space_helmet_rim.foreground = false;
		self.hud_space_helmet_rim.sort = -99;
		// self.hud_space_helmet_overlay = self create_client_overlay( "hud_xm25_temp", 0.1, self );
		// self.hud_space_helmet_overlay.foreground = false;
		// self.hud_space_helmet_overlay.sort = -99;
		self.hud_space_helmet_overlay = self create_client_overlay( "hud_space_helmet_overlay", 1, self );
		self.hud_space_helmet_overlay.foreground = false;
		self.hud_space_helmet_overlay.sort = -99;
	}
	/*else
	{
		self.hud_space_helmet = Spawn( "script_model", level.player GetEye() );
		self.hud_space_helmet setModel( "shpg_viewmodel_scuba_mask" );
		self.hud_space_helmet LinkToPlayerView( level.player, "tag_origin", ( -1.2, 0, -2.63 ), ( 0, 0, 0 ), true );
	}
	*/
}

player_space_helmet_disable( helmet_overlay )
{
	SetHUDLighting( false );
	
	if ( IsDefined( self.hud_space_helmet_rim ) )
	{
		self.hud_space_helmet_rim destroyElem();
	}

	if ( IsDefined( self.hud_space_helmet_overlay ) )
	{
		self.hud_space_helmet_overlay destroyElem();
	}
	/*
	if ( IsDefined( self.hud_space_helmet_overlay2 ) )
	{
		self.hud_space_helmet_overlay2 destroyElem();
	}
	*/
}