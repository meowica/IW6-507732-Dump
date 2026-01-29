#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_stealth_utility;
#include maps\jungle_ghosts_util;

#using_animtree("generic_human" );

CONST_WIND_STRENGTH = 1;
CONST_WIND_AMPLITUDE = .05;


intro_setup()
{			
	//UAV IS ACTIVE
	thread cull_distance_logic();
	thread fade_out_in( "black", undefined, 1  );
	
	//spawn the player rig for the parachute fall 
	ent = getstruct("parachute_anim_ent_player", "targetname");
	player_rig = spawn_anim_model( "player_rig", ent.origin );
	player_rig hide();
	
	//new freefall pre-intro 
	level.player EnableInvulnerability();
	maps\jungle_ghosts_util::move_player_to_start( "player_freefall_start" );
	trigger_wait_targetname("player_freefall_impact");
	
	thread fade_out_in( "white", undefined, .10  );
		
	//maps\jungle_ghosts_util::move_player_to_start( "jungle_player_start" );
	thread setup_friendlies();	
	thread setup_jungle_enemies();
	
	//thread player_backtrack_tracking();
	
	level.player thread play_sound_on_entity("scn_jungle_tree_branch");
	
	thread parachute_intro_fx();	
	thread parachute_spawn();
	
	level.player allowstand( true );
	level.player SetStance( "stand" );	
	level.player AllowSprint( false );
	level.player AllowCrouch( false );
		
	//show the player rig
	player_rig delayCall( 0.4, ::Show );
	
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.4, 0.2, 0.2 );
	wait( 0.5 );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0 );
	//time = 4;
	//level.player LerpViewAngleClamp( time, time * 0.5, time * 0.5, 20, 20, 30, 10 );

	level.player notify( "start_falling_anim" );
	ent anim_single_solo( player_rig, "para_crash" );
	
	level.player notify("done_falling");
	player_anchor =  level.player spawn_tag_origin();
	level.player unlink();
	wait(.05);
	
	level.player PlayerLinkToDelta( player_anchor, "tag_origin", 1, 30, 30, 50, 60 ); 
	player_anchor thread parachute_sway_settings();
	player_rig delete();

    
	wait 3;
	weapon = "knife_jungle";
	level.player GiveWeapon( weapon );
	level.player SwitchToWeapon( weapon );
	
	parachute_waittill_player_cuts();
	flag_set("player_landed");
	wait 1;
	level.player unlink();

	autosave_by_name("boots_on_ground");

	level.player AllowSprint( true );
	level.player AllowCrouch( true );
	
	thread hill_fx();
	thread do_bokeh( "hill_pos_1" );
		
	thread stand_player_up();
	thread do_birds();
	level thread jungle_stealth_settings();
	
	thread connect_dropdown_traverse();
	thread motion_tracker_setup();
	thread inform_player_when_section1_is_clear();
	thread first_distant_sat_launch();

	
	thread dead_pilot_hang();
		
	level.did_inactive_vo = 0;
	flag_wait("jungle_entrance");
	autosave_by_name("jungle_entrance");
	thread ambient_jungle_music();
	thread player_spotted_music();
	
	flag_wait( "crash_arrive");
	
	if(! flag( "_stealth_spotted" ) )
	{
		level notify("stop_ambient_music");
		music_stop( 2 );
		//music_play("mx_jungle_runway_objective");
	}

}

dead_pilot_hang()
{	
	chutes = GetEntArray("dead_guy_chutes", "targetname");
	chutes[0].linker = chutes[0] spawn_tag_origin();
	chutes[1].linker = chutes[1] spawn_tag_origin();
	
	origin_offset = 286;
	
	chutes[0].linker.origin = chutes[0].origin + (0, 0, origin_offset);
	chutes[1].linker.origin = chutes[1].origin + (0, 0, origin_offset);
	
	chutes[0] LinkTo(chutes[0].linker, "tag_origin");
	chutes[1] LinkTo(chutes[1].linker, "tag_origin");


	ent = get_target_ent("lt_jokes");
	ent.animname = "dead_jungle_pilot";
	
	ent.anim_ent = ent spawn_tag_origin();
	
	ent LinkTo(ent.anim_ent, "tag_origin");
	ent.anim_ent LinkTo(chutes[0].linker, "tag_origin");
		
	ent useAnimTree( #animtree );
	ent.anim_ent thread anim_loop_solo(ent, "dead_idle", "dead_hang_ender");

	
	while (1)
	{
		chutes[0].linker RotateTo(chutes[0].linker.angles + (0.5, 0, 0), 6, 0, 0);
		chutes[1].linker RotateTo(chutes[1].linker.angles - (0.5, 0, 0), 6, 0, 0);
		wait 5;
		
		chutes[0].linker RotateTo(chutes[0].linker.angles - (0.5, 0, 0), 6, 0, 0);
		chutes[1].linker RotateTo(chutes[1].linker.angles + (0.5, 0, 0), 6, 0, 0);
		
		wait 5;

		chutes[0].linker RotateTo(chutes[0].linker.angles - (0.5, 0, 0), 6, 0, 0);
		chutes[1].linker RotateTo(chutes[1].linker.angles + (0.5, 0, 0), 6, 0, 0);
		
		wait 5;

		chutes[0].linker RotateTo(chutes[0].linker.angles + (0.5, 0, 0), 6, 0, 0);
		chutes[1].linker RotateTo(chutes[1].linker.angles - (0.5, 0, 0), 6, 0, 0);
		
		wait 5;
	}
}

player_backtrack_tracking()
{
	//level thread player_backtracking_vo();
	level.player_is_in_first_section = 1;
	struct = spawnstruct();
	struct.origin = (-3152, -2738, -196 );
    struct.angles = ( 0, 34, 0 );
    
    while( 1 )
    {
        spotangles = anglestoforward( struct.angles );
        othervec = VectorNormalize( struct.origin - level.player.origin );
        dot = VectorDot( spotangles, othervec );
        
        if( dot > 0  )
            //iprintln( "behind" );
        	level.player_is_in_first_section = 1;
        else
           // iprintln( "infront" );
       		 level.player_is_in_first_section = 0;
        wait( 1 );
    }
	
}

player_backtracking_vo()
{
	flag_wait( "hill_pos_1");
	
	if( flag( "player_went_right" ) ) 
		wait 10;

	//goal_origin = ( -2724, -2348.9, -411.4 );
	
	//TODO: Inform player when theyre going in the wrong direction,
	while( 1 )
	{
		if( level.player_is_in_first_section == 1 )
		{		
			wait( randomintrange( 7, 11 ) );
		}
		wait .5;		
	}
		
}


hill_fx()
{

	activate_exploder( "wind" );
	
	flag_wait_any( "crash_arrive", "_stealth_spotted" );
	wait 3.5;
	
	stop_exploder( "wind" );
	activate_exploder( "nonwind" );

}

parachute_vehicle_speed_control()
{
	self endon("reached_end_node");
	level.player thread play_sound_on_entity("mvmt_vestlight_plr_run_breath");
	level.player thread play_sound_on_entity("movement_foliage");
	wait 2.3;
	branch_crash();
	self Vehicle_SetSpeed( 50,10 );
	
	level.player thread play_sound_on_entity("movement_foliage");
	wait 1.8;
	branch_crash();
	self Vehicle_SetSpeed( 50,25 );
	level.player thread play_sound_on_entity("mvmt_vestlight_plr_run_breath");
	level.player thread play_sound_on_entity("movement_foliage");
	//wait 1.85;
	//branch_crash();
	//self Vehicle_SetSpeed( 50,30 );
	
	
	
}

branch_crash()
{
	self Vehicle_SetSpeedImmediate( 2, 2 );
	level.player thread play_sound_on_entity("scn_jungle_tree_branch");//Land_foliage bodyfall_grass_small
	
	//if( randomint(100)  > 60 )
	//level.player thread play_sound_on_entity("generic_pain_friendly_1" );
		
	earthquake( .25, .5, level.player.origin, 200 );
	SetBlur( 5, .10 );
	wait(RandomFloatRange( .35, .55) );
	SetBlur( 0, .10 );
}

parachute_waittill_player_cuts()
{
	//NotifyOnCommand("cut", "+attack" );
	//NotifyOnCommand("cut", "+attack" );
	NotifyOnCommand("cut", "+melee" );
	NotifyOnCommand("cut", "+melee_breathe" );
	NotifyOnCommand("cut", "+melee_zoom" );

	level.player waittill("cut");
}


parachute_sway_settings()
{
	wait .15;
	angles = level.player getplayerangles();
	angles = ( 0, angles[1], 0 );
	
	_right = anglestoright( angles );

	right = (_right) * 10;		
	left = right * -1;
	
	level endon("player_landed");

	players_right = level.player.origin + right;
	players_left =  level.player.origin + left;
	
	time = 12;
	self moveto( players_right, time*.5 );
	wait  time*.5;
	
	while(1)
	{	
		time = randomintrange( 13, 18 );
		self moveto( players_left, time, time *.1, time * .9 );
		wait time;
		self moveto( players_right, time, time *.1, time * .9 );
		wait time;		
	}
	
}

parachute_intro_fx()
{
	//shocks: defualt hold_breath pain flashbang
	thread parachute_intro_visions();
	thread parachute_intro_sound();
	level.player thread parachute_heartbeat();
	
	//exploder("vfx_falling_debris");		
	exploder( 1 );
	
	level.player waittill("done_falling");
	SetBlur( 5, .10 );
	wait( 2 );
	SetBlur( 0, 2 );
	
	heartbeat();
	wait( 1 );
	do_bird_single();
	heartbeat();
	wait( 2 );
	
	heartbeat();
	wait( 3 );
	
	heartbeat();


}

parachute_heartbeat()
{
	level.player endon("done_falling");
	
	while(1)
	{
		heartbeat();
		wait( 1.5 );
	}
	
}


heartbeat()
{
	SetBlur( 5, .25 );
	level.player thread play_sound_on_entity("breathing_heartbeat");
	wait.25;
	SetBlur( 0, .25 );
}

patachute_ground_reference()
{
	//level.player waittill("done_falling");
	ent = spawn("script_origin", (0,0,0) );
	level.player PlayerSetGroundReferenceEnt( ent );
	time = 2;
	
	while(1)
	{
		ent RotateTo( ( -30, 20, -15 ), time );
		wait( time);
		ent RotateTo( ( -10, -10, 5 ), time );
	}
	
	
}
parachute_intro_visions()
{
	//aftermath coup_sunblind near_death
	//level.player ShellShock( "flashbang", .05);
	wait .5;
	//level.player thread set_vision_set("jungle_ghosts", .25 );
	
	level.player waittill("done_falling");

}


parachute_intro_sound()
{
	thread parachute_player_land_sounds();
	level endon("player_landed" );
	level.player thread play_sound_on_entity("breathing_better" );	
	level.player thread play_sound_on_entity("scn_jungle_tree_landing");
	wait .25;
	level.player thread play_sound_on_entity("movement_foliage");
	level.player thread play_sound_on_entity("weap_sniper_breathgasp" );
	wait .25;
	level.player thread play_sound_on_entity("movement_foliage");
	wait .25;

	level.player thread play_sound_on_entity("movement_foliage");
	wait .25;
	
	level.player waittill("done_falling");

	level.player thread play_sound_on_entity("scn_jungle_tree_branch");
	level.player thread play_sound_on_entity("scn_jungle_player_tree_pain" );
	earthquake( .25, .5, level.player.origin, 200 );
	//wait .10;
	//level.player  play_sound_on_entity("weap_sniper_breathgasp" );
	wait 1.5;
	level.player play_sound_on_entity("breathing_better" );	
	wait 1.5;
	level.player play_sound_on_entity("breathing_better" );
	
}

parachute_player_land_sounds()
{
	flag_wait("player_landed");
	wait 1.7;
	level.player thread play_sound_on_entity("scn_jungle_tree_jumpland");
	level.player DoDamage( 10, level.player.origin );
	level.player ShellShock( "prague_swim", 10 );
	
	wait .5;
	level.player thread play_sound_on_entity("breathing_better" );
	
}


#using_animtree("vehicles");
parachute_spawn()
{
	chute_node = getstruct( "parachute_struct", "targetname" );
	chute_node.origin = (-6129.8, -3073.9, 809.6 );
	chute_node.angles = (0, 213, 0);
	parachute  = spawn_anim_model( "player_parachute" );
	
	chute_node thread anim_single_solo( parachute, "parachute_land" );
	wait(.05);
	anim_set_time( [parachute], "parachute_land", .74 ); //Radiant Anim Preview time = 3.48/12.93 26% ( SO: script time = 1 -26%  )
	anim_set_rate( [parachute], "parachute_land", 0 );
}

ambient_jungle_music()
{
	//todo: UPDATE WAIT TIMES FOR FINAL MUSIC TIMES. MUSICLENGTH NOT WORKING CURRENTLY
	level endon("stop_ambient_music");
	music_play("mus_jungle_reveal");
	
	//delay = musicLength( "mus_jungle_reveal" );
	//fade_in_time = 10;
	//fade_out_time = 10;
	wait( 30 );
		
	while(1)
	{
		if( flag( "_stealth_spotted" ) )
			return;
		
		//total_playtime = RandomIntRange( 25, 35 );
		time_between_music = RandomIntRange( 15, 20 );
		
		wait( time_between_music );
		
		if( flag( "player_spotted_music" ) )
			continue;
		
		music_play( "mus_jungle_stealth" );
		wait( 25 );
		
		/*
		thread music_fade_in( "mus_jungle_intro", fade_in_time );
		wait( total_playtime - fade_out_time );
		music_stop( fade_out_time );		
		wait( fade_out_time );		
		*/
	}

}

player_spotted_music()
{
	level endon( "waterfall_approach" );
	while(1)
	{
		level waittill_any ("enemy_stealth_reaction", "_stealth_spotted" );
		flag_set( "player_spotted_music" );		
		//music_play( "mx_jungle_break_stealth_short", 1 );
	
		wait (40 );
		
		flag_clear( "player_spotted_music" );
	}
	
}

music_fade_in( song, fadein_time )
{
	//only play music if this dvar is 1. 
	if( GetDvarInt( "music_enable" ) == 0 )
	{
		return;
	}
	
	AssertEx( isdefined( level._audio ), "Cannot play music before _load::main " );
	level._audio.last_song = song;

	MusicPlay( song, fadein_time );	
}


jungle_moving_foliage_settings()
{
/*
"r_reactiveMotionWindDir" - Controls the global wind direction. Steve: 3d vector -1 to 1 ( 1 -1 0 ) for example
"r_reactiveMotionWindStrength" - Scale of the global wind direction . 1 = normal 50 = WINDY 1-- looks dumb. 
"r_reactiveMotionWindAreaScale" - Scales distribution of wind motion . Steve: Makes the grass more bendy instead of stiff, Shouldnt go past 10ish.. 
"r_reactiveMotionWindAmplitudeScale" - Scales amplitude of wind wave motion. Steve* How much the grass actually moves. .1 = subtle. 1 = Theres wind. 2 = WINDY. .  

r_reactiveMotionPlayerRadius: Radial distance from the player that influences reactive motion models (inches) 
r_reactiveMotionActorRadius: Radial distance from the ai characters that influences reactive motion models (inches) 
r_reactiveMotionActorVelocityMax: AI velocity considered the maximum when determining the length of motion tails (inches/sec) Steve: ?
r_reactiveMotionVelocityTailScale: Additional scale for the velocity-based motion tails, as a factor of the effector radius Steve: ?
r_reactiveMotionWindFrequencyScale: scales the frequency of the system's wind wave motion: Steve: speed at which it moves
*/
	SetSavedDvar( "r_reactiveMotionPlayerRadius", 100 );
	SetSavedDvar( "r_reactiveMotionActorRadius", 20 );
	SetSavedDvar( "r_reactiveMotionActorVelocityMax", 0.5 );
	SetSavedDvar( "r_reactiveMotionEffectorStrengthScale", 10 );
	SetSavedDvar( "r_reactiveMotionWindDir", ( 1, 1, 1 ) );
	SetSavedDvar( "r_reactiveMotionWindFrequencyScale", 0.03 );
	SetSavedDvar( "r_reactiveMotionWindAmplitudeScale", 2 );
	SetSavedDvar( "r_reactiveMotionWindStrength", 0 );
	//SetSavedDvar( "r_reactiveMotionHelicopterRadius", 2400 );
	//SetSavedDvar( "r_reactiveMotionVelocityTailScale"  );
	//SetSavedDvar( "r_reactiveMotionWindAreaScale", 3 );
	
	adjust_moving_grass( .8, 1, .4, .15 );

}
motion_tracker_setup()
{
	level endon ("crash_arrive");
	flag_wait("jungle_entrance");
	new_speed = undefined;
	default_speed = 2;
	current_speed = default_speed;
	
	level.motion_tracker_sweep_speed = default_speed; 
	level.motion_tracker_sweep_range = 1600; //1300 is default
		
	SetSavedDvar( "MotionTrackerRange", level.motion_tracker_sweep_range );
	SetSavedDvar( "MotionTrackerSweepInterval", level.motion_tracker_sweep_speed );
	
	while(1)
	{
		baddies =  getaiarray("axis");
		if( baddies.size != 0 )
		{
			//get closest bad guy and check how close he is
			baddies = SortByDistance( baddies, level.player.origin );		
			dist = DistanceSquared( baddies[0].origin, level.player.origin );
			
			if( dist < 400*400 )
			{
				new_speed  = .5;						
			}
			else if( dist < 600*600 )
			{
				new_speed  = 1;		
			}
			else if( dist < 800*800 )
			{
				new_speed  = 1.5;
			}
			else
			{
				new_speed  = default_speed;
			}	
			
			if( new_speed != current_speed )
			{
				update_motion_tracker_speed( new_speed );	
				current_speed = new_speed;
				if( current_speed <= 1 )
				{
					if( randomint( 100 ) > 60 )
						random( level.alpha ) notify ("enemy_close" ); //this notify gets spammy so throttling it here
				}
				if( current_speed > 1)
				{
					if (isdefined(baddies[0].script_stealthgroup))
					{
						//thread draw_line_from_ent_to_ent_for_time(level.player geteye(), baddies[0].origin, 1,1,1, 30);
						if (cointoss())
						{
							if (!BulletTracePassed(level.player geteye(), baddies[0].origin, false, level.player))
							{
								baddies[0] thread birds_on_baddy();
							}
						}
					}
					
				}
			}	
		}
		//no baddies alive, set default
		else
		{
			if( current_speed != default_speed )
			{
				update_motion_tracker_speed( default_speed );	
				current_speed = default_speed;
			}
		}
		wait (1);
	}	
}

CONST_TIME_BETWEEN_ENEMY_BIRDS = 25;

birds_on_baddy()
{
	self endon( "death" );
	
	if(isdefined(  self.doing_enemy_birds ) )
		return;
	
	self.doing_enemy_birds = 1;
		
	self do_bird_single_enemy();
	
	wait CONST_TIME_BETWEEN_ENEMY_BIRDS;
	
	self.doing_enemy_birds = undefined;
}


update_motion_tracker_speed( new_speed )
{	
	SetSavedDvar( "MotionTrackerSweepInterval", new_speed );	
}

first_distant_sat_launch()
{
	flag_wait("first_distant_sat_launch");
	level.player thread play_sound_in_space("jg_sat_launch_distant_first", level.player.origin);
	wait (0.3);
	
	Earthquake(0.1, 4, level.player.origin, 850);
}

jungle_apache_logic()
{
	flag_wait( "jungle_entrance" );
	wait RandomIntRange( 25, 45 );
	
	if( flag( "_stealth_spotted" ) )
		return;
	
	level.jungle_apache = spawn_vehicle_from_targetname( "jungle_apache" );
	//level.jungle_apache thread jungle_apache_searchlight_logic();
	search_structs = getstructarray( "jungle_search", "targetname" );
	exit_structs = getstructarray( "jungle_exit", "targetname" );
	heli = level.jungle_apache;
	heli thread mgoff();
	heli thread jungle_apache_damage_logic();
	heli thread jungle_apache_fx();
	
	node = getClosest( level.player.origin, search_structs );
	heli SetVehGoalPos( node.origin, 1 );
	
	level.alpha1 delayThread( 3, ::do_safe_radio_line, "jungleg_gs1_enemychopperstaydown" );

	heli waittill("goal" );
	wait 500;
		
	node = getFarthest( heli.origin, exit_structs );
	heli SetVehGoalPos( node.origin, 1 );

	level.alpha1 delayThread( 6, ::do_safe_radio_line, "jungleg_gs1_weshouldkeepmovin" );
	
	heli waittill("goal" );
	wait RandomIntRange( 10, 15 );		
	

	heli delete();
			
}

jungle_apache_fx()
{
	self endon("reached_end_node");
	while(1 )
	{
		spot = self.origin - (0,0,800);
		angles = self.angles;
		leaves_burst( spot, angles );
		wait 2;	   		
	}
	
}

leaves_burst( spot, angles  )
{
	for( i = 0; i< 5; i++ )
	{
		fwd = AnglesToForward( angles );
		up = AnglesToUp( angles );
		playfx( getfx( "chopper_leaves" ), spot, fwd, up  );
		wait(.05);
	}	
}

jungle_apache_damage_logic()
{
	//self = chopper
	//alert nearby enemies if player shoots chopper
	
	self endon("death");	
	self Godon();
	self waittill("damage", amount, attacker );
	if( isdefined( attacker ) )
	{
		if( attacker == level.player )
		{
			close_enemies = get_array_of_closest( level.player.origin, getaiarray("axis"), undefined, 5, 2000, 0 );
			
			if( close_enemies.size == 0 )
				return;
			
			foreach( guy in close_enemies )
				guy delaythread( 3, ::manually_alert_me );
			
			wait ( 3 );
			level.player maps\_stealth_shared_utilities::group_flag_set( "_stealth_spotted" );

		}
	}			
}


jungle_apache_searchlight_logic()
{
	level endon("hill_pos_1");
	self mgoff();
	gun = self.mgturret[0];
	gun SetLeftArc(180);
	gun SetRightArc(180);
	gun SetTopArc(180);
	gun SetBottomArc(180);
	gun SetMode( "manual" );
	
	_fwd = AnglesToForward( self.angles);
	spot = self.origin + (_fwd * 10000 );
	self.target_ent = spawn("script_model", spot);
	self.target_ent setmodel( "tag_origin" );
	gun settargetentity( self.target_ent );
	
	self.override_target = undefined;
	
	while(1)
	{
		if(IsDefined( self.override_target ) )
		{
			//IPrintLn( "standing by for override target" );
			wait(2);
			continue;
		}
		
		//IPrintLn( "getting new spot target struct" );
		targets = array_removeDead( level.jungle_enemies );
		//target = getclosest( level.player.origin, targets  );
		target = random( targets );
		move_time = randomintrange( 2, 4 );
		self.target_ent moveto( target.origin, move_time, move_time* .5, move_time*.5 );
		self.target_ent waittill("movedone");
		hold_time = randomintrange( 2, 4 );
		wait( hold_time );
	}
	
}

jungle_apache_light_on()
{
	PlayFXOnTag( getfx( "heli_spotlight" ), self.mgturret[0], "tag_flash" );
}

jungle_apache_light_off()
{
	StopFXOnTag( getfx( "heli_spotlight" ), self.mgturret[0], "tag_flash" );
}



setup_intro_takedown()
{
	level endon("intro_takedown_aborted");
	//anim ent
	ent = getstruct( "intro_takedown", "targetname" );
	
	//enemies
	array_spawn_function_targetname( "intro_takedown_enemies", ::intro_takedown_enemy_getin_position );
	enemies = array_spawn_targetname( "intro_takedown_enemies", 1 );
	
	//friendly
	while(!isdefined( level.alpha1 ) )
		wait .25;
	
	friendly = level.alpha1;

	//player rig
	player_rig = spawn_anim_model( "player_rig" );
	player_rig attach( "viewmodel_commando_knife", "tag_knife_attach" );
	player_rig hide();

	ent.actors = [ friendly, player_rig ];
	ent.actors = array_combine( ent.actors, enemies );
	
	foreach( actor in ent.actors )
		actor.anim_ent = ent;
	
	//level.takedown_trig = getent( "intro_takedown_player_spot", "targetname" );
	level.takedown_trig = spawn_tag_origin();
	level.takedown_trig.origin = (-6872, -4040, -228);
	
	flag_wait("intro_takedown_ready");
	
	level.takedown_trig MakeUsable();	
	actionBind = maps\jungle_ghosts::getActionBind( "player_takedown" );
	level.takedown_trig SetHintString(  actionbind.hint );
	
	//idle anim
	level.takedown_trig waittill("trigger");
	
	flag_set( "intro_takedown_started" );	
	level.takedown_trig delete();
	
	level.player SetStance( "stand" );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player DisableWeapons();
		
	//show the player rig
	player_rig delayCall( 0.4, ::Show );
	
	//link player to rig
	level thread intro_takedown_player_link_logic( player_rig );
	ent anim_single_solo( player_rig, "intro_takedown" );
	flag_set( "intro_takedown_done" );

}



intro_takedown_player_link_logic( player_rig )
{
	level.player endon( "death" );

	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.4, 0.2, 0.2 );
	wait( 0.5 );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0 );
	time = 4;
	level.player LerpViewAngleClamp( time, time * 0.5, time * 0.5, 20, 20, 30, 10 );
	
	player_rig waittill("single anim");
	level.player unlink();
	player_rig delete();
	level.player EnableWeapons();
	level.player AllowCrouch( true );
	level.player AllowProne( true );

}

intro_takedown_friendly_getin_position()
{
	level endon( "intro_takedown_aborted");
	self thread intro_takedown_friendly_aborted_detection();
	self disable_ai_color();
	self.animname = "ai_friendly";
	
	while(!isdefined( self.anim_ent ) )
		wait.10;
	
	self.anim_ent anim_reach_solo( self, "intro_takedown_arrival" );
	self.anim_ent anim_single_solo( self, "intro_takedown_arrival" );
	self.anim_ent thread anim_loop_solo( self, "intro_takedown_idle" );
	
	flag_set("intro_takedown_ready");
	
	flag_wait("intro_takedown_started" );
	
	self.anim_ent notify("stop_loop");
	self.anim_ent anim_single_solo( self, "intro_takedown" );
	self.animname = "alpha1";
	self set_force_color("r");
	self enable_ai_color();

}

intro_takedown_friendly_aborted_detection()
{
	level endon("intro_takedown_started");
	
	flag_wait("intro_takedown_aborted");
	self stopanimscripted();
	flag_set("intro_takedown_done");
	self.animname = "alpha1";
	self set_force_color("r");
	self enable_ai_color();
}

intro_takedown_enemy_getin_position()
{
	self.animname = self.script_noteworthy;
	self [[level.ignore_on_func]]();
//	self.skipDeathAnim = undefined;
//	self.noragdoll = true;
	self.allowDeath = true;
	self.a.nodeath = true;
	self thread intro_takedown_enemy_early_damage_detection();
	
	//self endon("abort_takedown");
	self set_deathanim( "intro_takedown_death");
	self.ragdoll_immediate = true;
	
	while(!isdefined( self.anim_ent ) )
		wait.10;
	
	idle_org = GetStartOrigin( self.anim_ent.origin, self.anim_ent.angles, getanim( "intro_takedown" ) );
	idle_angles = GetStartAngles( self.anim_ent.origin, self.anim_ent.angles, getanim( "intro_takedown" ) );
	self.anchor = spawn( "script_origin", idle_org );
	self.anchor.angles = idle_angles;
	
	self ForceTeleport( self.anchor.origin, self.anchor.angles );
	self linkto( self.anchor );
	
	outcome = level flag_wait_any_return( "intro_takedown_started", "intro_takedown_aborted" );
	
	if( outcome == "intro_takedown_started" )
	{
		self.anim_ent anim_single_solo( self, "intro_takedown" );
	}
	else
	{
		if( isdefined( level.takedown_trig ))
			level.takedown_trig delete();	
		wait .10;
		if( isalive( self ) )
		{
			wait .25;
			level.alpha2 thread play_sound_on_entity( "weap_fnp90silenced_fire_npc" );
			wait .10;
			level.alpha2 thread play_sound_on_entity( "weap_fnp90silenced_fire_npc" );
			self clear_deathanim();
			self die();	
			wait .15;
			level.alpha2 thread play_sound_on_entity( "weap_fnp90silenced_fire_npc" );			
		}
		
	}

}

intro_takedown_enemy_early_damage_detection()
{
	self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName );
	
	if( !flag( "intro_takedown_started" ) )
	{	
		if(!flag( "intro_takedown_aborted" ) )
		{			
			flag_set("intro_takedown_aborted");
		}
		
		self clear_deathanim();
		self die();		
	}

}

test_window_pip()
{
	//self = tech_window hud_elem	
	level.pip = level.player NewPIP();
	level.pip.fov = 110;			
	level.pip.enableshadows = false;
	level.pip.x = 210;
	level.pip.y = 300;
	level.pip.width = 200;
	level.pip.height = 100;
	//level.pip.sort = 1;
	//level.pip.foreground = true;

	level.pip.visionsetthermal = "ac130";
	level.pip.visionsetnaked = "ac130";
	level.pip.activeVisionSet = "ac130"; //jungle_ghosts_thermal
	
	
	ent = spawn_tag_origin();
	spot = get_spot_in_front_of_player( 170 );
	ent.origin = spot + (0,0,130 );
	ent.angles = level.player.angles +( 90,0,0 );
	ent linkto( level.player );
	//ent LinkToPlayerView( level.player, "tag_origin", (0,0,55), (0,0,0), true );
	
	level.pip.freeCamera = true;
	level.pip.tag = "tag_origin"; 
	level.pip.entity = ent;	
	level.pip.enable = 1;
	
	guys = getaiarray("axis");
	foreach( guy in guys )
		guy ThermalDrawEnable();
		
}

jungle_player_pathing_brush_logic()
{
	trigger_wait_targetname( "jungle_entrance" );
	level.player_brush = getent( "player_brush", "targetname" );
	level.player_brush.angles = level.player.angles;
	//level.player_brush NotSolid();
	
	fwd = anglestoforward( level.player getplayerangles() );
	front = (fwd) * 185;
	level.player_brush.origin = level.player.origin + front;
	//level.player_brush linkto( level.player );
	level.player_brush ent_flag_init("stop_blocking_paths");
	/*
	while ( !flag( "waterfall_approach" ) )
	{
		if( level.player_brush ent_flag( "stop_blocking_paths" ) )
		{
			level.player_brush ent_flag_waitopen( "stop_blocking_paths" );
		}
		
		current_origin = level.player_brush.origin;	
		wait( 1 );		
		new_origin = level.player_brush.origin;
		
		x_diff = new_origin[0] -  current_origin[0];
		y_diff = new_origin[1] -  current_origin[1];
		
		if( abs( x_diff ) >= 70 || abs( y_diff ) >= 70 )
			level.player_brush DisconnectPaths();				
	}
	
	level.player_brush unlink();
	level.player_brush delete();
	*/
}


connect_dropdown_traverse()
{	
	brush = getent( "dropdown_disconnect", "targetname" );
	brush DisconnectPaths();
	
	flag_wait( "hill_pos_1" );
	brush.origin += ( 0, 0, 1000 );
	
	brush ConnectPaths();	
}
 

stand_player_up()	
{

	level.player allowcrouch(true);
	level.player allowprone(true);		
	level.player SetMoveSpeedScale(.40 );
	level.player DisableInvulnerability();
	
	//wait(1); 
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp"];//usp_no_knife_silencer m4_silencer_reflex  iw5_m4_sp_heartbeat_reflex_silencerunderbarrel  //usp_silencer
	
	wait 4;

	maps\jungle_ghosts_util::arm_player( guns ); //m240_heartbeat_reflex
	wait 1;
	//maps\jungle_ghosts_jungle::attach_motion_tracker();
	
	flag_set("slamzoom_finished");
	wait( 5 );
	flag_set( "intro_lines" );
	
	if( level.start_point == "jungle_corridor" )
		maps\_introscreen::introscreen( true );	
	
	wait 3;
	level thread player_spotted_logic();
	
}
//
//attach_motion_tracker()
//{
//	if( GetDvarInt( "mt_test" ) == 0 )
//		level.player AddOnToViewModel( "viewmodel_heartbeat_iw5", "J_Sleave_Reshape_Top_LE_1", (-3.1, 2.5, -.105), ( 113, 36,-48 ) );	
//}

player_spotted_logic()
{
	level endon("waterfall_approach");
	
	while( 1 )
	{
		level.player SetMoveSpeedScale(.75);
		SetSavedDvar( "player_sprintSpeedScale", 1.2 ); //default 1.5
		
		flag_wait( "_stealth_spotted" );
		
		//Price: Open fire!
		level.alpha1 do_story_line( "jungleg_gs1_openfire" );
		//Price: Grab some cover!
		level.alpha1 delayThread( 5, ::do_story_line, "jungleg_gs1_grabsomecover" );
		
		battlechatter_on();
		//array_thread( level.alpha, ::unset_forcegoal );
		array_thread( level.alpha, ::set_ai_bcvoice, "delta" );
		array_thread( level.alpha, ::disable_cqbwalk );
		array_call( level.alpha, ::AllowedStances, "stand", "crouch", "prone" ); //in case theyre set to crouch only
		
		level.player SetMoveSpeedScale( 0.90 );	
		SetSavedDvar( "player_sprintSpeedScale", 1.5 ); //default 1.5
		//music_play( "mx_jungle_break_stealth_lp" );
		
		//in case any ignoreme stuff is leftover friendlies
		//array_thread( level.alpha, ::global_ignore_off );
		
		flag_waitopen( "_stealth_spotted" );
		array_thread( level.alpha, ::set_ai_bcvoice, "seal" );
		//player is close to top of hill, dont turn stealth back on
		if(!flag( "hill_pos_4" ) )
		{
			battlechatter_off();	
			thread music_stop( 4 );
			level thread  attack_with_player();
			//array_thread( level.alpha, ::cqb_when_player_sees_me );
		}
	}
		
}

inform_player_when_section1_is_clear()
{
	level endon("hill_pos_1");//when we exit the first section and into the hill area
	
	while(!isdefined( level.jungle_enemies ) )
		wait 1;
	
	//if we clear all the baddies
	while( level.jungle_enemies.size > 0 )
	{
		level.jungle_enemies = remove_dead_from_array( level.jungle_enemies );
		wait( 2 );
	}
	//if were still in section 1, say the line
	if(!flag("hill_pos_1") )
	{
		flag_set( "jungle_section1_clear" );
		//Ghost 1: Look's like it's clear. Let's keep moving to the crash site. North West. 
		level.alpha1 smart_radio_dialogue( "jungleg_gs1_lookslikeitsclear" );
	}
	
}
	
	
	
static_til_flag( _flag )
{
	hud = NewHudElem();
	hud.hidewheninmenu = false;
	hud.hidewhendead = true;
	hud SetShader( "overlay_static", 640, 480 ); 
	hud.alignX = "left";
	hud.alignY = "top";
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha =1 ;
	hud.sort = 1;
	
	flag_wait( _flag );
	wait(.5);
	hud FadeOverTime( 1 );
	hud.alpha = 0;
	hud destroy();
}

ToD_Change()
{
	flag_wait( "hill_pos_1");
	
	wait(25);
	trans_time = 120;
	level.player vision_set_changes( "jungle_dawn_halfway", trans_time );
	//IPrintLn("Sunrise: Begin transitioning to halfway over " +trans_time+ " seconds");
	wait( trans_time );
	trans_time *= .5;
	//IPrintLn("Sunrise: Halfway complete: Transitioning to full over "+trans_time+" seconds");
	//level.player vision_set_changes( "jungle_dawn", trans_time );
	wait( trans_time );
	//IPrintLn( "Sunrise Complete" );
}

#using_animtree("generic_human" );
setup_friendlies()
{	
	battlechatter_off();
	thread jungle_vo();
	//UAV SETUP 
	
	array_spawn_function_targetname( "alpha_team", ::jungle_friendly_logic );
	level.alpha = array_spawn_targetname( "alpha_team", 1 );

	left_jump = getent( "left_jump", "targetname" );
	right_node = getnode( "right_guy", "targetname" );
	
	foreach( guy in level.alpha )
	{
		if( guy.script_friendname == "Elias" ) 
		{
			level.alpha1 = guy;		
			level.alpha1.animname = "alpha1";		
			level.alpha1 forceUseWeapon( "honeybadger", "primary" );
			//level.alpha1.npcID = "pri";
			_node = getnode("keegan_wait", "targetname");
			level.alpha1.goalradius = 32;
			level.alpha1 ForceTeleport( _node.origin, _node.angles );
			level.alpha1 SetGoalNode( _node );			
		}
		else
		{
			level.alpha2 = guy;
			level.alpha2.animname = "alpha2";
			if( level.start_point != "jungle_corridor" &&  level.start_point != "e3")
				left_jump thread anim_first_frame_solo( level.alpha2, "intro_jumpdown" );
			
			//level.alpha2 forceUseWeapon( "sc2010+silencer_sp", "primary" );
			level.alpha2 forceUseWeapon( "honeybadger", "primary" );
		}
	}
	
	friendlyfire_warnings_off();
	flag_set( "friendlies_ready" );
	
	//UAV DONE, PLAYER ON GROUND	
	if (level.start_point != "e3")
		flag_wait("slamzoom_finished");
	
	level.alpha1.animname = "generic";
	//level.alpha1 set_run_anim("patrol_walk_creepwalk");
	
	flag_wait("player_landed");
	level.alpha1.animname = "alpha1";
	
	if( level.start_point != "jungle_corridor" && level.start_point != "e3")
	{
		left_jump anim_reach_solo( level.alpha1, "intro_jumpdown" );	
		
		flag_set("jump_start");
		
		left_jump thread anim_single( level.alpha, "intro_jumpdown" );
		wait(.10);
		//array_thread( level.alpha, ::anim_self_set_time, "intro_jumpdown", .15);
		array_thread( level.alpha, ::set_goalradius, 32 );
		
		node = getnode("alpha1", "targetname");
		level.alpha1 setgoalnode( node );
		
		node = getnode("alpha2", "targetname");
		level.alpha2 setgoalnode( node );
		level.alpha1 clear_run_anim();
		
		level.alpha1 waittillmatch( "single anim", "end" );		
	}
	
	flag_set( "jumped_down" );	
	
	//wait for player to reach corridor end
	flag_wait("jungle_entrance");
	
	//flag_wait("intro_takedown_done");
	assign_archetypes();
	level thread friendly_navigation();
	level thread attack_with_player();
	array_thread( level.alpha, ::cqb_when_player_sees_me );

	//top of waterfall!
	flag_wait("waterfall_approach");
	thread delete_bloomdome();
	thread waterfall_execution();
	
	level.player thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");
	music_stop( 5 );
}

delete_bloomdome()
{
	bloomdome = getent("bloomdome", "targetname" );
	if( IsDefined( bloomdome ) )
		bloomdome delete();		
}

uav_player_setup()
{
	uav_player = spawn_script_noteworthy("player", 1 );
	uav_player thread generic_ignore_on();
	delayThread( 5, maps\jungle_ghosts_uav::target_ent, uav_player, "ac130_hud_diamond" );	
	
	flag_wait("slamzoom_finished");	
	//uav_player stop_magic_bullet_shield();
	uav_player delete();	
}

smaw_guy_setup()
{
	level.smaw_guy = self;
	self.fake_smaw = spawn( "script_model", self gettagorigin( "tag_stowed_back") - (0, 0, 10 ) );
	self.fake_smaw.angles = self gettagangles( "tag_stowed_back" );
	self.fake_smaw linkto( self, "tag_stowed_back" );
	self.fake_smaw setmodel( "weapon_smaw" );	
}

setup_jungle_enemies()
{
	SetSavedDvar( "laserradius", .4 );
	array_spawn_function_targetname( "jungle_patroller", ::jungle_enemy_logic, "zero", 1 );
	array_spawn_function_targetname( "lookout_guys", ::lookout_guys_logic );
	array_spawn_function_targetname( "right_meeting_guys", ::right_meeting_guys_logic );
	array_spawn_function_targetname( "left_meeting_guys", ::left_meeting_guys_logic );
	
	level.jungle_enemies = array_spawn_targetname( "jungle_patroller", 1 );	
	
	lookout_guys = array_spawn_targetname( "lookout_guys", 1 );
	waittillframeend;
	level.jungle_enemies = array_combine( level.jungle_enemies, lookout_guys );
	
	level.right_meeting_guys = array_spawn_targetname( "right_meeting_guys", 1 );
	level.left_meeting_guys = array_spawn_targetname( "left_meeting_guys", 1 );
	level.meeting_guys = array_combine( level.right_meeting_guys, level.left_meeting_guys );
	waittillframeend;
	level.jungle_enemies = array_combine( level.jungle_enemies, level.meeting_guys );
	level thread meeting_guys_vo( level.left_meeting_guys );
	level thread meeting_guys_vo( level.right_meeting_guys );
	
	thread setup_hill_enemies();

}


setup_hill_enemies()
{
	array_spawn_function_targetname( "hill_patrollers", ::hill_enemy_stealth_logic );
	array_spawn_function_targetname( "hill_patrollers", ::hill_enemy_on_spotted );
	//array_spawn_function_targetname( "hill_hot_enemies", ::jungle_enemy_logic, "zero" );
	array_spawn_function_targetname( "plane_meeting_guys", ::plane_meeting_guys_logic );
	thread hill_chopper();
		
	flag_wait("hill_pos_1");
	
	autosave_by_name( "hill_start" );
	
	//if we arrive at the hill HOT only spawn 3 dudes + re-enforcements later
	if( flag( "_stealth_spotted" ) )
	{
		/*
		spawners = getentarray("hill_patrollers", "targetname" );
		level.hill_patrollers = [];
		
		for( i=0; i<3; i++)			
		{
			level.hill_patrollers[i] = spawners[i] spawn_ai( true );			
		}
		*/
		level.hill_patrollers = array_spawn_targetname( "hill_patrollers", 1 );
		thread spawn_hill_enemies_hot();
		level thread handle_enemies_behind_player();
		level thread hill_reenforcements();
	}
	//if still stealth spawn the cqb patrollers
	else
	{	
		level.hill_patrollers = array_spawn_targetname( "hill_patrollers", 1 );
		guys = array_spawn_targetname("plane_meeting_guys", 1);
		level.hill_patrollers = array_combine( guys, level.hill_patrollers );
		level thread handle_enemies_behind_player();
		level thread hill_reenforcements();
	}
		
	//wait for enemies to get clear when we're up the hill
	flag_wait( "hill_pos_4" );	
	wait( 2 );
	while( level.hill_patrollers.size  != 0 )
	{
		level.hill_patrollers = array_removeDead( level.hill_patrollers );
		wait(2);
	}
	
	flag_set( "hill_clear" );
}

hill_chopper()
{

	
	array_spawn_function_targetname("heli_guys", ::heli_guys_logic );
	hill_heli = spawn_vehicle_from_targetname( "hill_heli" );
	hill_heli Vehicle_TurnEngineOff();

	hill_heli endon ("death");
	
	flag_wait("hill_pos_1");
	hill_heli Vehicle_TurnEngineOn();
	
	flag_wait_any( "crash_arrive", "_stealth_spotted" );

	hill_heli gopath();
	wait 10;
	hill_heli Vehicle_SetSpeedImmediate( 40, 10 );
	
}


heli_guys_logic()
{
	self.ignoreme = 1;
	self.ignoreall = 1;
}

plane_meeting_guys_logic()
{
	self thread jungle_enemy_logic( "zero", 1 );	
	node = getstruct( "plane_meeting", "targetname" );	
	self thread meeting_animation( node );			
}

uav_trig_setup()
{	
	self.trig = spawn( "trigger_radius", self.origin, 0, 256, 256 );
	wait(.05);
	self thread trig_move_with_me();
	self.trig.ai = self;
	level.enemy_trigs = add_to_array( level.enemy_trigs, self.trig );
}


trig_move_with_me()
{	
	level endon("slamzoom_start");
	self endon("tagged");
	self endon("death");
	while( isdefined( self ) )		
	{
		self.trig.origin = self.origin;
		wait(.5);
	}	
}

spawn_hill_enemies_hot()
{
	volume = GetEnt( "hill_main_volume", "targetname" );
	hill_main_volume = getent( "hill_main_volume", "targetname" );
	level.hill_patrollers = array_removeUndefined( level.hill_patrollers );
	
	spawners = GetEntArray( "hill_hot_enemies", "targetname");
	
	level.hill_holders = [];
	level.hill_squad  = [];
	level.hill_squad = maps\jungle_ghosts_util::create_a_squad_from_spawner( spawners[0] , level.hill_squad, 5  );
	level thread maps\jungle_ghosts_util::squad_manager( level.hill_squad  );
	
	wait( 5 );
	
	level.hill_holders = maps\jungle_ghosts_util::spawn_ai_from_spawner_send_to_volume( spawners[1], 5, hill_main_volume );		
	level.hill_patrollers = array_combine( level.hill_holders, level.hill_squad );	
}

handle_enemies_behind_player()
{
	level endon("waterfall_approach");
	flag_wait( "hill_pos_1" );
	
	//If we're already hot from the 1st section, do nothing. 
	if( flag( "_stealth_spotted" ) )
		return;
	
	//wait for fight to go hot. 
	flag_wait( "_stealth_spotted" );

	close_guys = undefined;
	
	if( isdefined( level.jungle_enemies ) )
	{
		//if the player is far up the hill just delete the guys on the first section
		if( flag( "hill_pos_4" ) )
		{
		   	array_thread( level.jungle_enemies, maps\jungle_ghosts_util::delete_if_player_cant_see_me );
		}
		
		//Delete enemies from the first section and leave 2. Send them to the player.
		else
		{
			level.jungle_enemies = array_removeDead_or_dying( level.jungle_enemies );
			if( level.jungle_enemies.size > 2 )
			{
				close_guys = get_array_of_closest( level.player.origin, level.jungle_enemies );
				
				for( i = 2; i < close_guys.size; i ++ )
				{
					close_guys[i] maps\jungle_ghosts_util::delete_if_player_cant_see_me();
				}
				
				close_guys = array_removeUndefined( close_guys );	
				//IPrintLn( close_guys.size+ " enemies flanking" );			
			}
			
			else if( level.jungle_enemies.size != 0 )
			{
				close_guys = level.jungle_enemies;
				//IPrintLn( close_guys.size+ " enemies flanking" );
			}
			
			if( IsDefined( close_guys ) )
			{
				foreach ( guy  in close_guys )
				{
					guy enable_sprint();		
					ent = level.player;				
					guy SetGoalEntity( ent );
					//guy set_forcegoal();
					guy thread set_flag_when_close( ent );
				}
			}
		}
					
	}
	
}

set_flag_when_close( ent )
{
	self endon( "death" );
	level endon( "hill_flanked" );
	
	while(1)
	{
		dist = DistanceSquared( self.origin, ent.origin );
		if( dist <= 450*450 )
		{			
			//IPrintLn( "Hill getting flanked!");
			flag_set( "hill_flanked" );
			IPrintLnBold( "enemies flanking!" );
			return;
		}
		wait(.5);
	}
}

hill_reenforcements()
{
	level.spawned_reenforcements = 0;
	
	flag_wait( "hill_pos_4" );
	send_hill_reenforcements_if_hot();
	
	flag_wait( "hill_pos_5" );	
	
	if( level.spawned_reenforcements == 0 )
		send_hill_reenforcements_if_hot();			
}


send_hill_reenforcements_if_hot()
{
	if( flag( "_stealth_spotted" ) )
	{
		//IPrintLn( "spawning re-enforcements" );
		level.spawned_reenforcements = 1;
		volume = getent( "hilltop_volume_1", "targetname" );
		spawner = getent( "hill_backup_left", "targetname" );
		backup_guys1 = maps\jungle_ghosts_util::spawn_ai_from_spawner_send_to_volume( spawner, 4, volume );
		level.hill_patrollers = array_combine( level.hill_patrollers, backup_guys1 );

		wait 5;
	
		if ( player_is_surrounded() )
			//Price: Targets front and behind!
			level.alpha1 do_story_line( "jungleg_pri_targetsfrontandbehind" );
	}
}

jungle_stealth_custom_warning_func( type )
{
	if( !level.player player_can_see_ai( self ) )
	{
		//IPrintLn( "player cannot see enemy. Reseting to normal stealth" );
		//self maps\_stealth_threat_enemy::enemy_alert_level_change( "reset" );
		self maps\_stealth_threat_enemy::enemy_alert_level_normal_wrapper();
	}
	else
	{
		self maps\_stealth_threat_enemy::enemy_alert_level_warning1();
	}	
}

jungle_stealth_custom_attack_func( type )
{
	if( !level.player player_can_see_ai( self ) )
	{
		//IPrintLn( "player cannot see enemy. Reseting to normal stealth" );
		//self maps\_stealth_threat_enemy::enemy_alert_level_change( "reset" );
		self maps\_stealth_threat_enemy::enemy_alert_level_normal_wrapper();
	}
//	else if( DistanceSquared( self.origin, level.player.origin ) > 100*100 ) 
//	{
//		 self maps\_stealth_threat_enemy::enemy_alert_level_normal_wrapper();
//	}
	 else  		
	{
		self maps\_stealth_threat_enemy::enemy_alert_level_warning1();
	}	
}

jungle_enemy_logic( nade_ammo, stealth )
{
	self thread friendly_kill_vo();
	self endon("death");

	self set_moveplaybackrate(.7 );

	if( isdefined( self.target ) )
		self thread maps\_patrol::patrol();
	
	self disable_long_death();
	self.dieQuietly = true;
	self.no_pain_sound = true;
	self.skipBloodPool = true;

	self thread friendly_spotted_logic();
	self thread player_spotted_count();
	self thread jungle_enemy_sfx();
	self thread enemy_becomes_target_if_spotting_player();
	
	self set_ai_bcvoice( "shadowcompany" ); //shadowcompany = Spanish
	self ent_flag_init("stealth_kill");
	
	custom_array = [];
	
	custom_array[ "warning1" ] = ::jungle_stealth_custom_attack_func;
	custom_array[ "warning2" ] = ::jungle_stealth_custom_attack_func;
	
	self thread maps\_patrol_anims_creepwalk::enable_creepwalk(); 
	
	self stealth_threat_behavior_replace( custom_array );

	
	if( IsDefined( nade_ammo ) )
	{
		if( nade_ammo == "zero" )// passing in the int of 0 just becomes undefined so...
		{
			self.grenadeammo = 0;
		}
		else
		{
			self.grenadeammo = nade_ammo;
		}
	}
	
	if(isdefined( stealth ) )
	{
		self.stealth_blockers = 0;
		self._stealth.logic.alert_level.min_bulletwhizby_altert_dist  = 500;
		self stealth_pre_spotted_function_custom( ::jungle_prespotted_func );
	}
	
}

jungle_enemy_sfx()
{
	self endon( "death" );
	close_enough = 1000*1000;
	
	while(!IsDefined( level.meeting_guys ) )
		wait .10;
	
	if( is_in_array( level.meeting_guys, self ) )
		return;

	//Federation Radio Voice: Salvage team ETA to crash site: 45 minutes. 
	//Federation Radio Voice: Looks like ..uhh..zero survivors so far - several teams still en route over. 
	//Federation Radio Voice: Maintain sweep pattern….possible chutes dropped within a 3 mile radius
	//Federation Radio Voice: Stand by for rules of engagement.  Mother is awaiting confirmation from <garbled>
	//Federation Radio Voice: Team 2 reporting zero contact. Maintaining sweep pattern over. 
	//Federation Radio Voice: Team 3 has recovered two survivors and are proceediong to the LZ for interigation over.
	//Federation Radio Voice: Primary Target recovered - all teams shoot to kill.  Use of lethal force is authorized.  
	walla_sounds = [ "jungleg_safr_salvageteametato", "jungleg_safr_lookslikeuhhzerosurvivors", "jungleg_safr_maintainsweepchutes", "jungleg_safr_standbyforrules", "jungleg_safr_team2reportingzero", "jungleg_safr_team3hasrecovered", "jungleg_safr_primarytargetrecoveredall" ];
	walla_sounds = array_randomize( walla_sounds );
	i = 0;

	while( 1 )
	{
		dist = DistanceSquared( self.origin, level.player.origin );	
		if( dist <= close_enough )
		{
			//bush rustling
			if( self is_moving() )
				self play_foilage_sound_custom();
			
			sound = walla_sounds[i];
			
			self  play_sound_on_tag( sound, undefined, true );//TODO investigate endon death not working?
			i++;
			
			if(i > walla_sounds.size -1 )
				i = 0;
			
			wait( randomintrange( 5, 8 ) );
		}
		wait 2;
	}
}

play_foilage_sound_custom()
{
	self thread play_sound_on_tag( "scn_tree_snap", undefined, true );
	wait(.10);
	self  thread play_sound_on_tag( "scn_bush_movement", undefined, true );
	wait(.25);
	self thread play_sound_on_tag( "scn_tree_snap", undefined, true );
}

lookout_guys_logic()
{	
	self thread jungle_enemy_logic( "zero", 1 );
	trigger_wait_targetname( "jungle_entrance" );		
	self thread lookout_animation();		
}

right_meeting_guys_logic()
{	
	self thread jungle_enemy_logic( "zero", 1 );	
	node = getstruct( "right_meeting", "targetname" );
	self thread meeting_animation( node, "meeting_trig" );			
}

left_meeting_guys_logic()
{
	
	self thread jungle_enemy_logic( "zero", 1 );	
	node = getstruct( "left_meeting", "targetname" );	
	self thread meeting_animation( node, undefined );			
}

meeting_animation( node, the_trig  )
{
	self endon( "death" );
	//self endon("stop_idle_proc");
	//level endon("_stealth_spotted");
	//self.og_animname = self.animname;
	//self.animname = self.script_noteworthy;
	
	//node thread anim_loop_solo(self, "meeting_idle", "stop_idle" );
	idle_anim = undefined;
	
	switch( self.script_noteworthy )
	{
		case "guy1":
			idle_anim = "meeting_idle1";
			break;
		
		case "guy2":
			idle_anim = "meeting_idle2";
			break;	
	
		case "guy3":
			idle_anim = "meeting_idle3";
			break;			
	}
						
	node thread maps\jungle_ghosts_util::stealth_ai_idle( self, idle_anim, undefined, undefined );
	
	if( isdefined( the_trig ) )
	{
		self thread stealth_anim_interupt_detection( "meeting" );	
		self endon( "abort_meeting" );
		trigger_wait_targetname( the_trig );		
		self notify( "stop_meeting_vo" );
		node notify( "stop_loop" );
		self.animname = self.script_noteworthy;
		node anim_single_solo( self, "meeting" );
		self notify( "meeting" );
		self.animname = self.og_animname;	
		//self.patrol_walk_anim = "active_patrolwalk_gundown";
		self thread maps\_patrol::patrol();
	}
	else
	{
		//these guys would not pursue the player for some reason, so:
		flag_wait( "_stealth_spotted" );
		wait randomintrange( 1, 3 );
		self  disable_stealth_for_ai();
		self.goalradius = 250;
		self SetGoalEntity( level.player );		
	}	
}


meeting_guys_vo( meeting_guys )
{
	level endon( "_stealth_spotted" );
		
	//Federation Soldier 1: HQ is reporting survivors have already been recovered. 
	//Federation Soldier 2: How many?
	//Federation Soldier 1: Two so far. They're already at the extraction point. 
	//Federation Soldier 2: Vasquez said he saw some PMC's in zone 3.  What the hell was in that plane?
	//Federation Soldier 1: Conflicting reports.  From the sounds of it no one's going anywhere until we find these guys. 
	convo1 = [ "jungleg_saf1_hqisreportingsurvivors", "jungleg_saf2_howmany", "jungleg_saf1_twosofartheyre", "jungleg_saf2_vasquezsaidhesaw", "jungleg_saf1_conflictingreportsfromthe" ];
	
	//Federation Soldier 3: Team 2 is coverng the east corner and team 3 the west corner. No one's getting through here without being seen. 
	//Federation Soldier 4: I don't understand. Who was on that plane?
	//Federation Soldier 3: It's who wasn't on the plane.  Just have your men sweep their sectors and report if they find anything immediately. 
	//Federation Soldier 4: Copy that - they're already on it.  We're going to be here all day. 
	//Federation Soldier 3: We're going to be here as long as it takes.  I don’t care if you have to search the crash site yourself. 
	convo2 = [ "jungleg_saf3_team2iscoverng", "jungleg_saf4_idontunderstandwho", "jungleg_saf3_itswhowasnton", "jungleg_saf4_copythattheyrealready", "jungleg_saf3_weregoingtobe" ];
	
	//Federation Soldier 1: No. I'm saying he was in the plane, and they got him out. 
	//Federation Soldier 4: How do you even attempt to - 
	//Federation Soldier 1: It doesn’t matter. What matters is finding the rest of the crew in this wreckage. Dead or alive. 
	//Federation Soldier 4: We're gonna need more men. 
	//Federation Soldier 2: Less complaining. More combing through the wreckage. 
	//Federation Soldier 4: My team's on it.  Besides, no one survived this. Parachute or no parachute. 
	convo3 = [ "jungleg_saf1_noimsayinghe", "jungleg_saf4_howdoyoueven", "jungleg_saf1_itdoesntmatterwhat", "jungleg_saf4_weregonnaneedmore", "jungleg_saf2_lesscomplainingmore", "jungleg_saf4_myteamsonit" ];
	
	convos = [ convo1, convo2, convo3 ];
	
	foreach( guy in meeting_guys )
		guy endon( "stop_meeting_vo" );
	
	while(1)
	{
		foreach( i, convo in convos )
		{
			foreach( line in convo )
			{
				guy = random( meeting_guys );
				
				if(!isdefined_and_alive( guy ) )
				   return;
				else
					guy play_sound_on_tag( line, undefined, true );
			}
		}		
		wait 5;
	}

}

lookout_animation()
{
	//self stopanimscripted();
	self.og_animname = self.animname;
	self.animname = self.script_noteworthy;
	self thread stealth_anim_interupt_detection( "helpup_lookout" );
	node = getstruct( "lookout_scene", "targetname" );
	node thread anim_single_solo( self, "helpup_lookout" );
	wait(.05);
	self setanimtime( getanim("helpup_lookout"), .7 );	
	self.animname = self.og_animname;
	self notify_delay( "helpup_lookout", 5 );	
	self.patrol_walk_anim = "active_patrolwalk_gundown";
	self thread maps\_patrol::patrol();
}

stealth_anim_interupt_detection( _endon )
{
	self endon( _endon );
	self thread stealth_enemy_endon_alert();
	self waittill_any( "enemy_stealth_reaction", "damage", "stealth_enemy_endon_alert", "enemy_awareness_reaction", "bulletwhizby" );
	self stopanimscripted();	
	
	my_group = self get_my_meeting_group();
	if( isdefined( my_group ) )
	{
		my_group = array_removeDead_or_dying( my_group );
		array_notify( my_group, "abort_meeting" );
	}

}

get_my_meeting_group()
{
	if( is_in_array( level.left_meeting_guys, self ) )
		return level.left_meeting_guys;
	
	else if( is_in_array( level.right_meeting_guys, self ) )
		return level.right_meeting_guys;
	
	else
		return undefined;	
}

hill_enemy_stealth_logic()
{
	self endon ("death" );
	self disable_long_death();
	self thread player_spotted_count();
	self thread friendly_spotted_logic();
	self thread friendly_kill_vo();
	
	self stealth_pre_spotted_function_custom( ::jungle_prespotted_func );	
	self set_ai_bcvoice( "shadowcompany" ); //shadowcompany = Spanish
	self thread maps\_patrol_anims_creepwalk::enable_creepwalk(); 
	self forceuseweapon( "sc2010+silencer_sp", "primary" );
	self.grenadeammo = 0;
//	if( !isdefined( self.script_noteworthy ) )
//	{
//		self enable_cqbwalk();
//	}
	if( isdefined ( self.script_noteworthy ) && self.script_noteworthy == "cliff_looker" )
	{			
		self thread cliff_guy_logic();
		return;
	}
	
	level endon( "_stealth_spotted" );	//cliff guy doesnt get the endon
	//self set_moveplaybackrate( RandomFloatRange( .4, .8 ) );	
	self LaserForceOn();	
	
	//player is at top of hill. These guys go around a corner and delete
	flag_wait("waterfall_approach");
	//self disable_cqbwalk();
	self set_moveplaybackrate( 1 );	
	wait( 3 );
	if( cointoss() )
		self enable_sprint();
	self waittill("goal");
	self delete();		
}

cliff_guy_logic()
{
	self endon( "death" );
	self.animname = "generic";
	//self thread stealth_anim_interupt_detection( "waterfall_approach" );
	
	node = getstruct( self.target, "targetname" );
	self ForceTeleport( node.origin, node.angles );
	node stealth_ai_idle_and_react( self, "cliff_look", "cliff_look_react" );
}

stop_anim_on_stealth_spotted()
{
	self endon( "death" );
	flag_wait("_stealth_spotted");
	self StopAnimScripted();	
}


anim_single_solo_gravity( guy, anime, tag )
{
	pain = guy.allowPain;
	guy disable_pain();// anim_custom allows for pain - since 99% of the time this is unwanted behavior - we turn off pain before doing the anim.
	
	self anim_single_solo_custom_animmode( guy, "gravity", anime, tag );
	
	if( pain )
		guy enable_pain();
}

anim_single_solo_custom_animmode( guy, custom_animmode, anime, tag, thread_func )
{
	array = get_anim_position( tag );
	org = array[ "origin" ];
	angles = array[ "angles" ];

	thread anim_custom_animmode_on_guy( guy, custom_animmode, anime, org, angles, self.animname, false, thread_func );
	guy wait_until_anim_finishes( anime );
	self notify( anime );
}

hill_enemy_on_spotted()
{
	self endon("death");
	flag_wait( "_stealth_spotted");
	self disable_cqbwalk();
	self StopAnimScripted();
	self set_moveplaybackrate( 1 );	
}

jungle_prespotted_func()
{
	/*
	if(isdefined( self._stealth.logic.event.awareness_param["bulletwhizby"] ) )
	{
		// _stealth_spotted gets set right after this so if this is just a whizby and player is far away hold here forever.
		if( self._stealth.logic.event.awareness_param["bulletwhizby"] == level.player &&  DistanceSquared( self.origin, level.player.origin ) > 400*400 )			
		{
			self.stealth_blockers++;
			IPrintLn( "Enemy far from player revieved whizby. Ignoring. " +self.stealth_blockers+"x" );
			self waittill( "forever" );	
		}
	}
	*/
	//default stealth wait time before _Stealth_spotted is 2.25
	wait( level.stealth_spotted_time );
}

stealth_hard_reset()
{
	self.ignoreme = 1;
	self.ignoreall = 1;
	disable_stealth_for_ai();
	wait(1);
	enable_stealth_for_ai();
	self.ignoreme = 0;
	self.ignoreall = 0;
}

knife_victim_death_func()
{
	//self StopAnimScripted();
	self StartRagdoll();
}

jungle_friendly_logic()
{
	if( isdefined( self.script_noteworthy ) )
	 	if(  self.script_noteworthy == "player" )
	 	{
	 		self thread generic_ignore_on();
	 		return;
	 	}
	self.disableplayeradsloscheck = true;
	//self set_friendlyfire_warnings( false );
	self ent_flag_init( "stealth_kill" );
	self ent_flag_init( "override_follow_logic" );
	self.grenadeammo = 0;
	self thread magic_bullet_shield( 1 );
	self thread maps\_stealth_utility::stealth_default();
	self.maxsightdistsqrd = 900 * 900;
	self set_ai_bcvoice( "seal" );
	self.npcID = 0;	
	self disable_surprise();

	//self thread friendly_goes_hot_logic();	
}

assign_archetypes()
{

//	anim.archetypes[ "soldier_jungle" ][ "default_crouch" ][ "exposed_idle" ] = [ %exposed_crouch_lookaround_1, %exposed_crouch_lookaround_2, %exposed_crouch_lookaround_3, %exposed_crouch_lookaround_4 ];	
	foreach( guy in level.alpha )	
		guy.animArchetype = "jungle_soldier";
	
}
friendly_spotted_logic()
{
	//enemies spot friendly only when player can see the enemy and friendly is within range
	//self = ENEMY AI
	flag_wait( "jungle_entrance" );	
	//level endon( "_stealth_spotted" );		
	level endon( "waterfall_approach" );
	friendly_spotted_dist = 550 * 550;
	visible_friendly = undefined;
	enemies_near_me = [];
	
	player_attacks_time = undefined;
	skill = getdifficulty();
	switch( skill )
	{
		case "gimp":
		case "easy":
			player_attacks_time = .5;
		case "medium":
			player_attacks_time = 1.5;
		case "hard":
		case "difficult":
		case "fu":
			player_attacks_time = 2;
	}
	
	while( IsAlive( self ) )
	{	
		visible_friendly = self visible_enemy_can_see_either_visible_friendly( friendly_spotted_dist );
		if(isdefined( visible_friendly ) && !isdefined( self.jungle_melee) )
		{
			visible_friendly notify("friendly_spotted");
			//self thread maps\jungle_ghosts_util::print3d_on_me("I see a friendly!");
			spot = self.origin; //get his origiin before he dies
			
			//the spotted friendly attacks the enemy who saw him
			friendlies_attack_enemy_array( [ self ], [visible_friendly] );
			
			//give player a chance to engage nearby enemies
			wait( player_attacks_time );
			
			//get closeby enemies
			axis = getaiarray("axis");
			enemies_near_me = get_array_of_closest( spot, axis, [self], undefined, 450, 0 );
					
			//remaining friendly takes out close enemies
			if( enemies_near_me.size !=0 )
			{	
				remaining_squad_clears_close_enemies( enemies_near_me, visible_friendly, level.alpha );
			}
			
			return;
		}
		wait(1);		
	}

}

visible_enemy_can_see_either_visible_friendly( threshhold )
{
	//checks if enemy can see a friendly and returns the friendly if so
	self endon( "death");
	foreach( guy in level.alpha )
	{	
		if (isdefined(guy))
		{
			dist = DistanceSquared( self.origin, guy.origin );
			if( dist <= threshhold && ( player_can_see_ai( self ) && player_can_see_ai( guy ) && self cansee( guy ) ) )
			return guy;
		}
	}
	
	return undefined;	
}

bravo_friendly_logic()
{
	self.ignoreall = 1;
	self.ignoreme = 1;	
	self.goalradius = 32;
	self.disableplayeradsloscheck = true;
	self thread magic_bullet_shield( true );
	//self set_friendlyfire_warnings( false );
	
	if( self.script_friendname == "Merrick" )
		level.baker = self;
	else
		level.diaz = self;
	
	//self gun_remove();
}

setup_smaw_guy()
{
	guys = getaiarray( "allies" );	
	foreach( guy in guys )
	{
		if( guy.classname == "actor_iw5_ally_delta_woodland_m4sd_smaw" )
		{
			guy thread smaw_guy_setup();
		}
	}	
}

friendly_goes_hot_logic()
{
	//self = friendly
	flag_wait( "_stealth_spotted" );
	//self disable_stealth_for_ai();
	
	self unset_forcegoal();
	self set_baseaccuracy( .6 );
	self AllowedStances( "stand", "crouch", "prone" );
	self disable_cqbwalk();
	wait(.15 );

	
}

FAR_FROM_GOAL = 400;//150
follow_player()
{	
	self endon( "stop_following_player" );
	self.fixednode 	= false; //Wont use cover nodes otherwise
	self.goalradius = FAR_FROM_GOAL; 
	self.fixedNodeSafeRadius = FAR_FROM_GOAL; 
	//self.pathenemyfightdist = 300;
	self.interval = 100;
	//self.ignoreSuppression = 1;
	leap_frog = 0;
	
	//setup the target ent that is linked to the player.
	angles = level.player getplayerangles();
	angles = ( 0, angles[1], 0 );
	fwd = anglestoforward( angles );
	_right = anglestoright( angles );
	front = (fwd) * 120; //200, 240
	if( level.alpha1 == self )
	{
		right = (_right) * 110;	// 90 right of player
	}
	else
	{
		right = (_right) * -110;	//90 left of player
	}
	
	//in_front_of_player = level.player geteye() + front +( 0, 0, 250 );
	in_front_of_player = level.player.origin + front +( 0, 0, 250 );
	right_and_front =  in_front_of_player + right;
	self.target_ent = spawn("script_origin",  right_and_front );
	self.target_ent.angles = ( 0, angles[1], 0 );
	self.target_ent linkto( level.player );
	
	if( self == level.alpha[1] )
		self.target_ent = level.player;
	
	while( 1 )
	{
		if( self ent_flag( "override_follow_logic" ) )
		{
			wait(.10);
			continue;
		}
		ground_pos = groundpos( self.target_ent.origin);
		dist = distance2d( self.origin, ground_pos );
		
		if( dist >  FAR_FROM_GOAL  &&!maps\jungle_ghosts_util::origin_is_below_player( ground_pos))
		{			
			//check for melee possibility
//			potentially_close_enemy = maps\jungle_ghosts_util::ent_is_close_to_enemy( groundpos( self.target_ent.origin ));
//			if( isdefined( potentially_close_enemy ) && !isdefined( potentially_close_enemy.jungle_melee )  && !flag("_stealth_spotted") )
//			{
//				potentially_close_enemy.jungle_melee = 1;
//				self try_jungle_melee( potentially_close_enemy );				
//			}
//			
//			//go to goal position in front of player			
//			else
//			{
				self notify( "moving_up");
				self AllowedStances( "stand", "crouch", "prone" );
				//self.fixednode 	= false; 
				self setgoalpos( ground_pos );	
				//self setgoalpos( level.player.origin );
			//}
			
			timeout =  5;
			PC_Timeout = 2;
			
			//if we reach our goal and have no node, then crouch
			self  thread crouch_at_goal();
					
			//wait for the player to move ahead or timeout
			////TODO make this work on pc too =(
			if( level.Console )
			{			
				decision = waittill_player_moves_or_timeout_controller( timeout );
				//IPrintLn( decision );
			}
			else		
			{
				//wait( PC_Timeout );
				decision = waittill_player_moves_or_timeout_kb( timeout );
			}			
		}
		wait(.15 );
	}		
}

sneaky_trig_logic()
{
//	level endon("_stealth_spotted" );
//	level endon( "waterfall_approach" );
	set_custom_color_logic = 0;
	while( 1 )
	{
		self waittill("trigger");
		if( !set_custom_color_logic )
		{
			thread jungle_hill_friendly_color_stealth_settings();
			set_custom_color_logic = 1;
		}
		if( !level.alpha[0].ent_flag["override_follow_logic"] )		
		{
			array_thread( level.alpha, ::ent_flag_set, "override_follow_logic" );
			array_thread( level.alpha, ::enable_ai_color );
			
			while( level.player istouching( self ) )
			{
				wait(.05);
			}
			
			array_thread( level.alpha, ::ent_flag_clear, "override_follow_logic" );
			array_thread( level.alpha, ::disable_ai_color );
		}	

	}
		
}

crouch_at_goal()
{
	self endon( "moving_up" );
	self waittill( "goal" );
	
	//this notify cues a VO line. It gets sent a LOT so I'm throttling it a bit here. 
	if( randomint( 100 ) < 33 ) //33% chance
		self notify( "with_player" );
	
	//self.fixednode 	= true; 
	if( !IsDefined( self.node ) )
	{
		//IPrintLn("friendly is crouching because he has no cover node");
		self AllowedStances( "crouch" );	
	}
}


waittill_player_moves_or_timeout_controller( timeout )
{
	velocity_limit = 130;
	self thread return_after_time( timeout, "player_moved_ahead" );
	self thread return_on_velocity( velocity_limit );
	self waittill( "returned", msg );
	self notify( "kill" );
	return msg;
}

waittill_player_moves_or_timeout_kb( timeout )
{
	limit_sqd = 200*200;
	self thread return_after_time( timeout, "player_moved_ahead" );
	self thread return_on_movement( limit_sqd );
	self waittill( "returned", msg );
	self notify( "kill" );
	return msg;
}


waittill_close_to_ent_or_timeout( timeout, ent, distsqd )	
{
	ent endon( "death" );
	self thread return_after_time( timeout, "is_close_enough" );
	self thread return_when_close( ent, distsqd );
	self waittill( "returned", msg );
	self notify( "kill" );
	return msg;
}

waittill_not_moving_or_timeout( timeout, ent )
{
	ent endon( "death" );
	self thread return_after_time( timeout, "stopped_moving" );
	self thread return_when_still( ent );
	self waittill( "returned", msg );
	self notify( "kill" );
	return msg;
}

return_at_goal( ent )
{
	self endon( "kill" );
	ent endon( "death" );
	
	ent waittill("goal");
	self notify( "returned", "reached_goal");
}

return_when_still( ent )
{
	self endon( "kill" );
	ent endon( "death" );
	while( 1 )
	{
		current_org = ent.origin;
		wait( .10 );
		new_org = ent.origin;
		if( current_org == new_org )
		{
			self notify( "returned", "stopped_moving");
		}		
	}		
}

is_moving()
{
	self endon( "death" );
	current_org = self.origin;
	wait( .20 );
	new_org = self.origin;
	if( current_org == new_org )
		return false;
	return true;	
}

return_on_movement( distsqd_limit )
{
	self endon( "kill" );
	level.player endon( "death" );
	
	start_org = level.player.origin;
	while( 1 )
	{	
		wait( .10 );
		new_org = level.player.origin;
		if( Distance2DSquared( start_org, new_org ) >= distsqd_limit )
		{
			self notify( "returned", "has_moved");
		}		
	}			
}


return_when_close( ent, distsqd )
{
	self endon( "kill" );
	ent endon( "death" );
	while( 1 )
	{
		dist = DistanceSquared( self.origin, ent.origin );
		if( dist <= distsqd )
		{
			self notify( "returned", "is_close_enough");
		}		
		wait(.05 );
	}	
}

return_on_velocity( velocity_limit )
{ 
	self endon("kill");
	while(1)
	{
		velocity = level.player GetVelocity();
		if( velocity != (0,0,0) )
		{		
			difference =  distance2d( (0,0,0), velocity );
			if( difference >= velocity_limit || difference <= velocity_limit *-1  )
			{			
				//IPrintLnBold( "player velocity is " +difference+ ". Catching up" );
				self notify( "returned", "player_moved_ahead");
			}
		}
		wait(.5);
	}
}


return_after_time( timeout, _endon )
{
	self endon( "kill" );
	self endon( _endon );
	wait( timeout );
	self notify( "returned", "timed_out");
}

friendly_navigation()
{
	flag_wait( "jungle_entrance" );

	foreach( guy in level.alpha )
	{
		guy set_moveplaybackrate( 1 );
		guy disable_ai_color();
		guy thread follow_player();
		guy thread keep_up_with_player( "stop_following_player" );
		guy thread aim_with_player();
	}
	
	wait( 5 );
	level thread jungle_hill_friendly_navigation();
}

do_birds()
{
	trigger_wait_targetname( "jungle_entrance" );

	level endon("hill_pos_6");
	while(1)		
	{	
		do_bird_single();
		wait(randomintrange( 20, 45 ));
	}
	                                                                 
}

do_bird_single_enemy( optional_bird_fx )
{
	Forward = VectorNormalize( AnglesToForward( self.angles ) );
	spot = self.origin + ( Forward* randomintrange( 10, 30 )  );
	high_spot = spot +( 0, 0, 1000 );
	offset = RandomIntRange( -100, 100 );
	bird_spot = groundpos( high_spot ) + ( offset, offset, 0 );
		
	thread play_sound_in_space( "anml_bird_startle_foliage", bird_spot );
	wait(.5);
	
	/*if( !isdefined( optional_bird_fx ) )	
		optional_bird_fx = "birds";
	
	PlayFX( getfx( optional_bird_fx ), bird_spot  );
	thread play_sound_in_space( "anml_bird_startle_flyaway", bird_spot );	*/
	maps\interactive_models\_birds::birds_SpawnAndFlyAway( "parakeets", bird_spot, (1000,0,1000), RandomIntRange(3,8) );
}


do_bird_single( optional_bird_fx )
{
	Forward = VectorNormalize( AnglesToForward( level.player getplayerangles() ) );
	spot = level.player.origin + ( Forward* 1200  );
	high_spot = spot +( 0, 0, 1000 );
	offset = RandomIntRange( -300, 300 );
	bird_spot = groundpos( high_spot ) + ( offset, offset, 0 );
		
	if( randomint(100) < 33 )
	{
		thread play_sound_in_space( "anml_bird_startle_foliage", bird_spot );
		wait(.5);
	}
	
/*	if( !isdefined( optional_bird_fx ) )	
		optional_bird_fx = "birds";
	
	PlayFX( getfx( optional_bird_fx ), bird_spot  );
	thread play_sound_in_space( "anml_bird_startle_flyaway", bird_spot );	*/
	maps\interactive_models\_birds::birds_SpawnAndFlyAway( "parakeets", bird_spot, (500,0,500), RandomIntRange(3,8) );
}



keep_up_with_player( _endon )
{
	//wait(5); 
	self endon ( _endon );
	self.orig_speed = self.moveplaybackrate;
	while(1)
	{
		if( self ent_flag("override_follow_logic" ) )
		{
			wait(.10);
			continue;
		}
		dist = Distance2D( self.origin, self.target_ent.origin );
		//print3d( self.origin + (0,0,40), dot );
		threshhold = 250;;
		if( dist > threshhold )
		{
			self.moveplaybackrate = 1.2;
			//IPrintLn( "catching up");
			dist = Distance2D( self.origin, self.target_ent.origin );

			while( dist > 100 ) 
			{	
				dist = Distance2D( self.origin, self.target_ent.origin );
				wait(.05);
			}
			self.moveplaybackrate = self.orig_speed;
		}
		wait(.25);
	}
	
}

cqb_when_player_sees_me()
{
	//self enable_cqbwalk();
	
	self disable_cqbwalk();
	
	self endon("death");
	self endon("stop_following_player");
	level endon( "_stealth_spotted" );
	self.cqbwalking = undefined;
	self disable_cqbwalk();
	grace_period = .15;
	
	while ( 1 )
	{
		if( player_can_see_ai( self ) )
		{
			if( !isdefined( self.cqbwalking ) )
			{
				//IPrintLn("Enabling cqb");
				self enable_cqbwalk();
				wait( grace_period );		
			}
		}
		else
		{
			if( isdefined(self.cqbwalking ) )
			{
				//IPrintLn("disabling cqb");
				self disable_cqbwalk();
				wait( grace_period );	
			}
		}
		wait(.15);
	}
	
}

jungle_stealth_settings()
{
	jungle_hidden = [];
	jungle_hidden[ "prone" ]	 = 70;//70
	jungle_hidden[ "crouch" ]	 = 400;//600 450
	jungle_hidden[ "stand" ]	 = 600;//1024
		
	jungle_spotted = [];
	jungle_spotted[ "prone" ]	 = 500; //512;
	jungle_spotted[ "crouch" ]	 = 1500; //5000;
	jungle_spotted[ "stand" ]	 = 2000; //8000;
	
	maps\_stealth_utility::stealth_detect_ranges_set( jungle_hidden, jungle_spotted );

	array = [];
	array[ "player_dist" ] 		 = 600;//1500;// this is the max distance a player can be to a corpse
	array[ "sight_dist" ] 		 = 200;//1500;// this is how far they can see to see a corpse
	array[ "detect_dist" ] 		 = 100;//256;// this is at what distance they automatically see a corpse
	array[ "found_dist" ] 		 = 50;//96;// this is at what distance they actually find a corpse
	array[ "found_dog_dist" ] 	 = 50;//50;// this is at what distance they actually find a corpse

	maps\_stealth_utility::stealth_corpse_ranges_custom( array );

}


aim_with_player()
{
	level endon( "_stealth_spotted" );
	level endon( "waterfall_approach" );
	while(1)
	{
		//dont do this if other funcs are controlling this friendly
		ent_flag_waitopen( "stealth_kill" );		
		if(  ( isdefined( self.enemy ) && !level.player player_can_see_ai( self.enemy ) ) || !isdefined( self.enemy)  )
		{	
			axis = getaiarray( "axis" );		
			foreach( guy in axis )
			{
				if( player_can_see_ai( guy ) )
				{
					//IPrintLn( "trying to aim at an enemy the player can see" );
			   		self clearenemy();
					self set_favoriteenemy( guy );
					break;			   	
				}
			}	
		}
		wait( 2 );	
	}
}

player_target_detection()
{
	level endon ("waterfall_approach");	
	
	attempt_count = 4;
	while(1)
	{
		if( flag( "_stealth_spotted" ) )
		{
			wait 2;
			continue;
		}
		if( level.player isADS()  )	
		{
			for( i = 0; i < attempt_count; i ++ )
			{
				//IPrintLn( "checking for ads target: attempt: " +i  );
				player_target = get_players_ads_target();
				if( IsDefined( player_target ) )				
				{
					axis = GetAIArray( "axis" );
					level.enemies_near_target  = get_array_of_closest( player_target.origin, axis, undefined, undefined, 400, 0 );
					//array_thread( level.alpha, ::assign_my_favorite_enemy, player_target );
					wait .5;
					foreach ( guy  in level.alpha )
					{
						if( guy.is_speaking == 0 )							
						{
							if( isAlive( player_target ) && !level.player IsFiring() )
							{
								guy notify( "player_has_target" );
								wait 10;
								i = attempt_count;
								break;	
							}
						}
					}								
				}	
			}
		}	
		wait .5;		
	}
}

assign_my_favorite_enemy( guy )
{
	self clearenemy();
	self set_favoriteenemy( guy );
}

attack_with_player()
{	
	flag_wait( "jungle_entrance" );
	player_target = undefined;
	friendly_targets = [];
	buffer_time = 3;
	level endon("_stealth_spotted" );
	level endon ("waterfall_approach");	
	//level thread notify_squad_on_corpse_or_spotted();
	level thread player_fire_monitor();
	
	while ( 1 )
	{
		level.player waittill( "weapon_fired" );
			
		axis = getaiarray( "axis" );
		//try to get who player is aiming at if they are ADS
		if( level.player isADS() )		
		{
			player_target = get_players_ads_target();
		}
		//if we dont have the players target yet
		if( !isdefined( player_target) )
		{				
			foreach( guy in axis )			
			{				
				if( level.player player_can_see_ai( guy ) )
				{
					//check if hes in stealth first-reaction 
					if( guy ent_flag_exist( "_stealth_behavior_first_reaction" ) && guy ent_flag( "_stealth_behavior_first_reaction" )  ) 
					{
						player_target = guy;	
						break;					
					}  	
					//otherwise check if the player is the enemy of any axis
					else if( isdefined( guy.enemy ) )			
					{
						if( guy.enemy == level.player )
						{
							player_target = guy;	
							break;
						}
					}
				}
			}
		
		}
		//if we picked a guy, get the guys closest and tell friendlies to attack them
		if( isdefined( player_target ) )
		{
			friendly_targets = get_array_of_closest( player_target.origin, axis, [player_target], undefined, 450, 0 );
					
			if( friendly_targets.size !=0 )
			{
				//array_thread( friendly_targets, maps\jungle_ghosts_util::print3d_on_me, "!" );
				friendlies_attack_enemy_array( friendly_targets, level.alpha );
				
				//check if players target is still alive
				if( isAlive( player_target ) )
				{
					//IPrintLn( "Finishing off players target" );
					friendlies_attack_enemy_array( [ player_target], level.alpha );
				}
			
				wait( buffer_time );
			}
			//no other enemies are close so shoot the players target if hes still alive in X seconds
			else
			{
				player_kill_time = 1;
				wait( player_kill_time );
				if( isAlive( player_target ) )
				{
					//IPrintLn( "Finishing off players target" );
					friendlies_attack_enemy_array( [ player_target], level.alpha );
				}
				
			}
		}

	}
	
}

player_fire_monitor()
{
	level endon( "waterfall_approach");
	
	while(1)
	{
		level.player waittill( "weapon_fired" );
		level.player ent_flag_set( "recently_fired_weapon");	
		level thread ent_flag_clear_delayed_endon( "recently_fired_weapon", "weapon_fired" );
	}
}


ent_flag_clear_delayed_endon( _ent_flag, _endon )
{
	level.player endon( _endon );
	wait 7;
	level.player ent_flag_clear( _ent_flag );	
}

get_players_ads_target()
{
	Forward = VectorNormalize( AnglesToForward( level.player getplayerangles() ) );
	players_aim = level.player.origin + ( Forward* 10000  );
	trace = BulletTrace( level.player geteye(), players_aim, true, level.player );
	if( isDefined( trace["entity"] ) )
	   if( IsSentient( trace["entity"] ) )
	   	if( trace["entity"].team =="axis" )
		{
	   		player_target = trace["entity"];	
	   		return player_target;
		}
		else
		{
			return undefined;
		}
				
}

friendlies_attack_enemy_array( enemy_array, friendly_array )
{
	enemy_array = array_removeDead_or_dying( enemy_array );		
	if( !isdefined(enemy_array.size ) )
		return;
	
	array_thread( friendly_array, ::ent_flag_set, "stealth_kill" );
	array_thread( friendly_array, ::global_ignore_off );
	array_thread( enemy_array, ::disable_DontAttackMe );
	
	if( enemy_array.size == friendly_array.size )
	{	
		chosen_friendly = getclosest( enemy_array[0].origin, friendly_array );
		chosen_friendly.favoriteEnemy = enemy_array[0];
		chosen_friendly thread adjust_target_visibility( enemy_array[0] );
		//thread draw_line_for_time(   enemy_array[0].origin, chosen_friendly.origin, 0, 0, 1, 5 );
		
		foreach ( leftover_friendly in friendly_array )
		{
			if( leftover_friendly != chosen_friendly )
			{				
				leftover_friendly.favoriteEnemy = enemy_array[1];
				leftover_friendly thread adjust_target_visibility( enemy_array[1] );
				//thread draw_line_for_time(   enemy_array[1].origin, leftover_friendly.origin, 0, 1, 0, 5 );
				break;
			}
		}		
	}
	else
	{				
		foreach( i, friendly in friendly_array )
		{
			friendly_array[i].favoriteEnemy = enemy_array[0];
			friendly_array[i] thread adjust_target_visibility(  enemy_array[0] );
			//thread draw_line_for_time( enemy_array[i].origin, level.alpha[0].origin, 0, 0, 1, 3 );
		}
	}
		
	waittill_dead_or_dying( enemy_array, enemy_array.size, 7 ); //timeout is 7!!!
	
	//array_notify( friendly_array, "stop_pursuing_target" );
	array_thread( friendly_array, ::ent_flag_clear, "stealth_kill" );
	array_thread( friendly_array, ::global_ignore_on );
	//IPrintLn( "all baddies in group dead" );
}


friendly_kill_vo()
{
	self endon( "deleted" );
	self waittill( "death", attacker );
	
	if( isdefined( attacker ) )
	{
		if( attacker.classname == "player" )
		{	
			foreach( guy in level.alpha )
			{
				if( isdefined( guy.is_speaking ) )
				{
					if ( guy.is_speaking == 0 )
					{
						guy notify( "player_kill" );
						return;
					}	
				}					
			}
		}
		else
		{
			foreach( guy in level.alpha )
			{
				//if( attacker == guy && guy.is_speaking == 0 )
				//{
				//	guy notify( "friendly_kill" );
				//	return;						
				//}	
				//else
				//{
					guy notify( "friendly_kill" );
					return;	
				//}					
			}
		}
	}
	
	
}

player_spotted_count()
{
	self ent_flag_wait( "_stealth_behavior_first_reaction" );
	self LaserForceOn();
	  
	self thread delay_notify_alive();
	
	if( !is_in_array( level.stealth_player_aware_enemies, self ) )
	{
		level.stealth_player_aware_enemies = add_to_array( level.stealth_player_aware_enemies, self );
	}

	if( !flag("player_spotted_vo") && !flag("_stealth_spotted" ) )
	{
		flag_set( "player_spotted_vo" );
		if( cointoss() )
			line = "jungleg_gs1_contact";
		else
			line = "jungleg_gs2_hesgoteyeson";
		
		level.alpha1 thread do_story_line( line );
		flag_clear_delayed( "player_spotted_vo", 10 );
	}
	
	self waittill("death");
	level.stealth_player_aware_enemies = array_remove( level.stealth_player_aware_enemies, self );
}

delay_notify_alive()
{
	self endon("death" );
	wait 3;
	if( isdefined_and_alive( self ) )
			level notify( "enemy_stealth_reaction" );	//this plays music stinger. Dont want it playing if player kills this guy right away	
}

enemy_becomes_target_if_spotting_player()
{
	//enemies become hot one at a time, not all of them at once.  This makes them viable targets individually
	
	self endon("death");
	
	player_attacks_time = undefined;
	skill = getdifficulty();
	switch( skill )
	{
		case "gimp":
		case "easy":
			player_attacks_time = .5;
		case "medium":
			player_attacks_time = 1.5;
		case "hard":
		case "difficult":
		case "fu":
			player_attacks_time = 2;
	}
	
		
	self ent_flag_wait( "_stealth_behavior_first_reaction" );
	spot = self.origin; //get his origiin before he dies
	
	//give player a chance to engage nearby enemies
	wait( player_attacks_time );
	
	friendly_attacker = getClosest( self.origin, level.alpha );
	//the spotted friendly attacks the enemy who saw him
	friendlies_attack_enemy_array( [ self ], [friendly_attacker] );
	
	//plays a VO line in dynamic_vo_manager()
	friendly_attacker notify ( "friendly_spotted" );
	
	//get closeby enemies
	axis = getaiarray("axis");
	enemies_near_me = get_array_of_closest( spot, axis, [self], undefined, 450, 0 );
			
	//remaining friendly takes out close enemies
	if( enemies_near_me.size !=0 )
	{	
		remaining_squad_clears_close_enemies( enemies_near_me, friendly_attacker, level.alpha );
	}

}

adjust_target_visibility( victim )
{	
	//self = friendly. 
	//If friendly can't see intended victim, keep moving towards them until they have eyes-on
	if(!isdefined( self.target_ent ) )
		return; //we shouldnt be in this func yet
	
	if( isalive( victim ) && isdefined( victim ) )
	{
		self endon( "stop_pursuing_target" );
		self endon("timed_out");
		self thread return_after_time( 7, "eyes_on_target" );
		if( maps\jungle_ghosts_util::isdefined_and_alive( victim ) )
		{
			if( !self cansee( victim ) )
			{
				if( isdefined( level.player_brush ) )
				{
					if(!level.player_brush ent_flag( "stop_blocking_paths" ) )
					{
						level.player_brush ent_flag_set( "stop_blocking_paths" );
						level.player_brush delaycall( 1, ::connectpaths );
					}
				}
				self disable_cqbwalk();
				self set_forcegoal_no_sight_adjust();
				self.goalradius = 100;
				
				if( maps\jungle_ghosts_util::isdefined_and_alive( victim ) )
				{
					self SetGoalpos( victim.origin );
					//self thread maps\jungle_ghosts_util::print3d_on_me("*");
				
					while( isdefined_and_alive( victim ) &&  !self cansee( victim ) ) 
					{
				      	wait(.05);
					}
				
					self notify("eyes_on_target");
					self enable_cqbwalk();
					self unset_forcegoal_no_sight_adjust();
					//IPrintLn( "Stop adjusting view of target");
					self setgoalpos( self.target_ent.origin );		
					self.goalradius = FAR_FROM_GOAL;	
					//self notify ("stop_print3d_on_ent");
				}
				if( isdefined( level.player_brush ) )
				{
					if( level.player_brush ent_flag( "stop_blocking_paths" ) )
						level.player_brush ent_flag_clear( "stop_blocking_paths" );
				}
				
			}
		}
	}
}

set_forcegoal_no_sight_adjust()
{
	//same as forcegoal without blinding the ai
	if ( IsDefined( self.set_forcedgoal_custom ) )
		return;

	self.oldfightdist 	 = self.pathenemyfightdist;
	self.oldmaxdist 	 = self.pathenemylookahead;
	//self.oldmaxsight 	 = self.maxsightdistsqrd;

	self.pathenemyfightdist = 8;
	self.pathenemylookahead = 8;
	//self.maxsightdistsqrd = 1;
	self.set_forcedgoal_custom = true;
}

unset_forcegoal_no_sight_adjust()
{
	if ( !isdefined( self.set_forcedgoal_custom ) )
		return;

	self.pathenemyfightdist = self.oldfightdist;
	self.pathenemylookahead = self.oldmaxdist;
	//self.maxsightdistsqrd 	 = self.oldmaxsight;
	self.set_forcedgoal_custom = undefined;
}

disable_DontAttackMe()
{
	if( isdefined( self.dontattackme ) )
		self.dontattackme = undefined;	
}

global_ignore_off()
{
	//self.ignoreme = 0;
	if( isdefined( self.dontEverShoot ) )
		self.dontEverShoot = undefined;
	if( isdefined( self.enemy ) )
		self ClearEnemy();
	self.ignoreall = 0;
}


global_ignore_on()
{
	self.ignoreme = 1;
	//self.dontevershoot = undefined;

}

generic_ignore_on()
{
	self.ignoreme = 1;
	self.ignoreall = 1;	
}

generic_ignore_off()
{
	self.ignoreme = 0;
	self.ignoreall = 0;	
}

melee_interupt_logic( my_killer )
{
	//self = melee VICTIM
	level endon( "interupt_end" ); //set by notetrack
	self thread stealth_enemy_endon_alert();
	self waittill_any( "damage", "stealth_enemy_endon" );
	
	level notify( "takedown_interupted" );
	my_killer StopAnimScripted();
	self StopAnimScripted();
	
	if( maps\jungle_ghosts_util::isdefined_and_alive( self ) )
	{
		self.maxsightdistsqrd = 800 * 800;
		self.ignoreall = 0;
		self.jungle_melee = 0;
	}
		
}

//try_jungle_melee( _enemy)	
//{	
//	//self = friendly
//	_enemy thread melee_interupt_logic( self );
//	//level endon( "takedown_interupted" );
//	
//	_enemy notify("end_patrol");
//	_enemy notify( "release_node" );
//	if ( isdefined( _enemy.old_interval ) )
//		_enemy.interval = _enemy.old_interval;
//	_enemy.goalradius = 3000;
//	_enemy setgoalpos( _enemy.origin );	
//	_enemy.ignoreall = 1;	
//	
//	//had to this because he would not. stop. moving.
//	_enemy.anchor = spawn("script_origin", _enemy.origin );
//	_enemy linkto( _enemy.anchor );
//	
//	//give him time to stop moving
//	outcome = waittill_not_moving_or_timeout( 3, _enemy );		
//	if( isdefined ( outcome ) && outcome == "timed_out" )
//	{
//		PrintLn( "Aborting takedown. Enemy wont stop moving." );
//		_enemy.ignoreall = 0;
//		_enemy.jungle_melee = 0;
//		_enemy.goalradius = 32;
//		_enemy unlink();
//		_enemy.anchor delete();
//		return;
//	}
//	
//	level.player_brush ent_flag_set( "stop_blocking_paths" );
//	wait 1;
//	level.player_brush ConnectPaths();
//	
//	//Continue with anim attempt
//	_enemy.moveplaybackrate = 1;
//	_enemy.animname =  "victim" ;
//	
//	self AllowedStances( "stand", "crouch", "prone" );
//	//_enemy ent_flag_set( "stealth_kill" );
//	self ent_flag_set( "stealth_kill" );
//	if( isdefined( self.animname ) )
//		self.old_animname = self.animname;
//	
//	if( self == level.alpha1 )
//		self.animname = "alpha1";	
//	else
//		self.animname = "alpha2";
//	//self disable_cqbwalk();
//	//self anim_single_solo( self, "trans_to_knifewalk" );
//	//self set_run_anim( "knifewalk" );
//	
//	guys = [_enemy, self ];	
//	self.victim = _enemy;
//	_enemy thread melee_early_death_notify( self );
//	
//	//This needs to be delayed or else the following waittillany will not catch the returning message from this func
//	_enemy delayThread( .5,  maps\jungle_ghosts_util::anim_reach_custom, [self], "takedown_new1" );
//
//	outcome = self waittill_any_return("anim_reach_complete", "abort_takedown" );
//	
//	if( outcome != 	"abort_takedown" )
//	{
//		//double checking some conditions before doing the anim
//		if( isalive( _enemy ) &&!flag("_stealth_spotted" ) )
//		{	
//			spot = _enemy.origin;		
//			axis = getaiarray( "axis" );
//			close_enemies = get_array_of_closest( spot, axis, [ _enemy ], undefined, 300, 0 );		
//			
//			if( isdefined( close_enemies.size ) && close_enemies.size > 0  )
//			{
//				level thread remaining_squad_clears_close_enemies( close_enemies, self );
//			}		
//			_enemy anim_single( guys, "takedown_new1" );	
//			_enemy anim_last_frame_solo( _enemy, "takedown_new1" );
//			_enemy thread generic_ignore_on();
//			_enemy.team = "neutral";
//			_enemy.a.nodeath = true;
//			_enemy.allowpain = false;
//			_enemy.allowdeath = false;
//			_enemy.anchor delete();
//			_enemy disable_stealth_for_ai();
//			_enemy thread takedown_corpse_disposal();
//		}
//		else
//		{
//			PrintLn( "aborting takedown: vicitim is already dead or stealth is broken." );
//		}
//	}
//	else
//	{
//		//Anim wont work due to geo.  Execute the guy and any near him. 
//		PrintLn( "executing enemy" );
//		spot = _enemy.origin;
//		axis = getaiarray( "axis" );
//		close_enemies = get_array_of_closest( spot, axis, undefined, undefined, 300, 0 );		
//		
//		if( isdefined( close_enemies.size ) && close_enemies.size > 0  )
//		{
//			level thread friendlies_attack_enemy_array( close_enemies, level.alpha );
//		}		
//		else
//			friendlies_attack_enemy_array( [ _enemy ], level.alpha );		
//	}
//	
//	level.player_brush ent_flag_clear( "stop_blocking_paths" );	
//	
//	self.animname = self.old_animname;	
//	//self enable_cqbwalk();
//	self ent_flag_clear("stealth_kill");
//}

melee_early_death_notify( my_killer )
{
	self endon( "anim single" );
	self waittill( "death" );
	my_killer notify( "abort_takedown" );	
}

takedown_corpse_disposal()
{
	self endon( "death" );
	dist = DistanceSquared( self.origin, level.player.origin );
	while(  maps\jungle_ghosts_util::isdefined_and_alive( self ) && dist < 1500*1500 )
	{
		dist = DistanceSquared( self.origin, level.player.origin );
		wait 2;
	}
	
	self delete();		
}


remaining_squad_clears_close_enemies( enemies, excluder, optional_friendly_array )
{
	if(! isdefined( optional_friendly_array) )
		remaining_squad = GetAIArray( "allies" );
	else
		remaining_squad = optional_friendly_array;
	
	remaining_squad = array_remove( remaining_squad, excluder );
	friendlies_attack_enemy_array( enemies, remaining_squad );
	
}


jungle_hill_friendly_navigation()
{
	trigger_wait_targetname( "hill_pos_1" );
	//TODO check for stealth
	level.stealth_spotted_time = 3;
		
	//stop doing dynamic following of player. Switch to color trigs to move up back end of hill to waterfall. 
	flag_wait_any("hill_clear", "waterfall_approach" ); 
	foreach( guy in level.alpha )
	{
		guy notify( "stop_following_player" );
		guy AllowedStances( "stand", "crouch", "prone" );
		guy enable_ai_color();	
		guy set_force_color( "r" );
		guy disable_cqbwalk();
	}
	
	battlechatter_off();
	autosave_by_name( "waterfall_approach");
	
	ambeint_choppers = spawn_vehicles_from_targetname_and_drive( "jungle_hill_apaches" );
}	

jungle_hill_friendly_color_stealth_settings()
{
	array = [];
	array[ "hidden" ] = ::jungle_friendly_color_hidden;
	array[ "spotted" ] = ::jungle_friendly_color_spotted;

	array_thread( level.alpha, ::stealth_color_state_custom, array );
}


jungle_friendly_color_hidden()
{
	self enable_ai_color();
}


jungle_friendly_color_spotted()
{
	//blah
}

clear_next_color_trig()
{
	//self endon("death");
	if( flag( "_stealth_spotted" ) )
	   return;
	
	level endon( "_stealth_spotted" );
	self waittill( "trigger" );
	
	my_name = StrTok( self.targetname, "_" );
	wait( .10 );
	if( isdefined( my_name.size ) )
		if( isdefined( my_name[2] ) )
		{	
			my_number = int( my_name[2] );
			next_number = my_number+1;
			next_trig_targetname = "hill_pos_" +next_number;
			next_trig = getent( next_trig_targetname, "targetname" );
			if( isdefined( next_trig ) )
				level thread attack_enemies_in_trig( next_trig );
		}
			
}

attack_enemies_in_trig( trig )
{
	axis = getaiarray( "axis" );
	foreach( guy in axis )
	{
		if( guy istouching( trig ) )
		{
			guy thread disable_DontAttackMe();
			//guy thread  maps\jungle_ghosts_util::print3d_on_me( "attack me!" );
		}
	}
		
}

waterfall_execution()
{
	
	level thread maps\jungle_ghosts_stream::friendly_stream_navigation();
	
//	fail_trig = getent( "rescue_fail", "targetname" );
//	fail_trig thread maps\jungle_ghosts_util::fail_trig_logic( "waterfall_clear");
	
	slomo_sound_scale_setup();
	array_spawn_function_targetname( "bravo_team", ::bravo_friendly_logic );
	patrollers = array_spawn_targetname( "waterfall_patrollers", 1 );

	guard1 = spawn_targetname( "guard1", 1 );
	guard1.ignoreme = 1;
	
	guard2 = spawn_targetname( "guard2", 1 );
	guard2.ignoreme = 1;
	
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	//array_thread ( level.bravo, ::gun_remove );
	thread setup_smaw_guy();
	friendlyfire_warnings_off();
	
	hostage1 = level.bravo[0];
	hostage1.deathfunc = ::knife_victim_death_func;
	hostage2 = level.bravo[1];
	hostage2.deathfunc = ::knife_victim_death_func;
	
	hostage1.animname = "hostage1";
	hostage2.animname = "hostage2";
	hostage1.on_knees = undefined;
	
	guard1.animname	  = "guard1";
	guard2.animname	  = "guard2";

	scene		   = SpawnStruct();
	scene.guard1   = guard1;
	scene.guard2   = guard2;
	scene.hostage1 = hostage1;
	scene.hostage2 = hostage2;
	scene.patroller1 = patrollers[0];
	scene.patroller2 = patrollers[1];
	scene.outcome_decided = 0;
	scene.guards   = [ guard1, guard2 ];
	scene.execution_team = [guard1, guard2, patrollers[0], patrollers[1] ];
	array_thread( scene.execution_team, ::execution_team_globals );
	
	//scene endon( "player_interupted" );
	
	new_anim_ent = getstruct( "new_wf_anim_ent", "targetname" );
	guard1.anim_ent = new_anim_ent;
		
	guard2.anim_ent = getent( "guard2_anim_ent", "targetname" );
	hostage1.anim_ent = new_anim_ent;
	
	hostage2.anim_ent = spawn("script_origin", new_anim_ent.origin );
	hostage2.anim_ent.angles = new_anim_ent.angles;
	
	guard1.scene_struct = scene;
	guard1 thread guard1_logic();
	guard2.scene_struct = scene;
	
	hostage1.scene_struct = scene;
	hostage2.scene_struct = scene;
	
	patrollers[0].scene_struct = scene;
	patrollers[1].scene_struct = scene;
	
	player_close_trig = getent( "waterfall_spotted", "targetname" );
	player_close_trig.scene_struct = scene;
	player_close_trig thread monitor_player_close();
		
	guard1 thread scene_interupt_monitor();
	guard2 thread scene_interupt_monitor();
	array_thread( patrollers, ::scene_interupt_monitor );
	array_thread( patrollers, ::patroller_logic );
	
	//dunking into water loop
	hostage1.anim_ent thread anim_loop_solo( hostage1, "water_dunk_loop", "stop_loop" ); 
	hostage2.anim_ent thread anim_loop_solo( hostage2, "water_dunk_loop", "stop_loop" ); 	
	guard1.anim_ent thread anim_loop_solo( guard1, "water_dunk_loop", "stop_loop" ); 
	guard2.anim_ent thread anim_loop_solo( guard2, "standing_idle" ); 
	
	scene thread scene_vo();
		
	//player arrives
	trigger_wait_targetname( "waterfall_trig" );
	//IPrintLn( "player arrived" );
	flag_set( "player_at_execution" );
	
	TIME_BEFORE_SCENE = 3;

	scene thread guard1_pushes_hostage1_underwate_interrogates_and_kills_hostage_2();
	scene thread hostage1_goes_underwater();	
	scene thread hostage2_reacts_to_push_gets_interrogated();
	
	scene thread friendlies_execute_enemies();
	
	scene thread hostage1_helpup();	
	hostage2 thread hostage2_get_up_when_freed();
	//hostage1 thread hostage1_get_up_when_freed();

	time_before_execution =  GetAnimLength( guard1 getanim( "interrogation")  );
	
	//Time for player to shoot
	wait( time_before_execution );
	
	//this kicks off the friendlies going hot if the player hasnt shot yet
	if( !scene.outcome_decided )
		magicbullet( level.alpha[0].weapon, level.alpha[0] gettagorigin( "tag_flash" ), guard1 geteye() );
	
}

REACTION_TME = 1;

scene_vo()
{
	//self = scene struct
	self endon( "player_interupted" );
	
	//player is close
	flag_wait("squad_to_waterfall");
		
	//Federation Soldier 1: Where's the rest of your squad?
	self.guard1 smart_dialogue( "jungleg_saf1_wherestherestof" );
	
	//Federation Soldier 1: How many men were on that plane?
	self.guard1 smart_dialogue( "jungleg_saf1_howmanymenwere" );
	
	//player arrives
	flag_wait("player_at_execution");
	
	//using play_sound_on_tag because it hasd endon death ability
	
	//Federation Soldier 1: <forceful struggle sounds>
	//self.guard1 play_sound_on_tag( "jungleg_saf1_forcefulstrugglesounds", undefined, true );
	
	//Federation Soldier 1: Your friend is going to drown unless you start talking!
	self.guard1 play_sound_on_tag( "jungleg_saf1_yourfriendisgoing", undefined, true );
	
}

guard1_logic()
{
	self set_deathanim( "waterfall_death" );
	self gun_remove();		
	self attach( "weapon_beretta", "TAG_WEAPON_RIGHT" );
}

hostage1_helpup()
{	
	player_rig = spawn_anim_model( "player_rig", self.guard1.origin );	
	player_rig hide();
	
	self waittill("player_interupted");
	
	ent = self.guard1.anim_ent;	
	ent.actors = [ player_rig, self.hostage1 ];
	//anim_time = GetAnimLength( %jungle_ghost_wf_holdup_hostage1_helpup );

	//helpup_trig = self.hostage1;
	//helpup_trig MakeUsable(); //the dude is the trig yo!
	//actionBind = maps\jungle_ghosts::getActionBind( "player_helpup" );
	//helpup_trig SetHintString(  actionbind.hint );
	//helpup_trig thread maps\jungle_ghosts_util::print3d_on_me("!");
	
	//helpup_trig thread notify_delay( "player_waited_too_long", 14 );
	//outcome  = helpup_trig waittill_any_return("trigger", "player_waited_too_long" );
	/*
	if( outcome == "trigger" )
	{
		//player does it
		helpup_trig MakeUnusable();	
		level.player SetStance( "stand" );
		level.player AllowCrouch( false );
		level.player AllowProne( false );
		level.player DisableWeapons();
		flag_set("player_rescued_hostage" );
	
		//show the player rig	
		player_rig delayCall( 0.4, ::Show );		
		level thread intro_takedown_player_link_logic( player_rig );
		
		self.hostage1.anim_ent notify( "stop_underwater_idle" );
		ent anim_single( ent.actors, "helped_up" );
		level.player SetOrigin( level.player.origin + (0,0,10 ) );
		level.player AllowCrouch( true );
		level.player AllowProne( true );
		level.player EnableWeapons();	
	}
	else
	{
	*/
		//friendly does it
		//flag_set("player_rescued_hostage" );
		//helpup_trig MakeUnusable();
		//IPrintLnBold( "Whats wrong with you? I'll get him!");
		ent.actors = add_to_array( ent.actors, level.alpha1 );
		level.alpha1 disable_ai_color();
		ent anim_reach_solo( level.alpha1, "helped_up" );
		self.hostage1.anim_ent notify( "stop_underwater_idle" );
		level.alpha1 thread smart_dialogue("jungleg_gs1_dammitbakernottoday");
		ent anim_single( ent.actors, "helped_up" );
		level.alpha1 enable_ai_color();
		
		wait 4;
		level.alpha1 disable_ai_color();
		
	//}

}


execution_team_globals()
{
	self AllowedStances( "stand" );
	self disable_blood_pool();
	self disable_surprise();
	self.grenadeammo = 0;
	self.health = 75;	
	self.baseaccuracy = .6;
	self thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_walk_water");
}


patroller_logic()
{
	self endon( "death" );
	self.ignoreall = 1;
	self.ignoreme = 1;

	self.scene_struct waittill( "player_interupted" );
	self notify("end_patrol");
	self notify( "release_node" );
	self StopAnimScripted();
	self.goalradius = 32;
	self.pathenemyfightdist = 8;
//	self.pathenemylookahead = 8;
	self SetGoalEntity( level.player, 1 );	
}

hostage1_goes_underwater()
{
	//self = struct
	self.hostage1 endon( "death" );
	self.hostage1.anim_ent notify( "stop_loop" );
	self.hostage1 StopAnimScripted();
	self.hostage1.anim_ent anim_single_solo( self.hostage1, "push_underwater" );
	self notify( "hostage_on_knees" );
	self.hostage1.on_knees = 1;
	self.hostage1.anim_ent thread anim_loop_solo( self.hostage1, "underwater_idle", "stop_underwater_idle" ); 

}

hostage2_reacts_to_push_gets_interrogated()
{
	//self = struct
	self.hostage2 endon( "death" );
	self.hostage2.anim_ent notify( "stop_loop" );
	
	//self.hostage2.anim_ent thread debug_function();
	
	self.hostage2 StopAnimScripted();
	self.hostage2.anim_ent anim_single_solo( self.hostage2, "push_underwater" );
	//self.hostage2 StopAnimScripted();
	self.hostage2.anim_ent thread anim_loop_solo( self.hostage2, "interrogation" );
	//self.hostage2 thread debug_function();
}
/*
debug_function()
{
	while(1)
	{
		wtf = self waittill_any_return( "stop loop", "stop_loop" );
		IPrintLn( wtf );
	}
	
}
*/
hostage2_get_up_when_freed()
{
	self endon( "death" );
	
	//flag_wait( "waterfall_clear" );	
	helpup_trig = self;
	helpup_trig MakeUsable(); //the dude is the trig yo!
	actionBind = maps\jungle_ghosts::getActionBind( "player_helpup" );
	helpup_trig SetHintString(  actionbind.hint );
	//helpup_trig thread maps\jungle_ghosts_util::print3d_on_me("!");
	
	//helpup_trig thread notify_delay( "player_waited_too_long", 14 );
	//outcome  = helpup_trig waittill_any_return("trigger", "player_waited_too_long" );
	helpup_trig waittill("trigger");
	
	helpup_trig MakeUnusable();
	
	flag_set("player_rescued_hostage" );
	
	self.anim_ent notify( "stop_loop" );
	self notify( "stop_loop" );
	self StopAnimScripted();
	self.anim_ent anim_single_solo( self, "getup" );	
	self gun_recall();
	
	flag_wait("second_distant_sat_launch");
	
	river_blocker = get_target_ent("river_blocker");
	river_blocker ConnectPaths();
	river_blocker Delete();
	
	trigger_on("mid_stream", "targetname");
	trigger_on("waterfall_to_stream", "targetname");
}
/*
hostage1_get_up_when_freed()
{
	self endon( "death" );
	
	flag_wait( "waterfall_clear" );	
	//self.anim_ent notify( "stop_loop" );
	self notify( "stop_loop" );
	self StopAnimScripted();
	self anim_single_solo( self, "getup" );	
	self gun_recall();
	
}
*/
guard1_pushes_hostage1_underwate_interrogates_and_kills_hostage_2()
{
	//self = struct
	//self endon( "player_interupted" );
	self.guard1 endon( "death" );
	self.guard1.anim_ent notify( "stop_loop" );
	//self.guard1 StopAnimScripted();
	self.guard1.anim_ent anim_single_solo( self.guard1, "push_underwater" );
	//self.guard1 StopAnimScripted();
	flag_set("interrogtaion_started");
	self.guard1.anim_ent anim_single_solo( self.guard1, "interrogation" );
		
}


guard_executes()
{		
	/*
	if( isalive( self.hostage2 )  && isalive( self.guard1 ) )
	{
		//magicbullet( "ak47", self.guard1 geteye(), self.hostage2 geteye() );
		self.hostage2 notify( "stop_loop" );
		self.hostage2 StopAnimScripted();
		self.hostage2 stop_magic_bullet_shield();
		self.hostage2 die();
		self.guard1 StopAnimScripted();
		self notify ("hostage_shot");
		level.bravo = array_remove(  level.bravo, self.hostage2 );

	}
	else
	{
		IPrintLn( "cant execute. Guard or hostage not alive" );
	}
*/
}

scene_interupt_monitor()
{
	//self.scene_struct endon( "hostage_shot" );
	self thread magic_bullet_shield();
	flag_wait("player_at_execution");
	self thread stop_magic_bullet_shield();
	outcome = self waittill_any_return("damage", "bulletwhizby");	
	self.scene_struct notify( "player_interupted", self.script_noteworthy );
	
	
	if( isalive( self ) && self.script_noteworthy =="guard1" )
	{
		if( outcome == "damage" )
		{
			self StopAnimScripted();
			// added this so that it will support notetracks -Carlos
			self.anim_ent notify( "stop_loop" );
			self notify( "stop_loop" );			
			self.noragdoll = true;
			self.a.nodeath = true;
			self.allowdeath = true;
			self anim_single_solo( self, "waterfall_death" );
			self.noragdoll = true;
			self.a.nodeath = true;
			self.allowdeath = true;
			self kill();
		}
		else
		{
			self StopAnimScripted();
			self gun_recall();
		}
	}	   
}

monitor_player_close()
{
	self waittill("trigger");
	self.scene_struct notify( "player_interupted", self.script_noteworthy );
}

friendlies_execute_enemies()
{	
	self waittill( "player_interupted", guard_noteworthy );
	killer = undefined;
	execution_delay = 4;
	
	trigger_off("mid_stream", "targetname");
	trigger_off("waterfall_to_stream", "targetname");
	
	if( !self.outcome_decided )
	{
		self.outcome_decided = 1;
			
		self thread execution_slowmo();

		wait .4;
		
		if( IsAlive( self.guard1 ) )
			magicbullet( level.alpha[0].weapon, level.alpha[0] gettagorigin( "tag_flash" ), self.guard1 geteye() );
		
		//wait( REACTION_TME );
		array_thread( level.alpha, ::set_baseaccuracy, 1000 );		
		self.execution_team = array_removeDead_or_dying( self.execution_team );
		array_thread( self.execution_team , ::set_ignoreall, 0 );
		array_thread( self.execution_team , ::set_ignoreme, 0 );
		//thread friendlies_attack_enemy_array( self.execution_team , level.alpha );
		array_call( self.execution_team , ::StopAnimScripted );
		
		flag_wait("waterfall_clear");
		
		wait 3;
		array_thread( level.alpha, ::set_baseaccuracy, 1 );	
		//array_thread( level.bravo, ::set_force_color, "b" );
		//array_thread( level.bravo, ::enable_ai_color );
		activate_trigger_with_targetname( "squad_covers_helpup" );
		wait 3;
		level.squad = array_combine( level.alpha, level.bravo );
		array_thread( level.squad, ::disable_ai_color );
		//level.alpha1 smart_radio_dialogue("jungleg_gs1_shitbakersnotgetting");	
	}
	
}

execution_slowmo()
{	
	level.player thread play_sound_on_entity( "weap_sniper_breathin" );
	level thread player_heartbeat();
	SetSlowMotion( 1, .5, .15 );
	
	//self waittill_any_timeout( 3, "hostage_shot", "waterfall_clear" );	
	wait 1;
	SetSlowMotion( .5, 1, .15 );
	level notify( "stop_player_heartbeat" );
	level.player thread play_sound_on_entity( "ui_camera_whoosh_in" );
		
}


player_heartbeat()
{
	level endon( "stop_player_heartbeat" );
	while ( true )
	{
		level.player PlayLocalSound( "breathing_heartbeat" );
		wait .5;
	}
}

slomo_sound_scale_setup()
{
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "local3", 0.0 );
	SoundSetTimeScaleFactor( "Mission", 0.0 );
	SoundSetTimeScaleFactor( "Announcer", 0.0 );
	SoundSetTimeScaleFactor( "Bulletimpact", .60 );
	SoundSetTimeScaleFactor( "Voice", 0.40 );
	SoundSetTimeScaleFactor( "effects2", 0.20 );
	SoundSetTimeScaleFactor( "local", 0.40 );
	SoundSetTimeScaleFactor( "physics", 0.20 );
	SoundSetTimeScaleFactor( "ambient", 0.50 );
	SoundSetTimeScaleFactor( "auto", 0.50 );	
}
/*
execution_fail_monitor()
{
	
	//self endon( "player_interupted" );
	self waittill("hostage_shot", guard_noteworthy );
	
//	guard = maps\jungle_ghosts_util::get_ai_by_noteworthy( guard_noteworthy );
//	guard endon ("death" );
	if( guard_noteworthy == "guard1" )
	{
		self.hostage1 StopAnimScripted();
		self.hostage1 stop_magic_bullet_shield();
		self.hostage1 die();
	}
	else
	{
		self.hostage2 StopAnimScripted();
		self.hostage2 stop_magic_bullet_shield();
		self.hostage2 die();		
	}	
	wait(2);
	missionFailedWrapper();
	
}


*/	

jungle_vo( start )
{
	while(!isdefined( level.alpha ) )
		wait .10;
	
	switch ( level.start_point )
	{
		case "default":
		case "parachute":
		case "jungle":
			
			flag_wait( "player_landed" );
			wait 2.5;
			
			if ( cointoss() )
					//Price: Rook, you ok? 
					level.alpha1 do_story_line( "jungleg_pri_rookyouok" );	
			else
					//Price: You all right mate?
					level.alpha1 do_story_line( "jungleg_pri_youallrightmate" );	
					
			wait 1;
			
			//Price: Everyone in one piece?
			level.alpha1 do_story_line( "jungleg_pri_everyoneinonepiece" );	
			
			//Price: Keegan, let's go. 
			level.alpha1 do_story_line( "jungleg_pri_keeganletsgo" );	
						
			flag_wait( "jump_start" );
			
			wait 2;
			//Price: Time for a bit of the oldschool, then.
			level.alpha1 do_story_line( "jungleg_gs1_silencerson" );		
			//level thread display_hint_timeout( "hint_silencer_toggle", 2 );
			wait 4;
			//Price: You'll need this.  It's ancient, but reliable.
			level.alpha1 do_story_line( "jungleg_gs1_wegottagetto" );	
			wait 0.5;
			//Overlord: Gamma team we have you on the grid. "Swicks" will be providing evac 2 clicks from your location.  Be advised enemy search parties already in your vicinity. 
			level.player play_sound_on_entity( "jungleg_hqr_gammateamwehave" );
			//Price: Copy that
			level.alpha1 do_story_line( "jungleg_gs1_copythat" );
			//Keegan: Looks like we're getting' wet. 
			level.alpha2 do_story_line( "jungleg_gs2_lookslikeweregetting" );
			wait(1);
			flag_set("first_distant_sat_launch");
			
			wait 2;
			//Elias: Did you hear that?
			level.alpha1 thread add_dialogue_line( "Elias", "You hear that?" );
			wait (1);
			//Keegan: Yeah, felt it too. Let's get going.
			level.alpha2 thread add_dialogue_line( "Keegan", "Yeah, felt it too. " );			
			wait (1);
					
			flag_wait( "jungle_entrance_approach" );
			
		case "jungle_corridor":
		case "e3":	
			level.alpha1 SetLookAtEntity( level.player );
			//Price: Stay low. Use the brush for cover. The green dots on your motion tracker are us. 
			level.alpha1 do_story_line( "jungleg_gs1_staylowanduse" );
			wait 0.25;
			level.alpha1 SetLookAtEntity();
			//Price: Lead the the way, we'll be behind you. 
			//Price: Lead on. North-West. 
			//Price: We're following you. Take point.
			level.alpha1 thread do_nags_til_flag( "jungle_entrance", 3, 5, "jungleg_gs1_leadthetheway",  "jungleg_gs1_leadonnorthwest", "jungleg_gs1_werefollowingyoutake" );
			
			flag_wait( "jungle_entrance" );
			wait( 2 );
			//Price: Unless we're spotted, we'll only engage targets when you do. 
			level.alpha1 do_story_line( "jungleg_gs1_unlesswerespottedwell" );
			//level thread display_hint_timeout( "hint_silencer_toggle", 4 );
			wait( 3 );
			level.vo_activity = 0;
			array_thread( level.alpha, ::dynamic_vo_manager );
			level.alpha1 delaythread( 1, ::inactivity_monitor );
			
			wait 1;
			level thread player_target_detection();
						
		case "jungle_hill":	
						
			//battlechatter_on( "allies" );		
			flag_wait( "crash_arrive" );
			if ( !flag( "_stealth_spotted" ) )
			{
				//Keegan: That doesn't look like search and rescue..
				level.alpha2 do_story_line( "jungleg_gs2_thatdoesntlooklike" );
				wait 1;
				//Price: Anyone got eyes on Baker or Diaz?
				level.alpha1 do_story_line( "jungleg_gs1_anyonegoteyeson" );
				wait 2;
				//Keegan: (searching..)mmm..negative
				level.alpha2 do_story_line( "jungleg_gs2_searchingmmmnegative" );
				wait 2;
				//Price: C'mon, we gotta search for survivors. 
				level.alpha2 do_story_line( "jungleg_gs1_cmonwegottasearch" );
			}
			
			flag_wait_any( "hill_clear", "hill_pos_6" );
			//Alpha Team 1: C'mon, top of the hill, let's move!
			level.alpha1 do_safe_radio_line( "jungleg_at1_topofthehill" );
			
			flag_wait("waterfall_approach");
			 play_sound_in_space( "SP_0_stealth_alert", ( -1379.3, 2022.6, 255.5), 1 );
			thread play_sound_in_space( "SP_0_stealth_alert", ( -1379.3, 2022.6, 255.5), 1 );
			//IPrintLnBold( "< sounds of a struggle >" );
			//wait(2);
			//level.alpha1 dialogue_queue( "jungleg_at1_soundsbad" );
			
		case "waterfall":	
			flag_wait( "waterfall_trig" );
			//Price: Take the shot…
			level.alpha1 do_story_line( "jungleg_gs1_wegottamovein" );
			
			flag_wait( "player_rescued_hostage" );
			wait 2;
			//Merrick: ( Coughing - catching breath.)  What took you so long?
			level.baker thread smart_dialogue( "jungleg_bkr_coughingcatchingbreath" );
			wait 2;
			//Price: You're welcome.
			level.alpha2 smart_dialogue( "jungleg_gs2_sorrytobustup" );
			wait 0.5;
			//Hesh: So what's the plan?
			level.diaz smart_dialogue( "jungleg_diz_whatstheplan" );
			wait 0.25;
			//Price: Your comms up?
			level.alpha1 smart_dialogue( "jungleg_gs1_evac1clickout" );
			wait 0.4;
			//Hesh: Signal's shitty, but it works.
			level.alpha2 smart_dialogue( "jungleg_gs2_swicks" );
			wait 0.25;
			//Hesh: Rog'.
			level.diaz smart_dialogue( "jungleg_diz_soweregoinswimming" );
			wait 0.5;
			//Hesh: Whiplash Main, this is Ghost One-Three.  We are six klicks from Grid Two Seven Seven Nine.  Need immediate evac at Black LZ Three Echo Charlie.  How copy?
			level.alpha2 smart_dialogue( "jungleg_gs2_yepyouguysup" );
			wait 0.2;
			//Price: OK, on me. Let's go.
			level.alpha1 smart_dialogue( "jungleg_gs1_okonmelets" );
			
			flag_set("second_distant_sat_launch");
			
			wait (1);
			//Elias: There it is again.
			level.alpha1 thread add_dialogue_line( "Elias", "There it is again..."  );
			wait 1.2;
			//Merrick: We've heard those going off pretty regularly.
			level.baker thread add_dialogue_line( "Merrick", "We've heard a few of those going off pretty regularly." );
			wait 2.2;
			//Hesh: Some sort of missile launch?
			level.alpha2 thread add_dialogue_line( "Hesh", "Some sort of missile launch?" );
			wait 1.2;
			//Keegan: I have a feeling we're going to find out.
			level.diaz thread add_dialogue_line( "Keegan", "I have a feeling we're going to find out." );
			wait 1.5;
			
	}
}


dynamic_vo_manager()
{
	//This is handles the vo the friendlies say in the jungle. Its based off notifies and is supposed to prevent stacking and spamming
	level endon( "waterfall_clear" );
	level endon( "waterfall_approach" );
	self endon("death");	// added due to some undefined weirdness`
	
	self.is_speaking = 0;
	my_prefix = undefined;
	
	if( self == level.alpha1 )
	{
		my_prefix = "gs1";
		self.time_between_move_lines = 180000;
		self.first_moveup_line = 0;
	}
	else
	{
		my_prefix = "gs2";
		self.time_between_move_lines = 160000;
		self.first_moveup_line = 1;
	}
	
	self.kill_lines = [ "jungleg_"+my_prefix+"_theyredown", "jungleg_"+my_prefix+"_niceletskeepit" ];
	self.kill_lines = array_randomize( self.kill_lines );
	self.kill_lines_index = 0;
	
	self.move_lines = [ "jungleg_"+my_prefix+"_werewithyou", "jungleg_"+my_prefix+"_onyou", "jungleg_"+my_prefix+"_maintaininginterval", "jungleg_"+my_prefix+"_movingwithyou" ];
	self.move_lines = array_randomize( self.move_lines );
	self.move_lines_index = 0;
	
	self.spotted_lines = ["jungleg_"+my_prefix+"_hesmine", "jungleg_"+my_prefix+"_igotthisone", "jungleg_"+my_prefix+"_hesgoteyeson" ];
	self.spotted_lines = array_randomize( self.spotted_lines );
	self.spotted_lines_index = 0;
	
	self.enemy_close_lines = ["jungleg_"+my_prefix+"_staylowwww", "jungleg_"+my_prefix+"_hesgettinawfullyclose", "jungleg_"+my_prefix+"_staylow" ];
	self.enemy_close_lines = array_randomize( self.enemy_close_lines );
	self.enemy_close_lines_index = 0;
	
	//new soundaliase naming due to character change from here down \/\/\/\/\/\/
	if( my_prefix == "gs1" )
		my_prefix = "pri";
	else
		my_prefix = "kgn";
	
	self.player_kill_lines = ["jungleg_"+my_prefix+"_goodshot", "jungleg_"+my_prefix+"_nice", "jungleg_"+my_prefix+"_yougotem", "jungleg_"+my_prefix+"_nicehit", "jungleg_"+my_prefix+"_hesdown", "jungleg_"+my_prefix+"_targetdown", "jungleg_"+my_prefix+"_targetneutralized", "jungleg_"+my_prefix+"_droppedhim", "jungleg_"+my_prefix+"_hesdone", "jungleg_"+my_prefix+"_tangodown", "jungleg_"+my_prefix+"_hes86d", "jungleg_"+my_prefix+"_next", "jungleg_"+my_prefix+"_goodhit" ];// FIX spelling in alias!
	self.player_kill_lines = array_randomize( self.player_kill_lines );
	self.player_kill_lines_index = 0;
	
	//jungleg_pri_goodshot jungleg_pri_nice jungleg_pri_goodhit jungleg_pri_yougotem jungleg_pri_nicehit jungleg_pri_hesdown jungleg_pri_targetdown jungleg_pri_targetneutralized
	//jungleg_pri_droppedhim jungleg_pri_hesdone jungleg_pri_tangodown jungleg_pri_hes86d jungleg_pri_next
	
	level.time_between_enemy_lines = 20000;
	self.time_between_kill_lines = 10000;	
	self.time_between_target_ready_lines = 20000;
	level.time_between_enemy_close_lines = 35000;
	
	self.kill_confirm_time = 0;
	self.player_kill_confirm_time = 0;
	self.move_confirm_time =0;
	self.enemy_alert_time = 0;
	self.target_ready_time = 0;
	level.enemy_close_time = 0;
	
	self.first_kill_line = 1;
	self.first_target_ready_line = 1;
	level.first_enemy_close_line = 1;
		
	level.vo_activity = 0;	
	
	delay = .5;
	buffer_time = 1; //2.5
	
	while(1)		
	{	
		self.is_speaking = 0;
		
		msg = self waittill_any_return( "player_kill", "friendly_kill", "with_player", "enemy_close",  "friendly_spotted", "player_has_target"  );		
		
		self.is_speaking = 1;

		if( msg != "player_kill" && level.vo_activity == 1 )//I want player kill line to play everytime
			continue;
								
		new_time = gettime();	
		
		switch ( msg )
		{
			case "friendly_kill":	
				wait( delay  );
				
				if( self.kill_lines_index > self.kill_lines.size -1 )
						self.kill_lines_index = 0;
				
				wait .25;
				do_safe_radio_line( self.kill_lines[ self.kill_lines_index ] );				
				self.kill_lines_index++;
					
				self.kill_confirm_time = gettime();
				wait( buffer_time );									
				continue;
				
			case "player_kill":	
				wait( delay  );
				
				if( self.player_kill_lines_index > self.player_kill_lines.size -1 )
						self.player_kill_lines_index = 0;
				
				if(!flag( "_stealth_spotted" ) )
				{
					smart_radio_dialogue_interrupt( self.player_kill_lines[ self.player_kill_lines_index ] ); //doing the interupt cuz I want this to always play
					self.player_kill_lines_index++;
				}
					
				self.player_kill_confirm_time = gettime();
				wait( buffer_time );									
				continue;	
				
			case "with_player":		
				//just say it the first time, dont check for time passed					
				if( self.first_moveup_line == 1 )
				{
					self.first_moveup_line = 0;						
					do_safe_radio_line( self.move_lines[ self.move_lines_index ]  );
					self.move_lines_index++;	
					self.move_confirm_time = gettime();
					wait( buffer_time );							
				}
				else if( new_time - self.move_confirm_time >= self.time_between_move_lines )
				{
					if( self.move_lines_index > self.move_lines.size -1 )
						self.move_lines_index = 0;
					
					do_safe_radio_line( self.move_lines[ self.move_lines_index ] );
					self.move_lines_index++;
					self.move_confirm_time = gettime();
					wait( buffer_time );					
				}

				continue;
				
			case "enemy_close":		
				//just say it the first time, dont check for time passed					
				if( level.first_enemy_close_line == 1 )
				{
					level.first_enemy_close_line = 0;	
					level.enemy_close_time = gettime();
					do_safe_radio_line( random( self.enemy_close_lines ) );										
					self.enemy_close_lines_index++;
					wait( buffer_time );							
				}
				else if( new_time - level.enemy_close_time >= level.time_between_enemy_close_lines )
				{
					level.enemy_close_time = gettime();
					
					if( self.enemy_close_lines_index > self.enemy_close_lines.size -1 )
						self.enemy_close_lines_index = 0;
					
					do_safe_radio_line( self.enemy_close_lines[ self.enemy_close_lines_index ]  );
					self.enemy_close_lines_index++;
					wait( buffer_time );					
				}
	
				continue;	
				
			case "friendly_spotted":		
				if( new_time - self.enemy_alert_time >= level.time_between_enemy_lines )
				{
					if( self.spotted_lines_index > self.spotted_lines.size -1 )
						self.spotted_lines_index = 0;
					
					do_safe_radio_line( self.spotted_lines[ self.spotted_lines_index ] );
					self.spotted_lines_index++;
					self.enemy_alert_time = gettime();
					wait( buffer_time );				
				}
				continue;
			
			case "player_has_target":							
				if( self.first_target_ready_line == 1 )
				{
					self.first_target_ready_line = 0;						
					my_line = self get_my_enemy_count_line( level.enemies_near_target.size );		
					//this was playing sometimes as the player fired so doing a check first
					if( !level.player IsFiring() )
					{
						do_safe_radio_line( my_line );							
						self.target_ready_time = gettime();
						wait( buffer_time );	
					}						
				}
				else if( new_time - self.target_ready_time >= self.time_between_target_ready_lines )
				{
					my_line = self get_my_enemy_count_line( level.enemies_near_target.size );
					//this was playing sometimea as the player fired so doing a check first
					if( !level.player IsFiring() )
					{
						do_safe_radio_line( my_line );	
						self.target_ready_time = gettime();
						wait( buffer_time );	
					}						
				}
				
				//self.is_speaking = 0;
				//level.vo_activity = 0;		
				
			default:			
				continue;
		}
				
	}

}	
	
inactivity_monitor()
{
	// 15 secs of no VO = play one of these. Ends when they run out or _stealth_spotted
	level endon("_stealth_spotted");
	level endon("hill_pos_1");

	//Price: Any movement on the motion-tracker?
	//Price: You getting a signal on that thing?
	//Price: Stay frosty.
	//Price: You hear something?
	//Price: It's too quiet. 
	//Price: Anyone got eyes on?
	//Price: Keep it tight people.
	//Price: Watch each other's six.
	level.inactivity_lines = [ "jungleg_gs1_anymovementonthe", "jungleg_gs1_yougettingasignal", "jungleg_pri_stayfrosty", "jungleg_pri_youhearsomething", "jungleg_pri_itstooquiet", "jungleg_pri_anyonegoteyeson", "jungleg_pri_keepittightpeople",  "jungleg_pri_watcheachotherssix" ];
	level.inactivity_lines = array_randomize( level.inactivity_lines );
		
	inactivity_time = 15000;
		
	while( 1 )
	{
		level.inactivity_time = gettime();
		
		while( level.vo_activity == 0 )
		{
			new_time = gettime();
			
			if(  new_time - level.inactivity_time >= inactivity_time )
			{
				if( !level.player isFiring() && level.vo_activity == 0 )
				{
					the_line = random( level.inactivity_lines );
					
					if( !level.player ent_flag( "recently_fired_weapon" ) )
						self do_safe_radio_line( the_line );
					
					level.inactivity_lines = array_remove( level.inactivity_lines, the_line );
					
					if( level.inactivity_lines.size == 0 )
						return;
					
					level.inactivity_time = GetTime();			
				}	
			}
			wait .10;	
		}
		wait 1;	
	}	
}



do_safe_radio_line( the_line )
{	
	if( !flag("_stealth_spotted" ) && !flag( "doing_story_vo" ) )
	{ 
		level.vo_activity = 1;				
		//self.is_speaking = 1;	
		
		self smart_radio_dialogue( the_line );	
		
		level.vo_activity = 0;				
		//self.is_speaking = 0;	
	}
}

do_story_line( the_line )
{
	flag_set( "doing_story_vo" );
	//level.vo_activity = 1;		
	radio_dialogue_stop();
	self  smart_radio_dialogue( the_line );	
	//level.vo_activity = 0;		
	flag_clear( "doing_story_vo" );	
}

get_my_enemy_count_line( enemy_count )
{
	if( !isdefined( enemy_count ) )
		return;
	
	if( self == level.alpha1 )
		my_prefix = "gs1";
	else
		my_prefix = "gs2";
	
	my_line = "jungleg_" +my_prefix+ "_iseeem";
	
	switch ( enemy_count )
	{
		case 1:
			//if( cointoss() )
				my_line = "jungleg_" +my_prefix+ "_iseeem";
			//else
				//my_line = "jungleg_" +my_prefix+ "_firingonyourgo";
			break;
			
		case 2:
			my_line = "jungleg_" +my_prefix+ "_carefultherestwoof";
			break;	
			
		case 3:
			my_line = "jungleg_" +my_prefix+ "_iseethreeof";
			break;	
			
		case 4:
			my_line = "jungleg_" +my_prefix+ "_lookslike4tangos";
			break;		
			
		case 5:
			my_line = "jungleg_" +my_prefix+ "_lookslike5of";
			break;		
	
		default:
			my_line = "jungleg_" +my_prefix+ "_iseeem";						
			break;
	}	
	
	return my_line;
}

notify_squad_on_corpse_or_spotted()
{
	//NOT BEING RUN CURRENTLY
	level endon( "waterfall_clear" );
	level endon( "waterfall_approach" );
	toggle = 0;
	
	while(1)
	{
		msg = level waittill_any_return( "enemy_stealth_reaction",  "_stealth_found_corpse" );		

		if( !flag( "_stealth_spotted" ) )
		{
			if( toggle == 0 )
			{
				level.alpha1 notify( msg );
				toggle = 1;
			}
			else
			{
				level.alpha2 notify( msg );
				toggle = 0;
			}
		}
	}
			
}
