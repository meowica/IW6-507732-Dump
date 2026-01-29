#include maps\_utility;
#include common_scripts\utility;

pip_init()
{
	level.pip = level.player newpip();
	level.pip.enable = 0;
}


pip_enable( ent, tagname, shoulder_cam, optional_offset, optional_fov, x_pos, y_pos, width, height, visionset_override)
{	
	is_wide_screen 				= GetDvarInt( "widescreen", 1 );
	inv_standard_aspect_ratio	= 3 / 4;
	
	if ( !IsDefined(x_pos) || !IsDefined(y_pos) || !IsDefined(width) || !IsDefined(height) )
	{
		x_pos = ter_op( is_wide_screen, 545, 530 );
		y_pos = ter_op( is_wide_screen, 15, 30 );
		width = 165;
		height = 101;
	}
	
	if ( !IsDefined(visionset_override) )
	{
		visionset_override = "ac130_enhanced";
	}

//	level.pip.opened_width 		= ter_op( is_wide_screen, 220, 130 ); //240
//	level.pip.opened_height 	= ter_op( is_wide_screen, 135, Int( Floor( inv_standard_aspect_ratio * level.pip.opened_width ) ) );
	level.pip.opened_width 		= width;
	level.pip.opened_height 	= height;
	level.pip.closed_width 		= 16;
	level.pip.closed_height 	= 101;
//	level.pip.closed_height 	= ter_op( is_wide_screen, 135, Int( Floor( inv_standard_aspect_ratio * level.pip.opened_width ) ) );
//	level.pip.opened_x 			= ter_op( is_wide_screen, 490, 475 ); //ACTUAL X (bottom left =  -40) //460
	level.pip.opened_x 			= x_pos; //ACTUAL X (bottom left =  -40) //460
	level.pip.opened_y 			= y_pos; //ACTUAL Y (bottom left = 310)//32
	level.pip.closed_x 			= level.pip.opened_x + ( level.pip.opened_width * 0.5 ) - ( level.pip.closed_width * 0.5 );
	level.pip.closed_y 			= level.pip.opened_y;
	level.pip.border_thickness 	= 2;
		
	level.pip.enableshadows = false;
	level.pip.tag = "tag_origin";
	level.pip.x = level.pip.closed_x;
	level.pip.y = level.pip.closed_y;
	level.pip.width = level.pip.closed_width;
	level.pip.height = level.pip.closed_height;

	level.pip.visionsetnight = visionset_override;
	level.pip.visionsetnaked = visionset_override;
//	level.pip.visionsetnakedduration	= 0;
	level.pip.activevisionset 			= "night";
//	level.pip.activevisionsetduration 	= 0;
//	level.pip.visionsetnight = "vault_pip";
//	level.pip.visionsetnaked = "vault_pip";
	
	x = level.pip.closed_x;
	y = level.pip.closed_y;
	
	level.pip.borders[ "top_left" ] = new_L_pip_corner( x, y, "top_left" );
	level.pip.borders[ "top_right" ] = new_L_pip_corner( x, y, "top_right" );
	level.pip.borders[ "bottom_left" ] = new_L_pip_corner( x, y, "bottom_left" );
	level.pip.borders[ "bottom_right" ] = new_L_pip_corner( x, y, "bottom_right" );

	level thread pip_static();
	level thread pip_open();
//	level thread pip_display_timer();
	level thread pip_border();
	level thread pip_static_lines();
	
	pip_set_entity( ent, tagname, shoulder_cam, optional_offset, optional_fov );
}

pip_set_entity( ent, tagname, shoulder_cam, optional_offset, optional_fov )
{
	if ( IsDefined( level.pip.entity ) )
	{
		if ( !IsDefined( ent ) )
		{
			level.pip notify( "stop_interference" );
		}
		
		level.pip.entity Delete();
		level.pip.entity = undefined;
	}
	
	if ( IsDefined( ent ) )
	{
		level thread pip_interference();
	}
	
	cam = undefined;
	
	if ( IsDefined( ent ) )
	{
		//if ent is an actual ai, setup the cam pos with proper offset	
		if ( issentient( ent ) )
		{
			if ( !isDefined( shoulder_cam ) )
			{
				//PSUEDO FIRST-PERSON POV:
				spot = get_world_relative_offset( ent.origin, ent.angles, (12, 0, 0) );	
				eye = ent geteye();
				cam = spawn( "script_model", (spot[0], spot[1], eye[2]) );	
				cam setmodel( "tag_origin" );
				cam.angles = ent.angles;
				cam linkto( ent, "j_neck" );//j_head		
			}
			else
			{
				// SHOULDER CAM 
				offset = (-14, -14, 63);
				spot = get_world_relative_offset( ent.origin, ent.angles, offset);	
				cam = spawn( "script_model", spot );
				cam setmodel( "tag_origin" );
				cam.angles = ent.angles +(0, 6.8, 0); //roate towards him a tad
				cam linkto( ent, "j_neck" );//j_head
			}
		}
		// ent is just a static ent
		else
		{
			//use offset param if passed in
			if(isdefined(optional_offset))
			{
				spot = ent.origin + optional_offset;
				cam = spawn ("script_model", spot);
			}
			//else spawn at origin of ent
			else 
			{
				cam = spawn ("script_model", ent.origin);
			}		
			cam setmodel ("tag_origin");
			cam.angles = ent.angles;	
			cam linkto(ent);
		}
	}
	
	//wait(.05);
	
	level.pip.enable = 1;
	level.pip.freeCamera = true;
	
	if ( IsDefined( cam ) )
	{
		level.pip.entity = cam;
		
		if ( IsDefined( tagname ) )
		{
			level.pip.tag = tagname;
		}
		else
		{
			level.pip.tag = "tag_origin";
		}
	}
	else
	{
		level.pip.origin = level.player.origin + ( 0, 0, 60 );
	}
	
	level.pip.fov = ter_op( isdefined( optional_fov ), optional_fov, 50);
}

//pip_toggle_ai_cam( ai_array )
//{	
//	
// 	NotifyOnCommand( "toggle_pip_cam" , "+actionslot 4" );
//  	
//  	while(1)
//  	{
//  		foreach(guy in ai_array)
//  		{
//			level.player waittill( "toggle_pip_cam" );
//			//offset = (-13, -12, 64);
//			//spot = get_world_relative_offset(ai.origin, ai.angles, offset);	
//			ent = spawn( "script_model", guy.origin );
//			ent setmodel( "tag_origin" );
//			ent.angles = guy.angles;
//			ent linkto( guy, "j_head", ( -13, -12, 64 ), ( 0, 0, 0 ) );//j_head
//			
//			level.pip.entity = ent;
//			level.pip_ai_cam = guy;
//			wait( .20 ); //
//		}	
//	}	
//}
//
//pip_display_name()
//{
//	//displays the .name of the AI in the pip 	
//	level.pip_display_name = NewHudElem();
//	level.pip_display_name.alpha = 1;
//	level.pip_display_name.x = level.pip.opened_x + 15; //135
//	level.pip_display_name.y = level.pip.opened_y + 1; //117
//	level.pip_display_name.hidewheninmenu = false;
//	level.pip_display_name.hidewhendead = true;
//	level.pip_display_name.fontscale = 1.5;
//	level.pip_display_name.font = "objective";
//	
//	level.pip_display_name settext( level.pip_ai_cam.name );
//	
//	while(1)
//	{
//		level.player waittill( "toggle_pip_cam" );
//		wait( .10 );
//		level.pip_display_name settext( ( level.pip_ai_cam.name ) );
//	}	
//}	
//
//pip_display_timer()
//{
//	//displays the .name of the AI in the pip 	
//	level.pip_timer = level.player maps\_hud_util::createClientTimer( "objective", 1.5 );
//	level.pip_timer.alpha = 1;
//	level.pip_timer.x = level.pip.opened_x + 200;//225
//	level.pip_timer.y = level.pip.opened_y + 82;
//	level.pip_timer.hidewheninmenu = false;
//	level.pip_timer.hidewhendead = true;
//	level.pip_timer settenthstimerup( 0.00 ) ;
//}	

pip_static()
{
	//creates the staticFX shader in PIP
	if ( !IsDefined(level.pip.static_overlay) )
	{
		hud = NewHudElem();
	}
	else
	{
		hud = level.pip.static_overlay;
	}
	
	hud.alpha = 1;
	hud.sort = -50;
	hud.x = level.pip.opened_x;
	hud.y = level.pip.opened_y;
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "overlay_static", level.pip.opened_width, level.pip.opened_height ); //shader needs to be in CSV and precached

	level.pip.static_overlay = hud;

}	

pip_static_lines()
{
	// 220x135
	level.pip endon( "stop_interference" );
	
	//creates the static lines
	level.pip.line_a = NewHudElem();
	level.pip.line_a.alpha = 1;
	level.pip.line_a.sort = -50;
	level.pip.line_a.x = level.pip.opened_x;
	level.pip.line_a.y = level.pip.opened_y;
	level.pip.line_a.hidewheninmenu = false;
	level.pip.line_a.hidewhendead = true;
	
	lines=[];
	lines[0] = "ac130_overlay_pip_static_a";
	lines[1] = "ac130_overlay_pip_static_b";
	lines[2] = "ac130_overlay_pip_static_c";

	lines = array_randomize(lines);
	
	level thread random_line_flicker();
	level thread random_line_placement();
	pip_height  = 135;
	random_fraction = randomfloatrange( .10, .35 );	//Height Random
	
	while(1)
	{
		level.pip.line_a SetShader( random( lines ), level.pip.opened_width, int(  pip_height*random_fraction ) ); //shader needs to be in CSV and precached
		//wait( randomfloatrange( .05, .05 ) );			//Random wait between frame switch
		wait( .05 );
	}
}	

random_line_flicker()
{
	level.pip endon( "stop_interference" );
	
	while ( 1 )
	{
		time = RandomFloatRange( .05, .08 );			//Random Duration Value between Alpha Value Change
		//delay = time + RandomFloatRange( 0.1, 0.4 );
		alpha = RandomFloatRange( 0.1, 0.8 );			//Random Alpha Value Range
		level.pip.line_a FadeOverTime( time );
		level.pip.line_a.alpha = alpha;		
		wait( time );
		
		if ( randomint( 100 ) > 50 )					//Random decision to switch to nothing
		{
			time = RandomFloatRange( .25, .4 );			//Random duration of nothing if chosen
			level.pip.line_a FadeOverTime( time );
			//iprintlnbold("delay_error");
			level.pip.line_a.alpha = 0;		
			wait( time );
		}	
	}
}	

random_line_placement()
{
	level.pip endon( "stop_interference" );
	while ( 1 )
	{
		num = randomintrange( 10, int( level.pip.height - 25 ) );	//Random height placement value
		level.pip.line_a.y = num;
		wait( randomfloatrange( .05, .4 ) );						//Random Duration between height switch
	}
}	

pip_border()
{
	//creates the staticFX shader in PIP
	hud = NewHudElem();
	hud.alpha = 1;
	hud.sort = -50;
	hud.x = level.pip.opened_x;
	hud.y = level.pip.opened_y;
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "ac130_overlay_pip_vignette", level.pip.opened_width, level.pip.opened_height ); //shader needs to be in CSV and precached

	level.pip.border = hud;
	
}

pip_interference()
{
	level.pip endon( "stop_interference" );

	while ( IsDefined(level.pip) && IsDefined(level.pip.static_overlay) )
	{
		time = RandomFloatRange( 0.1, 1 );
		delay = time + RandomFloatRange( 0.1, 0.4 );
		alpha = RandomFloatRange( 0.1, 0.2 );

		level.pip.static_overlay FadeOverTime( time );
		level.pip.static_overlay.alpha = alpha;

		wait( delay );

		time = RandomFloatRange( 0.5, 0.75 );
		delay = time + RandomFloatRange( 0.5, 1.5 );

		level.pip.static_overlay FadeOverTime( time );
		level.pip.static_overlay.alpha = 0.3;

		wait( delay );
	}
}

pip_open()
{
	time = 0.1;
	
	foreach( i, border in level.pip.borders )
	{
		border thread pip_open_L_corner( i, time );
	}
	
	wait( time + 0.05 );
	
	level.pip.width 	= level.pip.opened_width;
	level.pip.height 	= level.pip.opened_height;
	level.pip.x 		= level.pip.opened_x;
	level.pip.y 		= level.pip.opened_y;
	
	level.pip.enable = true;
	
	wait( .8 ); //fuzzy-static intro
	
	level notify ("pip_in");
/*	
	if ( IsDefined( level.pip.entity ) )
	{
		level.pip.static_overlay FadeOverTime( 1 );
		level.pip.static_overlay.alpha = 0.2;

		level thread pip_interference();
	}
*/
}

get_world_relative_offset( origin, angles, offset )
{
	cos_yaw = cos( angles[ 1 ] );
	sin_yaw = sin( angles[ 1 ] );

	// Rotate offset by yaw
	x = ( offset[ 0 ] * cos_yaw ) - ( offset[ 1 ] * sin_yaw );
	y = ( offset[ 0 ] * sin_yaw ) + ( offset[ 1 ] * cos_yaw );

	// Translate to world position
	x += origin[ 0 ];
	y += origin[ 1 ];
	return ( x, y, origin[ 2 ] + offset[ 2 ] );
}


new_L_pip_corner( x, y, type )
{
	width = level.pip.closed_width;
	height = level.pip.closed_height;

	struct = SpawnStruct();
	thickness = level.pip.border_thickness;
	l = 16;

	if ( type == "top_left" )
	{
		v_align_x = "left";
		v_align_y = "top";
		h_align_x = "left";
		h_align_y = "top";

		x = x - thickness;
		y = y - thickness;
	}
	else if ( type == "top_right" )
	{
		v_align_x = "left";
		v_align_y = "top";
		h_align_x = "right";
		h_align_y = "top";

		x = x + width + thickness - 1;
		y = y - thickness;
	}
	else if ( type == "bottom_left" )
	{
		v_align_x = "left";
		v_align_y = "bottom";
		h_align_x = "left";
		h_align_y = "bottom";

		x = x - thickness;
		y = y + height + thickness;
	}
	else // if ( type == "bottom_right" )
	{
		v_align_x = "left";
		v_align_y = "bottom";
		h_align_x = "right";
		h_align_y = "bottom";

		x = x + width + thickness - 1;
		y = y + height + thickness;
	}

	hud = NewHudElem();
	hud.alignx = v_align_x;
	hud.aligny = v_align_y;
	hud.x = x;
	hud.y = y;
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "white", thickness, l );

	struct.vertical = hud;

	hud = NewHudElem();
	hud.alignx = h_align_x;
	hud.aligny = h_align_y;
	hud.x = x;
	hud.y = y;
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "white", l, thickness );

	struct.horizontal = hud;

	return struct;
}

pip_open_L_corner( index, time )
{
	if ( index == "top_left" || index == "bottom_left" )
	{
		self.vertical MoveOverTime( time );
		self.vertical.x = level.pip.opened_x - level.pip.border_thickness;

		self.horizontal MoveOverTime( time );
		self.horizontal.x = level.pip.opened_x - level.pip.border_thickness;
	}
	else
	{
		self.vertical MoveOverTime( time );
		self.vertical.x = level.pip.opened_x + level.pip.opened_width;
		self.horizontal MoveOverTime( time );
		self.horizontal.x = level.pip.opened_x + level.pip.opened_width;
	}
}

pip_disable()
{
/#
	if ( GetDvarInt( "no_pip_screen" ) > 0 )
	{
		return;
	}
#/
	level.pip notify( "stop_interference" );

	if (IsDefined(level.pip.static_overlay))
	{
		level.pip.static_overlay.alpha = 1;
	}
	
	wait( .5 );

	time = 0.25;
	level.pip.enableshadows = true;
	if (IsDefined(level.pip.static_overlay))
	{
		level.pip.static_overlay FadeOverTime( time );
		level.pip.static_overlay.alpha = 1;
	}
	wait( time );

	level.pip.enable = false;
	//level.pip.entity delete();

	if ( IsDefined( level.pip.linked_ent ) )
	{
		level.pip.linked_ent Delete();
	}

	time = 0.10;
	foreach( i, border in level.pip.borders )
	{
		border thread pip_close_L_corner( i, time );
	}

	if (IsDefined(level.pip.static_overlay))
	{
		level.pip.static_overlay ScaleOverTime( time, level.pip.closed_width, level.pip.closed_height );
	}
	wait( time + 0.05 );

//	pip_scaleovertime( time, true );

	level.pip.width = level.pip.closed_width;
	level.pip.height = level.pip.closed_height;
	level.pip.x = level.pip.closed_x;
	level.pip.y = level.pip.closed_y;

	if ( IsDefined( level.pip.borders ) )
	{
		array_thread( level.pip.borders, ::pip_remove_L_corners );
	}

	if (IsDefined(level.pip.static_overlay))
	{
		level.pip.static_overlay Destroy();
	}
	
	if(IsDefined(level.pip_display_name) )
	{
		level.pip_display_name destroy();
	}
	
	if(IsDefined(level.pip_timer) )
	{
		level.pip_timer destroy();
	}
	
	if(IsDefined(level.pip.border) )
	{
		level.pip.border destroy();
	}
	
	if(IsDefined(level.pip.line_a) )
	{
		level.pip.line_a destroy();
	}
	
	if ( IsDefined( level.pip.entity ) )
	{
		level.pip.entity Delete();
		level.pip.entity = undefined;
	}
	
	level.pip.enable = 0;
}

pip_remove_L_corners()
{
	self.vertical Destroy();
	self.horizontal Destroy();
}

pip_close_L_corner( index, time )
{
	if ( index == "top_left" || index == "bottom_left" )
	{
		self.vertical MoveOverTime( time );
		self.vertical.x = level.pip.closed_x;

		self.horizontal MoveOverTime( time );
		self.horizontal.x = level.pip.closed_x;
	}
	else
	{
		self.vertical MoveOverTime( time );
		self.vertical.x = level.pip.closed_x + level.pip.closed_width;
		self.horizontal MoveOverTime( time );
		self.horizontal.x = level.pip.closed_x + level.pip.closed_width;
	}
}

//Print3d_on_ent( msg ) 
//{ 
// /# 
//  self endon( "death" );  
//  self notify( "stop_print3d_on_ent" );  
//  self endon( "stop_print3d_on_ent" );  
//
//  while( 1 ) 
//  { 
//     print3d( self.origin + ( 0, 0, 0 ), msg );  
//     wait( 0.05 );  
//   } 
// #/ 
//}