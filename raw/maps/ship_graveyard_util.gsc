#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

player_panic_bubbles()
{
	if ( isalive( self ) )
	if ( isdefined( self.playerFxOrg ) )
		PlayFXOnTag( getfx( "scuba_bubbles_panic" ), self.playerFxOrg, "tag_origin" );
}

keep_player_below_surface()
{
	level endon ("end_swimming");
	flag_wait( "start_swim" );
	
	vec = 0.0;
	increment = GetDvarFloat( "player_swimVerticalSpeed", 95.0 ) * 2.5;
	vecmax = increment * 25;
	
	while( 1 )
	{
		if ( level.water_level_z - level.player.origin[2] < 128 )
		{
			if ( vec > -1*vecmax )
			{
				level.water_current -= (0,0,increment);
				string = level.water_current[0] + " " + level.water_current[1] + " " + level.water_current[2];
				setSavedDvar( "player_swimWaterCurrent", string );
				vec -= increment;
			}
		}
		else if ( vec < 0 )
		{
			level.water_current += (0,0,increment);
			vec += increment;
			if ( vec > -0.01 )
			{
				level.water_current -= (0,0,vec);
				vec = 0;
			}
			string = level.water_current[0] + " " + level.water_current[1] + " " + level.water_current[2];
			setSavedDvar( "player_swimWaterCurrent", string );
		}
		
		wait( 0.05 );
	}
}

read_parameters()
{
	if ( isdefined( self.script_moveplaybackrate ) )
	{
		self.movePlaybackRate = self.script_moveplaybackrate;
		self.moveTransitionRate = self.moveplaybackrate;
	}
}

teleport_to_target()
{
	org = self get_target_ent();
	if ( !isdefined( org.angles ) )
		org.angles = self.angles;
	self ForceTeleport( org.origin, org.angles );
	if ( isdefined( org.target ) )
	{
		org = org get_Target_ent();
		if ( isdefined( org.script_animation ) )
			self maps\ship_graveyard_stealth::stealth_idle( org, org.script_animation );
		else if ( isdefined( org.script_idlereach ) )
			self stealth_idle_reach( org );
		else
			self follow_path_and_animate( org, 0 );
	}
}

stealth_idle_reach( path )
{
	lastNode = path get_last_ent_in_chain( "struct" );
	self.goalradius = 128;
	self.goalheight = 128;
	
	self follow_path_and_animate( path, 0 );
	self maps\ship_graveyard_stealth::stealth_idle( lastNode, lastNode.script_animation );
}

boat_shoot_entity( ent, levelendon )
{
	if ( isdefined( levelendon ) )
		level endon( levelendon );
	self endon( "death" );
	self endon( "stop_shooting" );
	
	
	while( 1 )
	{
		start_pos = ( self.origin[0], self.origin[1], level.water_level_z );
		
		fwd = 64*AnglesToForward( ent.angles );
		
		if ( isPlayer( ent ) )
		{
			end_pos = ( ent getEye() + fwd );
		}
		else
		{
			end_pos = ( ent.origin + fwd );
		}
		
		rightside = AnglesToRight( self.angles );
		vec = VectorDot( rightside, end_pos - self.origin );
		
		if ( vec < 0 )
		{
			angles = random( [ 70, 90, 110 ] );
		}
		else
		{
			angles = random( [ -70, -90, -110 ] );
		}
		
		dist = 256;
		start_pos += AnglesToForward( (0, angles, 0 ) )*dist;
		
		times = RandomIntRange( 5, 20 );
		
		for ( i=0; i<times; i++ )
		{
			pos1 = start_pos + ( RandomFloatRange( -30, 30 ), RandomFloatRange( -30, 30 ), 0 );
			pos2 = end_pos + RandomVectorRange( -24, 24 );
			angle = VectorToAngles( pos2-pos1 );
			up = AnglesToUp( angle );
			a = (90,0,0);
			PlayFX( getfx( "underwater_surface_splash_bullet" ), (pos1[0], pos1[1], level.water_level_z - 1), AnglesToForward( a ), AnglesToUp( a ) );
			//PlayFX( getfx( "unerwater_bullet" ), pos1, pos2-pos1, up );
			MagicBullet( "aps_underwater", pos1 , pos2 );
			wait( RandomFloatRange( 0.3, 0.4 ) );
		}
		
		wait( RandomFloatRange( 2, 6 ) );
	}
}

underwater_setup()
{
	level.f_min = [];
	level.f_max = [];
	level.player.breathing_overlay = [];
	thread overlay_manage( "gasmask_overlay", -98 );
	thread overlay_manage( "halo_overlay_scuba_steam",-100 );
	level.f_min[ "halo_overlay_scuba_steam" ] = 0.35;
	level.f_max[ "halo_overlay_scuba_steam" ] = 0.95;
	level.player.breathing_overlay[ "halo_overlay_scuba_steam" ].alpha = 1;
		
	flag_wait( "start_swim" );

	level.baker thread maps\_swim_ai::enable_swim();
	PlayFXOntag( getfx( "silt_ground_kickup_runner" ), level.baker, "tag_origin" );
	
	trash = GetEntArray( "marker_deleteme", "targetname" );
	array_call( trash, ::Delete );
	
	level.player maps\_swim_player::enable_player_swim();
	level.player thread maps\ship_graveyard_fx::water_particulates();
	
 	SetSavedDvar( "glass_angular_vel", "1 5" );
	SetSavedDvar( "glass_linear_vel"	 , "20 40" );
	SetSavedDvar( "glass_fall_gravity"	 , 25 );
	SetSavedDvar( "glass_simple_duration", 20000 );
	SetSavedDvar( "bg_viewKickMax"		 , 20 );
	SetSavedDvar( "g_gravity"			 , 30 );
	SetSavedDvar( "sm_sunshadowscale"	 , 0.65 );
	SetSavedDvar( "sm_sunsamplesizeNear" , 0.25 );
	SetSavedDvar( "actionSlotsHide"		 , 1 );

	SetSavedDvar( "player_swimVerticalSpeed", 80 );

//	// distortion	
//	level.distOrg = spawn( "script_model", level.player.origin );
//	level.distOrg setModel( "tag_origin" );
//	level.distOrg LinkToPlayerView( level.player, "tag_origin", ( 150, 0, 0 ), ( 0, 0, 0 ), true );
	PLayFXontag( getfx( "vfx_scrnfx_water_distortion" ), level.player.scubaMask_distortion, "tag_origin" );
	
	//thread sun_manage();
	thread keep_player_below_surface();
	thread baker_killfirms();
	level.player thread shark_heartbeat();
	thread track_shark_flag();
	thread track_shark_warning();
	level.player thread player_get_closest_node();
	
	maps\_art::dof_set_base( 1, 200, 5, 700, 2500, 3, 0.0 );
}

track_shark_warning()
{
	level endon( "shark_eating_player" );
	flag_wait_either( "shark_warn_player", "baker_warn_player" );
	smart_radio_dialogue( "shipg_bkr_openwatersoutthere" );
	wait( 10 );
	
	while( 1 )
	{
		flag_wait( "shark_warn_player" );
		smart_radio_dialogue( "shipg_bkr_wandering" );
		wait( 10 );
		if ( flag( "shark_warn_player" ) )
			childthread shark_eat_wandering_player();
	}
}

shark_eat_wandering_player()
{
	level endon( "shark_warn_player" );
	wait( 5 );
	flag_set( "shark_force_eat_player" );
}

track_shark_flag()
{
	wait( 0.1 );
	flag_clear( "shark_force_eat_player" );
	wait( 0.1 );
	flag_Wait( "shark_force_eat_player" );
	if ( level.deadly_sharks.size > 0 )
	{
		wait( 0.5 );
		level.deadly_sharks = array_removeUndefined( level.deadly_sharks );
		sharks = SortByDistance( level.deadly_sharks, level.player.origin );
		if ( Distance( sharks[0].origin, level.player.origin ) < 800 )
		{
			sharks[0] shark_kill_player();
			return;
		}
	}
	
	shark_kill_side();
}

shark_heartbeat()
{
	flag_init( "player_near_shark" );
	level.heartbeat_delay = 2.25;
	thread track_sharks();
	
	while( 1 )
	{
		if ( ( flag( "player_near_shark" ) || flag( "shark_warn_player" ) )
			  && ( !flag( "no_shark_heartbeat" ) || flag( "shark_eating_player" ) ) )
		{
			level.player thread play_sound_on_entity( "shipg_shark_warning" );
			level.player delayCall( 0.2, ::PlayRumbleOnEntity, "damage_light" ); //replace this with heartbeat rumble
//			level.player thread heartbeat_rumble();
			wait( level.heartbeat_delay );
		}
		wait( 0.05 );
	}
}

heartbeat_rumble()
{
	level.player PlayRumbleOnEntity( "heavy_3s" );
	wait( .1 );
	StopAllRumbles();
	wait( .05 );
	level.player PlayRumbleOnEntity( "light_1s" );
	wait( .1 );
	StopAllRumbles();
}

track_sharks()
{
	level.shark_heartbeat_distances = [ 400, 250, 200, 150 ];
	
	while( 1 )
	{
		level.deadly_sharks = array_removeundefined( level.deadly_sharks );
		level.deadly_sharks = SortByDistance( level.deadly_sharks, level.player.origin );
		flag_clear( "player_near_shark" );
		level.heartbeat_delay = 2.25;
		foreach ( shark in level.deadly_sharks )
		{
			dist = Min( Distance( level.player.origin, shark.origin ), Distance( level.player.origin, shark getTagOrigin( "j_jaw" ) ) );
			if ( dist < level.shark_heartbeat_distances[0] )
			{
				flag_set( "player_near_shark" );
				if ( dist < level.shark_heartbeat_distances[1] )
					level.heartbeat_delay = 1.25;
				if ( dist < level.shark_heartbeat_distances[2] )
					level.heartbeat_delay = 0.75;
				if ( dist < level.shark_heartbeat_distances[3] )
					level.heartbeat_delay = 0.5;
				wait( level.heartbeat_delay );
				break;
			}
		}
		wait( 0.05 );
	}
}

player_not_obstructed( dist )
{
	origin = level.player GetEye();
	angles = level.player GetPlayerAngles();
	fwd = AnglesToForward( angles );
	trace = BulletTrace( origin, origin + (fwd*dist), true, level.player );
	return trace[ "fraction" ] == 1;
}

overlay_manage( shader, sort )
{
	endon_str = "destory_" + shader;
	level endon( endon_str );
	
	level.f_min[ shader ] = 0.3;
	level.f_max[ shader ] = 0.65;
	
	overlay = create_client_overlay( shader, level.f_min[ shader ], level.player );
	overlay.foreground = false;
	overlay.sort = sort;
	overlay.alpha = level.f_min[ shader ];
	level.player.breathing_overlay[ shader ] = overlay;
	overlay thread delete_on_notify( endon_str );
	
	while( 1 )
	{
		level.player waittill( "scuba_breathe_sound_starting" );
		overlay fade_over_time( level.f_max[ shader ], 1.1 );
		wait( 0.7 );
		overlay fade_over_time( level.f_min[ shader ], 2.3 );
	}
	
}

sun_manage()
{
	level endon( "stop_sun_movement" );
	origVector = GetMapSunDirection();
	oldForward = origVector;
	time = 0;
	scale = 0.1;
	while( 1 )
	{
		d = RandomFloatRange( 0.2, 0.4 );
		forward = origVector + ( sin(time)*scale, cos(time)*scale, 0 );
		lerpSunDirection( oldForward, forward, d );
		time =  (time+1)%360;
		wait( d - 0.05 );
		oldForward = forward;
	}
}

salvage_cargo_setup()
{
	self.linked_ents = self get_linked_ents();
	self Hide();
	foreach ( ent in self.linked_ents )
	{
		ent linkTo( self );
		ent Hide();
	}
}

salvage_cargo_show()
{
	self Show();
	foreach( ent in self.linked_ents )
	{
		ent Show();
	}
}

salvage_cargo_rise( rate )
{
	if ( !isdefined( rate ) )
		rate = 40;
	self salvage_cargo_show();
	point = (self.origin[0], self.origin[1], level.water_level_z - 24);
	self moveTo_speed( point, rate, 0.15, 0.1 );
	
}

vehicle_setup()
{
	switch( self.classname )
	{
		case "script_vehicle_submarine_minisub":
			self thread sdv_setup();
			self thread notify_spotted_on_damage();
		break;
		
		case "script_vehicle_zodiac_underneath":
			playfxontag( getfx( "prop_wash" ), self, "TAG_PROPELLER_FX" );
			self thread zodiac_setup();
			break;
		case "script_vehicle_missile_boat_under":
			playfxontag( getfx( "prop_wash" ), self, "TAG_PROPELLER_FX_LEFT" );
			playfxontag( getfx( "prop_wash" ), self, "TAG_PROPELLER_FX_RIGHT" );
			self thread zodiac_setup();
			break;
	}
}

sdv_setup()
{
	self StartIgnoringSpotLight();
	self ent_flag_set( "moving" );
	self ent_flag_set( "lights" );
}

zodiac_setup()
{
	if( !isdefined( self.hasstarted ) || !self.hasstarted )
		self waittill_either( "newpath", "start_vehiclepath" );
	
	self godon();
	org = spawn_tag_origin();
	self.fx_tag = org;
	self.fx_tag linkTo( self, "tag_fx_water_splash2", (0,0,10), (0,0,180) );
	PlayFxOnTag( getfx( "boat_trail" ), self.fx_Tag, "tag_origin" );
	
	org = spawn_tag_origin();
	self.fx_tag2 = org;
	self.fx_tag2 linkTo( self, "tag_fx_water_splash1", (90,0,10), (0,0,180) );
	PlayFxOnTag( getfx( "boat_trail" ), self.fx_Tag2, "tag_origin" );
	
	org = spawn_tag_origin();
	self.wake_org = org;
	self.wake_org linkTo( self, "tag_fx_water_splash2", (0,0,10), (90,-90,180) );
	self thread zodiac_wake( self.wake_org );
	
	self waittill( "death" );
	self.fx_tag delete();
	self.fx_tag2 delete();
	self.wake_org delete();
}

zodiac_wake( fx_tag )
{
	self endon( "reached_end_node" );
	self endon( "death" );
	
	while( 1 )
	{
		PlayFxOnTag( getfx( "wake_med" ), fx_tag, "tag_origin" );
		wait( 0.2 );
	}
}

lcs_setup()
{
	org = spawn_tag_origin();
	self.wake_org = org;
	self.wake_org linkTo( self, "TAG_SPLASH_BACK", (0,0,10), (90,-90,180) );
	self thread lcs_wake( self.wake_org );
	
	self waittill_any("death", "reached_end_node");
	
	if (IsDefined(self.wake_org))
		self.wake_org delete();
}

lcs_wake( fx_tag )
{
	self endon( "reached_end_node" );
	self endon( "death" );
	
	while( 1 )
	{
		PlayFxOnTag( getfx( "wake_lg" ), fx_tag, "tag_origin" );
		wait( 0.2 );
	}
}

littoral_ship_lights()
{		
	self.target_points = [];
	
	lcs_lights_front();
	lcs_lights_back();
	
	thread add_lcs_target( (-174, 101, -47) );
}

lcs_lights_front()
{
	thread spawn_tag_fx( "circle_glow_w_beam_lg", "tag_origin", (-406, -160, -10), (90,0,0) );
	thread spawn_tag_fx( "circle_glow_w_beam_lg", "tag_origin", (-134, -160, -10), (90,0,0) );
	
	thread spawn_tag_fx( "circle_glow_w_beam_lg", "tag_origin", (-406, 160, -10), (90,0,0) );
	thread spawn_tag_fx( "circle_glow_w_beam_lg", "tag_origin", (-134, 160, -10), (90,0,0) );
}

lcs_lights_back()
{
	thread spawn_tag_fx( "circle_glow_w_beam_lg", "tag_origin", (-698, -160, -10), (90,0,0) );

	thread spawn_tag_fx( "circle_glow_w_beam_lg", "tag_origin", (-698, 160, -10), (90,0,0) );
}

add_lcs_target( origin_offset )
{
	org = self spawn_tag_origin();
	self.target_points = array_add( self.target_points, org );
	org linkTo( self, "tag_origin", origin_offset, (0,0,0) );
	self waittill( "death" );
	org delete();
}

add_headlamp()
{
	if ( self.team == "axis" && isAI( self ) && ( self.type != "dog" ) )
		self thread spawn_tag_fx( "vfx_headlamp_enemy_diver", "j_head_end", (0,-5,0), (0,-90,0) );
}

spawn_tag_fx( fx, tag, origin_offset, angle_offset )
{
	org = self spawn_tag_origin();
	org linkTo( self, tag, origin_offset, angle_offset );
	PlayFXOnTag( getfx( fx ), org, "tag_origin" );
	self waittill( "death" );
	
	if (!self isVehicle())
		org thread headlamp_death_blink( getfx( fx ) );
	else
		org delete();
}

headlamp_death_blink( fx )
{	
	PlayFXOnTag( getfx( "shpg_enm_death_bubbles_a" ), self, "tag_origin" );
	
	for (i = 0; i < RandomIntRange(5,12); i++)
	{
		fx2 = getfx( "rebreather_hose_bubbles" );
		PlayFXOnTag( fx2, self, "tag_origin" );
	
		PlayFXOnTag( fx, self, "tag_origin" );
		wait RandomFloatRange(0.05, 0.1);
		StopFXOnTag( fx, self, "tag_origin" );
		wait RandomFloatRange(0.05, 0.1);
	}

	for (i = 0; i < RandomIntRange(1,8); i++)
	{
		fx2 = getfx( "rebreather_hose_bubbles" );
		PlayFXOnTag( fx2, self, "tag_origin" );
		wait RandomFloatRange(0.1, 0.2);
	}

	self delete();
}

sdv_patrol_setup()
{
	self Vehicle_TurnEngineOff();
	self StartIgnoringSpotLight();
	self.light_tag thread spot_light( "spotlight_underwater", "spotlight_underwater_cheap", "tag_origin" );
	self waittill( "death" );
	if ( isdefined( level.last_spot_light ) )
	{
		if ( isdefined( level.last_spot_light.entity ) && level.last_spot_light.entity == self.light_tag )
		{
			wait( 0.05 );
			stop_last_spot_light();
		}
	}
}

sdv_silt_kickup()
{
	self Vehicle_TurnEngineOff();
	PlayFXOnTag( getfx( "silt_ground_kickup_runner" ), self, "TAG_PROPELLER" );
}

set_start_positions( targetname )
{
	start_positions = getstructarray( targetname, "targetname" );
				
	foreach ( pos in start_positions )
	{
		if (isdefined (level.player_rig) && pos.script_noteworthy == "player")
		{
			level.player_rig unlink();
			level.player_rig.origin = pos.origin;
		}
		
		switch ( pos.script_noteworthy )
		{
			case "player":
				level.player SetOrigin( pos.origin );
				level.player SetPlayerAngles( pos.angles );
				break;
			case "baker":
				level.baker ForceTeleport( pos.origin, pos.angles );
				level.baker setGoalPos( pos.origin );
				break;
		}
	}
}

spawn_baker()
{
	spawner = get_target_ent( "baker" );
	level.baker = spawner spawn_ai( true );
	level.baker thread magic_bullet_shield();
	level.baker.animname = "baker";	
	
	thread baker_glint();
}

baker_glint()
{
	baker_glint_on();
	
	level.baker endon ("death");
	level endon ("end_swimming");
	
	flag_wait ("start_swim");
	
	level.baker.glint_org = spawn_tag_origin();
	level.baker.glint_org.origin = level.baker gettagorigin("tag_stowed_back");
	level.baker.glint_org linkto(level.baker, "tag_stowed_back", (7,3,3), (0,0,0));
		
	for ( ;; )
	{
		if ( isdefined(level.baker))
		{
			if (level.baker.back_light_on)
				//playfxontag(getfx("ai_marker_light"), level.baker.glint_org, "tag_origin");
				playfxontag(getfx("ai_marker_light"), level.baker.glint_org, "tag_origin");
				
			timer = 0.75;
			wait( timer );
		}
		wait( 0.2 );
	}
}
	
baker_glint_off()
{   
	level.baker notify( "glint_off" );
	
	level.baker.back_light_on = false;
}

baker_glint_on()
{   
	level.baker notify( "glint_on" );	
	level.baker.back_light_on = true; 
	
	thread turn_off_glint_when_player_looks();
}

turn_off_glint_when_player_looks()	
{
	level.baker endon( "glint_on" );
	level.baker endon( "glint_off" );
	
	MINDIST = 350;
	
	//wait( 1 );
	
	while( 1 )
	{
		wait( 1 );
		
		if ( Distance( level.player.origin, level.baker.origin ) > MINDIST )
			level.baker.back_light_on = true;
				
		while ( Distance( level.player.origin, level.baker.origin ) > MINDIST )
			wait( 0.1 );
		
		level.baker waittill_player_lookat_for_time( 5, 0.8, true );
		
		if ( Distance( level.player.origin, level.baker.origin ) <= MINDIST )
			level.baker.back_light_on = false;
		
		wait( 1 );
			
		while ( Distance( level.player.origin, level.baker.origin ) <= MINDIST )
		wait( 0.1 );
		
	}
}

jump_into_water()
{
	target_pos = undefined;
	org = undefined;
	if ( isdefined( self.target ) )
	{
		org = self get_target_ent();
		target_pos = org.origin;
	}
	self thread  maps\_swim_ai::jumpIntoWater( target_pos );
}

paired_death_restart()
{
	level notify( "paired_death_restart" );
	level.paired_death_group = [];
	level.paired_death_max_distance = 700;
}

paired_death_think( friendly )
{
	level endon( "paired_death_restart" );
	self thread paired_death_add();
	
	while( 1 )
	{
		self waittill( "damage", damage, attacker );
		
		if ( attacker != level.player )
			return;
		else
			break;
	}
//	level.paired_death_group = array_remove( level.paired_death_group, self );
	
	self.gotshot = true;
	
	// shoot my buddy
	orig = self.origin;
	
	if ( !isdefined( orig ) )
		return;
		
	wait( 0.1 );
	if ( level.paired_death_group.size > 0 )
	{
		enemies = level.paired_death_group;
		enemies = array_removedead( enemies );
		enemies = SortByDistance( enemies, orig );
		
		foreach ( e in enemies )
		{	
			if ( e != self )
			{
				if ( Distance2D( e.origin, orig ) < level.paired_death_max_distance && !isdefined(e.gotshot) )
				{
					friendly stealth_shot( e );
					level notify( "other_guy_died" );
				}
				break;
			}
		}
	}
}

paired_death_wait_flag( flagname )
{
	if ( flag( flagname ) )
		return;
		
	level endon( flagname );
	while ( level.paired_death_group.size > 0 )
	{
		wait( 0.05 );
	}
	
	thread flag_set( flagname );
}

paired_death_wait()
{
	while ( level.paired_death_group.size > 0 )
	{
		wait( 0.05 );
	}
}

paired_death_add()
{
	if ( !IsDefined( level.paired_death_group ) )
		level.paired_death_group = [];
	
	level.paired_death_group[ level.paired_death_group.size ] = self;
	self waittill( "death" );
	level.paired_death_group = array_remove( level.paired_death_group, self );
}

stealth_shot( target )
{
	self endon( "death" );
	target endon( "death" );
	self thread stealth_shot_accuracy( target );
	self.favoriteenemy = target;
	self GetEnemyInfo( target );
	target.dontattackme = undefined;

	wait( 0.4 );
	start_pos = self GetTagOrigin( "tag_flash" );
	end_pos = target GetTagOrigin( "j_head" );	
	MagicBullet( self.weapon, start_pos, end_pos );

	
	wait( 0.1 );
	start_pos = self GetTagOrigin( "tag_flash" );
	end_pos = target GetTagOrigin( "j_head" );	
	MagicBullet( self.weapon, start_pos, end_pos );
	target kill( target.origin, self );
	
	MagicBullet( self.weapon, start_pos, end_pos + (RandomInt(5), RandomInt(5), RandomInt(5)));
	wait( 0.05 );
	MagicBullet( self.weapon, start_pos, end_pos + (RandomInt(5), RandomInt(5), RandomInt(5)));
	wait( 0.05 );
	MagicBullet( self.weapon, start_pos, end_pos + (RandomInt(5), RandomInt(5), RandomInt(5)));
	wait( 0.05 );
	MagicBullet( self.weapon, start_pos, end_pos + (RandomInt(5), RandomInt(5), RandomInt(5)));
	wait( 0.05 );
	
	rand1 = RandomInt(5);
	rand2 = RandomInt(5);
	rand3 = RandomInt(5);
	
	MagicBullet( self.weapon, start_pos, end_pos + (rand1, rand2, rand3));
	wait( 0.05 );
	MagicBullet( self.weapon, start_pos, end_pos + (rand1, rand2, rand3));	
}

stealth_shot_accuracy( target )
{
	old = self.baseaccuracy;
	self.baseaccuracy = 9999;
	target waittill( "death" );
	self.baseaccuracy = old;
}
	
moveTo_speed( point, rate, accel, decel )
{
	start_pos = self.origin;
	dist = Distance( start_pos, point );
	time = dist / rate;
	
	if ( !isdefined( accel ) )
		accel = 0;
	if ( !isdefined( decel ) )
		decel = 0;
	
	self moveTo( point, time, time*accel, time*decel );
	self waittill( "movedone" );
}

moveTo_rotateTo_speed( node, rate, accel, decel )
{
	point = node.origin;
	
	start_pos = self.origin;
	dist = Distance( start_pos, point );
	time = dist / rate;
	
	if ( !isdefined( accel ) )
		accel = 0;
	if ( !isdefined( decel ) )
		decel = 0;
	
//	iprintlnbold( time );
	
	self rotateTo( node.angles, time, time*accel, time*decel );
	self moveTo( point, time, time*accel, time*decel );
	self waittill( "movedone" );
}

// SPOTLIGHT STUFF BORROWED FROM LONDON

spot_light( fxname, cheapfx, tag_name, death_ent )
{
    if ( IsDefined( level.last_spot_light ) )
    {
        struct = level.last_spot_light;
        // stop the spotlight shadowmap version
        if ( IsDefined( struct.entity ) )
        {
	        StopFXOnTag( struct.effect_id, struct.entity, struct.tag_name );
	        // start the low budget version
	        if ( IsDefined( struct.cheap_effect_id ) )
	          PlayFXOnTag( struct.cheap_effect_id, struct.entity, struct.tag_name );
        }
        wait( 0.1 );
    }

    wait( 0.8 );
	level notify( "spotlight_changed_owner" );
    struct = SpawnStruct();
    struct.effect_id = getfx( fxname );
    if ( isdefined( cheapfx ) )
    	struct.cheap_effect_id = getfx( cheapfx );
    struct.entity = self;
    struct.tag_name = tag_name;
    
    PlayFXOnTag( struct.effect_id, struct.entity, struct.tag_name );
    
    if ( IsDefined( death_ent ) )
    {
        self thread spot_light_death( death_ent );
        
    }
    level.last_spot_light = struct;
}

stop_last_spot_light()
{
	if ( IsDefined( level.last_spot_light ) )
	{
		struct = level.last_spot_light;
		// stop the spotlight shadowmap version
		StopFXOnTag( struct.effect_id, struct.entity, struct.tag_name );
		level.last_spot_light = undefined;
	}
}

spot_light_death( death_ent )
{
    self notify ( "new_spot_light_death" );
    self endon ( "new_spot_light_death" );
    self endon ( "death" );
    death_ent waittill ( "death" );
    self Delete();
}

volume_waittill_no_axis( targetname, tolerance )
{
	volume = get_target_ent( targetname );
	
	while ( 1 )
	{
		if ( volume_is_empty( volume, tolerance ) )
			break;
		wait ( 0.2 );
	}	
}

volume_is_empty( volume, tolerance )
{
	if ( !isdefined( tolerance ) )
		tolerance = 0;
	
	enemies = GetAIArray( "axis" );
	num = 0;
		
	foreach ( e in enemies )
	{
		if ( e IsTouching( volume ) )
		{
			num += 1;
			if ( num > tolerance )
				return false;
		}
	}
	
	return true;
}

anim_generic_reach_and_animate( guy, anime, tag, custommode )
{
	self anim_generic_reach( guy, anime, tag );
	self notify( "starting_anim" );
	guy notify( "starting_anim" );
	if ( isdefined( custommode ) )
		self anim_generic_custom_animmode( guy, custommode, anime, tag );
	else
		self anim_generic( guy, anime, tag );
}

move_up_when_clear()
{
	volume = self get_target_ent();
	trigger = volume get_target_ent();
	
	trigger endon( "trigger" );
	
	self waittill( "trigger" );
	
	volume_waittill_no_axis( volume.targetname, volume.script_count );
	
	trigger thread activate_trigger();
}

depth_charge_org()
{
	target_pos = undefined;
	if ( isdefined( self.target ) )
	{
		org = self get_target_ent();
		target_pos = org.origin;
	}
	
	offset = ( 0, 0, 5 );
	
	start_z = level.water_level_z;
	
	flagname = self.script_flag;
	if ( isdefined( flagname ) )
	if ( !flag_exist( flagname ) )
		flag_init( flagname );
	
	self script_delay();
	drop_depth_charge( self.origin, target_pos, flagname );
}

drop_depth_charge( start_pos, target_pos, flagname )
{
	offset = ( 0, 0, 5 );
	start_z = level.water_level_z;

	
	if ( !isdefined( target_pos ) )
	{
		start_pos = ( start_pos[0], start_pos[1], start_z );
		trace = BulletTrace( start_pos - (0,0,10), start_pos - (0,0,700), false );
		target_pos = trace[ "position" ];
    }
	else
	{
		start_pos = ( target_pos[0], target_pos[1], start_z );
	}

	start_pos += offset;
	
	mover = spawn_tag_origin();
	mover.origin = start_pos + (0,0,22);
	
	barrel = Spawn( "script_model", start_pos );
	barrel setModel( "com_barrel_benzin2" );
	barrel linkTo( mover );
	
	rate = 200;
	dist = start_z - target_pos[2];

	mover thread barrel_roll();
	d1 = Min( 100, dist * 0.2 );
	d2 = dist - d1;
	t1 = d1 / rate;
	t2 = d2 / (rate/2);
	mover PlaySound( "depth_charge_drop" ); 
	PlayFX( getfx( "jump_into_water_splash" ), start_pos - offset );
	PlayFXOnTag( getfx( "underwater_object_trail" ), mover, "tag_origin" );
	mover moveZ( -1*d1, t1, 0, t1 );
	wait( t1 );
	mover moveZ( -1*d2, t2, 0, 0 );
	wait( t2 );
	StopFXOnTag( getfx( "underwater_object_trail" ), mover, "tag_origin" );
	
	PlayFX( getfx( "shpg_underwater_explosion_med_a" ), mover.origin );
	thread play_sound_in_space( "depth_charge_explo_dist", mover.origin );
	
	if ( isdefined( flagname ) )
		flag_set( flagname );
	
	if ( !flag( "depth_charge_muffle" ) )
	{
		Earthquake( 0.6, 0.75, mover.origin, 1024 );
		RadiusDamage( mover.origin, 300, 100, 20 );

		Dist = Distance( level.player.origin, mover.origin );
		
		if (dist < 1900)
		{
			if (dist < 900)
				thread play_sound_in_space( "depth_charge_explo_close_2d", mover.origin );
			else
				thread play_sound_in_space( "depth_charge_explo_mid_2d", mover.origin );
		}		
		
		if ( dist < 600 )
		{
			thread thrash_player( 600, 0.4, mover.origin );
			
			if ( dist < 300 )
			{
				if ( dist < 150 )
				{
					level.player Shellshock( "depth_charge_hit", 2.5 );
					level.player thread delay_reset_swim_shock( 3 );
				}
				else
				{
					level.player Shellshock( "depth_charge_hit", 1.5 );
					level.player thread delay_reset_swim_shock( 2 );
				}
			}
		}
	}
	else
	{
		Earthquake( 0.3, 0.5, mover.origin, 1024 );
	}
	
	barrel delete();
	
	mover delete();
}

thrash_player( maxdist, minfraction, source_org )
{
	dist = Distance( level.player.origin, source_org );
	fraction = Max( ( dist / maxdist ), minfraction );
	level.player ViewKick( int( fraction * 120 ) , source_org );
	vel = level.player GetVelocity();
	vec = VectorNormalize( level.player.origin - source_org );
	level.player setVelocity( (vel*0.75) + (vec*fraction*100) );
//	level.player thread maps\_gameskill::grenade_dirt_on_screen( random( ["left", "right" ] ) );
}

delay_reset_swim_shock( time )
{
	self AllowSprint( false );
	self notify( "new_shock" );
	self endon( "new_shock" );
	wait( time );
	self thread maps\_swim_player::shellshock_forever();
	self AllowSprint( true );
}

barrel_roll()
{
	self endon( "death" );
	
	time = RandomFloatRange( 0.5, 1.5 );
	
	while( 1 )
	{
		ang = ( self.angles[0] + 20, self.angles[1] + 30, self.angles[2] + 40 );
		self RotateTo( ang, time );
		wait( time );
	}
}

trigger_depth_charges()
{
	self waittill( "trigger" );
	org = getstructarray( self.target, "targetname" );
	array_thread( org, ::depth_charge_org );
}


dyn_swimspeed_enable( mindist )
{
	self endon( "death" );
	self endon( "dynspeed_off" );
	
	if ( isdefined( self.dyn_speed ) )
		return;
	
	self.dyn_speed = true;
	
	if ( !isdefined( mindist ) )
		mindist = 200;
	
	self.old_moveplaybackrate = self.moveplaybackrate;
	
	while( 1 )
	{
		player_behind_me = self player_is_behind_me();
		playerdist = Distance( self.origin, level.player.origin );
		if ( !player_behind_me || playerdist < mindist )
		{
			self.moveplaybackrate = self.old_moveplaybackrate*1.4;
			self.moveTransitionRate = self.moveplaybackrate;
			/#
//			iprintln( "speeding up" );
			#/
			wait( 1 );
			
			while  ( !(self player_is_behind_me()) || Distance( self.origin, level.player.origin ) < mindist )
				wait( 0.1 );
				
			self.moveplaybackrate = self.old_moveplaybackrate;
			self.moveTransitionRate = self.moveplaybackrate;
			/#
//			iprintln( "resuming speed" );
			#/
			wait( 5 );
		}
		wait( 0.3 );
	}
}

dyn_swimspeed_disable()
{
	self notify( "dynspeed_off" );
	if ( isdefined( self.old_moveplaybackrate ) )
	{
		self.moveplaybackrate = self.old_moveplaybackrate;
		self.moveTransitionRate = self.moveplaybackrate;
	}
	self.old_moveplaybackrate = undefined;
	self.dyn_speed = undefined;
}

player_is_behind_me()
{
	a = ( self.angles[0], self.angles[1], 0 );
	my_forward = AnglesToForward( a );
	org = self.origin - (0,0,self.origin[2]);
	org2 = level.player.origin - (0,0,level.player.origin[2]);
	forward = VectorNormalize( org2 - org );
	dot = VectorDot( forward, my_forward );
	
	return ( dot < -0.1 );
}

track_death()
{
	if ( isAI( self ) && self.team == "axis" )
	{
		self waittill( "death", killer );
		
		if ( !IsDefined( killer ) )
			return;
	
		if ( !flag( "allow_killfirms" ) )
		    return;
		
		wait( 0.3 );
		
		timeout = 0.2;
		
		if ( GetTime() - level.last_killfirm_time < level.last_killfirm_timeout )
			return;
			
		if ( killer == level.player )
		{
			if ( GetTime() - level.last_killfirm_time < level.last_killfirm_timeout )
				return;	
			
			if ( level.killfirm_suffix == "_loud" )
			{
				success = radio_dialogue( "shpg_killfirm_other_" + RandomIntRange( 0, 3 ) + level.killfirm_suffix, timeout );
				if ( success )
					level.last_killfirm_time = GetTime();
			}
		}
		else if ( killer == level.baker )
		{
			if ( GetTime() - level.last_killfirm_time < level.last_killfirm_timeout )
				return;			
			success = radio_dialogue( "shpg_killfirm_other_" + RandomIntRange( 0, 4 ) + level.killfirm_suffix, timeout );
			if ( success )
				level.last_killfirm_time = GetTime();
		}
	}
}

baker_killfirms()
{
	flag_init( "allow_killfirms" );
	flag_set( "allow_killfirms" );
	
	level.last_killfirm_time = 0;
	level.last_killfirm_timeout = 15000;
	level.killfirm_suffix = "";
}

force_deathquote( deathquote )
{	
	if ( isdefined( deathquote ) )
	{
		level notify( "new_quote_string" );
		setDvar( "ui_deadquote", deathquote );
	}
}

dyn_balloon_delete()
{
	self notify( "deleted" );
	foreach ( clip in self.path_clip )
	{
		if ( isdefined( clip ) )
			clip delete();
	}
	foreach ( item in self.linked )
	{
		if ( isdefined( item ) )
			item delete();
	}
	self delete();
}

new_dyn_balloon_think()
{
	self endon( "deleted" );
	self.balloon_count = level.balloon_count;
	level.balloon_count += 1;
	
	linked = self get_linked_ents();
	array_call( linked, ::linkTo, self );
	self.linked = linked;
	parts = getentarray( self.target, "targetname" );
	self.path_clip = [];
	self.delete_things = [];
	
	self.damage_detect = self;
	
	foreach ( p in parts )
	{
		switch ( p.script_noteworthy )
		{
			case "bottom":
				self.bottom = p;
				self.bottom_target = self.bottom get_target_ent();
				break;
			case "path_clip":
				self.path_clip = array_add( self.path_clip, p );
				break;
		}
	}
	
	foreach ( l in linked )
	{
		if ( isdefined( l.script_noteworthy ) )
		{
			switch ( l.script_noteworthy )
			{
				case "damage_detect":
					self.damage_detect = l;
				case "delete_on_explode":
					self.delete_things = array_add( self.delete_things, l );
					break;
			}
		}
	}
	
	waitframe();
	
	foreach ( clip in self.path_clip )
	{
		clip NotSolid();
		clip ConnectPaths();
	}
	
	self.damage_detect setCanDamage( true );
	
	self thread dyn_balloon_bob();
	
	self.damage_detect.health = 1;
	while( self.damage_detect.health > 0 )
	{
		self.damage_detect waittill( "damage", amount, attacker, impact_vec, point, damageType );
	}
	
	PlayFX( getfx( "shpg_underwater_bubble_explo" ), self.origin + (0,0,64) );
	thread play_sound_in_space( "underwater_balloon_pop", self.origin );
	self Hide();
	self notify( "stop_bob" );
	foreach( d in self.delete_things )
		d delete();
	
	BadPlace_Cylinder( "balloon" + self.balloon_count, 5, self.bottom.origin, 128, 128 );
	
	foreach ( clip in self.path_clip )
	{
		clip Solid();
		clip DisconnectPaths();
	}
	
	ai = getAIArray( "axis" );
	foreach ( a in ai )
	{
		if ( Distance2d( self.origin, a.origin ) < 128 )
		{
			a thread notify_delay( "ai_event", RandomFloatRange( 0.2, 0.4 ) );
			a.health = 1;
			a.baseaccuracy = 0.3;
			a setThreatBiasGroup( "easy_kills" );
		}
	}
	org_diff = self.origin[2] - self.orig_org[2];
	self moveto_speed( self.origin - (0,0, self.bottom.origin[2] - self.bottom_target.origin[2] + org_diff), 50, 0.3, 0.0 );
	PlayFX( getfx( "underwater_impact_vehicle_cheap" ), self.bottom_target.origin, (0,0,1), (1,0,0) );
	thread play_sound_in_space( "scn_shipg_box_fall_generic", self.bottom_target.origin );
	Earthquake( 0.3, 0.6, self.bottom_target.origin, 512 );
}

dyn_balloon_think()
{
	self endon( "deleted" );
	self.balloon_count = level.balloon_count;
	level.balloon_count += 1;
	
	linked = self get_linked_ents();
	array_call( linked, ::linkTo, self );
	self.linked = linked;
	parts = getentarray( self.target, "targetname" );
	self.path_clip = [];
	foreach ( p in parts )
	{
		switch ( p.script_noteworthy )
		{
			case "bottom":
				self.bottom = p;
				self.bottom_target = self.bottom get_target_ent();
				break;
			case "path_clip":
				self.path_clip = array_add( self.path_clip, p );
				break;
		}
	}
	
	waitframe();
	
	foreach ( clip in self.path_clip )
	{
		clip NotSolid();
		clip ConnectPaths();
	}
	
	self setCanDamage( true );
	
	self thread dyn_balloon_bob();
	
	self waittill( "damage", amount, attacker, impact_vec, point, damageType );
	
	org = spawn_tag_origin();
	org.origin = point;
	org.angles = impact_vec;
	org linkto( self );
	PlayFXOnTag( getfx( "water_bubbles_longlife_lp" ) , org, "tag_origin" );
	
	BadPlace_Cylinder( "balloon" + self.balloon_count, 5, self.bottom.origin, 128, 128 );
	
	foreach ( clip in self.path_clip )
	{
		clip Solid();
		clip DisconnectPaths();
	}
	
	ai = getAIArray( "axis" );
	foreach ( a in ai )
	{
		if ( Distance2d( self.origin, a.origin ) < 128 )
		{
			a thread notify_delay( "ai_event", RandomFloatRange( 0.2, 0.4 ) );
			a.health = 1;
			a.baseaccuracy = 0.3;
			a setThreatBiasGroup( "easy_kills" );
		}
	}
	org_diff = self.origin[2] - self.orig_org[2];
	self moveto_speed( self.origin - (0,0, self.bottom.origin[2] - self.bottom_target.origin[2] + org_diff), 40, 0.3, 0.0 );
}

dyn_balloon_bob()
{
	self endon( "stop_bob" );
	self endon( "deleted" );
	self endon( "damage" );
	self.orig_org = self.origin;
	dist = 3;
	while( 1 )
	{
		time = RandomFloatRange( 3,5 );
		self moveTo( self.orig_org + ( 0,0,dist ), time, time*0.5, time*0.5 );
		self waittill( "movedone" );
		waitframe();
		self moveTo( self.orig_org - ( 0,0,dist ), time, time*0.5, time*0.5 );
		self waittill( "movedone" );
	}
}

shark_go_trig()
{
	sharks = getentarray( self.target, "targetname" );
	array_call( sharks, ::Hide );
	self waittill( "trigger" );
	sharks = getentarray( self.target, "targetname" );
	array_thread( sharks, ::shark_think );
	array_thread( sharks, ::delayThread, RandomFloatRange( 0,1 ), ::shark_kill_think );
}

#using_animtree( "animals" );

shark_think()
{
	self endon( "death" );
	self notify( "new_directive" );
	self endon( "new_directive" );
	self Show();
	self UseAnimTree( #animtree );
	spd = RandomFloatRange( 0.7, 1.1 );
	if ( isdefined( self.script_moveplaybackrate ) )
		spd = self.script_moveplaybackrate;
	
	self.animname = "shark";
	self setAnim( %shark_swim_f, 1, RandomFloatRange( 0, 0.5 ), spd );
	path = self get_target_ent();
	while( 1 )
	{
		vec = path.origin - self.origin;
		self rotateTo( VectorToAngles( vec ), 1 );
		self moveTo_speed( path.origin, 60 * spd );
		if ( isdefined( path.target ) )
			path = path get_target_ent();
		else break;
	}
	self delete();
}

dead_body_spawner()
{
	places = getstructarray( self.script_noteworthy, "script_noteworthy" );
	foreach ( p in places )
	{
		self.origin = p.origin;
		self.angles = p.angles;
		
		guy = self spawn_ai( true );
		guy gun_remove();
		anime = level.scr_anim[ "generic" ][ p.animation ];
		if ( IsArray( anime ) )
			anime = anime[0];
		guy SetCanDamagE( false );
		guy NotSolid();
		guy AnimScripted( "endanim", p.origin, p.angles, anime );
		waitframe();
	}
}

shark_kill_side( shark, anime, delays )
{
	SetDvar( "shpg_killed_by_shark", 1 );
	if ( !isdefined( anime ) )
	{		
		anime = "shark_attack";
	}
	if ( !isdefined( delays ) )
	{
		delays = [];
		delays[0] = 0.9;
		delays[1] = 0.3;
		delays[2] = 0.3;	
	}
	
	/* SHARK ATTACK TEST */
	org = level.player.origin;
	fwd = AnglesToForward( level.player.angles );
	rgt = AnglesToRight( level.player.angles );
	
	if ( !isdefined( shark ) )
	{
		shark = spawn( "script_model", org - (fwd*100) );
		shark setModel( "fullbody_tigershark" );
		shark.animname = "shark";
		shark setAnimTree();
	}
	player_swim_offset = (0,0,48);
	
	rig = maps\_player_rig::get_player_rig();
	rig.origin = level.player.origin - player_swim_offset;
	rig.angles = level.player.angles;// - (0,90,0);
	
	dummy = spawn_tag_origin();
	dummy.origin = rig.origin;
	dummy.angles = rig.angles;
	dummy linkTo( rig, "tag_player", player_swim_offset, (0,0,0) );
	
	rig thread anim_single( [rig, shark], anime );
	level.player DisableWeapons();
	//level.player PlayerLinkToBlend( rig, "tag_player", 1 );
	level.player PlayerLinkToBlend( dummy, "tag_origin", 0.6 );
	wait( delays[0] );
	fx_dummy = spawn_Tag_origin();
	fx_dummy.origin = level.player getEye();
	fx_dummy linkTo( level.player );
	PlayFX( getfx( "swim_ai_blood_impact" ), fx_dummy.origin );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), fx_dummy, "tag_origin" );
	level.player thread maps\_gameskill::blood_splat_on_screen( "bottom" );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	wait( delays[1] );
	level.player thread maps\_gameskill::blood_splat_on_screen( "left" );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	wait( delays[2] );
	level.player kill();
}

// self = shark
shark_kill_front( shark, anime, delays )
{
	shark unlink();
	shark notify( "stop_loop" );
	if ( isdefined( shark.anim_node ) )
	{
		shark.anim_node notify( "stop_loop" );
	}
	if ( !isdefined( anime ) )
	{		
		anime = "shark_attack_4";
	}
	if ( !isdefined( delays ) )
	{
		delays = [ 0.6, 1.25, 1.5 ];
	}
	
	/* SHARK ATTACK TEST */
	
	node = SpawnStruct();
	node.origin = shark.origin;
	node.angles = VectorToAngles( level.player.origin - shark.origin );
	
	if ( issubstr( anime, "_L" ) )
	{
		new_vec = anglesToRight( node.angles );
		node.angles = VectorToAngles( new_vec );
	}
	else if ( issubstr( anime, "_R" ) )
	{
		new_vec = anglesToRight( node.angles );
		node.angles = VectorToAngles( -1*new_vec );
	}
	
	org = level.player.origin;
	fwd = AnglesToForward( level.player.angles );
	rgt = AnglesToRight( level.player.angles );
	
	player_swim_offset = (0,0,52);
	
	rig = maps\_player_rig::get_player_rig();
	rig.origin = level.player.origin - player_swim_offset;
	rig.angles = level.player.angles;// - (0,90,0);
	rig Hide();
	
	dummy = spawn_tag_origin();
	dummy.origin = rig.origin;
	dummy.angles = rig.angles;
	dummy linkTo( rig, "tag_player", player_swim_offset, (0,0,0) );
	
	node thread anim_single( [rig, shark], anime );
	level.player DisableWeapons();
	
	blendtime = 0.2;
	level.player PlayerLinkToBlend( dummy, "tag_origin", blendtime, 0, blendtime*0.25 );
	thread shark_attack_slomo();
	rig delayCall( blendtime, ::show );
	level.player delayCall( 0.0, ::playsound, "scn_shipg_shark_bite_plr" );
	
	wait( delays[0] );
	fx_dummy = spawn_Tag_origin();
	fx_dummy.origin = level.player getEye();
	fx_dummy linkTo( level.player );
	PlayFX( getfx( "swim_ai_blood_impact" ), fx_dummy.origin );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), fx_dummy, "tag_origin" );
	level.player thread maps\_gameskill::blood_splat_on_screen( "bottom" );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	wait( delays[1] );
	level.player thread maps\_gameskill::blood_splat_on_screen( "left" );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	wait( delays[2] );
	SetDvar( "shpg_killed_by_shark", 1 );
	level.player kill();
}

shark_attack_slomo()
{
	slowmo = false;
	if ( getDvarInt( "shpg_killed_by_shark", 0 ) )
	{
		slowmo = false;
	}
	
	wait( 0.2 );
	
	slomoLerpTime_in = 0.15;
	slomoLerpTime_out = 0.35;
	
	level.player LerpFOV( 50, 0.2 );
//	level.player thread play_sound_on_entity( "slomo_whoosh" );
	slowmo_setspeed_slow( 0.1 );
	slowmo_setlerptime_in( slomoLerpTime_in );
	if ( slowmo )
		slowmo_lerp_in();
	wait( slomoLerpTime_in );
	wait( 0.1 );
	level.player LerpFOV( 65, 0.3 );
	slowmo_setlerptime_out( slomoLerpTime_out );
	if ( slowmo )
		slowmo_lerp_out();
	//level.player thread play_sound_on_entity( "slomo_whoosh" );
}

#using_animtree( "animals" );
shark_vehicle()
{
	shark = self;
	shark.animname = "shark";
	
	veh = spawn_vehicle_from_targetname_and_drive( self.target );
	
	shark ForceTeleport( veh.origin, veh.angles );
	shark linkTo( veh, "tag_origin" );
	
	wait( RandomFloatRange( 0, 1 ) );
	shark.anim_node = veh;
	veh thread anim_loop_solo( shark, shark.animation, "stop_loop", "tag_origin" );
	
	shark thread shark_kill_think();
}

shark_track_bulletwhizby()
{
	self addAIEventListener( "bulletwhizby" );
	while( 1 ) 
	{
		self waittill( "ai_event", type );
		if ( type == "bulletwhizby" )
		{
			if ( level.player player_looking_at( self.origin, 0.7, true ) )
			{
				success = self shark_kill_player();
				if ( success )
					break;
			}
		}
		wait( 0.5 );
	}
}

shark_kill_think()
{
	self endon( "death" );

	self.animname = "shark";
	level.deadly_sharks = array_add( level.deadly_sharks, self );
	if ( isAI( self ) )
	{
		self childthread shark_track_bulletwhizby();
	}
	
	self ent_flag_init( "shark_busy" );
		
	while( 1 )
	{
		eaten = GetDvarInt( "shpg_killed_by_shark", 0 );
		if ( !eaten )
		{
			shark_body_eat_dist = 110;
			shark_face_eat_dist = 90;
			speed_multiplier = 0.75;
		}
		else
		{
			shark_body_eat_dist = 90;
			shark_face_eat_dist = 70;
			speed_multiplier = 0.95;
		}
		
		self ent_flag_waitopen( "shark_busy" );
		flag_waitopen( "shark_eating_player" );
		flag_waitopen( "no_shark_heartbeat" );
		player_speed_max = getDvarInt( "player_swimSpeed", 70 );
		player_speed_max *= speed_multiplier;
	
		tag_jaw = self GetTagOrigin( "j_jaw" );
		tag_head = self GetTagOrigin( "j_head" );
		tag_head_angles = self GetTagAngles( "j_head" );
		tag_head_angles = AnglesToRight( tag_head_angles );
		tag_head_angles = VectorToAngles( tag_head_angles );
		
		player_speed_mult = 1;
		plr_speed = Distance( level.player getVelocity(), (0,0,0) );
		if ( plr_speed > player_speed_max )
		{
			player_speed_mult = plr_speed / player_speed_max;
		}
		
		if ( Distance( level.player.origin, self.origin ) < shark_body_eat_dist*player_speed_mult )
			self shark_kill_player();
		else if ( Distance( level.player.origin, tag_jaw ) < shark_face_eat_dist*player_speed_mult )
			self shark_kill_player();
		else if ( within_fov( tag_head, tag_head_angles, level.player.origin, 0.8 ) && Distance( level.player.origin, tag_head ) < shark_face_eat_dist*player_speed_mult*2 )
			self shark_kill_player();
		
		wait( 0.05 );
	}
}

player_get_closest_node()
{
	level.player endon( "death" );
	
	while ( 1 )
	{
		closestNode = GetClosestNodeInSight( self.origin );
		if ( IsDefined( closestNode ) )
		{	
			if ( closestNode.type != "Begin" && closestNode.type != "End" && closestNode.type != "Turret" )
				self.node_closest = closestNode;
		}

		wait 0.25;
	}
}

shark_kill_player( force_attack )
{
	self endon( "death" );
	self thread restore_attack_flag_on_death();
	
	if ( flag( "shark_eating_player" ) )
		return false;

	if ( !isdefined( force_attack ) )
	{
		trace = BulletTrace( self.origin, level.player.origin, false, self );
		if ( trace[ "fraction" ] < 0.95 )
			return false; 
		
		radio_dialogue_stop();
		thread radio_dialogue_interupt( "shpg_shark_attack_0" );
	}
	self notify( "killing_player" );
	/#
//	iprintln( "shark attack!" );
	#/
	
	flag_set( "shark_eating_player" );
	
	wait( 0.25 ); // give the shark some time to react
	
	if ( isAI( self ) )
	{
		if ( isdefined( self.animnode ) )
		{
			self.animnode notify( "stop_loop" );
			self.animnode notify( "stop_first_frame" );
			self notify( "stop_loop" );
			self notify( "stop_first_frame" );
		}
		
		self StopAnimScripted();
		self unlink();
		
		attack_radius = 250;
		
		self.moveplaybackrate = level.shark_attack_playbackrate;
		self.moveTransitionRate = self.moveplaybackrate;
		self.goalheight = 150;
		self.goalradius = 64;
		self thread shark_chase_player();
		
		while( 1 )
		{
			trace = BulletTrace( self.origin, level.player.origin, false, self );
			if ( trace[ "fraction" ] >= 0.95 && Distance( level.player.origin, self.origin ) <= attack_radius )
				break;
			wait( 0.1 );
		}
	}
	self notify( "chomp" );	
		
	delayThread( 0.9, ::flag_set, "no_shark_heartbeat" );
	delayThread( 0.6, ::smart_radio_dialogue_interrupt, "shipg_hsh_adam" );	
	
	direction = getDirectionFacing( self.angles, self.origin, level.player.origin );
//	iprintln( "shark_attack_" + direction );
	shark_kill_front( self, "shark_attack_" + direction );

	return true;
}

getDirectionFacing( viewerAngles, viewerOrigin, targetOrigin )
{
	forward = AnglesToForward( viewerAngles );
	vFacing = VectorNormalize( forward );
	anglesToFacing = VectorToAngles( vFacing );
	anglesToPoint = VectorToAngles( targetOrigin - viewerOrigin );

	angle = anglesToFacing[ 1 ] - anglesToPoint[ 1 ];
	angle += 360;
	angle = Int( angle ) % 360;

	if ( angle >= 315 || angle <= 45 )
	{
		direction = "F";
	}
	else if ( angle < 135 )
	{
		direction = "R";
	}
	else if ( angle < 255 )
	{
		direction = "B";
	}
	else
	{
		direction = "L";
	}

	return( direction );
}

restore_attack_flag_on_death()
{
	self waittill( "death" );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), self, "j_spineupper" );
	flag_clear( "shark_eating_player" );
	level.shark_attack_playbackrate += 1.5;
}

shark_chase_player()
{
	self endon( "chomp" );
	self endon( "death" );
	
	while( 1 )
	{
		self setGoalPos( level.player.node_closest.origin );
		wait( 0.25 );
	}
}

waittill_goal_or_dist()
{
	self endon( "death" );
	self childthread notify_delay( "timeout", 0.8 );
	self endon( "goal" );
	self endon( "timeout" );
	while( Distance( level.player.origin, self.origin ) > self.goalradius )
	{
		wait( 0.05 );
	}
}

notify_spotted_on_damage()
{
	self endon( "death" );
	self waittill( "damage", amount, attacker );
	if ( attacker == level.player )
		flag_set( "_stealth_spotted" );
}

make_swimmer()
{
	if ( self.team == "allies" )
		return;
	if ( self.type == "dog" )
		return;
	
	if ( !isdefined( self.swimmer ) || self.swimmer == 0 )
		self thread maps\_swim_ai::enable_swim();
}

delete_on_notify( message )
{
	if ( !IsDefined( message ) )
		message = "level_cleanup";
	self endon( "death" );
	level waittill( message );

	if ( IsDefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
	{
		self stop_magic_bullet_shield();
	}
	
	self Delete();
}

baker_noncombat()
{
	level.baker ClearEnemy();
	level.baker.alertlevel = "noncombat";
	level.baker.a.combatEndTime = getTime() - 10000;
}

moveTo_rotateTo( node, time, accel, decel )
{
	self moveTo( node.origin, time, accel, decel );
	self rotateTo( node.angles, time, accel, decel );
	self waittill( "movedone" );
}

set_flag_unless_triggered( _flag, _delay )
{
	self endon( "trigger" );
	self endon( "death" );
	
	wait( _delay );
	flag_set( _flag );
}

sdv_play_sound_on_entity()
{
	self Vehicle_TurnEngineOff();
	self thread play_sound_on_entity( "scn_shipg_minisub_passby" );
}

track_hint_up()
{
	flag_clear( "player_can_rise" );
	level.player notifyOnPlayerCommand( "pressed_up", "+frag" );
	level.player waittill( "pressed_up" );
	flag_set( "player_can_rise" );
}

track_hint_down()
{
	flag_clear( "player_can_fall" );
	level.player notifyOnPlayerCommand( "pressed_down", "+smoke" );
	level.player waittill( "pressed_down" );
	flag_set( "player_can_fall" );
}

track_hint_sprint()
{
	flag_clear( "player_can_sprint" );
	level.player notifyOnPlayerCommand( "pressed_sprint", "+sprint" );
	level.player notifyOnPlayerCommand( "pressed_sprint", "+sprint_zoom" );
	level.player notifyOnPlayerCommand( "pressed_sprint", "+breath_sprint" );
	level.player waittill( "pressed_sprint" );
	flag_set( "player_can_sprint" );
}

hintUp_test()
{
	return flag( "player_can_rise" );
}

hintDown_test()
{
	return flag( "player_can_fall" );
}

hintSprint_test()
{
	return flag( "player_can_sprint" );
}

hintFlashlight_test()
{
	return !(level.player ent_flag( "flashlight_on" ));
}

sardines_path_sound( triggername, sndalias )
{
	if ( !isdefined( sndalias ) )
		sndalias = "scn_fish_swim_away";
	
	trigger = get_target_ent( triggername );
	trigger waittill( "trigger" );
	sardines = getent( triggername, "target" );
	waitframe();
	sardines.pieces[0] thread play_sound_on_entity( sndalias );
}


sardines_path_sound_no_trigger( schoolname, sndalias )
{
	if ( !isdefined( sndalias ) )
		sndalias = "scn_fish_swim_away";
	
	sardines = getent( schoolname, "script_noteworthy" );
	waitframe();
	sardines.pieces[0] thread play_sound_on_entity( sndalias );
}


delete_fish_in_volume( volume )
{
	volume = get_Target_ent( volume );
	fish_array = getentarray( "interactive_fish_bannerfish", "targetname" );
		
	foreach ( fish in fish_array )
	{
		if ( isdefined( fish ) )
			if ( fish isTouching( volume ) )
				fish delete();
		waitframe();
	}
}

trigger_multiple_fx_volume_off_target()
{
	wait( 1 );
	
	self waittill( "trigger" );
	targ = self get_target_ent();	
	fx_volume_pause( targ );
}

/********************************
 *          MELEE STUFF         *
 ********************************/

MELEE_SLOWMO = 0.4;

try_to_melee_player( endon_flag )
{
	level endon( endon_flag );
	level.player endon( "death" );
	
	if ( !flag( endon_flag ) )
	{
		level endon( endon_flag );
		enemies = getAIArray( "axis" );
		while( enemies.size > 0 )
		{
			enemies = SortByDistance( enemies, level.player.origin );
			attempt = undefined;
			foreach( e in enemies )
			{
				if ( Distance( e.origin, level.player.origin ) > 200 )
				{
					attempt = e;
					break;
				}
			}
			
			if ( isdefined( attempt ) )
			{
				attempt childthread enemy_attempt_melee();
				msg = attempt waittill_any_return( "death", "start_melee" );
				if ( msg == "start_melee" )
				{
					wait( 90 );
				}
				else
				{
					wait( 0.5 );
				}
			}
			else
			{
				wait( 2 );
			}
			enemies = getAIArray( "axis" );
		}
	}
}

enemy_attempt_melee()
{
	level.player endon( "death" );
	self endon( "death" );
	
	self ent_flag_init( "adjusting_position" );
	
	self.ignoreme = true;
	
	self.favoriteenemy = level.player;

	self setThreatBiasGroup( "ignoring_baker" );
	
	self.turnrate = 1;
	self.moveplaybackrate = 2;
	self.movetransitionrate = self.moveplaybackrate;
	self.goalradius = 128;
	self.goalheight = 96;
	self setGoalentity( level.player, 50 );
	
	while( 1 )
	{
		while( Distance2d( self.origin, level.player.origin ) > self.goalradius + 64 )
		{
			wait( 0.05 );
		}
		
		trace = self AIPhysicsTrace( self.origin, level.player GetEye(), undefined, undefined, true, true );
		if ( trace[ "fraction" ] < 0.99 )
		{
			self thread enemy_melee_readjust();
			wait( 0.2 );
			continue;
		}
		else if ( Distance2d( self.origin, level.player.origin ) <= self.goalradius + 64 )
			break;
	}
	self notify( "start_melee" );
	
	self.health = 900;
	thread enemy_melee_front( self );
}

enemy_melee_readjust()
{
	if ( self ent_flag( "adjusting_position" ) )
		return;

	self notify( "adjusting_pos" );
	
	self endon( "start_melee" );
	self endon( "adjusting_pos" );
	self endon( "death");
	
	self ent_flag_set( "adjusting_position" );
	self delayThread( 2, ::ent_flag_clear, "adjusting_position" );
	
	nodes = GetNodesInRadiusSorted( level.player.origin, self.goalradius + 64, 64, self.goalheight );
	if ( nodes.size > 0 )
	{
		foreach ( node in nodes )
		{
			trace = self AIPhysicsTrace( self.origin, level.player GetEye(), undefined, undefined, true, true );
			if ( trace[ "fraction" ] > 0.99 )
			{
				self setGoalPos( node.origin );
				self waittill( "goal" );
				self setGoalentity( level.player, 50 );
				return;
			}
			else
			{
				waitframe();
			}
		}
	}
}

enemy_melee_front( enemy, anime )
{
	playfxOnTag( getfx( "rebreather_hose_bubbles" ), enemy.scuba_org, "tag_origin" );
	
	enemy unlink();
	enemy notify( "stop_loop" );
	if ( isdefined( enemy.anim_node ) )
	{
		enemy.anim_node notify( "stop_loop" );
	}
	if ( !isdefined( anime ) )
	{		
		anime = "melee_A";
	}
	
	/* MELEE TEST */
	
	node = SpawnStruct();
	node.origin = enemy.origin;
	//node.angles = VectorToAngles( enemy.origin - level.player.origin );
	node.angles = VectorToAngles( level.player.origin - enemy.origin );
	
	org = level.player.origin;
	fwd = AnglesToForward( level.player.angles );
	rgt = AnglesToRight( level.player.angles );
	
	player_swim_offset = (0,0,48);
	
	rig = maps\_player_rig::get_player_rig();
	rig.origin = level.player.origin - player_swim_offset;
	rig.angles = level.player.angles;// - (0,90,0);
	rig Hide();
	
	dummy = spawn_tag_origin();
	dummy.origin = rig.origin;
	dummy.angles = rig.angles;
	dummy linkTo( rig, "tag_player", player_swim_offset, (0,0,0) );
	
	// initial swing
	pos = enemy getTagOrigin( "tag_inhand" );
	ang = enemy getTagAngles( "tag_inhand" );
	
	enemy attach( "weapon_parabolic_knife", "tag_inhand", true );
	
	level.player thread melee_dof();
	
	node thread anim_single_solo( rig, anime );
	node thread anim_generic( enemy, anime );
	level.player DisableWeapons();
	level.player EnableDeathShield( true );
		
	blendtime = 0.5;
	level.player PlayerLinkToBlend( dummy, "tag_origin", blendtime, blendtime, 0 );
	rig delayCall( blendtime, ::show );
	level.player delayThread( 2, ::player_panic_bubbles );
	wait( 2.4 );
	if ( level.player.health < 60 )
	{
		melee_kill_stab( enemy, anime, rig, node );
	}
	else
	{
		melee_damage_stab( enemy, anime, rig, node );
	}
}

melee_damage_stab( enemy, anime, rig, node )
{
	level.player endon( "melee_button_pressed" );
	
	level.player thread melee_wait_for_player_input();
	level.player thread melee_hint();
	level.player thread melee_acknowledge_player_input( enemy, anime, rig, node, false );
	
	node waittill( anime );
	level.player notify( "melee_done" );
	
	// lose condition
	level.player thread melee_damage( enemy, anime, rig, node );
}

melee_damage( enemy, anime, rig, node )
{
	level.player notify( "melee_win", false );
	
	node thread anim_generic( enemy, anime + "_stab1" );
	node thread anim_single_solo( rig, anime + "_stab1" );
	
	level waittill ("stab");
	//wait( 0.2 ); // should be notetrack
		
	fx_origin = enemy GetTagOrigin( "tag_knife_fx" );
	level.player DoDamage( 200, fx_origin );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	level.player thread play_sound_on_entity( "generic_death_enemy_1" );

	wait( 0.1 ); // should be notetrack
	fx_origin = enemy GetTagOrigin( "tag_knife_fx" );
	//PlayFX( getfx( "swim_ai_blood_impact" ), fx_origin );
	
	node waittill( anime + "_stab1" );

	node thread anim_generic( enemy, anime + "_reset" );
	node thread anim_single_solo( rig, anime + "_reset" );

	noself_delayCall( 0.2, ::PlayFXOnTag, getfx( "knife_stab_blood" ), enemy, "tag_knife_fx" );
	
	wait( 0.65 );
	
	level.player endon( "melee_button_pressed" );
	SetSlowMotion( 1, MELEE_SLOWMO, 0.1 );	
	level.player thread melee_wait_for_player_input();
	level.player thread melee_hint();
	level.player thread melee_acknowledge_player_input( enemy, anime, rig, node, true );
	
	node waittill( anime + "_reset" );
	level.player notify( "melee_done" );
	
	// lose condition
	level.player thread melee_lose( enemy, anime, rig, node );
}

melee_kill_stab( enemy, anime, rig, node )
{
	level.player endon( "melee_button_pressed" );
	SetSlowMotion( 1, MELEE_SLOWMO, 0.1 );	
	level.player thread melee_wait_for_player_input();
	level.player thread melee_hint();
	level.player thread melee_acknowledge_player_input( enemy, anime, rig, node, true );
	
	node waittill( anime );
	level.player notify( "melee_done" );
	
	// lose condition
	level.player thread melee_lose( enemy, anime, rig, node );
}

melee_lose( enemy, anime, rig, node )
{
	level.player notify( "melee_win", false );
	
	SetSlowMotion( MELEE_SLOWMO, 1, 0.1 );

	node thread anim_generic( enemy, anime + "_stab2" );
	node thread anim_single_solo( rig, anime + "_stab2" );
	
	node waittill( anime + "_stab2" );
	
	node thread anim_generic( enemy, anime + "_lose" );
	node thread anim_single_solo( rig, anime + "_lose" );
	
	wait( 0.1 ); // should be notetrack
		
	fx_origin = enemy GetTagOrigin( "tag_knife_fx" );
	PlayFX( getfx( "swim_ai_blood_impact" ), fx_origin );
	level.player DoDamage( 90, fx_origin );
	level.player thread play_sound_on_entity( "generic_death_enemy_1" );
	
	wait( 0.1 );
	
	PlayFX( getfx( "swim_ai_death_blood" ), level.player GetEye() );
	level.player EnableDeathShield( false );
	level.player kill();
}

#using_animtree( "generic_human" );
melee_acknowledge_player_input( enemy, anime, rig, node, slowmo )
{
	level.player endon( "melee_done" );
	level.player waittill( "melee_button_pressed" );
	
	// win condition
	level.player notify( "melee_win", true );
	
	level.player EnableDeathShield( false );
	level.player EnableInvulnerability();
	
	enemy.allowdeath = true;
	
	pos = rig getTagOrigin( "tag_knife_attach" );
	ang = rig getTagAngles( "tag_knife_attach" );	

	rig attach( "viewmodel_knife", "tag_knife_attach", false );
	if ( slowmo )
		SetSlowMotion( MELEE_SLOWMO, 1, 0.25 );
	node thread anim_generic( enemy, anime + "_win" );
	node thread anim_single_solo( rig, anime + "_win" );
	
	level waittill ("stab");
	
	fx_origin = rig GetTagOrigin( "tag_knife_fx" );


		
	enemy thread animscripts\death::PlayDeathSound();
	PlayFX( getfx( "swim_ai_blood_impact" ), fx_origin );
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), enemy, "j_spineupper" );
	level.player notify( "melee_dof_adjust" );
	
	level waittill ("pull_out");
	//noself_delayCall( 0.4, ::PlayFXOnTag, getfx( "knife_stab_blood" ), rig, "tag_knife_fx" );
	PlayFXOnTag( getfx( "knife_stab_blood" ), rig, "tag_knife_fx" );
	
	node waittill( anime + "_win" );
	
	stopfxOnTag( getfx( "rebreather_hose_bubbles" ), enemy.scuba_org, "tag_origin" );
	enemy.a.nodeath = true;
	enemy.noDeathSound = true;
	enemy detach( "weapon_parabolic_knife", "tag_inhand" );
	enemy kill();
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), enemy, "j_spineupper" );
		
	rig delete();
	level.player unlink();
	level.player EnableWeapons();
	level.player DisableInvulnerability();
}

melee_wait_for_player_input()
{
	level.player endon( "melee_button_pressed" );
	level.player endon( "melee_done" );
	
	while( level.player player_attacked() )
	{
		wait( 0.05 );
	}
	
	while( !level.player player_attacked() )
	{
		wait( 0.05 );
	}
	
	level.player notify( "melee_button_pressed" );
}

player_attacked()
{
	return isalive( self ) && ( self MeleeButtonPressed() );
}

melee_hint()
{
	if ( isDefined( self.MeleeHintElem ) )
		self.MeleeHintElem maps\_hud_util::destroyElem();

	self.MeleeHintElem = self maps\_hud_util::createClientFontString( "default", 3 );
	self.MeleeHintElem.color = ( 1, 1, 1 );
	// [{+melee}]
	self.MeleeHintElem setText( &"SCRIPT_PLATFORM_DOG_HINT" );
	self.MeleeHintElem.x = 25;
	self.MeleeHintElem.y = -30;
	self.MeleeHintElem.alignX = "center";
	self.MeleeHintElem.alignY = "middle";
	self.MeleeHintElem.horzAlign = "center";
	self.MeleeHintElem.vertAlign = "middle";
	self.MeleeHintElem.foreground = true;
	self.MeleeHintElem.alpha = 1;
	self.MeleeHintElem.hidewhendead = true;
	self.MeleeHintElem.sort = -1;
	self.MeleeHintElem endon( "death" );

	self waittill( "melee_win", melee_won );
	self thread melee_hint_fade( melee_won );
}


melee_hint_fade( fade )
{
	if ( IsDefined( self ) && isDefined( self.MeleeHintElem ) )
	{
		hud = self.MeleeHintElem;
		if ( fade )
		{
			time = 0.5;
			hud ChangeFontScaleOvertime( time );
			hud.fontScale = hud.fontScale * 1.5;
			hud.glowColor = ( 0.3, 0.6, 0.3 );
			hud.glowAlpha = 1;
			hud FadeOverTime( time );
			hud.color = ( 0, 0, 0 );
			hud.alpha = 0;
			wait( time );
			hud maps\_hud_util::destroyElem();
		}
		else
		{
			hud maps\_hud_util::destroyElem();
		}
	}
}

melee_dof()
{
	flag_set("pause_dynamic_dof");
	maps\_art::dof_enable_script( 0, 10, 10, 70, 100, 10, 0.5 );
	
	level.player waittill( "melee_dof_adjust" );
	
	maps\_art::dof_disable_script( 1 );
	wait( 1 );
	flag_clear( "pause_dynamic_dof" );
}

/********************************
 *       GREENLIGHT STUFF       *
 ********************************/

e3_text_hud( text, holdtime )
{
	ht = 27;
	
	hudelem = NewHudElem();
	hudelem.alignX = "center";
	hudelem.alignY = "middle";
	hudelem.horzAlign = "center";
	hudelem.vertAlign = "middle";

//	hudelem.x = 80;
//	hudelem.y = 80 + index * 18;
	hudelem.x = 0;
	hudelem.y = ht;
	hudelem SetText( text );
	hudelem.alpha = 0;
	hudelem.font = "objective";
	hudelem.foreground = true;
	hudelem.sort = 150;
	hudelem.color		   	= ( 0.85, 0.93, 0.92 );
	
	hudelem.fontScale = 1.75;
//	hudelem FadeOverTime( 0.5 );
//	hudelem.alpha = 1;
	
	hudelem MoveOverTime( 1 );
	hudelem.y = 0;
	hudelem FadeOverTime( 1 );
	hudelem.alpha = 1;
	wait( 1 );
	wait( holdtime );
	hudelem MoveOverTime( 1 );
	hudelem.y = -1*ht;
	hudelem FadeOverTime( 1 );
	hudelem.alpha = 0;
	wait( 1 );
	hudelem destroy();
}

greenlight_check()
{
//	if (IsDefined (level.start_point))
//	{
//		if (level.start_point == "e3")
//			return true;
//		else
//			return false;
//	}
	return GetDvarInt( "e3", 0 );
}