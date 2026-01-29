#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PreCacheShader( "nightvision_overlay_goggles" );

	PreCacheShader( "halo_overlay_frost" );
	PreCacheShader( "halo_overlay_water" );
	PreCacheShader( "raindrop_overlay" );
	PreCacheShader( "raindrop_overlay2" );
	PreCacheShader( "raindrop_splat_overlay" );
	PreCacheShader( "raindrop_splat_overlay2" );

	PreCacheShader( "hud_rog_altimeter_bracket_l" );
	PreCacheShader( "hud_rog_altimeter_bracket_r" );
	PreCacheShader( "hud_rog_altimeter_num_box" );
	PreCacheShader( "hud_rog_altimeter_pip" );
	PreCacheShader( "hud_rog_altimeter_ruler" );
	PreCacheShader( "hud_rog_altimeter_ruler_bot" );
	PreCacheShader( "hud_rog_altimeter_ruler_warning_area" );
	PreCacheShader( "hud_rog_altimeter_ruler_warning_fill" );
	PreCacheShader( "hud_rog_altimeter_text" );
	PreCacheShader( "hud_rog_ammo" );
	PreCacheShader( "hud_rog_ammo_bg" );
	PreCacheShader( "hud_rog_fluff_0" );
	PreCacheShader( "hud_rog_fluff_1" );
	PreCacheShader( "hud_rog_fluff_bot" );
	PreCacheShader( "hud_rog_fluff_rect" );
	PreCacheShader( "hud_rog_overlay" );
	PreCacheShader( "hud_rog_reticle" );
	PreCacheShader( "hud_rog_zoom_box" );
	PreCacheShader( "hud_rog_zoom_box_tick" );
	PreCacheShader( "hud_rog_zoom_meter" );
	PreCacheShader( "hud_rog_zoom_meter_tick" );
	
	PreCacheShader( "hud_rog_target_dot_group_0_g" );
	PreCacheShader( "hud_rog_target_dot_group_0_r" );
	PreCacheShader( "hud_rog_target_dot_group_1_g" );
	PreCacheShader( "hud_rog_target_dot_group_1_r" );
	PreCacheShader( "hud_rog_target_dot_group_2_g" );
	PreCacheShader( "hud_rog_target_dot_group_2_r" );
	PreCacheShader( "hud_rog_target_building_g" );
	PreCacheShader( "hud_rog_target_building_r" );
	PreCacheShader( "hud_rog_target_g" );
	PreCacheShader( "hud_rog_target_r" );
	PreCacheShader( "hud_rog_target_vehicle_a_g" );
	PreCacheShader( "hud_rog_target_vehicle_a_r" );
	PreCacheShader( "hud_rog_target_vehicle_b_g" );
	PreCacheShader( "hud_rog_target_vehicle_b_r" );
	PreCacheShader( "ac130_hud_target_offscreen" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_screen_shake()
{
	level endon( "ROG_end" );

	duration		 = 0.05;
	fade_in			 = 0.0;
	fade_out		 = 0.0;
	radius			 = 90;
	scale[ "pitch" ] = 5;
	scale[ "yaw"   ] = 7;
	scale[ "roll"  ] = 2;
	freq [ "pitch" ] = 4;
	freq [ "yaw"   ] = 7;
	freq [ "roll"  ] = 1;
	expo			 = 1.5;

	ads_frac = 0.0;
	prev_ads_frac = ads_frac;
	increasing = false;
	decreasing = false;

	while( true )
	{
		while( flag( "starting_anim_done" ) )
		{
			ads_frac = level.player PlayerAds();
			if ( prev_ads_frac == ads_frac )
			{
				increasing = false;
				decreasing = false;
			}
			else
			{
				if ( prev_ads_frac > ads_frac )
				{
					increasing = false;
					decreasing = true;
				}
				else
				{
					increasing = true;
					decreasing = false;
				}
			}
			prev_ads_frac = ads_frac;
	
			if ( decreasing && ads_frac < 0.85 )
			{
				// high setting
				//IPrintLn( "setting high camara shake" );
				scale[ "pitch" ] = 2;
				scale[ "yaw"   ] = 5;
				scale[ "roll"  ] = 2;
				freq [ "pitch" ] = 3;
				freq [ "yaw"   ] = 4;
				freq [ "roll"  ] = 1;
				expo			 = 2.0;
				//level.player DisableSlowAim();
			}
	
			if ( increasing && ads_frac > 0.4 )
			{
				// low setting
				//IPrintLn( "setting low camara shake" );
				scale[ "pitch" ] = 5;
				scale[ "yaw"   ] = 4;
				scale[ "roll"  ] = 10;
				freq [ "pitch" ] = 2;
				freq [ "yaw"   ] = 3;
				freq [ "roll"  ] = 1;
				expo			 = 2.4;
				//level.player EnableSlowAim( 0.2, 0.1 );
			}
	
			if ( flag( "force_low_camera_shake" ) )
			{
				scale[ "pitch" ] = 5;
				scale[ "yaw"   ] = 4;
				scale[ "roll"  ] = 10;
				freq [ "pitch" ] = 2;
				freq [ "yaw"   ] = 3;
				freq [ "roll"  ] = 1;
				expo			 = 2.4;
			}
	
			level.player ScreenShakeOnEntity( scale[ "pitch" ], scale[ "yaw" ], scale[ "roll" ], duration, fade_in, fade_out, radius, freq[ "pitch" ], freq[ "yaw" ], freq[ "roll" ], expo );
			wait( 0.05 );
			//level.player ShellShock( "default", 1.0 );
			//wait( 1.0 );
		}

		flag_wait( "starting_anim_done" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_vision()
{
	level thread ROG_hud_effects();
	
	level.hud_static_overlay = maps\_hud_util::create_client_overlay( "nightvision_overlay_goggles", 0.5 );

	//thread maps\loki_fx::ROG_cam_fx();
	
	// Uncomment when the time is right
	//level.hud_static_overlay Destroy();
	//level.hud_static_overlay = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_hud()
{
	level thread ROG_setup_ammo_counter_hud();
	level thread ROG_setup_altimeter_hud();
	level thread ROG_setup_zoom_hud();
	level thread ROG_setup_static_hud();
	level thread ROG_setup_temp_hud();

	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	SetSavedDvar( "player_spaceViewHeight", 60 );
	SetSavedDvar( "player_spaceCapsuleHeight", 70 );

	//level.player thread ROG_cursor_logic();
	//level.ROG_cam_reticle ScaleOverTime( 5, 700, 700 );

	level waittill( "ROG_end" );

	ROG_cleanup_ammo_counter_hud();
	ROG_cleanup_altimeter_hud();
	ROG_cleanup_zoom_hud();
	ROG_cleanup_static_hud();
	ROG_cleanup_temp_hud();

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", 0 );
	SetSavedDvar( "actionSlotsHide", 0 );
	SetSavedDvar( "hud_showStance", 1 );
	SetSavedDvar( "player_spaceViewHeight", 11 );
	SetSavedDvar( "player_spaceCapsuleHeight", 30 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_hud_logic_reset()
{
	level thread ROG_altimeter_hud_logic();
	level thread ROG_ammo_counter_hud_logic();
	level thread ROG_temp_hud_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_hud_effects()
{
	//transition to cloud layer 2 vision set
	//VisionSetNaked("halo_cloudlayer2",1);
	//SetHUDLighting( true );

	//Start Rain Drops
	level.player delayThread( 5.0, ::raindrops_overlay );

	elem			= NewClientHudElem( level.player );
	elem.x			= 0;
	elem.y			= 0;
	elem.horzAlign	= "fullscreen";
	elem.vertAlign	= "fullscreen";
	elem.foreground = false;
	elem.sort		= -2;
	elem SetShader( "halo_overlay_frost", 640, 480 );
	elem.alpha = 0;
	elem FadeOverTime( 15.0 );
	elem.alpha					 = 0.5;
	level.ROG_effects[ "frost" ] = elem;

	elem			= NewClientHudElem( level.player );
	elem.x			= 0;
	elem.y			= 0;
	elem.horzAlign	= "fullscreen";
	elem.vertAlign	= "fullscreen";
	elem.foreground = false;
	elem.sort		= -2;
	elem SetShader( "halo_overlay_water", 640, 480 );
	elem.alpha = 0;
	elem FadeOverTime( 15.0 );
	elem.alpha					 = 0.5;
	level.ROG_effects[ "water" ] = elem;

	//add bob to raindrops
	//thread bob_mask(self.halomask_water_overlay);
}
raindrops_overlay(maxscale, minscale, maxtime, maxnum, rainfrequency,center_threshold)
{
	//defining preset values if not explicitly passed through
	if ( !IsDefined( maxscale ) ) maxscale				   = 2;											  //maximum scale of raindrop
	if ( !IsDefined( minscale ) ) minscale				   = 1;											  //minimum scale of raindrop
	if ( !IsDefined( maxtime ) ) maxtime				   = 2;											  //maximum time the raindrop stays on screen
	if ( !IsDefined( maxnum ) ) maxnum					   = 30;										  //maximum number of raindrops on screen
	if ( !IsDefined( rainfrequency ) ) rainfrequency	   = 0.3;										  //how often new raindrops get created
	if ( !IsDefined( center_threshold ) ) center_threshold = 100;										  //how close drops get created to screen center
	rainmaterials										   = [ "raindrop_overlay", "raindrop_overlay2" ]; //array containing different rain materials
	
	initialscale = 30; //initial scale of raindrop HUD ent
	level.numdrops = 0;//number of drops on screen
	screencenter = (320,240,0);//screen center

	while( true )
	{
		wait RandomFloatRange(0.1,rainfrequency);
				
		if(level.numdrops < maxnum)
		{
			newx   = RandomIntRange( 0, 640 );
			newy   = RandomIntRange( 0, 480 );
			newpos = ( newx, newy, 0 );
			
			if ( Distance2D( screencenter, newpos ) >= center_threshold )
			{
			dropshader						  = rainmaterials[ RandomIntRange( 0, rainmaterials.size ) ]; //drops will use random shader in array
			self.raindrop_hud_elem			  = NewClientHudElem( self );
			self.raindrop_hud_elem.x		  = newx;
			self.raindrop_hud_elem.y		  = newy;
			self.raindrop_hud_elem.foreground = false;
			self.raindrop_hud_elem.sort		  = -2;														  // trying to be behind introscreen_generic_black_fade_in
			dropscale						  = initialscale * RandomIntRange( minscale, maxscale );
			self.raindrop_hud_elem SetShader( dropshader, dropscale, dropscale );
			self.raindrop_hud_elem.alpha = 1.0;	
			
			self thread moveraindrop( self.raindrop_hud_elem, maxtime, dropscale );
			self thread addrainsplat( newpos, dropscale );		
			
			level.numdrops++; //increment total number of drops	
			}
		}
	}	
}
moveraindrop( drop, maxtime, dropscale )
{
	transformtime	   = RandomFloatRange( Float( maxtime / 2 ), maxtime );
	screencenter	   = ( 320, 240, 0 );
	hudelement		   = ( drop.x, drop.y, 0 );
	distancefromcenter = Distance2D( screencenter, hudelement );
	maxtranslation	   = 200; //longest distance the drop will travel
	newposition		   = VectorNormalize( hudelement - screencenter );
	
	//scale down the raindrop 
	drop ScaleOverTime( transformtime, Int( dropscale * 0.75 ), Int( dropscale * 0.75 ) );
	//fade the raindrop 
	drop FadeOverTime( transformtime );
	drop.alpha = 0.7;
	//move the raindrop along vector based on center screen
	drop MoveOverTime( transformtime );
	drop.x += newposition[ 0 ] * maxtranslation;
	drop.y += newposition[ 1 ] * maxtranslation;
	
		
	wait transformtime;
	drop Destroy();
	level.numdrops--;
}
addrainsplat( position, scale )
{
	newy = int(position[1]-(scale/2));
	newx = int(position[0]-(scale/2));
	splatmaterials = ["raindrop_splat_overlay","raindrop_splat_overlay2"];
	splatshader=splatmaterials[RandomIntRange(0,splatmaterials.size)];
	//Add Splat
	raindrop_splat = NewClientHudElem(self);
	raindrop_splat.x = newx;
	raindrop_splat.y = newy;
	raindrop_splat.foreground = false;
	raindrop_splat.sort = -2; // trying to be behind introscreen_generic_black_fade_in	
	raindrop_splat SetShader(splatshader,int(scale*RandomIntRange(1,3)),int(scale*RandomIntRange(1,3)));
	raindrop_splat.alpha = RandomFloatRange(0.7,1.0);
	raindrop_splat	FadeOverTime(2);
	raindrop_splat.alpha = 0;
	wait 3;
	raindrop_splat Destroy();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_setup_static_hud()
{
	level.ROG_static_ui = [];

	element			  = NewHudElem();
	element.x		  = 0;
	element.y		  = 0;
	element.alignx	  = "center";
	element.aligny	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.45;
	element SetShader( "hud_rog_reticle", 170, 170 );
	level.ROG_static_ui[ "reticle" ] = element;

	element			  = NewHudElem();
	element.x		  = -264;
	element.y		  = -8;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_altimeter_bracket_l", 96, 344 );
	level.ROG_static_ui[ "bracket_l" ] = element;

	element			  = NewHudElem();
	element.x		  = 264;
	element.y		  = -9;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_altimeter_bracket_r", 96, 344 );
	level.ROG_static_ui[ "bracket_r" ] = element;

	element			   = NewHudElem();
	element.x		   = 0;
	element.y		   = 0;
	element.horzAlign  = "fullscreen";
	element.vertAlign  = "fullscreen";
	element.foreground = false;
	element.alpha	   = 1.0;
	element.sort	  = -20;
	element SetShader( "hud_rog_overlay", 640, 480 );
	level.ROG_static_ui[ "overlay" ] = element;

	element			  = NewHudElem();
	element.x		  = 330;
	element.y		  = -170;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.25;
	element SetShader( "hud_rog_fluff_0", 64, 96 );
	level.ROG_static_ui[ "fluff_0" ] = element;

	element			  = NewHudElem();
	element.x		  = 300;
	element.y		  = 106;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_fluff_1", 48, 12 );
	level.ROG_static_ui[ "fluff_1" ] = element;

	element			  = NewHudElem();
	element.x		  = 0;
	element.y		  = 210;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_fluff_bot", 320, 19 );
	level.ROG_static_ui[ "fluff_bot" ] = element;
	
	element			  = NewHudElem();
	element.elemType  = "font";
	element.color	  = ( 1, 1, 1 );
	element.font	  = "objective";
	element.fontscale = 1.5;
	element.x		  = -1;
	element.y		  = 193;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetText( "0000" );
	level.ROG_static_ui[ "fluff_bot_num" ] = element;

	element			  = NewHudElem();
	element.x		  = -190;
	element.y		  = -214;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_fluff_rect", 80, 8 );
	level.ROG_static_ui[ "fluff_rect_tl" ] = element;

	element			  = NewHudElem();
	element.x		  = 190;
	element.y		  = -214;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_fluff_rect", 80, 8 );
	level.ROG_static_ui[ "fluff_rect_tr" ] = element;

	element			  = NewHudElem();
	element.x		  = -190;
	element.y		  = 214;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_fluff_rect", 80, 8 );
	level.ROG_static_ui[ "fluff_rect_bl" ] = element;

	element			  = NewHudElem();
	element.x		  = 190;
	element.y		  = 214;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.35;
	element SetShader( "hud_rog_fluff_rect", 80, 8 );
	level.ROG_static_ui[ "fluff_rect_br" ] = element;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_cleanup_static_hud()
{
	foreach( element in level.ROG_static_ui )
	{
		element Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_setup_ammo_counter_hud()
{
	level.ROG_ammo_ui = [];

	element			  = NewHudElem();
	element.x		  = 182;
	element.y		  = 150;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 0 ] = element;

	element			  = NewHudElem();
	element.x		  = 168;
	element.y		  = 156;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 1 ] = element;

	element			  = NewHudElem();
	element.x		  = 196;
	element.y		  = 156;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 2 ] = element;

	element			  = NewHudElem();
	element.x		  = 163;
	element.y		  = 172;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 3 ] = element;

	element			  = NewHudElem();
	element.x		  = 205;
	element.y		  = 171;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 4 ] = element;

	element			  = NewHudElem();
	element.x		  = 169;
	element.y		  = 186;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 5 ] = element;

	element			  = NewHudElem();
	element.x		  = 197;
	element.y		  = 185;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 6 ] = element;

	element			  = NewHudElem();
	element.x		  = 183;
	element.y		  = 193;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_ammo", 19, 20 );
	level.ROG_ammo_ui[ 7 ] = element;

	element			  = NewHudElem();
	element.x		  = 183;
	element.y		  = 172;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.3;
	element SetShader( "hud_rog_ammo_bg", 90, 90 );
	level.ROG_ammo_ui[ "bg" ] = element;

	element			  = NewHudElem();
	element.elemType  = "font";
	element.color	  = ( 1, 1, 1 );
	element.font	  = "objective";
	element.fontscale = 1.7;
	element.x		  = 190;
	element.y		  = 171;
	element.alignX	  = "right";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element SetText( level.ROG_num_rods );
	level.ROG_ammo_ui[ "count" ] = element;

	level thread ROG_ammo_counter_hud_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_cleanup_ammo_counter_hud()
{
	foreach( element in level.ROG_ammo_ui )
	{
		element Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_ammo_counter_hud_logic()
{
	level notify( "ROG_ammo_counter_restart" );
	level endon( "ROG_ammo_counter_restart" );

	ammo = level.ROG_num_rods;
	
	// reset
	for ( index = 0; index < level.ROG_num_rods; index++ )
	{
		level.ROG_ammo_ui[ index ].alpha = 1.0;
	}
	level.ROG_ammo_ui[ "count" ] SetText( Int( ammo ) );

	// now we wait for updates
	while( true )
	{
		level.player waittill( "ROG_fired" );

		ammo--;
		level.ROG_ammo_ui[ "count" ] SetText( Int( ammo ) );
		for ( index = 0; index < level.ROG_num_rods; index++ )
		{
			if( level.ROG_ammo_ui[ index ].alpha > 0.5 )
			{
				level.ROG_ammo_ui[ index ].alpha = 0.0;
				break;
			}
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_setup_altimeter_hud()
{
	level.ROG_altimeter_ui_static		 = [];
	level.ROG_altimeter_ui_dynamic		 = [];
	level.ROG_altimeter_start_value		 = 100000;
	level.ROG_altimeter_end_value		 = 829;
	level.ROG_altimeter_delta			 = abs( level.ROG_altimeter_end_value - level.ROG_altimeter_start_value );
  // game units Delta				   = ~230367
	level.ROG_altimeter_game_world_delta = 230367;
	level.EOG_altimeter_conv_ratio		 = level.ROG_altimeter_delta / level.ROG_altimeter_game_world_delta;

	level.ROG_alt_ui_pip_start	= -168;
	level.ROG_alt_ui_pip_end	= 126;
	level.ROG_alt_ui_fill_alpha = 0.35;

	element			  = NewHudElem();
	element.x		  = -285;
	element.y		  = 192;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_altimeter_num_box", 96, 48 );
	level.ROG_altimeter_ui_dynamic[ "num_box" ] = element;

	element			  = NewHudElem();
	element.x		  = -316;
	element.y		  = 124;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_altimeter_pip", 16, 16 );
	level.ROG_altimeter_ui_dynamic[ "pip" ] = element;

	element			  = NewHudElem();
	element.x		  = -340;
	element.y		  = 0;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_altimeter_ruler", 48, 384 );
	level.ROG_altimeter_ui_static[ "ruler" ] = element;

	element			  = NewHudElem();
	element.x		  = -340;
	element.y		  = 121;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.9;
	element.sort	  = 20;
	element SetShader( "hud_rog_altimeter_ruler_bot", 48, 174 );
	level.ROG_altimeter_ui_dynamic[ "ruler_bot" ] = element;

	element			  = NewHudElem();
	element.x		  = -340;
	element.y		  = 95.5;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_altimeter_ruler_warning_area", 174, 174 );
	level.ROG_altimeter_ui_dynamic[ "ruler_warning_area" ] = element;

	element			  = NewHudElem();
	element.x		  = -341;
	element.y		  = 144;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.0;
	element SetShader( "hud_rog_altimeter_ruler_warning_fill", 88, 128 );
	level.ROG_altimeter_ui_dynamic[ "ruler_warning_fill" ] = element;

	element					= NewHudElem();
	element.elemType		= "font";
	element.color			= ( 0, 0, 0 );
	element.font			= "default";
	element.fontscale		= 1.25;
	element.x				= -269;
	element.y				= 187;
	element.alignX			= "right";
	element.alignY			= "middle";
	element.horzAlign		= "center";
	element.vertAlign		= "middle";
	//element.point		  = "BOTTOMRIGHT";
	//element.relativepoint = "BOTTOMRIGHT";
	//element.width		  = 0;
	//element.height		  = int( level.fontHeight * 1.25 );
	//element.xOffset		  = 0;
	//element.yOffset		  = 0;
	//element.children	  = [];
	//fontElem setParent( level.uiParent );
	element SetText( level.ROG_altimeter_start_value );
	level.ROG_altimeter_ui_value = element;
	
	element					= NewHudElem();
	element.elemType		= "font";
	element.color			= ( 1, 1, 1 );
	element.font			= "objective";
	element.fontscale		= 1.9;
	element.x				= -266;
	element.y				= 164;
	element.alignX			= "right";
	element.alignY			= "middle";
	element.horzAlign		= "center";
	element.vertAlign		= "middle";
	element SetText( "ALT" );
	level.ROG_altimeter_ui_dynamic[ "name" ] = element;

	level thread ROG_altimeter_hud_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_cleanup_altimeter_hud()
{
	foreach( element in level.ROG_altimeter_ui_static )
	{
		element Delete();
	}
	foreach( element in level.ROG_altimeter_ui_dynamic )
	{
		element Delete();
	}
	level.ROG_altimeter_ui_value Delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_altimeter_hud_logic()
{
	// reset
	foreach( element in level.ROG_altimeter_ui_dynamic )
	{
		element.color = ( 1, 1, 1 );
	}
	level.ROG_altimeter_ui_value SetText( Int( level.ROG_altimeter_start_value ) );
	level.ROG_altimeter_ui_dynamic[ "pip" ].y = level.ROG_alt_ui_pip_start;
	level.ROG_altimeter_ui_dynamic[ "ruler_warning_fill" ].alpha = 0.0;

	level thread ROG_altimeter_logic_loop();

	level waittill( "ROG_new_sequence" );
	level.ROG_altimeter_ui_dynamic[ "pip" ] MoveOverTime( level.ROG_sequence_time );
	level.ROG_altimeter_ui_dynamic[ "pip" ].y = level.ROG_alt_ui_pip_end;

	level waittill( "ROG_seq_warning" );
	level.player notify( "altimeter_warning" );
	foreach( element in level.ROG_altimeter_ui_dynamic )
	{
		element.color = ( 1, 1, 0 );
	}

	level waittill( "ROG_seq_terminal" );
	foreach( element in level.ROG_altimeter_ui_dynamic )
	{
		element.color = ( 1, 0, 0 );
	}
	level.ROG_altimeter_ui_dynamic[ "ruler_warning_fill" ].alpha = level.ROG_alt_ui_fill_alpha;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_altimeter_logic_loop()
{
	time = 0.0;
	start = level.ROG_altimeter_start_value;
	prev_pos = level.player_mover.origin;

	while( true )
	{
		dist = Distance( prev_pos, level.player_mover.origin );
		prev_pos = level.player_mover.origin;
		start -= dist * level.EOG_altimeter_conv_ratio;
		level.ROG_altimeter_ui_value SetText( Int( start ) );
		
		if( time >= level.ROG_sequence_time )
		{
			break;
		}
		if( time >= level.ROG_sequence_time_terminal )
		{
			level notify( "ROG_seq_terminal" );
		}
		else if( time >= level.ROG_sequence_time_warning )
		{
			level notify( "ROG_seq_warning" );
		}

		time += 0.05;
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_setup_zoom_hud()
{
	level.ROG_zoom_ui = [];
	level.ROG_zoom_ui_pip_0 = 188;
	level.ROG_zoom_ui_pip_1 = 149;

	element			  = NewHudElem();
	element.x		  = 256;
	element.y		  = 192;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.3;
	element SetShader( "hud_rog_zoom_box", 60, 44 );
	level.ROG_zoom_ui[ "box_0" ] = element;

	element			  = NewHudElem();
	element.x		  = 288;
	element.y		  = 186;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.3;
	element SetShader( "hud_rog_zoom_box_tick", 8, 6 );
	level.ROG_zoom_ui[ "box_0_tick" ] = element;

	element					= NewHudElem();
	element.elemType		= "font";
	element.color			= ( 0, 0, 0 );
	element.font			= "objective";
	element.fontscale		= 1.4;
	element.x				= 254;
	element.y				= 187;
	element.alignX			= "right";
	element.alignY			= "middle";
	element.horzAlign		= "center";
	element.vertAlign		= "middle";
	element SetText( "1x" );
	level.ROG_zoom_ui[ "text_0" ] = element;

	element			  = NewHudElem();
	element.x		  = 256;
	element.y		  = 161;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.3;
	element SetShader( "hud_rog_zoom_box", 60, 44 );
	level.ROG_zoom_ui[ "box_1" ] = element;

	element			  = NewHudElem();
	element.x		  = 288;
	element.y		  = 155;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.3;
	element SetShader( "hud_rog_zoom_box_tick", 8, 6 );
	level.ROG_zoom_ui[ "box_1_tick" ] = element;
	
	element					= NewHudElem();
	element.elemType		= "font";
	element.color			= ( 0, 0, 0 );
	element.font			= "objective";
	element.fontscale		= 1.4;
	element.x				= 266;
	element.y				= 156;
	element.alignX			= "right";
	element.alignY			= "middle";
	element.horzAlign		= "center";
	element.vertAlign		= "middle";
	element SetText( "12x" );
	level.ROG_zoom_ui[ "text_1" ] = element;

	element			  = NewHudElem();
	element.x		  = 302;
	element.y		  = 177;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_zoom_meter", 12, 96 );
	level.ROG_zoom_ui[ "meter" ] = element;

	element			  = NewHudElem();
	element.x		  = 315;
	element.y		  = level.ROG_zoom_ui_pip_0;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 1.0;
	element SetShader( "hud_rog_zoom_meter_tick", 12, 6 );
	level.ROG_zoom_ui[ "meter_tick" ] = element;

	level thread ROG_zoom_hud_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_cleanup_zoom_hud()
{
	foreach( element in level.ROG_zoom_ui )
	{
		element Delete();
	}
	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_zoom_hud_logic()
{
	in_ads = true;
	while( true )
	{
		if( level.player isADS() && !in_ads )
		{
			level.ROG_zoom_ui[ "box_0" ].alpha = 0.3;
			level.ROG_zoom_ui[ "box_0_tick" ].alpha = 0.3;
			level.ROG_zoom_ui[ "text_0" ].alpha = 0.3;
			level.ROG_zoom_ui[ "box_1" ].alpha = 1.0;
			level.ROG_zoom_ui[ "box_1_tick" ].alpha = 1.0;
			level.ROG_zoom_ui[ "text_1" ].alpha = 1.0;
			level.ROG_zoom_ui[ "meter_tick" ] MoveOverTime( 0.05 );
			level.ROG_zoom_ui[ "meter_tick" ].y = level.ROG_zoom_ui_pip_1;
			in_ads = true;
		}
		if( !level.player isADS() && in_ads )
		{
			level.ROG_zoom_ui[ "box_0" ].alpha = 1.0;
			level.ROG_zoom_ui[ "box_0_tick" ].alpha = 1.0;
			level.ROG_zoom_ui[ "text_0" ].alpha = 1.0;
			level.ROG_zoom_ui[ "box_1" ].alpha = 0.3;
			level.ROG_zoom_ui[ "box_1_tick" ].alpha = 0.3;
			level.ROG_zoom_ui[ "text_1" ].alpha = 0.3;
			level.ROG_zoom_ui[ "meter_tick" ] MoveOverTime( 0.05 );
			level.ROG_zoom_ui[ "meter_tick" ].y = level.ROG_zoom_ui_pip_0;
			in_ads = false;
		}
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_setup_temp_hud()
{
	level.ROG_temp_ui = [];

	element			  = NewHudElem();
	element.x		  = 0;
	element.y		  = -128;
	element.alignX	  = "center";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.7;
	element SetShader( "white", 36, 16 );
	level.ROG_temp_ui[ "temp_bg" ] = element;

	element			  = NewHudElem();
	element.elemType  = "font";
	element.color	  = ( 0, 0, 0 );
	element.font	  = "objective";
	element.fontscale = 1.4;
	element.x		  = 10;
	element.y		  = -129;
	element.alignX	  = "right";
	element.alignY	  = "middle";
	element.horzAlign = "center";
	element.vertAlign = "middle";
	element.alpha	  = 0.7;
	element SetText( level.ROG_sequence_time );
	level.ROG_temp_ui[ "temp_text" ] = element;

	level thread ROG_temp_hud_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_cleanup_temp_hud()
{
	foreach( element in level.ROG_temp_ui )
	{
		element Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_temp_hud_logic()
{
	level notify( "ROG_temp_hud_logic" );
	level endon( "ROG_temp_hud_logic" );

	time = Int( level.ROG_sequence_time );
	while( time >= 0 )
	{
		level.ROG_temp_ui[ "temp_text" ] SetText( time );
		time--;
		wait( 1.0 );
	}
	
}