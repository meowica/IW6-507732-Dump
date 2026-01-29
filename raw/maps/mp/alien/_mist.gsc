#include maps\mp\_utility;
#include maps\mp\alien\_utility;
#include common_scripts\utility;

CONST_FOG_MIN_TRANSITION_TIME  = 2.0; // min time it takes to transition fog
CONST_VISION_MIN_TRANSITION_TIME  = 2.0; // min time it takes to transition vision
MIST_ENTER_TIME = 10;

main()
{
	if ( !alien_mode_has( "mist" ) )
		return;
	
	// contains all entities/structs that gets affected by mist wall combing through
	level.mist_affected_ents = [];	// should monitor size of this array, could get out of hand!
	
	level.fog_vision_ext_clear = "mp_alien_town"; //Exterior. Use when there is no-fog.
	level.fog_vision_ext_fog = "greenlight_alien_demo_ext_fog"; // Exterior. Use when heavy fog rolls in.
	//level.fog_vision_int_clear = "greenlight_alien_demo_int_clear"; // No-fog. Use inside the theater (currently same as “ext-clear”)
	//level.fog_vision_int_fog = "greenlight_alien_demo_int_fog"; // Heavy-fog. Use inside the theater (currently same as “ext-fog”)
	
	// inits
	init_mist_fx();
	init_mist();
	
	level.mist_sfx_node = Spawn( "script_origin", ( 0,0,0 ) );
	
	// level fog values:
	level.default_fog 			= [];
	level.default_fog[ "near" ] = 0;
	level.default_fog[ "half" ] = 1800;
	
	level.mist_fog 				= [];
	level.mist_fog[ "near" ] 	= 0;
	level.mist_fog[ "half" ] 	= 650;
	
	level.MIST_ENTER_TIME		= MIST_ENTER_TIME;
	
	// init flags
	foreach( ent in level.mist_affected_ents )
		ent ent_flag_init( "inside_mist" );

	thread mist_roll_based_on_cycle();
	
	//SetDvar( "music_enable", 1 );  //turning this off for now, not allowed to modify in mp

	// plays fx on fog trigger radii
	thread static_mist_void();
	thread init_mist_crater_fx();

	// fog static path test
	//thread static_mist_on_path(1,true,200.0);
	//thread static_mist_on_path(2,true,200.0);
}

player_fog_think()
{
	if ( !alien_mode_has( "mist" ) )
		return;
	
	// self is player
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	
	if ( !self ent_flag_exist( "inside_mist" ) )
		self ent_flag_init( "inside_mist" );
	
	// TODO:
	// keep track of player spawner ents state of being inside mist
	// then copy flag state to player after spawning
	spawner_ent = self.spawned_from;
	if ( isdefined( spawner_ent ) && spawner_ent ent_flag_exist( "inside_mist" ) )
	{
		if ( spawner_ent ent_flag( "inside_mist" ) )
			self ent_flag_set( "inside_mist" );
	}

	// add player to avoided ents
	if ( !array_contains( level.mist_affected_ents, self ) )
	{
		level.mist_affected_ents[ level.mist_affected_ents.size ] = self;
		thread move_undefined_from_mist_affected_ents( "disconnect", self );
	}
	
	// wait till player is spawned
	wait 0.05;
	
	while ( true )
	{
		if ( self ent_flag( "inside_mist" ) )
		{
			self mist_fog( CONST_FOG_MIN_TRANSITION_TIME );
			self ent_flag_waitopen( "inside_mist" );
		}
		else
		{	
			self default_fog( CONST_FOG_MIN_TRANSITION_TIME );
			self ent_flag_wait( "inside_mist" );
		}
		
		wait 1.0;
	}
}

move_undefined_from_mist_affected_ents( wait_msg, wait_ent )
{
	level endon ( "game_ended" );
	
	if ( isdefined( wait_ent ) )
		wait_ent waittill( wait_msg );
	else
		level waittill( wait_msg );
	
	wait 0.05;
	
	foreach ( ent in level.mist_affected_ents )
	{
		// clear undefined ents
		if ( !isdefined( ent ) )
			array_remove( level.mist_affected_ents, ent );
		
		// clear disconnected players
		if ( isplayer( ent ) )
		{
			found = false;
			foreach( player in level.players )
			{
				if( ent == player )
					found = true;
			}
			
			if ( !found )
				array_remove( level.mist_affected_ents, ent );
		}
	}
}

mist_roll_based_on_cycle()
{
	early_fog_timer = 5;	// this is how many seconds ahead of cycle spawning we want the fog to come
	
	flag_init( "mist_active" );
	
	while ( true )
	{
		level waittill( "alien_cycle_prespawning", countdown );
		// countdown is delay before cycle spawns
		
		// set flag to mist active before we spawn aliens, so they spawn closer when mist is here!
		delayThread( max( ( countdown - 1 ), 0 ), ::flag_set, "mist_active" );
		
		// timed to spawn mist wall
		fog_delay = max( ( countdown - early_fog_timer ), 0 );
		
		//level thread pre_mist_sequence( fog_delay );
		wait_for_fog( fog_delay );
		
		thread mist_enter();
		level waittill( "alien_cycle_ended" );
		thread mist_exit();
	}
}

wait_for_fog( fog_delay )
{
	level endon( "force_cycle_start" );
	
	wait fog_delay;
}

pre_mist_sequence( fog_delay )
{
	level endon( "force_cycle_start" );
	
	MIN_WARN_PLAY_TIME = 10.0;
	
	current_time = getTime();
	counter = 1;
	while ( fog_delay > MIN_WARN_PLAY_TIME )
	{
		wait( fog_delay / 2 );
		
		earthquake_intensity = min( 0.1 * counter, 0.3 );
		warn_all_players( earthquake_intensity );
		
		time_passed = ( getTime() - current_time ) / 1000;
		fog_delay -= time_passed;
		counter++;
		current_time = getTime();
	}
}

warn_all_players( earthquake_intensity )
{
	foreach ( player in level.players )
	{
		player thread warn_player( earthquake_intensity );
	}
}

warn_player( earthquake_intensity )
{
	Earthquake( earthquake_intensity, 3, self.origin, 300 ); 
	self PlaySound( "pre_quake_mtl_groan" );
	self PlayRumbleOnEntity( "heavygun_fire" );
}

mist_enter()
{	
	// TODO: WIP moving SP's sound utility script functions to MP
	//thread play_mist_approaching_vo();
	//thread audio_fog_sounds((559, 13536, 1244), mist_enter_time);	
	
	level notify( "mist_rolling_in", MIST_ENTER_TIME );
	thread mist_radius_rollout(MIST_ENTER_TIME, false);
	//thread fog_traverse_path( 1, true, 200.0, 100, MIST_ENTER_TIME );
	//thread fog_traverse_path( 2, true, 200.0, 100, MIST_ENTER_TIME );
	
	wait( MIST_ENTER_TIME );
	
	level notify( "mist_rolled_in", 0 );
	
	
	// failsafe when player did not get combed by the mist rolling in
	foreach ( player in level.players )
	{
		if ( !player ent_flag( "inside_mist" ) )
			player ent_flag_set( "inside_mist" );
	}
}

mist_exit()
{
	mist_exit_time = 10;
	
	// TODO: WIP moving SP's sound utility script functions to MP
	//thread play_mist_clearing_vo( mist_exit_time );
	
	// clearing pass
	level notify( "mist_rolling_out", mist_exit_time );
	thread mist_radius_rollout(mist_exit_time,true);
	//thread fog_traverse_path( 1, true, 200.0, 100, mist_exit_time, true );
	//fog_traverse_path( 2, true, 200.0, 100, mist_exit_time, true );
	
	level notify( "mist_rolled_out", 0 );
	flag_clear( "mist_active" );
}

/*
loop_music()
{
	//mist_enter_time = 15;
	
	//level.player PlaySound("mus_aliens_fog_stinger");
	//music_play("mus_aliens_fog_stinger");

	//level waittill_any_timeout( mist_enter_time, "sfx_fog_surround" );
	music_stop(3);
	wait 7;
	//IPrintLnBold("Starting music");
	level endon( "alien_cycle_ended" );
	
	level thread loop_music_stop_on( "alien_cycle_ended" );
	
	// TO DO: music differ by difficulty of AI
	//music_alias = "so_survival_boss_music_01";
	music_alias = "mus_aliens_fog";
	music_time 	= musicLength( music_alias ) + 2;
	
	while ( true )
	{
		MusicPlayWrapper( music_alias );
		wait( music_time );
	}
}

loop_music_stop_on( msg )
{
	level waittill( "alien_cycle_ended" );
	wait 5;
	music_stop( 5 );
	//IPrintLnBold("Stopped music");
}

audio_fog_sounds(mist_start_pos, roll_in_time)
{	
	fog_approach_sfx = Spawn( "script_origin", mist_start_pos );
	fog_approach_sfx playsound("alien_fog_approach");
	
	fog_approach_low_sfx = Spawn( "script_origin", level.player.origin );
	fog_approach_low_sfx LinkTo(level.player);
	fog_approach_low_sfx playsound("alien_fog_approach_low");
	
	
	// Wait untill player gets engulfed by smoke and play the engulf oneshot
	level waittill_any_timeout( roll_in_time, "sfx_fog_surround" ); //(roll_in_time - 8), "player_inside_mist",
	level.player playsound("alien_fog_enter");
        thread loop_music();
	
	//Fade out the fog approach sounds
	wait 3.0;
	fog_approach_sfx ScaleVolume(0.0, 3.0);
	fog_approach_low_sfx ScaleVolume(0.0, 10.0);
	
	
	//Fade in fog ambience
	set_audio_zone("amb_mist", 4);

	//Fog complete.
	level waittill( "alien_cycle_ended" );
	wait 10.0;
	
	//Play Fog exit sound
	level.player playsound("alien_fog_exit");
	wait 4.0;
	
	//Fade in normal ambience
	set_audio_zone("amb_chicago", 5);

	//Cleanup
	wait 1.0;
	fog_approach_sfx delete();
	fog_approach_low_sfx delete();
	
}
*/
	
// =====================================================
// Spawns fog in a circle around "fog_trigger" trigger radius
static_mist_void()
{
	PI = 3.14159265359;
	foreach( fog_trigger in level.fog_triggers)
	{
		// manages player's fog settings are surrounding ambient fx based on distance from void
		//fog_trigger thread update_void_fog_setting();
		
		// commented out below due to max entity count in MP
		/*
		if ( isdefined( fog_trigger.script_noteworthy ) && fog_trigger.script_noteworthy == "spawn_mist_wall" )
		{
			spacing = 50; // effect spacing
			trigger_circumference = 2.0 * PI * fog_trigger.radius;
			point_count = Int(trigger_circumference / spacing);
			
			// emission_pts = getCirclePoints(point_count, fog_trigger.radius, fog_trigger.origin);
			emission_pts = getRingPoints(fog_trigger.radius, fog_trigger.origin, 150, spacing);
			fog_trigger thread active_fog_trigger_boundary(emission_pts);
		}*/
	}
}

// dynamically update fogset based on distance from void center
update_void_fog_setting()
{
	while ( true )
	{
		self waittill( "trigger", owner );

		if ( !isplayer( owner ) )
		{
			wait 0.05;
			continue;
		}
		
		owner endon( "death" );
		
		// while player is inside void, set fog based on distance to center of void
		while ( owner IsTouching( self ) )
		{
			if ( !owner ent_flag( "inside_mist" ) )
				break;
			
			dist = abs( Distance2D( owner.origin, self.origin ) );

			half = max( level.mist_fog[ "half" ], ( self.radius - dist ) * 0.75 );
			near = half * 0.9;
			
			owner.mist_fog_setting = false; // overrides and force mist_fog
			owner mist_fog( 0.25, near, half );
			wait 0.25;
		}
		
		if ( isdefined( owner ) && isplayer( owner ) && owner ent_flag( "inside_mist" ) )
		{
			// make sure when player leaves trigger we restore to the exact mist fog settings
			owner.mist_fog_setting = false; // overrides and force mist_fog
			owner mist_fog( 0.25 );
		}
		
		wait 1;
	}
}

active_fog_trigger_boundary(points_list)
{
	while(true)
	{
		if ( !self ent_flag( "inside_mist" ) )
		{
			wait 0.25;
			continue;
		}
		else
		{
			// dont draw if a player is inside
			// this wont work with two players... 
			// need better solution where fx is played on client only
			any_player_inside = false;
			foreach ( player in level.players )
			{
				if ( player IsTouching( self ) )
				{
					any_player_inside = true;
				}
			}
		}
		
		/* // TEMP - Commented out: lets not do hiding fx if player is outside untill we get better fx
		if ( !any_player_inside )
		{
			wait 0.25;
			continue;
		}
		*/
		
		foreach (pt in points_list)
		{
			/*
			// dont draw if player is too close
			player_too_close = false;
			foreach ( player in level.players )
			{
				if ( abs( Distance2D( player.origin, pt ) ) < 250 )
					player_too_close = true;
			}
			if ( player_too_close )
				continue;
			*/
			// Sphere(pt, 20, (1,1,0), true, 10); // debug position checking
			PlayFX(level._effect[ "vfx_alien_env_traverse_medium" ], pt);
		}
		wait 1;
	}
}

// =====================================================
// Traverse fog along a path
// <path_id> (int): the id of the path - setup by using a 'script_group' KVP on the first node in the path
// <use_path_as_base>: use the height of the path as the base - i.e. don't trace down.
// <wall_height> (float): height of the wall from the base of the path that will be filled with vfx
// <wall_max_width>: Maximum Width
// <traverse_time>: the length of time for the effect to move from the start to the end of the path
// <clearing> (boolean): if true, clears existing static/void fx as wall combs through
fog_traverse_path(path_id, use_path_as_base, wall_height, wall_max_width, traverse_time, clearing )
{
	earthquaked = false;	// keeps track if this mist wall has already quaked

	spacing = 400; // spacing of the effects as we spawn them ... this needs to be modified
					// to work with different effects sizes, etc ... maybe a table of effects we use and good spacing for them

	default_radius = 500.0;
	// find the start of the path based on the id we're given.
	fog_path_idx = -1;
	for (i=0; i<level.fog_traversal_nodes.size; i++)
	{
		if (level.fog_traversal_nodes[i][0].script_group == path_id) {
			fog_path_idx = i;
			break;
		}
	}
	
	if (fog_path_idx == -1) {
		/#
		// error message - did not find the path of that ID
		IPrintLn("ERROR: fog_traverse_path can't find supplied path_id: " + path_id+"\n");
		#/
		return;
	}
	
	num_spawners = level.fog_traversal_nodes[fog_path_idx].size;

	path_len = 0.0;
	// get the total length of the path
	for (i=0; i<(num_spawners-1); i++) {
		path_len += length(level.fog_traversal_nodes[fog_path_idx][i+1].origin - level.fog_traversal_nodes[fog_path_idx][i].origin);
	}
	
	time_itr = traverse_time / (path_len / spacing); // update timer based on the overal path length and the spacing we're working with
	
	off_axis_feeler_dist = wall_max_width; /// for tracing ... not sure the best way to come up with a good value for this.
	
	for (i=0; i<(num_spawners-1); i++)
	{
		// we're always between two spawn points on the path
		this_spawner = level.fog_traversal_nodes[fog_path_idx][i];
		next_spawner = level.fog_traversal_nodes[fog_path_idx][i+1];
		this_spawner_pos = this_spawner.origin;
		next_spawner_pos = next_spawner.origin;
		
		if ( IsDefined(this_spawner.radius) )
			this_spawner_radius = this_spawner.radius;
		else
			this_spawner_radius = default_radius;

		if ( IsDefined(next_spawner.radius) )
			next_spawner_radius = next_spawner.radius;
		else
			next_spawner_radius = default_radius;
		
		
		segment_length = length(next_spawner_pos - this_spawner_pos);
		seg_dir = VectorNormalize(next_spawner_pos - this_spawner_pos);
		
		num_itr = ceil(segment_length / spacing);
		pos_now = this_spawner_pos;
		pos_before = (pos_now + (seg_dir * spacing * -1.0));

		for (j=0; j<num_itr; j++)
		{
			path_frac = j / num_itr; // fraction we are along the path between our two points
			
			pos_now = CosineInterpolate(this_spawner_pos, next_spawner_pos, path_frac);
			
			// Cubic interpolation - we need 4 points, so sometimes, we may need to
			// artificially create additional points at the very start or end of the sequence
			// currently not working correctly
			/*
			if (i >= 1)
			{
				first_spawner_pos = level.fog_spawners[i-1].origin;
			} else {
				first_spawner_pos = level.fog_spawners[0].origin + (level.fog_spawners[0].origin - level.fog_spawners[1].origin);
			}
			
			if (i <= (num_spawners-3))
			{
				last_spawner_pos = level.fog_spawners[i+2].origin;
			} else {
				last_spawner_pos = level.fog_spawners[i+1].origin + (level.fog_spawners[i+1].origin - level.fog_spawners[i].origin);
			}
			
			pos_now = CubicInterpolate(first_spawner_pos, this_spawner_pos, next_spawner_pos, last_spawner_pos, path_frac);
			*/
			
			spawn_radius = (next_spawner_radius * path_frac) + ((1.0-path_frac) * this_spawner_radius);
			
			seg_dir = VectorNormalize(pos_now-pos_before);
			
			line(pos_before, pos_now,(0.8,0.8,1), 1, true, int(((time_itr)*3) * 20));
			
			off_axis_dir = VectorCross(seg_dir, (0, 0, 1.0)); // vector perpendicular to the direction we're moving.

			new_pos = level.fog_traversal_nodes[fog_path_idx][i].origin + ( seg_dir * (j*spacing) );

			offaxis_result_1 = (off_axis_dir * spawn_radius);
			offaxis_result_2 = (off_axis_dir * (spawn_radius * -1.0));
			
			//offaxis_result_1 = BulletTrace(new_pos, new_pos + (off_axis_dir * off_axis_feeler_dist), false);
//			offaxis_result_2 = BulletTrace(new_pos, new_pos + (off_axis_dir * (off_axis_feeler_dist * -1)), false);
			
			off_axis_len_1 = spawn_radius; //offaxis_result_1["fraction"] * off_axis_feeler_dist;
			off_axis_len_2 = spawn_radius; //offaxis_result_2["fraction"] * off_axis_feeler_dist;
			
			off_axis_cnt_1 = ceil(off_axis_len_1 / spacing);
			off_axis_cnt_2 = ceil(off_axis_len_2 / spacing);
			
			for (k=0; k<off_axis_cnt_1; k++)
			{
				off_axis_pos = new_pos + ( off_axis_dir*(k*spacing) );
				if (use_path_as_base) {
					trace_result = [];
					trace_result["position"] = off_axis_pos;
				} else
					trace_result = BulletTrace(off_axis_pos, off_axis_pos+(0,0,-1000), false);
				
				mist_pos = trace_result["position"]+(0,0,spacing);
				spawn_mist(level._effect[ "vfx_alien_env_dark_loop_huge" ],mist_pos);
				
				// comment in to see debug locations of spawn points
				//Sphere(mist_pos,(spacing*0.5),(1,1,0),false, int(time_itr/0.05));
				
				//for (l=0; l<(int((wall_height/spacing)))-1; i++)
				//	spawn_mist(level._effect[ "vfx_alien_env_traverse_medium" ],trace_result["position"]+(0,0,(spacing*l)+spacing));
			}

			for (k=0; k<off_axis_cnt_2; k++) {
				off_axis_pos = new_pos + ( off_axis_dir*(k*spacing*-1) );
				if (use_path_as_base) {
					trace_result = [];
					trace_result["position"] = off_axis_pos;
				} else
					trace_result = BulletTrace(off_axis_pos, off_axis_pos+(0,0,-1000), false);
				mist_pos = trace_result["position"]+(0,0,spacing);
				spawn_mist(level._effect[ "vfx_alien_env_dark_loop_huge" ],mist_pos);
				//Sphere(mist_pos,(spacing*0.5),(1,1,0),false, int(time_itr/0.05));
				
				//for (l=0; l<(int((wall_height/spacing)))-1; i++)
				//	spawn_mist(level._effect[ "vfx_alien_env_traverse_medium" ],trace_result["position"]+(0,0,(spacing*l)+spacing));
			}
			
			//trace_result = BulletTrace(new_pos, new_pos+(0,0,-1000), false);
			//if (trace_result["fraction"] != 1.0) {
			//	new_pos = trace_result["position"] + (0,0,spacing);
			//}
			// spawn_mist(level._effect[ "vfx_alien_env_traverse_medium" ],new_pos);
			pos_before = pos_now;
			
			
			// =========== sets entity's flag when hit by the mist ===========
			point_1_in_line 		= new_pos + off_axis_dir * 100000; // wide enough to catch entities
			point_2_in_line 		= new_pos - off_axis_dir * 100000;
			switch_dist_past_wall 	= 500;	// this is the distance the fog passed player before switching of sky
			
			foreach ( ent in level.mist_affected_ents )
			{
				// skip testing ents already covered previously
				if ( isdefined( clearing ) && clearing )
				{
					if ( !( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" )))
						continue;
				}
				else
				{
					if ( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" ) )
						continue;
				}
				
				perp_vec = VectorNormalize( VectorFromLineToPoint( point_1_in_line, point_2_in_line, ent.origin ) );
				
				// if mist has passed/hit the ent
				if ( vectordot( perp_vec, seg_dir ) < 0 )
				{
					// quake players
					if ( !earthquaked && isplayer( ent ) )
					{
						level notify( "sfx_fog_surround" );
						thread quaking( 0, 0.1, 12, ent, 1200 );
						thread quaking( 5, 0.2, 5, ent, 600 );
						earthquaked = true;
					}
					
					// checks how far wall has passed the ent
					perp_point 		= PointOnSegmentNearestToPoint( point_1_in_line, point_2_in_line, ent.origin );
					dist_from_fog 	= distance2D( ent.origin, perp_point );
					
					// if distance passed satisfies
					if ( dist_from_fog > switch_dist_past_wall )
					{
						//if ( isplayer( ent ) )
							//IPrintLn( "HIT! Dist: " + dist_from_fog );
						
						if ( isdefined( clearing ) && clearing )
						{
							if ( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" ) )
								ent ent_flag_clear( "inside_mist" );
						}
						else
						{
							if ( !( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" )))
								ent ent_flag_set( "inside_mist" );
						}
					}
				}
			}
			
			wait time_itr;
		}
	}
	// level._effect[ "vfx_alien_env_traverse_medium" ];
}

// =====================================================
// spawn vfx along a static path - like a wall
// <path_id>:
// <use_path_as_base>: 
// <wall_height>: 
static_mist_on_path(path_id, use_path_as_base, wall_height)
{
	// level.fog_static_start_nodes;
	// level.fog_static_nodes;
	spacing = 50.0; // spacing of the effects as we spawn them ... this needs to be modified
					// to work with different effects sizes, etc ... maybe a table of effects we use and good spacing for them

	// find the start of the path based on the id we're given.
	fog_path_idx = -1;
	for (i=0; i<level.fog_static_start_nodes.size; i++)
	{
		if (level.fog_static_start_nodes[i].script_group == path_id) {
			fog_path_idx = i;
			break;
		}
	}
	
	if (fog_path_idx == -1) {
/#
		IPrintLn("ERROR: fog_static_path can't find supplied path_id: " + path_id+"\n");
#/
		// error message - did not find the path of that ID
		return;
	}
	
	num_spawners = level.fog_static_nodes[fog_path_idx].size;
	
	path_len = 0.0;
	// get the total length of the path
	for (i=0; i<(num_spawners-1); i++)
	{
		path_len += length(level.fog_static_nodes[fog_path_idx][i+1].origin - level.fog_static_nodes[fog_path_idx][i].origin);
	}
	
	while (true)
	{
		for (i=0; i<(num_spawners-1); i++)
		{
			if ( !level.fog_static_nodes[fog_path_idx][i] ent_flag( "inside_mist" ) )
			{
				continue;
			}
			
			// we're always between two spawn points on the path
			this_spawner_pos = level.fog_static_nodes[fog_path_idx][i].origin;
			next_spawner_pos = level.fog_static_nodes[fog_path_idx][i+1].origin;
			
			segment_length = length(next_spawner_pos - this_spawner_pos);
			seg_dir = VectorNormalize(next_spawner_pos - this_spawner_pos);
			
			num_itr = ceil(segment_length / spacing);
			pos_now = this_spawner_pos;
			pos_before = (pos_now + (seg_dir * spacing * -1.0));
	
			for (j=0; j<num_itr; j++)
			{
				path_frac = j / num_itr; // fraction we are along the path between our two points
				
				pos_now = CosineInterpolate(this_spawner_pos, next_spawner_pos, path_frac);
				
				// Cubic interpolation - we need 4 points, so sometimes, we may need to
				// artificially create additional points at the very start or end of the sequence
				// currently not working correctly
				/*
				if (i >= 1)
				{
					first_spawner_pos = level.fog_spawners[i-1].origin;
				} else {
					first_spawner_pos = level.fog_spawners[0].origin + (level.fog_spawners[0].origin - level.fog_spawners[1].origin);
				}
				
				if (i <= (num_spawners-3))
				{
					last_spawner_pos = level.fog_spawners[i+2].origin;
				} else {
					last_spawner_pos = level.fog_spawners[i+1].origin + (level.fog_spawners[i+1].origin - level.fog_spawners[i].origin);
				}
				
				pos_now = CubicInterpolate(first_spawner_pos, this_spawner_pos, next_spawner_pos, last_spawner_pos, path_frac);
				*/
				
				seg_dir = VectorNormalize(pos_now-pos_before);
				
				// line(pos_before, pos_now,(0.8,0.8,1), 1, true, int(((time_itr)*3) * 20));
				
				// off_axis_dir = VectorCross(seg_dir, (0, 0, 1.0)); // vector perpendicular to the direction we're moving.
	
				new_pos = level.fog_static_nodes[fog_path_idx][i].origin + ( seg_dir * (j*spacing) );
	
				/*
				offaxis_result_1 = BulletTrace(new_pos, new_pos + (off_axis_dir * off_axis_feeler_dist), false);
				offaxis_result_2 = BulletTrace(new_pos, new_pos + (off_axis_dir * (off_axis_feeler_dist * -1)), false);
				
				off_axis_len_1 = offaxis_result_1["fraction"] * off_axis_feeler_dist;
				off_axis_len_2 = offaxis_result_2["fraction"] * off_axis_feeler_dist;
				
				off_axis_cnt_1 = ceil(off_axis_len_1 / spacing);
				off_axis_cnt_2 = ceil(off_axis_len_2 / spacing);
				
				for (k=0; k<off_axis_cnt_1; k++)
				{
					off_axis_pos = new_pos + ( off_axis_dir*(k*spacing) );
					trace_result = BulletTrace(off_axis_pos, off_axis_pos+(0,0,-1000), false);
					spawn_mist(level._effect[ "vfx_alien_env_traverse_medium" ],trace_result["position"]+(0,0,spacing));
				}
	
				for (k=0; k<off_axis_cnt_2; k++)
				{
					off_axis_pos = new_pos + ( off_axis_dir*(k*spacing*-1) );
					trace_result = BulletTrace(off_axis_pos, off_axis_pos+(0,0,-1000), false);
					spawn_mist(level._effect[ "vfx_alien_env_traverse_medium" ],trace_result["position"]+(0,0,spacing));
				}
				*/
				
				trace_result = BulletTrace(new_pos, new_pos+(0,0,-1000), false);
				if (trace_result["fraction"] != 1.0)
				{
					new_pos = trace_result["position"] + (0,0,spacing);
				}
				spawn_mist(level._effect[ "vfx_alien_env_traverse_medium" ],new_pos);
				vert_itr = int(ceil(wall_height / spacing));
				for (k=0; k<vert_itr; k++)
				{
					spawn_mist(level._effect[ "vfx_alien_env_traverse_medium" ],new_pos + ((0,0,(k*spacing + spacing))));
				}
				pos_before = pos_now;
			}
		}
		wait 1.5;
	}
	// level._effect[ "vfx_alien_env_traverse_medium" ];
}

// ============================================================================
// Mist Crater
// ============================================================================

init_mist_crater_fx()
{
	wait 1.0;
	//level.crater_pos = (1490,-815,688);
	//PlayFX(level._effect[ "vfx_alien_mist_crater_idle"], level.crater_pos, (1,0,0), (0,0,1));
	//thread mist_radius_rollout(60.0);
	
	level.mist_zones 	= [];
	mist_zone_trigs 	= getentarray( "mist_zone_trig", "targetname" );
	
	foreach ( zone_trig in mist_zone_trigs )
	{
		zone 			= spawnstruct();
		zone.trigger 	= zone_trig;
		mist_start 		= getstruct( zone_trig.target, "targetname" );
		zone.mist_start = mist_start.origin;
		mist_end 		= getstruct( mist_start.target, "targetname" );
		zone.mist_end 	= mist_end.origin;
		
		level.mist_zones[ level.mist_zones.size ] = zone;
	}
}

get_mist_start_loc()
{
	return get_mist_zone().mist_start;
}

get_mist_end_loc()
{
	return get_mist_zone().mist_end;
}

get_mist_zone()
{
	touching_most 	= level.mist_zones[ 0 ];
	max_touching 	= 0;
	
	foreach ( zone in level.mist_zones )
	{
		player_touching = 0;
		foreach ( player in level.players )
		{
			if ( player istouching( zone.trigger ) )
				player_touching++;
		}
		
		if ( max_touching <= player_touching )
		{
			max_touching = player_touching;
			touching_most = zone;
		}
	}
	
	return touching_most;
}

has_mist_zones()
{
	return isdefined( level.mist_zones );
}

mist_radius_rollout(mist_transition_time, bReverse )
{
	earthquaked = false;	// keeps track if this mist wall has already quaked
	
	TWO_PI 		= 6.283185307;
	
	if ( has_mist_zones() )
	{
		target_pos 	= get_mist_end_loc();
		start_pos 	= get_mist_start_loc();
	}
	else
	{
		target_pos 	= (-202,7594,596); // CABIN location at the back side of our playtest area
		start_pos 	= (1490,-815,688); // CABIN
	}
	
	target_vec 	= ( target_pos - start_pos ); //(target_pos-level.crater_pos);
	target_len 	= Length( target_vec ); // distance from the crater center to target_pos
	target_vec	= VectorNormalize( target_vec );
	
	mist_wall_effect = level._effect[ "vfx_alien_mist_ring_wall" ];
	mist_wall_effect_base = level._effect[ "vfx_alien_mist_ring_wall_base" ];
	
	crater_radius = 750;
	mist_radius = crater_radius; // starting radius at the crater when the mist rolls out
	mist_spacing_on_radius = 200; // spacing of the spawned mist elemn - needs to be balanced with the size of the effect
	mist_spacing = 200; // spacing of the spawned mist elem in the direction it's moving - forward
	num_itrs = (target_len/mist_spacing);
	mist_time_itr = mist_transition_time/num_itrs;
	angle_spread = 15;
	angle_spread_dot = Cos(angle_spread);
	jitter_amt = 10;
	
	if (bReverse)
		mist_radius = target_len; // reversing .. start at the maximum

	while (1)
	{
		mist_circumference = TWO_PI * mist_radius;
		num_mist_points = floor(mist_circumference / mist_spacing_on_radius);
		circle_points = getCirclePoints(num_mist_points, (mist_radius+200), start_pos );
		
		// optimization, injecting waits between spawn fx
		wait_itr = mist_time_itr/0.05;
		wait_per = int( num_mist_points / wait_itr );
		wait_counter = 0;
		// -------------
		
		spawned_mist_counter = 0;
		for (i=0; i<num_mist_points; i++)
		{
			pt_raw = circle_points[i];
			
			pt = circle_points[i] * (1,1,0);
			pt_vec = VectorNormalize(pt-(start_pos * (1,1,0)));
			
			dot = VectorDot(pt_vec,target_vec);
			if (dot >= angle_spread_dot)
			{
				trace_result = BulletTrace(pt_raw + (0,0,500),pt_raw + (0,0,-1000), false);
				// jitter the result a bit
				trace_result["position"] += (RandomFloatRange(jitter_amt * -1,jitter_amt),RandomFloatRange(jitter_amt * -1,jitter_amt),0);
				
				PlayFX(mist_wall_effect,trace_result["position"],pt_vec,(0,0,1));
				thread mist_slope_check(trace_result["position"], pt_vec, mist_spacing, mist_time_itr, mist_wall_effect_base);
				spawned_mist_counter += 1;
			}
			
			// optimization, injecting waits between spawn fx
			if ( wait_counter >= wait_per )
			{
				wait_counter = 0;
				wait 0.05;
			}
			else
			{
				wait_counter++;
			}
			// ----------------
		}

		// game stuff
		foreach ( ent in level.mist_affected_ents )
		{
			if ( !isAlive( ent ) )
			{
				continue;
			}
			
			// skip testing ents already covered previously
			if ( isdefined( bReverse ) && bReverse )
			{
				if ( !( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" )))
					continue;
			}
			else
			{
				if ( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" ) )
					continue;
			}
			
			// if mist has passed/hit the ent
			ent_dist_from_crater = Length(start_pos-ent.origin);
			if ( ( !bReverse && ent_dist_from_crater < mist_radius ) || ( bReverse && ent_dist_from_crater > mist_radius ) )
			{
				// quake players
				if ( !earthquaked && isplayer( ent ) )
				{
					level notify( "sfx_fog_surround" );
					thread quaking( 0, 0.1, 12, ent, 1200 );
					thread quaking( 5, 0.2, 5, ent, 600 );
					earthquaked = true;
				}
				//switch_dist_past_wall 	= 500;	// this is the distance the fog passed player before switching of sky
				
				// checks how far wall has passed the ent
				// perp_point 		= PointOnSegmentNearestToPoint( point_1_in_line, point_2_in_line, ent.origin );
								
				// if distance passed satisfies
				//if ( isplayer( ent ) )
					//IPrintLn( "HIT! Dist: " + dist_from_fog );
				
				if ( isdefined( bReverse ) && bReverse )
				{
					if ( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" ) )
						ent ent_flag_clear( "inside_mist" );
				}
				else
				{
					if ( !( ent ent_flag_exist( "inside_mist" ) && ent ent_flag( "inside_mist" )))
						ent ent_flag_set( "inside_mist" );
				}
			}
		}
		
		
		if (bReverse)
		{
			mist_radius -= mist_spacing;// * 0.5;
			if (mist_radius < crater_radius)
				break;
		} else {
			mist_radius += mist_spacing;// * 0.5;
			if (mist_radius > target_len)
				break;
		}
		
		//wait mist_time_itr;
	}

	// failsafe when player did not get combed by the mist rolling out
	if ( isdefined( bReverse ) && bReverse )
	{
		foreach ( player in level.players )
		{
			if ( player ent_flag( "inside_mist" ) )
				player ent_flag_clear( "inside_mist" );
		}
	}
}

// check ahead of where we just spawned
// to see if we need to spawn more elements
// to adapt for a steep slope
mist_slope_check(pos, dir, mist_spacing, time_itr, the_effect)
{
	new_pos = pos + (dir*mist_spacing) + (0,0,100);
	trace_result = BulletTrace(new_pos, new_pos + (0,0,-500),false);
	trace_pos = trace_result["position"];
	len = Length(new_pos-trace_pos);
	// vertical_len = abs(new_pos[2]-trace_pos[2]);
	
	if (len > mist_spacing)
	{
		num_itr = floor(len/mist_spacing)*2;
		new_wait_time = time_itr/num_itr;
		new_spacing = len / num_itr;
		for (i=0; i<(num_itr-1); i++)
		{
			new_trace_start = pos + (dir*(new_spacing * (i+1)) + (0,0,100));
			trace_result = BulletTrace(new_trace_start, new_trace_start + (0,0,-500),false);
			PlayFX(the_effect,trace_result["position"],dir, (0,0,1));
			wait new_wait_time;
		}
// 			angle = acos(VectorDot(dir, VectorNormalize(trace_pos-new_pos)));
	}
}
// ============================================================================
// Inits
// ============================================================================

init_mist_fx()
{
	// fx
	level._effect[ "vfx_alien_env_traverse_medium" ] = loadfx( "vfx/gameplay/alien/vfx_alien_env_traverse_medium" );
	level._effect[ "vfx_alien_env_dark_loop_huge" ] = loadfx( "vfx/gameplay/alien/vfx_alien_env_dark_loop_huge" );
	level._effect[ "vfx_alien_env_ambient_fog" ] = loadfx( "vfx/gameplay/alien/vfx_alien_env_ambient_fog" );
	level._effect[ "vfx_alien_mist_startup" ] = loadfx( "vfx/gameplay/alien/vfx_alien_mist_startup" );
	level._effect[ "vfx_alien_mist_crater_idle" ] = loadfx( "vfx/gameplay/alien/vfx_alien_mist_crater_idle" );
	level._effect[ "vfx_alien_mist_ring_wall" ] = loadfx( "vfx/gameplay/alien/vfx_alien_mist_ring_wall" );
	level._effect[ "vfx_alien_mist_ring_wall_base" ] = loadfx( "vfx/gameplay/alien/vfx_alien_mist_ring_wall_base" );
	
}

// This implementation assumes it's using target/targetname to link script structs together.
// In the map I give an example of using script_linkTo and script_linkName to make a tree.
init_mist()
{
	//init_mist_volumes();
	init_mist_traversal_paths();
	//init_mist_static_paths();
	
	// fog trigger list
	level.fog_triggers = GetEntArray("mist_void_radius", "targetname");
	
	// collect ents affected by mist wall
	level.mist_affected_ents = array_combine( level.fog_triggers, level.mist_affected_ents );
}

init_mist_volumes()
{
	volumes = GetEntArray( "fog_volume", "script_noteworthy" );

	level.fog_volumes = [];
	foreach ( volume in volumes )
	{
		volume.state = "off";
		level.fog_volumes[ level.fog_volumes.size ] = volume;
	}
}

init_mist_traversal_paths()
{
	// *************************************************************************
	// fog traversal paths
	// TO DO: need to add support for multiple paths - planning on using
	// (int) script_group on the starting points to handle this
	// until we do this, only one of these paths in a level. bah.

	level.fog_traversal_start_nodes = getstructarray("fog_traversal_path_start", "script_noteworthy");
	level.fog_traversal_nodes = [];
	if (level.fog_traversal_start_nodes.size > 0) {
		for (i=0; i<level.fog_traversal_start_nodes.size; i++) {
			current_struct = level.fog_traversal_start_nodes[i];
			level.fog_traversal_nodes[i] = [];
			while ( true )
			{
				current_struct.fog_params = get_fog_params( current_struct );
				current_struct.enabled = true;
				current_struct.height = get_fog_height( current_struct );
				//current_struct.volumes = get_fog_volumes( current_struct );
				current_struct.width = get_fog_width( current_struct );
				
				level.fog_traversal_nodes[i][ level.fog_traversal_nodes[i].size ] = current_struct;

				if ( !isDefined( current_struct.target ) )
				{
					break;
				}
				
				current_struct = GetStruct( current_struct.target, "targetname" );
			}			
		}
	}
}

init_mist_static_paths()
{
	level.fog_static_start_nodes = getstructarray("fog_static_path_start", "script_noteworthy");
	level.fog_static_nodes = [];
	if (level.fog_static_start_nodes.size > 0) {
		for (i=0; i<level.fog_static_start_nodes.size; i++) {
			current_struct = level.fog_static_start_nodes[i];
			level.fog_static_nodes[i] = [];
			while ( true )
			{
				
				current_struct.fog_params = get_fog_params( current_struct );
				current_struct.enabled = true;
				current_struct.height = get_fog_height( current_struct );
				//current_struct.volumes = get_fog_volumes( current_struct );
				current_struct.width = get_fog_width( current_struct );
				
				level.fog_static_nodes[i][ level.fog_static_nodes[i].size ] = current_struct;
				
				// collect ents affected by mist wall
				level.mist_affected_ents[ level.mist_affected_ents.size ] = current_struct;
				
				if ( !isDefined( current_struct.target ) )
				{
					break;
				}
				
				current_struct = GetStruct( current_struct.target, "targetname" );
			}			
		}
	}
}

// ============================================================================
// Utility functions
// ============================================================================

// Spawns the mist fx <the_effect> on position <pos>, avoids "fog_trigger" trigger radius
spawn_mist(the_effect, pos)
{
	// check against negative volumes
	bIgnore = false;
	foreach(fog_trigger in level.fog_triggers)
	{
		if ( !isdefined( fog_trigger.height ) )
			height = 100000;
		else
			height = fog_trigger.height;
		
		if ( abs( Distance2D( fog_trigger.origin, pos ) ) <= fog_trigger.radius )
		{
			if ( abs( fog_trigger.origin[ 2 ] - pos[ 2 ] ) <= height )
			{
				bIgnore = true;
				break;
			}
		}
	}
	
	if (!bIgnore)
		PlayFX(the_effect, pos);
}

default_fog( transition_time, near, half )
{
	self notify( "stop_surrounding_ambient_fx" );
	
	self thread mist_sfx_off();
	
	if ( isdefined( self.mist_fog_setting ) && !self.mist_fog_setting )
		return;
	
	self.mist_fog_setting = false;

	//SetDvar("r_skyFogUseTweaks",1);
	//thread setSkyFog(0,-60,0,transition_time);
	
	fog_color 	= (0.539, 0.531, 0.602 );
	fog_opacity = 0.7;
	
	if ( !isdefined( near ) )
		near = level.default_fog[ "near" ];
	if ( !IsDefined( half ) )
		half = level.default_fog[ "half" ];

	//self thread set_vision_set_player(level.fog_vision_int_clear, CONST_VISION_MIN_TRANSITION_TIME);
	self thread set_vision_set_player(level.fog_vision_ext_clear, CONST_VISION_MIN_TRANSITION_TIME);

	self playerSetExpFog( 	near, 
						 	half, 
						 	fog_color[0], 
						 	fog_color[1], 
						 	fog_color[2], 
						 	0,
						 	fog_opacity,
						 	transition_time,
						 	0,
						 	0,
						 	0,
							0,
							( 0, 0, 0 ),
							0,
							1,
							0,
							0.94,
							0,
							80 );

}

mist_fog( transition_time, near, half )
{
	if ( isdefined( self.mist_fog_setting ) && self.mist_fog_setting )
		return;
	
	self thread mist_sfx_on();
	self.mist_fog_setting = true;
	
	self thread spawn_surrounding_ambient_fx(600);
	
	//SetDvar("r_skyFogUseTweaks",1);
	//thread setSkyFog(1,-60,0,transition_time);

	fog_color 	= (0.49, 0.49, 0.49);
	fog_opacity = 1;
	
	if ( !isdefined( near ) )
		near = level.mist_fog[ "near" ];
	if ( !IsDefined( half ) )
		half = level.mist_fog[ "half" ];
	
	self playerSetExpFog( 	(near * 0.25), 
						 	(half * 0.25), 
						 	fog_color[0], 
						 	fog_color[1], 
						 	fog_color[2], 
						 	0,
						 	fog_opacity + ((1.0-fog_opacity) * 0.5), 
						 	transition_time * 1.5, 
						 	0,
						 	0,
						 	0,
							0,
							( 0, 0, 0 ),
							0,
							1,
							0,
							1,
							0,
							80 );
	
	wait (transition_time * 2);
	//self thread set_vision_set_player(level.fog_vision_int_fog, CONST_VISION_MIN_TRANSITION_TIME);
	self thread set_vision_set_player(level.fog_vision_ext_fog, transition_time * 2 );

	self playerSetExpFog( 	near, 
						 	half, 
						 	fog_color[0], 
						 	fog_color[1], 
						 	fog_color[2],
						 	0,
						 	fog_opacity, 
						 	transition_time * 2,
						 	0,
						 	0,
						 	0,
							0,
							( 0, 0, 0 ),
							0,
							1,
							0,
							1,
							0,
							80 );
}

mist_sfx_on()
{
	self PlayLocalSound( "alien_fog_enter" ); 
	wait 3.9;
	level.mist_sfx_node playLoopSound( "amb_alien_fog_lr" );
}

mist_sfx_off()
{
	self PlayLocalSound( "alien_fog_exit" ); 
	wait 6;
	level.mist_sfx_node StopLoopSound( "amb_alien_fog_lr" );
}

setSkyFog(strength, min_angle, max_angle, transition_time)
{
	if (transition_time == 0)
	{
		SetDvar("r_sky_fog_intensity", strength);
		SetDvar("r_sky_fog_min_angle", min_angle);
		SetDvar("r_sky_fog_max_angle", max_angle);
	} else {
		num_itr = floor((transition_time / 0.05)+0.5); // @ 20hz, how many iterations do we need?
		
		start_intensity = GetDvarFloat("r_sky_fog_intensity");
		start_min_angle = GetDvarFloat("r_sky_fog_min_angle");
		start_max_angle = GetDvarFloat("r_sky_fog_max_angle");
		
		intensity_inc = (strength-start_intensity) / num_itr;
		min_angle_inc = (min_angle-start_min_angle) / num_itr;
		max_angle_inc = (max_angle-start_max_angle) / num_itr;
		
		for (i=0; i<num_itr; i++)
		{
			SetDvar( "r_sky_fog_intensity", start_intensity + (intensity_inc * (i+1)) );
			SetDvar( "r_sky_fog_min_angle", start_min_angle + (min_angle_inc * (i+1)) );
			SetDvar( "r_sky_fog_max_angle", start_max_angle + (max_angle_inc * (i+1)) );
			wait (0.05);
		}
	}
}

spawn_surrounding_ambient_fx(rad)
{
	self notify( "stop_surrounding_ambient_fx" );
	self endon( "stop_surrounding_ambient_fx" );
	self endon( "death" );
	self endon( "disconnect" );
	
	while ( true )
	{
		wait 0.65 + 0.01; // with this extra delay, this loop will not continue if called too quickly
		
		vel = self GetEntityVelocity();
		new_pos = (self.origin) + (vel * 2.0) + ((RandomFloat(2.0*rad) - rad), (RandomFloat(2.0*rad) - rad), RandomFloat(rad*0.333));
		PlayFX(level._effect[ "vfx_alien_env_ambient_fog" ], new_pos,(1,0,0), (0,0,1));
	}
}

quaking( delay, intensity, duration, source_ent, radius )
{
	if ( isdefined( delay ) )
		wait delay;
	
	Earthquake( intensity, duration, source_ent.origin, radius );
}

get_fog_height( struct )
{
	// Run a trace to ground, get actual height above ground
	return 128;
}

get_fog_params( struct )
{
	fog_type = struct.script_index;
	// Lookup fog params, add to struct
}

get_fog_volumes( struct )
{
	volumes = [];
	test_ent = Spawn( "script_origin", struct.origin );
	foreach ( volume in level.fog_volumes )
	{
		if ( test_ent IsTouching( volume ) )
		{
			volumes[ volumes.size ] = volume;
		}
	}
	
	test_ent delete();
	
	return volumes;
}

get_fog_width( struct )
{
	// Couple options.  
	// 1) Run a set of traces here (precalculated so we don't have to do this during gameplay).
	//    Could be added to a map building tool in the future.
	// 2) Use a radius KVP set on the entity.
}

is_touching_fog( entity )
{
	foreach ( volume in level.fog_volumes )
	{
		if ( volume.state != "active" && entity isTouching( volume ) )
		{
			if ( volume.state == "on" )
			{
				return true;
			}
			if ( volume.state == "transitioning" )
			{
				// do more logic to see where the current fog wall is
				return;
			}
		}
	}
}

getRingPoints(rad, center_pos, thickness, spacing)
{
	PI = 3.14159265359;
	
	trigger_circumference = 2.0 * PI * rad;
	point_count = Int(trigger_circumference / spacing);
	inner_points_list = getCirclePoints(point_count, rad, center_pos);

	trigger_circumference = 2.0 * PI * (rad + thickness);
	point_count = Int(trigger_circumference / spacing);
	outer_points_list = getCirclePoints(point_count, (rad + thickness), center_pos);
	
	// join the arrays
	return (array_combine(inner_points_list, outer_points_list));

}

getCirclePoints(num_points, rad, center_pos)
{
    PI = 3.14159265359;
    // num_points = floor(360.0/num_points);
    // slice = 2.0 * PI / num_points;
    slice = 360 / num_points;
	points_list = [];
	for (i=0; i < num_points; i++)
    {
        angle = slice * i;
        newX = (center_pos[0] + rad * cos(angle));
        newY = (center_pos[1] + rad * sin(angle));
        p = (newX, newY, center_pos[2]);
        points_list[points_list.size] = p;
    }
	return points_list;
}

CubicInterpolate(y0, y1, y2, y3, mu)
{
	mu2 = mu*mu;
	
	// cubic
	a0 = y3 - y2 - y0 + y1;
	a1 = y0 - y1 - a0;
	a2 = y2 - y0;
	a3 = y1;

	if (false)
	{
		// catmull-rom interpolation
		a0 = -0.5*y0 + 1.5*y1 - 1.5*y2 + 0.5*y3;
		a1 = y0 - 2.5*y1 + 2*y2 - 0.5*y3;
		a2 = -0.5*y0 + 0.5*y2;
		a3 = y1;
	}
   
	return ( a0 * mu * mu2 + a1 * mu2 + a2 * mu + a3);
}

CosineInterpolate(y1, y2, mu)
{
	PI = 3.14159265359;
	mu2 = (1.0 - cos( mu*PI )) * 0.5;
	return ( y1*(1-mu2)+y2*mu2 );
}
/*
play_mist_approaching_vo()
{
	sound_alias = [ "so_alien_anc_themistisapproaching",
				    "so_alien_anc_mistapproachingfromthe",
				    "so_alien_anc_thecreaturesareout",
				    "so_alien_anc_mistcominginfrom",
				    "so_alien_anc_ifyourestuckdowntown",
				    "so_alien_anc_gsnalertifanyone"
 				  ];
	radio_dialogue ( sound_alias [ RandomIntRange( 0, sound_alias.size )] );
}

play_mist_clearing_vo( delay_time )
{
	wait( delay_time );
	sound_alias = [ "so_alien_anc_globalsurvivornetwork",
				    "so_alien_anc_themistispassing",
				    "so_alien_anc_itsalmostblownthrough",
				    "so_alien_anc_themistisreceeding",
				    "so_alien_anc_reportsareinthat",
				    "so_alien_anc_gsnupdatewevebeen_2"
 				  ];
	radio_dialogue ( sound_alias [ RandomIntRange( 0, sound_alias.size )] );
}
*/