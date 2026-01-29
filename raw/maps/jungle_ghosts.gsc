#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;


#using_animtree("generic_human");

CONST_WIND_STRENGTH = 1;
CONST_WIND_AMPLITUDE = .05;

main()
{
	template_level( "jungle_ghosts" );
	maps\createart\jungle_ghosts_art::main();
	maps\jungle_ghosts_fx::main();
	maps\jungle_ghosts_anim::main();
	maps\jungle_ghosts_precache::main();
	maps\_patrol_anims_gundown::main();
	maps\_patrol_anims_creepwalk::main();
	
	//SetDvarIfUninitialized( "parachute_intro", "1" );
	
	setup_bind_detection();
	precache_please();	
	init_starts();
	init_level_flags();
	init_radio_dialogue();
	init_dialogue();
	
	//"Ghosts of the Jungle"
	//"August 12th - 05:12:[{FAKE_I_audiTRO_SECONDS:17}]"
	//"Cpt. Clive "Lucipher" Weston"
	//"Ghost Team"
	//"Sao Gabriel da Cachoeira, South America"
	intro_screen_create( &"JUNGLE_GHOSTS_INTROSCREEN_LINE_1", &"JUNGLE_GHOSTS_INTROSCREEN_LINE_5", &"JUNGLE_GHOSTS_INTROSCREEN_LINE_2" );
	intro_screen_custom_func( ::custom_intro_screen_func );
	
	maps\_load::main();
	
	//hide rain skybox!
	level.rain_skybox = getent("jungle_overcast_sky", "targetname");
	level.rain_skybox hide();
	
	
	level.player TakeAllWeapons();
	maps\jungle_ghosts_audio::main();
	
	// Setup Stealth
	maps\_stealth::main();
	array_thread( level.players, maps\_stealth_utility::stealth_default );
	
	//use silencer
	add_hint_string( "hint_silencer_toggle", &"JUNGLE_GHOSTS_SILENCER_TOGGLE", ::should_toggle_silencer );
	//do not have soflam weapon out
	//add_hint_string( "hint_switchto_soflam", &"JUNGLE_GHOSTS_HINT_WEAPON_SOFLAM", ::should_switchto_soflam );

	
	//trigs have closest friendly do a hand signal
	level.doing_hand_signal = 0;
	hand_signal_trigs = ["to_grassy_field", "field_entrance" ];
	foreach ( trig in hand_signal_trigs )
	{
		trig = getent( trig, "targetname" );
		trig thread maps\jungle_ghosts_util::play_hand_signal_for_player();
	}
	
	//no prone for player in stream trigs
	stream_trig = getent( "stream", "targetname" );
	stream_trig thread maps\jungle_ghosts_util::stream_trig_logic();
	
	level.stealth_spotted_time = 6;
	level.stealth_player_aware_enemies = [];
	level.ignore_on_func = maps\jungle_ghosts_jungle::generic_ignore_on;
	level.ignore_off_func = maps\jungle_ghosts_jungle::generic_ignore_off;
	
	jungle_soldier_archetype = [];
	
	jungle_soldier_archetype[ "default_crouch" ][ "exposed_idle" ] = [ %exposed_crouch_lookaround_1, %exposed_crouch_lookaround_2, %exposed_crouch_lookaround_3, %exposed_crouch_lookaround_4 ];	
	register_archetype( "jungle_soldier", jungle_soldier_archetype );
	
	//maps\_load::set_player_viewhand_model( "viewhands_gs_jungle" );
	level.player SetViewModel("viewhands_gs_jungle");
	
	thread maps\jungle_ghosts_jungle::jungle_moving_foliage_settings();
	
	SetSavedDvar( "cg_foliagesnd_alias", "plyr_wet_foliage_mvmnt" );
	SetDevDvarIfUninitialized( "underwater_test", 0 );
	SetDevDvarIfUninitialized( "mt_test", 0 );

	// tweaking default ADS dof settings since BulletTrace does not hit foliage
	setdvar( "ads_dof_tracedist", 2048 );	
	
	trigger_off( "river_slide_trig", "targetname" );
}

/* =-=-=-=-
  multi-platform key bind detection from MW2 trainer
  =-=-=-=--*/
  
setup_bind_detection()
{
	level.actionBinds = [];
	registerActionBinding( "player_takedown",	"+activate",			&"JUNGLE_GHOSTS_HINT_TAKEDOWN" );
	registerActionBinding( "player_takedown",	"+usereload",			&"JUNGLE_GHOSTS_HINT_TAKEDOWN_RELOAD" );
	
	registerActionBinding( "pickup_rpg",	"+activate",			&"JUNGLE_GHOSTS_RPG_PICKUP" );
	registerActionBinding( "pickup_rpg",	"+usereload",			&"JUNGLE_GHOSTS_RPG_PICKUP_RELOAD" );
	
	registerActionBinding( "player_helpup",	"+activate",			&"JUNGLE_GHOSTS_HINT_HELPUP" );
	registerActionBinding( "player_helpup",	"+usereload",			&"JUNGLE_GHOSTS_HINT_HELPUP_RELOAD" );
	
	registerActionBinding( "ads_360",			"+speed_throw",			&"JUNGLE_GHOSTS_HINT_ADS_THROW_360" );
	registerActionBinding( "ads_360",			"+speed",				&"JUNGLE_GHOSTS_HINT_ADS_360" );	
	registerActionBinding( "ads",				"+speed_throw",			&"JUNGLE_GHOSTS_HINT_ADS_THROW" );
	registerActionBinding( "ads",				"+speed",				&"JUNGLE_GHOSTS_HINT_ADS" );
	registerActionBinding( "ads",				"+toggleads_throw",		&"JUNGLE_GHOSTS_HINT_ADS_TOGGLE_THROW" );
	registerActionBinding( "ads",				"toggleads",			&"JUNGLE_GHOSTS_HINT_ADS_TOGGLE" );	
	registerActionBinding( "equip_soflam",		"+actionslot 4",		&"JUNGLE_GHOSTS_HINT_WEAPON_SOFLAM" );
}

registerActionBinding( action, binding, hint )
{
	if ( !isDefined( level.actionBinds[action] ) )
		level.actionBinds[action] = [];

	actionBind = spawnStruct();
	actionBind.binding = binding;
	actionBind.hint = hint;

	actionBind.keyText = undefined;
	actionBind.hintText = undefined;

	precacheString( hint );

	level.actionBinds[action][level.actionBinds[action].size] = actionBind;
}


getActionBind( action )
{
    for ( index = 0; index < level.actionBinds[action].size; index++ )
    {
        actionBind = level.actionBinds[action][index];

        binding = getKeyBinding( actionBind.binding );
        if ( !binding["count"] )
            continue;

        return level.actionBinds[action][index];
    }

    return level.actionBinds[action][0];//unbound
}

keyHint( actionName, timeOut, doubleline, alwaysDisplay )
{
	clear_hints();
	level endon ( "clearing_hints" );
	
	level.hintElem = create_custom_hint();
	
	actionBind = getActionBind( actionName );

	level.hintElem setText( actionBind.hint );
	//level.hintElem endon ( "death" );
	
	if ( !isdefined( alwaysDisplay ) )
	{
		notifyName = "did_action_" + actionName;
		for ( index = 0; index < level.actionBinds[actionName].size; index++ )
		{
			actionBind = level.actionBinds[actionName][index];
			notifyOnCommand( notifyName, actionBind.binding );
		}
	
		if ( isDefined( timeOut ) )
			level.player thread notifyOnTimeout( notifyName, timeOut );
		level.player waittill( notifyName );
	
		level.hintElem fadeOverTime( 0.5 );
		level.hintElem.alpha = 0;
		wait ( 0.5 );
	
		clear_hints();
	}

}

create_custom_hint()
{
	fontscale = 2;
	if (isdefined(level.hint_fontscale))
		fontscale = level.hint_fontscale;
	
	Hint = createFontString( "default", fontscale );
	Hint.hidewheninmenu = true;
	//Hint setPoint( "TOP", undefined, 0, 110 );
	Hint.sort = 0.5;
	
	Hint.alpha = 0.9;
	Hint.x = 0;
	Hint.y = -68;
	Hint.alignx = "center";
	Hint.aligny = "middle";
	Hint.horzAlign = "center";
	Hint.vertAlign = "middle";
	Hint.foreground = false;
	Hint.hidewhendead = true;
	Hint.hidewheninmenu = true;
	
	return Hint;	
}

clear_hints()
{
	if ( isDefined( level.hintElem ) )
		level.hintElem destroyElem();
	if ( isDefined( level.iconElem ) )
		level.iconElem destroyElem();
	if ( isDefined( level.iconElem2 ) )
		level.iconElem2 destroyElem();
	if ( isDefined( level.iconElem3 ) )
		level.iconElem3 destroyElem();
	if ( isDefined( level.hintbackground ) )
		level.hintbackground destroyElem();
	level notify ( "clearing_hints" );
}

notifyOnTimeout( finishedNotify, timeOut )
{
	self endon( finishedNotify );
	wait timeOut;
	self notify( finishedNotify );
}

/* =-=-=-=-
  End multi-platform key bind detection from MW2 trainer
  =-=-=-=--*/

precache_please()
{
	// MODELS
	PreCacheModel( "viewmodel_commando_knife" );
	PreCacheModel( "viewhands_gs_jungle");
	precachemodel ("tag_turret");
	precachemodel( "weapon_parabolic_knife");
	precachemodel( "weapon_smaw");
	PreCacheModel( "vehicle_parachute");
	PreCacheModel( "tag_laser" );
	PrecacheModel( "viewhands_player_gs_jungle");
	
	//CHOPPER CRASH MODELS
	PreCacheModel( "vehicle_mi17_woodland_fly_cheap" );
	PreCacheModel( "com_prague_rope_animated" );
	PreCacheModel( "vehicle_btr80_low" );
	PreCacheModel( "cargocontainer_20ft_blue" );
	PreCacheModel( "weapon_beretta" );
	PreCacheModel( "head_op_sniper_ghillie_forest" );
	PreCacheModel( "vehicle_aas_72x_destructible" );
	PreCacheModel( "jungle_crate_01" );
	PreCacheModel( "jungle_crate_01_dmg" );
	
	// SHADERS
	PreCacheShader( "cb_motiontracker3d_ping_enemy" );
	PreCacheShader( "cb_motiontracker3d_ping_friendly" );

	// ITEMS
	precacheitem( "honeybadger+acog_sp");
	precacheitem( "smaw" );
	PreCacheItem( "rpg_straight" );
	PreCacheItem( "smoke_grenade_american" );
	PreCacheItem( "ak47" );
	PreCacheItem( "ak47_silencer" );
	//precacheitem( "usp_silencer_jungle" );
	PreCacheItem( "knife_jungle" );
	//PreCacheItem( "usp_no_knife_silencer" );
	PreCacheItem( "m4_silencer_reflex" );
	PreCacheItem( "beretta" );
		
	// Temp weapons for e3
	PreCacheItem( "honeybadger" );
	PreCacheItem( "kriss" );
	PreCacheItem( "microtar" );
	PreCacheItem( "sc2010" );
	PreCacheItem( "p226" );
	PreCacheItem( "p226_tactical" );
	
	// STRINGS
	precachestring(&"JUNGLE_GHOSTS_SILENCER_TOGGLE");
	precachestring(&"JUNGLE_GHOSTS_INTROSCREEN_LINE_1");
	precachestring(&"JUNGLE_GHOSTS_INTROSCREEN_LINE_2");
	precachestring(&"JUNGLE_GHOSTS_INTROSCREEN_LINE_3");
	precachestring(&"JUNGLE_GHOSTS_INTROSCREEN_LINE_4");
	precachestring(&"JUNGLE_GHOSTS_INTROSCREEN_LINE_5");
	precachestring(&"JUNGLE_GHOSTS_OBJ_LEAD_TO_WATERFALL");
	precachestring(&"JUNGLE_GHOSTS_OBJ_SAVE_TEAM");
	precachestring(&"JUNGLE_GHOSTS_OBJ_ESC_TO_RIVER");
	precachestring(&"JUNGLE_GHOSTS_OBJ_PRIMARY_MISSION_OBJ");
	precachestring(&"JUNGLE_GHOSTS_OBIT_TREE");
	precachestring(&"JUNGLE_GHOSTS_FAIL_LEFT_SQUAD" );
	precachestring(&"JUNGLE_GHOSTS_HELP_HESH" );
	precachestring(&"JUNGLE_GHOSTS_RPG_PICKUP_RELOAD" );
	precachestring(&"JUNGLE_GHOSTS_RPG_PICKUP" );
	precachestring(&"JUNGLE_GHOSTS_GRASS_DEATH_HINT1" );
	precachestring(&"JUNGLE_GHOSTS_GRASS_DEATH_HINT2" );
		

	// SHELLSHOCKS AND RUMBLES
	PreCacheShellShock("prague_swim");
	PreCacheShellShock("underwater");
	PreCacheRumble( "damage_heavy" );
}

init_starts()
{
	add_start("e3", ::e3_start, "E3" );
	add_start( "crash_test", ::crash_test_start, "New chopper crash test" );
	add_start( "parachute", ::parachute_start, "Parachute" );
	add_start( "jungle_corridor", ::jungle_corridor_start, "Jungle, no parachute" );
	add_start( "jungle_hill", ::jungle_hill_start, "Jungle Hill" );
	add_start( "waterfall", ::execution_start, "Waterfall Execution" );
	add_start( "Stream", ::stream_start, "Stream" );
	add_start( "Stream Waterfall", ::stream_waterfall_start, "Stream Waterfall" );
	add_start( "Stream Backend", ::stream_backend_start, "Stream Backend" );
	
	add_start( "TallGrass", ::tall_grass_start, "tall_grass" );
	add_start( "TallGrass_chopper", ::tall_grass_chopper_start, "tall_grass_chopper" );
	add_start( "TallGrass_nogame", ::tall_grass_nogame_start, "tall_grass - no scripting" );
	
	add_start( "runway", ::runway_start, "Runway" );
	add_start( "escape_runway", ::escape_runway_start, "Escape: Runway" );
	add_start( "escape_jungle", ::escape_jungle_start, "Escape: Jungle" );
	add_start( "escape_river", ::escape_river_start, "Escape: River" );
	add_start( "escape_waterfall", ::escape_waterfall_start, "Escape: Waterfall Landing" );
	add_start("tree_test", ::dest_tree_test, "Destructible Tree test" );
	add_start("underwater", ::underwater_test, "underwater" );
	
	
	//default_start( ::jungle_start );
	default_start( ::parachute_start );
}

init_level_flags()
{
	level.player ent_flag_init( "recently_fired_weapon");
	level.player ent_flag_init( "tall_grass_player_protection" );
	
	//these are not set by trigs
	flag_init( "slamzoom_start" );
	flag_init( "slamzoom_finished" );
	flag_init( "uav_hud_set" );
	flag_init( "friendlies_ready" );
	flag_init( "intro_lines" );
	flag_init( "interupt_end" );
	flag_init( "hill_flanked" );
	flag_init( "hill_clear" );
	flag_init( "waterfall_clear" );
	flag_init( "player_at_execution" );
	flag_init( "stop_water_footsteps" );
	flag_init( "player_found_bravo" );
	flag_init( "uav_vo_finished" );
	flag_init( "jump_start" );
	flag_init( "jumped_down" );
	flag_init( "begin_shoot_chopper" );
	flag_init( "stream_fight_begin" );
	flag_init( "waterfall_hub" );
	flag_init( "smaw_target_detroyed" );
	flag_init( "stream_clear" );
	flag_init( "waterfall_ambush_begin" );
	flag_init( "ambush_open_fire" );
	flag_init( "squad_in_ambush_position" );
	flag_init( "player_in_ambush_position" );
	flag_init( "ambush_guys_dead" );
	flag_init( "ai_hold" );
	flag_init( "player_didnt_ambush" );
	flag_init( "tall_grass_goes_hot" );
	flag_init( "tall_grass_intro_goes_hot" );
	flag_init( "begin_runway_attack" );
	flag_init( "runway_hot" );
	flag_init( "intro_takedown_started" );
	flag_init( "player_targeting" );
	flag_init( "smaw_guy_get_into_pos" );
	flag_init( "runway_choppers_return" );
	flag_init( "chopper_over_tallgrass" );
	flag_init( "squad_to_escape_slide" );
	flag_init( "interrogtaion_started" );
	flag_init( "player_rescued_hostage" );
	flag_init( "player_shot_runway_with_wrong_weapon" );
	flag_init( "adjusting_wind" );
	flag_init( "player_is_moving" );
	flag_init( "player_swim_faster" );
	flag_init( "player_out_of_water" );
	flag_init( "intro_takedown_ready" );
	flag_init( "intro_takedown_done" );
	flag_init( "intro_takedown_aborted" );
	flag_init( "choppers_attacked" );
	flag_init( "player_surfaces" );
	flag_init( "runway_clear_to_shoot" );
	flag_init( "jungle_section1_clear" );
	flag_init( "squad_to_waterfall_ambush" );
	flag_init( "squad_exiting_tall_grass" );
	flag_init( "skybox_changed" );
	flag_init( "doing_lightning" );
	flag_init( "player_landed" );
	flag_init( "chopper_crash_complete" );
	flag_init( "doing_story_vo" );
	flag_init( "player_has_rpg" );
	flag_init( "player_jumping" );
	flag_init( "player_jump_watcher_stop" );
	flag_init( "player_fell_off_waterfall" );
	flag_init( "player_spotted_music");
	flag_init( "player_spotted_vo");
	flag_init(	"chopper_impact" );
	flag_init( "grass_went_hot");
	flag_init("first_distant_sat_launch");
	flag_init("second_distant_sat_launch");
	flag_init("tall_grass_heli_unloaded");
	flag_init("moving_into_tall_grass");
	flag_init("can_see_chopper");
	flag_init("bridge_approach");
	flag_init("stream_rush_chopper");
	flag_init("waterfall_patrollers_dead");
	flag_init("waterfall_patrollers_passed");
	flag_init("choppers_get_down");
	flag_init("choppers_saw_player");
	flag_init("choppers_are_gone");
	flag_init("stream_backend_moveup_stealth");
	flag_init("backend_friendlies_go_hot");
	flag_init("chopper_tallgrass_gone");
	flag_init("stream_heli_out");
	flag_init("time_for_chopper_to_leave");
	flag_init("e3_warp");
		
	//I prefer this to trig_mulitple_flag_set so I can keep track of flag names here
	trig_flags= [];
	trig_flags[trig_flags.size] = "jungle_entrance";
	trig_flags[trig_flags.size] = "jungle_entrance_approach";	
	trig_flags[trig_flags.size] = "hill_pos_1";
	trig_flags[trig_flags.size] = "hill_pos_2";
	trig_flags[trig_flags.size] = "hill_pos_3";
	trig_flags[trig_flags.size] = "hill_pos_4";
	trig_flags[trig_flags.size] = "hill_pos_5";
	trig_flags[trig_flags.size] = "hill_pos_6";
	trig_flags[trig_flags.size] = "waterfall_approach";
	trig_flags[trig_flags.size] = "waterfall_trig";
	trig_flags[trig_flags.size] = "chopper_crash_arrive";
	trig_flags[trig_flags.size] = "player_went_right";
	trig_flags[trig_flags.size] = "to_grassy_field";
	trig_flags[trig_flags.size] = "field_entrance";
	trig_flags[trig_flags.size] = "field_halfway";
	trig_flags[trig_flags.size] = "field_end";
	trig_flags[trig_flags.size] = "prone_guys_getup";
	trig_flags[trig_flags.size] = "runway_approach";
	trig_flags[trig_flags.size] = "runway_arrive";
	trig_flags[trig_flags.size] = "player_slid";	
	trig_flags[trig_flags.size] = "slide_start";	
	trig_flags[trig_flags.size] = "escape_halfway";	
	trig_flags[trig_flags.size] = "player_went_right_escape";	
	trig_flags[trig_flags.size] = "player_at_river";	
	trig_flags[trig_flags.size] = "player_crossed_river";
	trig_flags[trig_flags.size] = "stryker_go";
	trig_flags[trig_flags.size] = "final_read";
	trig_flags[trig_flags.size] = "waterfall_to_stream";
	trig_flags[trig_flags.size] = "stream_exit";
	trig_flags[trig_flags.size] = "crash_arrive";
	trig_flags[trig_flags.size] = "player_slide_arrive";
	trig_flags[trig_flags.size] = "tall_grass_intro_halfway";
	trig_flags[trig_flags.size] = "stream_backend_start";
	trig_flags[trig_flags.size] = "stream_backend_moveup";
	trig_flags[trig_flags.size] = "player_rushed_chopper_crash";
	trig_flags[trig_flags.size] = "abort_chopper_crash";
	trig_flags[trig_flags.size] = "bridge_area_exit";
	trig_flags[trig_flags.size] = "squad_to_waterfall";
	trig_flags[trig_flags.size] = "runway_halfway";
	trig_flags[trig_flags.size] = "can_see_chopper";
	trig_flags[trig_flags.size] = "bridge_approach";
	trig_flags[trig_flags.size] = "stream_rush_chopper";
	trig_flags[trig_flags.size] = "stream_backend_moveup_stealth";
	
	foreach( flag_name in trig_flags )
	{
		init_flag_and_set_on_targetname_trigger( flag_name );
	}

}

init_flag_and_set_on_targetname_trigger( trig_targetname )
{
	flag_init( trig_targetname );
	thread set_flag_on_targetname_trigger( trig_targetname );	
}

init_radio_dialogue()
{
	/* =-=-=-
 	U A V
 	=-=-=-*/
	
	//We're online.
	level.scr_radio[ "jungleg_at1_online" ] = "jungleg_at1_online";
	//Well, what do you see?
	level.scr_radio[ "jungleg_at2_whatdoyousee" ] = "jungleg_at2_whatdoyousee";
	//I see us…and lots of trees.  Bravo Team what's your loaction?
	level.scr_radio[ "jungleg_at1_lotsoftrees" ] = "jungleg_at1_lotsoftrees";
	//Half a click South East of the Waterfall, over.
	level.scr_radio[ "jungleg_bt1_halfaclick" ] = "jungleg_bt1_halfaclick";
	//Roger that, southeast of the waterfall...scanning sector…
	level.scr_radio[ "jungleg_at1_scanning" ] = "jungleg_at1_scanning";	
	//OK I got eyes on you position
	level.scr_radio[ "jungleg_at1_goteyes" ] = "jungleg_at1_goteyes";
	//uhh...Bravo team I'm seeing a lot of enemy movement in your vicinity....etc
	level.scr_radio[ "jungleg_at1_donotengage" ] = "jungleg_at1_donotengage";
	//Roger that. We'll stay out of sight.   Bravo out. 
	level.scr_radio[ "jungleg_bt1_toodifficult" ] = "jungleg_bt1_toodifficult";
	//Crib, this is Alpha-One.  We are proceeding to Bravo's location.  Standing by for radio-jammer activation.
	level.scr_radio[ "jungleg_at1_delayingrmp" ] = "jungleg_at1_delayingrmp";
	//Negative, Alpha-One. RMP will kill all radio frequencies in the area for at least two-five mikes.  
	level.scr_radio[ "jungleg_chq_radiosilence" ] = "jungleg_chq_radiosilence";
	//Copy that crib.  ETA on RMP?
	level.scr_radio[ "jungleg_at1_etaonrmp" ] = "jungleg_at1_etaonrmp";
	//RMP active in... 5…4….3….2….<static squelch>
	level.scr_radio[ "jungleg_chq_rmpactive" ] = "jungleg_chq_rmpactive";
	
}

init_dialogue()
{
	//JUNGLE INTRO
	
	//Alright, we're dark.
	level.scr_sound[ "alpha1" ][ "jungleg_at1_weredark" ] = "jungleg_at1_weredark";
	//take us out
	level.scr_sound[ "alpha1" ][ "jungleg_at1_takeusout" ] = "jungleg_at1_takeusout";
	//We can clear 'em out quietly, or just pass through. Either way let's avoid rattling the cage.
	level.scr_sound[ "alpha1" ][ "jungleg_at1_rattlingthecage" ] = "jungleg_at1_rattlingthecage";
	//Patrol incoming, top of the hill.  Stay out of sight, or clear em out - your call. 
	level.scr_sound[ "alpha1" ][ "jungleg_at1_yourcall" ] = "jungleg_at1_yourcall";
	//goin silent
	level.scr_sound[ "alpha1" ][ "jungleg_at1_goinsilent" ] = "jungleg_at1_goinsilent";
	//Take point. The waterfall is a half-click up. 
	level.scr_sound[ "alpha1" ][ "jungleg_at1_halfclickup" ] = "jungleg_at1_halfclickup";
	//No sign of bravo…they might need extract.  Keep moving to the top of the hill. 
	level.scr_sound[ "alpha1" ][ "jungleg_at1_mightneedextract" ] = "jungleg_at1_mightneedextract";
	//C'mon, top of the hill, let's move!
	level.scr_sound[ "alpha1" ][ "jungleg_at1_topofthehill" ] = "jungleg_at1_topofthehill";
	//That sounds bad.  Be ready for anything.
	level.scr_sound[ "alpha1" ][ "jungleg_at1_soundsbad" ] = "jungleg_at1_soundsbad";
	//Pick one, we'll clear the rest. Do it.
	level.scr_sound[ "alpha1" ][ "jungleg_at1_pickone" ] = "jungleg_at1_pickone";
	//we got company
	level.scr_sound[ "alpha1" ][ "jungleg_at1_gotcompany" ] = "jungleg_at1_gotcompany";
	//that was close
	level.scr_sound[ "alpha1" ][ "jungleg_at1_thatwasclose" ] = "jungleg_at1_thatwasclose";
	//with you
	level.scr_sound[ "alpha1" ][ "jungleg_at1_withyou" ] = "jungleg_at1_withyou";
	//im with ya
	level.scr_sound[ "alpha1" ][ "jungleg_at1_withya" ] = "jungleg_at1_withya";
	//hes down
	level.scr_sound[ "alpha1" ][ "jungleg_at1_hesdown" ] = "jungleg_at1_hesdown";
	//target down
	level.scr_sound[ "alpha1" ][ "jungleg_at1_targetdown" ] = "jungleg_at1_targetdown";
	//theres the waterfall
	level.scr_sound[ "alpha1" ][ "jungleg_at1_theresthewaterfall" ] = "jungleg_at1_theresthewaterfall";
	//lets Do it
	level.scr_sound["alpha1"]["jungleg_at1_letsdoit"] = "jungleg_at1_letsdoit";
	//ready when you are
	level.scr_sound["alpha1"]["jungleg_at1_whenyouare"] = "jungleg_at1_whenyouare";
	//they found a body..lets keep moving..
	level.scr_sound["alpha1"]["jungleg_at1_foundabody"] = "jungleg_at1_foundabody";	
		//Lets do it
	level.scr_sound["alpha1"]["jungleg_at1_letsdoit"] = "jungleg_at1_letsdoit";	
	//Ready when you are
	level.scr_sound["alpha1"]["jungleg_at1_whenyouare"] = "jungleg_at1_whenyouare";	
	
	//we got company
	level.scr_sound["alpha2"]["jungleg_at2_gotcompany"] = "jungleg_at2_gotcompany";
	//that was close
	level.scr_sound["alpha2"]["jungleg_at2_thatwasclose"] = "jungleg_at2_thatwasclose";
	//with you..
	level.scr_sound["alpha2"]["jungleg_at2_withyou"] = "jungleg_at2_withyou";
	//im with ya
	level.scr_sound["alpha2"]["jungleg_at2_withya"] = "jungleg_at2_withya";
	//im with you
	level.scr_sound["alpha2"]["jungleg_at2_imwithyou"] = "jungleg_at2_imwithyou";
	//hes down
	level.scr_sound["alpha2"]["jungleg_at2_hesdown"] = "jungleg_at2_hesdown";
	//target down
	level.scr_sound["alpha2"]["jungleg_at2_targetdown"] = "jungleg_at2_targetdown";
	//Theres the waterfall
	level.scr_sound["alpha2"]["jungleg_at2_theresthewaterfall"] = "jungleg_at2_theresthewaterfall";
	//lets do it
	level.scr_sound["alpha2"]["jungleg_at2_letsdoit"] = "jungleg_at2_letsdoit";
	//ready when you are
	level.scr_sound["alpha2"]["jungleg_at2_whenyouare"] = "jungleg_at2_whenyouare";
	//they found a body...lets keep moving
	level.scr_sound["alpha2"]["jungleg_at2_foundabody"] = "jungleg_at2_foundabody";	
	
	//Lets do it
	level.scr_sound["alpha2"]["jungleg_at2_letsdoit"] = "jungleg_at2_letsdoit";	
	//Ready when you are
	level.scr_sound["alpha2"]["jungleg_at2_whenyouare"] = "jungleg_at2_whenyouare";	

}

should_toggle_silencer()
{
	weapon	= level.player GetCurrentWeapon();
	alt_ = StrTok( weapon, "_" );
	if ( IsDefined( alt_.size ) )
	{	
		if ( alt_[ 0 ] == "alt" )
	   	{
	   		return true;
	   	}
	   	else
	   	{
	   		return false;
	   	}
	}		
}

should_switchto_soflam()
{
	if ( level.player GetCurrentWeapon() == "soflam" )
		return true;
	
	return false;
}

should_use_soflam()
{
	if ( level.player GetCurrentWeapon() == "soflam" && level.player PlayerAds() >= .25 )
		return true;
	
	return false;
}

jungle_start()
{
	//thread maps\jungle_ghosts_uav::static_flash( 1.5 );
	thread maps\jungle_ghosts_jungle::intro_setup();
	thread objectives( "jungle" );
}

parachute_start()
{
	thread maps\jungle_ghosts_jungle::intro_setup();
	thread objectives( "jungle" );
}

e3_start()
{
	// for e3 only
	SetDvar ("music_enable",1);
	
	level.player TakeAllWeapons();
	
	level.player SetMoveSpeedScale(.40 );
	level.player SetMoveSpeedScale(.75);
	SetSavedDvar( "player_sprintSpeedScale", 1.2 ); //default 1.5
		
	create_dvar("is_e3_level", true);
	
	thread objectives( "jungle" );
	thread maps\jungle_ghosts_util::cull_distance_logic();
	thread maps\jungle_ghosts_util::fade_out_in( "black", undefined, 1  );
	thread maps\jungle_ghosts_util::fade_out_in( "white", undefined, .10  );

	//maps\jungle_ghosts_util::move_player_to_start( "jungle_player_start" );
	thread maps\jungle_ghosts_jungle::setup_friendlies();	
	thread maps\jungle_ghosts_jungle::setup_jungle_enemies();
	
	// warp player to structs here
	maps\jungle_ghosts_util::move_player_to_start( "e3_player" );		
	alpha_structs = getstructarray( "e3_ai", "targetname" );
	
	while(!isdefined( level.alpha ) ) //wait here until friendlies are spawned! This could be disasterous!!!Ahhhhhhhh!!!!!!
		wait .10;
	
	foreach( i, struct in alpha_structs )
	{
		level.alpha[i] ForceTeleport( struct.origin, struct.angles );
		level.alpha[i] set_force_color( "r" );
	}	
	
	trig = getent("corridor_moveup","targetname");
	trig notify ("trigger");
	
	flag_set("player_landed");
	
	thread maps\jungle_ghosts_jungle::hill_fx();
	thread maps\jungle_ghosts_util::do_bokeh( "hill_pos_1" );
		
	thread maps\jungle_ghosts_jungle::do_birds();
	level thread maps\jungle_ghosts_jungle::jungle_stealth_settings();
	
	thread maps\jungle_ghosts_jungle::motion_tracker_setup();
	
	// do we need this?
	thread maps\jungle_ghosts_jungle::inform_player_when_section1_is_clear();
	thread maps\jungle_ghosts_jungle::first_distant_sat_launch();
	
	thread maps\jungle_ghosts_jungle::dead_pilot_hang();
		
	level.did_inactive_vo = 0;

	wait 1;

	guns = ["p226_tactical+silencerpistol_sp+tactical_sp"]; //usp_no_knife_silencer honeybadger+acog_sp  iw5_m4_sp_heartbeat_reflex_silencerunderbarrel  //usp_silencer
	maps\jungle_ghosts_util::arm_player( guns ); 
	

		
	flag_wait("jungle_entrance");
	autosave_by_name("jungle_entrance");
	thread maps\jungle_ghosts_jungle::ambient_jungle_music();
	thread maps\jungle_ghosts_jungle::player_spotted_music();
	
	
	flag_wait( "crash_arrive");
	if(! flag( "_stealth_spotted" ) )
	{
		level notify("stop_ambient_music");
		music_stop( 2 );
		//music_play("mx_jungle_runway_objective");
	}
	
	// WARP AND GO!
	fade_out(2, "black");
	thread e3_start_part2();
}

e3_start_part2()
{
	level.start_point = "stream";
	
	river_blocker = get_target_ent("river_blocker");
	river_blocker ConnectPaths();
	river_blocker Delete();
	
	guys = GetAIArray("axis");
	foreach (guy in guys)
		guy delete();
	
	flag_set ("e3_warp");
	
	activate_trigger_with_targetname( "stream_pos_1" );
	
	thread maps\jungle_ghosts_stream::jungle_cleanup();
	
	battlechatter_off();
	thread objectives( "stream" );
	maps\jungle_ghosts_util::move_player_to_start( "stream_start_player" );
	guns = ["honeybadger+acog_sp", "p226_tactical+silencerpistol_sp+tactical_sp" ];
	maps\jungle_ghosts_util::arm_player(guns, 1 );
	
	// alpha should be assigned
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	structs = getstructarray( "stream_start_ai", "targetname" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.bravo, ::set_force_color, "b" );
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.alpha, ::enable_ai_color );
		
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	
	array_thread( level.bravo, ::stream_friendly_setup );
		
	flag_set( "waterfall_clear" );
	flag_set( "second_distant_sat_launch" );
	flag_set("player_rescued_hostage");
	
	array_thread( guys, ::stream_friendly_setup_e3 );
	thread maps\jungle_ghosts_stream::friendly_stream_navigation();
	
	level.player thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");

	friendlyfire_warnings_off();	
	
	wait 2;
	fade_in(2, "black");
	
	flag_wait("field_entrance");
	
	// FOR E3
	wait 5;
	nextmission();
}

jungle_corridor_start()
{		
	flag_set("player_landed");
	flag_set("slamzoom_finished");
	thread maps\jungle_ghosts_util::cull_distance_logic();
	maps\jungle_ghosts_util::move_player_to_start( "jungle_corridor_player" );	
	
	thread maps\jungle_ghosts_jungle::setup_friendlies();	
	thread maps\jungle_ghosts_jungle::setup_jungle_enemies();
	
	thread maps\jungle_ghosts_jungle::dead_pilot_hang();
	
	alpha_structs = getstructarray( "jungle_corridor_ai", "targetname" );
	
	while(!isdefined( level.alpha ) ) //wait here until friendlies are spawned! This could be disasterous!!!Ahhhhhhhh!!!!!!
		wait .10;
	
	foreach( i, struct in alpha_structs )
	{
		level.alpha[i] ForceTeleport( struct.origin, struct.angles );
		level.alpha[i] set_force_color( "r" );
	}
	
	activate_trigger_with_targetname( "corridor_moveup" );
	thread objectives( "jungle" );
	
	thread maps\jungle_ghosts_jungle::hill_fx();
	thread maps\jungle_ghosts_util::do_bokeh( "hill_pos_1" );
	thread maps\jungle_ghosts_jungle::do_birds();
	thread maps\jungle_ghosts_jungle::jungle_stealth_settings();	
	thread maps\jungle_ghosts_jungle::connect_dropdown_traverse();
	thread maps\jungle_ghosts_jungle::motion_tracker_setup();
	thread maps\jungle_ghosts_jungle::inform_player_when_section1_is_clear();
	level.did_inactive_vo = 0;
	
	level.player allowcrouch(true);
	level.player allowprone(true);		
	level.player SetMoveSpeedScale(.40 );
	level.player DisableInvulnerability();
	
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp"]; //usp_no_knife_silencer honeybadger+acog_sp  iw5_m4_sp_heartbeat_reflex_silencerunderbarrel  //usp_silencer
	maps\jungle_ghosts_util::arm_player( guns ); //m240_heartbeat_reflex
	wait 1;
	//maps\jungle_ghosts_jungle::attach_motion_tracker();
	
	//player exits corridor
	flag_wait("jungle_entrance");
	autosave_by_name("jungle_entrance");
	
	thread maps\jungle_ghosts_jungle::player_spotted_logic();
	thread maps\jungle_ghosts_jungle::ambient_jungle_music();
	thread maps\jungle_ghosts_jungle::player_spotted_music();
	
	flag_wait( "crash_arrive");
	
	if(! flag( "_stealth_spotted" ) )
	{
		level notify("stop_ambient_music");
		music_stop( 2 );
		//music_play("mx_jungle_runway_objective");
	}
}

#using_animtree("generic_human");
crash_test_start()
{
	level.player SetOrigin( (673, 5084, 564.411) );
	
	crash_final_collision = getent( "crash_final_collision", "targetname" );
	crash_final_collision NotSolid();
	
	dest_crate = getent( "dest_crate", "targetname" );
	dest_crate NotSolid();
	
	scene = getstruct("new_crash", "targetname" );
	
	scene.chopper = spawn_anim_model( "aas" );
	scene.chopper thread maps\jungle_ghosts_stream::chopper_sound();
	thread maps\jungle_ghosts_stream::chopper_rumble_earthquake();
	
	scene.crate_clip = getent( "chopper_clip", "targetname" );	
	scene.crate_clip.origin = scene.chopper.origin;
	scene.crate_clip.angles = scene.chopper.angles;
	scene.crate_clip linkto( scene.chopper, "tag_origin" );
	
	scene.pristine_crate = spawn_anim_model( "pristine_crate" );
	scene.damaged_crate = spawn_anim_model( "damaged_crate" );
	scene.pilot = spawn_targetname( "chopper_pilot", 1 );
	scene.pilot.animname = "pilot";
	scene.pilot thread maps\jungle_ghosts_stream::crash_pilot_logic( scene.chopper);
	
	
	scene.pilot_corpse = spawn( "script_model", scene.origin );
	scene.pilot_corpse setmodel( scene.pilot.model );
	scene.pilot_corpse UseAnimTree( #animtree );
	scene.pilot_corpse.origin = scene.chopper GetTagOrigin( "tag_driver" );
	scene.pilot_corpse.angles = scene.chopper GetTagangles( "tag_driver" );
	scene.pilot_corpse linkto( scene.chopper );
	scene.pilot_corpse SetAnimKnob( %jungle_ghost_helicrash_pilot, 1, 0, 0 );
	scene.pilot_corpse SetAnimTime( %jungle_ghost_helicrash_pilot, 1 );
	
	scene.actors = [  scene.pilot, scene.pristine_crate, scene.damaged_crate, scene.chopper];
	
	scene thread  anim_loop( scene.actors, "new_crash_idle" );
	wait( 5 );
	flag_set("smaw_target_detroyed");
	
	scene anim_single( scene.actors, "new_crash" );
	
	crash_final_collision Solid();
	crash_final_collision DisconnectPaths();
	scene.crate_clip delete();
		
}


chopper_crash_fx()
{
	IPrintLnbold("sweet");
	activate_exploder( "Helikilled" );
}

dest_tree_test()
{
	thread fog_set_changes( "jungle_dusk", .05 );
	//thread set_audio_zone( "jungle_ghosts_intro" );
	maps\jungle_ghosts_runway::escape_setup_trees();
	level.player SetOrigin((246, 11798, 755.036) );
	level.player setPlayerAngles( (0, 180, 0) );
	maps\jungle_ghosts_util::arm_player( ["honeybadger+acog_sp", "usp_no_knife_silencer"] );
}


underwater_test()
{
	struct = getstruct("struct_player_bigjump_edge_reference", "targetname" );
	level.player SetOrigin(struct.origin );
	level.player setPlayerAngles( struct.angles );
	level.player EnableInvulnerability();
	level.mover = level.player spawn_tag_origin();
	thread maps\jungle_ghosts_runway::escape_player_water_logic();
	thread maps\jungle_ghosts_runway::new_player_jump();
	//thread maps\jungle_ghosts_runway::escape_waterfall_player_link_logic();
}

custom_intro_screen_func()
{
	flag_wait( "intro_lines" );
	maps\_introscreen::introscreen( true );	
}

jungle_hill_start()
{
	//thread set_audio_zone( "jungle_ghosts_intro" );
	thread maps\jungle_ghosts_util::cull_distance_logic();
	level thread maps\jungle_ghosts_jungle::jungle_stealth_settings();
	battlechatter_off();
	thread objectives( "jungle_hill" );
	array_spawn_function_targetname( "alpha_team", maps\jungle_ghosts_jungle::jungle_friendly_logic );
	
	thread maps\jungle_ghosts_jungle::setup_hill_enemies();
	
	maps\jungle_ghosts_util::move_player_to_start( "jungle_hill_start_player" );	
	//level.player vision_set_changes( "jungle_dawn", .05 );	
	
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp" ]; //iw5_m4_sp_heartbeat_reflex_silencerunderbarrel honeybadger+acog_sp   iw5_m4_sp_reflex_silencerunderbarrel iw5_m4_sp_acog_silencerunderbarrel
	maps\jungle_ghosts_util::arm_player( guns, 1 ); //m240_heartbeat_reflex
	wait 1;
	//maps\jungle_ghosts_jungle::attach_motion_tracker();
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	
	alpha_structs = getstructarray( "jungle_hill_start_ai", "targetname" );
	
	foreach( i, struct in alpha_structs )
	{
		level.alpha[i] ForceTeleport( struct.origin, struct.angles );
		level.alpha[i] set_force_color( "r" );
	}
	
	wait(.5);
	array_thread( level.alpha, maps\jungle_ghosts_jungle::cqb_when_player_sees_me );
	level thread maps\jungle_ghosts_jungle::friendly_navigation();
	level thread maps\jungle_ghosts_jungle::attack_with_player();
	//thread set_audio_zone( "jungle_ghosts_intro" );
	thread jungle_hill_music();
	level thread maps\jungle_ghosts_jungle::jungle_vo();
	
	level thread maps\jungle_ghosts_jungle::player_spotted_logic();
	//level delaythread ( 2, ::display_hint_timeout, "hint_silencer_toggle", 4 );
	
	flag_set("jungle_entrance");
	activate_trigger_with_targetname( "jungle_entrance" );
	thread maps\jungle_ghosts_jungle::motion_tracker_setup();
	//sneaky_trigs = getentarray("sneaky_trigs", "targetname" );
	//array_thread( sneaky_trigs, maps\jungle_ghosts_jungle::sneaky_trig_logic );
	array_thread( level.alpha, maps\jungle_ghosts_jungle::dynamic_vo_manager );
	
	
	
	flag_wait("waterfall_approach");
	thread maps\jungle_ghosts_jungle::waterfall_execution();
	level.player thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");
	music_stop( 5 );

}

jungle_hill_music()
{
	flag_wait( "crash_arrive");
	level notify("stop_ambient_music");
	music_stop( 2 );
	
	//music_play("mx_jungle_runway_objective");
	
}

execution_start()
{	
	battlechatter_off();
	thread objectives( "waterfall" );
	maps\jungle_ghosts_util::move_player_to_start( "waterfall_execution_player" );
	guns = ["honeybadger+acog_sp", "p226_tactical+silencerpistol_sp+tactical_sp" ];
	maps\jungle_ghosts_util::arm_player( guns, 1 );
	//level.player vision_set_changes( "jungle_dawn", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	alpha_structs = getstructarray( "waterfall_execution_ai", "targetname" );
	
	foreach( i, struct in alpha_structs )
	{
		level.alpha[i] ForceTeleport( struct.origin, struct.angles );
		level.alpha[i] set_force_color( "r" );		
		level.alpha[i] ent_flag_init( "stealth_kill" );
		level.alpha[i] thread magic_bullet_shield( 1 );
	}
	
	thread maps\jungle_ghosts_jungle::waterfall_execution();

	activate_trigger_with_targetname( "waterfall_approach" );
	
	level thread maps\jungle_ghosts_jungle::jungle_vo();
	friendlyfire_warnings_off();
}

stream_start()
{
	river_blocker = get_target_ent("river_blocker");
	river_blocker ConnectPaths();
	river_blocker Delete();
	
	battlechatter_off();
	thread objectives( "stream" );
	maps\jungle_ghosts_util::move_player_to_start( "stream_start_player" );
	guns = ["honeybadger+acog_sp", "p226_tactical+silencerpistol_sp+tactical_sp" ];
	maps\jungle_ghosts_util::arm_player(guns, 1 );
	//level.player vision_set_changes( "jungle_dawn", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	structs = getstructarray( "stream_start_ai", "targetname" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.bravo, ::set_force_color, "b" );
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.alpha, ::enable_ai_color );
		
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	
	flag_set( "waterfall_clear" );
	flag_set( "second_distant_sat_launch" );
	flag_set("player_rescued_hostage");
	
	array_thread( guys, ::stream_friendly_setup );
	thread maps\jungle_ghosts_stream::friendly_stream_navigation();
	
	level.player thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");
	//set_audio_zone("jungle_ghosts_stream");
	friendlyfire_warnings_off();
}

stream_waterfall_start()
{
	battlechatter_off();
	thread objectives( "stream" );
	maps\jungle_ghosts_util::move_player_to_start( "stream_waterfall_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	maps\jungle_ghosts_util::arm_player(guns, 1 );
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	level.squad = array_combine( level.alpha, level.bravo );
	structs = getstructarray( "stream_waterfall_ai", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.bravo, ::set_force_color, "b" );
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.alpha, ::enable_ai_color );
	
	//func = maps\jungle_ghosts_jungle::jungle_friendly_logic;
	array_thread( level.squad, 	::ent_flag_init, "stealth_kill");
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	
	array_thread( guys, ::stream_friendly_setup );
	thread maps\jungle_ghosts_stream::friendly_stream_navigation();
	thread maps\jungle_ghosts_stream::stream_enemy_setup( "waterfall" );
	battlechatter_off();
	level.player thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");
	//thread swap_to_overcast_sky();
	//set_audio_zone("jungle_ghosts_stream");
	friendlyfire_warnings_off();
}

stream_backend_start()
{
	battlechatter_off();
	thread objectives( "stream" );
	maps\jungle_ghosts_util::move_player_to_start( "stream_backend_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	maps\jungle_ghosts_util::arm_player(guns, 1 );
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	level.squad = array_combine( level.alpha, level.bravo );
	structs = getstructarray( "stream_backend_ai", "targetname" );
	
	array_thread( level.squad, 	::ent_flag_init, "stealth_kill" );
		
	guys = GetAIArray( "allies" );
	foreach ( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.bravo, ::set_force_color, "b" );
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.alpha, ::enable_ai_color );
		
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	
	array_thread( guys, ::stream_friendly_setup );
	thread maps\jungle_ghosts_stream::friendly_stream_navigation();
	thread maps\jungle_ghosts_stream::stream_enemy_setup( "backend" );
	battlechatter_on();
	level.player thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");
	thread swap_to_overcast_sky();
	//set_audio_zone("jungle_ghosts_stream");
	friendlyfire_warnings_off();
}

tall_grass_start()
{
	//battlechatter_off();
	thread objectives( "tall_grass" );
	
	maps\jungle_ghosts_util::move_player_to_start( "tall_grass_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp" ]; //usp_no_knife_silencer honeybadger+acog_sp  iw5_m4_sp_heartbeat_reflex_silencerunderbarrel  //usp_silencer
	maps\jungle_ghosts_util::arm_player( guns ); //m240_heartbeat_reflex
	wait 1;
	
	//maps\jungle_ghosts_jungle::attach_motion_tracker();
	//level.player vision_set_changes( "jungle_dawn", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	structs = getstructarray( "tall_grass_ai", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.bravo, ::set_force_color, "b" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	array_thread( level.squad, ::enable_ai_color );	
	array_thread( level.squad, ::tall_grass_friendly_setup );	
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	
	array_thread( level.squad, 	::ent_flag_init, "stealth_kill" );
		
	//PlayFX( getfx( "btr_dest_blacksmoke" ), struct.origin );
	//set_audio_zone("jungle_ghosts_grass");
	//array_thread( level.squad, maps\jungle_ghosts_jungle::generic_ignore_on );
	thread maps\jungle_ghosts_stream::tall_grass_globals();
	//thread 	maps\jungle_ghosts_stream::tall_grass_enemy_setup();
	thread 	maps\jungle_ghosts_stream::tall_grass_friendly_navigation();
	activate_trigger_with_targetname( "stream_exit" );
	battlechatter_off();
	thread swap_to_overcast_sky();
	activate_trigger_with_targetname( "stream_backend_moveup" );
	//flag_set("stream_backend_moveup");

}

tall_grass_chopper_start()
{
	thread objectives( "tall_grass" );
	maps\jungle_ghosts_util::move_player_to_start( "tall_grass_chopper_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp" ]; //usp_no_knife_silencer honeybadger+acog_sp  iw5_m4_sp_heartbeat_reflex_silencerunderbarrel  //usp_silencer
	maps\jungle_ghosts_util::arm_player( guns ); //m240_heartbeat_reflex
	wait 1;
	//maps\jungle_ghosts_jungle::attach_motion_tracker();


	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	structs = getstructarray( "tall_grass_chopper_ai", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.bravo, ::set_force_color, "b" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	array_thread( level.squad, ::enable_ai_color );	
	array_thread( level.squad, ::tall_grass_friendly_setup );	
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	
	thread maps\jungle_ghosts_stream::tall_grass_globals(1);
	//thread 	maps\jungle_ghosts_stream::tall_grass_enemy_setup();
	thread 	maps\jungle_ghosts_stream::tall_grass_friendly_navigation();
	
	flag_Set("tall_grass_intro_halfway");
	flag_set("to_grassy_field");
	flag_set("jungle_entrance");
	//activate_trigger_with_targetname( "stream_exit" );
	battlechatter_off();
	thread swap_to_overcast_sky();
	//activate_trigger_with_targetname( "stream_backend_moveup" );
}


tall_grass_nogame_start()
{
	thread swap_to_overcast_sky();
	maps\jungle_ghosts_util::move_player_to_start( "nogame_player_start" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	maps\jungle_ghosts_util::arm_player( guns, 1 );
	//level.player vision_set_fog_changes( "jungle_tall_grass_arrive", .05 );	
	
	flag_set("field_entrance" );
	level thread maps\jungle_ghosts_stream::tall_grass_moving_grass_settings();
}

runway_start()
{
	//battlechatter_off();
	//thread objectives( "runway" );
	//flag_set("begin_monitoring_soflam");
	thread maps\jungle_ghosts_runway::runway_setup();
	maps\jungle_ghosts_util::move_player_to_start( "runway_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	maps\jungle_ghosts_util::arm_player( guns, 1 );
	//level.player vision_set_fog_changes( "jungle_tall_grass_arrive", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	structs = getstructarray( "runway_ai", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.bravo, ::set_force_color, "b" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	array_thread( level.squad, ::enable_ai_color );	
	array_thread( level.squad, ::tall_grass_friendly_setup );	
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	battlechatter_off();
	activate_trigger_with_targetname( "squad_to_runway" );	
	thread objectives( "runway" );
	thread runway_escape_weather();
	thread swap_to_overcast_sky();
	flag_set("prone_guys_dead");

}


runway_escape_weather()
{	
	thread maps\jungle_ghosts_util::start_raining();
	thread maps\jungle_ghosts_util::thunder_and_lightning( 8, 12 );	
	//set_audio_zone("jungle_ghosts_escape_rain");	
	level.player SetClientTriggerAudioZone( "jungle_ghosts_escape_rain", 0.1 );		
}

escape_runway_start()
{
	maps\jungle_ghosts_util::move_player_to_start( "escape_runway_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	maps\jungle_ghosts_util::arm_player( guns, 1 );
	//level.player vision_set_fog_changes( "jungle_tall_grass_arrive", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	structs = getstructarray( "escape_runway_ai", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.bravo, ::set_force_color, "b" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	array_thread( level.squad, ::enable_ai_color );	
	array_thread( level.squad, ::magic_bullet_shield );	
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	battlechatter_off();
	activate_trigger_with_targetname( "squad_to_runway" );	
	thread objectives( "escape_runway" );
	thread maps\jungle_ghosts_runway::escape_globals( "runway");
	
	//setup the attack apache
	node = getent_or_struct( "apache1_start_point", "script_noteworthy" );
	blah = getent( "runway_apache", "script_noteworthy");
	level.apache1 = vehicle_spawn( blah );
	level.apache1 thread maps\jungle_ghosts_runway::runway_apache_logic("runway");
	
	level.apache1 Vehicle_Teleport( node.origin, node.angles );
	level.apache1 thread vehicle_paths( node );	
	wait .10;
	level.apache1 Vehicle_SetSpeedImmediate( 50 );

}

escape_jungle_start()
{
	maps\jungle_ghosts_util::move_player_to_start( "escape_jungle_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	//level.player vision_set_fog_changes( "jungle_tall_grass_arrive", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	assign_bravo();
	structs = getstructarray( "escape_jungle_ai", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.bravo, ::set_force_color, "b" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	array_thread( level.squad, ::enable_ai_color );	
	array_thread( level.squad, ::magic_bullet_shield );	
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	battlechatter_off();
	
	thread objectives( "escape_runway" );
	thread maps\jungle_ghosts_runway::escape_globals( "jungle" );
	
	//setup the attack apache
	node = getent_or_struct( "chopper_over_tallgrass", "script_noteworthy" );
	blah = getent( "runway_apache", "script_noteworthy");
	level.apache1 = vehicle_spawn( blah );
	
	level.apache1 Vehicle_Teleport( node.origin, (0, 130, 0) );
	level.apache1 thread maps\jungle_ghosts_runway::runway_apache_logic( "jungle" );
	
	if(  GetDvarInt( "jungle_music" ) == 1 )
				music_play( "mus_jungle_escape" );
	
	thread runway_escape_weather();

}

escape_river_start()
{
	thread maps\jungle_ghosts_jungle::slomo_sound_scale_setup();
	level.river_apache = thread spawn_vehicle_from_targetname_and_drive( "river_chopper");
	maps\jungle_ghosts_util::move_player_to_start( "escape_river_player" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	maps\jungle_ghosts_util::arm_player( guns, 1 );
	//level.player vision_set_fog_changes( "jungle_tall_grass_arrive", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	structs = getstructarray( "escape_river_ai", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.bravo, ::set_force_color, "b" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	array_thread( level.squad, ::enable_ai_color );	
	array_thread( level.squad, ::magic_bullet_shield );	
	
	//setup the attack apache
	node = getent_or_struct( "attack_river_jump", "targetname" );
	blah = getent( "runway_apache", "script_noteworthy");
	level.apache1 = vehicle_spawn( blah );
	
	level.apache1 Vehicle_Teleport( node.origin, node.angles );
	level.apache1 thread maps\jungle_ghosts_runway::runway_apache_logic( "river" );
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	battlechatter_off();
	thread maps\jungle_ghosts_runway::escape_globals( "river" );
	flag_set( "escape_halfway" );
	//flag_set("fastropers_dead" );
	level.river_apache mgoff();
	thread runway_escape_weather();
	music_play( "mus_jungle_escape" );
	
}

escape_waterfall_start()
{
	level.river_apache = thread spawn_vehicle_from_targetname_and_drive( "river_chopper");
	maps\jungle_ghosts_util::move_player_to_start( "waterfall_player_land" );
	guns = ["p226_tactical+silencerpistol_sp+tactical_sp", "honeybadger+acog_sp"];
	maps\jungle_ghosts_util::arm_player( guns, 1 );
	//level.player vision_set_fog_changes( "jungle_tall_grass_arrive", .05 );	
	
	level.alpha = array_spawn_targetname( "alpha_team", 1 );
	assign_alpha();
	level.bravo = array_spawn_targetname( "bravo_team", 1 );
	structs = getstructarray( "waterfall_ai_land", "targetname" );
	
	guys = getaiarray( "allies" );
	foreach( i, struct in structs )
	{
		guys[i] ForceTeleport( struct.origin, struct.angles );
	}
	
	array_thread( level.alpha, ::set_force_color, "r" );	
	array_thread( level.bravo, ::set_force_color, "b" );
	
	level.squad = array_combine( level.alpha, level.bravo );
	array_thread( level.squad, ::enable_ai_color );	
	array_thread( level.squad, ::magic_bullet_shield );	
	
	//setup the attack apache
//	node = getent_or_struct( "attack_river_jump", "targetname" );
//	blah = getent( "runway_apache", "script_noteworthy");
//	level.apache1 = vehicle_spawn( blah );
//	
//	level.apache1 Vehicle_Teleport( node.origin, node.angles );
//	level.apache1 thread maps\jungle_ghosts_runway::runway_apache_logic( "river" );
	
	thread maps\jungle_ghosts_jungle::setup_smaw_guy();
	battlechatter_off();
//	thread maps\jungle_ghosts_runway::escape_globals( "river" );
//	flag_set( "escape_halfway" );
//	flag_set("fastropers_dead" );
//	
//	if(  GetDvarInt( "jungle_music" ) == 1 )
//				music_play( "mx_jungle_escape" );
	thread runway_escape_weather();
	thread escape_setup_swimming();
}

escape_setup_swimming()
{	
	level thread  maps\jungle_ghosts_util::player_swim_think();
	
	foreach( guy in level.squad )
	{	
		guy thread maps\jungle_ghosts_util::enable_ai_swim();
	}
	
}

stream_friendly_setup()
{
	//set_ai_bcvoice( "delta" );
	self.ignoreme = 1;
	self thread magic_bullet_shield( 1 );	
	self thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");
	//self set_friendlyfire_warnings( false );
}

stream_friendly_setup_e3()
{
	//set_ai_bcvoice( "delta" );
	self.ignoreme = 1;
	self thread maps\jungle_ghosts_util::stream_waterfx("stop_water_footsteps", "step_run_plr_water");
	//self set_friendlyfire_warnings( false );
}


tall_grass_friendly_setup()
{
	self thread magic_bullet_shield( 1 );
	self.ignoreme = 1;
	self.ignoreall = 1;
	//self set_friendlyfire_warnings( false );
}

swap_to_overcast_sky()
{
	if( flag("skybox_changed" ) )
		return;	
	current_sunlight = GetMapSunLight();
	new_sunlight = (206/256, 225/256, 255/256 );
	thread sun_light_fade( current_sunlight, new_sunlight, .10 );
	
	flag_set("skybox_changed");	
	if( isdefined( level.rain_skybox ) )
		level.rain_skybox show();	
	
}

assign_alpha()
{	
	foreach( guy in level.alpha )
	{
		if( guy.script_friendname == "Elias" )
		{
			level.alpha1 = guy;		
			level.alpha1.animname = "alpha1";			
			level.alpha1 forceUseWeapon( "honeybadger", "primary" );
			level.alpha1 set_ai_bcvoice( "taskforce" );
			level.alpha1.npcID = "pri"; 
		}
		else
		{
			level.alpha2 = guy;
			level.alpha2.animname = "alpha2";
			level.alpha2 set_ai_bcvoice( "delta" );
			level.alpha2.npcID = 0; 
			level.alpha2 forceUseWeapon( "honeybadger", "primary" );
		}
	}	
}

assign_bravo()
{
	foreach( guy in level.bravo )
	{
		if( guy.script_friendname == "Merrick" )
		{
			level.baker = guy;
			guy.animname = "baker";
			guy set_ai_bcvoice( "delta" );
			guy.npcID = 0; 
			level.baker forceUseWeapon( "honeybadger", "primary" );
		}
		else
		{
			level.diaz = guy;
			guy.animname = "diaz";
			guy set_ai_bcvoice( "delta" );
			guy.npcID = 0; 
			level.diaz forceUseWeapon( "honeybadger", "primary" );
		}
	}
}

objectives( start_point )
{
	switch ( start_point )
	{
		case "default":
			
		case "uav":
			
		case "jungle":
			flag_wait( "jumped_down" );
			Objective_Add( obj( "runway" ), "current", &"JUNGLE_GHOSTS_OBJ_PRIMARY_MISSION_OBJ" );
			
			
			flag_wait( "jungle_entrance_approach" );
			wait( 2 );
			Objective_Add( obj( "waterfall" ), "current", &"JUNGLE_GHOSTS_OBJ_LEAD_TO_WATERFALL" );
			
		case "jungle_hill":	
			flag_wait("waterfall_approach" );
			objective_complete( obj( "waterfall" ) );
			
		case "waterfall":	
			
			flag_wait("player_at_execution");
			Objective_Add( obj( "rescue" ), "current", &"JUNGLE_GHOSTS_OBJ_SAVE_TEAM" );
			flag_wait("waterfall_clear");
			Objective_string (  obj( "rescue" ), &"JUNGLE_GHOSTS_HELP_HESH" );
			Objective_Position(  obj("rescue"), level.bravo[1].origin +( 0, 0, 30 ));
			//Objective_OnEntity( obj("rescue"), level.bravo[0] );
			
			flag_wait("player_rescued_hostage");		
			objective_complete( obj( "rescue" ) );
			
		case "stream":	
		case "tall_grass":
		case "runway":
			flag_wait("field_end");
			objective_complete( obj( "runway" ) );
			
			flag_wait( "begin_runway_attack" );
			Objective_Add( obj( "soflam" ), "current", &"JUNGLE_GHOSTS_OBJ_LASE_TARGET" );
			
			flag_wait("runway_hot" );
			wait 5;
			objective_complete( obj( "soflam" ) );
			
		case "escape_runway":
			flag_wait( "squad_to_escape_slide" );
			Objective_Add( obj( "escape" ), "current", &"JUNGLE_GHOSTS_OBJ_ESC_TO_RIVER" );
			
			
	}

}
