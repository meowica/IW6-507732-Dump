#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;

defend_sparrow_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//flag inits
	flag_init( "defend_sparrow_start" );
	flag_init( "defend_sparrow_finished" );
	flag_init( "reinforce_incoming_1" );
	flag_init( "sink_middle_ship" );
	flag_init( "clearing_up" );
	
	//precache
	PreCacheModel( "vehicle_slamraam_base" );
	PreCacheModel( "vehicle_slamraam_launcher_no_spike" );
	PreCacheModel( "projectile_slamraam_missile" );	
	PreCacheItem( "slamraam_missile_guided_fast" );
	PreCacheItem( "sparrow_missile" );
	PreCacheItem( "sparrow_missile_flak" );
	PreCacheShader( "veh_hud_target" );	
	PreCacheShader( "veh_hud_target_marked" );
	PreCacheShader( "veh_hud_sidewinder" );
	PreCacheShader( "dpad_laser_designator" );
	PreCacheShader( "veh_hud_target_offscreen" );
	PreCacheShader( "veh_hud_missile_flash" );
	PreCacheItem( "sparrow_targeting_device" );
	PreCacheShader( "a10_hud_reticle_large" );
	PreCacheShader( "ugv_screen_overlay" );
	PreCacheShader( "ugv_vignette_overlay" );
	PreCacheShader( "m1a1_tank_sabot_scanline" );
	PreCacheRumble( "ac130_40mm_fire" );
	PreCacheModel( "com_laptop_rugged_open_obj" );
	
	//init arrays/vars
	
	//hide ents
}

//*only* gets called from checkpoint/jumpTo
setup_defend_sparrow()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "defend_sparrow";
	
	
	setup_common();	
	spawn_allies();
	thread maps\carrier::obj_sparrow();
	thread maps\carrier_deck_combat2::ladder_blocker_guys(); //guys that block ladder on sparrow launcher platform so you can't climb up once you drop down.
	
	set_sun_post_heli_ride();	
	
	flag_set( "slow_intro_finished" );
	level.heli_ride_destroyer_sinking hide_entity();
	thread get_ships_in_position_for_defend_sparrow( true );
}

//always gets called
begin_defend_sparrow()
{
	//--use this to run your functions for an area or event.--
	thread run_operator();
	
	flag_wait( "defend_sparrow_platform" );
	thread run_defend_sparrow();
	wait 1;
	thread cleanup_enemies();
	flag_wait( "defend_sparrow_finished" );	
	thread autosave_tactical();
	
	deck_victory_start = getstruct( "deck_victory_start", "targetname" );
	level.player.prev_angles = deck_victory_start.angles;
	level.player delayThread( 9, ::sam_remove_control );
	wait 5;
	flag_set( "obj_sparrow_complete" ); //OBJECTIVE COMPLETE
}

cleanup_enemies()
{
	enemies = GetAIArray( "axis" );
	foreach ( enemy in enemies )
	{
		if ( IsAlive( enemy ) )
		{
			enemy thread maps\ss_util::fake_death_bullet( 1.5 );
		}
	}		
}

run_defend_sparrow()
{	
	level.defend_sparrow_control = getent( "defend_sparrow_control", "targetname" );
	level.defend_sparrow_control glow();
	level.defend_sparrow_control MakeUsable();
	level.defend_sparrow_control SetCursorHint( "HINT_ACTIVATE" );	
	level.defend_sparrow_control SetHintString( "Press [{+activate}] to use Sparrow Missiles." ); //TODO: localize				
	
	level.ds_ship_02 = getent( "us_destroyer_4", "targetname" );
	level.ds_ship_03 = getent( "us_destroyer_5", "targetname" );
	Missile_CreateAttractorEnt( level.ds_ship_02, 50000, 20000 );
	Missile_CreateAttractorEnt( level.ds_ship_03, 50000, 20000 );
	
	thread run_nag_vo();
	
	level notify( "jet_battle_end" );

	thread run_enemy_waves();
	
	level.defend_sparrow_control waittill( "trigger" );
	level.player thread sam_give_control();
	level.player notify( "use_sam" );
	level.defend_sparrow_control MakeUnusable();	
	flag_set( "defend_sparrow_start" );
	thread maps\_utility::vision_set_fog_changes( "carrier_sparrow", 10 );
	thread run_defend_vo();
	wait 1;
	IPrintLnBold( "DEFEND THE SHIPS" );
	
	thread autosave_now_silent(); //made this autosave_now because tactical and by name fail on 'low ammo'	
}

run_enemy_waves()
{
	thread spawn_heli_wave( "ds_heli_10" );	//ship 1
	wait 1;
	thread spawn_heli_wave( "ds_heli_20" ); //unload helis
	wait 3;
	thread spawn_jet_wave( "ds_jet_10" );
	
	wait 4;
	
	thread spawn_heli_wave( "ds_heli_50" ); //come at player
	wait 1;
	thread spawn_jet_wave( "ds_jet_50" ); //come at player
	
	wait 3;
	
	thread spawn_jet_wave( "ds_jet_20" );
	wait 1;
	thread spawn_heli_wave( "ds_heli_30" );	//ship 3
	
	wait 7;
	
	thread spawn_jet_wave( "ds_jet_30" );
	wait 1;
	thread spawn_heli_wave( "ds_heli_40" );	//ship 2
	wait 1;
	thread spawn_jet_wave( "ds_jet_10" );

	wait 2;
	
	thread spawn_heli_wave( "ds_heli_50" ); //come at player
	wait 1;
	thread spawn_jet_wave( "ds_jet_50" ); //come at player	
		
	wait 8;
	
	thread sink_middle_ship();
	
	thread spawn_heli_wave( "ds_heli_10" );	//ship 1
	wait 1;
	thread spawn_jet_wave( "ds_jet_40" );
	wait 1;
	thread spawn_heli_wave( "ds_heli_20" ); //unload helis
	wait 1;
	thread spawn_jet_wave( "ds_jet_20" );
	
	flag_set( "reinforce_incoming_1" );
	
	wait 5;
	
	thread spawn_heli_wave( "ds_heli_40" );	//ship 2
	wait 1;
	thread spawn_jet_wave( "ds_jet_10" );
	wait 1;
	thread spawn_heli_wave( "ds_heli_50" ); //come at player
	wait 1;
	thread spawn_jet_wave( "ds_jet_50" ); //come at player
	
	flag_set( "clearing_up" );
	
	wait 6;
	
	flag_set( "defend_sparrow_finished" );
}

sink_middle_ship()
{
	flag_set( "sink_middle_ship" );
	level.ds_ship_02 moveto( level.ds_ship_02.origin - (0,0,1000), 20, 10 );
	level.ds_ship_02 RotateTo( level.ds_ship_02.angles + (-20,0,0), 15, 8 );
	
	fx_tag = spawn_tag_origin();
	fx_tag.origin = level.ds_ship_02.origin - (0,0,2000);
	fx_tag.angles = (-90,0,0);
	PlayFXOnTag( getfx( "thick_dark_smoke_giant" ), fx_tag, "tag_origin" );
//	flag_wait( "heli_ride_finished" );
//	StopFXOnTag( getfx( "thick_dark_smoke_giant" ), fx_tag, "tag_origin" );			
}

run_nag_vo()
{
	level endon( "defend_sparrow_start" );
	
	//Hesh: Adam grab the guidance scope and paint the targets!
	level.hesh smart_dialogue( "carrier_hsh_adamgrabtheguidance" );	
	
	wait 4;
	
	//Hesh: Get on the Mark 115 and paint the targets!
	level.hesh smart_dialogue( "carrier_hsh_getonthemark" );	

	//NAG!!!!!!!!!
	while ( 1 )
	{
		wait RandomFloatRange( 8, 12 );
		//Hesh: Adam grab the guidance scope and paint the targets!
		level.hesh smart_dialogue( "carrier_hsh_adamgrabtheguidance" );	
		
		wait RandomFloatRange( 8, 12 );
		
		//Hesh: Get on the Mark 115 and paint the targets!
		level.hesh smart_dialogue( "carrier_hsh_getonthemark" );	
	}
}

run_defend_vo()
{
	//Triton: Reports of large forces entering our space.
	smart_radio_dialogue( "carrier_ttn_reportsoflargeforces" );
	//Triton: Our ships are taking a beating. Clear out that sky.
	smart_radio_dialogue( "carrier_ttn_ourshipsaretaking" );
//	//Triton: Incoming left!
//	smart_radio_dialogue( "carrier_ttn_incomingleft" );
	wait 2;
	//Triton: Incoming right!
	smart_radio_dialogue( "carrier_ttn_incomingright" );
	//Triton: Overwhelming forces incoming!
	smart_radio_dialogue( "carrier_ttn_overwhelmingforces" );

	flag_wait( "reinforce_incoming_1" );
	//Fox: This is Fox Squad. ETA 2 minutes. 
	smart_radio_dialogue( "carrier_fox_thisisfoxsquad" );	
	
	flag_wait( "sink_middle_ship" );
	//Triton: The Carolina has been lost. I repeat, the Carolina is down.
	smart_radio_dialogue( "carrier_ttn_thecarolinahasbeen" );	
	
	flag_wait( "clearing_up" );
	//Triton: Radar indicates it's clearing up. No further bogies inbound.
	smart_radio_dialogue( "carrier_ttn_radarindicatesitsclearing" );
	
	wait 2;
	
	//Fox: Fox over, we have the Prometheus in sight.
	smart_radio_dialogue( "carrier_fox_foxoverwehave" );
	
	wait 1;
	
	//Fox: We're clearing the sky for the C-17s.
	smart_radio_dialogue( "carrier_fox_wereclearingthesky" );
	
	flag_wait( "defend_sparrow_finished" );
	//Triton: Radar is clear.  All forces clear to move to deployment vectors.
	smart_radio_dialogue( "carrier_ttn_radarisclearall" );	
}

run_operator()
{
	spawner = getent( "defend_sparrow_operator", "targetname" );
	defend_sparrow_operator = spawner spawn_ai( true, false );
	defend_sparrow_operator.animname = "generic";	
	defend_sparrow_operator endon("death");
	
	ref = getstruct( "defend_sparrow_control_ref", "targetname" );
	ref anim_loop_solo( defend_sparrow_operator, "crouch_idle" );
	defend_sparrow_operator.ignoreall = true;
	
	flag_wait( "rog_hit" );
	defend_sparrow_operator StopAnimScripted();
}

//called externally
get_ships_in_position_for_defend_sparrow( instant )
{
	us_destroyer_4		 = GetEnt( "us_destroyer_4", "targetname" );
	us_destroyer_4_goal = getstruct( "us_destroyer_4_goal", "targetname" );
	us_destroyer_5		 = GetEnt( "us_destroyer_5", "targetname" );
	us_destroyer_5_goal = getstruct( "us_destroyer_5_goal", "targetname" );
	
	if ( IsDefined( instant ) && instant )
	{
		us_destroyer_4.origin = us_destroyer_4_goal.origin;
		us_destroyer_4.angles = us_destroyer_4_goal.angles;
		
		us_destroyer_5.origin = us_destroyer_5_goal.origin;
		us_destroyer_5.angles = us_destroyer_5_goal.angles;
	}
	else
	{
		us_destroyer_4 MoveTo( us_destroyer_4_goal.origin, 60, 30, 30 );
		us_destroyer_5 MoveTo( us_destroyer_5_goal.origin, 60, 30, 30 );
		us_destroyer_4 RotateTo( us_destroyer_4_goal.angles, 60, 30, 30 );
		us_destroyer_5 RotateTo( us_destroyer_5_goal.angles, 60, 30, 30 );
	}
}

spawn_jet_wave( targetname )
{
	array_spawn_function_targetname( targetname, maps\carrier_planes::mig29_monitor_projectile_death );
	array_spawn_function_targetname( targetname, ::sam_add_target );	
	return spawn_vehicles_from_targetname_and_drive( targetname );			
}

spawn_heli_wave( targetname )
{
	array_spawn_function_targetname( targetname, ::heli_fast_explode, 66 );
	array_spawn_function_targetname( targetname, ::sam_add_target );
	array_spawn_function_targetname( targetname, ::drone_delete_on_unload );

	return spawn_vehicles_from_targetname_and_drive( targetname );
}
