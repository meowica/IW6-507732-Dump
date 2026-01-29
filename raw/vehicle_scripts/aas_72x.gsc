#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_utility;
#include animscripts\utility;
#using_animtree( "vehicles" );

/*QUAKED script_vehicle_aas72x (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

valid ai groups are:
"first_guys" - left and right side guys that need to be on first
"left" - all left guys
"right" - all right guys
"passengers" - everybody that can unload
"default"

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\aas_72x::main( "vehicle_aas_72x", undefined, "script_vehicle_aas72x" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_aas_72x
sound,vehicle_aas72x,vehicle_standard,all_sp
include,_attack_heli


defaultmdl="vehicle_aas_72x"
default:"vehicletype" "aas_72x"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_aas72x_nonheli (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

valid ai groups are:
"first_guys" - left and right side guys that need to be on first
"left" - all left guys
"right" - all right guys
"passengers" - everybody that can unload
"default"

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\aas_72x::main( "vehicle_aas_72x", "aas_72x_nonheli", "script_vehicle_aas72x_nonheli" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_aas_72x
sound,vehicle_aas72x,vehicle_standard,all_sp
include,_attack_heli

defaultmdl="vehicle_aas_72x"
default:"vehicletype" "aas_72x_nonheli"
default:"script_team" "axis"
*/

main( model, type, classname )
{
	build_template( "aas_72x", model, type, classname );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_aas_72x" );
	build_drive( %mi28_rotors, undefined, 0, 3.0 );

					//   effect 											   tag 		     sound 								    bEffectLooping    delay      bSoundlooping    waitDelay    stayontag   
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", 	"tag_engine_right", 	"aascout72x_helicopter_secondary_exp", 	undefined, 		undefined, 	undefined, 		0.0, 	true );
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small",	"tag_engine_left", 		"aascout72x_helicopter_dying_loop", 	true, 			1.5, 		true, 			5.0, 	true );
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", 	"tag_engine_right",		undefined, 								true, 			2.25, 		undefined, 		2.5, 	true );
	build_deathfx( "fx/explosions/helicopter_explosion_little_bird", 		undefined, 				"aascout72x_helicopter_crash", 			undefined, 		undefined,	undefined, 		- 1,	undefined, 	"stop_crash_loop_sound" );
	build_deathfx( "fx/fire/fire_smoke_trail_L", 							"tail_rotor_jnt", 		undefined, 								true, 			0.05, 		undefined, 		0.5, 	true );	
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", 	"tail_rotor_jnt", 		undefined, 								undefined, 		undefined, 	undefined, 		0.5, 	true );
	
	
	//Death by Rocket effects, explodes immediatly
	build_rocket_deathfx( "fx/explosions/helicopter_explosion_little_bird_dcburn", 	"tag_deathfx", 	"aascout72x_helicopter_crash", undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0 );

	build_deathquake( 0.8, 1.6, 2048 );
	build_life( 3000, 2800, 3100 );
	build_team( "axis" );
	build_mainturret();
	build_unload_groups( ::unload_groups );
	build_aianims( ::setanims, ::set_vehicle_anims );

	randomStartDelay = RandomFloatRange( 0, 1 );
			 //   model      name 		    tag 			   effect 							    group 	   delay 		    
	build_light( classname, "white_blink", "TAG_LIGHT_BELLY", "fx/misc/aircraft_light_white_blink", "running", randomStartDelay );
	build_light( classname, "red_blink1" , "TAG_LIGHT_TAIL1", "fx/misc/aircraft_light_red_blink_occ", "running", randomStartDelay );
	build_light( classname, "red_blink2" , "TAG_LIGHT_TAIL2", "fx/misc/aircraft_light_red_blink_occ", "running", randomStartDelay );

//	turret = "minigun_littlebird_spinnup";

	build_treadfx( classname, "default", "vfx/gameplay/tread_fx/vfx_heli_dust_sand", true );
	build_treadfx( classname, "sand", "vfx/gameplay/tread_fx/vfx_heli_dust_sand", true );
	
	build_rider_death_func( ::handle_rider_death );

			  //   info    tag 						   model 							   
//	build_turret( turret, "TAG_MINIGUN_ATTACH_LEFT" , "vehicle_little_bird_minigun_left" );
//	build_turret( turret, "TAG_MINIGUN_ATTACH_RIGHT", "vehicle_little_bird_minigun_right" );
	
	if ( IsDefined( type ) && type == "aas_72x_nonheli" )
	{
		build_is_airplane();
	}
	else
	{
		build_is_helicopter();
	}
}

init_local()
{
	self endon( "death" );
	self.dropoff_height = 270;
	self.originheightoffset	 = Distance( self GetTagOrigin( "tag_origin" ), self GetTagOrigin( "tag_ground" ) ); // TODO - FIXME: this is ugly. Derive from distance between tag_origin and tag_base or whatever that tag was.
	//self.delete_on_death	 = true;
	self.script_badplace	 = false;//All helicopters dont need to create bad places
	self.dontDisconnectPaths = true; //so it can land. pathing through heli's generally not a problem
	self.vehicle_loaded_notify_size = 6; // so Vehicle can give loaded notify on 6 guys, this feels hacky but it's been a while since I wrote littlebird mounting scripts. - Nate

	self.deathanims = get_deathanims();

	self aircraft_wash();

	thread maps\_vehicle::vehicle_lights_on( "running" );
}

handle_rider_death()
{
	if ( IsDefined( self.shooters ) )
	{
		foreach ( shooter in self.shooters )
		{
			if ( !IsDefined( shooter ) || !IsAlive( shooter ) )
				continue;
			
			shooter thread shooter_death( self );
		}
	}
	
	// Make sure the drivers stay idle
	for ( i = 0; i < 2; i++ )
	{
		if ( !IsDefined( self.riders[ i ] ) )
			continue;

		self.riders[ i ] notify( "newanim" );
		self thread guy_idle( self.riders[ i ], self.riders[ i ].vehicle_position );
	}
	
	self waittill( "crash_done" );
	array_call( self.riders, ::Delete );
}

shooter_death( vehicle )
{
	vehicle endon( "crash_done" );
	self endon( "death" );
	
	time = RandomFloatRange( 2, 15 );
	wait( time );
	
	if ( IsDefined( self ) )
		self Kill();
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = SpawnStruct();

	positions[ 0 ].sittag 				= "tag_pilot1";
	positions[ 0 ].bHasGunWhileRiding 	= false;
	positions[ 0 ].idle			 [ 0 ] 	= %aas_72x_pilot_idle;
	positions[ 0 ].idleoccurrence[ 0 ] 	= 500;

	positions[ 1 ].sittag 				= "tag_pilot2";
	positions[ 1 ].bHasGunWhileRiding 	= false;
	positions[ 1 ].idle			 [ 0 ] 	= %aas_72x_copilot_idle;
	positions[ 1 ].idleoccurrence[ 0 ] 	= 450;

	positions[ 2 ].sittag 		= "tag_guy1";
	positions[ 2 ].getout		= %aas_72x_jumpout_front_r;

	positions[ 3 ].sittag 		= "tag_guy2";
	positions[ 3 ].getout		= %aas_72x_jumpout_rear_r;

	positions[ 4 ].sittag 		= "tag_guy3";
	positions[ 4 ].getout		= %aas_72x_jumpout_front_l;

	positions[ 5 ].sittag 		= "tag_guy4";
	positions[ 5 ].getout		= %aas_72x_jumpout_rear_l;

	// common stuff for the shooters
	for ( i = 2; i < 6; i++ )
	{
		positions[ i ].linktoblend 			= true;
		positions[ i ].rider_func 			= ::init_shooter;
	}

	return positions;
}

get_deathanims()
{
	array = [ %aas_72x_seated_death_a_1, %aas_72x_seated_death_a_5, %aas_72x_seated_death_a_10, %aas_72x_seated_death_a_11, %aas_72x_seated_death_a_12 ];
	return array_randomize( array );
}

unload_groups()
{
	unload_groups					   = [];
	unload_groups[ "first_guy_left"	 ] = [];
	unload_groups[ "first_guy_right" ] = [];

	unload_groups[ "left"		] = [];
	unload_groups[ "right"		] = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "default"	] = [];

	unload_groups[ "first_guy_left"	 ][ 0 ] = 3;
	unload_groups[ "first_guy_right" ][ 0 ] = 2;
	
	unload_groups[ "stage_guy_left"	 ][ 0 ] = 3;
	unload_groups[ "stage_guy_right" ][ 0 ] = 2;

	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 2;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 3;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 4;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 5;

	
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 2;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 3;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 4;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 5;

	unload_groups[ "default" ] = unload_groups[ "passengers" ];

	return unload_groups;
}

set_vehicle_anims( positions )
{
	return positions;
}

//---------------------------------------------------------
// AI/Shooter SECTION
//---------------------------------------------------------
init_shooter()
{
	if ( IsDefined( self.script_drone ) )
	{
		init_drone();
		return;
	}

	if ( !IsDefined( self.ridingvehicle.shooters ) )
	{
		self.ridingvehicle.shooters = [];
	}
	
	self.ridingvehicle.shooters[ self.ridingvehicle.shooters.size ] = self;
	
	self.custom_animscript[ "combat" ] 	= ::shooter_animscript;
	self.custom_animscript[ "stop" ] 	= ::shooter_animscript;

	self.getOffVehicleFunc 	= ::shooter_unload;
}

init_drone()
{
	idle_anim = get_idle_anim( self.vehicle_position );
	self SetAnimKnob( idle_anim, 1, 0 );
}

shooter_unload()
{
	self.current_event = undefined;
	self.custom_animscript = undefined;
	self.allowpain = true;
	self.a.pose = "stand";
	self.grenadeawareness = 0.2;
	self.deathanim = undefined;
	self enable_surprise();
	
	self.delay = RandomFloatRange( 0, 0.75 );
	
	unload_anim = self get_unload_anim();
	time = GetAnimLength( unload_anim ) * 0.3;
	self thread notify_delay( "jumpedout", time + self.delay );
	
	self delayCall( self.delay, ::Unlink ); // put this here cause _vehicle_aianim.gsc unlinks after the animation is done
}

get_unload_anim()
{
	return level.vehicle_aianims[ self.ridingvehicle.classname ][ self.vehicle_position ].getout;
}

shooter_animscript()
{
	self endon( "death" );
	self endon( "killanimscript" );

	self.current_event = "none";
	self.rightaimlimit = 77;
	self.leftaimlimit = -57;

	self.grenadeawareness = 0;
	self.a.pose = "crouch";
    self disable_surprise();
	self.allowpain = false;

	self init_shooter_anims();
	self animscripts\track::setanimaimweight( 1, 0.2 );

	self thread shooter_tracking();
	self thread shooter_shooting();

	self event_thread();	
}

get_idle_anim( vehicle_position )
{
	animation = undefined;
	switch ( self.vehicle_position )
	{
		case 2:
			animation = %aas_72x_guy1_idle;
			break;
		case 3:
			animation = %aas_72x_guy2_idle;
			break;
		case 4:
			animation = %aas_72x_guy3_idle;
			break;
		case 5:
			animation = %aas_72x_guy4_idle;
			break;
	}

	return animation;
}

init_shooter_anims()
{
	self.a.array = [];

	self.a.array[ "idle" ] = get_idle_anim( self.vehicle_position );

	self.a.array[ "add_aim_up" ] 		= %aas_72x_guy1_aim_8;
	self.a.array[ "add_aim_down" ] 		= %aas_72x_guy1_aim_2;
	self.a.array[ "add_aim_left" ] 		= %aas_72x_guy1_aim_4;
	self.a.array[ "add_aim_right" ] 	= %aas_72x_guy1_aim_6;
	self.a.array[ "straight_level" ] 	= %aas_72x_guy1_aim_5;

	self.a.array[ "burst2" ] = %exposed_crouch_shoot_burst3;
	self.a.array[ "burst3" ] = %exposed_crouch_shoot_burst3;
	self.a.array[ "burst4" ] = %exposed_crouch_shoot_burst4;
	self.a.array[ "burst5" ] = %exposed_crouch_shoot_burst5;
	self.a.array[ "burst6" ] = %exposed_crouch_shoot_burst6;

	self.a.array[ "semi2" ] = %exposed_crouch_shoot_semi2;
	self.a.array[ "semi3" ] = %exposed_crouch_shoot_semi3;
	self.a.array[ "semi4" ] = %exposed_crouch_shoot_semi4;
	self.a.array[ "semi5" ] = %exposed_crouch_shoot_semi5;

	self.a.array[ "fire" ] 		= %exposed_crouch_shoot_auto_v2;
	self.a.array[ "single" ] 	= [ %exposed_crouch_shoot_semi1 ];
	self.a.array[ "reload" ] 	= [ %exposed_crouch_reload ];

	self.deathanim 				= self.ridingvehicle.deathanims[ self.vehicle_position - 2 ]; // - 2 due to pilot/copilot
}

event_thread()
{
	self endon( "death" );
	self endon( "killanimscript" );

	vehicle = self.ridingvehicle;

	for ( ;; )
	{
		vehicle waittill( "start_event", output );
	}
}

shooter_shooting()
{
	self endon( "death" );
	self endon( "killanimscript" );

	leanblendtime = .05;

	for ( ;; )
	{
		wait( 0.05 );
		
		if ( !IsDefined( self.current_event ) )
		{
			continue;
		}
		
		if ( self.current_event != "none" )
		{
			self waittill( "event_finished" );
			continue;
		}

		if ( animscripts\combat_utility::NeedToReload( 0 ) )
		{
			self animscripts\combat_utility::endFireAndAnimIdleThread();

			reloadAnim = animArrayPickRandom( "reload" );

			self animscripts\combat::doReloadAnim( reloadAnim, false );// this will return at the time when we should start aiming
			self notify( "abort_reload" );// make sure threads that doReloadAnim() started finish

			self thread shooter_tracking();
			continue;
		}

		shoot_behavior();
		
		if ( IsPlayer( self.enemy ) )
			self UpdatePlayerSightAccuracy();
	}
}

shoot_behavior()
{
	self thread animscripts\shoot_behavior::decideWhatAndHowToShoot( "normal" );
	self animscripts\combat_utility::shootUntilShootBehaviorChange();
}

shooter_tracking()
{
	self endon( "death" );
	self endon( "killanimscript" );
	self notify( "stop tracking" );
	self endon( "stop tracking" );

/#
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = thisthread;
	self.trackLoopThreadType = "shooter_trackthread";
#/

	transTime = 0.2;
	self clearAnim( %root, transTime );
	self SetAnimKnob( self.a.array[ "idle" ], 1, 0 );

	// setupAim
	self SetAnimKnobLimited( animarray( "straight_level" ), 1, transTime );
	self SetAnimKnobLimited( animArray( "add_aim_up" ), 1, transTime );
	self SetAnimKnobLimited( animArray( "add_aim_down" ), 1, transTime );
	self SetAnimKnobLimited( animArray( "add_aim_left" ), 1, transTime );
	self SetAnimKnobLimited( animArray( "add_aim_right" ), 1, transTime );

	aim2 = %aas72x_aim_2;
	aim4 = %aas72x_aim_4;
	aim6 = %aas72x_aim_6;
	aim8 = %aas72x_aim_8;

	animscripts\track::trackLoop( aim2, aim4, aim6, aim8 );
}

//---------------------------------------------------------
// PLAYER SECTION
//---------------------------------------------------------

#using_animtree( "vehicles" );
// self is a player
chopper_lean( chopper )
{
	self endon( "stop_player_lean" );

//	chopper thread maps\_debug::drawtagforever( "tag_rider" );

	view_frac = 1.0;
	arc_right = 110;
	arc_left = 110;
	arc_top = 30;
	arc_bottom = 60;
	self PlayerLinkToDelta( chopper, "tag_rider", view_frac, arc_right, arc_left, arc_top, arc_bottom );

	curr_anim = %vegas_player_littlebird_lean_out_b;
	prev_anim = %vegas_player_littlebird_lean_in_b;
	
	anim_fraction = 0;
	prev_anim_fraction = 0;
	max_yaw = 110;
	prev_percent = 0;
	while( 1 )
	{
		wait( 0.05 );

		yaw = self.angles[ 1 ] - chopper.angles[ 1 ] - 90;
		yaw = AngleClamp180( yaw );
		percent = abs( yaw / max_yaw );
		percent = min( percent, 1 );

		if ( abs( prev_percent - percent ) < 0.001 )
		{
			chopper SetAnim( curr_anim, 1, 0.2, 0 );
			continue;
		}

		if ( percent > prev_percent )
		{
			curr_anim = %vegas_player_littlebird_lean_out_b;
			anim_fraction = percent;
		}
		else
		{
			curr_anim = %vegas_player_littlebird_lean_in_b;
			anim_fraction = 1 - percent;
		}

		if ( curr_anim != prev_anim )
		{
			chopper ClearAnim( prev_anim, 0 );
		}

		//println( anim_fraction + " ", curr_anim );
		chopper SetAnim( curr_anim, 1, 0, 0.5 );
		chopper SetAnimTime( curr_anim, anim_fraction );
		prev_anim = curr_anim;
		prev_percent = percent;
		prev_anim_fraction = anim_fraction;
	}
}

stop_chopper_lean()
{
	self notify( "stop_player_lean" );
}