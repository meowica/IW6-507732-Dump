#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\jungle_ghosts_util;
#include vehicle_scripts\_apache_player_raining_missile;

runway_setup()
{
	thread runway_vehicles();
	thread runway_sat_launch();
	thread escape_play_slide_fx_on_player();
	

	thread escape_globals( "runway" );

}

runway_sat_launch()
{
	
	flag_wait( "field_end" );
	
	missile01_start = getent( "missile01_start", "targetname" );
	missile01_end = getent( "missile01_end", "targetname" );
	icbm_missile01 = getent( "icbm_missile01", "targetname" );
	
	missile_move_time = 70; //50
	thread sat_launch_sound_earthquake_rumble( icbm_missile01 );
	icbm_missile01 linkto( missile01_start );
	missile01_start moveto( missile01_end.origin, missile_move_time, 10, 0 );
	missile01_start RotateTo ((45,0,0), 15, 15, 0);
				 
	// icbm_missile thread maps\_utility::playsoundontag( "parachute_land_player" );
	playfxontag( level._effect[ "smoke_geotrail_icbm" ], icbm_missile01, "tag_nozzle" );
	missile01_start waittill( "movedone" );
	icbm_missile01 delete();

}

sat_launch_sound_earthquake_rumble( missile )
{
	rumble_time = 4;
	level.player thread play_sound_on_entity( "jg_earthquake_lr" );
	//missile thread play_sound_on_entity( "jg_earthquake_lr" );
	
	earthquake( 0.2, 8, level.player.origin, 8000 );
	
	level.player playrumblelooponentity( "damage_heavy" );
	wait( rumble_time );
	level.player stoprumble( "damage_heavy");
	
}

runway_vehicles()
{
	flag_wait("runway_halfway");

	thread runway_detect_player_stance_and_movement();
	
	wait (1);
	
	choppers = spawn_vehicles_from_targetname_and_drive( "departing_apache" );
	wait .20;
	array_call( choppers, ::vehicle_turnengineoff );
	
	foreach( chopper in choppers )
	{
		if( isdefined( chopper.script_noteworthy ) )
		{
			if( chopper.script_noteworthy == "runway_apache" )
				level.apache1 = chopper;
		}
		else
			level.cliff_chopper = chopper;
	}
	
	level.apache1 thread runway_apache_logic( "runway" );
		
	array_call( choppers, ::vehicle_turnengineon );
	
	level.cliff_chopper thread cliff_chopper_shoot_over_players_head();
	wait ( 3 );
	maps\jungle_ghosts_util::do_lightning();

	wait 3;
	
	if (!flag("choppers_saw_player"))
		thread cliff_choppers_move_on(choppers);
}

cliff_choppers_move_on(choppers)
{	
	flag_set ("choppers_are_gone");
		
	foreach( i, chopper in choppers )
	{
		org = getent("runway_choppers_flyaway" + i, "targetname");
		chopper setlookatent( org );
		chopper SetVehGoalPos(org.origin, 1);
		wait 1;
	}
	
	wait 3;

	
	foreach( i, chopper in choppers )
	{
		org = getent("runway_choppers_flyaway" + i, "targetname");
		chopper setlookatent( org );
		chopper SetVehGoalPos(org.origin, 1);
		chopper Vehicle_SetSpeed(60, 15, 1);
		wait 2;
	}
	
	wait 20;
	
	foreach( i, chopper in choppers )
	{
		chopper delete();
	}
	 
}

runway_detect_player_stance_and_movement()
{
	level endon ("choppers_are_gone");
	
	flag_wait("choppers_get_down");
	
	time_to_react = 1.2;
	wait time_to_react;
	
	//IPrintLnBold("starting react");
	
	start_origin = level.player.origin;
	
	distance_player_can_move_and_not_be_seen = 64;
	
	seen = false;
	while (!seen)
	{
		if (level.player GetStance() != "prone" || Distance2D(start_origin, level.player.origin) > distance_player_can_move_and_not_be_seen)
			seen = true;

		waitframe();
	}
	
	flag_set("choppers_saw_player");
}

cliff_chopper_shoot_over_players_head()
{
	//self = chopper
	//todo finish the attack logic on this guy. he doesnt do anything after shooting the missiles currently
	self waittill_notify_or_timeout("attack_position", 3);
	self setlookatent( level.player );
	
	if (!flag("choppers_saw_player"))
		return;
	
	shot_amount = 2;
	tag = "tag_missile_left";
	for( i= 0; i< shot_amount; i++ )
	{
		start = self gettagorigin(  tag ) -( 0, 0, 60 );
		end = level.player geteye() + (0,0, 150 );
		missile = magicbullet( "rpg_straight", start, end );//rpg_straight apache_raining_missile
		missile thread escape_earthquake_on_missile_impact();
		wait .25;
		
		if( tag == "tag_missile_left" )
			tag = "tag_missile_right";
		else
			tag= "tag_missile_left";
	}

}

runway_apache_logic( start )
{
	self endon( "death" );
	switch ( start  )
	{
		default:
		case "runway":	
			self thread godon();			
			self waittill("attack"); //noteworthy on node
			self thread godon(); //might be off at this point
				
			flag_wait_any("choppers_saw_player", "choppers_are_gone");
			
			if (flag("choppers_saw_player"))
			{
				music_play( "mus_jungle_escape" );
				self delaythread( 5, ::turret_burst_fire_at_ent, level.player );
				self setlookatent( level.player );
			}

			
		case "jungle":
			
			if (flag("choppers_saw_player"))
			{
				self escape_apache_pressure_player_until_flag( "slide_start" );
			}
			
			flag_wait( "slide_start" );
			
			if (flag("choppers_saw_player"))
			{
				attack_node = getent_or_struct( "attack_trees", "script_noteworthy" );			
				self setvehgoalpos( attack_node.origin, 1 );
				self vehicle_setspeedimmediate( 50 );
				lookat_ent = getent( "attack_trees_lookat", "script_noteworthy" );
				self setlookatent( lookat_ent );
			                    
				self waittill("goal");
			
				trees = getentarray("dest_top", "script_noteworthy" );
				offset_min = 50;
				offset_max = 200;
			
				foreach( tree in trees )
				{
					spot = tree.origin;
					bullet_count = randomintrange( 3, 5 );
					for(i = 0; i< bullet_count; i++)
					{				
						offset = randomintrange( offset_min, offset_max );	
						if( cointoss() )
						{
							offset = offset * -1;
						}				
						self setturrettargetent( tree );
						wait(.05);
						self fireweapon();	
						wait( randomfloatrange( .05, .15 ) );
					}				
				}
			}
			
		case "river":	
			
			flag_wait( "escape_halfway" );
			
			if (flag("choppers_saw_player"))
			{
				attack_node = getent_or_struct( "attack_river_jump", "targetname" );			
				self setvehgoalpos( attack_node.origin, 1 );
				self vehicle_setspeedimmediate( 50 );
				self setlookatent( level.player );
				
				self thread turret_burst_fire_at_ent( level.player, 50 );			
				//flag_wait( "fastropers_dead");
				self thread turret_burst_fire_at_ent( level.player, 50 );
				wait 3;
				self escape_apache_pressure_player_until_flag( "player_at_river" );
			}
			
			flag_wait("player_at_river");
			
			if (flag("choppers_saw_player"))
			{
				self clearlookatent();
				start_node = getent_or_struct( "river_path_start", "targetname" );
				self thread vehicle_paths( start_node );
				self vehicle_setspeed( 50, 25 );
			}
			
			flag_wait("player_crossed_river");
			
			if (flag("choppers_saw_player"))
			{
				self setlookatent( level.player );		
			}
			
			trigger_wait_targetname( "river_slide_trig" );
			
			if (flag("choppers_saw_player"))
			{
				structs = getstructarray( "waterfall_missile_impact", "targetname" );
				wait 1;
				self  thread escape_apache_shoot_missiles_at_structs( structs );
				
				level.player delaycall( .5, ::playsound,  "slowmo_bullet_whoosh" );
				level.player delaycall( 1, ::playsound,  "slowmo_bullet_whoosh" );
				level.player delaycall( 1.5, ::playsound,  "slowmo_bullet_whoosh" );
			}
			
			flag_wait("final_read");
			
			if (flag("choppers_saw_player"))
			{
				ent = spawn( "script_origin", level.player geteye() +( 0, 0, 50 ) );
				ent linkto( level.player );
				
				bullet_count = 20;
				for( i = 0; i< bullet_count;  i++ )
				{
					self setturrettargetent( ent, (100, 100, 50 ));
					self fireweapon();		
					wait( randomfloatrange( .05, .15) );					
				}	
			}
	}
	
}

runway_apache_turret_logic()
{
	self setmode( "manual" );
	self setturretteam( "axis" );
	self setdefaultdroppitch( 0 );
}

escape_apache_pressure_player_until_flag( _flag )
{
	offset = 60;
	self notify( "stop_shooting" );
	self endon( "stop_shooting" );
	level endon( _flag );
	bullet_count = randomintrange( 15, 30 );
	while( ! flag( _flag ) )
	{		
		self setturrettargetent( level.player,  (offset, offset, 10) );
		wait(2);
		
		for(i = 0; i< bullet_count; i++)
		{
			if( cointoss() )
				offset *= -1;
			
			self setturrettargetent( level.player,  (offset, offset, 10) );
			wait(.05);
			self fireweapon();		
		}	
		
		offset -= 10;
		if( offset < 0 )
			offset = 0;
		
		//give the player time to do whatever we need him to do
		wait ( randomintrange( 2, 4 ) );
	}
}


turret_burst_fire_at_ent( target_ent, bullet_count )
{
	// self = apache minigun
	self endon("death");
	if(!isdefined( bullet_count) )
		bullet_count = randomintrange(80, 170);

	if(level.gameskill < 2)
	{		
		offset_min = 150;
		offset_max = 200;

	}
	else if(level.gameskill == 2)
	{	
		offset_min = 100;
		offset_max = 120;	
	}	
	else
	{
		offset_min = 50;
		offset_max = 100;
	}
	
	offset = randomintrange( offset_min, offset_max );
	self setturrettargetent( target_ent,  (offset, offset, 0) );	
	
	wait(2);
		
	for(i = 0; i< bullet_count; i++)
	{
		offset = randomintrange( offset_min, offset_max );
		//self thread draw_line_for_time( self.origin,  level.ground_player.origin + (offset, offset, 0), 1, 0, 0, 1 );	
		if( cointoss() )
		{
			offset = offset * -1;
		}	
		self setturrettargetent( target_ent,  (offset, offset, 0) );
		wait(.05);
		self fireweapon();		
	}	
		
	self notify("done_shooting");
}	

get_target_structs()
{
	array = [];
	if ( isdefined( self.target ) )
		array = getstructarray( self.target, "targetname" );
	return array;
}

escape_globals( start )
{
	escape_setup_trees();
	thread escape_player_speed( start );
	thread escape_friendly_movement( start );
	thread escape_enemies_and_vehicles( start );
	
	if (flag("choppers_saw_player"))
		thread escape_scripted_destruction( start );
	
	thread escape_player_jump();
	thread escape_vo( start );
	
	thread water_push_player();
	flag_wait("player_slid");
	level.rain_effect = getfx( "rain_heavy" );
	

	
}

water_push_player()
{
	
	water_volume = get_target_ent("water_push");
	//anglesToFacing = VectorToAngles(getstruct(water_volume.target, "targetname").origin - water_volume.origin);
	anglesToFacing = VectorNormalize(getstruct(water_volume.target, "targetname").origin - water_volume.origin);
	
	push_fraction = 0;
	
	while (1)
	{
		if (water_volume IsTouching(level.player))
		{
			push_fraction = push_fraction + 0.5;
			level.player DisableWeapons();
		}
		else
		{
			push_fraction = 0;	
			level.player EnableWeapons();
		}
		push_fraction = min(push_fraction, 12);
		
		level.player PushPlayerVector (anglesToFacing * push_fraction, 0);
		wait (0.1);
	}

	
}


escape_player_speed( start )
{
	switch ( start )
	{
		default:
		case "runway":	
			flag_wait( "runway_halfway" );
			level.player setmovespeedscale( .92 );	
			setsaveddvar( "player_sprintspeedscale", 1.5 );
			
		case "jungle":
			flag_wait( "player_slid" );
			level.player setmovespeedscale( .92 );	
			
			setsaveddvar( "player_sprintspeedscale", 1.5 ); //default 1.5
			//setsaveddvar( "player_sprinttime", 10 );//4 default
			setsaveddvar( "player_sprintunlimited", 1 );
			
		case "river":
	
		
			break;
	}

}

escape_player_went_right_logic()
{
	//self = trig
	self waittill("trigger");
	structs = getstructarray( "player_escape_right_structs", "targetname" );
	level.stryker thread escape_stryker_attacks_structs( structs );
	
}


escape_scripted_destruction( start )
{
	switch ( start )
	{
		default:
		case "runway":
		case "jungle":
			wait 1;
			flag_wait( "slide_start" );
			//wait 4;
			//tag_flash2 tag_flash11
			start = (1104, 12994, 1468 );
			target_vec = ( 274, 12416, 927 );
			missile = magicbullet( "rpg_straight", start, target_vec, level.player );
			missile thread escape_earthquake_on_missile_impact();
			wait .5;
			missile = magicbullet( "rpg_straight", start, target_vec, level.player );
			missile thread escape_earthquake_on_missile_impact();
			
		case "river":	
	}
	
}

escape_socr_turret_own_target( _target, waittill_notify )
{
	self.maxhealth = 99999999;
	self.health = self.maxhealth;
	//self setdefaultdroppitch( 0 );
	//self setleftarc( 180 );
	//self setrightarc( 180 );
	//self settoparc( 360 );
	//self setbottomarc( 10 );
	self setmode("manual");
		
	targetent = spawn ("script_origin", _target.origin -( 0,0,40 ));
	targetent linkto( _target );
	
	if( isdefined( waittill_notify ) )
		self waittill( waittill_notify );
	
	//wait( randomfloatrange( .5, 2 ) );
	self settargetentity( targetent );
	bullet_count = randomintrange( 60, 70 );
	self startbarrelspin();
	wait 1;
	_target thread escape_chopper_timeout_death();
	_target clearlookatent();
	if(!flag("choppers_attacked" ) )
		delaythread( 1.5, ::flag_set,  "choppers_attacked" );
	
	while( 1 )
	{
		for( i = 0; i < bullet_count; i ++ )
		{
			//thread draw_line_from_ent_for_time( self, targetent.origin, 1, 0, 0, .05 );
			self settargetentity( targetent );
			self shootturret();
			wait(  randomfloatrange(.05, .15 ) );
		}	
		
		if(!isdefined( _target ) )
			break;
		else if(  _target vehicle_is_crashing() )
			break;
	}	
	
	//self cleartargetentity();
	self stopbarrelspin();
	//targetent unlink();
	//targetent delete();
}

escape_chopper_timeout_death()
{
	self endon("death");
	wait 5;
	if( isalive( self ) || !self vehicle_is_crashing() )
		self force_kill();

}

escape_apache_shoot_missiles_at_structs( structs, optional_notify )
{
	if( isdefined( optional_notify ) )
		self waittill( optional_notify );
	
	tag = "tag_missile_left";
	foreach( struct in structs )
	{
		start = self gettagorigin(  tag ) -( 0, 0, 60 );
		missile = magicbullet( "rpg_straight", start, struct.origin );
		missile thread escape_earthquake_on_missile_impact();
		wait .2;
		
		if( tag == "tag_missile_left" )
			tag = "tag_missile_right";
		else
			tag= "tag_missile_left";
	}
}


escape_friendly_movement( start )
{
	
	red_guys = [];
	blue_guys=[];
	
	while( !isdefined( level.squad ) )
		wait .10;
	
	while( level.squad.size != 4 )
		wait .10;
	
	foreach( i, guy in level.squad )
	{
		guy disable_pain();
		if( guy.script_forcecolor == "r" )
			red_guys= add_to_array( red_guys, guy);
		else
			blue_guys = add_to_array( blue_guys, guy);
	}
	
	switch ( start )
	{
		default:
	   	case "runway":	
			//flag_wait( "squad_to_escape_slide" );
			wait 2;
		
			
			wait( 15 );
			autosave_by_name("to_slide");
			//activate_trigger_with_targetname( "squad_to_escape_slide" );
			
			flag_wait( "runway_halfway" );
			array_thread (level.squad, ::disable_ai_color);
			array_thread(level.squad, ::runway_stop_in_place);	
			array_call(level.squad, ::AllowedStances, "prone");							// make everyone get down
		
			flag_wait_any("choppers_are_gone", "choppers_saw_player");
			array_call(level.squad, ::AllowedStances, "stand", "crouch");		// allow everyone back up
			array_thread(level.squad, ::disable_cqbwalk);								// make them walk normally
			array_thread (level.squad, ::enable_ai_color);
						
			waitframe();
			activate_trigger_with_targetname( "squad_hill_bottom" );
			
			red_guy_went = false;
			//iprintln( "waiting on slide anims." );
			foreach(i, guy in level.squad )
			{
				if( guy.script_forcecolor == "r" && !red_guy_went )
					red_guy_went = true;
				else if( guy.script_forcecolor == "r" && red_guy_went )
				{
					guy thread escape_temp_ai_slide( "player_slide_arrive", 1 );
					continue;
				}
				
				guy thread escape_temp_ai_slide();
				
				wait 1;
			}
		
		case "jungle":			
			flag_wait( "slide_start" );		

			foreach( guy in level.squad )
			{
				guy thread enable_sprint();
				guy.perfectaim = true;
				guy.baseaccuracy = 90;
				guy.grenadeammo = 0;
			}

			level.squad = array_randomize( level.squad );
			
			turnaround_2 = getstruct( "turnaround_2", "targetname" );
			turnaround_3 = getstruct( "turnaround_3", "targetname" );
			
			level.squad[0] thread escape_friendly_does_anim_off_struct( turnaround_2 );
			wait( .3);
			level.squad[2] thread escape_friendly_follow_spline( "tree_run_middle" );
			wait( .3);
			level.squad[1] thread escape_friendly_does_anim_off_struct( turnaround_3 );		
			wait( .3 );
			level.squad[3] thread escape_friendly_follow_spline( "tree_run_right" );
			wait 1;
			level.squad[3] thread escape_friendly_throws_smoke();
		
			wait 1;
			activate_trigger_with_targetname( "squad_cover_rock" );	
			
		case "river":				
			flag_wait( "escape_halfway" );
			
			array_thread( red_guys, ::enable_ai_color );
			
			activate_trigger_with_targetname( "red_covers");			
			activate_trigger_with_targetname( "blue_to_river");	
			
			waterfall_jump_anim_ents = getstructarray( "waterfall_jump", "targetname" );
			swim_start_ents = getstructarray( "waterfall_ai_land", "targetname" );
			
			flag_wait("player_at_river");
			
			foreach( i, guy in level.squad )
			{
				guy thread escape_friendly_jumps_waterfall_to_swimming( waterfall_jump_anim_ents[i], swim_start_ents[i] );
			}

			
		case "waterfall":
			
			flag_wait( "choppers_attacked" );
			wait 6;
			activate_trigger_with_targetname( "squad_to_boats" );
			wait 5;
			iprintlnbold( "end of scripting" );
	}
	
}

runway_stop_in_place()
{
	self SetGoalPos(self.origin);
}

escape_vo ( start )
{
	switch ( start )
	{
		case "runway":
			
			flag_wait("field_end");
			thread add_dialogue_line( "hesh", "Is that what I think it is?" );
			wait 2;
			thread add_dialogue_line( "merick", "That's either a missile, or it's headed to orbit." );
			wait 2;
			thread add_dialogue_line( "keegan", "We should take a closer look." );
			
			flag_wait( "runway_halfway" );
			
			//ghost 2: choppers incoming!
			level.alpha2 smart_radio_dialogue( "jungleg_gs2_choppersincoming" );
			flag_set("choppers_get_down");
			
			//ghost 1: change of plan. this way!
			level.alpha1 smart_radio_dialogue( "jungleg_gs1_changeofplanthis" );
			
			wait( 0.5 );
			//ghost 1: whiplash we are moving to lzed black! apaches are giving chase over!
			level.alpha1 smart_radio_dialogue( "jungleg_gs1_whiplashwearemoving" );
			
			//boat driver: copy gamma team, adjusting course. 
			level.player play_sound_on_entity( "jungleg_btd_copygammateamadjusting" );
			
		case "jungle":
			flag_wait("slide_start");
			
			wait 4;
			//ghost 1: c'mon, this way!
			level.alpha1 smart_radio_dialogue( "jungleg_gs1_cmonthisway" );
			
			wait( 5 );
			//ghost 1: keep moving!
			level.alpha1 smart_radio_dialogue( "jungleg_gs1_keepmoving" );
			
			flag_wait( "escape_halfway" );
			//ghost 2: river up ahead!
			level.alpha2 smart_radio_dialogue( "jungleg_gs2_riverupahead" );
				
		default:
			break;
	}
	
}

air_time = 2;
underwater_time = 2.5;

escape_player_jump()
{
	flag_wait( "player_crossed_river");
	thread escape_mg_bullets_at_player_river_run();
	thread escape_player_water_logic();
	
	
	thread new_player_jump();
	
	return;
}

new_player_jump()
{
	edgeref = getstruct( "struct_player_bigjump_edge_reference", "targetname" );
	groundref = getstruct( "struct_player_recovery_animref", "targetname" );		
	jumpforward = anglestoforward( edgeref.angles );
	player = level.player;
	
	if( level.start_point != "underwater" )
	{
				
		jumpstart_trig = getent( "player_waterfall_jump_trig", "targetname" );
		edgeref = getstruct( "struct_player_bigjump_edge_reference", "targetname" );
		groundref = getstruct( "struct_player_recovery_animref", "targetname" );
		
		jumpforward = anglestoforward( edgeref.angles );
		thread player_jump_watcher();		
				
		// takes care of a player who missed the cool animated jump and just fell
		thread escape_player_fall_check();
		level endon( "player_fell_off_waterfall" );
		
		while( 1 )
		{
			breakout = false;
			
			while( level.player istouching( jumpstart_trig ) )
			{
				flag_wait( "player_jumping" );
//				if( player_leaps( jumpstart_trig, jumpforward, 0.915, true ) )  // 0.925
//				{
					breakout = true;
					break;
//				}
				wait( 0.05 );
			}
			
			if( breakout )
			{
				break;
			}
			wait( 0.05 );
		}
		
		flag_set( "player_jump_watcher_stop" );
		
		//flag_set( "roofrun_player_bigjump_start" );
	}
	player takeallweapons();
	
	animname = "player_rig";
	jump_scene = "waterfall_jump";
	anime_jump = level.scr_anim[ animname ][ jump_scene ];
	
	// figure out our start point
	// move the edge reference to the player location, this math only works because we are moving it in a cardinal direction
	startpoint = ( edgeref.origin[ 0 ], player.origin[ 1 ], edgeref.origin[ 2 ] );
	startangles = edgeref.angles;
	animstartorigin = getstartorigin( startpoint, startangles, anime_jump );
	animstartangles = getstartangles( startpoint, startangles, anime_jump );
	
	// spawn our animref spot
	animref = spawn( "script_origin", startpoint );
	animref.angles = startangles;
	
	// spawn & set up the rig
	player_rig = spawn_anim_model( animname, animstartorigin );
	player_rig.angles = level.player.angles;
	player_rig hide();
	level thread escape_waterfall_player_link_logic( player_rig );
	// don't show the rig until after the player has blended into the animation
	thread bigjump_player_blend_to_anim( player_rig );	
	player_rig delaycall( 1, ::show );
	
	animref thread anim_single_solo( player_rig, jump_scene );

	// cool slo mo end shit
	setslowmotion( 1, 0.5, 0.5 );
	wait 2.5;
	setslowmotion( 0.5, 1.5, 0.5 );
	wait 1;
	setslowmotion( 1.5, 0.3, 0.1 );
	wait 3;	
	setslowmotion( 0.3, 1, 1 );

	
}
escape_waterfall_player_link_logic( player_rig )
{
	if( isdefined(  player_rig ) )
	{
		player_rig waittill("single anim");
		level.player unlink();
		player_rig delete();
	}
	else
	{
		flag_wait("final_read");
		wait 1;
	}

	ent = spawn_tag_origin();
	ent.origin = getstruct("in_the_water","targetname").origin;
	ent.angles = getstruct("in_the_water","targetname").angles;
	
	level.player SetOrigin(ent.origin);
	level.player SetPlayerAngles(ent.angles);
	
	level.player.float_ent = ent;
	level.player PlayerLinkTo(ent);
	
	time = 0.6;
	thread maps\jungle_ghosts_jungle::player_heartbeat();
	
	//level.mover = level.player spawn_tag_origin();
	//level.player playerlinkto( level.mover );
	
	river_run = spawn_vehicle_from_targetname("river_run");
	underwater = getstruct("player_underwater", "targetname" );
	
	//if( GetDvarInt( "underwater_test", 1 ) )
	//	level waittill("never");
	//else
		//wait underwater_time;
	wait 1.5;
	//move above water
	time = 4;
	above_water = getstruct("waterfall_player_land", "targetname" );
	level.player.float_ent moveto( level.player.float_ent.origin + (0,0,233), 2.5, 0.2, 0.7);
	
	//level.mover moveto( above_water.origin, time );
	//level.player notify_delay( "stop_underwater_fx",  time*.5 );
	wait( 2.2 );

		level.player SetStance("stand");

	level.player SetClientTriggerAudioZone( "jungle_ghosts_exfil", 0.8 );	
	
	//above water now
	//river_run waittill("reached_end_node");
	level.player notify( "stop_underwater_fx" );
	flag_set("player_surfaces" );
	
	level thread  maps\jungle_ghosts_util::player_swim_think();
	
	level.player thread vision_set_fog_changes( "jungle_boat_rescue", .05 );
	level.player stopshellshock();	
	level notify("stop_player_heartbeat");
	level.player setwatersheeting( 1, 1.5 );
	level.player thread play_sound_on_entity( "weap_sniper_breathin" );
	

	wait ( 0.7 );
	level.player thread play_sound_on_entity( "weap_sniper_breathin" );
	level.player unlink();

	
	if( GetDvarInt( "underwater_test", 1 ) )
		level waittill("never");	
		
	wait ( 6.0 );	
	level.player SetClientTriggerAudioZone( "jungle_ghosts_fade_out", 5.3 );
	wait ( 4.0 );
	nextmission();
}

escape_player_fall_check()
{
	level endon("player_jump_watcher_stop");
	trig = getent("player_fall_check", "targetname");
	trig waittill("trigger");
	
	trig delete();
	flag_set("player_fell_off_waterfall");
	
	thread escape_waterfall_player_link_logic();
	level.player disableweapons();
	level.player enableinvulnerability();
	
}

escape_player_water_logic()
{
	//player hits water
	flag_wait("final_read");
	level.player thread play_sound_on_entity( "scn_jungle_player_plunge" );//scn_jungle_player_plunge water_land_splash
	level.player SetClientTriggerAudioZone( "jungle_ghosts_escape_uw", 0.1 );
	thread escape_underwater_fx();
}

escape_mg_bullets_at_player_river_run()
{
	if (flag("choppers_saw_player"))
	{
		//spawn/link ent to front of player, shoot at it
		fwd = anglestoforward( level.player.angles );
		players_fwd = level.player.origin + (fwd) * 200;
		ent = spawn("script_origin", players_fwd );
		ent linkto( level.player );
		//gun = level.river_apache.mgturret[0];
		bullet_count = 60;
		
		for( i = 0; i< bullet_count;  i++ )
		{
			level.river_apache setturrettargetent( ent );
			level.river_apache fireweapon();		
			wait( randomfloatrange( .05, .15) );			
		}
		
		ent delete();
	}
}


escape_underwater_fx()
{
	//one shot at start
	fwd = anglestoforward( level.player.angles );
	players_fwd = level.player.origin + (fwd);
	playfx( getfx( "vfx_jg_wfall_underw_inispl" ), players_fwd );
	
	ent = spawn_tag_origin();
	ent.script_max_left_angle = 2;
	level.player PlayerSetGroundReferenceEnt( ent );
	thread fade_out_in( "white", undefined, 0.75, 0.75);
	ent thread maps\jungle_ghosts_util::pitch_and_roll();	
	
	wait (0.75);

	level.player endon("stop_underwater_fx");
	level.player shellshock( "underwater", 999999 );	
	level.player thread vision_set_fog_changes( "jungle_underwater", .05 );
	
	if (flag("choppers_saw_player"))
	{
		choppers = [level.river_apache, level.apache1 ];
		if( isdefined( choppers[0] ) )
			array_thread( choppers, ::escape_fake_underwater_bullets );
	}
		
	playfx( getfx( "vfx_jg_wfall_underw_bubbles" ), level.player.origin );
}

fade_out_in_custom( time  )
{
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( "black", 640, 480 );//"black", "white"
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = .75;
	overlay.sort = -2;

//	if(isdefined( fadeup_notify ) )
//	{
//		level waittill( fadeup_notify );
//	}
//	else
//	{	
		//wait( time );
	//}	

	overlay fadeOverTime( time );
	overlay.alpha = 0;	
	wait(time);

	overlay destroy();
}

escape_friendly_jumps_waterfall_to_swimming( jump_struct, swimming_start_struct )
{
	self enable_sprint();
	self set_moveplaybackrate( randomfloatrange( 1.1, 1.4) );
	self escape_friendly_does_anim_off_struct( jump_struct );

	self.goalradius = 32; 
	self disable_ai_color();
	self setgoalpos( self.origin );
	
	self thread maps\jungle_ghosts_util::enable_ai_swim();
	
	wait(3);
	org = self spawn_tag_origin();
	self linkto (org);
	org moveto(swimming_start_struct.origin, 3);
}
escape_friendly_throws_smoke()
{
	self waittill( "end_of_spline" );
	self disable_ai_color();
	
	//ghost 2: incoming stryker - throwing smoke!
	self smart_radio_dialogue( "jungleg_gs2_incomingstrykerthrowing" );
	
	nade_throw	  = getstruct( "nade_throw", "targetname" );
	self.animname = "generic";
	nade_throw anim_reach_solo( self, "throw_smoke" );
	self allowedstances( "crouch" );
	wait 1;
	nade_throw thread anim_single_solo( self, "throw_smoke" );
	wait 1.5;
	self enable_ai_color();	
	self allowedstances( "stand", "prone","crouch");
}

escape_friendly_does_anim_off_struct( struct )
{
	//struct = getstruct( anim_ent, "targetname" );
	wait( randomint( 2 ));
	self disable_ai_color();
	self set_forcegoal();
	//self enable_heat_behavior();
	self.og_animname = self.animname;
	self.animname = "generic";
	struct anim_generic_reach( self, struct.script_noteworthy );
	
	self delaythread( 1, ::enable_ai_color );
	self delaythread( 1.5, ::unset_forcegoal );
	struct anim_single_solo_run( self, struct.script_noteworthy );
	//self stopanimscripted();
	self.animname = self.og_animname;	
}

escape_friendly_follow_spline( startnode_targetname )
{
	self disable_ai_color();
	self set_forcegoal();
	self disable_pain();
	self [[level.ignore_on_func]]();
	self.goalradius = 100;
	
	current_node = getnode( startnode_targetname, "targetname" );
	while( 1 )
	{
		self setgoalnode( current_node );	
		self waittill( "goal" );	
		if( isdefined( current_node.target ) )
		{
			next_node = getnode( current_node.target, "targetname" );
			current_node = next_node;
		}
		else
		{
			self notify("end_of_spline");
			self setgoalnode( current_node );	
			self waittill( "goal" );				
			break;
		}
			
	}
	
	self unset_forcegoal();
	self disable_sprint();	
	self enable_pain();
	self [[level.ignore_off_func]]();
}


escape_enemies_and_vehicles( start )
{
	
	//array_spawn_function_targetname( "escape_waterfall_enemies", ::escape_waterfall_enemies_logic );	
	array_spawn_function_targetname( "escape_tallgrass_chasers", ::escape_tallgrass_chasers_logic );	
	switch ( start )
	{
		case "runway":
					
			flag_wait( "runway_halfway" );
			wait 3;
			tallgrass_chasers = array_spawn_targetname( "escape_tallgrass_chasers");
			
		case "jungle":
			//rpg_chaser_spawner = getent( "rpg_chaser", "targetname" );
			//rpg_chaser_spawner add_spawn_function(  ::escape_rpg_chaser_logic );
			
			if (flag("choppers_saw_player"))
				thread escape_stryker_knocks_over_tree();
			
			flag_wait( "player_slid" );
			
//			fast_rope_helis = spawn_vehicles_from_targetname_and_drive( "fastrope_helis" );
//			array_call( fast_rope_helis, ::vehicle_setspeedimmediate, 50 );
//			
//			wait( .10 );	
//			level.fastropers = [];
//			foreach( i, heli in fast_rope_helis )
//			{
//				array_thread( heli.riders, ::escape_fast_rope_guys_logic );
//			}
			if (flag("choppers_saw_player"))
			{
				level.stryker = spawn_vehicle_from_targetname_and_drive( "jungle_stryker" );
				level.stryker thread escape_stryker_logic();
			}
			
			flag_wait( "escape_halfway" );
			
			if (flag("choppers_saw_player"))
			{
				level.river_apache = spawn_vehicle_from_targetname_and_drive( "river_chopper");
				level.river_apache mgoff();
			}
			//level.stryker thread escape_stryker_ending_logic();
			//flag_wait( "fastropers_dead");
			
		case "river":
			trigger_wait_targetname("player_waterfall_jump_trig" );
			
			if (flag("choppers_saw_player"))
				level.river_apache setlookatent( level.player );
			
		case "waterfall":
			flag_wait( "final_read");	
			
			boats = spawn_vehicles_throttled( "socr_boats", 1 );
				
			foreach (i, boat in boats )
			{
				if (boat.script_noteworthy == "left")
				{
					boat.animname = "seal_boat1";
					boat.spawners = GetEntArray("left_boat_guys","targetname");
				}
				else
				{
					boat.animname = "seal_boat2";
					boat.spawners = GetEntArray("right_boat_guys","targetname");
				}

				boat UseAnimTree(level.scr_animtree["seal_boat1"]);
				boat thread boat_populate();
			}
			
			boat_outro = get_target_ent("boat_outro");
			boat_outro_org = boat_outro spawn_tag_origin();			
			boat_outro_org thread anim_single(boats, "outro", "tag_origin");
		
			foreach(i, boat in boats )
			{
				boat godon();
								
				if (flag("choppers_saw_player"))
				{
					enemy_choppers = [ level.apache1, level.river_apache ];
					enemy_choppers[i].enablerocketdeath = true;
					enemy_choppers[i].alwaysrocketdeath = true;
					boat thread escape_socr_logic( enemy_choppers[i] );
				}
				else
				{
					boat thread escape_socr_logic( undefined );
				}
				
				wait 1.5;
			}
							
	}
}

boat_populate()
{
	foreach (spawner in self.spawners)
	{
		guy = spawner spawn_ai(1);
		
		guy.script_startingposition = spawner.script_startingposition;
		
		self thread maps\_vehicle_aianim::guy_enter(guy);
	}
}

escape_waterfall_enemies_logic()
{
	self.dontevershoot = 1;
	
	if ( cointoss() )
		self enable_cqbwalk();
	
}

spawn_vehicles_throttled( name, delay )
{
	vehicles	= [];
	test		= getentarray( name, "targetname" );
	test_return = [];

	//strip out non vehicles.. 
	foreach ( v in test )
	{
		if ( !isdefined( v.code_classname ) || v.code_classname != "script_vehicle" )
			continue;
		if ( isspawner( v ) )
			vehicles[ vehicles.size ] = maps\_vehicle_code::_vehicle_spawn( v );
		wait delay;
	}
	return vehicles;
}
escape_socr_logic( enemy_vehicle_to_own )
{
	// tag_fx_rf tag_fx_lf tag_propeller_fx tag_wheel_back_right tag_wheel_front_right
	/*level._effect[ "splash_large" ] = loadfx( "fx/water/zodiac_splash_bounce_large" );
	level._effect[ "splash_small" ] = loadfx( "fx/water/zodiac_splash_bounce_small" );
	level._effect[ "splash_turn" ] = loadfx( "fx/water/zodiac_splash_turn_hard" );
	level._effect[ "wake_large" ] = loadfx( "fx/water/dvora_wake_nyharbor" );
	 bone 9 1 "tag_propeller_left"
	bone 10 1 "tag_propeller_right"
	bone 11 1 "tag_splash_back"
	bone 12 1 "tag_splash_front"
	 */
	
	if( self.script_noteworthy == "left" )
		wake_tag = "tag_wheel_back_right";
	else
		wake_tag = "tag_wheel_back_left";
		
	self thread escape_socr_fx_loop( "splash_large", "tag_splash_front", .1, .25 );
	//self thread escape_socr_fx_loop( "splash_large", "tag_fx_lf", .1, .25 );
	self thread escape_socr_fx_loop( "splash_small", "tag_splash_back", .1, .25 );
	//self thread escape_socr_fx_loop( "splash_side", wake_tag, .1, .25 );
	
	//self waittill("wake"); //noteworthy on node	
	wait(2);
	
	if (flag("choppers_saw_player"))
	{
		foreach( i, turret in self.mgturret )
		{
			turret thread escape_socr_turret_own_target( enemy_vehicle_to_own );
		}
	}
	
	wait (2);
	self notify( "stop_fx_on_"+wake_tag );
	self thread escape_socr_fx_loop( "splash_small", "tag_splash_front", .1, .25 );
	//self thread escape_socr_fx_loop( "splash_small", "tag_splash_front", .1, .25 );
	
	//self waittill("`");
	wait (1);
	
	self notify( "stop_fx_on_tag_splash_front");
	self notify( "stop_fx_on_tag_splash_back");
	self notify( "stop_fx_on_tag_wheel_back_right");
	self notify( "stop_fx_on_tag_wheel_back_left");
			
	//self notify( "stop_fx_on_tag_fx_lf");

}

escape_socr_fx_loop( fx, tag, interval_min, interval_max )
{
	self notify( "stop_fx_on_" +tag );
	self endon( "stop_fx_on_" +tag );
	
	while(1)
	{
		playfxontag( getfx( fx), self, tag );
		wait( randomfloatrange( interval_min, interval_max ) );
	}
}

//fake_guy_shooting_turret(spawner)
//{
////	guy = spawn_anim_model ("boat_gunner");
////	guy UseAnimTree(level.scr_animtree["boat_gunner"]);
////	
////	org = spawn_tag_origin();
////	org.origin = self GetTagOrigin("tag_player");
////	org.angles = self GetTagAngles("tag_player");
////	
////	org linkto (self, "tag_player", (0,0,0), (0,180,0));
////	guy linkto (org, "tag_origin", (0,0,0), (0,0,0));
////	
////	org thread anim_loop_solo(guy, "aim_8", "ender", "tag_origin");
////	
////	
////	//self SetLeftArc(45);
////	//self SetRightArc(45);
////	self SetTopArc(30);
////	self SetBottomArc(90);
//
//	guy = spawner spawn_ai(1);
//	guy.script_starting_position = spawner script_starting_position;
//	
//	guy maps\_vehicle_aianim::guy_enter();
//	
//}	

escape_stryker_logic()
{
	//wait( 4 );
	self escape_stryker_shoot_over_players_head( 50 );
	
	targets = getstructarray( "stryker_targets", "targetname" );			
	self escape_stryker_attacks_structs( targets );	
	self thread escape_stryker_shoot_over_players_head( 50 );
	
	flag_wait( "escape_halfway" );
	self escape_stryker_shoot_over_players_head( randomintrange( 30, 45 ) );//make this more shots to give player more time before putting the pressure on
	                                            
	trig = getent( "stryker_hot_spot", "targetname" );
	
	level endon( "player_crossed_river" );
	while(1)	
	{
		//touching trig close to stryker = youre getting owned
		if( level.player istouching( trig ) )
		{
			self notify( "stop_shooting");
			shot_amount = randomintrange( 15, 23 );
			self setturrettargetvec( level.player geteye() );
			wait( .5 );
			
			for( i = 0; i < shot_amount; i ++ )
			{
				self setturrettargetent( level.player, ( 0,0,25)  );
				self fireweapon( "tag_flash" );
				wait(  randomfloatrange(.05, .10 ) );
			}
			
		}
		//not touching the trig = shot over your head
		else
		{
			self escape_stryker_shoot_over_players_head( randomintrange( 10, 15 ) );
		}
		wait randomfloatrange( 2, 3.5 ) ;
	}
	
}

escape_rpg_chaser_logic()
{
	self endon( "death" );
	self.ignoreme = 1;
	self.baseaccuracy = .3;
	self.grenadeammo = 0;
	self enable_sprint();
	self.goalradius = 800;
	delaythread( 5, ::set_ignoreme, false );
	thread escape_rpg_guy_magic_rpg();
	while( isalive( self ) )		
	{
		self setgoalpos( level.player.origin );
		wait 4;
	}

}

escape_rpg_guy_magic_rpg()
{
	wait 2;
	if( !player_can_see_ai( self ) )
			level.player thread escape_shoot_rpgs_over_players_head( 1 );
	
}
escape_stryker_shoot_over_players_head( shot_amount )
{
	self notify( "stop_shooting");
	self endon("stop_shooting");
	
	if(!isdefined( level.player_target ) )
	{
		spot = ( level.player geteye() + (0,0,150) );
		level.player_target = spawn ("script_origin", spot );
		level.player_target linkto( level.player );
	}	
	self setturrettargetent( level.player_target );
	wait 2.5;
	
	for( i = 0; i < shot_amount; i ++ )
	{
		self fireweapon( "tag_flash" );
		wait(  randomfloatrange(.05, .10 ) );
	}	
	
	self clearturrettarget();
}

escape_stryker_knocks_over_tree()
{
	stryker_tree_protector = getent( "stryker_tree_protection", "targetname" );
	damage_struct = getstruct( "stryker_tree_damage", "targetname" );
	//trig = getent( "stryker_tree_trig", "targetname" );
	close_node = getvehiclenode( "stryker_close_to_tree", "script_noteworthy" );
	//tree_node = getvehiclenode( "stryker_at_tree", "script_noteworthy" );
	
	close_node waittill("trigger");
	stryker_tree_protector delete();
	level.stryker vehicle_setspeed( 8, 4 );
	radiusdamage( damage_struct.origin, 200, 100, 100 );
		
}

escape_stryker_tree_custom_fall_logic( rotate_angles )
{
	//custom logic for the tree the styker knocks down
	fall_time = 1.2;
	fx_spot = groundpos( self.kill_trig.origin );
	_fx = getfx( "tree_dust");
	fall_sound = "jungle_tree_fall";
	impact_sound = "jungle_tree_land";
	earthquake( .3, .5, level.player.origin, 300 );
	wait( 1 );
	noself_delaycall( fall_time *.8,  ::playfx, _fx, fx_spot );			
	self rotateto( rotate_angles, fall_time, fall_time * .90, fall_time * .10 );

	self playsound( fall_sound );		
	wait( fall_time * .9 );

	self playsound( impact_sound );		
	wait( fall_time * .1 );

	earthquake( .7, .6, fx_spot, 1000 );
}

escape_stryker_attacks_structs( struct_array, shots_per_struct )
{
	self notify( "stop_shooting");
	self endon("stop_shooting");
	
	if(!isdefined( shots_per_struct ) )
		shots_per_struct = randomintrange( 7, 12 ); 
		
	foreach( struct in struct_array )
	{
		self setturrettargetvec( struct.origin );
		wait( .5 );
		
		for( i = 0; i < shots_per_struct; i ++ )
		{
			self fireweapon( "tag_flash" );
			wait(.05);
			if( randomint( 100 ) > 66 )
				playfx( getfx( "cliff_impact" ), struct.origin );
			wait(.05);
		}	
	}	
}


escape_fast_rope_guys_logic()
{
	self endon( "death" );
	level.fastropers = add_to_array( level.fastropes, self );
	if ( level.gameskill <= 1 )
		self.grenadeammo = 0;
	self.baseaccuracy = .2;
	self.health = 50;
	self disable_long_death();

}

escape_tallgrass_chasers_logic()
{
	//self.pathenemyfightdist = 4;
	self.baseaccuracy = 5;
	self disable_long_death();
	self.goalradius = 550;
	guys = add_to_array( level.squad, level.player );
	
//	if( cointoss() )
//		self enable_sprint();
	
	//self setgoalentity( random( guys ) );
	self setgoalpos( random( guys ).origin  );
	flag_wait( "player_slid" );
	
	if( isdefined( self ) )
		self delete();
	
}

escape_temp_ai_slide( flag_to_wait, slide_style )
{
	//self = ai sliding
	if( isdefined( flag_to_wait ) )
		flag_wait( flag_to_wait );
	/*
	start_struct = getstruct( "ai_slide_start", "targetname" );
	end_struct = getstruct( "ai_slide_end", "targetname" );
	
	slide_ent = self spawn_tag_origin();
	self linkto( slide_ent );
	
	slide_ent.origin = start_struct.origin;
	slide_ent.angles = start_struct.angles;
	
	slide_time = 3;
	slide_ent moveto( end_struct.origin, slide_time, slide_time* .8, slide_time* .2 );
	
	wait( slide_time );
	
	self unlink();
	slide_ent delete();
	*/
	//wait( randomfloatrange( 1, 1.5 ) );
	
	scene = undefined;
	
	if( !isdefined( slide_style ) )
		scene = "jungle_ghost_ai_slide1";
	else
		scene = "jungle_ghost_ai_slide2";
	
	struct = getstruct( "ai_slide_anim_ent", "targetname");
	self disable_ai_color();
	self set_forcegoal();
	//self enable_heat_behavior();
	self.og_animname = self.animname;
	self.animname = "generic";
	struct anim_generic_reach( self, scene );
	
	self delaythread( 1, ::enable_ai_color );
	self delaythread( 1.5, ::unset_forcegoal );
	
	self thread escape_play_slide_fx_on_npc();
		
	struct anim_single_solo_run( self, scene );
	//self stopanimscripted();
	self.animname = self.og_animname;	
	self notify ("finished slide");
}

escape_play_slide_fx_on_npc()
{
	playfxontag( level._effect[ "slide_npc" ], self, "tag_origin" );
	self waittill ("finished slide");
	stopfxontag( level._effect[ "slide_npc" ], self, "tag_origin");
}

escape_play_slide_fx_on_player()
{
	flag_wait("slide_start");
	linker = level.player spawn_tag_origin();
	linker linkto(level.player);
	
	//vfx_atmos_bokeh_jungle
	thread do_bokeh( "end mud bokeh", "slide_screenspace", 15, 1, 1.1 );
		
	playfxontag( level._effect[ "slide_player" ], linker, "tag_origin" );
	wait(3);
	
	level.player notify("stop_bokeh");
	level.player notify("end mud bokeh");
	StopFXOnTag( getfx( "vfx_atmos_bokeh_jungle" ), level.player.bokeh_ent, "tag_origin" );
	
	StopFXOnTag( level._effect[ "slide_player" ], linker, "tag_origin");
	linker delete();
}


escape_shoot_rpgs_over_players_head( rpg_num )
{
	//self = player
	for(i = 0; i < rpg_num; i++ )
	{
		fwd = anglestoforward(self.angles);
		random_num = randomintrange(10,20);
		
		behind =  (fwd) *(-75); 
		randomly_behind_and_above_me = self.origin + behind + (random_num, random_num, 100 );	
			
		front = (fwd) * (800);
		in_front_of_me = self.origin + front;
			
		magicbullet("rpg_straight", randomly_behind_and_above_me, in_front_of_me);
		wait(randomfloatrange(1, 1.5) );
	}	
}

escape_setup_trees()
{
	large_trees = getentarray( "dest_tree", "targetname" );
	small_trees = getentarray( "dest_tree_small", "targetname" );
	all_dest_trees = array_combine( large_trees, small_trees );
	array_thread( all_dest_trees, ::escape_dest_tree_logic );
	
	player_vicinity_detectors = getstructarray( "player_radius_damage", "targetname" );
	array_thread( player_vicinity_detectors, ::radius_damage_when_player_is_close );

}

escape_dest_tree_logic()
{
	//self = script_model tree with linked model parts
	parts = self get_linked_ents();
	dest_tree = add_to_array( parts, self );
	self.parts = parts;
	rotate_angles = undefined;
	foreach( part in parts )
	{
		part.is_small = false;
		if( part.script_noteworthy == "dest_top_goal" )
		{
			rotate_angles = part.angles;
		}
		if( part.model == "ctl_foliage_tree_pine_tall_b_broken_top" )
		{
			part.is_small = true;
		}
		if( part.script_noteworthy == "dest_top" ) //assign the trig to the falling top
		{
			foreach( other_part in parts )
			{
				if( other_part.script_noteworthy == "dest_kill_trig" )
				{
					part.kill_trig = other_part;
				}
			}
		}
	}
	array_thread( dest_tree, ::escape_dest_tree_parts_logic, rotate_angles );     	
}

escape_dest_tree_parts_logic( rotate_angles )
{
	//noteworthys: pristine  dest_top dest_top_goal dest_bottom
	switch ( self.script_noteworthy )
	{
		case "pristine":
			self ent_flag_init("destroyed");
			self setcandamage( true );
			self setcanradiusdamage( true );
			self waittill( "damage" );
			array_notify( self.parts, "tree_destroyed" );
			self ent_flag_set("destroyed");
			self hide();
			//self delete();
			break;
		
		case "dest_top":
			if( isdefined( self.is_small)  && self.is_small )
			{
				fall_time = randomintrange( 2, 4 );
				fx_spot = groundpos( self.origin );
				_fx = getfx( "tree_dust_small");
				tree_quake = false;
				fall_sound = "jungle_tree_small_fall";
				impact_sound = "jungle_tree_small_land";
			}
			else
			{
				fall_time = randomintrange( 4, 5 );// 5 7
				fx_spot = groundpos( self.kill_trig.origin );
				_fx = getfx( "tree_dust");
				tree_quake = true;
				fall_sound = "jungle_tree_fall";
				impact_sound = "jungle_tree_land";
			}
			
			self hide();
			self.clip_brush = getent( self.target, "targetname" );
			self.clip_brush linkto( self );
			
			self waittill( "tree_destroyed" );			
			playfx( getfx( "tree_explosion" ), self.origin );
			
			self show();
			if( isdefined( self.script_parameters ) || isdefined( self.script_index ))
			{
				self thread escape_stryker_tree_custom_fall_logic( rotate_angles );
				break;
			}
			self playsound( "explo_tree" );
			earthquake( .3, .5, level.player.origin, 300 );
			wait( randomfloatrange( .5, 1 ) );
			
			noself_delaycall( fall_time *.8,  ::playfx, _fx, fx_spot );			
			self rotateto( rotate_angles, fall_time, fall_time * .90, fall_time * .10 );
			
			if( !self.is_small) 
				self.kill_trig thread falling_tree_player_detection( fall_time );
			
			self playsound( fall_sound );
				
			wait( fall_time * .9 );
	
			self playsound( impact_sound );		
			wait( fall_time * .1 );
			
			if( tree_quake )
				earthquake( .7, .6, fx_spot, 1000 );
		
			break;
		
		case "dest_top_goal":
			self delete();
			break;
		
		case "dest_bottom":
			self hide();
			self waittill( "tree_destroyed" );
			self show();		
			break;
	
		default:
			break;
	}

}

radius_damage_when_player_is_close()
{	
	level endon("player_at_river");
	
	if (flag("choppers_saw_player"))
	{

		close = 1000*1000;
		while(1)
		{
			dist = distancesquared( self.origin, level.player.origin );
			if( dist <= close )
			{
				//self notify("damage");
				//iprintln( "player close, doing radius damage");
				radiusdamage( self.origin, 186, 100, 100 );
				return;
			}		
			wait .25;
		}
	}
}

falling_tree_player_detection( time )
{
	//only check last 1 sec of fall
	time -= 1;	
	wait time; 
	
	//start checking for player
	self endon("timeout" );
	self thread notify_delay( "timeout", 1 );

	while(1)
	{
		if( level.player istouching( self ) )
		{
			//iprintln( "player crushed by tree" );
			level.player kill();
			level notify( "new_quote_string" );
			setdvar( "ui_deadquote", &"jungle_ghosts_obit_tree" );				
			return;
		}
		wait.05;
	}
	
}


escape_fake_underwater_bullets()
{
	level endon("player_surfaces");
	fake_bullet_count = 26;	
	whizbys = [];
	whizbys[0] = "whizby_near_00_r";
	whizbys[1] = "whizby_near_00_l";
	
	for( i = 0; i< fake_bullet_count; i ++ )
	{
		offset = randomintrange( -25, 25 );
		forwardvec = vectornormalize(    self.origin - level.player.origin );
		start_point  = level.player.origin + ( forwardvec * randomintrange( 85, 100 ) );
		start_point += ( offset, offset, 0 );
		a = vectortoangles( forwardvec );
		up = anglestoup( a );
		//thread draw_line_for_time( start_point, level.player.origin, 1, 0, 0, .1 );
		playfx( getfx( "underwater_bullet" ), start_point, forwardvec, up );
		
		if( cointoss() )
			thread play_sound_in_space( "bullet_large_water", start_point );
		
		level.player thread play_sound_on_entity( random( whizbys ) );
		wait( randomfloatrange( .10, .35 ) );
	}
	
}

