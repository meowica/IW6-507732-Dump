#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

final_init()
{
	
}
	
final_main()
{
	kill_spawners_per_checkpoint( "final" );
	final_script();
	
	nextmission();
}

final_script()
{		
	// fire missile
	//flag_set( "satfarm_missile_strike" );
	//missile_strike();
	
	// spawning
	//spawn_player_checkpoint( "final_" );
		
	//spawn_heroes_checkpoint( "final_" );
	
	//spawn_vehicles_from_targetname_and_drive( "final_allies1" );
	
	player_gets_shot_down();
	thread player_makes_run();
	player_enters_allied_tank();
	begin_rail();
	
	//level.playertank.angles = (0, 165, 0 );
	//level.player SetPlayerAngles( (0, 165, 0 ) );
	
	flag_wait( "missile_strike_now" );
	
	missile_effect();
	//slamzoom_end();
	
	wait 1;
	maps\_hud_util::fade_out( 3 );
	wait 2;
}

player_gets_shot_down()
{
	// the hit
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "final_" );
		thread maps\satfarm_complex::hangar_wall_smash_setup();
		thread create_missile_attractor();
	}
		
	start  			= getstruct( "a10_player_start", "targetname" );
	newMissile	  	= MagicBullet( "javelin_dcburn", start.origin, level.player.origin );
//	newMissile SetEntityOwner( level.missilefire );
	newMissile Missile_SetTargetEnt( level.missilehit );
	newMissile Missile_SetFlightmodeTop();
	
	level.player thread play_loop_sound_on_entity( "missile_incoming" );
	newMissile 	waittill( "death" );
	level.player thread stop_loop_sound_on_entity( "missile_incoming" );
	waitframe();
	
	thread player_gets_shot_down_vo();
	
	level.player DigitalDistortSetParams( .5, 1 );
	waitframe();	
//	PlayFXOnTag( getfx( "tank_heavy_smoke" ), level.playertank, "tag_turret" );
	//wait 1;
	
	// spawn final tank in new location if starting from an earlier checkpoint
	level.playertank dismount_tank( level.player, 1, .25 );
	level.playertank delete();
	
	spawn_player_checkpoint( "final_" );
	level.playertank turn_on_the_tanks_lights();
		
//	thread cleanup_complex();
	
	// spawn in enemy tanks for ambience
	level.enemytanks 	= spawn_vehicles_from_targetname_and_drive( "final_tank_enemies" );
	level.finalgazs 	= spawn_vehicles_from_targetname_and_drive( "final_gaz_fire1" );
	array_thread( level.enemytanks, ::npc_tank_combat_init );
	array_thread( level.enemytanks, ::set_override_offset, ( 0, 0, 128 ) );
	thread mortar_strikes();
	
	hero2 = spawn_vehicles_from_targetname_and_drive( "final_hero2" );
	array_combine( level.allytanks, hero2 );
	array_thread( hero2, ::npc_tank_combat_init );
	
	hero3 = spawn_vehicle_from_targetname_and_drive( "final_hero3" );
	level.herotanks[ 2 ] = hero3;
	array_add( level.allytanks, hero3 );
	hero3 npc_tank_combat_init();
	
	array_thread( level.enemytanks, ::set_override_target, hero3 );
	
	// off tank controls
	level.playertank tank_spawn_crew();
	level.playertank dismount_tank( level.player, 1, .5 );
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	
	Earthquake( 1, 3, level.playertank.origin, 400 );
	level.player ShellShock( "hamburg_blackout", 10 );
	level.player PainVisionOn();
	
	intermediate = spawn_tag_origin();
	
	offset = ( 10, -4, -16 );
	intermediate.origin = level.playertank GetTagOrigin( "tag_guy0" );
	intermediate.angles = level.playertank GetTagAngles( "tag_guy0" );
	intermediate LinkTo( level.playertank, "tag_guy0", offset, ( 0, 0, 0 ) );
	
	level.player allowprone(  false );
	level.player AllowCrouch( true  );
	level.player AllowStand(  false );
	level.player SetStance( "crouch" );
	wait 0.5;
	level.player PlayerLinkToDelta( intermediate, "tag_origin", 0, 30, 60, 30, 30 );
	
	wait 4;
	
	maps\_hud_util::fade_out( 1 );
	wait 1.5;
	
	//setup next scene.
    foreach( crew_member in level.playertank.drones_crew )
    {
    	//crew_member nofity();
    	crew_member.animname = "dead";
    	crew_member thread anim_loop_solo( crew_member, "paris_npc_dead_poses_v24_chair_sq" );
    }
    
    player_rig 		= spawn_anim_model( "player_rig", 		level.playertank.origin );
//	player_rig_gun 	= spawn_anim_model( "player_rig_gun", 	level.playertank.origin );
	player_rig_legs = spawn_anim_model( "player_rig_legs", 	level.playertank.origin );
	
	level.player PlayerLinkToDeltaBlend( 0.3, 0, 0, player_rig, "tag_player", 1, 60, 20, 80, 20, false);
	
	guys = [ player_rig, player_rig_legs ]; //, player_rig_gun ];
	array_call( guys, ::Hide );
	level.playertank anim_first_frame( guys , "garage_crash_exit", "tag_guy0" );
	
	level.player allowstand( true );
	level.player allowcrouch( false );
	level.player allowprone( false );
	level.player SetStance( "stand" );
    
	waver = spawn_targetname( "tank_crew_2a", 1 );
	level.waver = waver;
	waver magic_bullet_shield();
	waver.goalradius = 32;
	waver.ignoreexplosionevents = true;
	waver.grenadeawareness = 0;
	waver.disablearrivals = true;
	waver.moveTransitionRate = 1;
	waver.notarget = true;
	//waver.ignoreme = true;
	waver.ignoresuppression = true;
	waver.suppressionwait = 0;
	waver.disableBulletWhizbyReaction = true;
	waver.ignorerandombulletdamage = true;
	waver thread disable_pain();
	waver thread disable_surprise();
	waver AllowedStances( "stand" );
	waver.badplaceawareness = 0;
	waver.moveplaybackrate = 1.25;
	waver.animname = "ally";
	waver thread anim_loop_solo( waver, "clockwork_chaos_wave_guard", "move_on" );
	
	wait 2;
	maps\_hud_util::fade_in(  .5 );
	
	Objective_Complete( obj( "mantis") );
	waitframe();
	Objective_Add( obj( "escape" ), "current", "Escape." );
	
	// exit vehicle
	level.player PainVisionoff();
    wait 2;
	level.waver char_dialog_add_and_go( "satfarm_bgr_moveyourasssoldier" );
	
	end_message = "exit_tank_button";
	level.player NotifyOnPlayerCommand( end_message, "+gostand" );
	level.player NotifyOnPlayerCommand( end_message, "+usereload" );
	level.player NotifyOnPlayerCommand( end_message, "+stance" );
	do_exit_wait_on_movement( end_message );
	thread hint_fade();
	
	array_call( guys, ::Show );
	level.player PlayerLinkToDeltaBlend( 1, .25, 0, player_rig, "tag_player", 1, 0, 0, 0, 0, true );
	level.playertank thread anim_single( guys , "garage_crash_exit", "tag_guy0" );
	
	wait 2;

	waver notify( "move_on" );
	waver thread runner_anims();
	//level.player EnableInvulnerability();
	level.player enabledeathshield(true);
	
	wait 2;
	
	spawn_heroes_checkpoint( "final_" );
	level.allytanks[ 0 ] npc_tank_combat_init();
	level.badger tank_spawn_crew();
	
	player_rig  waittillmatch( "single anim", "end" );
	
	level.player.disableReload = true;
	level.player GiveWeapon( "freerunner" );
	level.player switchtoWeapon( "freerunner");
	level.player disableWeaponSwitch();
	
	level.playertank turn_off_the_tanks_lights();
	
	level.player Unlink();
	array_delete( guys );
	
	//teleport_player( getstruct( "exit_tank", "targetname" ) );
	//level.player lerp_player_view_to_position( set_z( level.player.origin, -245.875), level.player getplayerangles(), 0.3,1,5,5,5,5,false );
	level.player AllowSprint( true );
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	
	foreach( hero in hero2 )
	{
		if( IsDefined( hero ) )
			hero kill();
		
		wait RandomFloatRange( 1, 4 );
	}
}

player_gets_shot_down_vo()
{
	radio_dialog_add_and_go( "satfarm_bgr_werehit" );
	radio_dialog_add_and_go( "satfarm_bdg2_stilloperationalgetus" );
	
	wait 4;
	
	thread add_dialogue_line( "Overlord", "All callsigns. Evacute the area. Payload is inbound to your coordinates." );
	wait 3;
	thread add_dialogue_line( "Overlord", "Repeat. Payload is inbound."  );
	thread radio_dialog_add_and_go( "satfarm_bgr_boomerreport" );
	wait 2;
	level.waver char_dialog_add_and_go( "satfarm_bct_boomerisnonoperational" );
	radio_dialog_add_and_go( "satfarm_bgr_oneofthecrew" );
	thread radio_dialog_add_and_go( "satfarm_bgr_movingintopickup" );
}
	
runner_anims()
{
	self anim_stopanimscripted();
	
	self.animname = "ally";
	self.moveplaybackrate = 1.2;
	
	struct = getstruct( "final_ally_exit_tank", "targetname" );
	struct anim_reach_solo(  self, "traverse_jumpdown_96" );
	struct anim_single_solo( self, "traverse_jumpdown_96" );
	
	wait 1;
	
	level.waver thread char_dialog_add_and_go( "satfarm_bgr_keeprunning" );
	struct = getstruct( "final_ally_exit_tank_run1", "targetname" );
	struct anim_reach_solo(  self, "payback_escape_start_wave_soap" );
	struct anim_single_solo( self, "payback_escape_start_wave_soap" );
	
//	struct = getstruct( "final_ally_exit_tank_run2", "targetname" );
//	struct anim_reach_solo(  self, "run_react_stumble" );
//	struct anim_single_solo( self, "run_react_stumble" );
//	
//	struct = getstruct( "final_ally_exit_tank_run3", "targetname" );
//	struct anim_reach_solo(  self, "run_react_duck" );
//	struct anim_single_solo( self, "run_react_duck" );
	
	struct = getstruct( "final_ally_exit_tank_run5", "targetname" );
	struct anim_reach_solo(  self, "payback_escape_forward_wave_right_price" );
	struct anim_single_solo( self, "payback_escape_forward_wave_right_price" );
	
	thread radio_dialog_add_and_go( "satfarm_bgr_getonthetank" );
//	struct = getstruct( "final_ally_exit_tank_run5", "targetname" );
//	struct anim_reach_solo(  self, "run_react_stumble" );
//	struct anim_single_solo( self, "run_react_stumble" );
	
	struct = getstruct( "final_ally_exit_tank_run6", "targetname" );
//	struct anim_reach_solo(  self, "longdeath_wander_leg_1" );
//	struct anim_single_solo( self, "longdeath_wander_leg_1" );
	fxTag 			= spawn_tag_origin();
	fxTag.origin 	= drop_to_ground( struct.origin );
	fxTag.angles	= (-90,0,0);
	
	playfxontag( getfx( "mortar" ), fxTag, "tag_origin" );
	EarthQuake( .2, .5, level.player.origin, 512 );
	thread play_sound_in_space( "mortar_explosion_intro", fxTag.origin );
	PlayRumbleOnPosition( "damage_heavy", fxTag.origin );
	self thread anim_single_solo( self, "death_explosion_run_F_v1" );
	
	wait 1;
	fxTag delete();
	self stop_magic_bullet_shield();
	self kill();
}

player_makes_run()
{
	thread smokelaunchbadger();
	
	wait 1;
	
	thread stumble_run();
	
	thread view_kick();
	
	thread kill_timer();
}

player_enters_allied_tank()
{
	rail = getstruct( "glowy_bit", "targetname" );
	shinybit = level.playertank spawn_tag_origin();
	shinybit.origin = rail.origin;
	shinybit.angles = rail.angles;
	shinybit SetModel ( "vehicle_m1a1_abrams_minigun_shiny_part" );
	shinybit Show();
//	shinybit LinkTo( level.playertank, "tag_shiny_part_attach", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	oldtank = level.playertank;
	level.playertank = level.badger;
	
	//old use trigger
//    trigger = GetEnt( "mount_tank", "targetname" );
//    trigger UseTriggerRequireLookAt();
//    
//    trigger SetCursorHint( "HINT_ACTIVATE" );
//    trigger SetHintString( "Hold [{+usereload}] to mount." );
//    
////	thread nag_p0layer_get_on_tank();
//    
//    trigger waittill ( "trigger" );

	flag_wait( "mount_tank" );
//	level.playertank ShowPart( "tag_not_shiny_part" );
	shinybit Delete();
    flag_set( "final_mounting_tank" );
    
	minigun 		= spawn_anim_model( "minigun_m1a1" );
	player_rig 		= spawn_anim_model( "player_rig" );
	player_rig_legs = spawn_anim_model( "player_rig_legs" );

	//level.playertank SetModel( "vehicle_m1a1_abrams_viewmodel" );
	//level.playertank thread kill_the_minigun_guy();

	//level.playertank maps\_vehicle_aianim::delete_corpses_around_vehicle();

	//level.playertank get_rid_of_tanks_mg();
	//level.playertank vehicle_scripts\_m1a1_player_control::tank_spawn_crew();
	level.playertank.mgturret[ 1 ] hide();
	
	guys = [];
	guys[ guys.size ] = player_rig;
	guys[ guys.size ] = player_rig_legs;
	
	level.player DisableWeapons();
	level.player DontInterpolate();
	level.player allowstand( true );
	level.player allowcrouch( false );
	level.player allowprone( false );
	level.player SetStance( "stand" );
	
	//level.player LerpFOV( 55, 3.15 );
	
	//hacking 90 degree offset
	intermediate = level.playertank spawn_tag_origin();
	minigun LinkTo( intermediate, "tag_origin", (0,0,0), (0,0,0));
	intermediate LinkTo( level.playertank , "tag_turret_mg_r", (0,0,0), (0,0,0));
	intermediate thread anim_single_solo( minigun, "mount_tank", "tag_origin" );	
	
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.3 );
	foreach( guy in guys )
		guy LinkTo( level.playertank, "tag_guy0" );
	level.playertank anim_single( guys, "mount_tank", "tag_guy0" );	
	
	level.playertank.mgturret[ 1 ] show();
	array_delete( guys );
	minigun delete();
	intermediate delete();
}

begin_rail()
{
	// let other script resolve.
	waittillframeend;
	
	flag_set( "final_rail" );
	
	thread begin_rail_vo();
	
	//level thread maps\satfarm_audio::complex_expl();
	
	foreach( gaz in level.finalgazs )
	{
		if( IsDefined( gaz ) )
		{
			gaz godoff();
			//gaz kill();
		}
	}
	
	//	attach player to vehicle and turret
	level.player PlayerLinkToDelta( level.playertank, "tag_turret_mg_r", 0, 180, 180, 30, 15 );
	
	turret = level.playertank.mgturret[ 1 ];
	thread maps\_minigun_viewmodel::player_viewhands_minigun( turret, "viewhands_player_delta" );
	turret MakeUsable();
	turret UseBy( level.player );
	turret MakeUnusable();
	
	level.player EnableWeapons();
	level.player_turret = turret;
	level.player SetPlayerAngles( ( 0, level.playertank.angles[ 1 ], 0 ) );
	level.player DisableTurretDismount();
	level.player SetStance( "stand" );
	turret thread maps\_minigun_viewmodel::show_hands( "viewhands_player_delta" ); 
	
	level.player enabledeathshield(false);
	
	// Start allied tank movement
	path0 = GetVehicleNode( "final_hero0_path", "targetname" );
	path1 = GetVehicleNode( "final_hero1_path", "targetname" );
	path2 = GetVehicleNode( "final_hero2_path", "targetname" );
	
	switch_node_now( level.herotanks[ 0 ], path0 );
	switch_node_now( level.herotanks[ 1 ], path1 );
	switch_node_now( level.herotanks[ 2 ], path2 );
	
	//flag_wait( "final_kill_turrets" );
	
	if( IsDefined( level.array_of_triggers1 ) )
	{
		foreach( trigger in level.array_of_triggers1 )
		{
			if( IsDefined( trigger ) )
				trigger DoDamage( 1, trigger.origin, level.player );
		}
		
		foreach( trigger in level.array_of_triggers2 )
		{
			if( IsDefined( trigger ) )
				trigger DoDamage( 1, trigger.origin, level.player );
		}
		
		foreach( trigger in level.array_of_triggers3 )
		{
			if( IsDefined( trigger ) )
				trigger DoDamage( 1, trigger.origin, level.player );
		}
	}
	
	flag_wait( "missile_strike_now" );
	
	flag_set( "all_tanks_stop_firing" );
	
	foreach( tank in level.enemytanks )
	{
		if( IsDefined( tank ) )
			tank kill();
	}
	foreach( gaz in level.enemygazs )
	{
		if( IsDefined( gaz ) )
			gaz kill();
	}
	axis = GetAIArray( "axis" );
	foreach( guy in axis )
	{
		if( IsDefined( guy ) )
			guy kill();
	}
}

begin_rail_vo()
{
	radio_dialog_add_and_go( "satfarm_bgr_wegotourman" );
//	radio_dialog_add_and_go( "satfarm_hqr_eagle1dropthepayload" );
	radio_dialog_add_and_go( "satfarm_eg1_rodgerdroppingthepayload" );
//	radio_dialog_add_and_go( "satfarm_hqr_moveitbadger1" );
}

missile_effect()
{
	start  = getstruct( "a10_player_start", "targetname" );
	target = getstruct( "final_effect_start", "targetname" );
	
	thread play_sound_in_space( "elm_quake_sub_rumble", start.origin );
	thread play_sound_in_space( "rog_thunder", start.origin );
	
	wait 3;
	
	//projectile
	rod_of_god		  = spawn_tag_origin();
	rod_of_god.origin = start.origin;
	rod_of_god MoveTo( target.origin, 2 );
	level.player PlaySound( "nymn_mortar_incoming" );
	PlayFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	wait( 2 );
	StopFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );

	thread play_sound_in_space( "scn_odin_pod_explosion", target.origin );
	
	//screen shake / rumble / shock
	ScreenShake( level.player.origin, 4, 3, 3, 4, 0, 3, 256, 8, 15, 12, 1.8 );
	level.player PlayRumbleOnEntity( "ac130_40mm_fire" );
	level.player ShellShock( "hijack_engine_explosion", 3 );
	
	waitframe();
	rod_of_god Delete();
	
	final 				= target;
	final_pos 			= spawn_tag_origin();
	final_pos.origin 	= final.origin;
	final_pos.angles 	= ( -90, 0, 0 );
	
	angles = VectorToAngles( level.playertank.origin - final.origin );
	
	//level.playertank.angles = angles;
	//level.player SetPlayerAngles( angles );
	
	rumble_ent 			= spawn_tag_origin();
	rumble_ent.origin	= final.origin;
	rumble_ent PlayRumbleLoopOnEntity( "damage_heavy" );
	rumble_ent moveto( level.player.origin, 5 );
	
	PlayFXOnTag( getfx( "nuke_explosion" ), 		final_pos, "tag_origin" );
	PlayFXOnTag( getfx( "nuke_flash" ), 			final_pos, "tag_origin" );
	PlayFXOnTag( getfx( "nuke_dirt_shockwave" ), 	final_pos, "tag_origin" );
	PlayFXOnTag( getfx( "nuke_smoke_fill" ), 		final_pos, "tag_origin" );
	
	wait 2;
	
	thread big_dish_fall();
	PlayFXOnTag( getfx( "sand_wall_payback_still_md" ), final_pos, "tag_origin" );
	
	objective_complete( obj( "satellite" ) );
		
	wait 5;
	
	rumble_ent delete();
	
	PlayFXOnTag( getfx( "nuke_smoke_fill" ), 		final_pos, "tag_origin" );
	
	wait 3;
}

// Other functions
do_exit_wait_on_movement( end_message )
{
	next_hint_time = gettime() + 5000;	
	level.player endon ( end_message );
	i = 1;
	while ( true )
	{
		movement = level.player GetNormalizedMovement();
		if( movement != ( 0, 0, 0 ) )
			return;
		
		if( gettime() > next_hint_time )
		{
			thread hint( "Press [{+gostand}] to exit the tank",99);
			next_hint_time = gettime() + ( 5000 * i );
			i++;
		}
		wait 0.05;
	}
}

mortar_strikes()
{	
	while( !flag( "missile_strike_now" ) )
	{
		for( i = 0; i < 3; i++ )
		{
			playerPosition	= level.player GetEye();
			playerAngles 	= level.player.angles;
			playerForward 	= AnglesToForward( 	playerAngles );
			playerRight 	= AnglesToRight( 	playerAngles );
			playerSpeed 	= level.playertank Vehicle_GetSpeed();
			
			//strike location
			strikePosition 	= playerPosition + ( playerForward * 2000 );
			
			//strike offset
			offsetx 		= RandomFloatRange( -1000, 1000 );
			if( offsetx < 500  && offsetx >= 0 )
				offsetx 	= RandomFloatRange( 500, 1000 );
			if( offsetx > -500 && offsetx <  0 )
				offsetx 	= RandomFloatRange( -1000, -500 );
			
			offsety 		= RandomFloatRange( -1000, 1000 );
			if( offsety < 500  && offsety >= 0 )
				offsety 	= RandomFloatRange( 500, 1000 );
			if( offsety > -500 && offsety <  0 )
				offsety 	= RandomFloatRange( -1000, -500 );
			
			strikeOffset	= ( offsetx, offsety, 2000 );
			
			//create fx tag
			fxTag 			= spawn_tag_origin();
			fxTag.origin 	= drop_to_ground( strikePosition + strikeOffset );
			fxTag.angles	= (-90,0,0);
			
			//mortar fire
			thread play_sound_in_space( "mortar_incoming_intro", fxTag.origin );
			
			wait RandomFloatRange( .25, .45 );
			
			playfxontag( getfx( "mortar" ), fxTag, "tag_origin" );
			EarthQuake( .2, .5, level.player.origin, 512 );
			thread play_sound_in_space( "mortar_explosion_intro", fxTag.origin );
			PlayRumbleOnPosition( "damage_heavy", fxTag.origin );
			
			wait RandomFloatRange( .25, .45 );
			
			fxTag Delete();
		}
		
		wait RandomFloatRange( .5, 1 );
	}
}

PlayerLinkToDeltaBlend( blendtime, accel_time, decel_time, linkto_entity, tag, viewpercentag_fraction, right_arc, left_arc, top_arc, bottom_arc, use_tag_angles_ )
{
	if ( !IsDefined( viewpercentag_fraction ) )
		viewpercentag_fraction = 1;
	if ( !IsDefined( right_arc ) )
		right_arc = 0;
	if ( !IsDefined( left_arc ) )
		left_arc = 0;
	if ( !IsDefined( top_arc ) )
		top_arc = 0;
	if ( !IsDefined( bottom_arc ) )
		bottom_arc = 0;
	if ( !IsDefined( use_tag_angles_ ) )
		use_tag_angles_ = true;
	
	self PlayerLinkToBlend( linkto_entity, tag, blendtime, accel_time, decel_time );
	self delaycall( blendtime, ::PlaYerLinkToDelta, linkto_entity, tag, viewpercentag_fraction, right_arc, left_arc, top_arc, bottom_arc, use_tag_angles_);

}

//crew functions
tank_spawn_crew()
{
	if( isdefined( self.drones_crew ) )
		return;
	
    self.drones_crew = [];
    
    self.drones_crew[ 0 ] = spawn_targetname( "tank_crew_2", true );
    self.drones_crew[ 1 ] = spawn_targetname( "tank_crew_1", true );
    
//    foreach( crew_member in self.drones_crew )
//    	crew_member.dontdeleteme = true;
    	
	tank_link_crew();
}

tank_link_crew()
{
    foreach ( drone in self.drones_crew )
    {
    	if( isdefined( drone.ridingvehicle ) )
    		continue;
    	drone.team = self.script_team;
		drone.voice = "american";
		drone.health = 10000;
    	//drone thread maps\_drone::drone_give_soul();
    	//drone SetCanDamage( false );
	    self thread guy_enter_vehicle( drone );
    }
}

// Run functions
view_kick()
{
	while( !flag( "final_rail" ) )
	{
		level.player ViewKick( RandomIntRange( 1, 20 ), level.finalgazs[ 1 ].origin );
		wait RandomFloatRange( .5, 3 );
	}
}

kill_timer()
{
	for( i = 0; i < 20; i++ )
	{
		wait 1;	
	}
	
	if( !flag( "final_mounting_tank" ) )
	{
		level.player PainVisionOn();
	}
	
	for( i = 0; i < 10; i++ )
	{
		wait 1;	
	}
	
	if( !flag( "final_mounting_tank" ) )
	{
		//level.player DisableInvulnerability();
		level.player enabledeathshield(false);
		level.player Kill();
	}
	else
		level.player PainVisionOff();
}

smokelaunchbadger()
{
	smokeLocations = getstructarray( "smoke_structs", "targetname" );
	
	i = 0;
	smoketagarray = [];
	foreach( smoke in smokeLocations )
	{
		level.badger		launch_smoke( smoke.origin );
		smoketagarray[ i ]			= spawn_tag_origin();
		smoketagarray[ i ].orgin	= smoke.origin;
		
		PlayFXontag( getfx( "smokescreen" ), smoketagarray[ i ], "tag_origin" );
		i++;
		wait randomfloatRange( .05, .25 );
	}	
	
	flag_wait( "final_rail" );
	
	wait 3;
	
	foreach( smoke in smokeLocations )
	{
		i--;
		StopFXOnTag( getfx( "smokescreen" ), smoketagarray[ i ], "tag_origin" );
		waitframe();
	}
}

stumble_run()
{
	stumble = 0;
	alt = 0;
	
	level.baseangles = level.player.angles;
	level.player_speed = 80;
	level.ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level.player playerSetGroundReferenceEnt( level.ground_ref_ent );
	
	wait .05;
	
	while ( 1 )
	{
		velocity = level.player getvelocity();
		player_speed = abs( velocity [ 0 ] ) + abs( velocity[ 1 ] );

		if ( player_speed < 10 )
		{
			wait 0.05;
			continue;
		}

		speed_multiplier = player_speed / level.player_speed;

		p = randomfloatrange( .5, 2 );
		if ( randomint( 100 ) < 20 )
			p *= 3;
		r = randomfloatrange( .5, 2 );
		y = randomfloatrange( -2, 0 );

		stumble_angles = ( p, y, r );
		stumble_angles = vector_multiply( stumble_angles, speed_multiplier );

		stumble_time = randomfloatrange( .25, .35 );
		recover_time = randomfloatrange( .55, .65 );

		stumble++;
		if ( speed_multiplier > 1.3 )
			stumble++ ;

		thread stumble( stumble_angles, stumble_time, recover_time );

		level waittill( "recovered" );
	}
	
	level.player playerSetGroundReferenceEnt( undefined );
	//thread blend_movespeedscale_custom( 50, 1 );
}

stumble( stumble_angles, stumble_time, recover_time, no_notify )
{
	level endon( "stop_stumble" );

//	if ( flag( "collapse" ) )
//		return;

	stumble_angles = adjust_angles_to_player( stumble_angles );

	level.ground_ref_ent rotateto( stumble_angles, stumble_time, ( stumble_time / 4 * 3 ), ( stumble_time / 4 ) );
	level.ground_ref_ent waittill( "rotatedone" );

//	if ( level.player getstance() == "stand" )
//		level.player PlayRumbleOnEntity( "damage_light" );

	base_angles = ( randomfloat( 4 ) - 4, randomfloat( 5 ), 0 );
	base_angles = adjust_angles_to_player( base_angles );

	level.ground_ref_ent rotateto( base_angles, recover_time, 0, recover_time / 2 );
	level.ground_ref_ent waittill( "rotatedone" );

 	if ( !isdefined( no_notify ) )
		level notify( "recovered" );
}

adjust_angles_to_player( stumble_angles )
{
	pa = stumble_angles[ 0 ];
	ra = stumble_angles[ 2 ];

	rv = anglestoright( level.player.angles );
	fv = anglestoforward( level.player.angles );

	rva = ( rv[ 0 ], 0, rv[ 1 ] * - 1 );
	fva = ( fv[ 0 ], 0, fv[ 1 ] * - 1 );
	angles = vector_multiply( rva, pa );
	angles = angles + vector_multiply( fva, ra );
	return angles + ( 0, stumble_angles[ 1 ], 0 );
}

vector_multiply( vector, number )
{
	return (vector[0] * number, vector[1] * number, vector[2] * number );
}

// missile functions
big_dish_fall()
{
	big_dish = getent( "big_dish", "targetname" );
	
	big_dish RotateRoll( 30, 10, 1, .05 );
	
	wait .5;
	
	big_dish RotatePitch( -30, 10, .5, .05 );
	
	wait .5;
	
	big_dish MoveZ( -2000, 20, 2, .05 );
}

rod_of_god_victory()
{	
	start  = getstruct( "a10_player_start", "targetname" );
	target = getstruct( "final_effect_start", "targetname" );
	
	//flashes
	//thread rog_victory_flashes();

	thread play_sound_in_space( "elm_quake_sub_rumble", start.origin );
	thread play_sound_in_space( "rog_thunder", start.origin );
	//stop music
	//flag_set( "victory_music_stop" );	
	
	wait 3;
//	
//	//sun/flash
//	sun		   = spawn_tag_origin();
//	sun.origin = start.origin;
//	PlayFXOnTag( getfx( "dcemp_sun" ), sun, "tag_origin" );
//	PlayFX( getfx( "vfx_lens_flare" ), start.origin );
//	wait 0.3;
//	StopFXOnTag( getfx( "dcemp_sun" ), sun, "tag_origin" );	
//	
//	wait 0.5;
	
	//projectile
	rod_of_god		  = spawn_tag_origin();
	rod_of_god.origin = start.origin;
	rod_of_god MoveTo( target.origin, 2 );
	level.player PlaySound( "nymn_mortar_incoming" );
	PlayFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	wait( 2 );
	StopFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	
	//impact
//	PlayFX( getfx( "building_explosion_mega_gulag" ), target.origin );
	thread play_sound_in_space( "scn_odin_pod_explosion", target.origin );
	//shockwave
	//thread rog_victory_shockwave( target );
	
	//water	
//	thread rog_victory_splashes( target );
	
	//screen shake / rumble / shock
	ScreenShake( level.player.origin, 4, 3, 3, 4, 0, 3, 256, 8, 15, 12, 1.8 );
	level.player PlayRumbleOnEntity( "ac130_40mm_fire" );
	level.player ShellShock( "hijack_engine_explosion", 3 );
	
	waitframe();
	rod_of_god Delete();	
}

turn_on_the_tanks_lights()
{
	effect_id = getfx( "hamburg_tank_red_light" );
	
	if( !ent_flag_exist( "lights_in_tank" ) )
	{
		ent_flag_init( "lights_in_tank" );
		ent_flag_set( "lights_in_tank" );
	}
	else
	{
		if( ent_flag( "lights_in_tank" ) )
			return;
	}
	
	PlayFXOnTag( effect_id, self, "tag_interior_light_1" );
	wait 0.05;
	PlayFXOnTag( effect_id, self, "tag_interior_light_2" );

//	wait 0.05;
//	effect_id = getfx( "hamburg_garage_godray_small" );
//	PlayFXOnTag( effect_id, self, "tag_interior_light_godray" );
}


turn_off_the_tanks_lights( onlygodray )
{
	effect_id = getfx( "hamburg_tank_red_light" );
	
	if( !ent_flag_exist( "lights_in_tank" ) || !ent_flag( "lights_in_tank" ) )
		return;
		
	ent_flag_clear( "lights_in_tank" );
	
//	if ( !IsDefined( onlygodray ) )
//	{
		StopFXOnTag( effect_id, self, "tag_interior_light_1" );
		StopFXOnTag( effect_id, self, "tag_interior_light_2" );
//	}

//	effect_id = getfx( "hamburg_garage_godray_small" );
//	StopFXOnTag( effect_id, self, "tag_interior_light_godray" );
	
}

//rog_victory_shockwave( target )
//{
//	wait 0.75;
//	playfx( getfx( "sw_rog_strike_shockwave" ), target.origin - (0,0,2000) );	
//}

//old
missile_strike()
{
	autosave_by_name( "missleguide" );
	level thread maps\satfarm_audio::complex_expl();
	
	/*missile = spawn_vehicle_from_targetname_and_drive( "missile" );
	
	level.player PlayerLinkToDelta( missile, "tag_origin", 1, 0, 0, 0, 0 );
	level.player SetPlayerAngles( missile.angles );
	level.player DisableWeapons();
	level.player AllowCrouch( true );
	level.player AllowStand( false );
	level.player AllowProne( false );
	level.player SetStance( "crouch" );
	//thread missile_overlays();
	//level.player uav_thermal_on();
	*/
	
	final 				= getstruct( "final_effect_start", "targetname" );
	
	//objective_add( obj( "missile" ), "active", "Guide Missile to the Satellite Complex" );
	//Objective_Position( obj( "missile" ), final.origin );
	//Objective_Current( obj( "missile" ) );
	
	start = get_a10_player_start();
	
	level.player init_bunker_buster_missile_for_player( start.origin, start.angles );
	level.player uav_thermal_on( 0, "ac130" );
	level.player give_player_missile_control();
//	level.a10_warthog_player remove_player_control( level.player );
	
	//flag_wait( "missile_hit" );
	flag_wait( "missile_hit_zone" );
	
	level.player remove_player_missile_control();
	level.player uav_thermal_off();
	
	objective_complete( obj( "satellite" ) );
	
	thread big_dish_fall();
	
	//objective_complete( obj( "missile" ) );
}

slamzoom_end()
{
	// slamzoom up
	// disable controls
	level.player FreezeControls( true );
	level.player EnableInvulnerability();
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player AllowCrouch( true );
	level.player AllowStand( false );
	level.player AllowProne( false );
   	level.player AllowJump( false );

	travel_time		= 1.75;
	zoomHeight 		= 15000;
	
	// setup player origin
	origin = level.player.origin;
	level.player PlayerSetStreamOrigin( origin );
	
	level.player.origin = origin;

	// create rig to link player view to
	ent = Spawn( "script_model", ( 0, 0, 0 ) );
	ent SetModel( "tag_origin" );
	ent.origin = level.player.origin;
	ent.angles = level.player.angles;
	ent.angles = ( ent.angles[ 0 ], ent.angles[ 1 ] + 180, ent.angles[ 2 ] );
	
	// link player
	level.player PlayerLinkTo( ent, undefined, 1, 0, 0, 0, 0 );
	ent.angles = ( ent.angles[ 0 ] + 89, ent.angles[ 1 ], 0 );
	
	ent MoveTo( origin + ( 0, 0, zoomHeight ), travel_time, 0, travel_time );
	
	// delay so sound would play
	wait 0.05;
	
	// SHUUUUUU
	level.player PlaySound( "survival_slamzoom_out" );
	
	wait( travel_time - 0.75 );
	
	level.player.ignoreme = 1;
}
