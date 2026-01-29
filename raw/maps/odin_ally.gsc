#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


ally_start()
{
	maps\odin_util::move_player_to_start_point( "start_odin_ally" );
	//thread maps\odin_intro::tweak_off_axis_player();
	
	// Set up ally and the player
	level.ally gun_remove();
	level.ally.animname = "odin_ally";
	level.player DisableWeapons();

	flag_set( "player_approaching_infiltration" );
	flag_set( "invasion_clear" );
	
	// Move the ally over to our module, and start the pathing
	maps\odin_util::actor_teleport( level.ally, "odin_ally_tp" );
	thread maps\odin_intro::tweak_off_axis_player();
	
	flag_set( "clear_to_tweak_player" );
}

section_precache()
{
	PreCacheRumble( "heavy_1s" );
	PreCacheRumble( "light_1s" );
}

section_flag_init()
{
	flag_init( "ally_clear" );
	flag_init( "play_invader_scene" );
	flag_init( "invader_scene_begin" );
	flag_init( "odin_ally_appear" );
	flag_init( "teleport_struggle_actors" );
	flag_init( "sync_struggle_actors" );
	flag_init( "player_is_teleported" );
	flag_init( "start_player_animating" );
	flag_init( "centered" );
	flag_init( "first_encounter_dialogue" );
	flag_init( "start_struggle_rotate" );
	flag_init( "stop_struggle_rotate" );
	flag_init( "player_is_failing" );
	flag_init( "player_is_succeeding" );
	flag_init( "spin_player_and_enemy" );
	flag_init( "player_shoot_anims" );
	flag_init( "saved_ally" );
	flag_init( "ally_has_enemy" );
	flag_init( "teleport_player_to_z_trans" );
	flag_init( "player_second_z_turn" );
	flag_init( "clear_to_tweak_player" );

	// Door control
	flag_init( "lock_info_room" );
	flag_init( "unlock_info_room" );
	flag_init( "lock_shuttle_room" );
	flag_init( "lock_post_z_room" );
	flag_init( "unlock_post_z_room" );
	flag_init( "lock_intro_breach_door" );
	flag_init( "unlock_intro_breach_door" );
	flag_init( "lock_post_invasion_door1" );
	flag_init( "unlock_post_invasion_door1" );
	flag_init( "lock_post_invasion_door2" );
	flag_init( "unlock_post_invasion_door2" );
	
	//Dialogue Flags
	flag_init( "player_has_yet_to_shoot" );
	flag_init( "pre_monitors_enemy" );
	flag_init( "ally_gun_acquired" );
	flag_init( "player_is_at_monitor" );
	flag_init( "ally_leaves_monitor" );
	flag_init( "ally_about_to_throw_tank" );
}

section_hint_string_init()
{
}


//================================================================================================
//	MAIN
//================================================================================================
ally_main()
{
	//iprintlnbold( "Ally Checkpoint Begin" );
	thread maps\_space_player::player_location_check( "interior" );
	
	// Save
	autosave_by_name( "ally_begin" );
	
	// Do some checkpoint setup
	thread ally_setup();
//	thread struggle_rotate();
	thread ally_dialogue();
	
	// Start of logic scripts
	infiltration();
	
	autosave_by_name( "ally_infiltration" );
	
	// Shotgun scene
	hallway_encounter();
	
	autosave_by_name( "space_shotgun" );
	
	// Ally gets gun
	ally_gets_gun_sequence();

	flag_wait( "ally_clear" );
	//iprintlnbold( "Ally Checkpoint Clear" );
}

ally_setup()
{
	// Setup scripted doors
	thread maps\odin_util::create_sliding_space_door( "odin_ally_info_room_door", 1.2, 0.1, 0, false, "lock_info_room", "unlock_info_room" );
	thread maps\odin_util::create_sliding_space_door( "odin_ally_info_room_door_alt", 1.2, 0.1, 0.4, false, "lock_info_room", "unlock_info_room" );
	thread maps\odin_util::create_sliding_space_door( "odin_ally_shuttle_door", 1.2, 0.1, 0, false, "lock_shuttle_room" );
	thread maps\odin_util::create_sliding_space_door( "odin_ally_shuttle_door_alt", 1.2, 0.1, 0.4, false, "lock_shuttle_room" );
	thread maps\odin_util::create_sliding_space_door( "post_z_door", 1.2, 0.1, 0, false, "lock_post_z_room" , "unlock_post_z_room" );
	thread maps\odin_util::create_sliding_space_door( "intro_breach_door", 2.0, 0, 0, false, "lock_intro_breach_door" , "unlock_intro_breach_door" );
	thread maps\odin_util::create_sliding_space_door( "post_invasion_door1", .51, 0, 0, false, "lock_post_invasion_door1" , "unlock_post_invasion_door1" );
	thread maps\odin_util::create_sliding_space_door( "post_invasion_door2", 2.0, 0, 0, false, "lock_post_invasion_door2" , "unlock_post_invasion_door2" );
	
	// Escape checkpoint doors
	// Set these up early because they can be seen from this checkpoint
	thread maps\odin_escape::create_escape_doors();
}

ally_dialogue()
{
	flag_wait( "player_approaching_infiltration" );
	
	radio_dialogue_stop();
//	smart_radio_dialogue( "odin_cub_copypayload" );
//	//Cubby: Payload, we have hard dock…
	smart_radio_dialogue( "odin_cub_payloadwehavehard" );
//	//Cubby: …and you are parked - nice driving.
	smart_radio_dialogue( "odin_cub_andyouareparked" );
	//Cubby: I'm at Payload dock - equalizing…
	smart_radio_dialogue( "odin_cub_imatpayloaddock" );
//	//Cubby: Opening the seal…
//	if (!flag ( "play_invader_scene" ))
	smart_radio_dialogue( "odin_cub_openingtheseal" );

	wait RandomFloatRange( 0.5, 1.5 );
	flag_set( "invader_scene_begin" );
	
	radio_dialogue_stop();
	
	//Payload: (translated) Move in!
	smart_radio_dialogue( "odin_pyl_translatedmovein" );
//	//Cubby: Who are…?!
//	smart_radio_dialogue( "odin_cub_whoare" );
	//Payload: (translated) Kill everyone! Set firing sequence!
	smart_radio_dialogue( "odin_pyl_translatedkilleveryoneset" );
//	//Cubby: Aaahh! Nooo! Aggghhh!
//	smart_radio_dialogue( "odin_cub_aaahhnoooaggghhh" );
//	//Kyra: Cubby!? What happened?!
//	smart_radio_dialogue( "odin_kyr_cubbywhathappened" );
//	//Kyra: Is that gunfire!?
//	smart_radio_dialogue( "odin_kyr_isthatgunfire" );
//	//Cubby: Emergency! Foothold situation!
//	smart_radio_dialogue( "odin_cub_emergencyfoothold" );
//	//Cubby: Noo!!!
//	smart_radio_dialogue( "odin_cub_noo" );
	//Kyra: Cubby!
	smart_radio_dialogue( "odin_kyr_cubby" );
//	//Kyra: Bud - get back here now! We have foreign elements on ODIN!
//	smart_radio_dialogue( "odin_kyr_budgetbackhere" );
	//Atlas Main: ODIN Main, this is Atlas Main… Are you guys seeing some unusual activity?
	smart_radio_dialogue( "odin_atl_odinmainthisis" );
	flag_set( "invasion_clear" );
//	//Kyra: The oxygen mains… we're losing control of... *BOOM*
//	smart_radio_dialogue( "odin_kyr_theoxygenmainswere" );
	flag_wait( "first_encounter_dialogue" );
	//Kyra: No you don't!
	smart_radio_dialogue( "odin_kyr_noyoudont" );
	wait .7;
	//Kyra: Grab his gun!
	smart_radio_dialogue( "odin_kyr_grabhisgun" );
	flag_wait( "ally_has_enemy" );
	//Kyra: Shoot him!
	smart_radio_dialogue( "odin_kyr_shoothim" );
	flag_wait( "saved_ally" );
	//Kyra: Thanks!
	smart_radio_dialogue( "odin_kyr_thanks" );
//	//Kyra: The whole is station going down! Primary coolant offline and heat-pumps are critical.
//	smart_radio_dialogue( "odin_kyr_thewholeisstation" );
	//Kyra: We need an ops station!
	smart_radio_dialogue( "odin_kyr_weneedanopsstation" );

//	//Kyra: There's more of them!
//	smart_radio_dialogue( "odin_kyr_theresmoreofthem" );
	flag_wait( "ally_gun_acquired" );
	//Computer Voice: ROD firing sequence initiaing.
	smart_radio_dialogue( "odin_comp_rodfiringsequence" );
	//Kyra: They're initiating a Kinetic ROD firing sequence!
//	smart_radio_dialogue( "odin_kyr_theyreinitiatingakinetic" );
//	//Kyra: We need to get to Main Observation!
//	smart_radio_dialogue( "odin_kyr_weneedtoget" );
//	wait 2;
//	//Kyra: The station's main coolant has been breached! 
//	smart_radio_dialogue( "odin_kyr_thestationsmaincoolant" );
//	//Kyra: This whole station is going to rip apart!
//	smart_radio_dialogue( "odin_kyr_thiswholestationis" );
//	//Kyra: We need to move it!
//	smart_radio_dialogue( "odin_kyr_weneedtomove" );

}

squad_kill( squad )
{
	foreach ( guy in squad)
	{
		if( IsAlive( guy ) )
		{
			guy kill();
		}
	}
		
}

//================================================================================================
//	Odin Invasion Scene
//	This happens when the player first enters Odin
//================================================================================================
odin_invasion_scene()
{	
	//First, spawn our actors
	invaders 	= enemy_squad_spawn( "intro_bad_guys_" , 6 , 	"intro_bad_guys_tp_" );
	counter = 1;
	foreach ( invader in invaders)
	{
		invader.ignoreall = true;
		invader.animname = "odin_invader_0" + counter ;
		counter = counter + 1;
	}
	
	victims		= enemy_squad_spawn( "intro_room_victim_" , 2 , "intro_victim_tp_" );
	counter = 1;
	foreach ( victim in victims)
	{
		victim.animname = "odin_victim_0" + counter ;
		counter = counter + 1;
	}
		
	//Now, prepare to animate!
	animNode = GetEnt( "intro_breach_origin" , "targetname" );
	
	guys = [];
	guys["odin_invader_01" ] 	= invaders[0] ;
	guys["odin_invader_02" ] 	= invaders[1] ;
	guys["odin_invader_03" ] 	= invaders[2] ;
	guys["odin_invader_04" ] 	= invaders[3] ;
	guys["odin_invader_05" ] 	= invaders[4] ;
	guys["odin_invader_06" ] 	= invaders[5] ;
	guys["odin_victim_01" ] 		= victims[0] ;
	guys["odin_victim_02" ] 		= victims[1] ;
	
	animNode thread anim_first_frame( guys , "odin_infiltrate"  );
	
	flag_wait( "invader_scene_begin" );
	flag_set( "unlock_intro_breach_door" );
	
	animNode anim_single( guys , "odin_infiltrate"  );
	
	foreach ( victim in victims)
	{
			victim kill();
	}
	foreach ( invader in invaders)
	{
		invader Delete();
	}
	
	flag_wait( "invasion_clear" );
	
}

infiltration()
{
	level.ally thread ally_invasion_scene_approach();
	odin_invasion_scene();
}

ally_invasion_scene_approach()
{
	node = GetEnt( "anim_entrance_to_infiltrate", "script_noteworthy" );
	
	node notify( "stop_loop" );
	
	// Moving Kyra to the infiltration hatch door
	node anim_single_solo( self, "odin_infiltrate_kyra_to_door" );
	node thread anim_loop_solo( self, "odin_infiltrate_kyra_door_idle", "stop_loop" );
	
	flag_wait( "invader_scene_begin" );

	node notify( "stop_loop" );
	waittillframeend;
	
	// Play the ally's infiltration scene
	node anim_single_solo( self, "odin_infiltrate_kyra" );
	node thread anim_loop_solo( self, "odin_infiltrate_kyra_escape_idle", "stop_loop" );
	
	flag_wait( "invasion_clear" );
	
	node notify( "stop_loop" );
}

//================================================================================================
//	FIRST ENCOUNTER 
//	These are the functions that handle the first encounter/ gun struggle.
//================================================================================================
#using_animtree( "generic_human" );
hallway_encounter()
{
	level endon( "struggle_end" );
	
	//SPAWN ENEMY
	firstEnemy 		= spawn_anim_model( "odin_opfor" );
	firstEnemyHead	= GetEnt( "struggle_enemy_head" , "targetname" );
	origin			= firstEnemy GetTagOrigin( "J_Spine4" );
	angles 			= firstEnemy GetTagAngles( "J_Spine4" );
	firstEnemyHead.origin = origin;
	firstEnemyHead.angles = angles;	
	firstEnemyHead LinkTo( firstEnemy , "J_Spine4" );
	
	//Set up enemy's gun
	gun 			= getEnt( "struggle_gun" , "targetname" );
	gun.origin 	= firstEnemy GetTagOrigin( "tag_weapon_right" );
	gun.angles 	= firstEnemy GetTagAngles( "tag_weapon_right" );
	gun LinkTo( firstEnemy , "tag_weapon_right" );
	
	level.ally.ignoreall = true;
	level.ally PushPlayer( true );
	
	wait .01;
	
	//Spawn Player Rig
	player_rig = spawn_anim_model( "player_rig" );
	player_rig hide();
	thread struggle_rotate( firstEnemy , player_rig );
	//Setup for intro animations
	animNode 	= GetEnt( "gun_struggle_intro" , "targetname" );
	level.ally.animname = "odin_ally" ;
	firstEnemy.animname = "odin_opfor" ;
	
	guys 					= [];
	guys["odin_ally"] 		= level.ally;
	guys["odin_opfor"] 		= firstEnemy;
	
	node = GetNode( "pre_struggle_cover_node" , "targetname" );
	level.ally set_goal_radius( 2 );
	level.ally SetGoalNode( node );
	level.ally waittill( "goal" );
	flag_set( "unlock_post_invasion_door1" );
	wait .05;

	//TODO: Add the anim of Ally opening the door and moving into the gun_struggle_intro anim
	
	animNode anim_first_frame( guys , "gun_struggle_intro" );
	animNode anim_single( guys , "gun_struggle_intro" );

	animNode thread anim_loop_solo( level.ally , "gun_struggle_intro_loop" , "end_loops" );
	animNode thread anim_loop_solo( firstEnemy , "gun_struggle_intro_loop" , "end_loops" );
	
//	firstEnemy SetAnim( %odin_intro_to_weapon_struggle_loop_ally , 1 , 1 );
	//Play the anim of Kyra tossing the enemy towards you
	flag_wait( "gun_struggle_commence_trig" );
	flag_set( "first_encounter_dialogue" );
	animNode notify( "time_to_toss" );
	guys 					= [];
	guys["odin_ally"] 		= level.ally;
	guys["odin_opfor"] 		= firstEnemy;
	
	player = [];
	player[ "player_rig" ]	= player_rig;
	animNode anim_first_frame( player , "gun_struggle_intro_throw" );
	flag_set( "sync_struggle_actors" );
	animNode thread anim_single( guys , "gun_struggle_intro_throw" );
	level.ally disable_ai_color();
	
	//The player is pulled into the animation
	flag_wait( "start_player_animating" );
	
	opfor = [];
	opfor["odin_opfor"] = firstEnemy;
	
	arc = 0;
	level.player PlayerLinkToBlend ( player_rig , "tag_player" , .75 , .4 );
	wait .75;
	level.player PlayerLinkToDelta( player_rig , "tag_player" , 1 , 0 , 0 , 0 , 0 );
	player_rig show();
	animNode notify( "end_loops" );
	animNode anim_single( player , "gun_struggle_intro_throw" );
	
	animNode anim_first_frame( player , "odin_hallway_weapon_struggle_range_player" );
	animNode anim_first_frame( opfor , "odin_hallway_weapon_struggle_range_opfor" );

	firstEnemy SetAnim(level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_range_opfor" ], 1 , 0 , 0 );
	player_rig SetAnim(level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_range_player" ], 1 , 0 , 0 );	
	thread struggle_logic( player_rig, firstEnemy , level.ally );
	
	wait.01;		
}


start_struggle_spin( guy )
{
	flag_set( "spin_player_and_enemy" );
}

set_player_anim_flag( guy )
{
	flag_set( "start_player_animating" );
}

struggle_door_opens( guy)
{
	flag_set( "unlock_post_invasion_door2" );
}


//Controls the struggle minigame
struggle_logic( player_rig, firstEnemy , fake_ally )
{
	level endon( "struggle_end" );
	flag_set( "ally_has_enemy" );
	level.player SetCanDamage( false );

	//Variables
	gun 						= getEnt( "struggle_gun" , "targetname" );
	gunTarget					= getEnt( "struggle_gun_target" , "targetname" );
	blendTime					= .01;
	bCheck 						= false;
	multiplier					= 1;
	direction 					= "left";
	bFirstPush 					= false;
	XANIM          				= 0.1;
	xAnim_lerped 				= XANIM;
	lerp_rate 					= .4;
	level.struggle_anim_time 	= 0;
	multiplier 					= 2;
	bLtoR						= true;
	bRtoL						= false;
	iThroughCenterCounter		= 0;
	bInCenter					= false;
	bUsingMouse					= false;
	
	//Checks if the player is on gamepad or not
	if( level.player is_player_gamepad_enabled(  ) )
	{
	}
	else
	{
		bUsingMouse = true;
		level.player EnableMouseSteer( true );	
	}
	
	//Move the weapon into position
	gunTarget LinkTo( gun );
	gun.origin 	= player_rig GetTagOrigin( "tag_weapon" );
	gun.angles 	= player_rig GetTagAngles( "tag_weapon" );
	gun LinkTo( player_rig , "tag_weapon" );
	
	thread z_trans_player( player_rig );
	thread player_wins_struggle( firstEnemy , player_rig , fake_ally );
	thread space_shotgun_firing( firstEnemy , player_rig );
	//The gun struggle sequence.  This works by constantly forcing the player away from center randomly
	while(bCheck == false )
	{		
		input = level.player GetNormalizedCameraMovement();
		if( bUsingMouse == true )
		{
			input = input * -1 ;	
		}
		
		// CHAD - doing a pass at making it easier to fight, then goign to add difficulty settings
		// RANGE DEFINITIONS - Outside Left = 0 to 0.2
		// RANGE DEFINITIONS - Inside Left = 0.2 to 0.398
		// RANGE DEFINITIONS - Center = 0.398 to 0.574
		// RANGE DEFINITIONS - Inside Right = 0.574 to 0.7
		// RANGE DEFINITIONS - Outside Right = 0.7 to 1.0

		//IPrintLnBold ("location="+level.struggle_anim_time);//+", input="+input[1]);
		//IPrintLnBold ("multiplier="+multiplier);
		//Check if the player is on the outside areas
		//if( level.struggle_anim_time <= .2 || level.struggle_anim_time >= .7 && input[1] > .15 )
		if( level.struggle_anim_time <= .2 || level.struggle_anim_time >= .7 )
		{
			//IPrintLnBold ("outside range");
			multiplier 	=  2.6;
			//multiplier 	=  1.25;
		}
		
		//Check if the player is passing through the left before the next trip through center
		if( level.struggle_anim_time > .2 && level.struggle_anim_time < .398 && input[1] > .15 )
		{
			//IPrintLnBold ("close right");
			bLtoR		= true;
			bRtoL		= false;
			multiplier 	= 0.5;
			level.player PlayRumbleOnEntity( "light_1s" );
		}
		
		//Check if the player is passing through the right before the next trip through center
		if( level.struggle_anim_time > .574 && level.struggle_anim_time < .7 && input[1] < -.15 )
		{
			//IPrintLnBold ("close left");
			bLtoR		= false;
			bRtoL		= true;
			multiplier 	= 0.5;
			level.player PlayRumbleOnEntity( "light_1s" );
		}
		
		// Player is near the Center
		if( level.struggle_anim_time > .4 && level.struggle_anim_time < .55 && bLtoR == true )
		{
			//IPrintLnBold ("center");
			multiplier = 3 - iThroughCenterCounter;
			level.player PlayRumbleOnEntity( "heavy_1s" );
		}
		
		if( level.struggle_anim_time > .4 && level.struggle_anim_time < .55 && bRtoL == true )
		{
			//IPrintLnBold ("center");
			multiplier = 3 - iThroughCenterCounter;
			level.player PlayRumbleOnEntity( "heavy_1s" );
		}
		
		//This if statement checks if the player has re-entered the "center" and adjust the difficulty accordingly
		if( level.struggle_anim_time > .4 && level.struggle_anim_time < .55 )
		{
			// Force some pushing by enemy if in center range
			if ( level.struggle_anim_time > .47)
			{
				//IPrintLnBold ("enemy pushes right");
				level.struggle_anim_time = level.struggle_anim_time  + (0.3-iThroughCenterCounter*0.1);
			}
			else
			{
				//IPrintLnBold ("enemy pushes left");
				level.struggle_anim_time = level.struggle_anim_time  - (0.3-iThroughCenterCounter*0.1);
			}

			if( bInCenter == false )
			{
				bInCenter = true;
				if( iThroughCenterCounter <= 1.5 )
				{
					iThroughCenterCounter = iThroughCenterCounter + .5;
				}
			}
		}
		else
		{
			bInCenter = false;
		}
		
		xAnim = input[1] * multiplier ;
		
		//Check if the player is pressing the right input
		if( level.struggle_anim_time <= .4 && input[1] < .15 )
		{
			XANIM = -.9 * 2 ;
		}
		
		//Check if the player is pressing the left input
		if( level.struggle_anim_time >= .55 && input[1] > -.15 )
		{
			XANIM = .9 * 2 ;
		}
		
		xAnim_lerped = xAnim_lerped + ( ( XANIM - xAnim_lerped ) * lerp_rate );
		
		thread enemy_struggle_anim( firstEnemy , blendTime, xAnim_lerped );
		thread player_struggle_anim( player_rig , blendTime, xAnim_lerped );
		wait blendTime;
		ScreenShake( level.player.origin , .25, 1, .1 , .25 );
	}
	
}

#using_animtree( "generic_human" );
enemy_struggle_anim( enemy , time, xAnim_lerped )
{
	enemy SetAnim( level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_range_opfor" ] , 1 , time , xAnim_lerped );
}

#using_animtree( "player" );
player_struggle_anim( player_rig , time, xAnim_lerped )
{
	player_rig SetAnim( level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_range_player" ] , 1 , time , xAnim_lerped  );
	level.struggle_anim_time = player_rig GetAnimTime( %odin_hallway_weapon_struggle_range_player );
}


//Function for the firing mechanics of Space shotgun
space_shotgun_firing( firstEnemy , player_rig )
{
	level endon( "struggle_end" );
	flag_set( "player_has_yet_to_shoot" );
	gun 		= GetEnt( "struggle_gun" , "targetname" );
	gun_target 	= GetEnt( "struggle_gun_target" , "targetname" );
	gun_target LinkTo( gun );
	timer 		= GetTime();
	shoot_time 	= timer - 500;
	shots_fired = 0;
	fail_timer 	= GetTime() - 6000;
	check_timer = GetTime();

	bTriggerHeld = false;
	bCanFire = true;
	
	while(1)
	{		
		if( bCanFire == true && level.player AttackButtonPressed() )
		{
			fail_timer = GetTime() - 9000;
			shoot_time = GetTime() - 500;
			if( shoot_time >= timer )
			{
				MagicBullet( "kriss_space_projectile" , gun GetTagOrigin( "tag_flash" ) , gun_target.origin , level.player );
				thread maps\odin_audio::sfx_distant_explo( level.player );
				PlayFXOnTag( getfx( "xm25_explosion" ), gun, "tag_flash" );
				timer = GetTime();
				shoot_time = timer - 500;
				shots_fired = shots_fired + 1;
				thread space_stuggle_enemy_death();
			}
	
			//TODO: Put fail timer back in
	//		if(shots_fired == 25 || fail_timer >= check_timer )
	//		{
	//			IPrintLnBold( "Enemy pushes the player away and shoots him dead" );
	//			wait .25;
	//			level.player kill();
	//			return;
	//		}
		}
		if( level.player AttackButtonPressed( true ) )
		{
			bCanFire = false ;			
		}
		else 
		{
			bCanFire = true ;	
		}
		
	wait .01;
	}
}
//Function to check for and handle the player's success
space_stuggle_enemy_death()
{
	if( level.struggle_anim_time > .425 && level.struggle_anim_time < .535  )
	{
		level notify( "struggle_end" );
		flag_clear( "player_is_failing" );
		flag_clear( "player_is_succeeding" );
		flag_set( "player_shoot_anims" );
		flag_set( "stop_struggle_rotate" );
		gun = GetEnt( "struggle_gun" , "targetname" );
		gun delete();
	}
}

//Wraps up the gun struggle moment and segues into Z_Trans
player_wins_struggle( firstEnemy , player_rig , fake_ally )
{
	flag_wait( "player_shoot_anims" );
	flag_set( "saved_ally" );

	thread struggle_succeed_slowmo();
	thread struggle_succeed_fx( firstEnemy );

	thread z_trans( player_rig , firstEnemy , fake_ally );
	node1_hall1 = GetEnt( "struggle_rotate_hinge" , "targetname" );		//The node in the spinning hallway
	
	node1_hall1 RotateTo( ( 0 , 270 , 0 ) , 1.5);
	
	guys = [];
	guys["player_rig"] = player_rig;
	guys["odin_opfor"] = firstEnemy;
	
//	node1_hall1 anim_first_frame( guys , "odin_hallway_weapon_struggle_shoot" );
	node1_hall1 anim_single( guys , "odin_hallway_weapon_struggle_shoot" );

	flag_set( "teleport_player_to_z_trans" );	
	level.player SetCanDamage( true );


}

struggle_succeed_fx( firstEnemy )
{
	level.player playsound( "scn_odin_pod_explosion" );
	firstEnemyHead	= GetEnt( "struggle_enemy_head" , "targetname" );
    struggle_fx_tag = spawn_tag_origin();
    struggle_fx_tag.origin = firstEnemyHead.origin;
    struggle_fx_tag LinkTo ( firstEnemyHead );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), struggle_fx_tag, "tag_origin" ); 
	PlayFXOnTag( getfx( "sp_blood_float" ), struggle_fx_tag, "tag_origin" );
	PlayFXOnTag( getfx( "factory_roof_steam_small_01" ), struggle_fx_tag, "tag_origin" );
}

struggle_succeed_slowmo()
{
	// Start slo motion
	slowmo_speed = 0.20;
	slowmo_setspeed_slow( slowmo_speed );
	slowmo_setlerptime_in( 0.2 );
	slowmo_lerp_in();
	
	level.player SetMoveSpeedScale( 0.3 );
	 
	real_time = 0.3;
	wait real_time;
	
	// Stop slow motion
	slowmo_setlerptime_out( 1.65 );
	slowmo_lerp_out();
	slowmo_end();

}

struggle_rotate( firstEnemy , player_rig )
{
	level endon( "struggle_end" );
	hinge 		= GetEnt( "struggle_rotate_hinge" , "targetname" );
	bcheck = false;
	flag_wait( "spin_player_and_enemy" );
	player_rig LinkTo( hinge );
	firstEnemy LinkTo( hinge );
	
	hinge RotatePitch( -90 , 1 , 1 , 0 );	//The initial roll
	wait 1;
	while( !flag( "saved_ally" ) ) 			//While loop keeps the hall rotating
	{
		hinge RotatePitch( -5400 , 60 , 0 , 0 );
		wait 60;		
	}
	angle = ( hinge.angles[2] / 360 ) * - 1 ;
	
	while( bCheck == false )
	{
		if( (angle - 1) > 0 )
		{
			angle = angle - 1;	
		}
		else
		{
			bCheck = true;	
		}
	}
	

		

//	if( angle >= .5 )
//	{
//		if(angle > .8 )
//		{
//			newRotation = maps\odin_util::factor_value_min_max( 0, 360, maps\odin_util::normalize_value( 0, 1, angle ));
//			hinge RotateRoll( (-360 + newRotation ) , 1 ,0 , 1 );	
//		}
//		else
//		{
//			newRotation = maps\odin_util::factor_value_min_max( 0, 360, maps\odin_util::normalize_value( 0, 1, angle ));
//			hinge RotateRoll( (-360 + newRotation ) , 1.25 ,0 , 1.25 );	
//		}
//		
//	}
//	else
//	{
//		if( angle < .3 )
//		{
//			newRotation = maps\odin_util::factor_value_min_max( 0, 360, maps\odin_util::normalize_value( 0, 1, angle ));
//			hinge RotateRoll( newRotation , 1 ,0 , 1 );	
//		}
//		else
//		{
//			newRotation = maps\odin_util::factor_value_min_max( 0, 360, maps\odin_util::normalize_value( 0, 1, angle ));
//			hinge RotateRoll( newRotation , 1.25 ,0 , 1.25 );	
//		}
//		
//	}
}
 
//================================================================================================
// Post Struggle Z-Trans
//================================================================================================
z_trans( player_rig , firstEnemy , fake_ally )
{
	spawner = GetEnt( "ally_doppleganger1" , "targetname" );
	fake_ally = spawner spawn_ai();
	fake_ally.ignoreall = true;
	fake_ally.animname = "odin_ally" ;
	
	
	level.ally disable_ai_color();
	//Variables
	node1_hall1 = GetEnt( "z_trans_hinge_a" , "targetname" );		//The node in the spinning hallway
	node1_hall2 = GetEnt( "z_trans_2_1_node" , "targetname" );		//The first node of the detatched, turned hallway
	node2_hall2 = GetEnt( "z_trans_2_2_node" , "targetname" );		//The second node of the detatched, turned hallway
	node1_hall3 = GetEnt( "z_trans_final_node" , "targetname" );	//The final node, found in the proper play space
	struggle_hall	= GetEntArray( "z_trans_test" , "targetname" );
	
	//Prepares actors
	ally 		= [];
	fakeally 	= [];
	enemy 		= [];
	
	ally["odin_ally"]		= level.ally;
	fakeally["odin_ally"]	= fake_ally;
	
	//Z-Trans 1
	node1_hall1 anim_first_frame( ally , "odin_hall_escape_turn01_ally" );
	node1_hall2 anim_first_frame( fakeally , "odin_hall_escape_turn01_ally" );

	node1_hall1 thread anim_single( ally , "odin_hall_escape_turn01_ally" );	//No thread to prevent fallthrough
	node1_hall2 anim_single( fakeally , "odin_hall_escape_turn01_ally" );
	
	node1_hall3 anim_first_frame( ally , "odin_hall_escape_turn02_ally" );
	
	node1_hall3 thread anim_single( ally , "odin_hall_escape_turn02_ally" );
	node2_hall2 anim_single( fakeally , "odin_hall_escape_turn02_ally" ); //No thread to prevent fallthrough
	
	//Clean-Up
	level.ally Unlink();
	level.ally SetGoalPos( level.ally.origin );
	level.ally enable_ai_color();
	maps\odin_util::safe_trigger_by_targetname( "ally_pre_get_gun_position" );
	
	fake_ally Delete();
	firstEnemy delete();
	
	foreach ( piece in struggle_hall)
	{
		piece Delete();
	}
}

z_trans_player( player_rig )
{
	flag_clear( "clear_to_tweak_player" );
	
	//Variables
	node1_hall1 = GetEnt( "z_trans_hinge_a" , "targetname" );		//The node in the spinning hallway
	node1_hall2 = GetEnt( "z_trans_2_1_node" , "targetname" );		//The first node of the detatched, turned hallway
	node2_hall2 = GetEnt( "z_trans_2_2_node" , "targetname" );		//The second node of the detatched, turned hallway
	node1_hall3 = GetEnt( "z_trans_final_node" , "targetname" );	//The final node, found in the proper play space
	
	//Spawn the second player rig
	player_rig2	= spawn_anim_model( "player_rig" );
	
	//Prepares actors
	player 		= [];
	player2		= [];
	
	player["player_rig"] 	= player_rig;
	player2["player_rig"]	= player_rig2;
	
	node1_hall2 anim_first_frame( player2 , "odin_hall_escape_turn01_player" );
	newOrigin = player_rig2 GetTagOrigin( "tag_player" );
	newAngles = player_rig2 GetTagAngles( "tag_player" );
	
	flag_wait( "teleport_player_to_z_trans" );
	//Z-Trans 1		
	level.player SetPlayerAngles( newAngles );
	level.player SetOrigin( newOrigin );
	
	ARC = 0;
	level.player PlayerLinkToDelta( player_rig2 , "tag_player" , 1 ,ARC , ARC , ARC , ARC , true );
	node1_hall2 anim_single( player2 , "odin_hall_escape_turn01_player" );
	player_rig hide();
	player_rig2 hide();
	
	level.player Unlink();
	level.player EnableWeapons();
	node2_hall2 anim_first_frame( player2 , "odin_hall_escape_turn02_player" );
	node1_hall3 anim_first_frame( player , "odin_hall_escape_turn02_player" );
		
	newOrigin = player_rig GetTagOrigin( "tag_player" );
	newAngles = player_rig GetTagAngles( "tag_player" );
	
	player_rig Show();
		
	flag_wait( "player_second_z_turn" );
	level.player DisableWeapons();
	
	level.player PlayerLinkToBlend( player_rig2 , "tag_player" , .5 );
	wait .5;
	level.player SetPlayerAngles( newAngles );
	level.player SetOrigin( newOrigin );
	
	level.player PlayerLinkToDelta( player_rig , "tag_player" , 1 ,ARC , ARC , ARC , ARC , true);
	node1_hall3 anim_single( player , "odin_hall_escape_turn02_player" );
	level.player Unlink();
	level.player EnableWeapons();
	flag_set( "unlock_post_z_room" );
	flag_set( "move_ambush_guy_forward" );
	
	player_rig delete();
	player_rig2 delete();
	
}

set_player_teleport_flag( guy )
{
//	flag_set( "teleport_player_to_z_trans" );
}

//Utility for the above function to shorten the code some
hinge_connector( array, hinge )
{
	foreach ( piece in array)
	{
		if( piece.classname == "script_brushmodel" || piece.classname == "script_model" )
		{
			piece unlink();
			piece LinkTo( hinge );
		}
	}	
}

//================================================================================================
// Ally Gets Gun Encounter
//================================================================================================
ally_gets_gun_sequence()
{
	// Spawn the ambusher enemy
	ambush_guy = maps\odin_util::spawn_odin_actor( "pre_monitors_enemy_01" );
	ambush_guy.health = 25;
	ambush_guy.fixednode = true;
	ambush_guy.fixednodesaferadius = 0;
	ambush_guy.ignoreall = true;
	ambush_guy.moveplaybackrate = 1.2;
	
	// Spawn a second enemy that is distracted by something on the interior hull wall
	backup_guy = maps\odin_util::spawn_odin_actor( "pre_monitors_enemy_02", true );
	backup_guy.health = 75;
	backup_guy.moveplaybackrate = 1.2;
	
	//Function handles a case where player shoots backup guy first
	thread backup_guy_ai_help( backup_guy , ambush_guy );
	
	//Move the weapon ally picks up to the enemy
	shotgun = getEnt( "allys_new_gun" , "targetname" );
	gun_origin = backup_guy GetTagOrigin( "tag_weapon" );
	gun_angles = backup_guy GetTagAngles( "tag_weapon" );
	shotgun.origin = gun_origin;
	shotgun LinkTo( backup_guy , "tag_weapon" );
	shotgun Hide();
	
	level.ally set_ignoreall( true );
	wait 3.5;
	flag_set( "pre_monitors_enemy" ); // Flag triggers ally reaction VO
	
	flag_wait( "move_ambush_guy_forward" );
	// Move the ambusher up
	goal_node = GetNode( "pre_com_room_enemy_ambush_goal", "targetname" );
	ambush_guy SetGoalNode( goal_node );
	
//	// When player enters room, move ally up into the room
	//DS - Commented out because the player could kill both enemies from the doorway, and we don't want this to fire
//	flag_wait( "player_entered_pre_com_room" );
//	maps\odin_util::safe_trigger_by_targetname( "ally_get_gun_position" );

	// Wait for guy the second guy to die
	backup_guy waittill( "death" );

	// Have ally go and grab the gun
	shotgun show();
	wait .01;
	shotgun Unlink();
	wait .1;
	ally_gun_destination = GetEnt( "ally_gun_destination" , "targetname" );
	shotgun MoveTo( ally_gun_destination.origin , 3 , 0 , 3 );
	wait .5;
	level.ally SetGoalPos( ally_gun_destination.origin );
	level.ally waittill( "goal" );
	flag_set( "ally_gun_acquired" );
	wait .5;
	shotgun Delete();
	level.ally gun_recall();
	level.ally enable_ai_color();
	wait .5;
	flag_set( "ally_clear" );
}

//Used so we can fall through to monitor section if backup guy dies first
backup_guy_ai_help( backup_guy , ambush_guy )
{
	ambush_guy waittill( "death" );
	if( IsAlive(  backup_guy  ) )
	{
		backup_guy anim_stopanimscripted();	
		//wait for the ambusher to die and movebackup guy into cover
		node = getNode( "pre_mon_backup_cover" , "targetname" );
		backup_guy SetGoalNode( node );
	}
	
}


//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
ally_cleanup( force_immediate_cleanup )
{
}

//Handles spawning of AI groups
enemy_squad_spawn( spawner_group , numberToSpawn , group_tp )
{
	squad = [];
	bCheck = false;
	for( i = 0 ; i < numberToSpawn ; i++ )
	{
		spawner = GetEnt( spawner_group + i , "targetname" );
		
		guy = spawner spawn_ai();
		squad[i] = guy;
		guy make_swimmer();
		maps\odin_util::actor_teleport( guy, group_tp + i );
		guy thread maps\_space_ai::handle_angled_nodes();
	}
	return squad; 
}

make_swimmer()
{
	if ( self.team == "allies" )
		return;
	if ( self.type == "dog" )
		return;
	
	if ( !isdefined( self.swimmer ) || self.swimmer == 0 )
        self thread maps\_space_ai::enable_space();
}