#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;

heli_ride_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	maps\_minigun::main();
	
	//flag inits
	flag_init( "heli_ride" );
	flag_init( "heli_ride_finished" );
	flag_init( "heli_landed" );
	flag_init( "heli_ride_right_combat_2" );
	flag_init( "player_on_blackhawkgun" );
	flag_init( "blackhawk_down_vo_finished" );
	flag_init( "helicrash_spinout2" );
	flag_init( "heli_ride_music" );
	flag_init( "heli_ride_music_stop" );
	flag_init( "gunner_death_finished" );
		
	//precache
	PreCacheTurret ( "dshk_turret_sp" );
	PreCacheModel( "cnd_rappel_rope" );
	PreCacheModel( "weapon_blackhawk_minigun" );//the blackhawk side turret
	PreCacheModel( "weapon_blackhawk_minigun_viewmodel" );//the blackhawk side turret viewmodel
	PreCacheModel( "cnd_zipline_trolley" );
	PreCacheModel( "cnd_zipline_trolley_obj" );
	PreCacheItem( "tomahawk_missile" );
	
	//init arrays/vars
	level.zodiacs = [];
	level.gunboats = [];
	
	//hide ents
	level.heli_ride_destroyer_smoking = getent( "heli_ride_destroyer_smoking", "targetname" );
	level.heli_ride_destroyer_smoking hide_entity();
	
	level.heli_ride_destroyer_sinking	= getent( "heli_ride_destroyer_sinking", "targetname" );
	
	//debug
	SetDvarIfUninitialized( "skip_heli_ride", "0" );
}

//*only* gets called from checkpoint/jumpTo
setup_heli_ride()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "heli_ride";
	setup_common();	
	spawn_allies();
	
	thread maps\carrier::obj_defend_carrier();
	thread maps\carrier_vista::run_vista();
	flag_set( "fb_01" );
	flag_set( "slow_intro_deck" );
	flag_set( "slow_intro_finished" );	
	
	level.heli_ride_destroyer_smoking show_entity();	
	
	fork = GetEnt( "forklift3", "targetname" );
	fork hide_entity();
	fork_clip = GetEnt( "forklift3_clip", "targetname" );
	fork_clip hide_entity();
}

//always gets called
begin_heli_ride()
{
	//--use this to run your functions for an area or event.--	
	setup_blackhawk_heli_ride( "heli_ride_blackhawk_player" );
	
	array_spawn_function_targetname( "heli_ride_blackhawk_ally", ::setup_blackhawk_ally );	
	array_spawn_function_targetname( "heli_ride_blackhawk_ally2", ::setup_blackhawk_ally );
	level.blackhawk_ally = spawn_vehicle_from_targetname_and_drive( "heli_ride_blackhawk_ally" );
	level.blackhawk_ally2 = spawn_vehicle_from_targetname_and_drive( "heli_ride_blackhawk_ally2" );
	
	
	thread heli_ride_ally();		
	level.player_blackhawk thread heli_ride();		
	thread run_enemies();
	thread run_ambience();
		
	flag_wait( "heli_ride_finished" );
	thread autosave_now_silent();
}





/*-----------------------------------------------*/
/*------------------ HELI RIDE ------------------*/
/*-----------------------------------------------*/
heli_ride()
{
	//INIT
	use_ent = getent( "heli_ride_blackhawk_player_seat", "targetname" );
	use_ent linkto( level.player_blackhawk, "tag_origin" );	
	blackhawk_glowing_obj = getent( "blackhawk_glowing_obj", "targetname" );
	blackhawk_glowing_obj linkto( level.player_blackhawk, "tag_guy3" );	
	use_ent MakeUsable();
	use_ent SetCursorHint( "HINT_ACTIVATE" );	
	use_ent SetHintString( "Press [{+activate}] to get in blackhawk." ); //TODO: localize		
//	Missile_CreateRepulsorEnt(level.player_blackhawk,1000,400);	
	Missile_CreateAttractorEnt( level.player_blackhawk, 40000, 5000 );
	thread run_blackhawk_gunner();
	
	//MINIGUNS
	level.player_blackhawk thread run_player_blackhawk_automated_minigun();
	level.blackhawk_ally delaythread( 2, ::run_blackhawk_minigun );
	
	thread heli_ride_intro_vo();
			
	flag_wait( "blackhawk_minigun_fire" );
	self set_lookat_targetname( "heli_ride_path_land_end" );

	//LAND
	flag_wait( "heli_ride_path_intro_end" );
	waittill_blackhawk_minigun_finished();
	node = getstruct( "heli_ride_path_land_start", "targetname" );
	self thread vehicle_paths( node );
	chopper_land_node = getstruct( "heli_ride_path_land_end", "targetname" );
	
	//Merrick: Adam. Hesh. Get in the choppers and provide air support!
	level.merrick delaythread( 1, ::smart_dialogue, "carrier_mrk_adamheshgetin" );

	flag_wait( "heli_ride_path_start" );
	self thread heli_lands( chopper_land_node );	

	//HESH GET IN
	thread load_blackhawk_hesh();		
	
	flag_wait( "heli_landed" );
	
	//seat glow
	blackhawk_glowing_obj glow();
		
	//PLAYER GET IN
	use_ent waittill( "trigger" );	
	thread autosave_by_name( "heli_ride" );	
	use_ent MakeUnusable();		
	init_player_on_blackhawk_heli_ride();	
	flag_set( "heli_ride" );
	thread set_player_weapon_heli_ride();
//	setsaveddvar( "player_damageMultiplier", 0.5 );
	level.player EnableDeathShield( true );	
	blackhawk_glowing_obj Delete();
	level.friendlyFireDisabled = true;	

	
	//DEBUG SKIP
	/#
	if ( GetDebugDvar( "skip_heli_ride" ) == "1" )
	{
		skip_heli_ride();	
		return;		
	}
	#/
	
	
	//GO!
	self ClearLookAtEnt();
	start_node = getstruct( "heli_ride_path_10", "targetname" );
	self thread vehicle_paths(start_node);	
	self set_lookat_targetname( "heli_ride_path_10" );	
	wait 2;
	self ClearLookAtEnt();	
	thread redshirt_operate_minigun_left();

	//Overlord: Enemies rappelling to deck! We need gun fire on those ropes.
	delaythread( 2, ::smart_radio_dialogue, "carrier_hqr_enemiesrappellingtodeck" );
	
	flag_wait( "backleft_lookat" );
	flag_set( "heli_ride_music" );
	self SetLookAtEnt( GetEnt( "backleft_lookat_ent", "targetname" ) );		
	thread backleft_vo();
	
	flag_wait( "backleft_lookat_stop" );	
	self ClearLookAtEnt();		
	thread big_turn_vo();
	
	flag_wait( "heli_ride_big_turn" );
	SetSavedDvar( "sm_sunSampleSizeNear", 2.75 );
	level.merrick stop_magic_bullet_shield();
	level.merrick Delete();
	level.player.ignoreme = true; //so player doesn't get prematurely shot by gunboats	
	
	flag_wait( "minigun_redshirt_dies" );
	thread run_cleanup();
	self notify( "stop_fx" );

	//GUNNER DEATH
	gunner_death();
	self ClearLookAtEnt();	
	wait 5;
	level.player.ignoreme = false;
	
	//SPARROW DOWN!
	flag_wait( "heli_ride_sparrow_down" );	
	sparrow_explodes = getstruct( "sparrow_explodes", "targetname" );
	playfx( getfx( "vehicle_explosion_mig29" ), sparrow_explodes.origin );
	thread play_sound_in_space( "carr_heli_engine_explosion", sparrow_explodes.origin );
	thread sparrow_down_vo();
		
	//CRASH
	flag_wait( "heli_ride_path_20_end" );	
	start_node = getstruct("heli_ride_path_30", "targetname" );
	self thread vehicle_paths(start_node);
	
	run_helicrash();
	
	flag_set( "heli_ride_music_stop" );
	thread run_cleanup();
}

run_blackhawk_gunner()
{
	level.player_blackhawk_gunner = spawn_targetname( "player_blackhawk_gunner", "targetname" );
	level.player_blackhawk_gunner.animname = "generic";
	level.player_blackhawk_gunner magic_bullet_shield( true );
	level.player_blackhawk_gunner.blackhawk_tag = spawn_tag_origin();
	level.player_blackhawk_gunner.blackhawk_tag linkto( level.player_blackhawk, "tag_gun_l", (0,0,0), (0,0,0) );
	level.player_blackhawk_gunner linkto( level.player_blackhawk_gunner.blackhawk_tag, "tag_origin", (0,0,0), (0,0,0) );
	level.player_blackhawk_gunner.blackhawk_tag anim_loop_solo( level.player_blackhawk_gunner, "carrier_heli_ride_idle_gunner", "stop_loop" );
}

setup_blackhawk_ally()
{
	self SetHoverParams( 75, 50, 60 );
}

heli_ride_ally()
{
	flag_wait( "heli_ride" );
	level.blackhawk_ally thread vehicle_paths( getstruct( "heli_ride_blackhawk_ally_path2", "targetname" ) );
	level.blackhawk_ally2 thread vehicle_paths( getstruct( "heli_ride_blackhawk_ally2_path2", "targetname" ) );	
	
	flag_wait( "blackhawk_ally_shoot_stern" );
	level.blackhawk_ally blackhawk_own_target();
	wait 0.5;
	level.blackhawk_ally blackhawk_own_target();
		
	flag_wait( "allied_blackhawk_down" );	
	level.blackhawk_ally kill();
	
	//Overlord: Wasp Three Three is hit and going down!
	smart_radio_dialogue( "carrier_hqr_waspthreethreeis" );
	flag_set( "blackhawk_down_vo_finished" );
	
	flag_wait( "heli_ride_blackhawk_ally2_delete" );
	level.blackhawk_ally2 Delete();
}

load_blackhawk_hesh()
{
	animEnt = getent( "hesh_blackhawk_getin", "targetname" );		
	
	animEnt anim_reach_solo( level.hesh, "hesh_blackhawk_getin" );	
	level.hesh setGoalPos( level.hesh.origin );
	level.hesh.goalradius = 16;
	
	animEnt linkto( level.player_blackhawk, "tag_gun_l" );
	animEnt anim_reach_solo( level.hesh, "hesh_blackhawk_getin" );
	level.hesh linkto( animEnt );
	animEnt anim_single_solo( level.hesh, "hesh_blackhawk_getin" );
			
	level.hesh unlink();		
	level.hesh.blackhawk_tag = spawn_tag_origin();
	level.hesh.blackhawk_tag linkto( level.player_blackhawk, "tag_gun_l", (0,0,0), (0,0,0) );
	level.hesh linkto( level.hesh.blackhawk_tag, "tag_origin", (0,0,0), (0,0,0) );
	level.hesh.blackhawk_tag anim_loop_solo( level.hesh, "carrier_heli_ride_idle_ally", "stop_loop" );
}

set_player_weapon_heli_ride()
{
	level.player TakeAllWeapons();
	level.player GiveWeapon( "honeybadger+acog_sp" );
	level.player SwitchToWeapon( "honeybadger+acog_sp" );	
}

/#
skip_heli_ride()
{
	start_node = getstruct("heli_ride_path_30", "targetname" );		
	self thread vehicle_paths(start_node);
	self Vehicle_Teleport( start_node.origin, start_node.angles );
	self ClearLookAtEnt();
	thread run_cleanup();
	player_switch_to_blackhawk_minigun();	
	run_helicrash();	
}
#/

gunner_death()
{
	//Wasp 1: Incoming fire.
	smart_radio_dialogue( "carrier_wsp1_incomingfire" );
	wait 1;
	//Hesh: Man down! We’ve lost our gunner!
	level.hesh smart_dialogue( "carrier_hsh_mandownwevelost" );
	//Hesh: Adam, man the turret!
	level.hesh thread smart_dialogue( "carrier_hsh_adammantheturret" );	
	
	level.player_blackhawk_gunner.blackhawk_tag notify( "stop_loop" );
	level.player_blackhawk thread anim_single_solo( level.player_blackhawk_gunner, "carrier_heli_ride_gunner_death_gunner", "tag_gun_l" );
	level.hesh.blackhawk_tag notify( "stop_loop" );
	level.player_blackhawk thread anim_single_solo( level.hesh, "carrier_heli_ride_gunner_death_ally", "tag_gun_l" );
	
	level.player_rig = spawn_anim_model( "player_rig" );	
	level.player PlayerLinkToBlend( level.player_rig, "tag_player", 0.2 );
	level.player_rig linkto( level.player_blackhawk, "tag_player1" );
	level.player DisableWeapons();
	level.player_blackhawk anim_single_solo( level.player_rig, "carrier_heli_ride_gunner_death_player", "tag_player1" );
	level.player_rig Unlink();
	
	level.player_blackhawk_gunner Delete();
	
	player_switch_to_blackhawk_minigun();
	flag_set( "gunner_death_finished" );
	
	
}





/*---------------------------------------------*/
/*------------------ ENEMIES ------------------*/
/*---------------------------------------------*/
run_enemies()
{
	thread run_enemies_left();	
	thread run_water_combat();
	thread run_heli_dogfight();
	thread run_enemies_deck();
	thread run_enemies_right();
	thread run_enemies_island();
	thread run_enemies_right_2();
}

run_enemies_left()
{
	flag_wait( "backleft_combat" );
			 //   timer    func 				   param1 				 
	delayThread( 0		, ::spawn_zodiacs_rappel, "zodiac_backleft_01" );
	delayThread( 0.25	, ::spawn_zodiacs_rappel, "zodiac_backleft_01b" );
	delayThread( 0		, ::spawn_zodiacs_rappel, "zodiac_backleft_02" );
	delayThread( 3		, ::spawn_zodiacs_rappel, "zodiac_backleft_03" );
	delayThread( 5		, ::spawn_zodiacs_rappel, "zodiac_backleft_04" );
	delayThread( 6		, ::spawn_zodiacs_rappel, "zodiac_backleft_05" );
	delayThread( 8		, ::spawn_zodiacs_rappel, "zodiac_backleft_06" );
	delayThread( 7		, ::spawn_zodiacs_rappel, "zodiac_backleft_06b" );
	delayThread( 9		, ::spawn_zodiacs_rappel, "zodiac_backleft_06c" );
	delayThread( 10		, ::spawn_zodiacs_rappel, "zodiac_backleft_07" );
}

redshirt_operate_minigun_left()
{
	turret = level.player_blackhawk.mgturret[0];
	turret SetMode( "auto_nonai" );
	turret StartFiring();
	
	wait 13;
	//Ally Soldier 2: More zodiacs incoming!
	level.player_blackhawk_gunner smart_dialogue( "carrier_gs2_morezodiacsincoming" );
}

run_water_combat()
{
	flag_wait( "heli_ride_pre_water_combat" );
	thread spawn_gunboat( "gunboat_00" );	
	thread spawn_gunboat( "gunboat_01" );
	
	flag_wait( "heli_ride_water_combat" );
			
	thread water_combat_vo();
	
	thread spawn_gunboat( "gunboat_35" );	
	thread spawn_gunboat( "gunboat_36" );		
	
	thread spawn_gunboat( "gunboat_10" );	
	thread spawn_gunboat( "gunboat_11" );	
	wait 2;
	thread spawn_zodiacs( "zodiac_00" );
	wait 5;
	thread spawn_zodiacs( "zodiac_01" );
	wait 1;
	thread spawn_zodiacs( "zodiac_02" );
	thread spawn_gunboat( "gunboat_20" );	
	thread spawn_gunboat( "gunboat_21" );
	
	flag_wait( "heli_ride_water_combat_2" );	
	wait 3;
	thread spawn_gunboat( "gunboat_30" );	
	thread spawn_gunboat( "gunboat_31" );	
	
	flag_wait( "heli_ride_water_combat_4" );
	thread spawn_gunboat( "gunboat_40" );	
}

run_heli_dogfight()
{
	flag_wait( "heli_ride_heli_combat" );	
	
	thread run_heli_dogfight_vo();
	
	level.enemy_heli_01 = spawn_vehicle_from_targetname_and_drive( "heli_dogfight_01" );
	level.enemy_heli_01.health = 25000;
	level.enemy_heli_01.currenthealth = 25000;
	level.enemy_heli_02 = spawn_vehicle_from_targetname_and_drive( "heli_dogfight_02" );
	level.enemy_heli_02.health = 25000;
	level.enemy_heli_02.currenthealth = 25000;

	flag_wait( "refill_enemy_heli_1" );
	if ( !IsDefined( level.enemy_heli_01 ) || !IsAlive( level.enemy_heli_01 ) || level.enemy_heli_01 vehicle_is_crashing() )
	{
		level.enemy_heli_01 = spawn_vehicle_from_targetname_and_drive( "heli_dogfight_01_refill_1" );
	}
	if ( !IsDefined( level.enemy_heli_02 ) || !IsAlive( level.enemy_heli_02 ) || level.enemy_heli_02 vehicle_is_crashing() )
	{
		level.enemy_heli_02 = spawn_vehicle_from_targetname_and_drive( "heli_dogfight_02_refill_1" );
	}	
	
	flag_wait( "refill_enemy_heli_2" );
	if ( !IsDefined( level.enemy_heli_01 ) || !IsAlive( level.enemy_heli_01 ) || level.enemy_heli_01 vehicle_is_crashing() )
	{
		level.enemy_heli_01 = spawn_vehicle_from_targetname_and_drive( "heli_dogfight_01_refill_2" );
	}
	if ( !IsDefined( level.enemy_heli_02 ) || !IsAlive( level.enemy_heli_02 ) || level.enemy_heli_02 vehicle_is_crashing() )
	{
		level.enemy_heli_02 = spawn_vehicle_from_targetname_and_drive( "heli_dogfight_02_refill_2" );
	}	
	
	
	flag_wait( "heli_ride_heli_combat_end" );
	if ( IsDefined( level.enemy_heli_01 ) && IsAlive( level.enemy_heli_01 ) )
	{
		level.enemy_heli_01 kill();
	}
	wait 1.5;
	if ( IsDefined( level.enemy_heli_02 ) && IsAlive( level.enemy_heli_02 ) )
	{	
		level.enemy_heli_02 kill();
	}
}

run_enemies_deck()
{
	//deck
	flag_wait( "heli_ride_heli_combat" );
	thread array_spawn_targetname_allow_fail( "enemy_heli_ride_deck_front", true );		
}

run_enemies_right()
{
	flag_wait( "heli_ride_heli_combat_end" );
	
	thread enemies_right_vo();
	
	thread run_cleanup();
	thread spawn_zodiacs_rappel( "zodiac_10" );
	thread spawn_zodiacs_rappel( "zodiac_11" );
	thread spawn_zodiacs_rappel( "zodiac_12" );
	thread spawn_zodiacs_rappel( "zodiac_13" );	
	
	targetname_spawn( "enemy_heli_ride_zodiac" );
	targetname_spawn( "enemy_heli_ride_hangar" );
	thread array_spawn_targetname_allow_fail( "ally_heli_ride_hangar", true );
	thread spawn_zodiacs_rappel( "zodiac_14" );
	thread spawn_zodiacs_rappel( "zodiac_15" );
	thread spawn_zodiacs_rappel( "zodiac_16" );
	thread spawn_zodiacs_rappel( "zodiac_17" );
	thread spawn_zodiacs_rappel( "zodiac_18" );
	thread spawn_zodiacs_rappel( "zodiac_19" );
	thread spawn_zodiacs_rappel( "zodiac_20" );
}

run_enemies_island()
{
	//island
	flag_wait( "heli_ride_island_combat" );	
	run_cleanup();
	delaythread( 0, ::spawn_zodiacs_rappel, "zodiac_22" );
	delaythread( 0, ::spawn_zodiacs_rappel, "zodiac_23" );
	
	level.enemies_island = [];
	thread island_breach();
	thread array_spawn_targetname_allow_fail( "ally_heli_ride_island", true );
	thread spawn_zodiacs_rappel( "zodiac_island_10" );
	guys = array_spawn_targetname_allow_fail( "enemy_heli_ride_island" );
	level.enemies_island = array_combine( array_removeDead_or_dying( level.enemies_island ), guys );	
	
	//island 2	
	guys = array_spawn_targetname_allow_fail( "enemy_heli_ride_island_2" );
	top_guys = guys;
	level.enemies_island = array_combine( array_removeDead_or_dying( level.enemies_island ), guys );
	targetname_spawn( "ally_heli_ride_island_2" );		
	
	thread island_top( top_guys );	
	
	flag_set( "heli_ride_right_combat_2" );
}

island_breach()
{
	breach_guys = array_spawn_targetname_allow_fail( "enemy_heli_ride_island_breach" );
	level.enemies_island = array_combine( array_removeDead_or_dying( level.enemies_island ), breach_guys );
		
	wait 5;
	
	door = getent( "heli_ride_island_breach_door", "targetname" );	
	clip = getent( "heli_ride_island_breach_door_clip", "targetname" );
	fx = getstruct( "heli_ride_island_breach_fx", "targetname" );
	playfx( level._effect[ "breach_door_metal"], fx.origin );
	target = getstruct( door.target, "targetname" );
	door moveto( target.origin, 0.5, 0.2 );	
	clip hide_entity();
	
	wait 1.5;
	foreach ( guy in breach_guys )
	{
		if ( IsDefined( guy ) )
		{
			guy thread run_to_volume_and_delete( "goalvol_island_interior" );		
		}
		wait 0.5;
	}
}

island_top( top_guys )
{
	foreach ( guy in top_guys )
	{
		if ( IsDefined( guy ) && IsAlive( guy ) )
		{
			guy thread run_to_volume_and_delete( "goalvol_island_interior_top" );		
		}
		wait 0.5;
	}	
}

run_enemies_right_2()
{
	flag_wait( "heli_ride_right_combat_2" );
	thread array_spawn_targetname_allow_fail( "ally_heli_ride_lower_10", true );
	thread array_spawn_targetname_allow_fail( "enemy_heli_ride_lower_10", true );
	thread array_spawn_targetname_allow_fail( "ally_heli_ride_lower_20", true );
	thread array_spawn_targetname_allow_fail( "enemy_heli_ride_lower_20", true );	
	thread spawn_zodiacs_rappel( "zodiac_24" );
	thread spawn_zodiacs_rappel( "zodiac_25" );		
}




/*----------------------------------------------*/
/*------------------ AMBIENCE ------------------*/
/*----------------------------------------------*/
run_ambience()
{
	thread smoking_ship();
	thread sinking_ship();
	thread heli_ride_armada();
	thread jet_vignette_01();
	thread rpg_enemies();
	flagWaitThread( "heli_ride_big_turn", maps\carrier_defend_sparrow::get_ships_in_position_for_defend_sparrow );
	level.heli_ride_cruiser	= getent( "heli_ride_cruiser", "targetname" );
	level.heli_ride_cruiser thread temp_boat_bob();	
}

smoking_ship()
{
	flag_wait( "heli_ride" );
	fx_tag = spawn_tag_origin();
	fx = getstruct( "heli_ride_destroyer_smoking_fx", "targetname" );
	fx_tag.origin = fx.origin;
	fx_tag.angles = (-90,0,0);
	PlayFXOnTag( getfx( "thick_dark_smoke_giant" ), fx_tag, "tag_origin" );
	//stop this earlier?
	flag_wait( "rog_reaction" );
	StopFXOnTag( getfx( "thick_dark_smoke_giant" ), fx_tag, "tag_origin" );
}

sinking_ship()
{
	flag_wait( "heli_ride_water_combat_2" );	
	level.heli_ride_destroyer_sinking moveto( level.heli_ride_destroyer_sinking.origin - (0,0,700), 10, 7 );
	
	fx_tag = spawn_tag_origin();
	fx = getstruct( "heli_ride_destroyer_2_smoking_fx", "targetname" );
	fx_tag.origin = fx.origin;
	fx_tag.angles = (-90,0,0);
	PlayFXOnTag( getfx( "thick_dark_smoke_giant" ), fx_tag, "tag_origin" );
	//stop this earlier?
	flag_wait( "heli_ride_finished" );
	StopFXOnTag( getfx( "thick_dark_smoke_giant" ), fx_tag, "tag_origin" );	
}

temp_boat_bob()
{
	self RotateRoll( -5, 2.5, 2.5 );
	wait 2.5;
	while ( 1 )
	{
		self MoveTo( self.origin - (0,0,32), 5, 2.5, 2.5 );
		self RotateRoll( 10, 3, 1.5, 1.5 );
		wait 3;
		self MoveTo( self.origin + (0,0,32), 5, 2.5, 2.5 );
		self RotateRoll( -10, 3, 1.5, 1.5 );
		wait 3;		
	}
}

heli_ride_armada()
{
	flag_wait( "heli_ride_water_combat" );
	vehicles_unload = spawn_vehicles_from_targetname_and_drive( "heli_ride_armada_unload" );
	vehicles = spawn_vehicles_from_targetname_and_drive( "heli_ride_armada" );
	
	foreach ( vehicle in vehicles_unload )
	{	
		foreach ( guy in vehicle.riders )
		{
			guy.drone_delete_on_unload = true;
		}
	}
	
	foreach ( vehicle in vehicles )
	{
		Target_Set( vehicle );
    	Target_HideFromPlayer( vehicle, level.player );

		//blow up non unloading helis on cointoss
		if ( cointoss() )
		{
			delaythread( RandomFloatRange( 4, 8 ), ::fire_single_sparrow_missile, ter_op( cointoss(), level.sparrow_right, level.sparrow_left ), vehicle );
		}
	}
}

jet_vignette_01()
{
	flag_wait( "heli_ride_water_combat_2" );
	jet_blowup = spawn_vehicle_from_targetname_and_drive( "heli_ride_jet_vignette_01_blowup");
	jet_missile = spawn_vehicle_from_targetname_and_drive( "heli_ride_jet_vignette_01_missile");
	
    Target_Set( jet_blowup );
    Target_HideFromPlayer( jet_blowup, level.player );
	
    //blow up fast mover
	fire_single_sparrow_missile( level.sparrow_left, jet_blowup );
}

rpg_enemies()
{
	flag_wait( "heli_ride_water_combat" );
	array_spawn_function_targetname( "heli_ride_rpg_enemies_10", ::rpg_guy_wait_and_fire_at_target, level.player_blackhawk, "heli_ride_water_combat_3" );
	rpg_enemies = array_spawn_targetname_allow_fail( "heli_ride_rpg_enemies_10", true );	
}

ally_ambient_movement()
{	
	spawn_targetname ("ally_deck_runner1");
	spawn_targetname ("ally_deck_runner2");
	spawn_targetname ("ally_deck_runner3");
	
	waver = spawn_targetname("ally_wave_plane");
	
	waver.animname = "generic";
	waver.ignoreall = 1;
	waver.diequietly = 1;
	waver.noragdoll = 1;
	waver.a.nodeath = 1;
	waver.allowdeath = 1;
	waver gun_remove();
	
	waver thread anim_single_solo(waver,"run_wave");
		
	dragman = spawn_targetname("ally_dragger");
	
	
	dragman.animname = "generic";
	dragman.ignoreall = 1;
	dragman.diequietly = 1;
	dragman.noragdoll = 1;
	dragman.a.nodeath = 1;
	dragman.allowdeath = 1;
	dragman gun_remove();
	
	dragman thread anim_single_solo(dragman,"dragger");
	
	
	wounded_drag = spawn_targetname("ally_wounded_drag_deck");
		
	wounded_drag.animname = "generic";
	wounded_drag.ignoreall = 1;
	wounded_drag.diequietly = 1;
	wounded_drag.noragdoll = 1;
	wounded_drag.a.nodeath = 1;
	wounded_drag.allowdeath = 1;
	wounded_drag gun_remove();
	
	wounded_drag thread anim_single_solo(wounded_drag,"wounded being dragged");
}

run_cleanup()
{
	thread ai_cleanup( "enemy_heli_ride" );
	thread ai_cleanup( "ally_heli_ride" );
	
	foreach ( zodiac in level.zodiacs )
	{
		if ( IsDefined( zodiac ) )
		{
			zodiac Delete();
		}
	}
	
	foreach ( gunboat in level.gunboats )
	{
		if ( IsDefined( gunboat ) )
		{
			gunboat Delete();
		}
	}	
}



/*------------------------------------------------*/
/*------------------ HELI CRASH ------------------*/
/*------------------------------------------------*/
run_helicrash()
{
	flag_wait("crash_time");   
	playfx( level._effect[ "vehicle_explosion_mig29" ], level.player_blackhawk.origin);
    level.player thread play_loop_sound_on_entity( "missile_incoming" );   
    earthquake( .7, 2.5, level.player.origin, 1600 );
	level.player_blackhawk thread player_spinout();
	thread helicrash_vo();
	
	flag_wait( "helicrash_jump" );
	wait 1; //wait for VO
	thread helicrash_jump();
	
	flag_wait( "helicrash_explode" );
	playfx( getfx( "vehicle_explosion_mig29" ), level.player_blackhawk.origin );
	level.player_blackhawk Delete();
}

player_spinout()
{
	self endon( "death" );
	
	self SetMaxPitchRoll( 50, 100 );
	self setturningability( 1 );
	yawspeed = 1000;
	yawaccel = 200;
	targetyaw = undefined;

	while ( isdefined( self ) && !flag( "helicrash_stop_spin" ) )
	{
		targetyaw = self.angles[ 1 ] + 100;
		self setyawspeed( yawspeed, yawaccel );
		self settargetyaw( targetyaw );
		wait 0.1;
	}
	
	self set_lookat_targetname( "helicrash_jump" );	
	helicrash_jump = getstruct( "helicrash_jump", "targetname" );
	self settargetyaw( helicrash_jump.angles[1] );
	
	flag_wait( "helicrash_spinout2" );	
	
	wait 1.0;
	
	self ClearLookAtEnt();
	self SetMaxPitchRoll( 50, 100 );
	self setturningability( 1 );
	yawspeed = 1000;
	yawaccel = 200;
	targetyaw = undefined;

	while ( isdefined( self ) )
	{
		targetyaw = self.angles[ 1 ] + 100;
		self setyawspeed( yawspeed, yawaccel );
		self settargetyaw( targetyaw );
		wait 0.1;
	}	
}

helicrash_jump()
{
	slowmo_setspeed_slow( .5 );
    slowmo_setlerptime_in( 1 );    
    slowmo_lerp_in();
	
    level.player thread show_msg( "JUMP!", 2 );
	jumped = helicrash_jumpcheck( 2 );
	
	slowmo_setlerptime_out( 0.25 );    
    slowmo_lerp_out();
    
    flag_set( "helicrash_spinout2" );

//NO FAIL FOR NOW    
//    if ( !IsDefined( jumped ) || !jumped )
//    {
//    	flag_wait( "helicrash_explode" );
//    	level.player Kill();
//    	return;
//    }
    
	// init anim
	anim_node = getent( "helicrash_anim_ref", "targetname" );
	level.hesh.anim_node = anim_node;
	blendtime			 = 1;
	
	// init player
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player DisableWeaponSwitch();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	SetSavedDvar( "sm_sunSampleSizeNear", 0.25 );
	level.player stop_loop_sound_on_entity( "missile_incoming" );	
	maps\carrier_blackhawk::player_dismount_blackhawk_gun();	
	flag_set( "obj_defend_carrier_complete" );	//OBJECTIVE FAILED  
	SetSavedDvar( "cg_fov", 65 );	
	level.friendlyFireDisabled = false;
//	setsaveddvar( "player_damageMultiplier", 1.0 );
	level.player EnableDeathShield( false );	
	
	//init hesh
    level.hesh unlink();
    level.hesh StopAnimScripted();
    level.hesh gun_remove();
    level.hesh.blackhawk_tag notify( "stop_loop" ); 	
	
    thread hesh_anim();
   
	// setup player rig
   	player_rig = spawn_anim_model( "player_rig" );
   	player_rig.origin = anim_node.origin;
	player_rig LinkTo( anim_node );
	player_rig Hide();
	
	// animate hesh and player_rig
	level.hesh notify( "helicrash_pullup" );
	anim_node thread anim_single_solo( player_rig, "helicrash_jump" );
		
	// blend player into jump
	level.player PlayerLinkToBlend( player_rig, "tag_player", blendtime );
	level.player delayCall( blendtime, ::HideViewModel );
	player_rig delayCall( blendtime, ::Show );

	// Player hits side and climbs up							
	level waittill( "notify_jump_hit_side" );
		
	// sync animation to player
	time = player_rig GetAnimTime( level.scr_anim[ "player_rig" ][ "helicrash_jump" ] );
	level.hesh SetAnimTime(  level.scr_anim[ "hesh" ][ "helicrash_pullup" ], time );

	thread cleanup_helicrash_on_notify( player_rig );	

}

hesh_anim()
{
	level.hesh waittill( "helicrash_pullup" );
	level.hesh LinkTo( level.hesh.anim_node );	 
	level.hesh.anim_node anim_single_solo( level.hesh, "helicrash_pullup", undefined, 0.1 );
	level.hesh Unlink();		
}

helicrash_jumpcheck( timeout )
{
	level endon( "helicrash_jumpfail" );
	
	jump_held = false;
	
	// delay timout thread
	delayThread( timeout, ::helicrash_jumpfail );
	
	// jumpcheck loop
	while( 1 )
	{
		if( level.player JumpButtonPressed() )
		{
			if( !jump_held )
			{
				return true;
			}
		}
		else
		{
			jump_held = false;
		}
		
		wait( 0.05 );
	}
}

helicrash_jumpfail()
{
	level notify( "helicrash_jumpfail" );
}

cleanup_helicrash_on_notify( player_rig )
{
	level waittill( "notify_player_end_vignette" );
	
	// re-set player
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player EnableWeaponSwitch();
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	level.player ShowViewModel();
	level.player unlink();
	
	heli_crash_player_spot = getstruct( "heli_crash_player_spot", "targetname" );
	tag_origin = spawn_tag_origin();
	tag_origin.origin = heli_crash_player_spot.origin;
	tag_origin.angles = heli_crash_player_spot.angles;
	
	flag_set( "heli_ride_finished" );
	
	tag_origin lerp_player_view_to_tag( level.player, "tag_origin", 0.7, .8, 70, 70, 40, 55 );
	level.player unlink();
	level.hesh gun_recall();
	player_rig delete();
}







/*----------------------------------------*/
/*------------------ VO ------------------*/
/*----------------------------------------*/
heli_ride_intro_vo()
{
	//Wasp: Wasp Three-One in position for gun run.
	smart_radio_dialogue( "carrier_wsp_waspthreeoneinposition" );
	//Triton: You are in the clear Three One.
	smart_radio_dialogue( "carrier_ttn_youareinthe" );
	//Wasp: Wasp Three-One copies, multiple targets, inbound hot.
	smart_radio_dialogue( "carrier_wsp_waspthreeonecopies" );
}

backleft_vo()
{
	wait 8;
	//Triton: Enemy choppers deploying troops!
	smart_radio_dialogue( "carrier_ttn_enemychoppersdeploying" );
	
	//Wasp 2: I have visual. Clearing hostiles!
	smart_radio_dialogue( "carrier_wsp2_ihavevisualclearing" );
	
	//Overlord: Large enemy force incoming by boat, right side.
	smart_radio_dialogue( "carrier_hqr_largeenemyforceincoming" );	
}

big_turn_vo()
{
	//Triton: Wasp 1, 2 and 3. Group up and circle back for a straifing run.
	smart_radio_dialogue( "carrier_ttn_wasp12and" );	
	
	//Wasp 1: Roger that!
	smart_radio_dialogue( "carrier_wsp1_rogerthat" );	
	//Wasp 2: Moving into position.
	smart_radio_dialogue( "carrier_wsp2_movingintoposition" );
//	//Wasp 3: Sweeping back into formation.
//	smart_radio_dialogue( "carrier_wsp3_sweepingbackintoformation" );	
}

water_combat_vo()
{
	//Overlord: Multiple incoming gunboats starboard side.
	thread smart_radio_dialogue( "carrier_hqr_multipleincominggunboats" );		
	
	wait 2;
	
	//Triton: The Colorado is taking fire. Break formation and clear out those gun boats.
	smart_radio_dialogue( "carrier_ttn_thecoloradoistaking" );	
	//Wasp 1: Roger, moving left.
	smart_radio_dialogue( "carrier_wsp1_rogermovingleft" );	
	//Wasp 2: Moving low and fast.
	smart_radio_dialogue( "carrier_wsp2_movinglowandfast" );	
	//Wasp 3: Sweeping right.
	smart_radio_dialogue( "carrier_wsp3_sweepingright" );
	
	wait 2;
	
	//Overlord: F18s are in the air. I repeat, F18s are in the air.
	smart_radio_dialogue( "carrier_hqr_f18sareinthe" );	
	
	wait 1.5;
	
	//Triton: The Carolina is taking on water, clear area for rescue teams!
	smart_radio_dialogue( "carrier_ttn_thecarolinaistaking" );
}

run_heli_dogfight_vo()
{
	flag_wait( "blackhawk_down_vo_finished" );
	
	//Hesh: Take out those choppers!
	level.hesh smart_dialogue( "carrier_hsh_takeoutthosechoppers" );	
	
	wait 5;
	
	//Hesh: Get those bogeys out of the air!
	level.hesh smart_dialogue( "carrier_hsh_getthosebogeysout" );	
	
	wait 0.5;
	
	//Overlord: Enemies rappelling starboard side. Get down there and strafe run.
	smart_radio_dialogue( "carrier_hqr_enemiesrappellingside" );
}

enemies_right_vo()
{
	wait 2;
	
	//Hesh: Don’t let those zodiacs get to the Carrier.
	level.hesh smart_dialogue( "carrier_hsh_dontletthosezodiacs" );
	
	wait 2;
	
	//Hesh: They're storming the hangar!
	level.hesh smart_dialogue( "carrier_hsh_theyrestormingthehangar" );
	
	wait 2;
	
	//Triton: The ship is crawling with enemy forces.
	smart_radio_dialogue( "carrier_ttn_theshipiscrawling" );	
	
	flag_wait( "heli_ride_island_combat" );
	
	//Triton: We have reports they're breaching the island.
	smart_radio_dialogue( "carrier_ttn_wehavereportstheyre" );	
	
	wait 1;
	
	//Triton: Enemy jets in our airspace.
	smart_radio_dialogue( "carrier_ttn_enemyjetsinour" );		
}

sparrow_down_vo()
{
	wait 1;	
	//Triton: We’ve lost missile defense, repeat Sparrow is down.
	level.player play_sound_on_entity( "carrier_ttn_wevelostmissiledefense" );
	//Hesh: We need to get back to the Carrier.
	level.hesh thread smart_dialogue( "carrier_hsh_weneedtoget" );	
}

helicrash_vo()
{
//	//Blackhawk: Missile incoming. Deploy flares!
//	smart_radio_dialogue( "carrier_hp1_missileincomingdeploy" );	
//	//Blackhawk: Evasive maneuvers - bank hard!
//	smart_radio_dialogue( "carrier_hp1_evasivemaneuversbankhard" );	

	//Hesh: We're hit!
	level.hesh smart_dialogue( "carrier_hsh_werehit" );
	//Hesh: We're going down!
	level.hesh smart_dialogue( "carrier_hsh_weregoingdown" );
	
	flag_wait( "helicrash_jump" );
	
	//Hesh: Jump!
	level.hesh smart_dialogue( "carrier_hsh_jump" );
	
	flag_wait( "heli_ride_finished" );
	
	//Hesh: Adam, get your ass up!
	level.hesh smart_dialogue( "carrier_hsh_adamgetyourass" );	
}