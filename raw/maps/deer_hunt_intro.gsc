#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\deer_hunt_util;
#include maps\_vehicle;
#include maps\_stealth_utility;
#include maps\deer_hunt_color_system;
#include maps\_utility_dogs;

CONST_TIME_BEFORE_SHADOW_CHASERS = 2;
CONST_TIME_BEFORE_SHADOW_CHASERS_HOT = 7;
DELAY_BEOFRE_ATTACK_GUARD_GOES_HOT = 1.8;
DELAY_BEFORE_DOG_ATTACK = .5;
DELAY_BEFORE_EXECUTION = 2;

intro_setup()
{
	thread move_player_to_start( "intro_player_start" );
	thread player_control();
	thread deer_init();
	thread lobby_ruckus();	
	thread intro_enemies();
	thread intro_music();
	
	thread setup_friendlies();
	flag_wait("friendlies_spawned");
	thread intro_vo();
	
	//thread maps\_introscreen::introscreen(undefined, 9 );	
		
	trigs = GetEntArray( "deer_ruckus", "script_noteworthy");
	array_thread( trigs, ::deer_ruckus_trig_logic );
	
	flag_wait("pipe_enter");
	thread lariver_global_setup();
}


intro_stealth_settings()
{
	hidden = [];
	hidden[ "prone" ]	 = 70;//70
	hidden[ "crouch" ]	 = 300;//600 450
	hidden[ "stand" ]	 = 400;//1024
		
	spotted = [];
	spotted[ "prone" ]	 = 500; //512;
	spotted[ "crouch" ]	 = 1500; //5000;
	spotted[ "stand" ]	 = 2000; //8000;~
	
	maps\_stealth_utility::stealth_detect_ranges_set( hidden, spotted );

	array = [];
	array[ "player_dist" ] 		 = 600;//1500;// this is the max distance a player can be to a corpse
	array[ "sight_dist" ] 		 = 200;//1500;// this is how far they can see to see a corpse
	array[ "detect_dist" ] 		 = 100;//256;// this is at what distance they automatically see a corpse
	array[ "found_dist" ] 		 = 50;//96;// this is at what distance they actually find a corpse
	array[ "found_dog_dist" ] 	 = 50;//50;// this is at what distance they actually find a corpse

	maps\_stealth_utility::stealth_corpse_ranges_custom( array );
	level.stealth_spotted_time = 6;

}


player_control()
{
	level.current_speed_percent = 1;
	switch( level.start_point )
	{
	   case "default":
	   case"intro":
			guns = [ "acr_hybrid_silenced" ];
			arm_player( guns );
			
			level.player set_player_speed( .75 );
			SetSavedDvar( "player_sprintSpeedScale", 1.2 ); //default 1.5
			wait 1;
			
			/*
			level.player_flashlight = level.player spawn_tag_origin();
		
			//level.player_flashlight.origin = level.player GetTagOrigin( "tag_flash");	
			//level.player_flashlight.angles = level.player.angles;	
			
			level.player_flashlight.origin -= ( 0,0,64 );
			level.player_flashlight LinkToPlayerView( level.player, "tag_flash", ( 0, 0, 0), (0,0,0), false );	
			//level.player AddOnToViewModel( "tag_origin", "tag_flash", (0,0,0), ( 0,0,0 ) );
			//thread draw_line_from_ent_for_time( level.player_flashlight, (0,0,0), 1, 0, 0, 60 );
		
			PlayFXOnTag( getfx( "light3" ), level.player_flashlight, "tag_origin" );
			/*
			while(!isdefined( level.hesh ) )
				wait .05;
			
			level.hesh_flashlight = level.hesh spawn_tag_origin();
			level.hesh_flashlight.origin = level.hesh GetTagOrigin( "tag_flash" );	
			level.hesh_flashlight.angles = level.hesh GetTagAngles( "tag_flash" );		
			level.hesh_flashlight LinkTo( level.hesh, "tag_flash", ( 0, 0, 0), (0,0,0) );	
			PlayFXOnTag( getfx( "light2" ), level.hesh_flashlight, "tag_origin" );
			*/	
			
			flag_wait("screen_arrive");
			wait 2;
			level.player set_player_speed(.85);
		
		case "lobby":
		case "street":
		case "encounter1":
		case "encounter2":	
		case "lariver":
		case "ride":
	}
}


set_player_speed( percentage )
{
	level.current_speed_percent = percentage;
	level.player SetMoveSpeedScale( percentage );
}

intro_music()
{
	//SetDvar( "music_enable", 1 );
	music_on_flag( "screen_arrive", "mus_deer_hunt_theatre" );
	
	music_on_flag( "promenade_exit", "mus_deer_hunt_the_wall", .5 );	
}

intro_vo()
{
	
/*
deerhunt_els_team2sitrep
deerhunt_els_yourteamarethe
deerhunt_els_lastfederationscout
deerhunt_els_team2beadvised
deerhunt_eli_team2beadvised


deerhunt_hsh_chuckleyeahthatwas
deerhunt_hsh_stillzerocontactin
deerhunt_hsh_rogteam2out
deerhunt_hsh_copythatlifeguard
deerhunt_hsh_team2copiesall
deerhunt_hsh_lastfederationcontactwas

deerhunt_hsh_whatayagotcairo
deerhunt_hsh_eassssyboy
deerhunt_hsh_whoaboy
deerhunt_hsh_cmoncairosgotsomething
deerhunt_hsh_cairosgotascentlets

deerhunt_hsh_yourememberthelast
deerhunt_hsh_talkaboutarelic
deerhunt_hsh_idontcarehow
deerhunt_hsh_10yearssincethe
deerhunt_hsh_mmmmmmsomethingsupwith
deerhunt_hsh_onyou
deerhunt_hsh_onyourgo
deerhunt_hsh_idontlikethisss
deerhunt_hsh_damndeer
deerhunt_hsh_nicetoobadi
deerhunt_hsh_iftheyvebeenhere
deerhunt_hsh_checkyourcornersand
deerhunt_hsh_iswearsometimesit
deerhunt_hsh_lastintelwasargentina
deerhunt_hsh_cmonwegottakeep
deerhunt_hsh_illnevergetused
deerhunt_hsh_weretheonlyones
deerhunt_hsh_keeplowcmon
deerhunt_hsh_thisway
deerhunt_hsh_looksclear
deerhunt_hsh_seeanything
deerhunt_hsh_oneoftherods
deerhunt_hsh_youhearthatsomeones
deerhunt_hsh_hmmmthatdoesntsoundlike
deerhunt_hsh_waitforcairoif
deerhunt_hsh_holdyourfirecairo
deerhunt_hsh_standbyandwait
deerhunt_hsh_waitforcairoalt
deerhunt_hsh_theshadow
deerhunt_hsh_weaponsfree
deerhunt_hsh_whatthehellare
deerhunt_hsh_lifeguardthisisteam
deerhunt_hsh_conserveammowedont

*/

	switch( level.start_point )
	{
	  	case "default":
	   	case"intro":
			
			//wait 1;
			//Elias: Team 2- sitrep.
			//level.player smart_radio_dialogue( "deerhunt_els_team2sitrep" );
		//	
			//wait .15;
			//Hesh: Still zero contact in the last 4 hours. Almost done with our final sweep, ETA 1730 over. 
			level.hesh smart_radio_dialogue( "deerhunt_hsh_stillzerocontactin" );
			
			//Elias: Last Federation Scout sighting was your location so report on first contact over. 
			level.player smart_radio_dialogue( "deerhunt_els_lastfederationscout" );
			
			flag_set("intro_vo_done");
			
			hesh_radio_aknowledge();
			
			//hesh: We're the only ones patrolling this sector and we've got some ground to cover. 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_weretheonlyones" );
			
			//hesh:  C'mon, we gotta keep moving.
			level.hesh smart_dialogue_generic( "deerhunt_hsh_cmonwegottakeep" );
							
			wait(.5);
			//Hesh: Last Federation contact was months ago. I don't know what the old man's all worked up about. 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_lastfederationcontactwas" );
			
			flag_wait( "hallway_halfway" );
			wait 1.5;
			//Hesh: Eassssy boy. 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_eassssyboy" );
			
			//Hesh: C'mon, Cairo's got something…
			level.hesh smart_dialogue_generic( "deerhunt_hsh_cmoncairosgotsomething" );
					
			flag_wait( "through_screen" );
			
			//Hesh: Talk about a relic of the past…
			level.hesh smart_dialogue_generic( "deerhunt_hsh_talkaboutarelic" );
			
			wait 2;
			//Hesh: You remember the last movie you saw here?
			level.hesh smart_dialogue_generic( "deerhunt_hsh_yourememberthelast" );
			
			delayThread( 1.5, ::flag_set, "exit_theater" );
			//Hesh: 10 years since the rods? Feels like yesterday I was here eating popcorn. 
			//level.hesh smart_dialogue_generic( "deerhunt_hsh_10yearssincethe" );
			
			//hesh:  C'mon, we gotta keep moving.
			level.hesh smart_dialogue_generic( "deerhunt_hsh_cmonwegottakeep" );
			
			flag_wait( "theater_exit" );
		
			//Hesh: I don't like thisss…
			level.hesh smart_dialogue_generic( "deerhunt_hsh_idontlikethisss" );
				
			flag_wait( "to_lobby_entrance" );
					
		case "lobby":
		
			wait 2;
			hesh_says_on_you(); //random "on you" type line
			
			flag_wait("lobby_entrance");
			
		//TODO: get anim time of deer scene and wait that long
			wait 4;
			//Hesh: Damn deer…
			//level.hesh smart_dialogue_generic( "deerhunt_hsh_damndeer" );
			
			//Hesh: If they've been here we're probably alone. C'mon.
			level.hesh smart_dialogue_generic( "deerhunt_hsh_iftheyvebeenhere" );
							
			flag_wait( "lobby_exit" );
			
			autosave_by_name_silent( "theater_exit" );
			
			//Hesh: Check your corners and stay sharp. 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_checkyourcornersand" );
			
			wait( 3 );
			//Hesh: Last intel was Argentina finally joined the Federation. That's almost all of South America just waiting to bust through the wall.
			level.hesh smart_dialogue_generic( "deerhunt_hsh_lastintelwasargentina" );
			
		case "outside":	
			
			flag_wait( "deer_moved_away" ); //this gets set when tthe deer runs away at top of stairs. 
			
			//Hesh: I swear sometimes it feels like we're the intruders…
			level.hesh smart_dialogue_generic( "deerhunt_hsh_iswearsometimesit" );
								
			flag_wait("promenade_exit" );
			
			wait 1;
			//Hesh:  I'll never get used to seeing that thing. 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_illnevergetused" );
			
	case "street": 
			
			flag_wait("road_chasm_approach");
			
			//Hesh: See anything?
			level.hesh smart_dialogue_generic( "deerhunt_hsh_seeanything" );
			//Hesh: Looks clear.
			level.hesh smart_dialogue_generic( "deerhunt_hsh_looksclear" );
			
			flag_wait( "dropdown_arrive" );
			
			//Hesh: One of the Rod's hit not too far from here. These folks never had a chance. 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_oneoftherods" );
			
			flag_set( "hesh_to_shop_door" ); //hesh_logic is waiting for this to open the shop door
			
			autosave_by_name_silent( "shop_approach" );
			
			//Hesh: Keep low, c'mon.
			level.hesh smart_dialogue_generic( "deerhunt_hsh_keeplowcmon" );
			
	case "encounter1":
			
			flag_wait( "player_at_shop_door" ); //trig radius at door
			thread play_sound_in_space("stealth_2_huh", ( -13290.7, 14145.4, -212 ) ); //enemy chatter
			wait 1.5;
			
			//Hesh:  You hear that? Someone's out there.
			level.hesh smart_dialogue_generic( "deerhunt_hsh_youhearthatsomeones" );
			
			thread play_sound_in_space("stealth_2_huh", ( -13290.7, 14145.4, -212 ) ); //enemy chatter
			//wait 1.5;
			
			//Hesh: hmmm..that doesn't sound like civilians. 
			//level.hesh smart_dialogue_generic( "deerhunt_hsh_hmmmthatdoesntsoundlike" );
									
		
			
			flag_wait( "shop_exit" );
			
			autosave_by_name( "encounter1_approach" );
			
			//Hesh: mmmmmm..something's up with Cairo. Stay frosty.
			//level.hesh smart_dialogue_generic( "deerhunt_hsh_mmmmmmsomethingsupwith" );
			
			//flag_wait( "player_at_encounter1" );
			
			//Hesh: The shadow.
			//level.hesh smart_dialogue_generic( "deerhunt_hsh_theshadow" );
			
			//flag_wait("player_sees_shadow"); //
			
			//Hesh: Cairo - up!
			//level.hesh smart_dialogue_generic( "deerhunt_hsh_cairoup" );
			
			//wait 2;
			//Hesh: Wait for Cairo. If he attacks the target, shoot to kill. 
			//level.hesh smart_radio_dialogue( "deerhunt_hsh_waitforcairoif" );
			
			//flag_wait( "shadow_guy_dead" );
			//Hesh: Hold your fire. Cairo will draw them out. 
			//level.hesh smart_radio_dialogue( "deerhunt_hsh_holdyourfirecairo" );
			
			//flag_wait( "hesh_attacks_shadow_guys" );
			//hesh_says_on_you();
			
			//flag_wait("shadow_chasers_hot");
			//Hesh: Weapons free. 
			flag_wait("dog_kill_started");
			wait( 1 );
			
			level.hesh smart_radio_dialogue( "deerhunt_hsh_weaponsfree" );
		
			
			flag_wait( "dog_attack_enemies_dead" ); //script_deathflag on spawners
			
			wait 2;
			//Hesh: What the hell are they doing so close to the wall? 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_whatthehellare" );
			
			//Hesh: Lifeguard this is Team 2. We've got confrimed contact with Federation Scouts. Requesting backup over. 
			level.hesh smart_radio_dialogue( "deerhunt_hsh_lifeguardthisisteam" );
			
			//Elias: Team 2 be advised ODA squad 627 en route to your position. Continue with your sweep over. 
			//level.player play_sound_on_entity( "deerhunt_eli_team2beadvised" );
			
			//hesh_radio_aknowledge();
			
		case "encounter2":	
			level thread intro_vo_player_enters_gas_station();
			level thread intro_vo_pipe_callout();
				
			flag_wait( "hesh_to_lookout" );
			
			//autosave_by_name( "gas_station_approach" );
			
			//Hesh: Conserve ammo. We don't know how many more there are. 
			//level.hesh smart_dialogue_generic( "deerhunt_hsh_conserveammowedont" ); //TODO remove radio processing
			
			//flag_wait( "hesh_to_lookout" );
			
				
			wait 1;
			//Hesh: I see one on the roof. C'mon let's get a closer look. 
			level.hesh smart_radio_dialogue( "deerhunt_hsh_iseeoneon" );
				
			flag_wait( "player_dropped_down" );
			
			wait( 4 );
			//Hesh: There's a back entrance if you want to flank right. Your call. 
			level.hesh smart_radio_dialogue( "deerhunt_hsh_theresabackentrance" );
			
			wait( 1 );
			if ( !flag( "gas_station_open_fire" ) )
	
				//Hesh: Weapons free on your go.
				level.hesh smart_radio_dialogue( "deerhunt_hsh_weaponsfreeonyour" );
						
			flag_wait( "gasstation_clear");
			
			wait 2;
			
			//Hesh: This is just the begining. More are coming. A lot more. 
			level.hesh smart_dialogue_generic( "deerhunt_hsh_thisisjustthe" );
			//Hesh: C'mon let's move!
			level.hesh smart_dialogue_generic( "deerhunt_hsh_cmonletsmove" );
			
			flag_wait( "to_pipe" );
			
			//Squad 627 Leader: Team 2 this is ODA 627. We've got eyes on a large group of federation approaching the LA River checkpoint. What's your ETA, over. 
			level.player play_sound_on_entity( "deerhunt_sql_team2thisis" );
			
			//Hesh: Team 2 copies all.
			//level.hesh smart_radio_dialogue( "deerhunt_hsh_team2copiesall" );
			//Hesh: We're approaching you now from the north east.
			level.hesh smart_radio_dialogue( "deerhunt_hsh_weareapproachingyou" );
			
			flag_wait("pipe_enter" );
			autosave_by_name( "pipe_enter" );
				
		case "lariver":
			
			flag_wait( "pipe_halfway" );
			
			//Squad 627 Leader: Team 2 friendlies at your 12'clock! 
			level.player play_sound_on_entity( "deerhunt_sql_team2friendliesat" );
			
			flag_wait( "pipe_exit" );			
			//Squad 627 Leader: Let's go let's go!
			level.player play_sound_on_entity( "deerhunt_sql_letsgoletsgo" );
			
							
		case "ride":
			
			
			
	}
	
/*
deerhunt_hsh_theyresettinupshop
deerhunt_hsh_theresabackentrance
deerhunt_hsh_cairocantakeout
deerhunt_hsh_cairoup
deerhunt_hsh_goodthinkingillflank
deerhunt_hsh_weaponsfreeonyour
deerhunt_hsh_thatpipeleadsto
deerhunt_hsh_thisisjustthe
deerhunt_hsh_cmonletsmove
deerhunt_hsh_weareapproachingyou


deerhunt_sql_team2thisis
//Squad 627 Leader: Team 2 friendlies at your 12'clock! 
""
deerhunt_sql_letsgoletsgo*/
	
}

intro_vo_player_enters_gas_station()
{
	level endon( "gas_station_open_fire" );
	
	flag_wait( "gas_station_enter" );

	//Hesh: Good thinking. I'll flank left. 
	level.hesh smart_radio_dialogue( "deerhunt_hsh_goodthinkingillflank" );
	
}

intro_vo_pipe_callout()
{	
	level endon( "gas_station_open_fire" );
	
	flag_wait("hill_pos2");
	
	//Hesh: They're settin up shop right here. 
	level.hesh smart_radio_dialogue( "deerhunt_hsh_theyresettinupshop" );
	//Hesh: That pipe leads to the LA river.
	level.hesh smart_radio_dialogue( "deerhunt_hsh_thatpipeleadsto" );
}


flashlight_on()
{	
	wait 1;
	self endon( "death" );
	
	//level.flashlight_guy = self;
	//self.deathfunction = ::flashlight_off;	
	self.flashlight_tag_origin = self spawn_tag_origin();
	self.flashlight_tag_origin.origin = self GetTagOrigin( "tag_flash" );	
	self.flashlight_tag_origin.angles = self GetTagAngles( "tag_flash" );	
	wait(.05);
	self.flashlight_tag_origin LinkTo(self, "tag_flash");//j_head
	
	wait(.10);
	PlayFxOnTag( getfx("flashlight"), self.flashlight_tag_origin, "tag_origin");
}

flashlight_off()
{
	if(isdefined( self.flashlight_tag_origin ) )
		StopFXOnTag( getfx("flashlight"), self.flashlight_tag_origin, "tag_origin");
	
}


setup_friendlies()
{

	getent( "hesh", "targetname" ) add_spawn_function( ::hesh_logic );
	level.hesh = spawn_targetname( "hesh", 1 );
	
	getent( "dog", "targetname" ) add_spawn_function( ::dog_logic );
	level.dog = spawn_targetname( "dog", 1 );
	
	level.squad = [level.hesh, level.dog];
	
	//level.hesh thread maps\_stealth_utility::stealth_default();

	battlechatter_off( "allies" );
	flavorbursts_off( "allies" );
	
	flag_set( "friendlies_spawned" );
	level thread sniff_system_init();
	
	array_spawn_function_targetname( "team2", ::lariver_team2_logic );
	
	flag_wait( "road_chasm_approach" );
	
	level.team2 = array_spawn_targetname( "team2" );
	random( level.team2 ).colornode_setgoal_func= ::hesh_does_360;
	
	flag_wait("player_out_of_chasm");
	
	blocker = getent( "dropdown_blocker", "targetname" );
	blocker.origin += (0,0,400);
	blocker ConnectPaths();
	wait(.05);
	blocker delete();
	
	array_thread( level.team2, ::cqb_off_sprint_on );
	
	flag_wait("dog_kill_ended");
	
	
	
}

sniff_system_init()
{
	while(!isdefined( level.dog ) )
		  wait .05;
	
	//cant check isTouching with structs so spawn temp script_origins	
	structs = getstructarray( "dog_sniff", "targetname" );
	foreach( s in structs )
	{
		temp = spawn ( "script_origin", s.origin );
		temp.targetname = "dog_sniff";
	}
	
	temp_origins = getentarray( "dog_sniff", "targetname" );
	volumes = getentarray( "sniff_zone", "script_noteworthy" );
	
	//have each volume keep track of which spots are inside of them
	foreach( v in volumes )
		v sniff_assign_structs_to_volume( temp_origins );
	
	level.current_sniff_zone = undefined;
	sniff_trigs = getentarray( "sniff_trig", "targetname" );
	array_thread( sniff_trigs, ::sniff_trig_logic );
	
	//delete the script_origins!
	array_call( temp_origins, ::delete );

}


sniff_trig_logic()
{
	while(1)
	{
		self waittill("trigger");
		trig_volume =  getent( self.target, "targetname" );
		
		if( !isdefined( level.current_sniff_zone ) )
			level.current_sniff_zone = trig_volume;
		
		else if( level.current_sniff_zone == trig_volume ) 
		{
			wait 2;
			continue;
		}
	
		level.current_sniff_zone = trig_volume;
		level.dog disable_dog_sniff();
		level.dog thread dog_sniff_spots( level.current_sniff_zone.sniff_spots );
		wait 2;
	}
}


sniff_assign_structs_to_volume( script_origin_array )
{	
	//self = volume
	self.sniff_spots = [];	
	foreach( i, t in script_origin_array )
	{
		if( t istouching( self ) )
		{
			self.sniff_spots[i] = t.origin;		
		}		
	}	
}


dog_logic()
{
	getent( "teleport_dog", "targetname" ) thread dog_teleport_trig_logic();
	//level init_dog_anims();	   
	self endon( "deleted" );
	self.animname = "generic";
	self.meleeAlwaysWin = true;
	self.ignoreme = 1;
	self thread magic_bullet_shield();
	self.script_nobark = 1;
	self disable_ai_color();
	self SetDogHandler( level.player );
	self ignore_me_ignore_all();
	self.goalradius = 32;
	//self thread dog_stays_in_front_of_player();
	
	
	switch ( level.start_point )
	{
		case "default":
		case "intro":
			
			flag_wait("to_theater_exit" );
			
			wait 2;
			dog_blocker = getent( "dog_blocker", "targetname" );
			dog_blocker.origin +=( 0,0,500 );
			dog_blocker connectpaths();
			
//			wait 1;
//			activate_trigger_with_targetname( "dog_pos1" );
//			
//			wait 4;
//			//flag_wait("flare_down");
//		
			//self set_dog_walk_anim();
//			//self set_run_anim( "sniff" );
//			
//			flag_wait("to_theater_exit");
//			self clear_generic_run_anim();
//			
//			wait 1.5;
//			self set_dog_walk_anim();
			//self set_run_anim( "sniff" );
			
		case "lobby":
			
//			flag_wait("lobby_entrance");
//			self clear_generic_run_anim();
//			
//			flag_wait("lobby_exit_approach");
			//self set_run_anim( "sniff" );
			
		case "outside":
		case "street":
			flag_wait("promenade_exit");
			
			//flag_wait( "road_chasm_approach" );
			self notify( "stop_sniffing" );
			self disable_dog_sniff();
			
			node = getnode( "dog_stay", "targetname" );
			self setgoalnode( node );
			
			flag_wait("hesh_to_shop_door");
			self notify( "stop_sniffing" );
			self disable_dog_sniff();
			self enable_ai_color();
			//wait 1;
			//self.colornode_setgoal_func =::dog_waits_before_crossing_chasm;
			//self set_dog_walk_anim();
			//self set_run_anim( "sniff" );
			//self enable_ai_color();
			
		case "encounter1":	
			flag_wait("player_out_of_chasm" );

			wait 2;
			self dog_growl();
		
			//flag_wait("player_at_shop_door" );
			wait 1;
			//self set_dog_walk_anim();
			//self set_run_anim( "sneak_walk" );
			
			flag_wait( "shop_exit" );
			//self clear_generic_run_anim();
			
			
			
//			flag_wait("player_at_encounter1");
//						
//			flag_wait_or_timeout( "player_sees_shadow", 8 ); //lookat trig
//			if( !flag( "player_sees_shadow" ) ) //might be timeout so set it for other funcs waiting for it
//				flag_set ("player_sees_shadow" );
//			
//			activate_trigger_with_targetname( "dog_to_shadow_guy" );
//						
//			self waittill("teleported");
//			wait 1.5;
			
			//self set_dog_walk_anim();
			//self set_run_anim( "sniff" );
			
			//activate_trigger_with_targetname("encounter1_dog_to_cover" );
			//self clear_generic_run_anim();
			

			
		case "encounter2":		
			//self ignore_me_ignore_all();
			
			//self set_dog_walk_anim();
			//self set_run_anim( "walk" );
			
			//flag_wait("player_approaches_gasstation"); // trig so no flag_init
			//self clear_generic_run_anim();
			//self thread dog_gasstation_logic();
			//self SetGoalEntity( level.roof_guy );
			//self enable_ai_color();
			
		case "lariver":
//			self ignore_me_ignore_all();
//			self.attackradius = 64;
		
		case "ride":
	}
	
	
}

FAR_FROM_GOAL = 75;//150
dog_stays_in_front_of_player()
{

	self ent_flag_init( "override_follow_logic" );
	self endon( "stop_following_player" );
	self.goalradius = 32; 
	self.animname = "generic";
	self SetDogHandler( level.player );
	//setup the target ent that is linked to the player.
	angles = level.player getplayerangles();
	angles = ( 0, angles[1], 0 );
	fwd = anglestoforward( angles );
	front = (fwd) * 375; //200, 240

	in_front_of_player = level.player.origin + front;

	level.target_ent = spawn("script_origin",  in_front_of_player );
	level.target_ent.angles = ( 0, angles[1], 0 );
	level.target_ent linkto( level.player );
	
	//thread draw_line_from_ent_to_ent_for_time( level.target_ent, level.dog, 0, 0, 1, 600 );
	sniff_structs = getstructarray( "sniff_spots", "targetname" );
	
	self disable_dog_sniff();
	while( 1 )
	{
		if( self ent_flag( "override_follow_logic" ) )
		{
			wait(.10);
			continue;
		}
		ground_pos = groundpos( level.target_ent.origin);
		dist = distance2d( self.origin, ground_pos );
		print3d( ground_pos, "OMG" );
		if( dist >  FAR_FROM_GOAL )
		{			
			self notify( "moving_up");
			//IPrintLn( "Moving up");
			//self  disable_dog_sniff();
			sniff_spots = get_array_of_closest( ground_pos, sniff_structs, undefined, 5, 200, 0 );
			if( array_is_greater_than( sniff_spots, 0 ) )
			{
				thread dog_sniff_spots( sniff_spots );
			}
			else			
			{
				IPrintLn( "No sniff spots" );
				self setgoalpos( ground_pos );
			}
			
			timeout = 6;
			
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
			
			IPrintLn( "Moving up because of " +decision );
			//self disable_dog_sniff();
		}
		wait(.15 );
	}		
}

dog_sniff_spots( sniff_spots_vectors )
{
	self notify( "new_spots" );
	self endon( "new_spots" );
	self endon( "stop_sniffing");
	
	first_spot = random( sniff_spots_vectors );
	self setgoalpos(first_spot );
	
	while( Distance2DSquared( self.origin, first_spot) > 75*75 )
		wait .25;
	
	//if( sniff_spots_vectors.size == 1 )
		//sniff_spots = add_to_array( sniff_spots,  level.target_ent.origin );
	
	self enable_dog_sniff();
	//IPrintLn( "sniffing " +sniff_spots_vectors.size+ " spots" );
	while(1)
	{
		sniff_spots_vectors = array_randomize( sniff_spots_vectors );
		foreach( spot in sniff_spots_vectors )
		{	
			self setgoalpos( spot );
			//IPrintLn( "new sniff spot");
			//thread draw_line_to_ent_for_time( spot, level.dog, 0, 1, 0, 1 );
			wait( RandomIntRange( 4,8 ) );
		}
	}
		
}

dog_teleport_trig_logic()
{
	struct = getstruct( self.target, "targetname" );
	self waittill("trigger", who );
	if ( who.type == "dog" )		
	{
		who forceteleport( struct.origin, struct.angles );	
		wait .05;
		who notify( "teleported" );
	}
	
}

dog_waits_before_crossing_chasm( color_node )
{
	flag_wait("hesh_to_shop_door");
	
	wait 3;
	
	self setgoalnode( color_node );
	wait .10;
	self.colornode_setgoal_func = undefined;
	
	
}

intro_enemies()
{
	intro_stealth_settings();
	battlechatter_off();
	level.gasstation_guys = [];
	
	
	//encountr 1
	//getent( "shadow_guy", "targetname" ) add_spawn_function( ::shadow_guy_logic );	
	array_spawn_function_targetname("shadow_guy", ::shadow_chaser_logic );
	
	array_spawn_function_targetname("shadow_chasers", ::shadow_chaser_logic );
	
	getent( "dog_victim", "targetname" ) add_spawn_function( ::dog_attack_victim_logic );
	getent( "dog_attack_guard", "targetname" ) add_spawn_function( ::dog_attack_guard_logic, "dog_attack_guard" );
	getent( "dog_attack_guard_stairs", "targetname" ) add_spawn_function( ::dog_attack_guard_logic, "dog_attack_guard_stairs" );
	array_spawn_function_targetname("dog_attack_back_enemies", ::dog_attack_back_enemies_logic );
	
	
	//enocunter 2
	getent( "roof_guy", "targetname" ) add_spawn_function( ::roof_guy_logic );
	getent( "meeting_guys_patroller", "targetname" ) add_spawn_function( ::gasstation_enemy_globals );
	
	array_spawn_function_targetname("meeting_guys", ::meeting_guys_logic );
	array_spawn_function_targetname("runners", ::running_guys_logic );
	
	array_spawn_function_targetname("executioners", ::gasstation_executioners_logic );
	
	switch ( level.start_point )
	{
		case "default":
		case "intro":
			
			
			
		case "lobby":
			
			
		case "outside":
			
		case "street":
			flag_wait("promenade_exit");
			//level.shadow_guys = array_spawn_targetname( "shadow_guy", 1 );
		
		case "encounter1":
			level.dog_victim = spawn_targetname( "dog_victim", 1 );
			level.dog_attack_guard = spawn_targetname( "dog_attack_guard", 1 );
			level.dog_attack_guard_stairs = spawn_targetname( "dog_attack_guard_stairs", 1 );
		
			thread dog_attack();
			level.dog_attack_guard_stairs enable_sprint();
			
			flag_wait("dog_kill_ended" );
//			flag_wait( "shadow_guy_dead");
//			wait CONST_TIME_BEFORE_SHADOW_CHASERS;
//			level.shadow_chasers = array_spawn_targetname( "shadow_chasers", 1 );
//			flag_wait("shadow_chasers_dead");
//			wait(2);
			
		case "encounter2":		
			thread gasstation_execution_timing();
			gasstation_civs();
			array_spawn_targetname( "executioners", 1 );
//			thread gasstation_takedown_globals();
//			level.roof_guy = spawn_targetname( "roof_guy", 1 );
//			
			flag_wait("player_dropped_down");
			level.meeting_guys = array_spawn_targetname( "meeting_guys", 1 );
			guy = spawn_targetname( "meeting_guys_patroller", 1 );
//			level.runing_guys = array_spawn_targetname( "runners", 1 );
	}
}

gasstation_execution_timing()
{
	
	flag_wait_any_return( "player_sees_execution", "gasstation_front_approach", "gas_station_enter" );
	//flag_wait( "player_sees_execution" );
	wait ( DELAY_BEFORE_EXECUTION );
	flag_set( "execution_start" );
	
	wait 1;
	
	array_thread( getaiarray( "allies"), ::ignore_me_ignore_all_OFF );
	trig = getent( "hill_pos1", "targetname" );
	trig trigger_off();
	
	activate_trigger_with_targetname( "hill_pos2" );
	battlechatter_on();
	
}

gasstation_executioners_logic()
{
	self endon( "death" );
	level.gasstation_guys = add_to_array( level.gasstation_guys, self );
	self ignore_me_ignore_all();
	self.dontEverShoot = true;
	self.goalradius = 24;
	self SetGoalPos( self.origin );
	self.anchor = spawn( "script_origin", self.origin );
	self linkto( self.anchor );
	
	while( !isdefined ( level.execuioner_targets ) )
		wait .25;
		
	//self SetEntityTarget( random( level.execuioner_targets ) );
	
	flag_wait( "execution_start" );
	self.dontEverShoot = undefined;
	self ignore_me_ignore_all_OFF();
	
	flag_wait( "civilians_shot" );
	
	self unlink();
	self.goalradius = 1024;

	
	
	
}
dog_attack_back_enemies_logic()
{
	self.grenadeammo = 0;
	self.baseaccuracy = 2;
	self disable_long_death();
}


dog_attack_guard_logic( node_targetname )
{
	self ignore_me_ignore_all();
	self disable_long_death();
	self.goalradius = 20;
	self.grenadeammo = 0;
	self.baseaccuracy = 2;
	self disable_careful();
	node = getnode( node_targetname, "targetname" );
	
	flag_wait( "dog_kill_started" );
	wait( DELAY_BEOFRE_ATTACK_GUARD_GOES_HOT );
	
	self SetGoalNode( node );
	self ignore_me_ignore_all_OFF();	
}

dog_attack_victim_logic()
{
	self ignore_me_ignore_all();
	self.maxvisibledist = .01;
	self.animname = "victim";
	self.goalradius = 24;
	self.allowDeath = true;
	self.a.nodeath = true;
	self disable_surprise();
	//self.ragdoll_immediate = true;
	//self.forceragdollimmediate = 1;
	struct = getstruct("dog_attack", "targetname" );
	scene = getanim( "dog_kill_long" );
	self thread dog_victim_radio_sounds();
	start_spot = GetStartOrigin( struct.origin, struct.angles, scene );
	start_angles = GetStartAngles( struct.origin, struct.angles, scene );
	
	self.anchor = spawn( "script_origin", start_spot );
	self.anchor.angles = start_angles;
	
	self ForceTeleport( start_spot, start_angles );
	self linkto ( self.anchor );
	
	flag_wait("shop_exit");
	
	self thread dog_victim_enemy_early_damage_detection();
	self endon( "death" );
	
	flag_wait("dog_kill_started" );
	self unlink();
	
	wait .25;	
	self thread play_sound_on_tag( "generic_meleecharge_enemy_7", "tag_eye", true );
	wait 1.5;
	self thread play_sound_on_tag( get_random_death_sound(), "tag_eye", true );
	wait 2;
	self thread play_sound_on_tag( get_random_death_sound(), "tag_eye", true );
	wait 1;
	self thread play_sound_on_tag( get_random_death_sound(), "tag_eye", true );
	
	
	//wait( 8.33 );
	//self kill();
	

}

dog_victim_radio_sounds()
{
	//self = dog victim
	while( 1 )
	{
		self play_sound_on_tag_endon_death( "fed_flavor_burst", "tag_eye" );
		wait( RandomIntRange( 2, 3 ) );
		
		if( flag( "dog_kill_started") || flag( "dog_kill_aborted" ) )
			return;			
	}
	
}


dog_victim_enemy_early_damage_detection()
{
	self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName );
	
	if( flag( "dog_kill_started" ) )
	{	
		if(!flag( "dog_kill_aborted" ) )
		{			
			self die();	
			flag_set("dog_kill_aborted");
			set_flag_if_not_set( "dog_kill_ended" );
		}			
	}

}


dog_attack()
{
	while( !isdefined( level.dog_victim ) )
		wait(.05);
	
	struct = getstruct( "dog_attack", "targetname" );
	actors = [ level.dog_victim, level.dog ];
	
	flag_wait( "shop_exit" );
		
	wait DELAY_BEFORE_DOG_ATTACK;
	
	flag_set( "dog_kill_started" );
	if( isalive( level.dog_victim ) )
	{
		battlechatter_on( "axis" );
		//level.dog_victim unlink();
		
		level.dog thread dog_attack_dog_ends_early();
		struct anim_single( actors, "dog_kill_long" );
		
		if( isalive( level.dog_victim ) )
			level.dog_victim kill();
		
		set_flag_if_not_set( "dog_kill_ended" );
	}
	
	//
	
}


dog_attack_dog_ends_early()
{
	level endon( "dog_kill_ended");
	self thread play_sound_on_entity( "anml_dog_attack_npc_jump" );
	
	flag_wait( "dog_kill_aborted" );
	self StopAnimScripted();

}

gasstation_takedown_globals()
{
	if( GetDvarInt( "steve", 1 ) )
	{
		level endon("intro_takedown_aborted");
	
		ent = getstruct( "backdoor_takedown", "targetname" );
		
		getent( "backdoor_takedown_enemy", "targetname")  add_spawn_function( ::gasstation_takedown_enemy_getin_position );
		getent( "team2_gs_1", "targetname")  add_spawn_function( ::gasstation_takedown_friendly_getin_position );
		
		enemy = spawn_targetname( "backdoor_takedown_enemy", 1 );
		friendly = spawn_targetname( "team2_gs_1", 1 );
		
		ent.actors = [ friendly, enemy ];
	
		foreach( actor in ent.actors )
			actor.anim_ent = ent;
	
		flag_wait("intro_takedown_ready");
			
		wait 3;
		
		flag_set( "intro_takedown_started" );	
		
		ent anim_reach_solo( friendly, "intro_takedown" );
		ent anim_single( ent.actors, "intro_takedown" );
	}
	
	//flag_set( "intro_takedown_done" );

}





gasstation_takedown_friendly_getin_position()
{
	level endon( "intro_takedown_aborted");
	self ignore_me_ignore_all();
	self thread gasstation_takedown_friendly_aborted_detection();
	self.animname = "ai_friendly";
	self enable_cqbwalk();
	self.grenadeammo = 0;
	self forceuseweapon( "acr_hybrid_silenced", "secondary" );
	
	while(!isdefined( self.anim_ent ) )
		wait.10;
		
	flag_set("intro_takedown_ready");

}

gasstation_takedown_friendly_aborted_detection()
{
	level endon("intro_takedown_started");
	
	flag_wait("intro_takedown_aborted");
	self stopanimscripted();
	flag_set("intro_takedown_done");
	self.animname = "alpha1";
	self set_force_color("r");
	self enable_ai_color();
}

gasstation_takedown_enemy_getin_position()
{
	self.animname = "ai_enemy";
	self ignore_me_ignore_all();
//	self.skipDeathAnim = undefined;
//	self.noragdoll = true;
	self.allowDeath = true;
	self.a.nodeath = true;
	self thread gasstation_takedown_enemy_early_damage_detection();
	
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
	


}

gasstation_takedown_enemy_early_damage_detection()
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


gasstation_civs()
{
	level.civs = array_spawn_targetname( "gasstation_civs", "targetname" );
	array_thread( level.civs, ::gasstation_civs_logic );
	
}

gasstation_civs_logic()
{
	self.animname = "generic";
	self.name = "";
	self.team = "allies";
	//self.allowDeath = true;
	//self.a.nodeath = true;
	self.ragdoll_immediate = true;
	self.ignoreme = 1;
	if(!isdefined( level.execuioner_targets ) )
		level.execuioner_targets = [];
	
	
	ent = spawn( "script_origin", self geteye() );
	ent linkto( self, "tag_eye" );
	level.execuioner_targets = add_to_array( level.execuioner_targets, ent );
	
	self thread anim_loop_solo( self, "knees_idle" );
	self set_moveplaybackrate( RandomFloatRange( .6, 1.3 ) );
	self thread civs_set_flag_on_damage();
	//self thread gasstation_civ_team_switch();
	
	flag_wait("civilians_shot" );	
	self notify ("stop_loop");
	self StopAnimScripted();
	self die();
	
	
}

gasstation_civ_team_switch()	
{
	flag_wait( "execution_start" );
	self.team = "allies";
	self.ignoreme = 0;
		
		
}



civs_set_flag_on_damage()
{
	self waittill("damage" );	
	set_flag_if_not_set( "civilians_shot" );
}

gasstation_enemy_globals()
{
	level.gasstation_guys = add_to_array( level.gasstation_guys, self );
	self set_ai_bcvoice( "shadowcompany" ); //shadowcompany = Spanish
	self.grenadeammo = 0;
	self set_baseaccuracy( .6);
	self disable_long_death();
	
	//self thread gasstation_enemy_awareness_monitor();
	
}

gasstation_enemy_awareness_monitor()
{
	/*
	if( self != level.roof_guy ) 
	{
		self ignore_me_ignore_all();
		self disable_stealth_for_ai();
		
		flag_wait( "player_dropped_down" );
		self ignore_me_ignore_all_OFF();
		self enable_stealth_for_ai();
	}
	*/
	self ent_flag_wait( "_stealth_behavior_first_reaction" );
	
	 if( !flag( "gasstation_guys_engaged" ) )
	 	flag_set( "gasstation_guys_engaged" );

}


running_guys_logic()
{
	self thread gasstation_enemy_globals();
	//self endon("_stealth_behavior_first_reaction");
	
	flag_wait( "gasstation_front_approach" );
	volume = getent("running_guys_delete", "targetname" );
	self SetGoalVolumeAuto( volume );
	
	self waittill( "goal");
	self delete();

}

roof_guy_logic()
{
	self endon( "death" );
	//self thread gasstation_enemy_globals();
	
	flag_wait( "dog_on_roof" );
	self notify ("end_patrol");
	self disable_DontAttackMe();
	self StopAnimScripted();
	
}

meeting_guys_logic()
{
	self thread gasstation_enemy_globals();
	node = getstruct( "meeting_guys_ent", "targetname" );	
	self.animname = "generic";
	
	self thread meeting_animation( node, undefined );			
}


shadow_chaser_logic()
{	
	//self endon("death");
	self set_ai_bcvoice( "shadowcompany" ); //shadowcompany = Spanish
	//self set_archetype( "gundown_archetype" );	
	
	self ignore_me_ignore_all();
	self.health = 50;
	

	self set_archetype( "gundown_archetype" );	
	
	flag_wait( "dog_distracts" );
	self.goalradius = 32;
	self set_moveplaybackrate( .7 );
	
	if( self.script_noteworthy == "one" )
	{
		self thread shadow_guy_dog_react();
	}
	
	else
	{
		wait randomintrange( 2, 4 );
		self setgoalnode( getnode( "shdaw_guy2_dog", "targetname") );
	}

	self waittill_notify_or_timeout( "damage", CONST_TIME_BEFORE_SHADOW_CHASERS_HOT );
	self stopanimscripted();
	
	if(!flag("shadow_chasers_hot") )
		flag_set("shadow_chasers_hot");
		
	self ignore_me_ignore_all_OFF();
	
	//self die();
}

shadow_guy_dog_react()
{
	self endon("death");
	self.animname = "generic";
	struct = getstruct("dog_react", "targetname" );
	struct anim_reach_solo( self, "dog_react" );
	struct anim_single_solo( self, "dog_react" );	
}

shadow_guy_logic()
{
	self ignore_me_ignore_all();	
	self set_ai_bcvoice( "shadowcompany" ); //shadowcompany = Spanish
}



#using_animtree( "generic_human" );
hesh_logic()
{
	self endon( "deleted" );
	self.animname = "generic";
	self thread magic_bullet_shield();
	self set_baseaccuracy( 2 );
	self forceuseweapon( "acr_hybrid_silenced", "secondary" );
	self.grenadeammo = 0;
	
	//active_patrolwalk_gundown
	switch ( level.start_point )
	{
		case "default":
		case "intro":	
			self.ignoreme = 1;
			self.ignoreall = 1;
			self.animname = "generic";
					
			self enable_cqbwalk();
			
			flag_wait("intro_vo_done");
			
			self set_force_color("r");
			
			activate_trigger_with_targetname( "to_corner" );
			
			flag_wait("hallway_halfway");
			
			self delaythread( 2, ::switch_from_cqb_to_creepwalk );
			
			//crouch under beam
			struct = getstruct("crouch_test", "targetname" );
			scene = "creepwalk_duck";
			self disable_ai_color();
			struct anim_reach_solo( self, scene );
			self delaythread( 1, ::enable_ai_color );
			struct anim_single_solo( self, scene );					
						
			self disable_exits();
			flag_wait( "screen_arrive" );

			//gradual speedup (util func for this eventually)
			self set_moveplaybackrate( .6 );			
			self set_moveplaybackrate( 1, 6 );
			
			self enable_exits();
			
			//set by VO lines completing
			flag_wait( "exit_theater" );
			
			deer_ruckus( (284, -2438, 112 ) );
			
			hesh_blocker = getent( "hesh_blocker", "targetname" );
			hesh_blocker.origin +=( 0,0,500 );
			hesh_blocker connectpaths();
			
			activate_trigger_with_targetname( "theater_exit_wait" );
			flag_set("to_theater_exit");
			
			self switch_from_creepwalk_to_cqb();
			
			wait 3;
					
		case "lobby":
			
			self switch_from_creepwalk_to_cqb();
			
			flag_wait("lobby_exit_approach");
			self flashlight_off();
			wait 2;
			
		case "outside":
			
			self switch_from_cqb_to_creepwalk();
			wait 6;
			self switch_from_creepwalk_to_cqb();
			flag_wait("promenade_exit_halfway");
			
			//self.colornode_setgoal_func= ::hesh_does_360;
			
		case "street":
			
			
			level thread bus_movement();
			flag_wait( "hesh_to_shop_door" );//VO finishes
			
			//send team 2 to cover the chasm until the player drops down
			activate_trigger_with_targetname( "team2_covers_chasm" );
			self ignore_me_ignore_all();
			
			//door open
		case "encounter1":	
			
			ent = getstruct( "shop_door_anim_ent", "targetname");
			self disable_ai_color();
			self disable_cqbwalk();
			self set_run_anim( "stumble_creepwalk" );
			ent anim_reach_and_idle( [self], "shop_door_idle","shop_door_idle" );
			
			flag_wait("player_at_shop_door" );//trig radius by door
			
			self clear_generic_run_anim();
			
			doors = getentarray( "shop_door_left", "targetname" );
			door = doors[0];
			
			if( isdefined( doors[1] ) )
				doors[1] delete();
			
			ent notify("stop_loop");
			ent thread anim_single_solo( self, "shop_door_open" );
			door thread shop_door_open();
			
			wait .5;
			self enable_ai_color();
			
			flag_wait( "dog_kill_started" );
			wait( DELAY_BEOFRE_ATTACK_GUARD_GOES_HOT + 2 );
			self.baseaccuracy = .8;
			self ignore_me_ignore_all_OFF();
			
			delaythread( 4, ::activate_trig_if_not_flag, "back_enemies_fight_begin" );
			
			flag_wait( "dog_attack_enemies_dead" );
			
			wait 3;
			
			activate_trigger_with_targetname( "hesh_attacks_shadow_guys" );
			
			flag_wait("player_at_encounter1");
			
			ent = getstruct( "wall_kick", "targetname" );
			ent.origin = ( -13736.5, 14092, -232 );
//			self disable_ai_color();
			
			//flag_wait( "dog_distracts" );
			ent anim_reach_solo( self, "wall_kick" );
			ent anim_single_solo( self, "wall_kick" );
			
			level thread activate_trigger_with_targetname("hesh_to_dropdown");
			self enable_ai_color();
		
			
		case "encounter2":	
			self ignore_me_ignore_all();
			
			//gasstation lookout
			flag_wait("hesh_to_lookout");
			
			//if player doesnt jump down, they do anyways
			flag_wait_or_timeout( "player_dropped_down", 10 );
			
			if(!flag( "player_dropped_down" ) )
				activate_trigger_with_targetname( "player_dropped_down" );
			
			self thread hesh_gasstation_logic();
			
			flag_wait_or_timeout( "player_approaches_gasstation", 4.5 );
			
			activate_trigger_with_targetname( "hill_pos1" ); //also sets that flag
						
			flag_wait( "gasstation_clear" );
		
		case "lariver":
	
		}
	

}

TIME_BETWEEN_BUS_MOVES = 2;
bus_movement()
{
	drop_angles = (272.4, 52.6004, 89.9999);
	slow_rotate_angles = (275.186, 115.125, 27.5734);
	thread bus_movement_sounds_rumble_etc();
	model = getent( "bus", "targetname" );
	clip = getent( "bus_clip", "targetname" );
	clip linkto( model );
	
	flag_wait("player_on_bus");
	model RotateTo( drop_angles, 1 );
	
	wait TIME_BETWEEN_BUS_MOVES;
	
	time = 3;
	model RotateTo( slow_rotate_angles, time, .5, time - .5 );

}

bus_movement_sounds_rumble_etc()
{
	flag_wait("player_on_bus");
	current_speed = level.current_speed_percent;
	
	spot = level.player.origin - (0,0,400);
	level.player thread play_sound_on_entity( "bus_impact" );//npc_car_slide_cover deer_metal_impact bodyfall_metal_small
	earthquake( .2, .6, level.player.origin, 600 );

	set_player_speed( .2 );	
	delayThread( 3, ::lerp_player_speed, current_speed );

	//level .player ScreenShakeOnEntity( 6, 0, 4, 2, .2, 1.8, 0, .5, 0, .5 );
	
	delayThread( 2,  ::play_sound_in_space, "bus_settle", spot ); //wall_kick_impact_rubble
	//delayThread( 2,  ::play_sound_in_space, "wall_kick_impact_rubble", spot - (0,0, 500 ) ); //wall_kick_impact_rubble
	//set_player_speed( current_speed );
	
	wait( TIME_BETWEEN_BUS_MOVES - .5 );
	
	//thread play_sound_in_space( "bus_metal_creak", spot ); 
		
}

hesh_does_360( color_node )
{
	//used by the color system at a specific time
	
	struct = getstruct( "360_turn", "targetname" );	
	struct anim_reach_solo( self, "360" );
	struct anim_single_solo( self, "360" );
	
	//wait .5;
	
	self enable_ai_color();
	//self setgoalnode( color_node );
	self.colornode_setgoal_func = undefined;	
}

hesh_gasstation_logic()
{
	 
	flag_wait("player_dropped_down");
	//turn off these trigs that lead the AI to the pipe until the gasstation is clear
	pipe_trigs = getentarray( "pipe_trigs", "script_noteworthy" );
	array_thread( pipe_trigs, ::trigger_off );
	
	//cause = flag_wait_any_return("_stealth_spotted", "gasstation_guys_engaged" );
	//IPrintLn( "Going hot on flag: " + cause );
//	flag_wait("_stealth_spotted" );
//	wait .5;
//	flag_set( "gas_station_open_fire" );
	flag_wait("execution_start");
	
	//Hesh: Weapons free. 
	level.hesh smart_radio_dialogue( "deerhunt_hsh_weaponsfree" );
	
	vis_clip = getent( "hesh_foliage_clip", "targetname" );
	vis_clip delete();
	
	//self ignore_me_ignore_all_OFF();
	self.baseaccuracy = 5;
	
	while( level.gasstation_guys.size != 0 )
	{
		level.gasstation_guys = array_removeDead_or_dying( level.gasstation_guys );
		wait 1;
	}
	
	hill_trigs = getentarray( "hill_trigs", "script_noteworthy" );
	array_thread( hill_trigs, ::trigger_off );
	array_thread( pipe_trigs, ::trigger_on );
	
	activate_trigger_with_targetname( "gasstation_clear" );
	
}

dog_gasstation_logic()
{
	flag_wait( "hill_pos1" );
	
	//give player time to kill roof guy if they want
	flag_wait_or_timeout( "gas_station_open_fire", 45 );
	

	if( !flag( "roof_guy_dead" ) )
	{
		flag_set( "send_dog_to_roof");
		self dog_kills_roof_guy();		
		self ignore_me_ignore_all();
	}
	
}

dog_kills_roof_guy()
{
	if( flag( "roof_guy_dead" ) )
	   return;
	 
	//Hesh: Cairo can take out the roof patrol.
	if ( !flag( "gas_station_open_fire" ) )
		level.hesh	smart_radio_dialogue( "deerhunt_hsh_cairocantakeout" );
	
	self endon( "roof_guy_dead" );
	//self set_run_anim( "run" );
	self disable_ai_color();
	self SetGoalEntity( level.roof_guy );
	
	flag_wait( "dog_on_roof" );
	wait 2;
	self.ignoreall = 0;
	
	flag_wait( "roof_guy_dead" );
	
	
	
}

meeting_animation( node, the_trig  )
{
	flag_wait( "player_dropped_down" );
	self endon( "death" );
	idle_anim = undefined;
	
	idle_anim =  self.script_noteworthy;					
	node thread stealth_ai_idle( self, idle_anim, undefined, undefined );
	
	self thread stealth_anim_interupt_detection();
	//these guys would not pursue the player for some reason, so:
//	flag_wait( "_stealth_spotted" );
//	wait randomintrange( 1, 3 );
//	self  disable_stealth_for_ai();
//	self.goalradius = 250;
	
}

stealth_anim_interupt_detection()
{

	self thread stealth_enemy_endon_alert();
	self waittill_any( "enemy_stealth_reaction", "damage", "stealth_enemy_endon_alert", "enemy_awareness_reaction", "bulletwhizby" );
	self stopanimscripted();	
	
	self.goalradius = 1000;
	
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

hesh_lights_flare_at_door()
{
	ent = getstruct("paris_delta_deploy_flare_crouched", "targetname" );
	ent anim_reach_solo( self, ent.targetname );
	self thread flare_fx_internal();
	ent anim_single_solo( self, ent.targetname );
	flag_set("flare_down");
}

flare_fx_internal()
{
	wait 2.10;
	//PlayFX( getfx("flare"), self GetTagOrigin("tag_inhand") );
}

move_player_to_start( struct_targetname )
{
	assert( isdefined( struct_targetname ) );
	start = getstruct( struct_targetname, "targetname" );
	
	if(!isdefined( start ) )
	{
			start = getent( struct_targetname, "targetname" );
			if(!isdefined( start ) )
				return;			
	}
		
	level.player SetOrigin( start.origin );
	
	lookat = undefined;
	if ( isdefined( start.target ) )
	{
		lookat = getent( start.target, "targetname" );
		assert( isdefined( lookat ) );
	}
	
	if ( isdefined( lookat ) )
		level.player setPlayerAngles( vectorToAngles( lookat.origin - start.origin ) );
	else
		level.player setPlayerAngles( start.angles );
	wait(.10);
		
}

deer_ruckus_trig_logic()
{
	self waittill("trigger");
	if( isdefined( self.target ) )
	{
		spot = getstruct( self.target, "targetname" ).origin;
		thread deer_ruckus( spot );
	}
}

deer_ruckus( pos )
{
	sounds = [ "deer_metal_impact", "deer_glass_break" ];
	sounds = array_randomize( sounds );
	
	thread play_sound_in_space( sounds[0], pos );
	wait( randomfloatrange( .5, .8 ) );
	thread play_sound_in_space( sounds[1], pos );
	//wait( randomfloatrange( .5, .8 ) );
	//thread play_sound_in_space( sounds[2], pos );
	
}

deer_init()
{

	level.drone_lookAhead_value = 100;
	
	lobby_spawners = getentarray( "lobby_deer", "targetname" );
	outside_spawners = getentarray( "promenade_deer", "targetname" );
	exit_spawners = getentarray( "promenade_exit_deer", "targetname" );

	lobby_deer = [];
	outside_deer = [];
	exit_deer = [];
	
	foreach( i, s in lobby_spawners )
		lobby_deer[i] = maps\_drone_deer::deer_dronespawn( s );

	foreach( i, s in outside_spawners )
		outside_deer[i] = maps\_drone_deer::deer_dronespawn( s );
	
	foreach( i, s in exit_spawners )
		exit_deer[i] = maps\_drone_deer::deer_dronespawn( s );
	
	structs = getstructarray( "physics_push", "targetname" );
	array_thread( structs, ::do_physics_pulse );
	thread theatre_doors();
	
	flag_wait("lobby_entrance");
	
	exit_deer[0] thread deer_detects_when_to_run();
	wait .25;
	array_notify( lobby_deer, "move" );	
	wait 1;
	array_notify( outside_deer, "move" );
	
	
	flag_wait( "promenade_exit_halfway" );
	//wait 1;
	//array_notify( exit_deer, "move" );
	
}

deer_drone_logic()
{
	//experiment with getting drones to stop/start again
	flag_wait("lobby_entrance");
	wait 1.5;
	self notify("drone_stop");
	self thread maps\_drone_deer::deer_drone_custom_idle();
	wait 2;
	self thread maps\_drone::drone_move();
	
}

deer_vehicle_move_logic()
{

	switch ( level.start_point )
	{
		case "default":
		case "intro":
		case "lobby":
			self endon( "deleted" );
			flag_wait( "lobby_entrance" );	
			//wait( randomfloatrange( .3, .6 ) );	
			self maps\_vehicle::gopath();
			
			self Vehicle_SetSpeedImmediate( 20, 10, 10 );
			
			wait 3;
			
		case "outside":
			
			self.deer thread deer_detects_when_to_run();
			
			flag_wait( "deer_runs" );
			self Vehicle_SetSpeedImmediate( 20, 10, 10 );
			
		case "encounter1":
		case "encounter2":
	}
	
}

theatre_doors()
{
	//["theatre_doors_A_1",  "theatre_doors_A_2",
	doors =[  "theatre_doors_b_1", "theatre_doors_b_2" ];
	
	theatre_doors = [];
	foreach( i, door in doors )
	{
		theatre_doors[i] = getentarray( door, "targetname" );
	}
		
	flag_wait( "lobby_entrance" );
	wait .5;
	array_thread( theatre_doors, ::smash_open );
	
}

smash_open()
{
	//self = script_brushmodel doors array
	foreach( door in self )
	{
		if( door.targetname == "theatre_doors_A_1" ||  door.targetname == "theatre_doors_b_1" )
		{
			num = 70;
		}
		else
		{
			num = -70;		
		}
		door thread open_and_connect(num);
	}
}

open_and_connect(num)
{

	wait(randomfloatrange( .15, .20));
	self RotateYaw( num, .10 );
	self ConnectPaths();	
	
}

deer_detects_when_to_run()
{
	//self = script_model 
	wait 1;
	//self SetCanDamage( true );
	self thread deer_allies_dist_detection();
	self thread deer_damage_detection();
	self thread deer_player_aim_detection();	

	self waittill("move");
	
	level flag_set( "deer_moved_away" );
}

deer_allies_dist_detection()
{
	self endon("stop_deciding_when_to_move");
	max_dist = 900*900;
	
	all_allies = add_to_array( level.squad, level.player  );
	
	//dist = Distance2DSquared( self.origin, level.player.origin );
	
	while( !is_array_close( all_allies, max_dist ) )
	{
		//dist = Distance2DSquared( self.origin, level.player.origin );
		wait .25;		
	}
	
	//flag_set( "deer_runs" );		
	self notify("move");
	self notify("stop_deciding_when_to_move");
}



deer_damage_detection()	
{
	//self = script_model 
	//ENDON PLEASE!!!!!
	self endon("stop_deciding_when_to_move");
	total_amount = 0;
	while(1)
	{
		self waittill("damage", amount, attacker );
		total_amount += amount; 
		if( isdefined( attacker ) )
		{
			if( attacker == level.player )
			{
				//flag_set( "deer_runs" );		
				self notify("move");
				self notify("stop_deciding_when_to_move");
				return;
			}
		}
	}

}

deer_player_aim_detection()
{
	//self = script_model 
	//ENDON PLEASE!!!!
	self endon("stop_deciding_when_to_move");
	while( 1 )
	{
		Forward = VectorNormalize( AnglesToForward( level.player getplayerangles() ) );
		players_aim = level.player.origin + ( Forward* 10000  );
		trace = BulletTrace( level.player geteye(), players_aim, true, level.player );
		if( isDefined( trace["entity"] ) )
		{
		   if( trace["entity"] == self )
		   {
		   		//flag_set( "deer_runs" );		
		   		wait .5;
				self notify("move");
				self notify("stop_deciding_when_to_move");
				return;
		   }
		}
		wait .10;		
	}				
}


do_physics_pulse()
{
	//self = struct
	flag_wait( "lobby_entrance" );
	
	wait .40;
	PhysicsExplosionSphere( self.origin, 50,30, 1 );
	
}

lobby_ruckus()
{
	flag_wait( "lobby_entrance" );
	pos = ( -9124.8, 12167.3, -170 );
	sounds = [ "deer_metal_fall", "deer_glass_break", "deer_metal_impact" ];
	sounds = array_randomize( sounds );
	
	wait .5;
	thread play_sound_in_space( sounds[0], pos );
	wait( randomfloatrange( .5, .8 ) );
	thread play_sound_in_space( sounds[1], pos );
	wait( randomfloatrange( .5, .8 ) );
	thread play_sound_in_space( sounds[2], pos );
		
}

lariver_global_setup()
{
	init_enemy_color_volumes();
	thread lariver_friendly_setup();
	thread lariver_enemies();
	
	CreateThreatBiasGroup( "final_pos_enemies" );
	CreateThreatBiasGroup( "final_pos_friendlies" );
	
	SetThreatBias( "final_pos_enemies", "final_pos_friendlies", 10000 );
	SetThreatBias( "final_pos_friendlies", "final_pos_enemies", 10000 );
	SetThreatBias( "axis", "final_pos_friendlies", 0 );
	SetThreatBias( "allies", "final_pos_enemies", 0 );
	
	spot = (-18346.3, 15553.2, -121.6);
	playfx( getfx( "green_smoke"), spot );
	
	
}

FINAL_POS_ENEMY_AMOUNT = 8;
TIME_BEFORE_CALVARY = 6;
TIME_BEFORE_OPEN_FIRE = 4;

lariver_enemies()
{	
	array_spawn_function_noteworthy( "lariver_enemies", ::lariver_enemies_global_logic );
	array_spawn_function_noteworthy( "lariver_enemies", ::enemy_color_volume_logic );	
	array_spawn_function_targetname( "chopper_guys", ::lariver_enemies_global_logic );
	array_spawn_function_targetname( "lariver_backline_guys", ::lariver_backline_guys_logic );
	
	//final_position_enemy_spawner
	flag_wait("pipe_halfway");
	//wait for chopper to spawn via trigger than run this func on it:
	wait(.5);
	level.Chopper = get_vehicle( "lariver_enemy_chopper", "targetname" );
	level.Chopper thread lariver_enemy_chopper_logic();
	
	flood_spawners = getentarray( "lariver_flood_filler", "targetname" );
	
	foreach( s in flood_spawners )
	{
		s.count = 10;
	}
	flood_spawn( flood_spawners );
	
	array_spawn_targetname( "lariver_backline_guys", 1 );
	
	while( GetAIArray( "axis" ).size > 0 )
		wait 2;
	
	wait 5;
	
	getent( "hesh", "targetname" ) remove_spawn_function( ::hesh_logic );	
	getent( "dog", "targetname" ) remove_spawn_function( ::dog_logic );
	maps\deer_hunt_ride::jeep_ride_setup();
	
	
}




lariver_enemies_global_logic()
{
	self forceuseweapon( "kriss", "secondary" );
	self grenades_by_difficulty();
	self.script_forcegoal = true;
	self set_ai_bcvoice( "shadowcompany" ); //shadowcompany = Spanish
}


lariver_backline_guys_logic()
{
	self.grenadeammo = 0;
	self SetThreatBiasGroup( "final_pos_enemies" );
	
	//self thread magic_bullet_shield();
	self thread only_take_damage_from_player();
	
	
	
}


lariver_friendly_setup()
{
	/*	
	team2_squad_size = 3;
	level.team2 = [];
	level.team2_leader = undefined;
	spawner = getent( "team2", "targetname" );
	structs = getstructarray( "slide_guy", "targetname" );
	
	for( i=0; i< team2_squad_size; i++ )
	{
		spawner.count = 1;
		level.team2[i] = spawner StalingradSpawn();
		wait .05;
		
		if( i == 0 )
		{
			level.team2_leader = level.team2[i];
			level.team2_leader thread lariver_team2_leader_logic();
		}
		else
		{
			level.team2[i] thread lariver_team2_logic();
		}		
		
		thread lariver_play_anim_on_struct( level.team2[i], structs[i] );
		
	}
	*/
	battlechatter_on( "allies" );
	
	array_spawn_function_targetname( "rpg_guys", ::lariver_balcony_friendly_logic );
	
	array_spawn_targetname( "rpg_guys", 1 );
	flag_wait( "lariver_final_position" );
	

	
}

lariver_balcony_friendly_logic()
{
	self thread magic_bullet_shield();
	self.grenadeammo = 0;
	self SetThreatBiasGroup( "final_pos_friendlies" );
	
}

lariver_rivertop_friendly_logic()
{
	self.grenadeammo = 0;
	
	if( randomint( 100 ) < 33 ) 
		self LaserForceOn();
	
	self.dontEverShoot = true;
	self thread magic_bullet_shield();
	
	wait TIME_BEFORE_CALVARY;
	
	self.dontEverShoot = undefined;
	self.baseaccuracy = 3;		
}


lariver_enemy_chopper_logic()
{
	//self = enemy chopper
	self endon("death");
	//self.health += 500;
	self.preferred_crash_style = 1;
	wait 2;
	self notify("stop_kicking_up_dust");//turn off dust kickup til the bridge guys are unloaded.  You cant see them jump out with it.
	self waittill("unloaded");
	wait 1.5;
	array_thread( self.riders, ::lariver_chopper_passanger_logic );
	self delayThread( 2, ::aircraft_wash );
	
	self waittill( "player_attacked_riders" );
	//wait( 2 );
	self Vehicle_SetSpeed( 40, 4 );
		
}

lariver_chopper_evade()
{
	og_node_origin = self.currentNode.origin;
	self.currentNode.origin += (0,0,200);
	wait 5;
	self.currentNode.origin -= ( 0,0,200);
	
}

lariver_chopper_passanger_logic()
{
	//self endon("death");
	self waittill("death",  attacker );
	
	if( isdefined( attacker ) )
		if( IsPlayer( attacker ) )
			self.ridingvehicle notify("player_attacked_riders");
	
}


lariver_team2_leader_logic()
{
	self thread magic_bullet_shield();
	self lariver_team2_logic();
	
}



lariver_team2_logic()
{
	//self.health = 200;
	self.flavorbursts = false;
	self.animname = "generic";
	self set_force_color( "o" );
	self enable_ai_color();
	self set_ai_bcvoice( "delta" );
	self.grenadeammo = 0;
	self ignore_me_ignore_all();
	self enable_cqbwalk();
	self thread magic_bullet_shield();

	
	//self thread waterfx( "lariver_finished", "Land_water" );
	
//	if( self != level.team2_leader ) 
//	{
//		self thread magic_bullet_shield();
//		self delayThread( 10, ::stop_magic_bullet_shield );
//	}
	
}

lariver_play_anim_on_struct( guy, struct )
{
	scene = StrTok( struct.script_parameters, " " );//returns an array
	
	if( !isdefined( struct.angles ) )
		struct.angles = (0,0,0);
	
	guy thread lariver_play_anim_off_me( struct, scene[0] );
	
}


lariver_play_anim_off_me( ent, scene )
{
	flag_wait( "pipe_halfway" );
	if( isdefined( ent.script_noteworthy ) )
		if( ent.script_noteworthy == "gun_hide" ) 
			self gun_remove();

	self.animname = "generic";
	wait( randomfloatrange( .5, 1.5 ) );
	ent thread anim_single_solo( self, scene );
	
	if( isdefined( ent.script_delay ) ) //used to FastForward to a specific part of the anim
	{
		wait.05;
	   	time = ent.script_delay;
	   	self setAnimtime( getanim(scene), time );
	}
	
	//wait for anim to finish
	//ent waittill( scene );
	
}