#include common_scripts\utility;
#include maps\_hud_util;

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

player_scuba()
{
	//if coop splitscreen, only play scuba sound for player1 to avoid sound overlap
	if ( !isSplitscreen() )
		self thread player_scuba_breathe_sound();
	else
	{
		if ( self == level.player )
			self thread player_scuba_breathe_sound();
	}
	self thread player_scuba_bubbles();
}

player_scuba_breathe_sound()
{
	self endon("death");
	self notify( "start_scuba_breathe" );
	self endon( "start_scuba_breathe" );
	self endon( "stop_scuba_breathe" );
	while ( true )
	{
		wait( 0.05 );
		self notify( "scuba_breathe_sound_starting" );
		
		if (self IsSprinting())
			self playLocalSound( "scuba_breathe_player_sprint", "scuba_breathe_sound_done" );
		else
			self playLocalSound( "scuba_breathe_player", "scuba_breathe_sound_done" );
		
		self waittill( "scuba_breathe_sound_done" );
	}
}

stop_player_scuba()
{
	self notify( "stop_scuba_breathe" );
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
	self endon( "stop_scuba_breathe" );
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
		self waittill( "scuba_breathe_sound_starting" );
		wait( 2.1 );
		self thread player_bubbles_fx( self.playerFxOrg );
		if ( cointoss() )
			self waittill( "scuba_breathe_sound_starting" );
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
		self waittill( "scuba_breathe_sound_starting" );
		*/
	}
}

scuba_fx_cleanup( playerFxOrg )
{
	self waittill( "stop_scuba_breathe" );
	playerFxOrg UnlinkFromPlayerView( self );
	playerFxOrg delete();
}

player_bubbles_fx( playerFxOrg )
{
	self endon( "stop_scuba_breathe" );
	playfxontag( getfx( "scuba_bubbles" ), playerFxOrg, "TAG_ORIGIN" );
}

underwater_hud_enable( bool )
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

player_scuba_mask( mask_overlay, overlay_override )
{
	SetHUDLighting( true );
	
	overlay = "halo_overlay_scuba";
		
	if ( IsDefined( overlay_override ) )
	{
		overlay = overlay_override;
	}
	
	self.hud_scubaMask = self create_client_overlay( overlay, 1, self );
	self.hud_scubaMask.foreground = false;
	self.hud_scubaMask.sort = -99;
	
	self.scubaMask_distortion = Spawn("script_model",level.player.origin);
	self.scubaMask_distortion setModel( "tag_origin" );
	self.scubaMask_distortion.origin = self.origin;
	self.scubaMask_distortion LinkToPlayerView( self, "tag_origin", ( 10, 0, 0 ), ( 0, 180, 0 ), true );
	PlayFXOnTag( getfx( "scuba_mask_distortion" ), self.scubaMask_distortion, "tag_origin" );
	
    self.hud_scubaMask_model = Spawn( "script_model", level.player GetEye() );
    self.hud_scubaMask_model setModel( "shpg_udt_headgear_player_a" );
    self.hud_scubaMask_model LinkToPlayerView( self, "tag_origin", ( -0.3, 0, -1.2 ), ( 0, 90, -4 ), true );
}

player_scuba_mask_disable( mask_overlay )
{
	SetHUDLighting( false );
	
	if ( IsDefined( self.hud_scubaMask ) )
	{
		self.hud_scubaMask destroyElem();
		self.scubaMask_distortion UnlinkFromPlayerView( self );
		self.scubaMask_distortion delete();
		self.hud_scubaMask_model UnlinkFromPlayerView( self );
		self.hud_scubaMask_model delete();
	}
}