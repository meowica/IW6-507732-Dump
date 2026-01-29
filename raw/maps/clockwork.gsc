#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_teargas;



main()
{
	add_hint_string( "nvg", &"SCRIPT_NIGHTVISION_USE", maps\_nightvision::ShouldBreakNVGHintPrint );
	// Press^3 [{+actionslot 1}] ^7to disable Night Vision Goggles.
	add_hint_string( "disable_nvg", &"SCRIPT_NIGHTVISION_STOP_USE", maps\_nightvision::should_break_disable_nvg_print );

	template_level( "clockwork" );
	maps\createart\clockwork_art::main();
	maps\clockwork_fx::main();
	maps\clockwork_precache::main();
	maps\clockwork_anim::main();
	

	maps\_c4::main();
	maps\_drone_ai::init();
	precache_for_startpoints();
	thread initTearGas();
	
	clockwork_starts();
	maps\clockwork_code::clockwork_init();
	  
	maps\_load::main();	
	maps\clockwork_fx::setup_footstep_fx();
	maps\_rv_vfx::init(); // Global breakable system
	maps\clockwork_audio::main();
	thread fx_turn_on_tunnel_lights();
	thread fx_turn_on_introFX();
	thread fx_snowmobile_light();
	maps\_nightvision::main( level.players, 1 );
	level.player SetActionSlot( 1, "" );  //  disable nightvision to start with

	SetSavedDvar_cg_ng( "r_specularcolorscale", 3.2, 6.5 );    
	SetSavedDvar_cg_ng( "r_diffusecolorscale", 1.5, 1.5 );
	setsaveddvar( "cg_foliagesnd_alias" , "clkw_foot_foliage_player" );

	//level.altskybox = getent( "clk_alt_skybox_01", "targetname" );
	//level.altskybox hide();
	
	maps\clockwork_scriptedlights::main();
	
	setsaveddvar_cg_ng( "fx_alphathreshold", 9, 9 );
	/*
	//If PC or Durango
	if(level.console== 0 || level.xb3 ==1 )
		SetSavedDvar( "sm_polygonOffsetScale", 7 );
	else if ( level.ps4 )
		setsaveddvar_cg_ng( "sm_polygonOffsetScale", 112 );
*/

	thread fx_aurora_anim();
	thread maps\clockwork_fx::fx_checkpoint_states(); //FX checkpoint loading states
}
fx_aurora_anim()
{ 
	
	aurora_model = GetEnt("clk_aurora","targetname");
	if (IsDefined(aurora_model))
	{
		aurora_model.animname = "aurora";
		new_location = aurora_model spawn_tag_origin();
		
		
		new_model = spawn_anim_model( "aurora",aurora_model.origin);
		new_model.angles = aurora_model.angles;
		new_model2 = spawn_anim_model( "aurora2",aurora_model.origin);
		new_model2.angles = aurora_model.angles;
		
		aurora_model delete();
		
		new_model thread anim_loop_solo(new_model,"clk_aurora_loop");
		wait(7.35);
		new_model2 thread anim_loop_solo(new_model2,"clk_aurora_loop");
	}
	
}
fx_turn_on_tunnel_lights()
{
	exploder(150);
}
fx_turn_on_introFX()
{
	exploder(2000);
}

fx_snowmobile_light()
{
	thread maps\clockwork_fx::turn_effects_on("snowmobile_headlight","vfx/moments/clockwork/vfx_intro_snwmbl_lights");
	thread maps\clockwork_fx::turn_effects_on("snowmobile_runninglight","vfx/moments/clockwork/vfx_intro_snwmbl_runninglights");
	flag_wait("FLAG_intro_light_off");
	
	thread maps\clockwork_fx::turn_effects_on("snowmobile_headlight","vfx/moments/clockwork/vfx_intro_snwmbl_lights_break");
	flag_set("snowmobile_headlight");
}

clockwork_starts()
{
		   //   msg 				    func 											     loc_string 			     optional_func 										 
	add_start( "intro2"				 , maps\clockwork_intro::setup_intro2				  , "Snowmobiles."		  , maps\clockwork_intro::begin_intro );
	add_start( "checkpoint",				maps\clockwork_intro::setup_checkpoint,						"Checkpoint",			maps\clockwork_intro::begin_checkpoint );
	add_start( "start_ambush",				maps\clockwork_intro::setup_ambush,							"Ambush",				maps\clockwork_intro::begin_ambush );
	add_start( "interior",					maps\clockwork_interior_nvg::setup_interior,				"interior",				maps\clockwork_interior_nvg::begin_interior );
	add_start( "interior_vault_scene",		maps\clockwork_interior::setup_interior_vault_scene,		"interior_vault_scene",	maps\clockwork_interior::begin_interior_vault_scene );
	add_start( "interior_combat",			maps\clockwork_interior::setup_interior_combat,				"interior_combat",		maps\clockwork_interior::begin_interior_combat );
	add_start( "interior_cqb", 				maps\clockwork_interior::setup_interior_cqb,				"interior_cqb",			maps\clockwork_interior::begin_interior_cqb );
	add_start( "defend",					maps\clockwork_defend::setup_defend,						"defend",				maps\clockwork_defend::begin_defend );
	add_start( "defend_plat"		 , maps\clockwork_defend::setup_defend_plat			  , "Defend from platform"	  , maps\clockwork_defend::begin_defend_plat );
	add_start( "defend_blowdoors1"	 , maps\clockwork_defend::setup_defend_blowdoors1	  , "Defend 1st doors boom"	  , maps\clockwork_defend::begin_defend_blowdoors1 );
	add_start( "defend_blowdoors2"	 , maps\clockwork_defend::setup_defend_blowdoors2	  , "Defend 2nd doors boom"	  , maps\clockwork_defend::begin_defend_blowdoors2 );
	add_start( "defend_fire_blocker" , maps\clockwork_defend::setup_defend_fire_blocker	  , "Defend fireblocker ready", maps\clockwork_defend::begin_defend_fire_blocker );
	add_start( "chaos",						maps\clockwork_exfil::setup_chaos,							"chaos",				maps\clockwork_exfil::begin_chaos );
	add_start( "exfil",						maps\clockwork_exfil::setup_exfil,							"exfil",				maps\clockwork_exfil::begin_exfil );
	add_start( "exfil_tank",				maps\clockwork_exfil::setup_exfil_alt,						"exfil_tank",			maps\clockwork_exfil::begin_exfil_tank );
	add_start( "exfil_bridge",				maps\clockwork_exfil::setup_exfil_alt,						"exfil_bridge",			maps\clockwork_exfil::begin_exfil_bridge );
	add_start( "exfil_cave",				maps\clockwork_exfil::setup_exfil_alt,						"exfil_cave",			maps\clockwork_exfil::begin_exfil_cave );
	//add_start( "exfil_sub",					maps\clockwork_exfil::setup_exfil_alt,						"exfil_sub",			maps\clockwork_exfil::begin_exfil_sub );
	
	default_start( maps\clockwork_intro::setup_intro2 );

}

precache_for_startpoints()
{
	precacheshader( "hud_icon_nvg" );
	PreCacheItem( "ak47_grenadier_acog" );
	PreCacheItem( "ak47_silencer_reflex_iw6" );
	PrecacheItem( "btr80_turret_castle" );
	PrecacheItem( "ak47_disguise_acog" );
	PrecacheItem( "drill_press" );
	PreCacheItem( "helmet_goggles" );
	PreCacheModel( "viewmodel_commando_knife" );
	precachemodel( "weapon_electric_claymore");
	precachemodel( "weapon_proximity_mine");
	PreCacheModel( "chinese_brave_warrior_obj_door_front_LE" );
	PreCacheModel( "chinese_brave_warrior_obj_door_back_LE" );
	PreCacheModel( "chinese_brave_warrior_obj_door_back_RI" );
	precachemodel( "clk_lab_overheadlight_off" );
//	precachemodel( "clk_lab_overheadlight_on" );
//	precachemodel( "com_tv1" );
	precachemodel( "clk_emergency_light" );
//	precachemodel( "ctl_light_spotlight_generator" );
	PreCacheModel( "clk_emergency_light_02" );
	PreCacheModel( "clk_light_rack" );
//	precachemodel("light_outdoorwall02");
//	precachemodel("light_outdoorwall02_on");
//	precachemodel("clk_facemask");
	precachemodel("chinese_brave_warrior_fx_glass");
	PreCacheModel( "clk_fire_extinguisher_lrg_anim" );
	PreCacheModel("clk_door_01");
	PreCacheRumble( "drill_normal" );
	PreCacheRumble( "drill_vault" );
	PreCacheRumble( "drill_through" );
	precachemodel( "clk_russian_disguise_deadbodies" );
	precachemodel( "clk_russian_military_non_disguise_head_a" );
	precachemodel( "clk_russian_military_non_disguise_head_b" );
	precachemodel( "clk_russian_military_non_disguise_head_c" );
	
	precacheModel( "weapon_ak47" );
	PrecacheModel( "weapon_commando_knife" );

//	PreCacheModel( "head_russian_military_dd_arctic" );
	PreCacheModel( "head_elite_pmc_head_b" );
	precachemodel("ny_harbor_missle_key");
	precachemodel("weapon_binocular");
	PreCacheModel("com_hand_radio");
	precachemodel("mil_ammo_case_1");
	precachemodel("clk_searchlight_ir_light");
	precachemodel("clk_searchlight_stand");
	maps\clockwork_fx::clockwork_treadfx_override();	
	
	maps\clockwork_intro::clockwork_intro_pre_load();
	maps\clockwork_interior_nvg::clockwork_interior_nvg_pre_load();
	maps\clockwork_interior::clockwork_interior_pre_load();
	maps\clockwork_defend::clockwork_defend_pre_load();
	maps\clockwork_exfil::clockwork_exfil_pre_load();

	thread post_load();
}

post_load()
{	
	level waittill ( "load_finished" );
	// connect paths in the defend area to avoid running out of disconnected nodes
	maps\clockwork_defend::setup_blockers();
	common_scripts\_sentry::setup_sentry_smg();
	
	//Add / call your post load stuff here.

}

