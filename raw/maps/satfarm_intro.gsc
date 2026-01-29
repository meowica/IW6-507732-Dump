#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

intro_init()
{
    level.start_point = "intro";
    thread fade_in_from_black();
    thread maps\satfarm_audio::satfarm_intro();
    
    kill_spawners_per_checkpoint( "intro" );
}

intro_main()
{
	if( level.start_point != "intro" )
		return;
	
	// init arrays
	level.allytanks 		= [];
	level.herotanks			= [];
	level.othertanks		= [];
	level.enemytanks 		= [];
	level.enemygazs 		= [];

	// spawn player
	level.playertank 		= spawn_vehicle_from_targetname( "intro_playertank" );
	level.player.tank 		= level.playertank;
	level.playertank.driver = level.player;
	level.playertank notify( "nodeath_thread" );
	level.playertank godon();
	
	// init player
	level.lock_on			= 0;
	level.player.script_team = "allies";
	
	//level.player FreezeControls( true );
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player AllowProne( false );
   	level.player AllowCrouch( false );
   	level.player AllowSprint( false );
   	level.player AllowJump( false );
   	
   	thread hide_normal_hud_elements();
   	
   	level.playertank thread tank_rumble();

	level.player EnableInvulnerability();
	
	level.playertank MakeUnusable();
	
	//player_org = spawn_tag_origin();
	//player_org linkto( level.playertank, "tag_player", ( 0, 0, -60 ), ( 0, 0, 0 ) );
	//level.player PlayerLinkToDelta( player_org, "tag_origin", 1, 45, 45, 35, 35, true );
	
	level.player.old_contents = level.player.contents;
	level.player.contents = 0;
	
	thread intro_begin();
	
	flag_wait( "intro_end" );
	
	maps\_spawner::killspawner( 10 );
    kill_vehicle_spawners_now( 10 );

}

fade_in_from_black()
{
	level.intro_black = maps\_hud_util::create_client_overlay( "black", 1, level.player );
	
	//level.intro_black.sort = 999;

	wait( 0.5 );
	
	intro_screen_custom_timing( 1.0, 3.5 );
	thread maps\_introscreen::introscreen( true );
	
	wait( 3.0 );

	level.intro_black FadeOverTime( 1 );
	level.intro_black.alpha = 0;
	wait 1.05;
	level.intro_black Destroy();
}

#using_animtree( "vehicles" );
intro_begin()
{
	//level.player FreezeControls( true );
	
	thread intro_vo();
	
	intro_ents_fake = [];
	
	playertank_fake_org = getstruct( "playertank_fake_org", "targetname" );
	playertank_fake_org.origin = playertank_fake_org.origin - ( 0, 0, 68 );
	playertank_fake = spawn_anim_model( "playertank_fake", playertank_fake_org.origin );
	intro_ents_fake		= add_to_array( intro_ents_fake, playertank_fake );
	
	intro_commander_spawner	 = GetEnt( "intro_commander", "targetname" );
	intro_commander			 = intro_commander_spawner spawn_ai( true, true );
	intro_commander.animname = "intro_commander";
	intro_ents_fake				 = add_to_array( intro_ents_fake, intro_commander );
	
	intro_crewmaster_spawner  = GetEnt( "intro_crewmaster", "targetname" );
	intro_crewmaster		  = intro_crewmaster_spawner spawn_ai( true, true );
	intro_crewmaster.animname = "intro_crewmaster";
	intro_ents_fake				  = add_to_array( intro_ents_fake, intro_crewmaster );
	
	intro_helper_spawner  = GetEnt( "intro_helper", "targetname" );
	intro_helper		  = intro_helper_spawner spawn_ai( true, true );
	intro_helper.animname = "intro_helper";
	intro_ents_fake			  = add_to_array( intro_ents_fake, intro_helper );
	
	intro_lieutenant_spawner  = GetEnt( "intro_lieutenant", "targetname" );
	intro_lieutenant		  = intro_lieutenant_spawner spawn_ai( true, true );
	intro_lieutenant.animname = "intro_lieutenant";
	intro_ents_fake				  = add_to_array( intro_ents_fake, intro_lieutenant );
	
	intro_soldier1_spawner	= GetEnt( "intro_soldier1", "targetname" );
	intro_soldier1			= intro_soldier1_spawner spawn_ai( true, true );
	intro_soldier1.animname = "intro_soldier1";
	intro_ents_fake				= add_to_array( intro_ents_fake, intro_soldier1 );
	
	intro_soldier2_spawner	= GetEnt( "intro_soldier2", "targetname" );
	intro_soldier2			= intro_soldier2_spawner spawn_ai( true, true );
	intro_soldier2.animname = "intro_soldier2";
	intro_ents_fake				= add_to_array( intro_ents_fake, intro_soldier2 );
	
	intro_turretman_spawner	 = GetEnt( "intro_turretman", "targetname" );
	intro_turretman			 = intro_turretman_spawner spawn_ai( true, true );
	intro_turretman.animname = "intro_turretman";
	intro_ents_fake				 = add_to_array( intro_ents_fake, intro_turretman );
	
	wait( 0.05 );
	
	level.player PlayerLinkToDelta( playertank_fake, "tag_player", 1, 0, 0, 0, 0, true );
	
	level.player LerpViewAngleClamp( 2.0, .05, .05, 45, 45, 30, 10 );
	
	playertank_fake_org anim_single( intro_ents_fake, "intro", undefined, 0.5 );
	
	thread lerp_player_view_for_teleport();
	
	sat_farm_intro_org = getstruct( "sat_farm_intro_org", "targetname" );
	
	level.herotanks[ 0 ] = spawn_vehicle_from_targetname_and_drive( "crash_site_hero0" );
	level.bobcat 		 = level.herotanks[ 0 ];
	
	level.allytanks = array_combine( level.allytanks, level.herotanks );
	
	intro_ents = [];
	
	level.playertank.animname = "playertank" ;
	level.playertank useAnimTree( level.scr_animtree[ level.playertank.animname ] );
	
	intro_ents = add_to_array( intro_ents, level.playertank );
	
	crashedtank = spawn_anim_model( "crashedtank" );
	intro_ents = add_to_array( intro_ents, crashedtank );
	
	level.herotanks[ 0 ].animname = "allytank_right" ;
	level.herotanks[ 0 ] useAnimTree( level.scr_animtree[ level.herotanks[ 0 ].animname ] );
	
	intro_ents = add_to_array( intro_ents, level.herotanks[ 0 ] );
	
	playerc17 = spawn_anim_model( "playerc17" );
	intro_ents = add_to_array( intro_ents, playerc17 );
	
	crashedc17 = spawn_anim_model( "crashedc17" );
	intro_ents = add_to_array( intro_ents, crashedc17 );
	
	level.crashedc17_missile_org = spawn_tag_origin();
	level.crashedc17_missile_org linkto( crashedc17, "tag_origin", ( -800, -256, 0 ), ( 0, 0, 0 ) );
	
	allyc17_right = spawn_anim_model( "allyc17_right" );
	intro_ents = add_to_array( intro_ents, allyc17_right );
	
	wait( 0.05 );
	
	sat_farm_intro_org thread anim_single( intro_ents, "intro" );
	
	level.playertank thread playertank_waits();
	
	level.herotanks[ 0 ] thread allytank_right_waits();
	
	playerc17 thread playerc17_waits();
	crashedc17 thread crashedc17_waits();
	allyc17_right thread allyc17_right_waits();
	intro_commander thread intro_commander_waits();
	//thread maps\satfarm_crash_site::intro_and_crash_site_ally_setup();
	thread mig_fires_at_c17_scene();

	level.playertank thread tank_deploy_chutes( "_player" );
	crashedtank thread tank_deploy_chutes( "_crashedtank" );
	level.herotanks[ 0 ] thread tank_deploy_chutes( "_allytankright" );
	
	thread maps\satfarm_audio::deploychutes2();
	
	wait( 0.2 );
	
	level.player PlayerLinkToAbsolute( level.playertank, "tag_player" );
	
	wait( 0.1 );
	
	SetBlur( 0, .25 );
}

setup_intro_allies()
{
	level.herotanks[ 1 ] = spawn_vehicle_from_targetname_and_drive( "intro_hero1" );
	level.badger 		 = level.herotanks[ 1 ];
	level.allytanks = array_combine( level.allytanks, level.herotanks );
	level.herotanks[ 1 ] thread npc_tank_combat_init();
	level.herotanks[ 1 ] thread tank_relative_speed( "base_array_relative_speed", "crash_site_end", 250, 13.5, 1.5 );
	thread switch_node_on_flag( level.herotanks[ 1 ], "", "switch_crash_site_path_hero1", "crash_site_path_hero1" );
	
	thread maps\satfarm_crash_site::intro_and_crash_site_ally_setup();
}

lerp_player_view_for_teleport()
{
	thread setup_intro_allies();
	
	thread fade_to_white_then_fade_to_normal();
	
	level.player LerpViewAngleClamp( 1.0, .5, 0, 0, 0, 0, 0 );
}

intro_commander_waits()
{
	self waittillmatch( "single anim", "cargo_bay_doors_open" );
	
	self waittillmatch( "single anim", "turbulence_shift" );
	
	self waittillmatch( "single anim", "strafe_attack1" );
	
	self waittillmatch( "single anim", "strafe_attack2" );
	
	self waittillmatch( "single anim", "humvee_minor_explosion" );
	
	self waittillmatch( "single anim", "deploy_button_pressed" );
	
	self waittillmatch( "single anim", "humvee_explode" );
	
}

#using_animtree( "vehicles" );
playertank_waits()
{
	self waittillmatch( "single anim", "end" );
	
	level.playertank useAnimTree( #animtree );
	
	level.playertank SetAnim( %abrams_movement, 1, 0.05 );

	wait( 0.5 );

	level.player EnableSlowAim( 0.5, .25);
	
	level.player Unlink();
	
	level.playertank MakeUsable();
	level.playertank UseBy( level.player );
	level.playertank MakeUnusable();
	
	level.player thread tank_hud( level.playertank );
	
	//make the playertank move forward here
	
	level.player LerpViewAngleClamp( 1, .05, .05, 180, 180, 30, 10 );
	
	SetSavedDvar( "cg_viewVehicleInfluence", 0.1 );
	
	/*
	level.herotanks[ 1 ] = spawn_vehicle_from_targetname_and_drive( "crash_site_hero1" );
	level.badger 		 = level.herotanks[ 1 ];
	
	level.allytanks = array_combine( level.allytanks, level.herotanks );
	
	level.herotanks[ 1 ] thread npc_tank_combat_init();
	*/
	
	flag_set( "intro_end" );
	
	flag_set( "player_in_tank" );
	
	// Aim assist/ Auto Aim
	//SetSavedDvar( "aim_aimAssistRangeScale", ".5" );
	SetSavedDvar( "aim_autoAimRangeScale"  , "0" );
	
	thread tank_zoom();
	level.player thread init_chatter();	
	level.player thread take_fire_tracking();
	level.playertank thread tank_health_monitor();
	level.playertank thread on_fire_main_cannon();
	level.playertank thread on_fire_mg();
	level.playertank thread tank_handle_sabot();
	level.playertank thread on_pop_smoke();
	level.playertank thread on_fire_sabot();
	level.playertank thread tank_quake();
	thread kill_in_volume();
	level.player thread toggle_thermal();
	level.playertank thread do_damage_from_tank();
	
	level thread maps\satfarm_audio::player_tank_turret_sounds();
	
	level.player FreezeControls( false );
}

allytank_right_waits()
{
	self waittillmatch( "single anim", "end" );
	
	wait( 0.05 );
	
	self useAnimTree( #animtree );
	
	self thread npc_tank_combat_init();
}

playerc17_waits()
{
	self waittillmatch( "single anim", "plane_explode" );
	
	//do cool plane explosion here
	
	wait( 1.0 );
	
	self Delete();
}

crashedc17_waits()
{
	self waittillmatch( "single anim", "end" );
	
	wait( 0.05 );
	
	self Delete();
}

allyc17_right_waits()
{
	self waittillmatch( "single anim", "end" );
	
	wait( 0.05 );
	
	self Delete();
}

intro_allies()
{
	tanks = spawn_vehicles_from_targetname_and_drive( "intro_allies" );
	
	array_thread( tanks, ::spawn_death_collision_phys );
	
	flag_wait( "intro_end" );
	
	foreach( tank in tanks )
	{
		if( IsDefined( tank ) )
		   tank Delete();
	}
}

mig_fires_at_c17_scene()
{	
	wait( 24.0 );
	
	mig = spawn_vehicle_from_targetname_and_drive( "intro_mig29_missile_c17_01" );
	mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
}

intro_vo()
{
	wait( 0.5 );
	
	//Com Unit 3: Heli retrieval of primary ghost asset green. En route.
	thread radio_dialog_add_and_go( "satfarm_cu3_heliretrievalofprimary" );
	
	//Overlord: B-company, secure the airstrip asap for priority one asset retrieval.
	radio_dialog_add_and_go( "satfarm_hqr_bcompanysecuretheairstrip" );
	
	wait( 1.0 ); //temp
	
	//Badger: Hawk this is Badger One. Sitrep.
	radio_dialog_add_and_go( "satfarm_bgr_hawkthisisbadger", undefined, true );
	
	//Hawk: Assault is under way Badger One
	radio_dialog_add_and_go( "satfarm_hwk_assaultisunderway" );
	
	//Com Unit 3: Heavy AA fire over the air strip. Rerouting A10s.
	thread radio_dialog_add_and_go( "satfarm_cu3_heavyaafireover" );
	
	wait( 1.0 );
	
	//Hawk: Entering drop zone now, prep for deployment.
	radio_dialog_add_and_go( "satfarm_hwk_enteringdropzonenow", undefined, true );
	
	//Hawk: Under heavy fire…
	radio_dialog_add_and_go( "satfarm_hwk_underheavyfire" );
	
	//Bravo: B-Company is split, Overlord. We are all over the AO.
	thread radio_dialog_add_and_go( "satfarm_brv_bcompanyissplitoverlord" );
	
	wait( 1.0 );
	
	//Hawk: We’re hit! We’re hit!!
	radio_dialog_add_and_go( "satfarm_hwk_werehitwerehit", undefined, true );

	//Hawk: Deploy chutes! Deploy! Deploy!
	radio_dialog_add_and_go( "satfarm_hwk_deploychutesdeploydeploy" );
}

//tank will be "_player", "_crashedtank", "_allytankright"
tank_deploy_chutes( tank )
{
	sat_farm_intro_org = getstruct( "sat_farm_intro_org", "targetname" );
	model = "pilot_chute" + tank;
	pilot_chute = spawn_anim_model( model );
	pilot_chute Hide();
	
	main_chutes = [];
	for( i = 0; i <= 2; i++ )
	{
		model = "main_chute" + i + tank;
		main_chutes[ i ] = spawn_anim_model( model );
		main_chutes[ i ] Hide();
	}
	
	sat_farm_intro_org thread anim_first_frame_solo( pilot_chute, "pilot_chute_deploy" );
	
	sat_farm_intro_org thread anim_first_frame( main_chutes, "main_chute_deploy" );
	
	self waittillmatch( "single anim", "spawn_pilot_chute" );
	
	pilot_chute Show();
	sat_farm_intro_org thread anim_single_solo( pilot_chute, "pilot_chute_deploy" );
	
	level thread maps\satfarm_audio::deploychutes1();
	
	self waittillmatch( "single anim", "spawn_main_chutes" );
	
	foreach ( chute in main_chutes )
	{
		chute Show();
	}
	sat_farm_intro_org thread anim_single( main_chutes, "main_chute_deploy" );
	
	level thread maps\satfarm_audio::deploychutes2();
	
	flag_wait( "crash_site_end" );
	
	pilot_chute Delete();
	
	foreach ( chute in main_chutes )
		chute Delete();
}

fade_to_white_then_fade_to_normal()
{
	wait( .5 );
	
	level.intro_white = maps\_hud_util::create_client_overlay( "white", 0, level.player );
	
	level.intro_white FadeOverTime( 0.5 );
	level.intro_white.alpha = 1.0;
	
	wait 0.5;
	
	wait( 0.2 );
	
	level notify( "faded_to_white" );
	
	wait( 0.05 );
	
	level.player PlayerSetGroundReferenceEnt( undefined );
	
	level.intro_white FadeOverTime( 0.75 );
	level.intro_white.alpha = 0;
	
	wait( 0.75 );
	
	level.intro_white Destroy();
}

intro_cleanup()
{
	//wait( 1.0 );
	ents = GetEntArray( "intro_ent", "script_noteworthy" );
	array_delete( ents );
}