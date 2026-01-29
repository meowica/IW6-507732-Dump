#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_modelspawner_menu;

init_modelspawner()
{
	SetDvarIfUninitialized( "filter", "" );
	SetDvarIfUninitialized( "filterout", "" );

	// Used in codescript\character.gsc to store the character data.
	level.store_characterinfo = true;
	level.use_behavior = "Highlight";
	level.highlight_num = 1;
	init_spawners();
	init_menus();
	init_buttons();

	level thread toggle_menu();
	level thread menu_input();
}

init_spawners()
{
	add_global_spawn_function( "axis", ::postspawn_ai );
	add_global_spawn_function( "neutral", ::postspawn_ai );
	add_global_spawn_function( "allies", ::postspawn_ai );
	add_global_spawn_function( "team3", ::postspawn_ai );

	level.ent_types = [];
	level.ent_spawners = [];
	ents = GetSpawnerArray();
	ents = array_combine( ents, GetEntArray( "script_model", "classname" ) );
	
	volume = GetEnt( "spawner_volume", "targetname" );
	ground_struct = getstruct( "spawner_ground", "targetname" );
	
	foreach ( ent in ents )
	{
		if ( !ent IsTouching( volume ) )
			continue;

		if ( IsSpawner( ent ) )
		{
			ent.script_ignoreall = true;
			id = ent.classname;
		}
		else // script_model
		{
			id = ent.model;
			ent.ground_offset = ( 0, 0, ent.origin[ 2 ] ) - ( 0, 0, ground_struct.origin[ 2 ] );
		}
		
		if ( IsDefined( level.ent_spawners[ id ] ) )
		{
			println( "^2Found Dupe of " + id );
			continue;
		}
		
		level.ent_types[ level.ent_types.size ] = id;
		level.ent_spawners[ id ] = ent;
	}

//	level.ent_types = array_remove_dupes( level.ent_types );
	level.ent_types = alphabetize( level.ent_types );
	
	
}

init_menus()
{
	level.menu_sys = [];
	level.menu_sys[ "current_menu" ] = SpawnStruct();

	add_menu( "select_group", "Main:" );
		add_menuoptions( "select_group", "Model 1", ::select_model, undefined, 1 );
		add_menuoptions( "select_group", "Model 2", ::select_model, undefined, 2 );
		add_menuoptions( "select_group", "Model 3", ::select_model, undefined, 3 );
		add_menuoptions( "select_group", "Model 4", ::select_model, undefined, 4 );
		add_menuoptions( "select_group", "Use Behavior", ::select_use_behavior );
		add_menuoptions( "select_group", "Move Player", ::move_player );
		add_menuoptions( "select_group", "Close Menu", ::close_menu );

	enable_menu( "select_group" );
}

toggle_menu()
{
	NotifyOnCommand( "smoke_button_pressed", "+smoke" );

	enabled = true;

	while ( 1 )
	{
		level.player waittill( "smoke_button_pressed" );

		if ( !IsDefined( level.menu_cursor ) )
		{
			enable_menu( "select_group" );
		}
		else
		{
			disable_menu( "current_menu" );
			level notify( "menu_button_pressed", "close_menu" );
		}

		wait( 0.25 );
	}
}

close_menu()
{
	disable_menu( "current_menu" );
}

init_buttons()
{
	clear_universal_buttons( "menu" );

	add_universal_button( "menu", "dpad_up" );
	add_universal_button( "menu", "dpad_down" );
	add_universal_button( "menu", "dpad_left" );
	add_universal_button( "menu", "dpad_right" );
	add_universal_button( "menu", "button_a" );
	add_universal_button( "menu", "button_b" );
	add_universal_button( "menu", "button_y" );
	add_universal_button( "menu", "button_x" );
	add_universal_button( "menu", "button_lshldr" );
	add_universal_button( "menu", "button_rshldr" );

	add_universal_button( "menu", "1" );
	add_universal_button( "menu", "2" );
	add_universal_button( "menu", "3" );
	add_universal_button( "menu", "4" );
	add_universal_button( "menu", "5" );
	add_universal_button( "menu", "6" );
	add_universal_button( "menu", "7" );
	add_universal_button( "menu", "8" );
	add_universal_button( "menu", "9" );
	add_universal_button( "menu", "0" );

	add_universal_button( "menu", "downarrow" );
	add_universal_button( "menu", "uparrow" );
	add_universal_button( "menu", "leftarrow" );
	add_universal_button( "menu", "rightarrow" );

	add_universal_button( "menu", "=" );
	add_universal_button( "menu", "-" );

	add_universal_button( "menu", "enter" );
	add_universal_button( "menu", "end" );
	add_universal_button( "menu", "backspace" );
	add_universal_button( "menu", "del" );
	add_universal_button( "menu", "ins" );
	add_universal_button( "menu", "pgup" );
	add_universal_button( "menu", "pgdn" );

	add_universal_button( "menu", "kp_leftarrow" );
	add_universal_button( "menu", "kp_rightarrow" );
	add_universal_button( "menu", "kp_uparrow" );
	add_universal_button( "menu", "kp_downarrow" );
	add_universal_button( "menu", "kp_home" );
	add_universal_button( "menu", "kp_pgup" );

	level thread universal_input_loop( "menu", "never", undefined, undefined, "button_ltrig" );
}

array_remove_dupes( array )
{
	string_indexed_array = [];
	
	foreach ( val in array )
	{
		string_indexed_array[ val ] = true;
	}
	
	new_array = [];
	foreach ( index, _ in string_indexed_array )
	{
		new_array[ new_array.size ] = index;
	}
	
	return new_array;
}

postspawn_ai()
{
	self.team = "neutral";
	self.nododgemove = true;
	self.alertLevel = "noncombat";
	self thread use_behavior();
}

//---------------------------------------------------------
// Select / Spawn AI Group Section
//---------------------------------------------------------
select_model()
{
	y = level.menu_sys[ "current_menu" ].options[ level.menu_cursor.current_pos ].y;

	menu_name = level.menu_sys[ "current_menu" ].menu_name;
	num_for_spawning = level.menu_sys[ menu_name ].args[ level.menu_cursor.current_pos ];

	arrow_hud = set_hudelem( "-------->", 125, y, 1.3 );
	value = undefined;

	list = filter_model_types();

	value = list_menu( list, 180, y, 1.3 );

	if ( IsDefined( value ) )
	{
		if ( value < 0 )
		{
			level thread selection_error( "No Models Found", 10, y );
		}
		else
		{
			selected_model( num_for_spawning, level.ent_types[ value ] );
		}
	}

	arrow_hud Destroy();
}

filter_model_types()
{
	list = level.ent_types;

	filterout = GetDvar( "filterout" );
	filter = GetDvar( "filter" );

	if ( filter != "" )
	{
		filter_list = [];
		foreach ( ai_type in list )
		{
			if ( IsSubStr( ToLower( ai_type ), ToLower( filter ) ) )
			{
				filter_list[ filter_list.size ] = ai_type;
			}
		}

		list = filter_list;
	}

	if ( filterout != "" )
	{
		filterout_list = [];
		foreach ( ai_type in list )
		{
			if ( IsSubStr( ToLower( ai_type ), ToLower( filterout ) ) )
			{
				continue;
			}

			filterout_list[ filterout_list.size ] = ai_type;
		}

		list = filterout_list;
	}

	return list;
}

selected_model( num, type )
{
	structs = getstructarray( "spawnpoint_" + num, "targetname" );
	foreach ( struct in structs )
	{
		if ( !IsDefined( struct.spawnpoint_num ) )
			struct.spawnpoint_num = num;
		
		struct set_struct_model( type );
		wait( 0.05 );
	}
	
	// See if models should propagate to the "highlight_model_points"
	if ( level.highlight_num == num )
	{
		set_highlight_structs( num );
	}
}

set_struct_model( type )
{
	if ( !IsDefined( self.ground_pos ) )
		self.ground_pos = drop_to_ground( self.origin, 10 );
	
	self delete_struct_ent();
	
	waittillframeend;
	
	spawner = level.ent_spawners[ type ];
	if ( IsSpawner( spawner ) )
	{
		spawner.origin = self.ground_pos;
		spawner.angles = self.angles;
		spawner.count = 1;
		
		self.ent = spawner spawn_ai( true );
		
		if ( !IsDefined( self.ent ) )
			return;
	}
	else
	{
		self.ent = Spawn( "script_model", ( 0, 0, 0 ) );
		self.ent.origin = self.ground_pos + spawner.ground_offset;
		
		self.ent.angle_offset = spawner.angles;
		
		self.ent.angles = self.angles + self.ent.angle_offset;
		
		self.ent SetModel( spawner.model );
		self.ent thread use_behavior();
	}
	
	self.type = type;
	self.ent.spawnpoint = self;
}

delete_struct_ent()
{
	if ( !IsDefined( self.ent ) )
		return;
	
	if ( IsAi( self.ent ) && !IsAlive( self.ent ) )
		return;
	
	self.ent Delete();
}

set_highlight_structs( num )
{
	if ( !IsDefined( num ) )
		return;
	
	spawnpoints = getstructarray( "spawnpoint_" + num, "targetname" );
	spawnpoint = spawnpoints[ 0 ];
	
	structs = getstructarray( "highlight_model_point", "targetname" );
	foreach ( struct in structs )
	{	
		struct set_struct_model( spawnpoint.type );
		wait( 0.05 );
	}
}

//---------------------------------------------------------
// Use Behavior Section 
//---------------------------------------------------------
select_use_behavior()
{
	y = level.menu_sys[ "current_menu" ].options[ level.menu_cursor.current_pos ].y;

	menu_name = level.menu_sys[ "current_menu" ].menu_name;
	current_selected_group = level.menu_sys[ menu_name ].options[ level.menu_cursor.current_pos ];

	arrow_hud = set_hudelem( "-------->", 125, y, 1.3 );
	value = undefined;

	list = [ "Highlight", "Face Player", "Face Away Player", "Swap Head" ];
	value = list_menu( list, 180, y, 1.3 );

	if ( IsDefined( value ) )
	{
		if ( value < 0 )
		{
			level thread selection_error( "No models Found", 10, y );
		}
		else
		{
			level.use_behavior = list[ value ];
		}
	}

	arrow_hud Destroy();
}

use_behavior()
{
	self endon( "death" );
	
	self MakeUsable();
	self SetCursorHint( "HINT_ACTIVATE" );
	while ( 1 )
	{
		self waittill( "trigger" );

		switch ( level.use_behavior )
		{
			case "Face Player":
				self use_face_player();
				break;
			case "Face Away Player":
				self use_face_away_player();
				break;
			case "Swap Head":
				self swap_head();
				break;
			case "Highlight":
				set_highlight_structs( self.spawnpoint.spawnpoint_num );
				break;
		}

		wait( 1 );
	}
}

use_face_player()
{
	if ( IsAi( self ) )
	{
		self OrientMode( "face point", level.player.origin );
	}
	else
	{
		angles = VectorToAngles( level.player.origin - self.origin );
		angles = ( 0, angles[ 1 ], 0 );
		
		if ( IsDefined( self.angle_offset ) )
			angles += self.angle_offset;
		
		time = abs( AngleClamp180( self.angles[ 1 ] - angles[ 1 ] ) / 360 );
		self RotateTo( angles, time );
	}
}

use_face_away_player()
{
	if ( IsAi( self ) )
	{
		self OrientMode( "face point", level.player.origin );
	}
	else
	{
		angles = VectorToAngles( self.origin - level.player.origin );
		angles = ( 0, angles[ 1 ], 0 );
		
		if ( IsDefined( self.angle_offset ) )
			angles += self.angle_offset;
		
		time = abs( AngleClamp180( self.angles[ 1 ] - angles[ 1 ] ) / 360 );
		self RotateTo( angles, time );
	}
}

swap_head()
{
	if ( !IsAi( self ) )
		return;

	if ( !IsDefined( self.characterinfo ) )
	{
		IPrintln( "^1Character cannot swap head: characterinfo is not defined" );
		return;
	}

	if ( !IsDefined( self.characterinfo.headalias ) )
	{
		IPrintln( "^1Character cannot swap head: headalias is not defined" );
		return;
	}

	if ( !IsDefined( self.characterinfo.headarray ) )
	{
		IPrintln( "^1Character cannot swap head: headarray is not defined" );
		return;
	}

	self Detach( self.headModel, "" );
	codescripts\character::attachhead( self.characterinfo.headalias, self.characterinfo.headarray );
}

move_player()
{
	// If the level.moveplayer_ent is not defined, grab the start of the daisy-chain
	if ( !IsDefined( level.moveplayer_ent ) )
	{
		level.moveplayer_ent = getstruct( "move_player_start", "targetname" );
	}
	else
	{
		// If the level.moveplayer_ent does not target anything, grab the start of the daisy-chain
		if ( IsDefined( level.moveplayer_ent.target ) )
		{
			level.moveplayer_ent = getstruct( level.moveplayer_ent.target, "targetname" );
		}
		else // We've reached the end of the chain so start from the beginning.
		{
			level.moveplayer_ent = getstruct( "move_player_start", "targetname" );
		}
	}
	
	if ( !IsDefined( level.moveplayer_ent ) )
		return;
	
	level.player SetOrigin( groundpos( level.moveplayer_ent.origin ) );
	level.player setPlayerAngles( level.moveplayer_ent.angles );
}