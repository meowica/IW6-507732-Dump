#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;

satellite_view_precache()
{
	PreCacheShader( "osp_hud_frame" );
	PreCacheShader( "cnd_laser_tag_hud_vignette" );
	PreCacheString( &"SATFARM_BADGER_1" );
	PreCacheString( &"SATFARM_GHOST_1" );
}

satellite_view_init_hud()
{
	if ( !IsDefined( level.satellite_view_hud_item ) )
	{
		level.satellite_view_hud_item = [];
	}
	
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
	SetSavedDvar( "compass", 0 );
	
	level.satellite_view_hud_item[ "vignette" ] = createIcon( "cnd_laser_tag_hud_vignette", 640, 480 );
	level.satellite_view_hud_item[ "vignette" ] set_default_hud_parameters();
	level.satellite_view_hud_item[ "vignette" ].alignx = "left";
	level.satellite_view_hud_item[ "vignette" ].aligny = "top";
	level.satellite_view_hud_item[ "vignette" ].horzAlign = "fullscreen";
	level.satellite_view_hud_item[ "vignette" ].vertAlign = "fullscreen";
	level.satellite_view_hud_item[ "vignette" ].alpha = 1;
	level.satellite_view_hud_item[ "vignette" ].sort -= 1;
	
	level.satellite_view_hud_item[ "overlay" ] = createIcon( "osp_hud_frame", 640, 480 );
	level.satellite_view_hud_item[ "overlay" ] set_default_hud_parameters();
	level.satellite_view_hud_item[ "overlay" ].alignx = "left";
	level.satellite_view_hud_item[ "overlay" ].aligny = "top";
	level.satellite_view_hud_item[ "overlay" ].horzAlign = "fullscreen";
	level.satellite_view_hud_item[ "overlay" ].vertAlign = "fullscreen";
	level.satellite_view_hud_item[ "overlay" ].alpha = 1;
	level.satellite_view_hud_item[ "overlay" ].sort -= 1;
	
	level.satellite_view = SpawnStruct();
	level.satellite_view.x = 0;
	level.satellite_view.y = 0;
	level.satellite_view.width = 32;
	level.satellite_view.height = 32;
	level.satellite_view.border_thickness = 2;
	
	if ( !IsDefined( level.satellite_view_borders ) )
	{
		level.satellite_view_borders = [];
	}
	
	if ( !IsDefined( level.satellite_view_borders[ "top_left" ] ) )
	{
		level.satellite_view_borders[ "top_left" ] = satellite_view_new_L_corner( level.satellite_view.x, level.satellite_view.y, "top_left" );
	}
	
	if ( !IsDefined( level.satellite_view_borders[ "top_right" ] ) )
	{
		level.satellite_view_borders[ "top_right" ] = satellite_view_new_L_corner( level.satellite_view.x, level.satellite_view.y, "top_right" );
	}
	
	if ( !IsDefined( level.satellite_view_borders[ "bottom_left" ] ) )
	{
		level.satellite_view_borders[ "bottom_left" ] = satellite_view_new_L_corner( level.satellite_view.x, level.satellite_view.y, "bottom_left" );
	}
	
	if ( !IsDefined( level.satellite_view_borders[ "bottom_right" ] ) )
	{
		level.satellite_view_borders[ "bottom_right" ] = satellite_view_new_L_corner( level.satellite_view.x, level.satellite_view.y, "bottom_right" );
	}
	
	level.satellite_view_hud_item[ "selector_top_line" ] = createIcon( "white", 1, 2000 );
	level.satellite_view_hud_item[ "selector_top_line" ] set_default_hud_parameters();
	level.satellite_view_hud_item[ "selector_top_line" ].aligny = "bottom";
	level.satellite_view_hud_item[ "selector_top_line" ].vertAlign = "middle";
	level.satellite_view_hud_item[ "selector_top_line" ].x = level.satellite_view.x;
	level.satellite_view_hud_item[ "selector_top_line" ].y = level.satellite_view.y - level.satellite_view.height * 0.5;
	
	level.satellite_view_hud_item[ "selector_bottom_line" ] = createIcon( "white", 1, 2000 );
	level.satellite_view_hud_item[ "selector_bottom_line" ] set_default_hud_parameters();
	level.satellite_view_hud_item[ "selector_bottom_line" ].aligny = "top";
	level.satellite_view_hud_item[ "selector_bottom_line" ].vertAlign = "middle";
	level.satellite_view_hud_item[ "selector_bottom_line" ].x = level.satellite_view.x;
	level.satellite_view_hud_item[ "selector_bottom_line" ].y = level.satellite_view.y + level.satellite_view.height * 0.5;
	
	level.satellite_view_hud_item[ "selector_left_line" ] = createIcon( "white", 2000, 1 );
	level.satellite_view_hud_item[ "selector_left_line" ] set_default_hud_parameters();
	level.satellite_view_hud_item[ "selector_left_line" ].alignx = "right";
	level.satellite_view_hud_item[ "selector_left_line" ].horzAlign = "center";
	level.satellite_view_hud_item[ "selector_left_line" ].x = level.satellite_view.x - level.satellite_view.width * 0.5;
	level.satellite_view_hud_item[ "selector_left_line" ].y = level.satellite_view.y;
	
	level.satellite_view_hud_item[ "selector_right_line" ] = createIcon( "white", 2000, 1 );
	level.satellite_view_hud_item[ "selector_right_line" ] set_default_hud_parameters();
	level.satellite_view_hud_item[ "selector_right_line" ].alignx = "left";
	level.satellite_view_hud_item[ "selector_right_line" ].horzAlign = "center";
	level.satellite_view_hud_item[ "selector_right_line" ].x = level.satellite_view.x + level.satellite_view.width * 0.5;
	level.satellite_view_hud_item[ "selector_right_line" ].y = level.satellite_view.y;
}

satellite_fade_hud( time )
{
	keys = getArrayKeys( level.satellite_view_hud_item );
	foreach ( key in keys )
	{
		level.satellite_view_hud_item[ key ] FadeOverTime( time );
		level.satellite_view_hud_item[ key ].alpha = 0;
	}
	
	foreach ( index, border in level.satellite_view_borders )
	{
		border.vertical FadeOverTime( time );
		border.horizontal FadeOverTime( time );
		border.vertical.alpha = 0;
		border.horizontal.alpha = 0;
	}
}

satellite_view_clear_hud()
{
	keys = getArrayKeys( level.satellite_view_hud_item );
	foreach ( key in keys )
	{
		level.satellite_view_hud_item[ key ] Destroy();
		level.satellite_view_hud_item[ key ] = undefined;
	}
	
	if ( IsDefined( level.satellite_view_borders ) )
	{
		array_thread( level.satellite_view_borders, ::satellite_view_remove_L_corners );
		level.satellite_view_borders = [];
	}
	
	satellite_view_pip_disable();
	
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
}

satellite_view_move_to_point( x, y, time )
{	
	if ( time > 0 )
	{
		foreach ( index, border in level.satellite_view_borders )
		{
			border.vertical MoveOverTime( time );
			border.horizontal MoveOverTime( time );
		}
		
		level.satellite_view_hud_item[ "selector_top_line" ] MoveOverTime( time );
		level.satellite_view_hud_item[ "selector_bottom_line" ] MoveOverTime( time );
		level.satellite_view_hud_item[ "selector_left_line" ] MoveOverTime( time );
		level.satellite_view_hud_item[ "selector_right_line" ] MoveOverTime( time );
	}
	
	level.satellite_view_hud_item[ "selector_top_line" ].x = x;
	level.satellite_view_hud_item[ "selector_top_line" ].y = y - level.satellite_view.height * 0.5;
	
	level.satellite_view_hud_item[ "selector_bottom_line" ].x = x;
	level.satellite_view_hud_item[ "selector_bottom_line" ].y = y + level.satellite_view.height * 0.5;

	level.satellite_view_hud_item[ "selector_left_line" ].x = x - level.satellite_view.width * 0.5;
	level.satellite_view_hud_item[ "selector_left_line" ].y = y;
	
	level.satellite_view_hud_item[ "selector_right_line" ].x = x + level.satellite_view.width * 0.5;
	level.satellite_view_hud_item[ "selector_right_line" ].y = y;
	
	foreach ( index, border in level.satellite_view_borders )
	{
		border.vertical.x = border.vertical.x - level.satellite_view.x + x;
		border.vertical.y = border.vertical.y - level.satellite_view.y + y;
		border.horizontal.x = border.horizontal.x - level.satellite_view.x + x;
		border.horizontal.y = border.horizontal.y - level.satellite_view.y + y;
		
		border.vertical updateChildren( time );
		border.horizontal updateChildren( time );
	}
	
	level.satellite_view.x = x;
	level.satellite_view.y = y;
}

satellite_view_pip_init()
{
	self.satellite_view_pip = self newpip();
	self.satellite_view_pip.enable = 0;
}

satellite_view_pip_enable( ent, tagname )
{
	self notify( "pip_enable" );
	
	if ( !IsDefined( self.satellite_view_pip ) )
	{
		self satellite_view_pip_init();
	}
	
	self.satellite_view_pip.opened_width 		= Int( level.satellite_view.width * 2 * 4 / 3 );
	self.satellite_view_pip.opened_height 		= level.satellite_view.height * 2;
	self.satellite_view_pip.closed_width 		= level.satellite_view.width;
	self.satellite_view_pip.closed_height 		= level.satellite_view.height;
	
//	self objective_selector_update_pip_position();
	self.satellite_view_pip.opened_x = 320 + level.satellite_view.x - level.satellite_view.width * 0.5;
	self.satellite_view_pip.opened_y = 240 + level.satellite_view.y - level.satellite_view.height * 0.5;
	self.satellite_view_pip.closed_x = self.satellite_view_pip.opened_x;
	self.satellite_view_pip.closed_y = self.satellite_view_pip.opened_y;
		
	self.satellite_view_pip.enableshadows = true;
	self.satellite_view_pip.tag = "tag_origin";
	self.satellite_view_pip.x = self.satellite_view_pip.closed_x;
	self.satellite_view_pip.y = self.satellite_view_pip.closed_y;
	self.satellite_view_pip.width = self.satellite_view_pip.closed_width;
	self.satellite_view_pip.height = self.satellite_view_pip.closed_height;
	
	x = self.satellite_view_pip.closed_x;
	y = self.satellite_view_pip.closed_y;
	
	self.satellite_view_pip.enable = true;

	self thread satellite_view_pip_change_size( level.satellite_view.width * 4 * 16 / 9, level.satellite_view.height * 4, 1.0 );
//	self thread satellite_view_pip_border();
	
	satellite_view_pip_set_entity( ent, tagname );
}

satellite_view_pip_display_name( display_name )
{
	if ( !IsDefined( level.satellite_view_hud_item[ "display_name" ] ) )
	{
		level.satellite_view_hud_item[ "display_name" ] = self maps\_hud_util::createClientFontString( "default", 0.3125 );
		level.satellite_view_hud_item[ "display_name" ] set_default_hud_parameters();
		level.satellite_view_hud_item[ "display_name" ].xOffset = 5;
		level.satellite_view_hud_item[ "display_name" ].yOffset = 0;
		level.satellite_view_hud_item[ "display_name" ].point = "BOTTOMLEFT";
		level.satellite_view_hud_item[ "display_name" ].relativepoint = "TOPLEFT";
		level.satellite_view_hud_item[ "display_name" ].color = ( 0, 1, 0 );
		level.satellite_view_hud_item[ "display_name" ].alpha = 1;
		level.satellite_view_hud_item[ "display_name" ] maps\_hud_util::setParent( level.satellite_view_borders[ "bottom_left" ].horizontal );
	}
	
	level.satellite_view_hud_item[ "display_name" ] SetText( display_name );
}

satellite_view_update_pip_position()
{
	if ( !IsDefined( self.objective_selector_pip ) )
	{
		return;
	}
	
	if ( level.satellite_view.x > 0 )
	{
		self.objective_selector_pip.opened_x = 320 + level.satellite_view.x - level.satellite_view.width * 1.1 - self.objective_selector_pip.opened_width;
		self.objective_selector_pip.closed_x = self.objective_selector_pip.opened_x;
	}
	else
	{
		self.objective_selector_pip.opened_x = 320 + level.satellite_view.x + level.satellite_view.width * 1.1;
		self.objective_selector_pip.closed_x = self.objective_selector_pip.opened_x;
	}
	
	if ( level.satellite_view.y >= 0 )
	{
		self.objective_selector_pip.opened_y = 240 + level.satellite_view.y - level.satellite_view.height * 1.1 - self.objective_selector_pip.opened_height;
		self.objective_selector_pip.closed_y = self.objective_selector_pip.opened_y;
	}
	else
	{
		self.objective_selector_pip.opened_y = 240 + level.satellite_view.y + level.satellite_view.height * 1.1;
		self.objective_selector_pip.closed_y = self.objective_selector_pip.opened_y;
	}
	
	x_diff = self.objective_selector_pip.opened_x - self.objective_selector_pip.x;
	y_diff = self.objective_selector_pip.opened_y - self.objective_selector_pip.y;
	
	self.objective_selector_pip.x = self.objective_selector_pip.opened_x;
	self.objective_selector_pip.y = self.objective_selector_pip.opened_y;
	
	foreach ( border in self.objective_selector_borders )
	{
		border.vertical.x += x_diff;
		border.horizontal.x += x_diff;
		border.vertical.y += y_diff;
		border.horizontal.y += y_diff;
	}
	
	if ( IsDefined( self.objective_selector_pip.border ) )
	{
		self.objective_selector_pip.border.x += x_diff;
		self.objective_selector_pip.border.y += y_diff;
	}
}

satellite_view_pip_set_entity( ent, tagname )
{
	self.satellite_view_pip.enable = 1;
	self.satellite_view_pip.freeCamera = true;
	
	cam = undefined;
	
	if ( IsDefined( ent ) )
	{
		cam = spawn ( "script_model", ent GetTagOrigin( tagname ) );
		cam setmodel( "tag_origin" );
		cam.angles = ent GetTagAngles( tagname );
		cam linkto( ent, tagname, ( 0, 0, 60 ), ( 0, 0, 0 ) );
	}
	
	//wait(.05);
	
	if ( IsDefined( cam ) )
	{
		self.satellite_view_pip.entity = cam;
		self.satellite_view_pip.tag = "tag_origin";
	}
	else
	{
		self.satellite_view_pip.origin = self.origin + ( 0, 0, 60 );
	}
}
/*
satellite_view_pip_border()
{
	if ( !IsDefined( self.satellite_view_pip.border ) )
	{
		//creates the staticFX shader in PIP
		hud = NewHudElem();
		hud.alpha = 1;
		hud.sort = 0;
		hud.x = self.satellite_view_pip.closed_x;
		hud.y = self.satellite_view_pip.closed_y;
		hud.hidewheninmenu = false;
		hud.hidewhendead = true;
		hud SetShader( "ac130_overlay_pip_vignette", self.satellite_view_pip.closed_width, self.satellite_view_pip.closed_height ); //shader needs to be in CSV and precached
		
		hud ScaleOverTime( 0.1, self.satellite_view_pip.opened_width, self.satellite_view_pip.opened_height );
	
		self.satellite_view_pip.border = hud;
	}
}
*/
satellite_view_pip_change_size( width, height, time )
{
	self endon( "pip_disable" );
	
	start_width = level.satellite_view.width;
	start_height = level.satellite_view.height;
	
	for ( i = 0.05; i <= time; i += 0.05 )
	{
		level.satellite_view.width = start_width + ( ( width - start_width ) * i / time );
		level.satellite_view.height = start_height + ( ( height - start_height ) * i / time );
		self.satellite_view_pip.width 	= level.satellite_view.width;
		self.satellite_view_pip.height	= level.satellite_view.height;
		self.satellite_view_pip.x 		= 320 + level.satellite_view.x - self.satellite_view_pip.width * 0.5;
		self.satellite_view_pip.y 		= 240 + level.satellite_view.y - self.satellite_view_pip.height * 0.5;
		self satellite_view_update_borders();
		self satellite_view_update_lines();
		
		if ( IsDefined( level.satellite_view_hud_item[ "display_name" ] ) )
		{
			level.satellite_view_hud_item[ "display_name" ].fontscale = level.satellite_view.height * 0.01;
		}
		
		wait 0.05;
	}
}

satellite_view_update_lines()
{
	level.satellite_view_hud_item[ "selector_top_line" ].x = level.satellite_view.x;
	level.satellite_view_hud_item[ "selector_top_line" ].y = level.satellite_view.y - level.satellite_view.height * 0.5;
	
	level.satellite_view_hud_item[ "selector_bottom_line" ].x = level.satellite_view.x;
	level.satellite_view_hud_item[ "selector_bottom_line" ].y = level.satellite_view.y + level.satellite_view.height * 0.5;
	
	level.satellite_view_hud_item[ "selector_left_line" ].x = level.satellite_view.x - level.satellite_view.width * 0.5;
	level.satellite_view_hud_item[ "selector_left_line" ].y = level.satellite_view.y;
	
	level.satellite_view_hud_item[ "selector_right_line" ].x = level.satellite_view.x + level.satellite_view.width * 0.5;
	level.satellite_view_hud_item[ "selector_right_line" ].y = level.satellite_view.y;
}

satellite_view_update_borders()
{
	foreach ( index, border in level.satellite_view_borders )
	{
		if ( index == "top_left" || index == "bottom_left" )
		{
			border.vertical.x = level.satellite_view.x - level.satellite_view.width * 0.5 - level.satellite_view.border_thickness;
			border.horizontal.x = level.satellite_view.x - level.satellite_view.width * 0.5 - level.satellite_view.border_thickness;
		}
		else
		{
			border.vertical.x = level.satellite_view.x + level.satellite_view.width * 0.5;
			border.horizontal.x = level.satellite_view.x + level.satellite_view.width * 0.5;
		}
	
		if ( index == "bottom_left" || index == "bottom_right" )
		{
			border.vertical.y = level.satellite_view.y + level.satellite_view.height * 0.5 + level.satellite_view.border_thickness;
			border.horizontal.y = level.satellite_view.y + level.satellite_view.height * 0.5 + level.satellite_view.border_thickness;
		}
		else
		{
			border.vertical.y = level.satellite_view.y - level.satellite_view.height * 0.5 - level.satellite_view.border_thickness;
			border.horizontal.y = level.satellite_view.y - level.satellite_view.height * 0.5 - level.satellite_view.border_thickness;
		}
		
		border.vertical updateChildren();
		border.horizontal updateChildren();
	}
}

satellite_view_new_L_corner( x, y, type )
{
	width = level.satellite_view.width;
	height = level.satellite_view.height;

	struct = SpawnStruct();
	thickness = level.satellite_view.border_thickness;
	l = 16;

	if ( type == "top_left" )
	{
		v_align_x = "left";
		v_align_y = "top";
		h_align_x = "left";
		h_align_y = "top";

		x = x - width * 0.5 - thickness;
		y = y - height * 0.5 - thickness;
	}
	else if ( type == "top_right" )
	{
		v_align_x = "left";
		v_align_y = "top";
		h_align_x = "right";
		h_align_y = "top";

		x = x + width * 0.5 + thickness - 1;
		y = y - height * 0.5 - thickness;
	}
	else if ( type == "bottom_left" )
	{
		v_align_x = "left";
		v_align_y = "bottom";
		h_align_x = "left";
		h_align_y = "bottom";

		x = x - width * 0.5 - thickness;
		y = y + height * 0.5 + thickness;
	}
	else // if ( type == "bottom_right" )
	{
		v_align_x = "left";
		v_align_y = "bottom";
		h_align_x = "right";
		h_align_y = "bottom";

		x = x + width * 0.5 + thickness - 1;
		y = y + height * 0.5 + thickness;
	}

	hud = level.player maps\_hud_util::createClientIcon( "white", thickness, l );
	hud.alignx = v_align_x;
	hud.aligny = v_align_y;
	hud.horzalign = "center";
	hud.vertalign = "middle";
	hud.x = x;
	hud.y = y;
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;

	struct.vertical = hud;

	hud = level.player maps\_hud_util::createClientIcon( "white", l, thickness );
	hud.alignx = h_align_x;
	hud.aligny = h_align_y;
	hud.horzalign = "center";
	hud.vertalign = "middle";
	hud.x = x;
	hud.y = y;
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;

	struct.horizontal = hud;

	return struct;
}

satellite_view_pip_open_L_corner( index, time )
{
	if ( index == "top_left" || index == "bottom_left" )
	{
		self.borders[index].vertical MoveOverTime( time );
		self.borders[index].vertical.x = self.opened_x - self.border_thickness;

		self.borders[index].horizontal MoveOverTime( time );
		self.borders[index].horizontal.x = self.opened_x - self.border_thickness;
	}
	else
	{
		self.borders[index].vertical MoveOverTime( time );
		self.borders[index].vertical.x = self.opened_x + self.opened_width;
		
		self.borders[index].horizontal MoveOverTime( time );
		self.borders[index].horizontal.x = self.opened_x + self.opened_width;
	}
	
	if ( index == "bottom_left" || index == "bottom_right" )
	{
		self.borders[index].vertical.y = self.opened_y + self.border_thickness;
		self.borders[index].horizontal.y = self.opened_y + self.border_thickness;
	}
}

satellite_view_pip_disable()
{
	self endon( "pip_enable" );
	self notify( "pip_disable" );
	
	if ( !IsDefined( self.satellite_view_pip ) || ( IsDefined( self.satellite_view_pip ) && !self.satellite_view_pip.enable ) )
	{
		return;
	}
	
	self.satellite_view_pip.enable = false;
	//self.objective_selector_pip.entity delete();

	if ( IsDefined( self.satellite_view_pip.linked_ent ) )
	{
		self.satellite_view_pip.linked_ent Delete();
	}

//	self.satellite_view_pip.border ScaleOverTime( time, self.satellite_view_pip.closed_width, self.satellite_view_pip.closed_height );
	
	if ( IsDefined(self.satellite_view_pip.border) )
	{
		self.satellite_view_pip.border destroy();
	}
}

satellite_view_remove_L_corners()
{
	self.vertical Destroy();
	self.horizontal Destroy();
}

satellite_view_pip_close_L_corner( index, time )
{
	if ( index == "top_left" || index == "bottom_left" )
	{
		self.borders[index].vertical MoveOverTime( time );
		self.borders[index].vertical.x = self.closed_x;

		self.borders[index].horizontal MoveOverTime( time );
		self.borders[index].horizontal.x = self.closed_x;
	}
	else
	{
		self.borders[index].vertical MoveOverTime( time );
		self.borders[index].vertical.x = self.closed_x + self.closed_width;
		self.borders[index].horizontal MoveOverTime( time );
		self.borders[index].horizontal.x = self.closed_x + self.closed_width;
	}
	
	if ( index == "bottom_left" || index == "bottom_right" )
	{
		
		self.borders[index].vertical.y = self.closed_y;
		self.borders[index].horizontal.y = self.closed_y;
	}
}

get_world_relative_offset_os( origin, angles, offset )
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

set_default_hud_parameters()
{
	self.alignx = "center";
	self.aligny = "middle";
	self.horzAlign = "center";
	self.vertAlign = "middle";
	self.hidewhendead = true;
	self.hidewheninmenu = true;
	self.sort = -5;
	self.foreground = false;
	self.alpha = 1.0;
}