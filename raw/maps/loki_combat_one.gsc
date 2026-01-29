#include maps\_utility;
#include common_scripts\utility;
#include maps\loki_util;
#include maps\_anim;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PreCacheShader( "green_block" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "explosion" );
	flag_init( "combat_one_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

combat_one_start()
{
	player_move_to_checkpoint_start( "combat_one" );
	spawn_allies();

	array_spawn_function( GetSpawnerTeamArray( "axis" ), ::enemy_marker );
	
	foreach( ally in level.allies )
		ally SetGoalPos( ally.origin );

	level.redshirts = maps\loki_infil::create_redshirts();
	foreach( redshirt in level.redshirts )
	{
		node = GetNode( redshirt.first_goal_node, "targetname" );
		redshirt ForceTeleport( node.origin, node.angles );
	}
	
	level.allies[ 0 ] set_force_color( "r" );
	level.allies[ 1 ] set_force_color( "r" );
	level.allies[ 2 ] set_force_color( "r" );
	
	foreach( ally in level.allies )
	{
		ally.ignoresuppression = 0;
//		ally.script_suppression = 5;
//		ally.script_dontpeek = 0;
		ally.forcesuppression = 1;
//		ally.moveplaybackrate = 1.5;
	}
	
	node = GetNode( "cover_one_ally0_node1", "targetname" );
	level.allies[ 0 ] SetGoalNode( node );
	
	ais = cool_spawn( "combat_one_wave1_top", 5, true );
	foreach( ai in ais )
		ai thread enemy_attack_player_when_in_open();
	flag_set( "first_wave_spawned" );
}

combat_one()
{
	autosave_by_name_silent( "combat_one" );
	
	level.activeBreaks = 0;
	level.grenadeSplashing = false;
	tiles	  = GetEntArray( "breakTile", "targetname" );
	edgetiles = GetEntArray( "breakTileEdge", "targetname" );
	array_thread( tiles, ::do_tile_single, tiles, edgetiles );
//	level._effect[ "tilebreak" ] = LoadFX( "fx/misc/tile_break_explosion" );
	
	activate_trigger_with_targetname( "combat_one_trig_wave1_color" );
	
	level thread moving_cover_pre_tele();
	level thread track_ai();
	level thread trigger_wave2();
	level thread trigger_wave3();
	level thread trigger_wave4();
//	level thread player_in_combat_area();
//	level thread track_player_hiding();
	
	panels = GetEntArray( "sniper_sat_solarpanel", "targetname" );
	array_thread( panels, ::solarpanels_damage_think );
	
	flag_wait( "combat_one_done" );
}

moving_cover_pre_tele()
{
	node = GetEnt( "explosion_node1", "targetname" );
	node2 = GetEnt( "explosion_node2", "targetname" );
	Objective_Add( 1, "current", "get to the spot where things blow up!", node.origin );

//	wait 2;
	flag_wait( "objective" );

	level.player FreezeControls( true );
	level.player DisableWeapons();
	level.player HideViewModel();
	level.player TakeAllWeapons();
	
	player_rig   = spawn_anim_model( "player_rig" );
	player_legs  = spawn_anim_model( "player_legs" );
	in_your_face = spawn_anim_model( "in_your_face" );

	deadbody = maps\_vignette_util::vignette_actor_spawn( "deadbody", "deadbody" );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), deadbody, "j_spineupper" );
	PlayFXOnTag( getfx( "sp_blood_float" ), deadbody, "j_spineupper" );
	PlayFXOnTag( getfx( "factory_roof_steam_small_01" ), deadbody, "j_spineupper" );

	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 15, 15, 15, 15, 1 );
	
	level.explosion_parts					= [];
	level.explosion_parts[ "player_rig"	  ] = player_rig;
	level.explosion_parts[ "player_legs"  ] = player_legs;
	level.explosion_parts[ "in_your_face" ] = in_your_face;

	flag_set( "explosion" );
	
	level thread random_explosions( node.origin );

	solar_panels = GetEnt( "big_solar_panels", "targetname" );
	solar_panels Hide();
	solar_panels NotSolid();
	
	guys = get_all_wave_guys();
	foreach( guy in guys )
		guy thread die_from_explosion();

	foreach( redshirt in level.redshirts )
		redshirt thread die_from_explosion();
	
	node thread anim_single_solo( deadbody, "explosion_part1" );
	node anim_single( level.explosion_parts, "explosion_part1" );
	
	node2 anim_first_frame( level.explosion_parts, "explosion_part2" );
	level.player DoDamage( 50, level.player.origin );
	PlayFX( getfx( "explosion" ), in_your_face.origin );
	JKUprint( level.player.origin );
	JKUprint( in_your_face.origin );
//	wait 2;
//	in_your_face LinkToPlayerView( level.player, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ), false );
//	wait 2;
//	in_your_face Unlink();

	deadbody maps\_vignette_util::vignette_actor_delete();

	level notify( "stop_explosions" );
	flag_set( "combat_one_done" );
}

moving_cover_pre_tele_old()
{
	objective		   = getstruct( "objective", "targetname" );
	objective_end	   = getstruct( "objective_end", "targetname" );
	objective_tele	   = getstruct( "objective_tele", "targetname" );
	player_tele_node   = GetEnt( "moving_cover", "targetname" );
	in_your_face_start = getstruct( "in_your_face_start", "targetname" );

	Objective_Add( 1, "current", "get to the spot where things blow up!", objective.origin );
//	Objective_Position( 1, pos.origin );
	
	flag_wait( "objective" );
	
	Objective_Delete( 1 );
	
	level thread random_explosions( objective.origin );

	level.player FreezeControls( true );
	level.player DisableWeapons();
	level.player HideViewModel();
	level.player TakeAllWeapons();
	
	mover = Spawn( "script_model", level.player.origin );
	mover.angles = objective.angles;
	mover SetModel( "tag_origin" );

	spin_time = 6;
	
	arc = 20;
	level.player PlayerLinkToDelta( mover, "tag_origin", 1, arc, arc, arc, arc, true );
	mover RotateRoll( -360, spin_time );
	mover MoveTo( objective_end.origin, spin_time );
	
	in_your_face = Spawn( "script_model", in_your_face_start.origin );
	in_your_face.angles = in_your_face_start.angles;
	in_your_face SetModel( "fed_space_assault_body" );
	level.in_your_face = in_your_face;
	
	in_your_face_mover = Spawn( "script_model", in_your_face_start.origin );
	in_your_face_mover.angles = in_your_face_start.angles;
	in_your_face_mover SetModel( "tag_origin" );
	
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), in_your_face, "j_spineupper" );
	PlayFXOnTag( getfx( "sp_blood_float" ), in_your_face, "j_spineupper" );
	PlayFXOnTag( getfx( "factory_roof_steam_small_01" ), in_your_face, "j_spineupper" );
	
	in_your_face LinkTo( in_your_face_mover );
	in_your_face.animname = "generic";
	in_your_face assign_animtree();
	in_your_face thread maps\_anim::anim_generic_loop( in_your_face, "in_your_face_death", "stop_loop" );

	in_your_face_mover Hide();
	in_your_face_mover MoveTo( objective_end.origin + ( 40, 25, -15 ), spin_time );
	in_your_face_mover RotateRoll( 420, spin_time );
	
	level thread maps\loki_moving_cover::start_moving_cover( "pre_object_", 1, spin_time );

	wait spin_time;
	
	level thread lerp_fov_overtime( 0.01, 60 );
	PlayFX( getfx( "explosion" ), objective_tele.origin );
	Earthquake( 1, 1, level.player.origin, 1600 );

	pos_offset = ( 25, -38, -26 );  // distance, it's +up -down, it's -left +right
	angles_offset = in_your_face.angles * ( 1, 0.6667, 1 );
	in_your_face LinkToPlayerView( level.player, "tag_origin", pos_offset, angles_offset, false );
	IPrintLn( in_your_face_mover.angles );
	IPrintLn( in_your_face_mover.origin );
	in_your_face_mover Delete();
	
	level.player Unlink();
	level.player FreezeControls	( true );
	level.player SetOrigin( player_tele_node.origin );
	level.player SetPlayerAngles( player_tele_node.angles );
	
	level notify( "stop_explosions" );
	level thread random_explosions( objective_tele.origin );
	
	flag_set( "combat_one_done" );
}

track_ai()
{
	level endon( "explosion" );
	
	// make sure the initial wave has been spawned
	flag_wait( "first_wave_spawned" );
	
//	level delayThread( 1, ::add_dialogue_line, "Keegan", "Fuck!  They're gonna pick us off easy if we can't close the gap." );
//	level delayThread( 3, ::add_dialogue_line, "Keegan", "Switch to your rifle and let's clear a hole for our guys." );
	
	// ******** WAVE 2 ********
	guys = get_all_wave_guys();
	
	while( guys.size > 3 )
	{
		guys = get_all_wave_guys();
		waitframe();
	}

	wait RandomFloatRange( 0.75, 1 );
	ais = cool_spawn( "combat_one_wave1_top_support", 3, false );
	foreach( ai in ais )
		ai thread enemy_attack_player_when_in_open();
//	enemies_attack_player_when_in_open();
	guys = get_all_wave_guys();
	
	while( guys.size > 2 )
	{
		guys = get_all_wave_guys();
		waitframe();
	}

	wait RandomFloatRange( 0.75, 1.25 );
	JKUprint( "w2: via tracker" );
//	level delayThread( 0, ::add_dialogue_line, "Keegan", "Good!  Keep providing cover fire." );

	guys = get_all_wave_guys();
	foreach( guy in guys )
	{
		if( isdefined(guy) && isdefined(guy GetGoalVolume().targetname) && (guy GetGoalVolume().targetname == "combat_one_wave1" || guy GetGoalVolume().targetname == "combat_one_wave1_bottom" ))
		{
			level thread reassign_goal_volume( guy, "combat_one_wave1_fallback" );
		}
	}
	
	activate_trigger_with_targetname( "combat_one_trig_wave2" );
	activate_trigger_with_targetname( "combat_one_trig_wave2_color" );
	
	level waittill( "cool_spawn_finished" );
	
	// ******** WAVE 3 ********
	guys = get_all_wave_guys();
	while( guys.size >= 3 )
	{
		guys = get_all_wave_guys();
		waitframe();
	}

	wait RandomFloatRange( 0.75, 1.25 );
	JKUprint( "g: 3 via tracker" );

	activate_trigger_with_targetname( "combat_one_trig_wave3" );
	activate_trigger_with_targetname( "combat_one_trig_wave3_color" );
	
	level waittill( "wave3_spawned" );
	
	// ******** WAVE 4 ********
	guys = get_all_wave_guys();
	while( guys.size >= 2 )
	{
		guys = get_all_wave_guys();
		waitframe();
	}
	
	wait RandomFloatRange( 1.0, 2.0 );
	JKUprint( "g: 4 via tracker" );

	guys = get_all_wave_guys();
	foreach( guy in guys )
	{
		if( guy GetGoalVolume().targetname != "combat_one_final_fallback" )
		{
			level thread reassign_goal_volume( guy, "combat_one_final_fallback" );
		}
	}
	
	activate_trigger_with_targetname( "combat_one_trig_wave4" );
	activate_trigger_with_targetname( "combat_one_trig_wave4_color" );
}

trigger_wave2()
{
	level endon( "explosion" );

	trigger = GetEnt( "combat_one_trig_wave2", "targetname" );
	trigger waittill( "trigger" );
	
	JKUprint( "w2" );
	
	ais = spawn_space_ais_from_targetname( "combat_one_wave2" );
	foreach( ai in ais )
		ai thread enemy_attack_player_when_in_open();

	ais = cool_spawn( "combat_one_wave2_", 3, false );
	foreach( ai in ais )
		ai thread enemy_attack_player_when_in_open();
}

trigger_wave3()
{
	level endon( "explosion" );

	trigger = GetEnt( "combat_one_trig_wave3", "targetname" );
	trigger waittill( "trigger" );
	
	JKUprint( "w3" );

	ais = spawn_space_ais_from_targetname( "combat_one_wave3" );
	foreach( ai in ais )
		ai thread enemy_attack_player_when_in_open();
	
	level notify( "wave3_spawned" );
}

trigger_wave4()
{
	level endon( "explosion" );

	trigger = GetEnt( "combat_one_trig_wave4", "targetname" );
	trigger waittill( "trigger" );
	
	JKUprint( "w4" );

	ais = spawn_space_ais_from_targetname( "combat_one_wave4" );
	foreach( ai in ais )
		ai thread enemy_attack_player_when_in_open();
}


//*******************************************************************
//                                                                  *
//                          ACTORS                                  *
//                                                                  *
//*******************************************************************

enemy_attack_player_when_in_open()
{
	self endon( "death" );
	level.player endon( "death" );
	
	while( IsAlive( self ) )
	{
		flag_waitopen( "in_combat_area" );
		
		JKUprint( "ap" );
		self.favoriteenemy = level.player;
		self.baseaccuracy = 50;

		flag_wait( "in_combat_area" );

		JKUprint( "n-ap" );
		self.favoriteenemy = undefined;
		self.baseaccuracy = 1;
	}
}

cool_spawn( tname, count, instant )
{
	if( !IsDefined( instant ) )
		instant = false;
	
	ais = [];
	
	for( i = 0; i < count; i++ )
	{
		ai = spawn_space_ai_from_targetname( tname + i, instant );
		ais = add_to_array( ais, ai );
		
		if( !instant )
			wait RandomFloatRange( 1.5, 1.75 );
	}
	
	level notify( "cool_spawn_finished" );
	
	return ais;
}

die_from_explosion()
{
	self endon( "death" );
	
	self anim_generic( self, "explosion_part1" );
	self Kill();
}

get_all_wave_guys()
{
	guys  = get_ai_group_ai( "combat_one_wave1" );
	guys1 = get_ai_group_ai( "combat_one_wave2" );
	guys2 = get_ai_group_ai( "combat_one_wave3" );
	guys3 = get_ai_group_ai( "combat_one_wave4" );
	guys  = array_merge( guys, guys1 );
	guys  = array_merge( guys , guys2 );
	guys  = array_merge( guys , guys3 );
	
	guys = array_removeDead_or_dying( guys );
	
	return guys;
}


//*******************************************************************
//                                                                  *
//                            MISC                                  *
//                                                                  *
//*******************************************************************

player_in_combat_area()
{
	while( 1 )
	{
		if( flag( "in_combat_area" ) )
		   IPrintLn( "player safe" );
		waitframe();
	}
}

solarpanels_damage_think()
{
	self SetCanDamage( true );
	self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
	wait 0.25;
	self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
	
	nodes = GetNodesInRadius( self.origin, 48, 0, 48, "cover" );
	foreach( node in nodes )
	{
		node DisconnectNode();
		BadPlace_Cylinder( "foo", 0, node.origin, 32, 32, "axis", "allies" );
		
		guys = get_all_wave_guys();
		foreach( guy in guys )
		{
			if( guy NearNode( node ) )
			{
				JKUprint( "crap my node sucks now" );
			}
		}
	}
	
	self Hide();
	self NotSolid();
}

random_explosions( pos )
{
	level.player endon( "death" );
	level endon( "stop_explosions" );
	
	PlayFX( getfx( "explosion" ), pos );
	Earthquake( 0.6, 1, level.player.origin, 1600 );
	
	while( 1 )
	{
		wait RandomFloatRange( 1, 3 );
		PlayFX( getfx( "explosion_small" ), pos );
		Earthquake( 0.3, 1, level.player.origin, 1600 );
	}
}

track_player_hiding()
{
	hide_vols = GetEntArray( "combat_one_hide", "targetname" );
	
	level.hiding_icon = maps\_hud_util::createIcon( "green_block", 16, 16 );
	level.hiding_icon.alignX = "right";
	level.hiding_icon.alignY = "middle";
	level.hiding_icon.vertAlign = "top";
//	level.hiding_icon.x = 82;
//	level.hiding_icon.y = -501;
	level.hiding_icon.alpha = 0;
	level.hiding_icon.hidewhendead = false;
	level.hiding_icon.hidewheninmenu = false;
	level.hiding_icon.sort = -205;
	level.hiding_icon.foreground = true;
	
	level thread set_player_hidden();

//	foreach( hide_vol in hide_vols )
//		hide_vol thread track_hiding_think();
}

track_hiding_think()
{
	self endon( "death" );
	
	level.last_used_cover_vol = 0;
	
	while( 1 )
	{
		if( level.player IsTouching( self ) && self != level.last_used_cover_vol )
		{
			IPrintLn( "here" );
			flag_set( "combat_one_player_hiding" );
//			self = level.last_used_cover_vol;
			level.hiding_icon.alpha = 0.8;
		}
		else if( level.player IsTouching( self ) )
		{
		}
		else if( level.player_in_cover )
		{
			flag_clear( "combat_one_player_hiding" );
			level.player_in_cover = 0;
			level.hiding_icon.alpha = 0.0;
		}
		waitframe();
	}
}

set_player_hidden()
{
	level.player endon( "death" );
	
	while( 1 )
	{
		flag_wait( "combat_one_player_hiding" );
		
//		IPrintLn( "player being ignored" );
		level.hiding_icon.alpha = 0.8;
		level.player.ignoreme = 1;

		flag_waitopen( "combat_one_player_hiding" );
		
//		IPrintLn( "player being tracked" );
		level.hiding_icon.alpha = 0;
		level.player.ignoreme = 0;
	}
}


//*******************************************************************
//                                                                  *
//                          TILES                                   *
//                                                                  *
//*******************************************************************


do_tile_single( tiles, edgeTiles )
{
	get_touching_tiles(tiles);
	get_edge_tiles( edgeTiles );
	self.TileAlive = true;
	self SetCanDamage( true );
	self endon ( "tileDeath" );
	point = undefined;
	while( true)
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
	
		if( type == "MOD_GRENADE_SPLASH" || type == "MOD_EXPLOSIVE" )
		{
			if( type == "MOD_EXPLOSIVE" && attacker.classname == "script_model" )
				point = attacker GetCentroid();
			thread doGrenadeSplash(point);
			continue;
		}
		if( level.activeBreaks < 10  )
			break;
	}
	self thread tile_death( point );
}

doGrenadeSplash(point)
{
	if( level.grenadeSplashing )
		return;
	level.grenadeSplashing = true;
	ents = get_array_of_closest( point, GetEntArray( "breakTile", "targetname" ),undefined,75 );
	ents = featherEnts(ents);
	array_thread( ents, ::tile_death, point );
	thread removeGrenadeSplash();
}

featherEnts(ents)
{
	inent = true;
	returnarray = [];
	foreach( ent in ents )
	{
		if ( inent )
			returnarray[ returnarray.size ] = ent;
		inent = !inent;
	}
	return returnarray;
}

removeGrenadeSplash()
{
	wait 0.05;
	level.grenadeSplashing = false;
}

get_touching_tiles( tiles )
{
	self.touchingTiles = [];
	foreach ( tile in tiles )
		if ( tile IsTouchingLinktos( self ) && tile != self)
			self.touchingTiles[ self.touchingTiles.size ] = tile;
}

get_edge_tiles( tiles )
{
	self.edgeTiles = [];
	foreach ( tile in tiles )
		if ( tile IsTouchingLinktos( self ) && tile != self)
			self.edgeTiles[ self.edgeTiles.size ] = tile;
}

IsTouchingLinktos( targetEnt )
{
	return targetEnt IsLinkedTo(self) || self IsLinkedTo( targetEnt );
}

IsLinkedTo( targetEnt )
{
	links = get_linked_ents();
	foreach ( link in links )
		if ( link == targetent )
		{
			Assert( link != self );
				return true;
		}
	return false;
}

tile_spider( deathVec )
{
	if( !self.TileAlive )
		return;
	spiderStruct = SpawnStruct();
	spiderStruct.baseTile = self;
	spiderStruct.TestedArray = [];
	spiderStruct.ToTestArray = self.touchingTiles;
	spiderStruct.foundWall = false;
	spiderStruct.livingEdgeConnections = 0;
	foreach( tile in self.touchingTiles )
		if( tile.TileAlive && tile.edgeTiles.size )
			spiderStruct.livingEdgeConnections++;
	
	
	while( !spiderStruct.foundWall && spiderStruct.ToTestArray.size > 0 )
	{
		tester = spiderStruct.ToTestArray[0];
		spiderStruct.ToTestArray = array_remove( spiderStruct.ToTestArray, tester );
		if( !tester.TileAlive )
			continue;
		tester tile_attached_to_edge(spiderStruct);
	}
	
	if( spiderStruct.foundWall && nonEdgeMaintains(spiderStruct) )
		return;
	self thread tile_death(deathVec);
}

nonEdgeMaintains(spiderStruct)
{
	if( self.edgeTiles.size > 0 )
		return true;
	if( spiderStruct.livingEdgeConnections > 1 )
		return true;
	return true;
}

tile_attached_to_edge(spiderStruct )
{
	if( array_contains(spiderStruct.TestedArray, self ) )
		return ; 
	else
		spiderStruct.TestedArray[spiderStruct.TestedArray.size] = self;
	
	if( self.edgeTiles.size > 0 )
		spiderStruct.foundWall = true;
	
	foreach ( tile in self.touchingTiles )
	{
		if( !tile.TileAlive ) 
			continue;
		if( !array_contains(spiderStruct.TestedArray, tile ) )
			spiderStruct.ToTestArray[spiderStruct.ToTestArray.size] = tile;
	}
}

tile_death( deathVec )
{
	if( !self.TileAlive )
		return;
	level.activeBreaks += 1;
	 self notify ( "tileDeath" );
	self.TileAlive = false;
	//vec = self GetCentroid() + ( deathVec );
	vec = deathVec;
	
	self RotateVelocity( vec , 0.5 );
	self MoveGravity( (0,0,-3), 1 );

	//self delayCall( 0.45, ::hide );
	foreach( tile in self.touchingTiles )
		tile delaythread( RandomFloatRange(0.05,0.1), ::tile_spider, deathVec );
	
	thread decrementLevelBreaks();
	thread fallingTileEffect();
}

fallingTileEffect()
{
	while( self.origin[2] > -64 )
		wait 0.05;
	origin = set_z(self.origin,-64);
//	PlayFX( getfx("tilebreak"), origin);
}

decrementLevelBreaks()
{
	wait 0.05;
	level.activeBreaks--;
}

