#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\enemyhq_code;
#include maps\_teargas;


main()
{
	template_level( "enemyhq" );
	maps\createart\enemyhq_art::main();
	maps\enemyhq_fx::main();
	maps\enemyhq_precache::main();
	maps\enemyhq_anim::main();
	SetDvar( "debug_bcprint", "on" );
	enemyhq_pre_load();
	enemyhq_starts();

	maps\_load::main();
	maps\enemyhq_audio::main();
	maps\_patrol_anims::main();
	thread initTearGas();
	//thread link_field_veh_path_to_crash_path();
	thread lights();
	maps\_c4::main();
	maps\_drone_ai::init();
	maps\_dog_control::init_dog_control();
	
	maps\enemyhq_remoteturret::remote_turret_init( "player_view_controller" );

	
	init_color_trigger_listeners("atrium_color_triggers");
	//precacheitem("honeybadger+acog_sp");
	PreCacheItem( "teargas_grenade" );
	PreCacheItem( "remote_sniper" );
	PrecacheItem( "nosound_magicbullet" );
	PreCacheModel( "viewhands_player_yuri" );
	PreCacheModel( "weapon_m4m203_acog" );
	PreCacheModel( "generic_prop_raven" );
	PreCacheModel( "vehicle_man_7t_front_door_RI_obj" );
	PreCacheModel( "vehicle_iveco_lynx_destroyed_iw6_static" );
	PrecacheModel( "prop_sas_gasmask" );
	PrecacheShader( "gasmask_overlay_delta2" );
	PreCacheItem( "scuba_mask_on" );
	PreCacheItem( "scuba_mask_off" );

	
	array_spawn_function_noteworthy("delete_at_path_end",::delete_ai_at_path_end);
	
	setsaveddvar("fx_alphathreshold",9);

	// automatic dog sniffing triggers
	trigs = GetEntArray("start_dog_sniffing", "targetname");
	array_thread (trigs, ::handle_dog_sniffing);
	trigs = GetEntArray("stop_dog_sniffing", "targetname");
	array_thread (trigs, ::handle_dog_sniffing);
	
	level.disable_teargas_ally_badplaces = true;
}

enemyhq_starts()
{
		   //   msg 			    func 										     loc_string 	     optional_func 									 
	add_start( "intro"			 , maps\enemyhq_rooftop_intro::setup_rooftop_intro, "Intro"			  , maps\enemyhq_rooftop_intro::begin_rooftop_intro );
	add_start( "introroof"		 , maps\enemyhq_rooftop_intro::setup_rooftop_shoot, "Intro shoot"	  , maps\enemyhq_rooftop_intro::begin_rooftop_shoot );
	add_start( "drive_in"		 , maps\enemyhq_intro::setup_drive_in			  , "Drive in"		  , maps\enemyhq_intro::begin_drive_in );
	add_start( "atrium"			 , maps\enemyhq_atrium::setup_atrium			  , "Atrium Combat"	  , maps\enemyhq_atrium::begin_atrium );
	add_start( "vip"			 , maps\enemyhq_vip::setup_vip					  , "VIP Suite"		  , maps\enemyhq_vip::begin_vip );
	add_start( "traverse"		 , maps\enemyhq_traverse::setup_traverse		  , "Traverse"		  , maps\enemyhq_traverse::begin_traverse );
	add_start( "basement_combat" , maps\enemyhq_basement::setup_combat			  , "Basement Combat" , maps\enemyhq_basement::begin_combat );
	add_start( "basement_teargas", maps\enemyhq_basement::setup_teargas			  , "Basement Teargas", maps\enemyhq_basement::begin_teargas );
	add_start( "clubhouse_breach", maps\enemyhq_basement::setup_clubhouse		  , "Clubhouse Breach", maps\enemyhq_basement::begin_clubhouse );
	add_start( "hvt_rescue"		 , maps\enemyhq_basement::setup_hvt				  , "HVT Rescue"	  , maps\enemyhq_basement::begin_hvt );
	add_start( "finale"			 , maps\enemyhq_finale::setup_finale			  , "Finale"		  , maps\enemyhq_finale::begin_finale );

}

enemyhq_pre_load()
{
	maps\enemyhq_rooftop_intro::enemyhq_rooftop_intro_pre_load();
	
	maps\enemyhq_intro::enemyhq_intro_pre_load();
	maps\enemyhq_atrium::enemyhq_atrium_pre_load();
	maps\enemyhq_vip::enemyhq_vip_pre_load();
	maps\enemyhq_traverse::enemyhq_traverse_pre_load();
	maps\enemyhq_basement::enemyhq_basement_pre_load();
	maps\enemyhq_finale::enemyhq_finale_pre_load();
	
//	flag_init( "someflag" );
	flag_init("FLAG_link_veh_crash_paths");
	flag_init("FLAG_player_enter_truck");
	PreCacheItem("deserteagle");
	
}

setup_common( spawn_override )
{
	//level.player takeallweapons();
//	level.player giveWeapon( "m14ebr_thermal_silencer" );
	//level.player giveWeapon("deserteagle");
	//level.player giveWeapon( "m4m203_acog_payback" );
	//level.player switchToWeapon( "m4m203_acog_payback" );
	level.player takeWeapon( "fraggrenade" );

//	level.player SetOffhandPrimaryClass( "frag" );
//	level.player GiveWeapon( "fraggrenade" );
	level.player VisionSetNakedForPlayer( "enemyhq", 0.25 );
	
	
/*
 * 	if(!isdefined(level.variable_scope_weapons))
		level.variable_scope_weapons = [];
	level.variable_scope_weapons[level.variable_scope_weapons.size]= "m14ebr_thermal_silencer";
	level.variable_scope_weapons[level.variable_scope_weapons.size]= "m14ebr_scope";
	
	thread maps\_shg_common::monitorScopeChange();
*/
	
	setup_player(spawn_override);
	spawn_allies(spawn_override);
}



setup_player(spawn_override)
{
	if(IsDefined(spawn_override))
		tp = spawn_override + "_start" ;
	else 
		tp = level.start_point + "_start" ;
	startstruct = getstruct( tp, "targetname" );
	if( IsDefined( startstruct ) )
	{
		level.player SetOrigin( startstruct.origin );
		level.player SetPlayerAngles( startstruct.angles);
	}
	else
	{
		IPrintLnBold( "can't find startpoint for " + level.start_point );
	}

}

spawn_allies(spawn_override)
{
	level.allies					  = [];
	level.allies[ level.allies.size ] = spawn_ally( "ally1", spawn_override );
	level.allies[ level.allies.size ] = spawn_ally( "ally2", spawn_override );
//	level.allies[ level.allies.size ] = spawn_ally( "ally3", spawn_override );
	level.allies[ level.allies.size ] = spawn_ally( "ally4", spawn_override );
	
	level.allies[0].animname = "baker";
	level.allies[1].animname = "keegan";
//	level.allies[2].animname = "dudebro";
	level.allies[2].animname = "hesh";
	
	foreach(ally in level.allies)
	{
		self.goalradius = 25;
	}
	
	dog = spawn_ally( "dog", spawn_override );
	
	dog.meleeAlwaysWin = true;
	level.dog = dog;
	level.dog.animname = "dog";
	
//	dog.script_stealthgroup = "dog";
//	level.player thread maps\_stealth_utility::stealth_default();
//	dog thread dog_stfealth();

//	dog.goalradius = 512;
//	dog.goalheight = 128;
//	dog.pathenemyfightdist = dog.goalradius;
////	dog.fixednode = true;
////	dog SetDogHandler(level.player);
//	dog SetDogAttackRadius(420);

	
	dog.goalradius = 64;
	dog.goalheight = 128;
	dog.pathenemyfightdist = 0;
	dog SetDogAttackRadius(128);
	level.dog_alt_melee_func = animscripts\dog\dog_kill_traversal::dog_alt_combat_check;
	
	maps\ally_attack_dog::init_ally_dog( level.player, dog,true );
	level.player_dog = dog;


//	level.player thread maps\_dog_control::enable_dog_control( level.dog );
////	level.dog_flush_functions[ "church" ] = ::flush_church;
	
}


spawn_ally( allyName , overrideSpawnPointName )
{
	spawnname = undefined;
    if ( !IsDefined( overrideSpawnPointName ))
    {
        spawnname = level.start_point + "_" + allyName;
    }
    else
    {
        spawnname = overrideSpawnPointName + "_" + allyName;
    	
    }

    ally = spawn_targetname_at_struct_targetname( allyName , spawnname );
    
    if( !IsDefined( ally ) )
    {
    	return undefined;
    }
    
//	if ( ally.type != "dog" )
	{
	    ally make_hero();
	    if( !IsDefined( ally.magic_bullet_shield ) )
	    {
    		ally magic_bullet_shield();
	    }
	}
       //BCS hack.
    ally.countryid = "US";
//	ally.voice = "american";
//	ally.voice = "seal";
	ally.voice = "delta";

    return ally;
}



lights()
{
	
	flares = getentarray( "flickerlight1", "targetname" );
	foreach( flare in flares )
		flare thread flareFlicker();

}

flareFlicker()
{
	while( isdefined( self ) )
	{
		wait( randomfloatrange( .05, .1 ) );
		self setLightIntensity( randomfloatrange( 0.6, 1.8 ) );
	}
}

flare_flicker( minIntensity, maxIntensity )
{
	//self ==> the script_model of the flare
	assertex( self.classname == "script_model", "This function can only be called on a script_model. Preferably mil_emergency_flare" );
	dynamicLight = getent( self.target, "targetname" );
	assertex( maps\_lights::is_light_entity( dynamicLight ), "The flare script_model must be targeting a scriptable primary light" );
	
	if ( !isdefined( minIntensity ) ) 
		minIntensity = 0.6;
	if ( !isdefined( maxIntensity ) ) 
		maxIntensity = 1.8;
	
	self thread play_loop_sound_on_entity( "flare_burn_loop" );
	
	while( isdefined( self ) )
	{
		wait( randomfloatrange( .05, .1 ) );
		dynamicLight setLightIntensity( randomfloatrange( minIntensity, maxIntensity ) );
	}
}
