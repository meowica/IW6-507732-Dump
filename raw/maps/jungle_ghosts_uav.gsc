#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

init_jungle_uav()
{
	level.player TakeAllWeapons();
	thread maps\jungle_ghosts_util::fade_out_in( "black", "uav_hud_set" );
	wait(.05);
	thread static_flash( 2 );
	level.tech_window_fontscale = .9;
	level.tech_window_font = "default"; //default bigfixed smallfixed objective small hudbig hudsmall 
	
	thread uav_hud_setup();
	level.player setstance("stand");
	level.player FreezeControls( true );
	level.player TakeAllWeapons();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	
	level.uav_defualt_fov = 55;
	setsaveddvar("compass", "1" );  //needs to be 1 to see objectives in the world TODO: remove if we dont have 3d objectives in uav view
		
	level.player VisionSetThermalForPlayer( "jungle_ghosts_uav_color", 0.05 );
	level.player thread maps\_load::thermal_EffectsOn();
	level.player ThermalVisionOn();
	
	level.uav = spawn_vehicle_from_targetname_and_drive( "new_uav" );	
	starting_look_pos = (-3007, -903, -198);
	
	level.uav uav_useby( level.player, starting_look_pos );	
	level thread light_static_interference( "slamzoom_start" );
	level thread uav_static_lines();
	level thread uav_sounds();
	level.player FreezeControls( false );
	level.uav thread uav_cloud_thread();
	
	level.uav Vehicle_SetSpeedImmediate( 40, 20 );
	
	thread maps\jungle_ghosts_jungle::intro_setup();
	thread maps\jungle_ghosts_jungle::uav_player_setup();
	
	thread maps\jungle_ghosts::objectives( "default" );
	level thread uav_dialogue();
	level thread player_tag_enemies();
	
	flag_wait( "friendlies_ready" );
	foreach ( guy in level.alpha)
	{
		guy  delayThread( 5, maps\jungle_ghosts_uav::target_ent, guy, "ac130_hud_diamond" );
	}
	//rc_drone_fly_loop rc_drone_startup
}

uav_sounds()
{
	wait( 1.5);
	level.uav thread play_sound_on_entity( "rc_drone_startup" );
	wait 1;
	level.uav thread play_loop_sound_on_entity( "rc_drone_fly_loop" );
	
	flag_wait( "slamzoom_finished" );
	level.uav stop_loop_sound_on_entity( "rc_drone_fly_loop" );
	
	
}

uav_dialogue()
{
	struct = getstruct( "jungle_player_start", "targetname" );
	thread uav_cam_lookat( struct, .05, 1 );
	
	flag_wait( "friendlies_ready" );

	wait 2;
	radio_dialogue( "jungleg_at1_online" );
	wait 1;
	radio_dialogue( "jungleg_at2_whatdoyousee" );
	wait 1;
	radio_dialogue( "jungleg_at1_lotsoftrees" );
	
	//struct = getstruct( "uav_center", "targetname" );
	//thread uav_cam_lookat( struct, 1, 1 );
	
	wait .5;
	radio_dialogue( "jungleg_bt1_halfaclick" );
	wait .5;
	radio_dialogue( "jungleg_at1_scanning" );
	
	level.uav Vehicle_SetSpeedImmediate( 5, 2.5 );
	
	flag_wait_or_timeout( "player_found_bravo", 3 );
	
	if(! flag("player_found_bravo" ) )
	foreach ( guy in level.uav_bravo_team )
	{
		guy maps\jungle_ghosts_uav::target_ent( guy, "ac130_hud_diamond" );
	}
	
	level.uav Vehicle_SetSpeedImmediate( 20, 20 );
	
	thread uav_cam_lookat( level.uav_bravo_team[0], .05, 2 );
	radio_dialogue( "jungleg_at1_goteyes" );
		
	radio_dialogue( "jungleg_at1_donotengage" );
	wait .5;
	radio_dialogue( "jungleg_bt1_toodifficult" );
	wait 1;
	radio_dialogue( "jungleg_at1_delayingrmp" );
	wait .5;
	thread radio_dialogue( "jungleg_chq_rmpactive" );
	
	wait 5.3;
	flag_set( "uav_vo_finished");
	flag_set( "slamzoom_start" );
	
}

player_tag_enemies()
{
	level endon("slamzoom_start");
	temp_ent = spawn( "script_origin", (0,0,0) );
	while(1)
	{
		Forward = VectorNormalize( AnglesToForward( level.player getplayerangles() ) );
		trace = bullettrace( level.player.origin, level.player.origin + ( Forward* 80000 ), 1, level.player );
		//thread draw_line_for_time( level.player.origin, level.player.origin + ( Forward* 80000 ), 1, 0, 0, 1 );
		temp_ent.origin =  trace["position"];
		wait(.05);
		foreach( trig in level.enemy_trigs )
		{
			if( temp_ent istouching( trig ) ) 
			{	
				if( trig.ai.team == "allies")
				{
					material = "ac130_hud_diamond";
					flag_set( "player_found_bravo");
				}
				else
					material = "remotemissile_infantry_target";
				target_ent( trig.ai, material );
				trig.ai  notify("tagged");
				level.enemy_trigs = array_remove( level.enemy_trigs, trig );
				level.threat_count++;
				level.uav_huds["top_horiontal"].huds[0] settext( level.threat_count );	
				trig delete();				
			}
		}
		wait( .5 );
				
		if( level.enemy_trigs.size == 0 )
			return;
	}
}

target_ent( ent, material, optional_offset )
{
	if(!isdefined( optional_offset) )
	{
		optional_offset = (0, 0, 0 );
	}	
	Target_Alloc( ent, optional_offset );
	Target_Set( ent );	
	target_setShader( ent, material );	//tech_panel_square_a tech_window_test_image ac130_hud_diamond
	target_setscaledrendermode( ent, true );
	Target_DrawSingle( ent );	  
  	Target_DrawSquare( ent, 150 );
	Target_SetMaxSize( ent, -1 );
	Target_SetMinSize( ent, -1, false );	
	Target_flush( ent );
	Target_ShowToPlayer( ent, level.player );
}

uav_cloud_thread()
{
	self endon( "slamzoom_start" );

	while ( 1 )
	{
		wait( RandomFloatRange( 2, 3 ) );

		forward = AnglesToForward( self.angles );
		up = AnglesToForward( self.angles ); 
		PlayFXOnTag( getfx( "clouds_predator" ), self.view_controller, "tag_aim" );
	}
}


uav_useby( player, targetent_start_origin )
{	
	self.player = player;
	self.view_controller = get_player_view_controller( self, "tag_origin", ( 0, 0, -8 ), "player_view_controller" );
		
	origin = self.origin + ( 0, 0, -1000 );
	if ( IsDefined( targetent_start_origin ) )
	{
		origin = targetent_start_origin;
	}
 
	self.target_ent = Spawn( "script_origin", origin );
	self.view_controller SnapToTargetEntity( self.target_ent );
	//thread draw_line_from_ent_to_ent_for_time( self, self.target_ent, 1,0,1, 60 );

	//player uav_enable_view();

	player UnLink();

	self.view_rig = uav_rig_controller( self.view_controller, "player_view_controller_zoom" );

	player PlayerLinkToDelta( self.view_controller, "tag_player", 1, 0, 0, 0, 0, true );
	SetSavedDvar( "sv_znear", 100 );
	self.view_rig UseBy( player );
	level.player DisableTurretDismount();
	level.player LerpViewAngleClamp( 1, .5, .5, 90, 90, 90, 90 );
	
	self Hide();
	
	self.view_rig setturretfov( level.uav_defualt_fov );	
}

uav_rig_controller( ent, turret )
{
	tag = "tag_aim";
	origin = ent GetTagOrigin( tag );
	angles = ent GetTagAngles( tag );

	if ( !IsDefined( turret ) )
	{
		turret = "player_view_controller";
	}
	
	rig = SpawnTurret( "misc_turret", origin, turret );
	rig.angles = angles;
	rig SetModel( "tag_turret" );
	rig LinkTo( ent, tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );
	rig MakeUnusable();
	rig Hide();
	rig SetMode( "manual" );
	rig TurretFireDisable();

	return rig;
}

light_static_interference( _flag )
{
	wait(.3);
	level endon( _flag );
	hud = NewHudElem();
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "overlay_static", 640, 480 ); //shader needs to be in CSV and precached
	hud.alignX = "left";
	hud.alignY = "top";
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha = .1;
	level.static = hud ;
		
	while ( 1 )
	{
		if( randomint( 100 ) < 15 )
			thread static_flash( 1 );
		time = RandomFloatRange( 1,2 );
		delay = time + RandomFloatRange( 5, 7 );
		alpha = RandomFloatRange( 0.05, 0.2 );

		level.static FadeOverTime( time );
		level.static.alpha = alpha;

		wait( delay );

		time = RandomFloatRange( 0.2, 0.4 );
		delay = time + RandomFloatRange( 0.5, .8 );

		level.static FadeOverTime( time );
		level.static.alpha = 0.1;

		wait( delay );
	}
}

uav_hud_setup()
{
	level.uav_huds = [];
	level.threat_count = 0;
	//SetSavedDvar( "cg_drawCrosshair", 0 );
	
	level.uav_huds["tech_bg"] = tech_background();
	
	
	level.uav_huds["top_center"] = tech_window_create( "tech_label_simple", 210, 55, 270, 35, "left" );
	top_center_text = ["Remote Tech UAV View 3.12"];
	level.uav_huds["top_center"] thread tech_window_text( top_center_text, 20, -23, 6000, .7, 1 );
	level.uav_huds["bottom_left"] = tech_window_create( "tech_label_simple", 330, 75, -10, 440, "left" );
	level.uav_huds["bottom_left"]  thread uav_hud_player_coords_update( 5, -32, .8, "slamzoom_start" );
	
	level.uav_huds["bottom_right"] = tech_window_create( "tech_label_simple", 260, 75, 470, 440, "left" );
	level.uav_huds["bottom_right"]  thread uav_hud_player_angles_update( 5, -32, .8, "slamzoom_start" );
	
	level.uav_huds["right_vertical"] = tech_window_create( "uav_vertical_meter", 20, 150, 600, 240, "right" );
	level.uav_huds["bottom_horiontal"] = tech_window_create( "uav_horizontal_meter", 150, 15, 395, 350, "right" );
	
	level.uav_huds["left_vertical"] = tech_window_create( "uav_vertical_meter", 20, 150, 100, 240, "right" );
	
	left_vertical_label_top = ["1337"];
	left_vertical_label_center = ["0"];
	left_vertical_label_bottom = ["-1337"];
	left_vertical_label_label = ["FLIR"];
	
	level.uav_huds["left_vertical"] thread uav_hud_time_update( 255, -105,  1.5, "slamzoom_start"  );	
	level.uav_huds["left_vertical"] thread tech_window_text( left_vertical_label_label, -10, -85, 6000, 1.5, 1 );
	level.uav_huds["left_vertical"] thread tech_window_text( left_vertical_label_top, -15, -70, 6000, 1, 1 );
	level.uav_huds["left_vertical"] thread tech_window_text( left_vertical_label_center, -10, 0, 6000, 1, 1 );
	level.uav_huds["left_vertical"] thread tech_window_text( left_vertical_label_bottom, -15, 70, 6000, 1, 1 );
	
	flag_set("uav_hud_set");
	
	level.uav_huds["top_horiontal"] = tech_window_create( "uav_horizontal_meter", 150, 15, 395, 150, "right" );	
	
	enemy_count = [ level.threat_count ];
	level.uav_huds["top_horiontal"]  thread tech_window_text( enemy_count, -39, 20, 6000, 1, 1, "HOSTILE COUNT: " );
	
	level.uav_huds["vertical_arrow"] = tech_window_create( "uav_arrow_left", 20, 20, 120, 240, "right" );
	level.uav_huds["vertical_arrow"] thread uav_vertical_arrow_movement( "slamzoom_start" );
	
	level.uav_huds["horizontal_arrow"] = tech_window_create( "uav_arrow_up", 20, 20, 330, 365, "right"  );
	level.uav_huds["horizontal_arrow"] thread uav_horizontal_arrow_movement( "slamzoom_start" );
	
	right_vertical_label_label = ["RECORDING"];
	level.uav_huds["right_vertical"] thread tech_window_text( right_vertical_label_label, 5, -85, 6000, 1.5, 1 );
	
	horizontal_label_left = ["1972"];
	horizontal_label_center = ["0"];
	horizontal_label_right = ["-1972"];
	
	level.uav_huds["bottom_horiontal"] thread tech_window_text( horizontal_label_right, 5, -10, 6000, 1, 1 );
	level.uav_huds["bottom_horiontal"] thread tech_window_text( horizontal_label_center, -72, -10, 6000, 1, 1 );
	level.uav_huds["bottom_horiontal"] thread tech_window_text( horizontal_label_left, -145, -10, 6000, 1, 1 );
	
	level.uav_huds["bottom_right_corner"] = tech_window_create( "uav_predator2_l_bottomright", 18, 18, 585, 350, "left" );
	level.uav_huds["bottom_left_corner"] = tech_window_create( "uav_predator2_l_bottomleft", 18, 18, 100, 350, "left" );
	
	delaythread(5, ::uav_irc_window);

	flag_wait("slamzoom_start");
	tech_windows_flush();

}

generic_hud_txt( message, x_offset, y_offset, fontsize, optional_font, optional_label )
{

	hudelem = NewHudElem();
	hudelem.x = self.x +x_offset;
	hudelem.y = self.y + y_offset;
	hudelem.sort = 1;// force to draw after the background
	hudelem.foreground = true;
	hudelem SetText( message );
	hudelem.alpha = 1;
	hudelem.fontScale = fontsize;

	//hudelem.color = ( 0.8, 0.8, 1.0 );
	if( isdefined (optional_font ) )
	{
		hudelem.font = optional_font;
	}
	else
	{
		hudelem.font = "default"; //default bigfixed smallfixed objective small hudbig hudsmall 
	}
	
	if( isdefined( optional_label ) )
	{
		hudelem.label = optional_label;
	}

	if( !isdefined( self.huds ) )
	{
		self.huds = [];
		self.huds[ 0 ] = hudelem;
	}
	else
	{
		self.huds = add_to_array( self.huds, hudelem  );
	}	
		
}

uav_irc_window()
{
	level.uav_huds["irc_window"] = tech_window_create( "tech_label_simple", 280, 120, 470, 438, "left" );
	chat_text = ["INCOMING IRC_MIL RELAY...", "Connecting...Logging in...CONNECTED", "<BlackBird1>: Eyes on primary target", "<Lucipher>: Copy that. LZ ETA 40", "<BlackBird1>: Rog. ROE strict", "<Lucipher>: Fuck that. Daddy's getting some.", "<BlackBird1>: LOL Copy that. Out.", "END OF RELAY" ];
	level.uav_huds["irc_window"]thread irc_txt_display( chat_text, 5, -55, .8 );

}

irc_txt_display( data, x_offset, y_offset, optional_font_size )
{
	//self = tech_window 
	home_pos = y_offset;
	toggle = 0;
	spacing = 10 * level.tech_window_fontscale;
	foreach ( i, item in data )
	{
		hudelem = NewHudElem();
		hudelem.x = self.x + x_offset;
		hudelem.y = self.y + y_offset;
		hudelem.alignX = self.alignX;
		hudelem.alignY = self.alignY;
		hudelem.sort = 1;// force to draw after the background
		hudelem.foreground = true;
		hudelem SetText( item );
		hudelem.alpha = 0;
		hudelem FadeOverTime( 0.5 );
		hudelem.alpha = 1;
		hudelem.type = "text";
	
		//hudelem.hidewheninmenu = true;
		if(isdefined( optional_font_size ) )
		{
			hudelem.fontScale = optional_font_size;
		}
		else
		{	
			hudelem.fontScale = level.tech_window_fontscale;
		}	
		hudelem.color = ( 0.8, 0.8, 1.0 );			
		hudelem delaycall( 3, ::destroy);
		
		toggle++;
		if( toggle == 2 )
		{
			y_offset = home_pos;
			toggle = 0;
		}
		else
		{		
			y_offset += spacing;
		}
		
		wait(randomfloatrange( 3, 3.6 ));
		
	}
	
	self thread tech_window_destroy();
}

uav_vertical_arrow_movement( _endon )
{
	top = 170;
	center = 240;
	bottom = 310;
	level endon( _endon );
	//current_angles = level.player GetPlayerAngles()[0];
	current_angles = level.player GetNormalizedCameraMovement()[0];
	//IPrintLn( current_angles );
	while(1)
	{
		if( isdefined( current_angles ) && current_angles != -0 )
		{
			new_angles = level.player GetNormalizedCameraMovement()[0];
			if( isdefined( new_angles ) )
			{
				if ( new_angles > current_angles )
				{
					if( self.y > top )
					{
						self.y -= 20;
						self MoveOverTime(.50);
						wait(.5);
					}
				}
				else if( new_angles < current_angles )
				{
					if( self.y < bottom )
					{
						self.y += 20;
						self MoveOverTime(.50);
						wait(.5);
					}		
				}	
			}
		}
		else
		{		
			if( self.y != center )
			{
				self.y = center;
				self MoveOverTime(1);	
				wait(1);		
			}
		}
		current_angles = level.player GetNormalizedCameraMovement()[0];
		wait(.10);
	}
	
}

uav_horizontal_arrow_movement( _endon )
{
	top = 260;
	center = 330;
	bottom = 400;
	level endon( _endon );
	//current_angles = level.player GetPlayerAngles()[0];
	current_angles = level.player GetNormalizedCameraMovement()[0];
	//IPrintLn( current_angles );
	while(1)
	{
		if( isdefined( current_angles ) && current_angles != -0 )
		{
			new_angles = level.player GetNormalizedCameraMovement()[0];
			if( isdefined( new_angles ) )
			{
				if ( new_angles > current_angles )
				{
//					IPrintLn( new_angles );
//					IPrintLn("raising");
					if( self.x > top )
					{
						self.x -= 20;
						self MoveOverTime(.25);
						wait(.5);
					}
				}
				else if( new_angles < current_angles )
				{
//					IPrintLn( new_angles );
//					IPrintLn("lowering");
					if( self.x < bottom )
					{
						self.x += 20;
						self MoveOverTime(.25);
						wait(.5);
					}		
				}	
			}
		}
		else
		{		
			if( self.x != center )
			{
				self.x = center;
				self MoveOverTime(1);	
				wait(1);		
			}
		}
		current_angles = level.player GetNormalizedCameraMovement()[0];
		//IPrintLn( current_angles );
		wait(.10);
	}
	
}
uav_hud_player_coords_update( x_offset, y_offset, font_size, _endon)
{
	level endon( _endon );
	
	hudelem = NewHudElem();
	hudelem.x = self.x + x_offset;
	hudelem.y = self.y + y_offset;
	hudelem.alignX = self.alignX;
	hudelem.alignY = self.alignY;
	hudelem.sort = 1;// force to draw after the background
	hudelem.foreground = true;
	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.2 );
	hudelem.alpha = 1;
	hudelem.label = "GPS: ";

	hudelem.fontScale = font_size;
	
	hudelem.color = ( 0.8, 0.8, 1.0 );
	hudelem.font = level.tech_window_font; 	
	
	if( !isdefined( self.huds ) )
	{
		self.huds = [];
	}
	
	self.huds = add_to_array( self.huds, hudelem );
	
	
	while( 1 )
	{
		hudelem SetText( level.player.origin );
		wait( randomfloatrange( .05, .4 ) );
	}

}

uav_hud_player_angles_update( x_offset, y_offset, font_size, _endon)
{
	level endon( _endon );
	
	hudelem = NewHudElem();
	hudelem.x = self.x + x_offset;
	hudelem.y = self.y + y_offset;
	hudelem.alignX = self.alignX;
	hudelem.alignY = self.alignY;
	hudelem.sort = 1;// force to draw after the background
	hudelem.foreground = true;
	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.2 );
	hudelem.alpha = 1;
	hudelem.label = "TRAJ: ";

	hudelem.fontScale = font_size;
	
	hudelem.color = ( 0.8, 0.8, 1.0 );
	hudelem.font = level.tech_window_font; 	
	
	if( !isdefined( self.huds ) )
	{
		self.huds = [];
	}
	
	self.huds = add_to_array( self.huds, hudelem );
	
	while( 1 )
	{
		hudelem SetText( level.player GetPlayerAngles() );
		wait( randomfloatrange( .05, .4 ) );
	}

}

uav_hud_time_update( x_offset, y_offset, font_size, _endon)
{
	timer = 0;
	level endon( _endon );	
	hudelem = NewHudElem();
	hudelem.x = self.x + x_offset;
	hudelem.y = self.y + y_offset;
	hudelem.alignX = self.alignX;
	hudelem.alignY = self.alignY;
	hudelem.sort = 1;// force to draw after the background
	hudelem.foreground = true;
	hudelem.label = "08:59:";

	hudelem.fontScale = font_size;
	
	//self.hudelem.color = ( 0.8, 0.8, 1.0 );
	hudelem.font = level.tech_window_font; 	
	
	if( !isdefined( self.huds ) )
	{
		self.huds = [];
	}
	
	self.huds = add_to_array( self.huds, hudelem );
	hudelem SetTimerUp( timer );
	
	
//	while( 1 )
//	{
//		self.hudelem SetText( level.player GetPlayerAngles() );
//		wait( randomfloatrange( .05, .4 ) );
//	}

}



/*=-=-=-=-=-==-
TECH WINDOW STUFF
=-=-=-=-=-=-=-=*/

//all tech_windows and child hudelems have a .type to help identify in script_debugger( text, image, cinematic, etc)
//all tech_windows are stored/removed from the level.tech_windows array as they are created/deleted

tech_window_create( image, res_x, res_y, x, y, align_x, optional_sort )
{
	if(!isdefined( level.tech_windows ) )
	{
		level.tech_windows = [];
	}	
	
	//calculate 20% of the desired resolution
	temp_x = (res_x * .2);
	temp_y = (res_y * .2);	
	//round up
	start_x =  ceil( temp_x );
	start_y =  ceil( temp_y );
	//convert to int and use as a temp starting point to scale up from
	start_x = int(start_x);
	start_y = int(start_y);
	
	window = NewHudElem();
	window.x = x;
	window.y = y;
	window.alpha = 0;
	
	if( isdefined( optional_sort ) )
	{
		window.sort = optional_sort;
	}
	else
	{	
		window.sort = -1; //so stuff can go on top of it (pip cant however, use tech_pip_panel material for that)
	}	
	
	window.alignX = align_x; //left right center
	window.alignY = "middle"; //top bottom middle	
	window.type = image;
	window setshader( image, start_x, start_y );
	
	window scaleovertime(.25, res_x, res_y );
	window FadeOverTime(.5);
	window.alpha = 1;
	//level.player thread play_sound_on_entity ("tech_window_open" );//cobra_aquiring_lock tech_window_open
	level.tech_windows = add_to_array( level.tech_windows, window );
	wait(.25);
	return window;

}		

tech_window_text( data, x_offset, y_offset, duration, optional_font_size, skip_typing, optional_label )
{
	//self = tech_window 
	spacing = 10 * level.tech_window_fontscale;
	foreach ( i, item in data )
	{
		hudelem = NewHudElem();
		hudelem.x = self.x + x_offset;
		hudelem.y = self.y + y_offset;
		hudelem.alignX = self.alignX;
		hudelem.alignY = self.alignY;
		hudelem.sort = 1;// force to draw after the background
		hudelem.foreground = true;
		hudelem SetText( item );
		hudelem.alpha = 0;
		hudelem FadeOverTime( 0.2 );
		hudelem.alpha = 1;
		hudelem.type = "text";
	
		//hudelem.hidewheninmenu = true;
		if(isdefined( optional_font_size ) )
		{
			hudelem.fontScale = optional_font_size;
		}
		else
		{	
			hudelem.fontScale = level.tech_window_fontscale;
		}	
		hudelem.color = ( 0.8, 0.8, 1.0 );
		hudelem.font = level.tech_window_font; 
		hudelem.glowColor = ( 0.3, 0.6, 0.3 );
		hudelem.glowAlpha = 1;
		if(!IsDefined( skip_typing ) )
		{
			hudelem SetPulseFX( 30, duration * 1000, 700 );// something, decay start, decay duration
		}
		
		if( !isdefined( self.huds ) )
		{
			self.huds = [];
			self.huds[ i ] = hudelem;
		}
		else
		{
			self.huds = add_to_array( self.huds, hudelem  );
		}	
		
		if(isdefined( optional_label ) )
		{
			hudelem.label = optional_label;
		}
		
		y_offset += spacing;
		wait(.15);
	}
}

tech_window_on_ent( ent )
{
	//this isnt working with images over 32x32 so it shouldnt be used for tech_windows until code support is given
	offset = (0, 0, 0 );
	Target_Alloc( ent, offset );
	target_setShader( ent, "ac130_hud_diamond" );	
	target_setscaledrendermode( ent, true );
	Target_DrawSingle( ent );	  
    Target_DrawSquare( ent, 100 );
	Target_SetMaxSize( ent, -1 );
	Target_SetMinSize( ent, -1, false );	
	target_flush( ent );
	Target_ShowToPlayer( ent, level.player );
}

tech_window_image( image, res_x, res_y, x_offset, y_offset )
{
	//self = tech_window
	hudelem = NewHudElem();
	hudelem.x = self.x + x_offset;
	hudelem.y = self.y + y_offset;
	hudelem.alignX = self.alignX;
	hudelem.alignY = self.alignY;
	hudelem.sort = 0;// force to draw after the background
	//hudelem.foreground = true;
	hudelem.alpha = 0;
	hudelem setshader( image, res_x, res_y );
	hudelem FadeOverTime( 0.2 );
	hudelem.alpha = .9;
	hudelem.type = "static image " +image;
	
	if( !isdefined( self.huds ) )
	{
		self.huds = [];
		self.huds[ 0 ] = hudelem;
	}
	else
	{
		self.huds = add_to_array( self.huds, hudelem  );
	}	
	
}	

tech_window_cinematic( bik_file, res_x, res_y, x_offset, y_offset, optional_sound )
{
	//self = tech_window 
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	wait(.15);
	self.has_cinematic = 1; //check for this in tech_window_destroy();
	hudelem = NewHudElem();
	hudelem.x = self.x + x_offset;
	hudelem.y = self.y + y_offset;
	hudelem.alignX = self.alignX;
	hudelem.alignY = self.alignY;
	hudelem.type = "Cinematic";
	hudelem.sort = 1;// force to draw after the background
	//hudelem.foreground = true;

	hudelem setshader( "cinematic", res_x, res_y );
	wait(.05);
	CinematicInGameSync( bik_file ); //plays the bik file over the "cinematic" shader
	
	if(IsDefined( optional_sound ) )
	{
		//level.player thread play_sound_on_entity( optional_sound );
	}	
	
	level thread tech_window_cinematic_cleanup();
	
	if( !isdefined( self.huds ) )
	{
		self.huds = [];
		self.huds[ 0 ] = hudelem;
	}
	else
	{
		self.huds = add_to_array( self.huds, hudelem  );
	}	
	
}

tech_window_cinematic_cleanup()
{	
	wait(3);
	while ( IsCinematicPlaying() )
	{
		wait( 0.5 );
	}
	
	SetSavedDvar( "cg_cinematicFullScreen", "1" );
}		


tech_window_pip( res_x, res_y, x_offset, y_offset, ent, optional_visionset )
{
	//self = tech_window hud_elem	
	level.pip.fov = 50;			
	level.pip.enableshadows = false;
	level.pip.x = self.x + x_offset;
	level.pip.y = self.y + y_offset;
	level.pip.width = res_x;
	level.pip.height = res_y;
	level.pip.sort = 1;
	level.pip.foreground = true;
	level.pip.activeVisionSet = "naked";
	
	if( isdefined( optional_visionset ) )
	{
		level.pip.visionsetnaked = optional_visionset;
	}
	else
	{	
		level.pip.visionsetnaked = "multiple_insertion"; //paris_ac130_thermal so_assault_rescue_2_ac130	
	}	
	
	level.pip.freeCamera = true;
	level.pip.tag = "tag_origin"; 
	level.pip.entity = ent;	
	level.pip.enable = 1;
}

tech_window_pip_disable()
{
	//self = tech_window
	//static flash	
	hud = NewHudElem();
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	
	//hud.alignX = "left";
	//hud.alignY = "top";	
	hud.x = level.pip.x;
	hud.y = level.pip.y;
	
	hud.sort = 1;
	hud.alpha = 1;	
	resx = int( level.pip.width );
	resy = int( level.pip.height );
	
	hud SetShader( "overlay_static", resx, resy ); //shader needs to be in CSV and precached
	
	level.pip.enableshadows = true;
	level.pip.enable = 0;
	//level.pip = undefined;~
	
	wait.2;
	
	hud.alpha = 0;	
	hud destroy();
			
}		

tech_windows_flush()
{
	if( IsDefined( level.tech_windows ) )
	{
		foreach( window in level.tech_windows)
		{
			window thread tech_window_destroy();
		}	
	}
	
}	

tech_window_destroy( level_notify, uav_hud_destroy )
{
	//self = tech_window hud element + children hud elems
	
	//UAV hud windows need extra param to get destroyed
	if( isdefined(self.is_uav_hud ) )
	{		
		if( !isdefined( uav_hud_destroy ) )
		{
			return;
		}
	}
	
	if(isdefined( level_notify ) )
	{ 
		level waittill( level_notify );
	}
	
	wait( randomfloatrange( .2, .7 ) );
		
	if( isdefined (self.huds ) )
	{
		//text lines and images
		foreach( hudelem in self.huds )
		{
			hudelem destroy();
		}
	}
	//bik file cinematic
	if( isdefined(self.has_cinematic) && IsCinematicPlaying() )
	{
		stopcinematicingame();
		SetSavedDvar( "cg_cinematicFullScreen", "1" ); //restore for loading movies
	}	
	
	//shut down pip
//	if( ( level.pip.enable ) )
//	{		
//		self tech_window_pip_disable(); //shuts down pip with sexy static flash
//	}	

	//level.player thread play_sound_on_entity( "tech_window_close" );
	
	//3 different ways to move off screen ( and fade out )		
	chance = randomint( 100 );
	 
	if( chance > 66 )
	{	
		//move up and right
		self FadeOverTime(.25);
		self MoveOverTime(.25);
		self.x = 1000;
		self.y = 1000;
	}
	else if( chance > 33 )
	{
		//move down and left
		self FadeOverTime(.25);
		self MoveOverTime(.25);
		self.x = -1000;
		self.y = -1000;
	}
	else
	{
		//window doesnt move, just fades out
		self FadeOverTime(.25);
	}	
		
	self.alpha = 0;	
	level.tech_windows = array_remove( level.tech_windows, self );
	
	wait .10;
	self destroy();
}	
	
	
	
	
static_flash( amount, optional_sound )
{
	hud = NewHudElem();
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "overlay_static", 640, 480 ); //shader needs to be in CSV and precached
	hud.alignX = "left";
	hud.alignY = "top";
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha = 0;
	hud.sort = 1;
	
	for( i = 0; i < amount; i++ )
	{
		hud.alpha = 1;		
		if(IsDefined( optional_sound ) )
		{
			level.player thread play_sound_on_entity( optional_sound );
		}		
		wait.1;
		hud.alpha = 0;	
		wait.2;	
	}
	
	hud destroy();
}			
		
tech_background()
{	
	if(!isdefined( level.tech_windows ) )
	{
		level.tech_windows = [];
	}
		
	hud = NewHudElem();
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "tech_grid_512", 640, 480 ); //shader needs to be in CSV and precached
	//hud.alignX = "left";
	//hud.alignY = "top";
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha = 1;
	hud.sort = -2;
	hud.type = "grid_background";
	
	level.tech_windows = add_to_array( level.tech_windows, hud );
	
	return hud;	
}		


uav_friendly_logic()
{
	self.ignoreme = 1;
	self.ignoreall = 1;
	self thread magic_bullet_shield( 1 );
}

uav_enemy_logic()
{
	self.ignoreme = 1;
	self.ignoreall = 1;
	self thread magic_bullet_shield( 1 );
	
}

uav_static_lines()
{
	level endon( "slamzoom_start" );
	
	level.uav.opened_x = -530;
	level.uav.opened_y = 0;
	
	//creates the static lines
	level.uav.line_a = NewHudElem();
	level.uav.line_a.alpha = 1;
	level.uav.line_a.sort = -50;
	level.uav.line_a.x = level.uav.opened_x;
	level.uav.line_a.y = level.uav.opened_y;
	level.uav.line_a.hidewheninmenu = false;
	level.uav.line_a.hidewhendead = true;

	lines=[];
	lines[0] = "ac130_overlay_pip_static_a";
	lines[1] = "ac130_overlay_pip_static_b";
	lines[2] = "ac130_overlay_pip_static_c";

	lines = array_randomize(lines);
	
	level childthread random_line_flicker();
	level childthread random_line_placement();
	uav_height  = 180;
	random_fraction = randomfloatrange(.10, .65);	//Height Random
	
	while(1)
	{
		level.uav.line_a SetShader( random( lines ), 1280, int(  uav_height*random_fraction ) ); //shader needs to be in CSV and precached
		wait(.05);
	}	

}	

random_line_flicker()
{	
	while ( 1 )
	{
		time = RandomFloatRange( .05, .08 );			//Random Duration Value between Alpha Value Change
		//delay = time + RandomFloatRange( 0.1, 0.4 );
		alpha = RandomFloatRange( 0.1, 0.8 );			//Random Alpha Value Range
		level.uav.line_a  FadeOverTime( time );
		level.uav.line_a.alpha = alpha;		
		wait( time );
		
		if(randomint(100) > 50)							//Random decision to switch to nothing
		{
			time = RandomFloatRange( .25, .4 );			//Random duration of nothing if chosen
			level.uav.line_a  FadeOverTime( time );
			//iprintlnbold("delay_error");
			level.uav.line_a.alpha = 0;		
			wait( time );
		}		
	}
}	

random_line_placement()
{

	while(1)
	{
		num = randomintrange(10, 640);					//Random height placement value - uav height is 135
		level.uav.line_a.y = num;
		wait( randomfloatrange(.05, .4) );				//Random Duration between height switch
	}	
		
}	

pip_border()
{
	//creates the staticFX shader in PIP
	hud = NewHudElem();
	hud.alpha = 1;
	hud.sort = -50;
	hud.x = level.uav.opened_x;
	hud.y = level.uav.opened_y;
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "ac130_overlay_pip_vignette", level.uav.opened_width, level.uav.opened_height ); //shader needs to be in CSV and precached

	level.uav.border = hud;
	
}
uav_cam_lookat( ent, move_time, duration, fov, follow_ent )
{
	level.uav.view_controller ClearTargetEntity();
	
	if( isdefined ( follow_ent ) )
	{		
//		level.uav.target_ent moveto( ent.origin, .4 );
//		wait( .4 );
		level.uav.target_ent.origin = ent.origin;	
		level.uav.target_ent linkto( ent );
	}	
	else
	{	
		//level.uav.view_controller SnapToTargetEntity( ent );
		//level.uav.target_ent moveto ( ent.origin,  move_time );
		level.uav.target_ent.origin = ent.origin;
	}	

	//wait( .5 );
	level.uav.view_controller SnapToTargetEntity( level.uav.target_ent );
	level.player LerpViewAngleClamp( move_time, 0, 0, 0, 0, 0, 0 );
	
	wait( move_time );
	
	if(isdefined( fov ) )
	{
		thread lerp_turret_fov( fov, move_time );
		wait( duration );		
	}	
	else
	{
		//wait_time = move_time + duration;
		wait ( duration );
	}	
	
	if( isdefined ( follow_ent ) )
	{		
		level.uav.target_ent unlink();
	}
		
	if(isdefined( fov ) )
	{
		thread lerp_turret_fov( level.uav_defualt_fov, .5 );
	}
	
	level notify( "camera_release" );
	level.player LerpViewAngleClamp( 1, .5, .5, 45, 45, 45, 45 );	
			
}


lerp_turret_fov( fov, time )
{
	//Turret must have "interface" set to "turret scope" in GDT!!
	level.player lerpfov( fov, time );	//this is hacky. It only zooms in, does not stay if desired fov is not within range of ADS min/max in GDT
	level.uav.view_rig setturretfov( fov ); //this gets it to stay at the new FOV after lerping
}