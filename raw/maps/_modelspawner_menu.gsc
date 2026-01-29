#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

add_menu( menu_name, title )
{
	if ( IsDefined( level.menu_sys[ menu_name ] ) )
	{
		PrintLn( "^1level.menu_sys[ " + menu_name + " ] already exists, change the menu_name" );
		return;
	}

	level.menu_sys[ menu_name ] = SpawnStruct();
	level.menu_sys[ menu_name ].title = "none";

	level.menu_sys[ menu_name ].title = title;
}

add_menuoptions( menu_name, option_text, func, key, args )
{
	if ( !IsDefined( level.menu_sys[ menu_name ].options ) )
	{
		level.menu_sys[ menu_name ].options = [];
	}

	num = level.menu_sys[ menu_name ].options.size;
	level.menu_sys[ menu_name ].options[ num ] = option_text;
	level.menu_sys[ menu_name ].function[ num ] = func;

	if ( IsDefined( key ) )
	{
		if ( !IsDefined( level.menu_sys[ menu_name ].func_key ) )
		{
			level.menu_sys[ menu_name ].func_key = [];
		}

		level.menu_sys[ menu_name ].func_key[ num ] = key;
	}
	
	if ( IsDefined( args ) )
	{
		level.menu_sys[ menu_name ].args[ num ] = args;
	}
}

add_menu_child( parent_menu, child_menu, child_title, child_number_override, func )
{
	if ( !IsDefined( level.menu_sys[ child_menu ] ) )
	{
		add_menu( child_menu, child_title );
	}

	level.menu_sys[ child_menu ].parent_menu = parent_menu;

	if ( !IsDefined( level.menu_sys[ parent_menu ].children_menu ) )
	{
		level.menu_sys[ parent_menu ].children_menu = [];
	}

	if ( !IsDefined( child_number_override ) )
	{
		size = level.menu_sys[ parent_menu ].children_menu.size;
	}
	else
	{
		size = child_number_override;
	}

	level.menu_sys[ parent_menu ].children_menu[ size ] = child_menu;

	if ( IsDefined( func ) )
	{
		if ( !IsDefined( level.menu_sys[ parent_menu ].children_func ) )
		{
			level.menu_sys[ parent_menu ].children_func = [];
		}

		level.menu_sys[ parent_menu ].children_func[ size ] = func;
	}
}

enable_menu( menu_name )
{
	// Destroy the current menu
	disable_menu( "current_menu" );

	if ( IsDefined( level.menu_cursor ) )
	{
		level.menu_cursor.y = 130;
		level.menu_cursor.current_pos = 0;
	}

	// Set the title
	level.menu_sys[ "current_menu" ].title = set_menu_hudelem( level.menu_sys[ menu_name ].title, "title" );

	// Set the Options
	level.menu_sys[ "current_menu" ].menu_name = menu_name;

	back_option_num = 0; // Used for the "back" option
	if ( IsDefined( level.menu_sys[ menu_name ].options ) )
	{
		options = level.menu_sys[ menu_name ].options;
		for ( i = 0; i < options.size; i++ )
		{
			text = ( i + 1 ) + ". " + options[ i ];
			level.menu_sys[ "current_menu" ].options[ i ] = set_menu_hudelem( text, "options", 20 * i );
			back_option_num = i;
		}
	}

	// If a parent_menu is specified, automatically put a "Back" option in.
	if ( IsDefined( level.menu_sys[ menu_name ].parent_menu ) && !IsDefined( level.menu_sys[ menu_name ].no_back ) )
	{
		back_option_num++;
		text = ( back_option_num + 1 ) + ". " + "Back";
		level.menu_sys[ "current_menu" ].options[ back_option_num ] = set_menu_hudelem( text, "options", 20 * back_option_num );
	}

	menu_cursor();

	level.player AllowJump( false );
}

disable_menu( menu_name )
{
	if ( IsDefined( level.menu_sys[ menu_name ] ) )
	{
		if ( IsDefined( level.menu_sys[ menu_name ].title ) )
		{
			level.menu_sys[ menu_name ].title Destroy();
		}
	
		if ( IsDefined( level.menu_sys[ menu_name ].options ) )
		{
			options = level.menu_sys[ menu_name ].options;
			for ( i = 0; i < options.size; i++ )
			{
				options[ i ] Destroy();
			}
		}
	}

	level.menu_sys[ menu_name ].title = undefined;
	level.menu_sys[ menu_name ].options = [];

	if ( IsDefined( level.menu_cursor ) )
	{
		level.menu_cursor Destroy();
	}

	level.player AllowJump( true );
}

set_menu_hudelem( text, type, y_offset )
{
	x = 10;
	y = 100;
	if ( IsDefined( type ) && type == "title" )
	{
		scale = 2;
	}
	else // Default to Options
	{
		scale = 1.3;
		y = y + 30;
	}

	if ( !IsDefined( y_offset ) )
	{
		y_offset = 0;
	}

	y = y + y_offset;

	return set_hudelem( text, x, y, scale );
}

set_hudelem( text, x, y, scale, alpha, sort )
{
	if ( !IsDefined( alpha ) )
	{
		alpha = 1;
	}

	if ( !IsDefined( scale ) )
	{
		scale = 1;
	}

	if ( !IsDefined( sort ) )
	{
		sort = 20;
	}

	hud = NewHudElem();
	hud.location = 0;
	hud.alignX = "left";
	hud.alignY = "middle";
	hud.foreground = 1;
	hud.fontScale = scale;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.x = x;
	hud.y = y;
	hud.og_scale = scale;

	if ( IsDefined( text ) )
	{
		hud SetText( text );
	}

	return hud;
}

menu_input()
{
	while ( 1 )
	{
		// Notify from button_loop
		level waittill( "menu_button_pressed", keystring );

		if ( !IsDefined( level.menu_cursor ) )
		{
			wait( 0.1 );
			continue;
		}

		menu_name = level.menu_sys[ "current_menu" ].menu_name;

		// Move Menu Cursor
		if ( keystring == "dpad_up" || keystring == "uparrow" )
		{
			if ( level.menu_cursor.current_pos > 0 )
			{
				level.menu_cursor.y = level.menu_cursor.y - 20;
				level.menu_cursor.current_pos--;
			}
			else if ( level.menu_cursor.current_pos == 0 )
			{
				// Go back to the Bottom.
				level.menu_cursor.y = ( level.menu_cursor.y + ( ( level.menu_sys[ "current_menu" ].options.size - 1 ) * 20 ) );
				level.menu_cursor.current_pos = level.menu_sys[ "current_menu" ].options.size - 1;
			}
			
			wait( 0.1 );
			continue;
		}
		else if ( keystring == "dpad_down" || keystring == "downarrow" )
		{
			if ( level.menu_cursor.current_pos < level.menu_sys[ "current_menu" ].options.size - 1 )
			{
				level.menu_cursor.y = level.menu_cursor.y + 20;
				level.menu_cursor.current_pos++;
			}
			else if ( level.menu_cursor.current_pos == level.menu_sys[ "current_menu" ].options.size - 1 )
			{
				// Go back to the top.
				level.menu_cursor.y = ( level.menu_cursor.y + ( level.menu_cursor.current_pos * -20 ) );
				level.menu_cursor.current_pos = 0;
			}
			wait( 0.1 );
			continue;
		}
		else if ( keystring == "button_a" || keystring == "enter" )
		{
			key = level.menu_cursor.current_pos;
		}
		else // If the user is on the PC and using 1-0 for menu selecting.
		{
			key = Int( keystring ) - 1;
		}
	
		if ( key > level.menu_sys[ menu_name ].options.size )
		{
			continue;
		}
		else if ( IsDefined( level.menu_sys[ menu_name ].parent_menu ) && key == level.menu_sys[ menu_name ].options.size )
		{
			// This is if the "back" key is hit.
			level notify( "disable " + menu_name );
			level enable_menu( level.menu_sys[ menu_name ].parent_menu );
		}
		else if ( IsDefined( level.menu_sys[ menu_name ].function ) && IsDefined( level.menu_sys[ menu_name ].function[ key ] ) )
		{
//			level.menu_sys["current_menu"].options[key] thread hud_font_scaler( 1.1 );
			level.menu_sys[ "current_menu" ].options[ key ] thread hud_selector( level.menu_sys[ "current_menu" ].options[ key ].x, level.menu_sys[ "current_menu" ].options[ key ].y );

			if ( IsDefined( level.menu_sys[ menu_name ].func_key ) && IsDefined( level.menu_sys[ menu_name ].func_key[ key ] ) && level.menu_sys[ menu_name ].func_key[ key ] == keystring )
			{
				error_msg = level [[ level.menu_sys[ menu_name ].function[ key ]]]();
			}
			else
			{
				error_msg = level [[ level.menu_sys[ menu_name ].function[ key ]]]();
			}

			level thread hud_selector_fade_out();

			if ( IsDefined( error_msg ) )
			{
				level thread selection_error( error_msg, level.menu_sys[ "current_menu" ].options[ key ].x, level.menu_sys[ "current_menu" ].options[ key ].y );
			}
		}

		if ( !IsDefined( level.menu_sys[ menu_name ].children_menu ) )
		{
//			PrintLn( "^1 " + menu_name + " Menu does not have any children menus, yet" );
			continue;
		}
		else if ( !IsDefined( level.menu_sys[ menu_name ].children_menu[ key ] ) )
		{
			PrintLn( "^1 " + menu_name + " Menu does not have a number " + key + " child menu, yet" );
			continue;
		}
		else if ( !IsDefined( level.menu_sys[ level.menu_sys[ menu_name ].children_menu[ key ]] ) )
		{
			PrintLn( "^1 " + level.menu_sys[ menu_name ].options[ key ] + " Menu does not exist, yet" );
			continue;
		}

		if ( IsDefined( level.menu_sys[ menu_name ].children_func ) && IsDefined( level.menu_sys[ menu_name ].children_func[ key ] ) )
		{
			func = level.menu_sys[ menu_name ].children_func[ key ];
			error_msg = [[ func ]]();

			if ( IsDefined( error_msg ) )
			{
				level thread selection_error( error_msg, level.menu_sys[ "current_menu" ].options[ key ].x, level.menu_sys[ "current_menu" ].options[ key ].y );
				continue;
			}
		}

		level enable_menu( level.menu_sys[ menu_name ].children_menu[ key ] );

		wait( 0.1 );
	}
}

hud_selector( x, y )
{
	if ( !IsDefined( level.menu_cursor ) )
	{
		return;
	}

	if( IsDefined( level.hud_selector ) )
	{
		level thread hud_selector_fade_out();
	}

	level.menu_cursor.alpha = 0;

	level.hud_selector = set_hudelem( undefined, x - 10, y, 1 );
	level.hud_selector SetShader( "white", 125, 20 );
	level.hud_selector.color = ( 0.5, 0.5, 0.5 );
	level.hud_selector.alpha = 0.9;
	level.hud_selector.sort = 10;
}

hud_selector_fade_out( time )
{
	if( !IsDefined( time ) )
	{
		time = 0.25;
	}

	if ( IsDefined( level.menu_cursor ) )
	{
		level.menu_cursor.alpha = 0.9;
	}

	hud = level.hud_selector;
	level.hud_selector = undefined;

	if( !IsDefined( hud.debug_hudelem ) )
	{
		hud FadeOverTime( time );
	}
	hud.alpha = 0;
	wait( time + 0.1 );
	hud Destroy();
}

selection_error( msg, x, y )
{
	hud = set_hudelem( undefined, x - 10, y, 1 );
	hud SetShader( "white", 125, 20 );
	hud.color = ( 0.5, 0, 0 );
	hud.alpha = 0.7;

	error_hud = set_hudelem( msg, x + 125, y, 1 );
	error_hud.color = ( 1, 0, 0 );

	if( !IsDefined( hud.debug_hudelem ) )
	{
		hud FadeOverTime( 3 );
	}
	hud.alpha = 0;

	if( !IsDefined( error_hud.debug_hudelem ) )
	{
		error_hud FadeOverTime( 3 );
	}
	error_hud.alpha = 0;

	wait( 3.1 );
	hud Destroy();
	error_hud Destroy();
}

menu_cursor()
{
	level.menu_cursor = set_hudelem( undefined, 0, 130, 1.3 );
	level.menu_cursor SetShader( "white", 125, 20 );
	level.menu_cursor.color = ( 0.2, 0.2, 0.2 );	
	level.menu_cursor.alpha = 0.9;
	level.menu_cursor.sort = 1; // Put behind everything
	level.menu_cursor.current_pos = 0;
}

list_menu( list, x, y, scale, func, sort, start_num )
{
	if ( !IsDefined( list ) || list.size == 0 )
	{
		return -1;
	}

	hud_array = [];
	space_apart = 15;

	for ( i = 0; i < 5; i++ )
	{
		if ( i == 0 )
		{
			alpha = 0.3;
		}
		else if ( i == 1 )
		{
			alpha = 0.6;
		}
		else if ( i == 2 )
		{
			alpha = 1;
		}
		else if ( i == 3 )
		{
			alpha = 0.6;
		}
		else
		{
			alpha = 0.3;
		}

		hud = set_hudelem( list[ i ], x, y + ( ( i - 2 ) * space_apart ), scale, alpha, sort );
		hud_array = common_scripts\utility::array_add( hud_array, hud );
	}

	if ( IsDefined( start_num ) )
	{
		move_list_menu( hud_array, list, start_num );
	}
	else
	{
		move_list_menu( hud_array, list, 0 );
	}

	current_num = 0;
	old_num = 0;
	selected = false;

	level.menu_list_selected = false;

	if ( IsDefined( func ) )
	{
		[[ func ]]( list[ current_num ] );
	}

	while ( true )
	{
		level waittill( "menu_button_pressed", key );

		if ( !IsDefined( level.menu_cursor ) )
		{
			selected = false;
			break;
		}

		level.menu_list_selected = true;
		if ( any_button_hit( key, "numbers" ) )
		{
			break;
		}
		else if ( key == "downarrow" || key == "dpad_down" )
		{
			if ( current_num >= list.size - 1 )
			{
				continue;
			}

			current_num++;
			move_list_menu( hud_array, list, current_num );
		}
		else if ( key == "uparrow" || key == "dpad_up" )
		{
			if ( current_num <= 0 )
			{
				continue;
			}

			current_num--;
			move_list_menu( hud_array, list, current_num );		
		}
		else if ( key == "pgup" )
		{
			if ( current_num <= 0 )
			{
				continue;
			}

			current_num -= 5;
			current_num = Clamp( current_num, 0, list.size - 1 );
			current_num = int( current_num );
			
			move_list_menu( hud_array, list, current_num );		
		}
		else if ( key == "pgdn" )
		{
			if ( current_num >= list.size - 1 )
			{
				continue;
			}

			current_num += 5;
			current_num = Clamp( current_num, 0, list.size - 1 );
			current_num = int( current_num );
			
			move_list_menu( hud_array, list, current_num );		
		}
		else if ( key == "enter" || key == "button_a" )
		{
			selected = true;
			break;
		}
		else if ( key == "end" || key == "button_b" )
		{
			selected = false;
			break;
		}

		level notify( "scroll_list" ); // Only used for special functions

		if ( current_num != old_num )
		{
			old_num = current_num;

			if ( IsDefined( func ) )
			{
				[[ func ]]( list[ current_num ] );
			}
		}

		wait( 0.1 );
	}

	for ( i = 0; i < hud_array.size; i++ )
	{
		hud_array[ i ] Destroy();
	}

	if ( selected )
	{
		return current_num;
	}
}

move_list_menu( hud_array, list, num )
{

	for ( i = 0; i < hud_array.size; i++ )
	{
		if ( IsDefined( list[ i + ( num - 2 ) ] ) )
		{
			text = list[ i + ( num - 2 ) ];
		}
		else
		{
			text = "";
		}

		hud_array[ i ] SetText( text );
	}

}

//---------------------------------------------------------
// buttons section
//---------------------------------------------------------

add_universal_button( button_group, name )
{
	if ( !IsDefined( level.u_buttons[ button_group ] ) )
	{
		level.u_buttons[ button_group ] = [];
	}

	if ( array_check_for_dupes( level.u_buttons[ button_group ], name ) )
	{
		level.u_buttons[ button_group ][ level.u_buttons[ button_group ].size ] = name;
	}	
}

array_check_for_dupes( array, single )
{
	for ( i = 0; i < array.size; i++ )
	{
		if ( array[ i ] == single )
		{
			return false;
		}
	}

	return true;
}

clear_universal_buttons( button_group )
{
	level.u_buttons[ button_group ] = [];
}

universal_input_loop( button_group, end_on, use_attackbutton, mod_button, no_mod_button )
{
	level endon( end_on );

	if ( !IsDefined( use_attackbutton ) )
	{
		use_attackbutton = false;
	}

	notify_name = button_group + "_button_pressed";
	buttons = level.u_buttons[ button_group ];
	level.u_buttons_disable[ button_group ] = false;

	while ( 1 )
	{
		if ( level.u_buttons_disable[ button_group ] )
		{
			wait( 0.05 );
			continue;
		}

		if ( IsDefined( mod_button ) && !level.player ButtonPressed( mod_button ) )
		{
			wait( 0.05 );
			continue;
		}
		else if ( IsDefined( no_mod_button ) && level.player ButtonPressed( no_mod_button ) )
		{
			wait( 0.05 );
			continue;
		}


		if ( use_attackbutton && level.player AttackButtonPressed() )
		{
			level notify( notify_name, "fire" );
			wait( 0.1 );
			continue;
		}

		for ( i = 0; i < buttons.size; i++ )
		{
			if ( level.player ButtonPressed( buttons[ i ] ) )
			{
				level notify( notify_name, buttons[ i ] );
				wait( 0.1 );
				break;
			}
		}

		wait( 0.05 );
	}
}

any_button_hit( button_hit, type )
{
	buttons = [];
	if ( type == "numbers" )
	{
		buttons[ 0 ] = "0";
		buttons[ 1 ] = "1";
		buttons[ 2 ] = "2";
		buttons[ 3 ] = "3";
		buttons[ 4 ] = "4";
		buttons[ 5 ] = "5";
		buttons[ 6 ] = "6";
		buttons[ 7 ] = "7";
		buttons[ 8 ] = "8";
		buttons[ 9 ] = "9";
	}
	else
	{
		buttons = level.buttons;
	}

	for ( i = 0; i < buttons.size; i++ )
	{
		if ( button_hit == buttons[ i ] )
		{
			return true;
		}
	}

	return false;
}