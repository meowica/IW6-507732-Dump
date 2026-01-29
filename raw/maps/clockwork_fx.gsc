#include maps\_utility;
#include common_scripts\utility;

main()
{
	level._effect[ "fx/misc/vapor_defend_clk"                     ] = loadfx( "fx/misc/vapor_defend_clk" );
	level._effect[ "fx/lights/lights_conelight_security"          ] = loadfx( "fx/lights/lights_conelight_security" );
	level._effect[ "fx/smoke/steam_vent_clk"                      ] = loadfx( "fx/smoke/steam_vent_clk" );
	level._effect[ "fx/fire/fire_gaz_clk"                         ] = loadfx( "fx/fire/fire_gaz_clk" ); // exploder 2811
	level._effect[ "fx/treadfx/tread_snow_night_clk"              ] = loadfx( "fx/treadfx/tread_snow_night_clk" );
	level._effect[ "fx/snow/snow_jump_launch_gaz"                 ] = loadfx( "fx/snow/snow_jump_launch_gaz" ); // exploder 2634
	level._effect[ "fx/snow/snow_spiral04"                        ] = loadfx( "fx/snow/snow_spiral04" );
	level._effect[ "fx/misc/clk_sub_breach_xp"                    ] = loadfx( "fx/misc/clk_sub_breach_xp" );
	level._effect[ "fx/weather/snow_sub_blow2"                    ] = loadfx( "fx/weather/snow_sub_blow2" );
	level._effect[ "fx/misc/clk_sub_rise"                         ] = loadfx( "fx/misc/clk_sub_rise" );
	level._effect[ "fx/weather/snow_sub_blow"                     ] = loadfx( "fx/weather/snow_sub_blow" );
	level._effect[ "lights_blink_red_nofxlight"                   ] = loadfx( "fx/lights/lights_blink_red_nofxlight" );
	level._effect[ "fx/lights/lights_conelight_smokey_exfil"      ] = loadfx( "fx/lights/lights_conelight_smokey_exfil" );
	level._effect[ "fx/lights/godrays_catwalk_clk"                ] = loadfx( "fx/lights/godrays_catwalk_clk" );
	level._effect[ "fx/lights/wall_light_lowint_ramp"             ] = loadfx( "fx/lights/wall_light_lowint_ramp" );
	level._effect[ "fx/explosions/sparks_runner_clk"              ] = loadfx( "fx/explosions/sparks_runner_clk" );
	level._effect[ "fx/snow/snowfall_exfil_clk"                   ] = loadfx( "fx/snow/snowfall_exfil_clk" );
	level._effect[ "fx/misc/clk_sub_watersplash"                  ] = loadfx( "fx/misc/clk_sub_watersplash" );
	level._effect[ "fx/misc/clk_sub_breach_chnk1"                 ] = loadfx( "fx/misc/clk_sub_breach_chnk1" );
	level._effect[ "fx/misc/clk_sub_breach_chnk2"                 ] = loadfx( "fx/misc/clk_sub_breach_chnk2" );
//	level._effect[ "fx/misc/clk_sub_water_roll"                   ] = loadfx( "fx/misc/clk_sub_water_roll" );
	level._effect[ "fx/weather/snow_vista_blow_exfil"             ] = loadfx( "fx/weather/snow_vista_blow_exfil" );
	level._effect[ "fx/misc/clk_sub_breach3"                      ] = loadfx( "fx/misc/clk_sub_breach3" );
	level._effect[ "fx/misc/clk_sub_breach2"                      ] = loadfx( "fx/misc/clk_sub_breach2" );
	level._effect[ "fx/misc/clk_sub_breach1"                      ] = loadfx( "fx/misc/clk_sub_breach1" );
	level._effect[ "fx/misc/thermite_molten"                      ] = loadfx( "fx/misc/thermite_molten" );
	level._effect[ "fx/weather/snow_exfil_blow_ground"            ] = loadfx( "fx/weather/snow_exfil_blow_ground" );
	level._effect[ "fx/weather/snow_wispy_ground_runner"          ] = loadfx( "fx/weather/snow_wispy_ground_runner" );
	level._effect[ "fx/weather/snow_wispy_ground_clk_ch"          ] = loadfx( "fx/weather/snow_wispy_ground_clk_ch" );
	level._effect[ "fx/weather/snow_vista_blow_clk"               ] = loadfx( "fx/weather/snow_vista_blow_clk" ); //exploder 2000
	level._effect[ "fx/weather/snow_vista_small_clk"              ] = loadfx( "fx/weather/snow_vista_small_clk" );
	level._effect[ "fx/weather/cloud_bank_clk"                    ] = loadfx( "fx/weather/cloud_bank_clk" ); //exploder 100
	level._effect[ "fx/weather/snow_thin_vista_clk"               ] = loadfx( "fx/weather/snow_thin_vista_clk" ); //exploder 100
	level._effect[ "fx/weather/snow_vista_wispy_clk"              ] = loadfx( "fx/weather/snow_vista_wispy_clk" ); //exploder 100
	level._effect[ "fx/weather/snow_thin_vista_slow_clk"          ] = loadfx( "fx/weather/snow_thin_vista_slow_clk" ); //exploder 100
	level._effect[ "fx/weather/snow_vista_wispy_slow_clk"         ] = loadfx( "fx/weather/snow_vista_wispy_slow_clk" );//exploder 100
	level._effect[ "fx/weather/vista_fog_filler_clockwork"        ] = loadfx( "fx/weather/vista_fog_filler_clockwork" );//exploder 100
	level._effect[ "mine_explode"								] = LoadFX( "fx/explosions/emp_grenade" );
	level._effect[ "throwbot_explode"							] = LoadFX( "fx/explosions/large_vehicle_explosion" );
	level._effect[ "fx/snow/snow_wind_clk"                        ] = loadfx( "fx/snow/snow_wind_clk" );
	level._effect[ "snow_filler"								] = LoadFX( "fx/snow/snow_filler" );
	level._effect[ "blowing_ground_snow"						] = LoadFX( "fx/snow/blowing_ground_snow" );
	level._effect[ "steam_vent"						            ] = LoadFX( "fx/smoke/steam_vent_tunnel" );
	level._effect[ "wall_light_cool"                              ] = loadfx( "fx/lights/wall_light_cool" );
	level._effect[ "wall_light_warm"                              ] = loadfx( "fx/lights/wall_light_warm" );
	level._effect[ "fx/snow/snow_blowoff_ledge_runner"			] = LoadFX( "fx/snow/snow_blowoff_ledge_runner" );
	level._effect[ "fx/snow/snow_spiral_runner"					] = LoadFX( "fx/snow/snow_spiral_runner" );
	level._effect[ "fx/snow/snow_clockwork_flow_A"				] = LoadFX( "fx/snow/snow_clockwork_flow_A" );
	level._effect[ "fx/snow/snow_clockwork_flow_B"				] = LoadFX( "fx/snow/snow_clockwork_flow_B" );
	level._effect[ "fx/snow/snow_clockwork_flow_C"				] = LoadFX( "fx/snow/snow_clockwork_flow_C" );
    level._effect[ "fx/snow/snow_clockwork_dump"				] = LoadFX( "fx/snow/snow_clockwork_dump" );
	level._effect[ "fx/lights/lights_spotlight_beam_warm"		] = LoadFX( "fx/lights/lights_spotlight_beam_warm" );
	level._effect[ "fx/lights/lights_strobe_red_dist_max_small" ] = LoadFX( "fx/lights/lights_strobe_red_dist_max_small" );
	level._effect[ "fx/lights/lights_glow_small_cool"			] = LoadFX( "fx/lights/lights_glow_small_cool" );
	level._effect[ "fx/lights/lights_flourescent"			    ] = LoadFX( "fx/lights/lights_flourescent" );
	level._effect[ "fx/lights/lights_spotlight_generator"	    ] = LoadFX( "fx/lights/lights_spotlight_generator" );
	level._effect[ "fx/lights/lights_snowmobile_head"	        ] = LoadFX( "fx/lights/lights_snowmobile_head" );
	level._effect[ "fx/lights/lights_snowmobile_fade"	        ] = LoadFX( "fx/lights/lights_snowmobile_fade" );
	level._effect[ "fx/lights/wall_light_shaft"			        ] = LoadFX( "fx/lights/wall_light_shaft" );  	//exploder 150
	level._effect[ "fx/lights/lights_defend_ceil"		        ] = LoadFX( "fx/lights/lights_defend_ceil" );
	level._effect[ "fx/lights/wall_light_lowint"			    ] = LoadFX( "fx/lights/wall_light_lowint" ); 
	level._effect[ "fx/lights/lights_cone_cagelight"			] = LoadFX( "fx/lights/lights_cone_cagelight" );
	level._effect[ "fx/lights/lights_blink_red"			        ] = LoadFX( "fx/lights/lights_blink_red" );
//	level._effect[ "fx/lights/light_search_clockwork"			] = LoadFX( "fx/lights/light_search_clockwork" ); //search light
	level._effect[ "fx/lights/window_bloom"						] = LoadFX( "fx/lights/window_bloom" );
	//level._effect[ "fx/lights/light_thermite_flicker"		    ] = LoadFX( "fx/lights/light_thermite_flicker" ); //exploder 50
	level._effect[ "fx/lights/bulb_single"						] = LoadFX( "fx/lights/bulb_single" );
	level._effect[ "fx/lights/bulb_single_offset"				] = LoadFX( "fx/lights/bulb_single_offset" );
	level._effect[ "fx/lights/bulb_single_offset_red"			] = LoadFX( "fx/lights/bulb_single_offset_red" );
	level._effect[ "fx/lights/bulb_single_cargoship"			] = LoadFX( "fx/lights/bulb_single_cargoship" );
	level._effect[ "fx/lights/lights_conelight_smokey"			] = LoadFX( "fx/lights/lights_conelight_smokey" );
	level._effect[ "fx/lights/lights_ext_halogen_quad"			] = LoadFX( "fx/lights/lights_ext_halogen_quad" );
	level._effect[ "fx/smoke/steam_geothermal_exhaust"			] = LoadFX( "fx/smoke/steam_geothermal_exhaust" );
	level._effect[ "ThermalChimney"								] = LoadFX( "fx/smoke/clockwork_thermal_chimney" );
	level._effect[ "fx/weather/cloud_bank"						] = LoadFX( "fx/weather/cloud_bank" );
	level._effect[ "fx/weather/cloud_bank_night"				] = LoadFX( "fx/weather/cloud_bank_night" );
	level._effect[ "fx/dust/falling_dust_clockwork"				] = LoadFX( "fx/dust/falling_dust_clockwork" );
	//level._effect[ "fx/misc/vault_breach_thermite_loop"			] = LoadFX( "fx/misc/vault_breach_thermite_loop" );
	//level._effect[ "fx/misc/thermite_start"			            ] = LoadFX( "fx/misc/thermite_start" );

	level._effect[ "fx/smoke/amb_smoke_blend_dark"				] = LoadFX( "fx/smoke/amb_smoke_blend_dark" );
	level._effect[ "fx/smoke/amb_int_haze_clockwork"			] = LoadFX( "fx/smoke/amb_int_haze_clockwork" );
	level._effect[ "fx/smoke/amb_int_haze_vault"			    ] = LoadFX( "fx/smoke/amb_int_haze_vault" );
	level._effect[ "fx/weather/mist_ground_clockwork_vista"		] = LoadFX( "fx/weather/mist_ground_clockwork_vista" );
	level._effect[ "fx/water/fire_sprinkler_clockwork"			] = LoadFX( "fx/water/fire_sprinkler_clockwork" ); //exploder 1005
	level._effect[ "fx/weather/fog_filler_clockwork"			] = LoadFX( "fx/weather/fog_filler_clockwork" );
	level._effect[ "Vault_smoke_linger"					        ] = LoadFX( "fx/smoke/smoke_fill_vault" );
	level._effect[ "garage_smoke"					            ] = LoadFX( "fx/smoke/clockwork_garage_smoke" );
	level._effect[ "Vault_smoke_exp"					        ] = LoadFX( "fx/smoke/smoke_vault_exp" );
	level._effect[ "fx/maps/dubai/knife_attack_throat"			] = LoadFX( "fx/maps/dubai/knife_attack_throat" );
	level._effect[ "vfx/moments/clockwork/vfx_intro_watch_glow"	] = LoadFX( "vfx/moments/clockwork/vfx_intro_watch_glow" );
	level._effect[ "fx/snow/snow_jump_launch"					] = LoadFX( "fx/snow/snow_jump_launch" ); 
	level._effect[ "fx/misc/blood_pool_small_soap"				] = LoadFX( "fx/misc/blood_pool_small_soap" ); // exploder 162
	level._effect[ "fx/misc/blood_throat_stab"					] = LoadFX( "fx/misc/blood_throat_stab" );
	
	level._effect[ "vfx/moments/clockwork/vfx_vault_thermite_fuse"		] = LoadFX( "vfx/moments/clockwork/vfx_vault_thermite_fuse" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_thermite_start"		] = LoadFX( "vfx/moments/clockwork/vfx_vault_thermite_start" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_thermite_end"		] = LoadFX( "vfx/moments/clockwork/vfx_vault_thermite_end" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick1"			] = LoadFX( "vfx/moments/clockwork/vfx_vault_glowstick1" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick1_fade"	] = LoadFX( "vfx/moments/clockwork/vfx_vault_glowstick1_fade" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick2"			] = LoadFX( "vfx/moments/clockwork/vfx_vault_glowstick2" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick2_fade"	] = LoadFX( "vfx/moments/clockwork/vfx_vault_glowstick2_fade" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_charge_warmup"		] = LoadFX( "vfx/moments/clockwork/vfx_vault_charge_warmup" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_charge_set"			] = LoadFX( "vfx/moments/clockwork/vfx_vault_charge_set" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_charge_activate"	] = LoadFX( "vfx/moments/clockwork/vfx_vault_charge_activate" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_charge_explode"		] = LoadFX( "vfx/moments/clockwork/vfx_vault_charge_explode" );
	level._effect[ "vfx/moments/clockwork/vfx_vault_tablet_screen" 		] = LoadFX( "vfx/moments/clockwork/vfx_vault_tablet_screen" );
	
	level._effect[ "vfx/moments/clockwork/vfx_defend_pipeburst_jet"			] = LoadFX( "vfx/moments/clockwork/vfx_defend_pipeburst_jet" );
	level._effect[ "vfx/moments/clockwork/vfx_defend_pipeburst_wallfire"	] = LoadFX( "vfx/moments/clockwork/vfx_defend_pipeburst_wallfire" );
	level._effect[ "vfx/moments/clockwork/vfx_defend_pipeburst_floorfire"	] = LoadFX( "vfx/moments/clockwork/vfx_defend_pipeburst_floorfire" );
	
	level._effect[ "vfx/moments/clockwork/vfx_intro_snwmbl_lights"			] = LoadFX( "vfx/moments/clockwork/vfx_intro_snwmbl_lights" );
	level._effect[ "vfx/moments/clockwork/vfx_intro_snwmbl_lights_break"	] = LoadFX( "vfx/moments/clockwork/vfx_intro_snwmbl_lights_break" );
	level._effect[ "vfx/moments/clockwork/vfx_intro_snwmbl_runninglights"	] = LoadFX( "vfx/moments/clockwork/vfx_intro_snwmbl_runninglights" );
	
	level._effect[ "fx/misc/vault_breach_cutting_charge"		] = LoadFX( "fx/misc/vault_breach_cutting_charge" );
	level._effect[ "fx/misc/vault_breach_smolder"				] = LoadFX( "fx/misc/vault_breach_smolder" );
		
	//NVG
	level._effect[ "flashlight"		  ] = LoadFX( "fx/misc/flashlight" );
	level._effect[ "player_nvg_light" ] = LoadFX( "fx/misc/flashlight_clockwork_player" );
	
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\clockwork_fx::main();
		maps\createfx\clockwork_sound::main();
		
	}

	//vault door scene
	level._effect[ "glowstick" ] = LoadFX("fx/lights/clockwork_glowstick" );
	//level._effect[ "tablet" ] = LoadFX("fx/lights/clockwork_tablet_screen" );

	level._effect[ "drill_sparks"		] = LoadFX("fx/misc/drill_clk");
	level._effect[ "drill_progress1"	] = LoadFX("fx/misc/drill_clk_progress1");
	level._effect[ "drill_progress2"	] = LoadFX("fx/misc/drill_clk_progress2");
				 
	level._effect[ "thermite_reaction" ] = LoadFX( "fx/smoke/thermite_reaction" );
	level._effect[ "vault_smoke"	   ] = LoadFX( "fx/smoke/teargas_grenade" );
	
	// Exfil
	level._effect[ "mortar" ][ "water" ]	 = LoadFX( "fx/explosions/grenadeExp_water_ice" );
	level.scr_sound[ "mortar" ][ "water" ]	 = "mortar_explosion_water";
	level._effect[ "grenade_muzzleflash"   ] = LoadFX( "fx/muzzleflashes/m203_flshview" );
	//level._effect[ "flashlight_spotlight"  ] = LoadFX( "fx/misc/flashlight_clockwork_chase" );
	level._effect[ "fx/water/sub_surface_runner_clk" ]	= LoadFX( "fx/water/sub_surface_runner_clk" );
	level._effect[ "spotlight_dlight" ]					= LoadFx( "fx/lights/spotlight_uaz_headlights_castle" );
	
	//for BTR scripted
	level._effect[ "bmp_flash_wv" ] = LoadFX( "fx/muzzleflashes/bmp_flash_wv" );
	
	// Jeep TreadFX Overrides & temporary aliased vehicle FX
	level._effect[ "fx/treadfx/tread_snow_night"				] = LoadFX( "fx/treadfx/tread_snow_night" );
	level._effect[ "fx/treadfx/bigair_snow_night_emitter"		] = LoadFX( "fx/treadfx/bigair_snow_night_emitter" );
	level._effect[ "fx/treadfx/bigjump_land_snow_night"			] = LoadFX( "fx/treadfx/bigjump_land_snow_night" );
	level._effect[ "fx/treadfx/smalljump_land_snow_night"		] = LoadFX( "fx/treadfx/smalljump_land_snow_night" );
	level._effect[ "fx/treadfx/leftturn_snow_night"				] = LoadFX( "fx/treadfx/leftturn_snow_night" );
	level._effect[ "fx/treadfx/rightturn_snow_night"			] = LoadFX( "fx/treadfx/rightturn_snow_night" );
	level._effect[ "fx/treadfx/clk_jeep_skid_sub"			    ] = LoadFX( "fx/treadfx/clk_jeep_skid_sub" );
	level._effect[ "fx/treadfx/tread_snow_speed_clk"              ] = loadfx( "fx/treadfx/tread_snow_speed_clk" );
	
	level._effect[ "sparks"              						] = loadfx( "fx/impacts/tank_round_spark" );
	
	level._effect[ "shockwave_shock" 							] = loadfx( "vfx/ambient/misc/electric_bolt_origin_claymore" );
   
}

setup_footstep_fx()
{
	level._effect[ "footstep_snow" ]							= loadfx ( "fx/impacts/footstep_snow_night" );
	level._effect[ "footstep_snow_small" ]						= loadfx ( "fx/impacts/footstep_snow_small_night" );
	level._effect[ "footstep_ice" ]								= loadfx ( "fx/impacts/footstep_ice_night" );
		
	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "snow",				level._effect[ "footstep_snow" ] );
	animscripts\utility::setFootstepEffect( "ice",				level._effect[ "footstep_ice" ] );
			
	//Small footstep fx
	animscripts\utility::setFootstepEffectSmall( "snow",		level._effect[ "footstep_snow_small" ] );
	animscripts\utility::setFootstepEffectSmall( "ice",			level._effect[ "footstep_ice" ] );
			
	//Player Footstep fx
	level.player thread playerSnowFootsteps();
}


// FX SCRIPTING STARTS HERE

turn_effects_on(model_targetname, effectname)
{
    // Runs on the first turn_effects_on call
    if (!IsDefined(level.effect_monitors))
        level.effect_monitors = [];
    if (!IsDefined(level.effect_monitors[model_targetname+effectname]))
        level.effect_monitors[model_targetname+effectname] = false;
    
    if (level.effect_monitors[model_targetname+effectname] == false)
    {
        level.effect_monitors[model_targetname+effectname] = true;
        if ( !flag_exist(model_targetname))
        {
            flag_init(model_targetname);
        }
        object_array = getstructarray(model_targetname,"targetname");
        effects= [];
        iter = 0;
        foreach (light in object_array)
        {
        	newAngles = (0,0,0);
    		newOrigin = (0,0,0);
    		if (IsDefined(light.origin))
    			newOrigin = light.origin;
    		if (IsDefined(light.angles))
    			newAngles  = light.angles;
            lightfx = SpawnFx(level._effect[ effectname],newOrigin,AnglesToForward(newAngles),AnglesToUp(newAngles));
            TriggerFX(lightfx);
            effects[effects.size]=lightfx;
            waitframe();
        }
        
        // Set flag if you want to turn off the effects & delete ents
        
        flag_wait( model_targetname);
        foreach (effect in effects)
        {
            effect Delete();
        }
        flag_clear(model_targetname);
        level.effect_monitors[model_targetname+effectname] = false;
    }
}
//turn_effects_off(model_targetname)
//{
//	// add flag check here
//    flag_set(model_targetname);
//}


fx_checkpoint_states()
{
	// Per section ambient FX states
	//waittillframeend;// let the actual start functions run before this one
	start = level.start_point;

	if ( start == "start_ambush" )
    {
     	flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint    
    }
	if ( start == "interior" )
	{
		flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		thread maps\clockwork_fx::turn_effects_on("cagelight","fx/lights/lights_cone_cagelight");
	   	thread maps\clockwork_fx::turn_effects_on("tubelight_parking","fx/lights/lights_flourescent");
		stop_exploder (100); //turn snow fx off
		stop_exploder(850); //turn off vista mist
		exploder(250); //turn security checkpoint fx on
	    exploder(300); //turn on ambient garage smoke
	    stop_exploder(2000);
	    stop_exploder(150);             //turn off tunnel fx
	    
		
	}
	if ( start == "interior_combat" )
	{
		exploder(1005);	// sprinklers and haze
		flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		stop_exploder(2000);
		stop_exploder(150);             //turn off tunnel fx
	}
	if ( start == "interior_cqb" )
	{
		flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		thread maps\clockwork_fx::turn_effects_on("ch_industrial_light_02_on_red","fx/lights/bulb_single_offset_red");
        thread maps\clockwork_fx::turn_effects_on("clk_cargoship_wall_light_on","fx/lights/bulb_single_cargoship");
		exploder(200);  //catwalk snow fx
		exploder(850); //turn on vista mist
		exploder(6400);
		stop_exploder(2000);
		stop_exploder(150);             //turn off tunnel fx
	}
	if ( string_starts_with(start, "defend" ))
	{
    	thread maps\clockwork_fx::turn_effects_on("ch_industrial_light_02_on_red","fx/lights/bulb_single_offset_red");
        thread maps\clockwork_fx::turn_effects_on("clk_cargoship_wall_light_on","fx/lights/bulb_single_cargoship");
		flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		exploder(200);
		exploder(6400);
		stop_exploder(2000);
		stop_exploder(150);             
	}
    if ( start == "chaos" )
	{
    	flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
    	stop_exploder(2000);
    	stop_exploder(150);             //turn off tunnel fx
	}
    if ( start == "greenlight" ||  start == "exfil" || ( level.default_start == maps\clockwork_exfil::setup_exfil ) )
	{
    	flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		thread maps\clockwork_fx::turn_effects_on("cagelight","fx/lights/lights_cone_cagelight");
	   	thread maps\clockwork_fx::turn_effects_on("tubelight_parking","fx/lights/lights_flourescent");
		exploder(250); //turn security checkpoint fx on
	    exploder(300); //turn on ambient garage smoke
	    exploder(301); //turn on bulbs 
	    stop_exploder(2000);
	    stop_exploder(150); 
        stop_exploder(6400);	    
        
	}
    if ( start == "exfil_tank" )
	{
    	flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		stop_exploder(2000);
		stop_exploder(150);             //turn off tunnel fx
	}
    if ( start == "exfil_bridge" )
	{	  
    	flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		stop_exploder(2000);
		stop_exploder(150);             //turn off tunnel fx
	}
    if ( start == "exfil_cave" )
	{  
    	flag_set("snowmobile_headlight"); //turn off snowmobile headlight if starting from checkpoint	
		stop_exploder(2000);
		stop_exploder(150);             //turn off tunnel fx
	}
    
   
}

clockwork_treadfx_override()
{
	// Vehicle Tread Overrides
	maps\_treadfx::setVehicleFX("script_vehicle_gaz_tigr_turret_physics", "snow", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_gaz_tigr_turret_physics", "slush", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_gaz_tigr_turret", "snow", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_gaz_tigr_turret", "slush", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_snowmobile", "snow", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_snowmobile", "slush", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_btr80_snow", "snow", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_btr80_snow", "slush", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_warrior_physics_turret", "snow", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_warrior_physics_turret", "slush", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_warrior_physics", "snow", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_warrior_physics", "slush", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_warrior", "snow", "fx/treadfx/tread_snow_night");
	maps\_treadfx::setVehicleFX("script_vehicle_warrior", "slush", "fx/treadfx/tread_snow_night");
}

//handle_ambush_victim_fx( guy )
//{
//	PlayFXOnTag(getfx("fx/maps/dubai/knife_attack_throat"), level.ambush_jeep_driver, "TAG_WEAPON_CHEST");
//}

handle_jeep_launch_fx()
{
	flag_wait("exfil_jump_off_snowdrift");
	exploder(2634);
}
