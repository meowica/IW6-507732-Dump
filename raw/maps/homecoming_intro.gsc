#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\homecoming_util;
#include maps\homecoming_drones;

#using_animtree( "generic_human" );
intro_spawn_functions()
{
	// AI \\
	// street
	//array_spawn_function_noteworthy( "intro_building_cqbers", ::intro_building_cqbers );
	array_spawn_function_targetname( "intro_runners", ::intro_runners );
	array_spawn_function_targetname( "house_stumble_dude", ::intro_house_stumble_event );

	// VEHICLES \\
	
	// street
	getent( "intro_stryker", "targetname" ) add_spawn_function( ::intro_stryker_logic );
	//array_spawn_function_targetname( "intro_slamraam", ::intro_slamraams_think );
	//array_spawn_function_targetname( "intro_abrams_runners", ::intro_abrams_runners );	
}

// STREET SEQUENCE
intro_sequence_street()
{	
	//thread intro_ambient();
	//thread intro_osprey();
	//thread intro_driveby_vehicles(b);
	
	/*-----------------------
	SCRIPTED SEQUENCE
	-------------------------*/
	thread intro_scripted_sequence();
	
	/*-----------------------
	AMBIENT
	-------------------------*/
	array_thread( getstructarray( "intro_bunker_turret", "targetname" ), ::intro_bunker_turrets );
	thread intro_flavorburst();
	thread intro_animated_scenes();
	
	/*-----------------------
	DRONE RUNNERS
	-------------------------*/
	thread intro_skybridge_drones();
	thread intro_garage_drones();
	//thread intro_street_drones();
	
	/*-----------------------
	DRONE SHOOTERS
	-------------------------*/
	array_spawn( getentarray( "intro_drone_shooters", "targetname" ) );
	
	/*-----------------------
	VEHICLES
	-------------------------*/
	thread intro_house_artemis();
	thread intro_cargo_osprey();
	
}

intro_scripted_sequence()
{
	/*-----------------------
	PLAYER OSPREY SEQUENCE
	-------------------------*/
	//thread intro_player_osprey();
	thread intro_player_nh90();
	
	/*-----------------------
	FIRE TURRETS
	-------------------------*/
	spots = getstructarray( "intro_bunker_turret", "targetname" );
	turret_1 = undefined;
	turret_2 = undefined;
	foreach( spot in spots )
	{
		if( !isdefined( spot.script_noteworthy ) )
			continue;
		
		if( spot.script_noteworthy == "bunker_osprey_turret_1" )
			turret_1 = getentarray( spot.target, "targetname" );
		else
			turret_2 = getentarray( spot.target, "targetname" );
	}
	
	wait( 1.1 );
	thread intro_bunker_turrets_fire( turret_1 );
	wait( 1.5 );
	thread intro_bunker_turrets_fire( turret_2 );

	spawn_vehicle_from_targetname_and_drive( "intro_pullup_truck" );
	array_spawn( getentarray( "intro_runners", "targetname" ) );
	
	//thread intro_animation_scenes();
	//thread intro_osprey_crash();
	//thread intro_tarp_slamraam();
		
	//thread spawn_vehicles_from_targetname_and_drive( "intro_driveby_trucks" );
	
	/*-----------------------
	HESH WAVE
	-------------------------*/
	teleSpot = getstruct( "intro_hesh_start", "targetname" );
	level.hesh ForceTeleport( teleSpot.origin, teleSpot.angles );
	waveSpot = getstruct( teleSpot.target, "targetname" );
	waveSpot anim_reach_solo( level.hesh, "intro_hesh_wave" );
	
	flag_wait( "FLAG_intro_hesh_start" );
	
	thread add_dialogue_line( "Hesh",  "Common Adam, let's move!" );
	delaythread( 1, ::add_dialogue_line, "Hesh",  "Cairo heel!" );
	
	waveSpot thread anim_single_solo( level.hesh, "intro_hesh_wave" );
	
	level.heroes thread heroes_move( "movespot_street" );	
	
	waittill_trigger( "player_moving_towards_house" );
	
	level.heroes thread heroes_move( "movespot_bunker" );	
}

#using_animtree( "vehicles" );
intro_player_nh90()
{
	fadein = maps\_hud_util::create_client_overlay( "black", 1, level.player );
	hud_hide();
	level.player disableweapons();
	level.player AllowCrouch( true );
	level.player allowstand( false );
	level.player allowprone( false );
	
	nh90 = spawn_vehicle_from_targetname( "intro_player_nh90" );
	nh90 setanim( %nh90_right_door_open, 1, 1, 10 );
	nh90 SetAnimRestart( %nh90_landing_gear_down, 1, 1, 10 );
	
	heroSpots = getstructarray( "intro_nh90_hero_spots", "targetname" );
	foreach( spot in heroSpots )
	{
		ospreySpot = spawn_tag_origin();
		ospreySpot.origin = spot.origin;
		ospreySpot.angles = spot.angles;
		ospreySpot linkto( nh90 );
		
			if( isdefined( spot.script_noteworthy ) )
			{
				foreach( hero in level.heroes )
				{
					if( spot.script_noteworthy == hero.script_noteworthy )
					{
						hero.ospreySpot = ospreySpot;
						hero linkto( hero.ospreySpot, "tag_origin", ( 0,0,0 ), ( 0,0,0 ) );
					}
				}
			}
			else
			{
				level.player.ospreySpot = ospreySpot;
				level.player setplayerangles( ospreySpot.angles );
				level.player playerlinkto( level.player.ospreySpot, "tag_origin", 1, 25, 25, 25, 35 );
			}
	}
	
	level.dog.ospreySpot thread anim_loop_solo( level.dog, "casualidle" );
	
	flag_wait( "FLAG_bunker_turrets_setup" );
	
	thread add_dialogue_line( "Hesh", "All units, this is Lieutenant Rourke. " );
	wait( 1 );
	thread add_dialogue_line( "Hesh", "We are landing in section B charlie in a stolen enemy chopper. " );
	wait( 1.5 );
	thread add_dialogue_line( "Hesh",  "Hold your fire!" );
	wait( .5 );
	
	fadein thread maps\_hud_util::fade_over_time( 0, 1 );
	
	thread gopath( nh90 );
	
	nh90 player_nh90_land();
	
	wait( .4 );
	level.dog notify( "stop_loop" );
	level.dog unlink();
	level.dog.ospreySpot thread anim_single_solo( level.dog, "down_70" );
	
	flag_set( "FLAG_intro_hesh_start" );
	
	wait( .4 );
	thread player_nh90_jumpout();
}

player_nh90_land()
{
	currentSpot = self.currentNode;
	self SetNearGoalNotifyDist( 5 );
	self SetHoverParams( 0, 0, 0 );
	self SetVehGoalPos( currentSpot.origin, true );
	self ClearGoalYaw();
	self SetTargetYaw( flat_angle( self.angles )[ 1 ] );
	self waittill( "near_goal" );
}

player_nh90_jumpout()
{
	spot = level.player.ospreySpot;
	fwd = AnglesToForward( spot.angles );
	origin = spot.origin + ( fwd * 70 );
	spot unlink();
	spot moveto( origin , .4, .1, 0 );
	wait( .5 );
	level.player unlink();
	
	hud_show();
	level.player enableWeapons();
	level.player AllowCrouch( true );
	level.player allowstand( true );
	level.player allowprone( true );
}

#using_animtree( "vehicles" );
intro_player_osprey()
{
	fadein = maps\_hud_util::create_client_overlay( "black", 1, level.player );
	hud_hide();
	level.player disableweapons();
	level.player AllowCrouch( true );
	level.player allowstand( false );
	level.player allowprone( false );
	
	ospreyStruct = getstruct( "intro_player_osprey", "targetname" );
	osprey = spawn( "script_model", ospreyStruct.origin );
	osprey.angles = ospreyStruct.angles;
	osprey setmodel( "vehicle_v22_osprey_fly" );
	osprey UseAnimTree( #animtree );
//	osprey = spawn_vehicle_from_targetname( "intro_player_osprey" );
//	osprey notify ( "stop_kicking_up_dust" );
	
	heroSpots = getstructarray( "intro_osprey_hero_spots", "targetname" );
	foreach( spot in heroSpots )
	{
		ospreySpot = spawn_tag_origin();
		ospreySpot.origin = spot.origin;
		ospreySpot.angles = spot.angles;
		ospreySpot linkto( osprey );
		
			if( isdefined( spot.script_noteworthy ) )
			{
				foreach( hero in level.heroes )
				{
					if( spot.script_noteworthy == hero.script_noteworthy )
					{
						hero.ospreySpot = ospreySpot;
						hero linkto( hero.ospreySpot, "tag_origin", ( 0,0,0 ), ( 0,0,0 ) );
					}
				}
			}
			else
			{
				level.player.ospreySpot = ospreySpot;
				level.player setplayerangles( ospreySpot.angles );
				level.player playerlinkto( level.player.ospreySpot, "tag_origin", 1, 25, 25, 25, 25 );
			}
	}
	
	fake_doors = getentarray( "osprey_fake_interior_doors", "targetname" );
	foreach( door in fake_doors )
		door linkto( osprey, door.script_noteworthy );
	
	osprey SetAnimRestart( %v22_osprey_wings_up, 1, 0.2, 10 );
	osprey SetAnimRestart( %v22_osprey_hatch_down, 1, 1, 10 );
	
	flag_wait( "FLAG_bunker_turrets_setup" );
	
	fadein thread maps\_hud_util::fade_over_time( 0, 1 );
	
	landSpot = getstruct( "player_osprey_landing_spot", "targetname" );
	osprey moveto( landSpot.origin, 5.5, 0, 2.5 );
	osprey rotateto( landSpot.angles, 5.5, 0, 2.5 );
	
	osprey waittill( "rotatedone" );
	
	heroes = array_add( level.heroes, level.player );
	foreach( hero in heroes )
	{
		hero unlink();
		hero.ospreySpot delete();
	}
	
	flag_set( "FLAG_start_bunker_turret_fire" );
	
	hud_show();
	level.player enableWeapons();
	level.player AllowCrouch( true );
	level.player allowstand( true );
	level.player allowprone( true );
	
	flag_wait( "FLAG_start_bunker" );
	
	osprey delete();
}

intro_animated_scenes()
{
	structs = getstructarray( "intro_animated_scene", "targetname" );
	droneSpawner = getent( "intro_anim_drone", "targetname" );
	foreach( struct in structs )
	{
		switch( struct.script_noteworthy )
		{
			case "sitting_wounded" :
				struct thread sitting_wounded_scene( droneSpawner );
				break;
			case "cpr" :
				struct thread cpr_scene( droneSpawner );
				break;
			case "wire_pull" :
				struct thread bared_wire_scene( droneSpawner );
				break;
			case "generic_looper" :
				struct thread generic_looper( droneSpawner );
				break;
		}
		waitframe();
	}
}

sitting_wounded_scene( droneSpawner )
{
	trigger = getent( self.target, "targetname" );
	aiSpawner = getent( trigger.target, "targetname" );
	
	drone = droneSpawner spawn_ai();
	drone gun_remove();
	self thread anim_generic_loop( drone, "hurt_sitting_wounded_loop" );
	
	trigger waittill( "trigger" );
	
	ai = aiSpawner spawn_ai();
	ai ignore_everything();
	ai magic_bullet_shield();
	
	//self anim_generic_reach( ai, "help_hurt_sitting_helper" );
	
	self notify( "stop_loop" );
	
	self thread anim_generic( drone, "help_hurt_sitting_wounded" );
	self anim_generic( ai, "help_hurt_sitting_helper" );
	
	self thread anim_generic_loop( drone, "help_hurt_sitting_wounded_loop" );
	self thread anim_generic_loop( ai, "help_hurt_sitting_helper_loop" );
	
	flag_wait( "FLAG_start_bunker" );
	
	ai delete_safe();
	drone delete_safe();
}

cpr_scene( droneSpawner )
{
	wounded = droneSpawner spawn_ai();
	wounded gun_remove();
	
	medic = droneSpawner spawn_ai();
	medic gun_remove();
	
	self thread anim_generic( wounded, "DC_Burning_CPR_wounded" );	
	self anim_generic( medic, "DC_Burning_CPR_medic" );
	
	self thread anim_generic_loop( medic, "DC_Burning_CPR_medic_endidle" );
	
	flag_wait( "FLAG_start_bunker" );
	
	wounded delete_safe();
	medic delete_safe();
}

bared_wire_scene( droneSpawner )
{
	level.barbedwireRunners = [];
	
	thread barbed_wire_waver();
	
	drone = droneSpawner spawn_ai();
	drone.animname = "wire_puller";
	wire = spawn_anim_model( "barbed_wire", self.origin );
	
	scene = [ drone, wire ];
	
	self thread anim_first_frame( scene, "wire_pull" );
	
	flag_wait( "TRIGFLAG_barbed_wire_close" );
	
	while( level.barbedwireRunners.size > 0 )
		wait( .1 );
	
	self anim_single( scene, "wire_pull" );
	drone delete();
	
	flag_wait( "FLAG_start_bunker" );
	
	wire delete_safe();
}

barbed_wire_waver()
{
	spawner = getent( "bared_wire_waver", "targetname" );
	waver = spawner spawn_ai();
	waver thread magic_bullet_shield();
	
	struct = getstruct( spawner.script_linkto, "script_linkname" );
	struct thread anim_generic_loop( waver, "wire_wave" );
	
	flag_wait( "TRIGFLAG_barbed_wire_close" );
	
	struct notify( "stop_loop" );
	waver stopanimscripted();
	waver move_on_path( getstruct( spawner.target, "targetname" ), true );
}

generic_looper( droneSpawner )
{
	drone = droneSpawner spawn_ai();
	
	if( self parameters_check( "nogun" ) )
		drone gun_remove();

	if( self parameters_check( "first_frame" ) )
		self thread anim_generic_first_frame( drone, self.animation );
	else
		self thread anim_generic_loop( drone, self.animation );
	
	flag_wait( "FLAG_start_bunker" );
	
	drone delete_safe();
}

set_flavorburst_drones( team, state )
{
	level.flavorbursts[ team ] = state;
	drones = level.drones[ team ].array;
	array_thread( drones, ::set_flavorbursts, state );
}

MAX_FLAVORBURST_GUYS = 3;	
MAX_FLAVORBURST_DIST = 800;
intro_flavorburst()
{
	level endon( "stop_intro_flavorburst" );

	battlechatter_off( "allies" );
	flavorbursts_off( "allies" );
	
	while(1)
	{
		guys = [];
		guys = GetAIArray( "allies" );
		guys = array_combine( guys, level.drones[ "allies" ].array );
		close_guys = get_array_of_closest( level.player.origin, guys, undefined, MAX_FLAVORBURST_GUYS, MAX_FLAVORBURST_DIST );
		array_thread( close_guys, ::custom_flavor_burst_on_me );
		
		wait( 6 );
			
	}	
}

custom_flavor_burst_on_me()
{
	//self = dude playing sound
	self endon("death");
	self notify("doing_custom_flavor_burst");
	
	self endon("doing_custom_flavor_burst");
	
	wait( randomfloatrange( .5, 2 ) );
	
	//taken from flavorburst system!
	nationality = "american";
	burstID = animscripts\battlechatter::getFlavorBurstID( self, nationality );
	aliases = animscripts\battlechatter::getFlavorBurstAliases( nationality, burstID );
	
	//self thread Print3d_on_me( "*" );
	//play the alias on the guy
	if( isdefined( aliases.size ) )
	{
		if( aliases.size > 0 )
		{	
			self thread play_sound_on_entity( random( aliases ) );
			self waittill( "sounddone" );
		}
	}
	self notify ("stop_print3d_on_ent" );
}

intro_animation_scenes()
{
	spots = getstructarray( "intro_anim_spots", "targetname" );
	spawner = getent( "intro_anim_drone", "targetname" );
	
	foreach( struct in spots )
	{
		assert( isdefined( struct.script_animation ) );
		myAnim = struct.script_animation; 
		drone = spawner spawn_ai();
		
		if( struct parameters_check( "nogun" ) )
			drone gun_remove();
		
		struct thread anim_generic_loop( drone, myAnim );
		
		waitframe(); // so we don't spawn two guys on the same frame
	}
}

BUNKER_TURRETS_MAXY = 25;
intro_bunker_turrets()
{
	turrets = getentarray( self.target, "targetname" );

	points = [];
	foreach( turret in turrets )
	{
		points[ points.size ] = turret.origin;
		struct = getstruct( turret.target, "targetname" );
		turret.fireTag = spawn( "script_model", struct.origin );
		turret.fireTag setmodel( "tag_origin" );
		turret.fireTag.angles = struct.angles;
		turret.fireTag linkto( turret );
	}
	
	flag_set( "FLAG_bunker_turrets_setup" );
	flag_wait( "FLAG_start_bunker_turret_fire" );
	
	midpoint = get_midpoint( points, true );
	base = spawn( "script_model", midPoint );
	base setmodel( "tag_origin" );
	base.angles = ( 0,0,0 );
	
	bool = randomint( 2 );
	while( 1 )
	{
		foreach( turret in turrets )
			turret linkto( base );
		
		newY = undefined;
		if( bool )
		{
			bool = 0;
			newY = randomintrange( 15, BUNKER_TURRETS_MAXY );
			
			if( base.angles[1] + newY > BUNKER_TURRETS_MAXY )
				newY = BUNKER_TURRETS_MAXY;
		}
		else
		{
			bool = 1;
			newY = randomintrange( -25, -15 );
			negMaxY = BUNKER_TURRETS_MAXY * -1;
			
			if( base.angles[1] - newY < negMaxY )
				newY = negMaxY;
		}
		
		newAngles = ( base.angles[0], newY, base.angles[2] );
		base rotateto( newAngles, 2, .5, .5 );
		base waittill( "rotatedone" );
		
		wait( .2 );
		
		intro_bunker_turrets_fire( turrets );
		
		wait( randomfloatrange( 3.5, 6.5 ) );
	}
}

intro_bunker_turrets_fire( turrets )
{
	foreach( turret in turrets )
	{	
		turret unlink();
		
		playfxontag( getfx( "tank_flash" ), turret.fireTag, "tag_origin" );
		turret.fireTag thread play_sound_on_tag( "intro_bunker_fire", "tag_origin" );
			
		originalOrigin = turret.origin;
		fwd = anglestoforward( turret.angles );
		back = fwd * -1;
		origin = turret.origin + ( back * 25 );
			
		turret moveto( origin, .2 );
		wait( .2 );
		turret moveto( originalOrigin, .6 );
		wait( .2 );
	}	
}

intro_medic_osprey()
{
	osprey = spawn_vehicle_from_targetname( "intro_medic_osprey" );
	osprey notify ( "stop_kicking_up_dust" );	
	
	osprey SetAnimRestart( %v22_osprey_wings_up, 1, 0.2, 10 );
	osprey SetAnimRestart( %v22_osprey_hatch_down, 1, 0.2, 10 );
}

intro_tarp_slamraam()
{
	slamraam = getent( "intro_tarp_slamraam", "targetname" );
	
	spawner = getent( slamraam.target, "targetname" );
	stuffArray = [];
	for( i=0; i<2; i++ )
	{
		ai = spawner spawn_ai();
		ai.animname = "slamraamAI_"+ i;
		stuffArray[ stuffArray.size ] = ai;
		waitframe(); // don't spawn two ai from spawner on same frame
	}
	
	tarp = spawn_anim_model( "slamraamTarp", slamraam.origin );
	stuffArray[ stuffArray.size ] = tarp;
	slamraam thread anim_first_frame( stuffArray, "slamraam_tarp" );
	
	flag_wait( "TRIGFLAG_slamraam_animate" );
	
	slamraam anim_single( stuffArray, "slamraam_tarp" );
	aiArray = array_remove( stuffArray, tarp );
	slamraam thread anim_loop_solo( aiArray[1], "slamraam_idle" );
	
	
}


intro_runners()
{
	self disable_arrivals_and_exits();
	self ignore_everything();
	self pathrandompercent_zero();
	self.fixedNode = false;
	self.interval = 0;
	self.pushable = false;
	self.badplaceawareness = 0;
	self magic_bullet_shield( true );
	//self set_generic_run_anim( "combat_jog" );

	self thread move_on_path( getstruct( self.target, "targetname" ), true );
	
	
	msg = self waittill_any_return( "heading_to_wire", "death" );
	if( msg == "death" )
		return;
	
	if( flag( "TRIGFLAG_barbed_wire_close" ) )
	{
		self notify( "stop_path" );
		self setgoalpos( self.origin ); // clear goalpos
		self SetGoalVolumeAuto( getent( "intro_street_runner_goalvolume", "targetname" ) );
		
		flag_wait( "FLAG_start_bunker" );
		
		self delete();
		
		return;
	}
	
	level.barbedwireRunners = array_add( level.barbedwireRunners, self );
	
	msg = self waittill_any_return( "past_wire", "death" );
	
	level.barbedwireRunners = array_remove( level.barbedwireRunners, self );
}

#using_animtree( "vehicles" );
intro_osprey_crash()
{
	osprey = spawn_vehicle_from_targetname( "intro_crash_osprey" );
	osprey SetAnimRestart( %v22_osprey_wings_up, 1, 0.2, 10 );
	
	osprey waittill( "crash_start" );
	playfxontag( getfx( "osprey_engine_explosion" ), osprey, "tag_engine_left" );
	//playfxontag( getfx( "osprey_engine_trail" ), osprey, "tag_engine_left" );
	osprey thread playLoopingFX( "osprey_engine_trail", .1, undefined, "tag_engine_left" );
	osprey thread play_loop_sound_on_entity( "blackhawk_helicopter_dying_loop" );
	
	osprey waittill( "reached_end_node" );
	playfx( getfx( "building_explosion" ), osprey.origin );
	osprey delete();
	
}

intro_stryker_logic()
{
	self create_default_targetEnt();
	self setturrettargetent( self.defaultTarget );
	self thread vehicle_fire_loop( undefined, .6, 1.4 );
	
	self waittill( "reached_end_node" );
	self notify( "stop_firing" );

}

#using_animtree( "generic_human" );
intro_house_stumble_event()
{
	fxSpot = getstruct( "house_stairs_explosion_spot", "targetname" );
	animSpot = getstruct( self.target, "targetname" );
	
	self.animname = "generic";
	
	playfx( getfx( "house_hallway_explosion" ), fxSpot.origin, anglestoforward( fxSpot.angles ) );
	animSpot thread anim_single_solo( self, "wall_stumble" );
	waitframe();
	self setanimtime( getanim_generic( "wall_stumble" ), .13 );
	animSpot waittill( "wall_stumble" );
	animSpot thread anim_loop_solo( self, "wall_stumble_idle" );
	
	// ADD DELETE
	flag_wait( "TRIGFLAG_player_jumped_down_balcony" );
	
	self delete();
}

// OLD STUFF
#using_animtree( "vehicles" );
intro_osprey()
{	
	osprey = spawn_vehicle_from_targetname( "intro_osprey" );
	osprey notify ( "stop_kicking_up_dust" );
	
	// This is the osprey that takes off and flys away
	fakeOsprey = spawn( "script_model", osprey.origin );
	fakeOsprey.angles = osprey.angles;
	fakeOsprey hide();
	fakeOsprey setmodel( "vehicle_v22_osprey_fly" );
	fakeOsprey UseAnimTree( #animtree );
	fakeOsprey SetAnimRestart( %v22_osprey_props, 1 );
	fakeOsprey SetAnimRestart( %v22_osprey_wings_up, 1, 0.2, 10 );
	fakeOsprey SetAnimRestart( %v22_osprey_hatch_down, 1, 0.2 );
	
	// This is temp while I wait for the new osprey
	fake_doors = getentarray( "osprey_fake_interior_doors", "targetname" );
	foreach( door in fake_doors )
		door linkto( osprey, door.script_noteworthy );
	
	osprey SetAnimRestart( %v22_osprey_wings_up, 1, 0.2, 10 );
	osprey SetAnimRestart( %v22_osprey_hatch_down, 1 );
	
	foreach( door in fake_doors)
	{
		door unlink();
		door linkto( fakeOsprey, door.script_noteworthy );
	}
	
	
	flag_wait( "intro_osprey_fly_away" );
	
	playerCheck = getent( "intro_osprey_player_check", "targetname" );
	while( level.player istouching( playerCheck ) )
		wait( .1 );
	
	fakeOsprey show();
	osprey delete();
	
	fakeOsprey ClearAnim( %v22_osprey_hatch_down, 1 );
	fakeOsprey SetAnimRestart( %v22_osprey_hatch_up, 1 );
	
	struct = getstruct( "intro_osprey_exit", "targetname" );
	array = get_target_chain_array( struct );
	first = true;
	foreach( index, struct in array )
	{
		fakeOsprey moveto( struct.origin, 2 );
		fakeOsprey rotateto( struct.angles, 2 );
		wait( 2 );
		
		if( first )
		{
			fakeOsprey thread osprey_fake_hover();
			
			fakeOsprey ClearAnim( %v22_osprey_wings_up, 1 );
			fakeOsprey SetAnimRestart( %v22_osprey_wings_down,1,0,0.25 );
			wait( getanimlength( %v22_osprey_wings_down ) + .5 );
			first = false;
			
			fakeOsprey notify( "stop_fake_hover" );
		}
	}
	
	fakeOsprey delete();
	
}


osprey_fake_hover()
{
	self endon( "stop_fake_hover" );
}

intro_scripted_sequence_old()
{
	tatra = spawn_vehicle_from_targetname( "intro_tatra" );
	
	leader = undefined;
	foreach( rider in tatra.riders )
	{
		if( isdefined( rider.script_noteworthy ) && rider.script_noteworthy == "leader" )
			leader = rider;
	}
	
	array_spawn( getentarray( "intro_leader_troops", "targetname" ) );
	
	level.hesh.goalradius = 56;
	level.heroes move_to_goal( "intro_circle_jerk", undefined, "struct" );
	
	tatra waittill( "unloaded" );
	
	struct = getstruct( "intro_circle_jerk_leader", "targetname" );
	
	leader.goalradius = 56;
	leader setgoalpos( struct.origin );
	leader waittill_goal();
	
	wait( 4 );
	
	flag_set( "intro_osprey_fly_away" );
	
	//missiles = spawn_vehicles_from_targetname_and_drive( "battleship_missiles" );
	//array_thread( missiles, ::intro_ship_attack );
	wait( 1.5 );
	
	leader OrientMode( "face angle", struct.angles[ 1 ] );
	
	wait( .9 );
	
	//struct anim_generic_reach( leader, "briefing" );
	struct thread anim_generic( leader, "briefing" );
	
	wait( 3 );

	level.heroes move_to_goal( "movespot_bunker" );
	
	wait( 1.4 );
	
	getent( "intro_circlejerk_color_trig", "targetname" ) notify( "trigger" );
	
}

intro_ship_attack()
{
	self waittill( "reached_end_node" );
	playfx( getfx( "building_explosion" ), self.origin, ( 0,1,0 ) );
	self delete();
}

intro_driveby_vehicles()
{
	drivebyVehicles = spawn_vehicles_from_targetname( "intro_driveby_vehicles" );
	abrams = undefined;
	stryker = undefined;
	foreach( vehicle in drivebyVehicles )
	{
		if( isdefined( vehicle.script_noteworthy ) && vehicle.script_noteworthy == "abrams" )
			abrams = vehicle;
		else if( isdefined( vehicle.script_noteworthy ) && vehicle.script_noteworthy == "stryker" )
			stryker = vehicle;			
	}
	
	abrams thread intro_abrams_logic();
	stryker thread intro_stryker_logic();
}

intro_abrams_logic()
{
	
	self thread gopath();
	self thread player_stay_behind_abrams();
	array_spawn( getentarray( "intro_abrams_runners", "targetname" ), true );
	
//	getvehiclenode( "abrams_minigun_engage_choppers", "script_noteworthy" ) waittill( "trigger" );
//	
//	points = [];
//	choppers = spawn_vehicles_from_targetname_and_drive( "abrams_target_choppers" );
//	foreach( chopper in choppers )
//		points[ points.size ] = chopper.origin;
//	
//	midpoint = get_midpoint( points, true );
//	target = spawn( "script_origin", midpoint );
//	target linkto( choppers[0] );
//	
//	self.mgturret[1] settargetentity( target );
//	
//	while( distance2dSquared( self.origin, midpoint ) > squared( 4300 ) )
//		wait( .2 );
//	
//	self.mgturret[1] TurretFireDisable();
//	
//	wait( randomfloatrange( .4, .8 ) );
//	
//	self.mgturret[1] cleartargetentity();
//	target delete();
	
	getvehiclenode( "abrams_minigun_engage_beach", "script_noteworthy" ) waittill( "trigger" );
	
	target = spawn( "script_origin", ( -2664, 2144, 248 ) );
	self.mgturret[1] settargetentity( target );
	self.mgturret[1] TurretFireEnable();
	
	self waittill( "reached_end_node" );
	
	flag_set( "FLAG_turn_off_abrams_player_check" );
}

// Checks to see if the player is infront of the beginning abrams, if so turn off sprint temporarily
// Most players will never come close to being infront, this is just to make sure
player_stay_behind_abrams()
{
	frontEnt = spawn( "script_origin", self.origin );
	fwd = anglestoforward( self.angles );
	spot = self.origin + ( fwd * 120 );
	frontEnt = spawn( "script_origin", spot );
	frontEnt.angles = self.angles;
	frontEnt linkto( self );
	
	sprintOff = false;
	while( !flag( "FLAG_turn_off_abrams_player_check" ) )
	{
		check = postion_dot_check( frontEnt, level.player );
		if( check == "infront" )
		{
			level.player allowsprint( false );
			sprintOff = true;
		}
		else if( sprintOff )
		{
			level.player allowSprint( true );
			sprintOff = false;
		}
		
		wait( .1 );
	}
	
	if( sprintOff )
		level.player allowsprint( true );
	
	frontEnt delete();
}

#using_animtree( "generic_human" );
intro_ambient()
{
	thread intro_skybridge_drones();
	thread intro_house_artemis();
	thread intro_street_crossers();
	thread ambient_aa( "intro_aa_spots" );
	//spawn_vehicles_from_targetname( "intro_slamraam" );
}

intro_house_artemis()
{
	vSpawner = getent( "intro_house_artemis", "targetname" );
	artemis = vSpawner spawn_vehicle();
	artemis thread artemis_think();
}

#using_animtree( "vehicles" );
intro_cargo_osprey()
{
	osprey = spawn_vehicle_from_targetname_and_drive( "intro_cargo_osprey" );
	cargo = getentarray( osprey.script_linkto, "script_linkname" );
	foreach( piece in cargo )
		piece linkto( osprey );
	osprey UseAnimTree( #animtree );
	
	//osprey SetAnimRestart( %v22_osprey_wings_up,1,0,10 );
	osprey sethoverparams( 32, 10, 3 );
}

intro_slamraams_think()
{
	
	
//	self slamraam_think();	
//	
//	if( !isdefined( self.target ) )
//		return;
//	
//	trigger = getent( self.target, "targetname" );
//	trigger waittill( "trigger" );
//	
//	fireSpeed = [ .1, .3 ];
//	self slamraam_fire_missiles( undefined, fireSpeed, "slamraam_missile_guided_fast" );
}

#using_animtree( "generic_human" );
intro_street_crossers()
{
	spawner = getent( "intro_street_runners", "targetname" );
	for( i=0; i<3; i++ )
	{
		ai = spawner spawn_ai( true );
		wait( randomfloatrange( .7, 1.2 ) );
	}
}

intro_building_cqbers()
{
	self enable_cqbwalk();
	self disable_arrivals_and_exits();
	self ignore_everything();
	self thread waittill_goal( 56, true );
	self setgoalpos( getstruct( self.target, "targetname" ).origin );
}

intro_skybridge_drones()
{
	spawners = getentarray( "intro_skybridge_runners", "targetname" );
	runAnims = [ "run" ];
	weaponSounds = [ "drone_m16_fire_npc", "drone_m4carbine_fire_npc" ];
	spawnTime = [ 1.2, 3.2 ];
	
	spawners thread drone_infinite_runners( "TRIGFLAG_stop_skybridge_drones", spawnTime, runAnims, weaponSounds );
	
}

intro_garage_drones()
{
	spawners = getentarray( "intro_garage_runners", "targetname" );
	runAnims = [ "run" ];
	spawnTime = [ 2.2, 4 ];
	
	spawners thread drone_infinite_runners( "TRIGFLAG_stop_skybridge_drones", spawnTime, runAnims );	
}

intro_street_drones()
{
	spawners = getentarray( "intro_street_runners", "targetname" );
	runAnims = [ "run" ];
	spawnTime = [ 2.8, 4 ];
	
	spawners thread drone_infinite_runners( "TRIGFLAG_stop_skybridge_drones", spawnTime, runAnims );	
}

beach_flyover_helis()
{
	spawners = getentarray( "beach_flyover_helis", "targetname" );
	
	lastSpawner = undefined;
	while( 1 )
	{
		currentSpawners = spawners;
		while( currentSpawners.size > 0 )
		{
			
			while( 1 )
			{
				vSpawner = currentSpawners[ randomint( currentSpawners.size ) ];
				
				if( !isdefined( lastSpawner ) )
					break;
				
				if( lastSpawner == vSpawner )
				{
					wait( .05 );
					continue;
				}
				
				break;
			}
			
			lastSpawner = Vspawner;
			
			vSpawner thread spawn_vehicle_and_gopath();
			currentSpawners = array_remove( currentSpawners, vSpawner );
			wait( randomintrange( 1, 5 ) );
		}
	}
}