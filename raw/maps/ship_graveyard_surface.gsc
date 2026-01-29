#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

#include maps\ship_graveyard_util;

main()
{
	flag_init( "lightning_bloom" );
	flag_init( "lightning_flashing" );

	SetSavedDvar( "sm_sunsamplesizeNear" , 1 );
	setsaveddvar( "r_specularColorScale", 5.5 ); //  We need to set it up so it goes dry in 
	thread maps\_weather::rainInit( "light" );
	thread fade_out( 0 );
	level.player DisableWeapons();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowJump( false );
	level.player player_speed_percent( 100, 0.1 );
	level.player FreezeControls( true );
	
	level.baker set_generic_idle_anim( "surface_swim_idle" );
	//level.player_view_pitch_down = getDvar( "player_view_pitch_down" );
	level.player maps\_underwater::player_scuba_mask();
	//setSavedDvar( "player_view_pitch_down", -10 );
	level.player EnableSlowAim( 0.5, 0.5 );
	brush = get_target_ent( "surface_player_clip" );
	brush.origin -= (0,0,0);
//	thread bobbing_ally( level.baker );
//	thread bobbing_player_brush( brush, 0.5 );	
//	
	bobbers = getentarray( "bobbing_object", "targetname" );
	array_thread( bobbers, ::pitch_and_roll );
	
//	level.ground_ref_ent = spawn_Tag_origin();
//	level.player PlayerSetGroundReferenceEnt( level.ground_ref_ent );
//	level.ground_ref_ent.script_max_left_angle = 3;
//	level.ground_ref_ent.script_duration = 1;
//	level.ground_ref_ent thread pitch_and_roll();
	
	boat = get_target_ent( "start_fishing_boat" );
	boat.script_max_left_angle = 8;
	boat.script_duration = 4;
	boat thread pitch_and_roll();
	
	flag_set( "fx_screen_raindrops" );
	//thread maps\_weather::lightning( ::lightning_normal, ::lightning_flash );
	
	level.player thread vision_set_fog_changes( "shpg_start_abovewater", 0 );
	
	wait( 1 );
	
	//Hesh: Neptune, this is Trident Two-One.  We're feet wet.  I pass ATLAS.
	smart_radio_dialogue( "shipg_hsh_neptunethisistrident" );
	wait( 0.6 );
	thread smart_radio_dialogue( "shipg_pri_copytwoonehowsit" );
	wait( 2 ); // ideally length of the line - 0.5
	
	level.player player_speed_percent( 10, 0.1 );
	thread fx_screen_raindrops();

	level.rainLevel = 10;
	//thread maps\_weather::thunder();
	thread thunder_big_sound_moving();
	thread water_drops_on_ocean();
	wait( 0.7 );
	lcs = spawn_vehicle_from_targetname_and_Drive( "lcs_abovewater" );
	lcs thread spawn_tag_fx( "glow_beam_lcs_large", "tag_origin", (473, -0, 577), (0,0,0) );	
	lcs Vehicle_TurnEngineOff();	
	lcs thread play_sound_on_entity("scn_shipg_lcs_approach");
		
	thread intro_anim_scene();
	
	fade_out( 0.25, "white" );
	fade_in( 0.05 );
	//thread maps\_weather::lightningFlash( ::lightning_normal, ::lightning_flash, 2 );
	thread fade_in( 0.35, "white" );
//	level.player delaythread( 0, ::vision_set_fog_changes, "shpg_start_abovewater", 0.5 );
	//thread maps\_weather::rainHard( 0.05 );
	level.player SetPlayerAngles((0, 70, 0));
	
	wait( 0.1 );
	delayThread( 0.5, ::flag_set, "lightning_bloom" );
	level.player FreezeControls( false );

	heli = spawn_vehicles_from_Targetname_and_drive( "above_water_hind" );
	heli[0] Vehicle_TurnEngineOff();
	heli[0] thread play_sound_on_entity("scn_shipg_intro_chopper_by");
	
	thread spotlight_hind();
	level.baker disable_pain();
	level.player EnableHealthShield( false );
	level.player thread blur_death();
	wait( 1.5 );
	//Hesh: Doing fine.  Just a little cold out…
	smart_radio_dialogue( "shipg_hsh_doingfinejusta" );
	wait( 1 );
	//Price: Heh…can you confirm a visual on the target?
	smart_radio_dialogue( "shipg_pri_hehcanyouconfirma" );
	//wait( 0.5 );
	//smart_radio_dialogue( "shipg_hsh_rogerthat" );
	wait( 1.5 );
	
	//Hesh: We have eyes on the target.  Beginning our approach.
	smart_radio_dialogue( "shipg_hsh_wehaveeyeson" );
	wait( 1 );
	//Hesh: You ready, bro?
	smart_radio_dialogue( "shipg_hsh_youreadybro" );
	wait( 1 );
	//Hesh: Let's move.
	thread smart_radio_dialogue( "shipg_hsh_letsmove" );
	
	level.player endon( "death" );
	
	wait( 0.2 );
	//thread baker_dive();
	thread thunder_big_sound_moving();	
	
	trigger = level.player spawn_tag_origin();
	trigger linkTo( level.player );
	trigger MakeUsable();
	trigger setHintString( &"SHIP_GRAVEYARD_HINT_DIVE" );
	trigger trigger_on();
	trigger waittill( "trigger" );
	level notify ("player_dove");
	trigger delete();

	level.player FreezeControls( true );
	level.player EnableInvulnerability();
	
	wait (2.5);
//	level.ground_ref_ent notify( "stop_bob" );
//	level.ground_ref_ent rotateTo( (0,0,0), 0.25 );
	brush notify( "stop_bob" );
	time = 0.25; 
	level.player SetWaterSheeting( 1, 1.0 );
	PlayFX( getfx( "abv_large_water_impact_close" ), level.player.origin ); // Jesse: This was "abv_large_water_impact_close_wave" and changed 3/25
	brush moveZ( 10, time, 0, time*0.4 );
//	brush waittill( "movedone" );
	wait( time - 0.05 );
	time = 0.5;
	brush moveZ( -25, time, 0, time );
	thread maps\_weather::rainNone( 0.05 );
	flag_clear( "_weather_lightning_enabled" );
	level.player thread play_sound_on_entity( "scn_player_dive_in" );
	fade_out( 0.25, "white" );
	wait( 0.05 ); // Fixes slight pop from white shader not getting fully opaque
	level.player PlayerSetGroundReferenceEnt( undefined );
	
	flag_clear( "fx_screen_raindrops" );
	level.player.health = 100;
	level.screenRain delete();
	lightning_normal();
	level notify("stop_bob");
	level notify("cleanup_bob");
	level.player player_speed_percent( 100, 0.1 );
	level.player DisableSlowAim();
	//setSavedDvar( "player_view_pitch_down", level.player_view_pitch_down );
	lcs delete();
	level.baker clear_generic_idle_anim();
	level.player maps\_underwater::player_scuba_mask_disable( true );
	maps\ship_graveyard::start_tutorial();
	level.player DisableInvulnerability();
	level.player FreezeControls( false );
	level.player AllowJump( true );
	foreach ( h in heli )
		h delete();
	level.heli delete();
	level.baker enable_pain();
	level.player EnableHealthShield( true );
	setsaveddvar( "r_specularColorScale", 2.5 ); //  We need to set it up so it goes dry in 
	resetSunLight();
    resetSunDirection();
}


intro_anim_scene()
{
	ent = get_target_ent("start_boat");
	boat = get_target_ent("start_boat_model");
	
	boat.origin = ent.origin;
	boat.angles = ent.angles;
	boat.animname = "intro_boat";
	boat setanimtree();

	// player anim
	level.player_rig = maps\_player_rig::get_player_rig();
	level.player_rig.origin = boat gettagorigin("tag_guy1");
	level.player_rig.angles = boat gettagangles("tag_guy1");
	
	level.player_rig linkTo( boat, "tag_guy1", (0,0,0), (0,0,0) );
	
	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, 16, 29, 45, 9, 1 );	
	
	// the boat anim
	ent thread anim_loop_solo(boat, "rocking", "stop_rocking");

	// baker anim
	level.baker linkTo( boat, "tag_guy1" );
	boat thread anim_single_solo(level.baker, "on_boat_intro", "tag_guy1");
	level.baker thread play_sound_on_entity ("scn_npc_roll_off");
	boat thread intro_baker_unlink(boat);
	
	boat thread anim_loop_solo(level.player_rig, "idle_above_water", "end_idle", "tag_guy1");

	boat thread boat_crashing_waves();
	
	level waittill ("player_dove");

	level.player thread play_sound_on_entity ("scn_player_roll_off");
		
	level.player_rig notify ("end_idle");
	boat anim_single_solo(level.player_rig, "roll_into_water", "tag_guy1");
}

thunder_big_sound_moving()
{
	wait ( 1 );
	ent = spawn( "script_origin", ( 0, 0, 0 ) );
	ent.origin = level.player.origin + ( -200, 500, 300 );
	//ent linkto( level.player );
	ent playsound( "elm_thunder_distant", "sounddone" );
	ent thread play_sound_on_entity( "elm_thunder_strike" );
	wait ( 0.4 );
	//now start moving the ent around the player to give the thunder a sense of rolling movement
	ent moveto (level.player.origin + (1200, -800, 300), 5);	
	ent waittill( "sounddone" );
	ent delete();	
}

boat_crashing_waves()
{
	level endon ("start_swim");
	fwd = AnglesToForward( self.angles + (0,-25,0));
	fwd = fwd * 400;
	
	fwd = fwd + (0,0,20);
	
	//thread draw_line(level.player.origin, self.origin + fwd, 1,1,1);
	while (1)
	{
		PlayFX(getfx("boat_crashing_waves"), self.origin + fwd);
		// play sound here
		self play_sound_on_entity("scn_wave_crash_boat");
		wait randomfloatrange(3,6);
	}
}

intro_baker_unlink(boat)
{
	level.baker endon ("kill surface unlink");
		
	boat waittill ("on_boat_intro");
	level.baker unlink();
}

baker_dive()
{
	org = level.baker spawn_tag_origin();
	level.baker linkTo( org );
	org moveZ( 8, 0.5, 0.1, 0.2 );
	org waittill( "movedone" );
	level notify( "stop_ripple" );
	org moveZ( -50, 1, 0.3, 0 );
	flag_wait( "start_swim" );
	org delete();
}

blur_death()
{
	level endon( "start_tutorial" );
	self waittill( "death" );
	SetBlur( 30, 1 );
}

spotlight_hind()
{
	level.heli = spawn_vehicle_from_targetname_and_drive( "spotlight_hind" );
	level.heli Vehicle_TurnEngineOff();
	level.heli thread play_sound_on_entity("scn_shipg_chopper_in_kill");
	level.heli thread spotlight_think();
	level.heli endon( "death" );
	level.heli waittill( "reached_dynamic_path_end" );
	
	level.heli notify( "new_spotlight_target" );
	level.heli SetTurretTargetEnt( level.player );
	flag_clear( "lightning_bloom" );
//	level.player thread vision_set_fog_changes( "shpg_start_abovewater_bloom", 3 );
	wait( 1 );
	while( 1 )
	{
		level.heli FireWeapon();
		wait( RandomFloatRange( 0.1, 0.4 ) );
	}
}

spotlight_think()
{
	target_ent_center = spawn_tag_origin();
	target_ent_left = spawn_tag_origin();
	target_ent_right = spawn_tag_origin();
	fwd = AnglesToForward( self.angles );
	rgt = AnglesToRight( self.angles );
	
	org = self GetTagOrigin( "TAG_BARREL" );
	target_ent_center.origin = org + (fwd*50) - (0,0,25);
	target_ent_left.origin = org + (fwd*50) - (0,0,25) - (15*rgt);
	target_ent_right.origin = org + (fwd*50) - (0,0,25) + (15*rgt);
	
	target_ent_center linkTo( self );
	target_ent_left linkTo( self );
	target_ent_right linkTo( self );
	PlayFXOnTAG( getfx( "abv_spotlight" ), self, "TAG_BARREL" );
	
	targets = [ target_ent_center, target_ent_left, target_ent_right ];
	self thread spotlight_loop( targets );
	
	self waittill( "death" );
	
	foreach( t in targets )
		t delete();
}

spotlight_loop( targets )
{
	self endon( "new_spotlight_target" );
	self endon( "death" );
	while( 1 )
	{
		tgt = random( targets );
		self setTurretTargetEnt( tgt );
		wait( RandomFloatRange( 0.5,1.5 ) );
	}
}

bobbing_jitter_cleanup( bob )
{
	level waittill( "cleanup_bob" );
	bob.bob_ref delete();
	bob delete();
}

bobbing_updown( bob )
{
	bob_ref = bob.bob_ref;
	if (!isdefined(bob_ref))
		bob_ref = spawn_tag_origin();
	bob_ref.origin = bob.origin;
	bob_ref.angles = bob.angles;
	bob.bob_ref = bob_ref;
	bob.start_origin = bob.origin;
	
	level endon("stop_bob");
	thread bobbing_jitter_cleanup( bob );

	minZrange = -4.0;
	maxZrange = 4.0;
	minTime = 0.5;
	maxTime = 2.5;
	while (true)
	{
		x = 0;
		y = 0;
		z = RandomFloatRange( minZrange, maxZrange );
		time = RandomFloatRange( minTime, maxTime );
		bob.bob_ref moveto( bob.start_origin + (x, y, z), time, time/4.0, time/4.0 );
		wait time;
	}
}

bobbing_ripple( bobbing_obj )
{
	level endon("stop_bob");
	
	bobbing_obj endon("death");
	zoff = 52;
	ripple_obj = spawn_tag_origin();
	ripple_obj.origin = self.origin;
	ripple_obj.angles = ( -90, 0, 0 );
	ripple_obj thread delete_on_notify( "stop_bob" );
	ripple_obj thread delete_on_notify( "stop_ripple" );
	ripple_obj endon( "death" );
	curtime = 0;
	time = 0;
	while (true)
	{
		// the ripple will be centered on the actor's x,y and not be displaced with z jitter, so use ref_origin[2] for it
		ripple_obj.origin = (self.origin[0], self.origin[1], bobbing_obj.ref_origin[2] + zoff);
	/#
//	draw_point( ripple_obj.origin, 24, (1,1,1) );
	#/
		if (curtime >= time)
		{
			playfxontag( getfx("abv_ocean_ripple"), ripple_obj, "tag_origin" );
			time = RandomFloatRange( 0.25,0.5 );
			curtime = 0;
		}
		else
			curtime += 0.05;
		wait 0.05;
	}
}

bobbing_object( bobscale )
{
	self thread delete_on_notify( "stop_bob" );
	self endon("death");
	self.start_origin = self.origin;
	self.ref_origin = self.origin;
	self childthread pitch_and_roll();
	while (true)
	{
		origin = self.origin;	// use the actor's x,y to determine displacement
		displacement = maps\_ocean::GetDisplacementForVertex( level.oceantextures["water_patch"], origin );
		// get the non-jittered origin
		self.ref_origin = self.start_origin + ( 0, 0, displacement );
		// add the jitter to the ref_origin
		self.origin = self.ref_origin;
		wait 0.05;
	}
}

pitch_and_roll()
{
	self endon( "stop_bob" );
	self endon( "death" );
	node = self;
	old = (0, node.angles[1], 0);
	
	maxdist = 20;
	if ( isdefined( node.script_max_left_angle ) )
	{
		maxdist = node.script_max_left_angle;
	}
	mindist = maxdist * 0.5;
	
	maxtime = 4;
	if ( isdefined( node.script_duration ) )
	{
		maxtime = node.script_duration;
	}
	mintime = maxtime * 0.5;
	
	node = undefined;
	
	while( 1 )
	{
		dist = ( RandomFloatRange( mindist, maxdist ), 0, RandomFloatRange( mindist, maxdist ) );
		time = RandomFloatRange( mintime,maxtime );
		
		self rotateTo( old + dist, time, time*0.2, time*0.2 );
		//wait( RandomFloatRange( time*0.5, time ) );
		self waittill( "rotatedone" );
		self rotateTo( old - dist, time, time*0.2, time*0.2 );
		//wait( RandomFloatRange( time*0.5, time ) );
		self waittill( "rotatedone" );
	}
}

bobbing_actor( bobbing_obj, bobscale )
{
	// self is the actor that is being bobbed
	// bobbing_obj is the reference node for the animation, so it's Z is relative to it's original Z
	// bobbing_obj will be tracking the surface z where self is in x,y (though it isn't necessarily at x,y)
	// bobbing_obj.bob_ref is jittered (up/down or all around) using movetos and is used to offset bobbing_obj
	// bobbing_obj.ref_origin is the origin displaced in z without any jittered
	// bobbing_obj.start_origin is the initial origin
	level endon("stop_bob");
	
	bobbing_obj endon("death");
	bobbing_obj.start_origin = bobbing_obj.origin;
	bobbing_obj.ref_origin = bobbing_obj.origin;
	bobbing_obj thread delete_on_notify( "stop_bob" );
	
//	thread bobbing_updown( bobbing_obj );
	thread bobbing_ripple( bobbing_obj );

	while (true)
	{
		origin = self.origin;	// use the actor's x,y to determine displacement
		displacement = maps\_ocean::GetDisplacementForVertex( level.oceantextures["water_patch"], origin );
		// get the non-jittered origin
		bobbing_obj.ref_origin = bobbing_obj.start_origin + ( 0, 0, displacement*bobscale );
		// add the jitter to the ref_origin
		bobbing_obj.origin = bobbing_obj.ref_origin + (0,0,16);
		wait 0.05;
	}
}

bobbing_player_brush( brush, bobscale )
{
	// self is the actor that is being bobbed
	// bobbing_obj is the reference node for the animation, so it's Z is relative to it's original Z
	// bobbing_obj will be tracking the surface z where self is in x,y (though it isn't necessarily at x,y)
	// bobbing_obj.bob_ref is jittered (up/down or all around) using movetos and is used to offset bobbing_obj
	// bobbing_obj.ref_origin is the origin displaced in z without any jittered
	// bobbing_obj.start_origin is the initial origin
	level endon("stop_bob");
	brush endon("death");
	brush endon("stop_bob");
	
	brush.start_origin = brush.origin;
	brush.ref_origin = brush.origin;
	if (bobscale <= 0)
	{
		level.player thread bobbing_ripple( brush );
	}
	while (true)
	{
		origin = level.player.origin;	// use the actor's x,y to determine displacement
		displacement = maps\_ocean::GetDisplacementForVertex( level.oceantextures["water_patch"], origin );
		// get the non-jittered origin
		brush.ref_origin = brush.start_origin + ( 0, 0, displacement * bobscale );
		// add the jitter to the ref_origin
		brush.origin = brush.ref_origin + (0,0,12);
		wait 0.05;
	}
}

bobbing_ally( ally )
{
	bobbing_obj = spawn_tag_origin();
	bobbing_obj.origin = ally.origin - (0,0,0);
	bobbing_obj.angles = ally.angles;
	ally show();
	if ( isAI( ally ) )
		ally ForceTeleport( bobbing_obj.origin, bobbing_obj.angles );
	ally linkto( bobbing_obj, "tag_origin" );
	ally thread bobbing_actor( bobbing_obj, 0.5 );
}

/* LIGHTNING */

lightning_flash( dir )
{
	level notify( "emp_lighting_flash" );
	level endon( "emp_lighting_flash" );
	
	if ( level.createFX_enabled )
		return;

//	if ( flag( "lightning_bloom" ) )
//		level.player thread vision_set_fog_changes( "shpg_start_abovewater_bloom", 4 );
	
   	num = randomintrange( 1, 4 );
	
	if( !isdefined( dir ) )
		dir = ( -20, 60, 0 );
	
	flag_set( "lightning_flashing" );
	
    for ( i = 0; i < num; i++ )
    {	
    	type = randomint( 3 );
	    switch( type )
	    {
	    	case 0:
	    		wait( 0.05 );
						   			    
			    setSunLight( 1, 1, 1.2 );	
//			    parking_lightning( 1.2 );    
			    
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
//			    parking_lightning( 2.25 );

	    		break;

	    	case 1:{
	    		wait( 0.05 );
			   
			    setSunLight( 1, 1, 1.2 );	
//			   	parking_lightning( 1.2 );	    
			     
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
//			    parking_lightning( 2.25 );

			   	wait( 0.05 );

			    setSunLight( 3, 3, 3.7 );
//			    parking_lightning( 3 );

	    		}break;

	    	case 2:{
	    		wait( 0.05 );
			   
			    setSunLight( 1, 1, 1.2 );
//			    parking_lightning( 1.2 );	
			     
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
//			    parking_lightning( 2.25 );

			   	wait( 0.05 );

			    setSunLight( 3, 3, 3.7 );
//			    parking_lightning( 3 );
			    
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
//			    parking_lightning( 2.25 );

	    		}break;
	    }
	    
	    wait randomfloatrange( 0.05, 0.1 );
   		lightning_normal();
    }
    flag_clear( "lightning_flashing" );
    
    lightning_normal();
}

lightning_normal()
{
//	if ( flag( "lightning_bloom" ) && !flag( "lightning_flashing" ) )
//		level.player thread vision_set_fog_changes( "shpg_start_abovewater", 2.5 );
    resetSunLight();
    dir = AnglesToForward( (-38.63, -76, -8 ) );
    setSunDirection( dir );
 //   parking_lightning_reset();
 	//(0.775827, -0.0914133, 0.624289)
}

fx_screen_raindrops()
{
	level endon ("stop screen rain");
	
	level.screenRain = spawn( "script_model", ( 0, 0, 0 ) );
	level.screenRain setmodel( "tag_origin" );
	level.screenRain.origin = level.player.origin;
	level.screenRain LinkToPlayerView (level.player, "tag_origin", (0,0,0), (0,0,0), true );

	level.screenRain endon( "death" );
	
	for( ;; )
	{

		if ( flag( "fx_screen_raindrops" ) || flag( "fx_player_watersheeting" ) )
		{
			sheeted = false;
			upAngle = level.player GetPlayerAngles();
	
			if ( flag( "fx_player_watersheeting" ) && upAngle[ 0 ] < 25 )
			{
				level.player SetWaterSheeting( 1, 1.0 );
				sheeted = true;
			}
			
			if ( flag( "fx_screen_raindrops" ) )
			{
				if ( !sheeted && upAngle[ 0 ] < -55 && RandomInt( 100 ) < 20 )
				{
					level.player SetWaterSheeting( 1, 1.0 );
				}
				
				if ( upAngle[ 0 ] < -40 )
				{
					PlayFXOnTag(  level._effect[ "abv_raindrops_screen_20" ], level.screenRain, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < -25 )
				{
					PlayFXOnTag(  level._effect[ "abv_raindrops_screen_10" ], level.screenRain, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < 25 )
				{
					PlayFXOnTag(  level._effect[ "abv_raindrops_screen_5" ], level.screenRain, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < 40 )
				{
					PlayFXOnTag(  level._effect[ "abv_raindrops_screen_3" ], level.screenRain, "tag_origin" );
				}
			}
		}
		
		wait 0.5;
	}
}

water_drops_on_ocean()
{
	level endon( "start_swim" );
	fx = getfx( "abv_water_splash" );
	ht = 35;
	while( 1 )
	{
		times = RandomFloatRange( 7, 10 );
		for( i=0; i<times; i++ )
		{
			side = [-1, 1];
			randomSide1 = random( side );
			randomSide2 = random( side );
			origin = level.player.origin + ( RandomFloatRange(128, 500)*randomSide1, RandomFloatRange(128, 500)*randomSide2, ht );
			displacement = maps\_ocean::GetDisplacementForVertex( level.oceantextures["water_patch"], origin );		
			PlayFX( fx, origin + (0,0,displacement) );
			origin = level.player.origin + ( RandomFloatRange(16, 128)*randomSide2, RandomFloatRange(16, 128)*randomSide1, ht );
			displacement = maps\_ocean::GetDisplacementForVertex( level.oceantextures["water_patch"], origin );		
			PlayFX( fx, origin + (0,0,displacement) );
		}

		wait( 0.05 );
	}
}
