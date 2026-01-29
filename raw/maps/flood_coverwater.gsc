#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

init_coverwater( endon_event )
{
	if( !IsDefined( endon_event ) )
		endon_event = "";
	
	// array of flag volumes used that are also used to fizzle flashbangs
	level.cw_trigger_volumes = [];
	
	// FIX TimS hmm....
	level.current_audio_zone = get_audio_zone();
	
	// variable inits
	level.cw_waterwipe_above_playing = false;
	level.cw_waterwipe_under_playing = false;
	
	// variables that can be modified externally
	
//	self.cw_in_rising_water
//	self.cw_ai_only_stand
//	level.cw_znear_default
	
	// FIX JKU look into removing this func since it's specific to rising water or better integrate rising water.
	level.cw_player_in_rising_water = false;
	// default time the player is allowed to be underneath cover water
	level.cw_player_allowed_underwater_time = 15;
	// do we damage him if he exceeds the time?
	level.cw_player_damage_underwater_time_exceeded = true;

	level.cw_vision_under	 = undefined;
	level.cw_bloom_under	 = undefined;
	level.cw_fog_under		 = undefined;
	level.cw_waterwipe_above = undefined;
	level.cw_waterwipe_under = undefined;
	
	// turn the waterwipe off
	level.cw_no_waterwipe = false;
	// animate the player when he's drowning, take the gun away, etc...
	level.cw_player_drowning_animate = true;

	// this is set when you've transitioned from being in water to out of water
	flag_init( "cw_player_out_of_water" );
	// this is set when you're inside a flag volume that defines the coverwater area
	flag_init( "cw_player_in_water" );
	// this is set when youre under cover water
	flag_init( "cw_player_underwater" );
	// this is set when you're in coverwater but your head is above water
	flag_init( "cw_player_abovewater" );
	// external flag that if set we don't adjust the players speed when you're in the water
	flag_init( "cw_player_no_speed_adj" );
	// this is set if you've been underwater too long and have been forced up and are no longer allowed to crouch underwater for a brief period
	flag_init( "cw_player_crouch_disabled" );
	// this is set if you've been underwater too long and have been forced to stand
	flag_init( "cw_player_make_stand" );
	// audio investigate that this is even needed
	flag_init( "underwater_forced_surface" );
	
	// FIX JKU these need to get moved into someplace that makes sense
	// minot bokehdots when you're sprinting on coverwater
	level._effect[ "player_sprint_bokehdots" ] = LoadFX ( "vfx/gameplay/screen_effects/scrnfx_water_bokeh_dots_inst_16" );
	// view aligned screen splash when you're sprinting in coverwater
	// FIX JKU this can be removed now I think
//	level._effect[ "player_splash_view" ] = loadfx( "vfx/ambient/water/splash_lens_02" );
	// bullet trail created under the water surface when a bullet is fired into the water
	level._effect[ "bullet_trail" ] = LoadFX( "fx/water/flooded_underwater_bullet_trail" );
	// player bubbles when you are near or out of breath
	level._effect[ "scuba_bubbles_breath_player" ] = LoadFX( "fx/water/scuba_bubbles_breath_player" );
	// screen wipe when you go under coverwater
	level._effect[ "waterline_under" ] = loadfx( "vfx/moments/flood/water_waterline_swept_01" );
	// screen wipe when you transition from under to above cover water
	level._effect[ "waterline_above" ] = loadfx( "vfx/ambient/water/splash_lens_03" );
	// flash fizzle when they explode in a coverwater area
	level._effect[ "cw_fizzle_flashbang" ] = LoadFX( "fx/water/flooded_body_splash" );
	// when ai moves underwater
	level._effect[ "underwater_movement" ] = LoadFX( "fx/water/flood_water_wake" );
	// not hooked up yet but could be....
	// when ai stops underwater
	level._effect[ "underwater_stop" ] = LoadFX( "fx/water/flood_water_stand" );
	// when ai moves
	level._effect[ "water_movement" ] = LoadFX( "fx/water/flood_water_wake" );
	// when ai stops
	level._effect[ "water_stop" ] = LoadFX( "fx/water/flood_water_stand" );
	// when ai moves in the rising water section
	level._effect[ "water_movement_rising" ] = LoadFX( "fx/water/flood_water_wake_rising" );
	// when ai stops in the rising water section
	level._effect[ "water_stop_rising" ] = LoadFX( "fx/water/flood_water_stand_rising" );
	// when the player is moving walk speed or faster
	level._effect[ "water_movement_player" ] = LoadFX( "fx/water/flood_water_wake" );
	// when the player is slowwer than walk speed
	level._effect[ "water_stop_player" ] = LoadFX( "fx/water/flood_water_stand" );
	// when the ai is sprinting
	level._effect[ "sprint_splash" ] = LoadFX( "vfx/moments/flood/flood_ai_water_splash_01" );
	// when the ai is sprinting in rising water
	level._effect[ "sprint_splash_rising" ] = LoadFX( "vfx/moments/flood/flood_ai_water_splash_rising_01" );
	// when the player is sprinting
	level._effect[ "sprint_splash_player" ] = LoadFX( "vfx/moments/flood/flood_player_water_splash_01" );
	// when you melee the water surface
	level._effect[ "melee_water" ] = LoadFX( "fx/water/flooded_sprint_splash" );
	// splash played when you're underwater and fire out of the water.
	level._effect[ "water_under_splash" ] = LoadFX( "fx/water/flood_water_wake" );
	// used by ai when they enter a water trigger volume at a low velocity
	level._effect[ "cw_enter_splash_small" ] = LoadFX( "fx/water/flooded_sprint_splash" );
	// used by ai when they enter a water trigger volume at a high velocity
	level._effect[ "cw_enter_splash_big" ] = LoadFX( "fx/water/flooded_body_splash" );
	
	// JOWs
	level._effect[ "scrnfx_water_splash_high" ] = LoadFX( "vfx/gameplay/screen_effects/scrnfx_water_splash_high" );
	level._effect[ "scrnfx_water_splash_low" ]	= LoadFX( "vfx/gameplay/screen_effects/scrnfx_water_splash_low" );
	level._effect[ "scrnfx_water_splash_med" ]	= LoadFX( "vfx/gameplay/screen_effects/scrnfx_water_splash_med" );

	// new warlord like stuff
	level._effect[ "cw_water_emerge_weapon" ] = LoadFX( "vfx/moments/flood/flood_water_emerge_weapon" );
	level._effect[ "cw_character_drips"	 ]	  = LoadFX( "vfx/moments/flood/flood_character_drips" );
	level._effect[ "cw_player_drips"	 ]	  = LoadFX( "vfx/moments/flood/flood_player_drips" );
	
	// Factory water splash stuff
	level._effect[ "splash_body_shallow" ]		 = LoadFX( "vfx/ambient/water/splash_body_shallow" );
	level._effect[ "factory_single_splash_plr" ] = LoadFX( "vfx/moments/factory/factory_single_splash_plr" );
	
	
	PreCacheItem( "coverwater_magicbullet_above" );
	PreCacheItem( "coverwater_magicbullet_under" );

	thread init_waistwater_archetype();

	// setup water splash fx entity infront of the player
	thread setup_player_view_water_fx_source();
	
	// FIX JKU hmm...
	thread sfx_set_audio_zone_after_deathsdoor();
	
	thread fizzle_flashbangs_think();

	// FIX JKU should this be area specific???  if so move to the register script
	// blur when your eye level gets close to the surface.  turned off for now	
	thread player_surface_blur_think( endon_event );

	thread start_coverwater( endon_event );
	
//	level.player thread splash_on_player( endon_event );
}

register_coverwater_area( area, endon_event )
{
	if( !IsDefined( endon_event ) )
		endon_event = "";
	
	// FIX JKU need to come back to this when there is no water with more than one ent in Flood
	// setup the bullets and bubble trails under the water
//	water_top = GetEnt( area + "_top", "targetname" );
//	water_top thread water_surface_think( endon_event );
	array_thread( GetEntArray( area + "_above", "targetname" ), ::water_surface_think, endon_event );
	array_thread( GetEntArray( area + "_under", "targetname" ), ::water_surface_think, endon_event );

	coverwater_trigger_vol = GetEnt( area + "_trigger", "targetname" );
	coverwater_trigger_vol thread trigger_volume_think( endon_event );
	level.cw_trigger_volumes = array_add( level.cw_trigger_volumes, coverwater_trigger_vol );
}

flag_checker()
{
	while( 1 )
	{
		if( flag( "cw_player_in_water" ) )
			JKUprint( "flag getting set!" );
		
		waitframe();
	}
}

start_coverwater( endon_event )
{
	level endon( endon_event );
	
	level.cw_znear_default = GetDvar( "r_znear" );

	while( 1 )
	{
		// wait till player is in water
		flag_wait( "cw_player_in_water" );
		
		flag_clear( "cw_player_out_of_water" );
		
		SetSavedDvar( "r_znear", 0.7 );
		
		// check the water level and adjust your speed.  this needs to get called after the in water flag has been set
		thread player_water_height_think( endon_event );
		
		// no prone in the water
		level.player AllowProne( false );
		
		// check if you're underneath or not
		thread player_underwater_think( endon_event );
	
		// wait till player is out of water add defined by a flag volume created in radiant
		flag_waitopen( "cw_player_in_water" );
		
		flag_set( "cw_player_out_of_water" );

		SetSavedDvar( "r_znear", level.cw_znear_default );

		level.cw_player_is_drowning = undefined;
	
		// JKU temp removing sound
	//	level.player playsound( "player_stairs_outowater" );
		
		level.player AllowProne( true );

//		thread kill_above_water_fx();
	}
}

player_underwater_think( endon_event )
{	
	level endon( endon_event );
	level endon( "cw_player_out_of_water" );

	vel = ( 0, 0, 0 );
	prevEye = level.player GetEye();
	while( 1 )
	{
		eye = level.player GetEye();
		vel = eye - prevEye;
		prevEye = eye;
		if( is_player_eye_underwater( -20 ) && !flag( "cw_player_underwater" ) && vel[ 2 ] < -12 )
		{
			if( !level.cw_no_waterwipe && !level.cw_waterwipe_under_playing )
			{
				JKUprint( "waterline under " + vel[ 2 ] );
 				thread fx_waterwipe_under();
			}
		}
		// the -8 vel is important because that's the typical stair height so we don't want to look ahead more than 8" with less than an 8 vel
		else if( is_player_eye_underwater( -9 ) && !flag( "cw_player_underwater" ) && vel[ 2 ] < -8 )
		{
			if( !level.cw_no_waterwipe && !level.cw_waterwipe_under_playing )
			{
				JKUprint( "waterline under 2 " + vel[ 2 ] );
 				thread fx_waterwipe_under();
			}
		}
		else if( is_player_eye_underwater( -4 ) && !flag( "cw_player_underwater" ) && vel[ 2 ] < -1 )
		{
			if( !level.cw_no_waterwipe && !level.cw_waterwipe_under_playing )
			{
				JKUprint( "waterline under 3 " + vel[ 2 ] );
 				thread fx_waterwipe_under();
			}
		}
 		
 		if ( is_player_eye_underwater() )
		{
			break;
		}
		waitframe();
	}
	
	// JKU not weapon switching for now
//	thread instant_weapon_switch ( "going underwater" );

	flag_set( "cw_player_underwater" );
	flag_clear( "cw_player_abovewater" );
	
	thread create_player_going_underwater_effects();
	
	if( IsDefined( level.swept_away ) && level.swept_away == 0 )
	{
		level.player SetClientTriggerAudioZone( "flood_underwater", 0.01 );
	}

	// when you go underwater, the enemies aren't your enemies anymore
	thread ai_enemy_tracking( "underwater", endon_event );
	// Start the hold breath timer
	thread player_breath_timer( endon_event );
	thread kill_above_water_fx();
	
	// Eliminate any outstanding water sheet effects
	level.player SetWaterSheeting( 0 );
	
 	// level.player AllowFire(false);

	vel = ( 0, 0, 0 );
	prevEye = level.player GetEye();
	while( 1 )
	{
		eye = level.player GetEye();
		vel = eye - prevEye;
		prevEye = eye;
		if( !is_player_eye_underwater( 9 ) && !flag( "cw_player_abovewater" ) && vel[ 2 ] > 7 )
		{
			if( !level.cw_no_waterwipe && !level.cw_waterwipe_above_playing )
			{
//				IPrintLn( "waterline above " + vel[ 2 ] );
 				thread fx_waterwipe_above();
			}
		}

		if( !is_player_eye_underwater() )
		{
			break;
		}
		waitframe();
	}
	
	// JKU not weapon switching for now
//	thread instant_weapon_switch ( "going abovewater" );
 	
	flag_set( "cw_player_abovewater" );
	flag_clear( "cw_player_underwater" );
	
	thread create_player_surfacing_effects();
	level.player thread drip_on_player( endon_event );

	level.cw_player_is_drowning = undefined;
		
	// FIX JKU stuff to make the enemies hate you again.  temp solution.  need to treat the player and allies separately based on their water state
	thread ai_enemy_tracking( "abovewater", endon_event );
	
	player_stop_bubbles();
	
	level.player ClearClientTriggerAudioZone( 0.01 );

	// Start this script over
	thread player_underwater_think( endon_event );
}

player_in_coverwater( trigger_volume )
{
	trigger_volume endon( "death" );
	level.player endon( "death" );
	
	flag_set( "cw_player_in_water" );
	
	// IMPORTANT!!!
	waittillframeend;
	
	level.player thread entity_fx_and_anims_think( "cw_player_out_of_water", ( 0, 0, 0 ) );

	// remove all clever vision and fog stuff.
/*	
	// FIX JKU need to come back to this.  Do we really want all of these to be specific for each area?  The artists aren't currently using this functionality			
	// ALSO, the vision set stuff is pretty hacky becuase there's not a way that I know of to test if a vision set is actually loaded
	area = GetSubStr( trigger_volume.targetname, 0, trigger_volume.targetname.size - 5 );

	if( IsDefined( level.cw_vision_under_default ) )
		level.cw_vision_under = level.cw_vision_under_default;
	else
		level.cw_vision_under = area + "_under";
	
	if( IsDefined( level.cw_bloom_under_default ) )
		level.cw_bloom_under = level.cw_bloom_under_default;
	else
		level.cw_bloom_under = area + "_bloom";

	if( IsDefined( level.fog_set[ area + "_fog" ] ) )
		level.cw_fog_under = area + "_fog";
	// FIX JKU not idea why this was an else if and not and else.  Need to come back to this and make sure this change is safe
//	else if( IsDefined( level.cw_fog_under_default ) && IsDefined( level.fog_set[ level.cw_fog_under_default ] ) )
	else
		level.cw_fog_under = level.cw_fog_under_default;
	
	if( IsDefined( level._effect[ area + "_waterwipe_above" ] ) )
		level.cw_waterwipe_above = area + "_waterwipe_above";
	else if( IsDefined( level.cw_waterwipe_above_default ) && IsDefined( level._effect[ level.cw_waterwipe_above_default ] ) )
		level.cw_waterwipe_above = level.cw_waterwipe_above_default;
	
	if( IsDefined( level._effect[ area + "_waterwipe_under" ] ) )
		level.cw_waterwipe_under = area + "_waterwipe_under";
	else if( IsDefined( level.cw_waterwipe_under_default ) && IsDefined( level._effect[ level.cw_waterwipe_under_default ] ) )
		level.cw_waterwipe_under = level.cw_waterwipe_under_default;
*/

	while( level.player IsTouching( trigger_volume ) )
		waitframe();

	flag_clear( "cw_player_in_water" );
}

ai_in_coverwater( trigger_volume )
{
	trigger_volume endon( "death" );
	self endon( "death" );

	self.in_coverwater = true;
	self ent_flag_set( "cw_ai_in_of_coverwater" );
	self ent_flag_clear( "cw_ai_out_of_coverwater" );
	
	if( IsDefined( self.cw_ai_only_stand ) )
		self.cw_ai_only_stand = self.cw_ai_only_stand;
	else
		self.cw_ai_only_stand = true;

	if( self.team == "axis" )
	{
		self.cw_previous_grenadeammo = self.grenadeammo;
		self.grenadeammo = 0;
		self.cw_previous_longdeath = self.script_longdeath;
		self.script_longdeath = 0;
	}
	
	self thread entity_fx_and_anims_think( "cw_ai_out_of_coverwater", ( 0, 0, 0 ) );
	
//	rnd_playbackrate = RandomFloatRange( 0.7, 0.75 );
//	self.moveplaybackrate = rnd_playbackrate;
//	self.movetransitionrate = rnd_playbackrate;
//	self.animplaybackrate = rnd_playbackrate;

	while( self IsTouching( trigger_volume ) )
		waitframe();

	self.in_coverwater = false;
	
	self ent_flag_set( "cw_ai_out_of_coverwater" );
	self ent_flag_clear( "cw_ai_in_of_coverwater" );
	
	if( self.team == "axis" )
	{
		self.grenadeammo = self.cw_previous_grenadeammo;
		self.script_longdeath = self.cw_previous_longdeath;
	}
}

// do things when you're in an area's flag volume
trigger_volume_think( endon_event )
{
	self endon( "death" );
	level endon( endon_event );

	while( 1 )
	{
		self waittill( "trigger", ent );
		
		ents = GetAIArray( "axis" );
		ents = array_combine( ents, GetAIArray( "allies" ) );
		ents = array_add( ents, level.player );
		
		touching_ents = self GetIsTouchingEntities( ents );
//		IPrintLn( touching_ents.size );
		
		foreach( ent in touching_ents )
		{
			if( IsPlayer( ent ) )
			{
				if( !flag( "cw_player_in_water" ) )
					level.player thread player_in_coverwater( self );
			}
			else
			{
				if( !ent ent_flag_exist( "cw_ai_in_of_coverwater" ) )
				{
					ent ent_flag_init( "cw_ai_in_of_coverwater" );
					ent ent_flag_init( "cw_ai_out_of_coverwater" );
					ent thread ai_in_coverwater( self );
				}
				else if( !ent ent_flag( "cw_ai_in_of_coverwater" ) )
				{
					ent thread ai_in_coverwater( self );
				}
			}
		}
		waitframe();
	}
}

// create bubble trail fx and bullets when top water plane is hit.
// when top water is surface type "water" it will have no penetration so we need to create magicbullets.
water_surface_think( endon_event )
{
	self endon( "death" );
	level endon( endon_event );

	// FIX JKU this is pretty ghetto, there must be a better way to make something invulnerable
	self.health = 1000000;
	self SetCanDamage( true );

	while( 1 )
	{
		// Wait until the bullet hits the object
		// this is only capable of dealing with one bullet per frame, so if multiple bullets hit the surface on the same frame, only the first one will get processed...
		self waittill( "damage", damage, attacker, impact_vec, point, damageType, modelName, tagName );
		self.health = 1000000;
		if( damageType == "MOD_MELEE" )
		{
			PlayFX( getfx( "melee_water" ), point );
		}
		// FIX JKU will need to change this if/when the chopper model changes and we shouldn't be doing it this way anyways as sometimes we will want a helicopter shooting into the water.
		else if ( attacker.classname != "script_vehicle_nh90" )
		{
			if( GetSubStr( self.targetname, self.targetname.size - 5 ) == "above" )
			{
				start_point = ( point - ( 0, 0, 1 ) );
				end_point = ( start_point + ( 120 * impact_vec ) );
				// FIX JKU need to come back to this!  Does it matter who the attacker is?  if not we don't need the if statement
				if( IsPlayer( attacker ) )
				{
					// FIX JKU had to change this from using the players weapon because sometimes the player would die before it got here to create the magic bullet.
					// also need to make sure this works with noob tubes and rpg's
	//				MagicBullet( level.player GetCurrentWeapon(), start_point, end_point, level.player );
					MagicBullet( "coverwater_magicbullet_under", start_point, end_point, level.player );			
				}
				else
				{
					MagicBullet( "coverwater_magicbullet_under", start_point, end_point );			
				}
				PlayFX( getfx( "bullet_trail" ), point, impact_vec );
			}
			else
			{
				start_point = ( point + ( 0, 0, 1 ) );
				end_point = ( start_point + ( 120 * impact_vec ) );
				if( IsPlayer( attacker ) )
				{
					MagicBullet( "coverwater_magicbullet_above", start_point, end_point, level.player );			
				}
				else
				{
					MagicBullet( "coverwater_magicbullet_above", start_point, end_point );			
				}
				PlayFX( getfx( "water_under_splash" ), point - ( 0, 0, 1 ) );
			}
		}
		waitframe();
	}
}

// check how deep in water we are and adjust speed and jump accordingly
player_water_height_think( endon_event )
{
	level endon( endon_event );
	
	// remember the default jump height so we can change it back
	if( !IsDefined( level.flood_player_default_jump_height ) )
		level.flood_player_default_jump_height = GetDvarFloat( "jump_height" );
	
	player_speed_underwater = 40;
	player_speed_coverwater = 50;

	while( flag( "cw_player_in_water" ) )
	{
		// start a bullet trace upwards from eye level to see if we're underwater
		trace = BulletTrace( level.player.origin, level.player GetEye(), false, self );
		
		if( is_player_eye_underwater() )
		{
			// only adjust the player speed if this flag isn't set.  this is somewhat of a special case to handle the warehouse and coming out of the stairs.
			if( !flag( "cw_player_no_speed_adj" ) )
			{
				if( IsDefined( level.cw_player_is_drowning ) && level.cw_player_is_drowning )
				{
					if( level.cw_player_drowning_damage_count > 10 )
						maps\flood_util::player_water_movement( ( player_speed_underwater * 0.5 ), 0.25 );
					else
						maps\flood_util::player_water_movement( ( player_speed_underwater * ( 1 - ( level.cw_player_drowning_damage_count * 0.05 ) ) ), 0.25 );
				}
				else
				{
					maps\flood_util::player_water_movement( player_speed_underwater, 0.25 );
				}
			}
			
			// FIX JKU make this a percentage based on the actual default since it's possible that the dvar was changed before we got into here?  Or maybe we don't care.
			SetSavedDvar( "jump_height", level.flood_player_default_jump_height * 0.4 );
		}
		else if ( trace[ "surfacetype" ] == "water" )
		{
			height_above_feet = ( abs( level.player.origin[ 2 ] - trace[ "position" ][ 2 ] ) );
			
			// first number is the percentage we're going to cut off
			// second number is the amount of height we want to do it in
			new_speed = 100 - ( height_above_feet * ( player_speed_coverwater / 48 ) );
			
			// cap it at 100.  probably a better way to do this.
			if( new_speed > 100 )
				new_speed = 100;
			else if( new_speed < player_speed_coverwater )
				new_speed = player_speed_coverwater;
			
			// last number is the percentage we scale the water speed by to determine the new jump height. 50 *.008 = .4
			jump_height = level.flood_player_default_jump_height * ( new_speed * 0.008 );
			SetSavedDvar( "jump_height", jump_height );

			if( !flag( "cw_player_no_speed_adj" ) )
				maps\flood_util::player_water_movement( new_speed, .25 );
		}
		wait 0.2;
	}

//	IPrintLn( "jump and speed reset to default" );
	SetSavedDvar( "jump_height", level.flood_player_default_jump_height );

	if( !flag( "cw_player_no_speed_adj" ) )
		maps\flood_util::player_water_movement( 100, 0.25 );
}

// blur when your eyes are close to the surface
player_surface_blur_think( endon_event )
{
	level endon( endon_event );
	
	if( !IsDefined( level.surface_blur ) )
	{
		level.surface_blur = true;
		blur_at_zero = true;
		
		while( 1 )
		{
			while( flag( "cw_player_in_water" ) )
			{
				eyePos = level.player GetEye();
				range = 1.5;
				max_blur = 25;
				trace = BulletTrace( eyePos + ( 0, 0, range * -1 ), eyePos +  ( 0, 0, range ), false, self );
				if( trace[ "surfacetype" ] == "water" )
				{
					blur_strength = Distance( trace[ "position" ], eyePos ) * ( max_blur / range );
//					IPrintLn( blur_strength );
					SetBlur( max_blur - blur_strength, 0.05 );
					blur_at_zero = false;
				}
				else if( !blur_at_zero )
				{
//					IPrintLn( "setting to zero" );
					SetBlur( 0, 0.5 );
					blur_at_zero = true;
				}
				waitframe();
			}
			flag_wait( "cw_player_in_water" );
		}
	}
}

// FIX JKU somehow the rising stuff should really get removed from this???
// FX to play around the actor it's been called on
entity_fx_and_anims_think( endflag, offset, entry_splash )
{
	level endon( endflag );
	self endon( endflag );
	self endon( "death" );
	
	if( !IsDefined( entry_splash ) )
		entry_splash = true;
	
	cw_last_splash_fx_time = GetTime();
	
	if( !IsPlayer( self ) && entry_splash )
	{
		// FIX JKU need to test for vel so we can do the correct one
		// FIX JKU why is this even here?  to play a splash when they first enter the water???
		PlayFX( getfx( "cw_enter_splash_small" ), self.origin );
	}

	if( !IsDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	
	if( !IsDefined( self.cw_in_rising_water ) )
	{
		self.cw_in_rising_water = false;
	}
	
	while( 1 )
	{
//		IPrintLn( self.script_friendname + ": " + endflag );
		
		if( !IsPlayer( self ) && self.cw_in_rising_water )
			wait( RandomFloatRange( 0.05, 0.1 ) );
		else
		wait( RandomFloatRange( 0.15, 0.25 ) );
		
//		if( !IsPlayer( self ) )
//			IPrintLn( self.unique_id + " " + self.team + ": doing fx" );
//		else
//			IPrintLn( "player doing fx" );
		
		// FIX JKU it's possible to optimize this so it doesn't do the collision check when the player is underwater,
		// but probably not worthwhile since a lot of things down the line assume the check has been done
		start = self.origin;
		end = start + ( 0, 0, 84 );
		trace = BulletTrace( start, end, false, undefined );
		
		// early out if we're not in water and set the anims to not in water
		if ( trace[ "surfacetype" ] != "water" )
			continue;
		
		// how deep you must be into the water to be considered deep enough to play the water anims
		water_anim_depth = 36;
		// depth of the water
		depth = trace[ "position" ][ 2 ] - self.origin[ 2 ];

		if( !IsPlayer( self ) )
		{
			if ( !self.cw_in_rising_water && depth < water_anim_depth && IsDefined( self.animArchetype ) )
			{
//				IPrintLn( "not in water, switching to normal anims" );
				self AllowedStances( "prone", "crouch", "stand" );
				self clear_archetype();
				self.maxFaceEnemyDist = 512;
			}
	
			// check for anim swapping
			if( !self.cw_in_rising_water && depth > water_anim_depth )
			{
				if( !IsDefined( self.animArchetype ) || self.animArchetype != "waist_water" )
				{
//					IPrintLn( "in water, switching to water anims" );
					if( self.cw_ai_only_stand )
					{
//						IPrintLn( self.team + " forcing stand" );
						self AllowedStances( "stand" );
					}
					self.animarchetype = "waist_water";
					self.maxFaceEnemyDist = 1024;
				}
			}
		}
		
		// FIX JKU come back to this or remove
		// water drips and stuff on allies when they're in the water or emerging
//		thread do_wet_fx();

		fx = "water_movement";
		// FIX JKU player can have his own water stop fx but we're not using one yet
		// stop fx only?  why not fold this into the rest of the stuff?
		if( IsPlayer( self ) )
		{
			if( !flag( "cw_player_underwater" ) )
			{
				if ( Distance( self GetVelocity(), ( 0, 0, 0 ) ) < 5 )
				{
					fx = "water_stop_player";
				}
				else
				{
					fx = "water_movement_player";
				}
			}
		}
		else if( IsDefined( level._effect[ "water_" + self.a.movement ] ) )
		{
			if( self.cw_in_rising_water )
				fx = "water_" + self.a.movement + "_rising";
			else
			fx = "water_" + self.a.movement;
		}

		water_fx = getfx( fx );
		start = trace[ "position" ] + offset;		
		// changed this to play the rings further infront of you if you're moving fast/running FORWARD ONLY (for player)
		// FIX JKU this could be improved to vary the distance based on speed, but probably not necessary
		if( IsPlayer( self ) )
		{
			if( !flag( "cw_player_underwater" ) )
			{
				if ( self GetNormalizedMovement()[ 0 ] > 0 )
				{
					playerVelocity = Distance( self GetVelocity(), ( 0, 0, 0 ) );
					
					if( playerVelocity > 100 )
					{
					// 130 is sprinting
						if( GetTime() - cw_last_splash_fx_time > 750 )
						{
//							if( cointoss() )
//								self SetWaterSheeting( 1, RandomFloatRange( 0.35, 0.75 ) );
//							if( cointoss() )
//								PlayFXOnTag( GetFX( "player_sprint_bokehdots" ), level.cw_player_view_fx_source, "tag_origin" );
//							thread maps\flood_fx::fx_waterdrops_3();
//	
//							switch( RandomInt( 2 ) )
//							{
//								case 0:
//									cw_last_splash_fx_time = GetTime();
//									PlayFXOnTag( getfx( "vfx_scrnfx_water_splash_0" ), level.cw_player_view_fx_source, "tag_origin" );
//									break;
//								case 1:
//									cw_last_splash_fx_time = GetTime();
//									PlayFXOnTag( getfx( "vfx_scrnfx_water_splash_1" ), level.cw_player_view_fx_source, "tag_origin" );
//									break;
//							}
							cw_last_splash_fx_time = GetTime();
								
							if( RandomInt( 3 ) == 0 )
							{
								PlayFXOnTag( level._effect[ "scrnfx_water_splash_med" ], level.cw_player_view_fx_source, "tag_origin" );
							}
							else
							{
								PlayFXOnTag( level._effect[ "scrnfx_water_splash_high" ], level.cw_player_view_fx_source, "tag_origin" );
							}
						}
					}
					else if( playerVelocity > 40 )
					{
						// Walking
						if( GetTime() - cw_last_splash_fx_time > 1500 )
						{
							cw_last_splash_fx_time = GetTime();
							PlayFXOnTag( level._effect[ "scrnfx_water_splash_low" ], level.cw_player_view_fx_source, "tag_origin" );
						}
					}
				}
			}
		}
		else if( self.a.movement == "run" )
		{
			// don't play this for waist water guys
			if( IsDefined( self.animArchetype ) && self.animArchetype != "waist_water" || !IsDefined( self.animArchetype ) )
			{
				start = start + ( 25 * AnglesToForward( self.angles ) );
				if( self.cw_in_rising_water )
					PlayFX( getfx( "sprint_splash_rising" ), start );
				else
				PlayFX( getfx( "sprint_splash" ), start );
			}
		}
			
		if( self.cw_in_rising_water )
		{
			if( !flag( "cw_player_underwater" ) )
				self thread fx_water_surface_floater( start, water_fx, trace[ "entity" ], endflag );
		}
		// FIX JKU need to come back to this and make sure it's only run based on the flag volume youre in
		else if( IsPlayer( self ) && IsDefined( level.cw_player_in_rising_water ) && level.cw_player_in_rising_water )
		{
			if( !flag( "cw_player_underwater" ) )
				self thread fx_water_surface_floater( start, water_fx, trace[ "entity" ], endflag );
		}
		else
		{
			angles = ( 0, self.angles[ 1 ], 0 );
			forward = AnglesToForward( angles );
			up = AnglesToUp( angles );
			
			// play this if you're not underwater
			// fudge up a few inches because we want to account for the whold head
			if( self GetEye()[ 2 ] + 6 - depth > 0 )
			{
				PlayFX( water_fx, start, up, forward );
			}
			// play this if you are underwater
			else
			{
				PlayFX( getfx( "underwater_movement" ), start, up, forward );
			}
		}
	}
}

do_wet_fx()
{
	wetfx_tags = [];
	wetfx_tags[ 0 ] = "J_Elbow_LE";
	wetfx_tags[ 1 ] = "J_Elbow_RI";
	wetfx_tags[ 2 ] = "J_Wrist_LE";
	wetfx_tags[ 3 ] = "J_Wrist_RI";
	wetfx_tags[ 4 ] = "TAG_STOWED_BACK";
	wetfx_tags[ 5 ] = "J_Neck";

	// deep enough to play some drips
	if ( 0 )
//	if ( depth > 4 && depth < 24 && !IsPlayer( self ) )
	{
		if( !IsDefined( self.cw_playing_wet_fx ) )
		   self.cw_playing_wet_fx = false;
		
		if( !self.cw_playing_wet_fx )
		{
			JKUprint( "playing wet fx" );
			self.cw_playing_wet_fx = true;
			
//			PlayFXOnTag( GetFX( "cw_water_emerge_weapon" ), self, "TAG_FLASH" );
//			PlayFXOnTag( GetFX( "cw_character_drips" ), self, "J_Elbow_LE" );
//			PlayFXOnTag( GetFX( "cw_character_drips" ), self, "J_Elbow_RI" );
//			PlayFXOnTag( GetFX( "cw_character_drips" ), self, "J_Wrist_LE" );
//			PlayFXOnTag( GetFX( "cw_character_drips" ), self, "J_Wrist_RI" );
//			PlayFXOnTag( GetFX( "cw_character_drips" ), self, "TAG_STOWED_BACK" );
//			PlayFXOnTag( GetFX( "cw_character_drips" ), self, "J_Neck" );
		}
//		self.lastWaterEmergeTime = ( GetTime() );
//		self thread ally_water_emerge_fx();

//		num_tags = GetNumParts( self );
//		for( i = 0; i < num_tags; i++ )
//		{
//			tag_name = GetPartName( self, i );
//		
//			if( tag_name == "J_Elbow_RI" )
//			{
//				PlayFX( GetFX( "cw_character_drips" ), self, "J_ElbowTwist_LE" );
//			}
//			waitframe();
//		}
		
		if( self.a.movement == "run" )
		{
			foreach( wetfx_tag in wetfx_tags )
			{
				if( RandomInt( 3 ) == 0 )
				{
					wetfx_tag_pos = self GetTagOrigin( wetfx_tag ) + ( RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ) );
					PlayFX( GetFX( "cw_character_drips" ), wetfx_tag_pos );
				}
			}
		}
	}
	else
	{
		if( !IsDefined( self.cw_playing_wet_fx ) )
		   self.cw_playing_wet_fx = false;

		if( self.cw_playing_wet_fx )
		{
	   		JKUprint( "stopping wet fx" );
	   		self.cw_playing_wet_fx = false;
			
			StopFXOnTag( GetFX( "cw_water_emerge_weapon" ), self, "TAG_FLASH" );

			// some drips after you get out of the water
			foreach( wetfx_tag in wetfx_tags )
			{
				wetfx_tag_pos = self GetTagOrigin( wetfx_tag ) + ( RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ) );
				PlayFX( GetFX( "cw_character_drips" ), wetfx_tag_pos );
			}

			// delay for a bit after we come out of the water
//			wait 2;
			
//			StopFXOnTag( GetFX( "cw_character_drips" ), self, "J_Elbow_LE" );
//			StopFXOnTag( GetFX( "cw_character_drips" ), self, "J_Elbow_RI" );
//			StopFXOnTag( GetFX( "cw_character_drips" ), self, "J_Wrist_LE" );
//			StopFXOnTag( GetFX( "cw_character_drips" ), self, "J_Wrist_RI" );
//			StopFXOnTag( GetFX( "cw_character_drips" ), self, "TAG_STOWED_BACK" );
//			StopFXOnTag( GetFX( "cw_character_drips" ), self, "J_Neck" );
		}
	}
}

// create a tag that is linked to the rising water so fx played in that area move up with the water
fx_water_surface_floater( start, water_fx, trace_ent, endflag )
{
	self endon( "death" );
	self endon( endflag );
	level endon( endflag );
	
	// move up a touch to deal with irregular surface
	offset =  ( 0, 0, 2 );
	
	waterball = Spawn( "script_model", start + offset );
	waterball SetModel( "tag_origin" );
	waterball Hide();
	waterball.angles = ( -90, 0, 0 );
	waterball LinkTo( trace_ent );
	
//	waterball2 = Spawn( "script_model", start + offset );
//	waterball2 SetModel( "com_hand_radio" );
//	waterball2 LinkTo( trace_ent );

	PlayFXOnTag( water_fx, waterball, "tag_origin" );
	
	wait 3;
	waterball Delete();
//	waterball2 Delete();
}

is_player_eye_underwater_new( vel )
{
	if ( level.player ButtonPressed( "BUTTON_B" ) && vel[ 2 ] == 0 ) 
	{
		vel += ( 0, 0, -5 );
	}
	
	eyePos = level.player GetEye( true );
//	eyePos = level.player GetEye( true ) + ( vel * 3 );
	trace = BulletTrace( eyePos, ( eyePos + ( 0, 0, 250 ) ), false, self );
	if( trace[ "surfacetype" ] == "water" )
	{
		return true;
	}
	
	return false;
}

// return wether or not the players eye is underwater
is_player_eye_underwater( z_offset )
{
	// check slightly on the opposite end for each case if offset defined
	if( !IsDefined( z_offset ) )
		z_offset = 0;
	
	// Is the player's eye level above the height given?
	eyePos = level.player GetEye() + ( 0, 0, z_offset );
	
	// start a bullet trace upwards from eye level to see if we're underwater
	trace = BulletTrace( eyePos, ( eyePos + ( 0, 0, 250 ) ), false, self );
//	IPrintLn( trace[ "surfacetype" ] );
//	IPrintLn( ( eyepos - trace[ "position" ] )[ 2 ] + " abovewater" );
	
	if( trace[ "surfacetype" ] == "water" )
	{
//		IPrintLn( "underwater" );
		return true;
	}
	// consider you to be underwater for certain objects, like the bottles and papers bobbing in the stealth rooms
	else if( IsDefined( trace[ "entity" ] ) && IsDefined( trace[ "entity" ].script_noteworthy ) && trace[ "entity" ].script_noteworthy == "consider_underwater" )
	{
//		IPrintLn( "under bobber" );
		return true;
	}
	else
	{
//		IPrintLn( "abovewater" );
		return false;
	}
}

create_player_surfacing_effects()
{
	//Back to regular vision
	// THERE CAN BE NO DELAYS BETWEEN ANY OF THESE VISION CHANGES
//	if( IsDefined( level.cw_bloom_above ) )
//		level.player thread vision_set_changes( level.cw_bloom_above, 0 );
	if( IsDefined( level.cw_vision_above ) )
		level.player thread vision_set_changes( level.cw_vision_above, 0);
	if( IsDefined( level.cw_fog_above ) )
		level.player thread fog_set_changes( level.cw_fog_above, 0 );
  
 	thread fx_waterwipe_above();
 	
	//  Sound Effects of emerging out of the water
	thread audio_water_level_logic( "emerge" );
	
	level.player SetWaterSheeting( 1, 1.5 );
	
	thread maps\flood_fx::fx_waterdrops_20_inst();
	waitframe();
	thread maps\flood_fx::fx_turn_on_bokehdots_16_player();

	//---fx loads in gsc and csv have been commented out as part as first opimization pass-PH

//	thread player_do_surfacing_models( "create" );
	
//	PlayFXOnTag( getfx( "water_emerge_player_weapon" ), level.player.weapon, "TAG_FLASH" );

//	player_rig = spawn_anim_model( "player_rig" );
//	player_rig.origin = level.player.origin + ( 0, 0, 10 );
//	player_rig.angles = level.player.angles;
//	player_rig LinkTo( level.player );
//	player_rig Hide();
//	PlayFXOnTag( getfx( "water_emerge_player_hand" ), player_rig, "J_Wrist_RI" );
//	PlayFXOnTag( getfx( "water_emerge_player_hand" ), level.player_view_water_bubble_source, "tag_origin" );
	
	// Blur effects
//	SetBlur( 3, .25 );
//	SetBlur( 0, .5 );
	
//	maps\_art::dof_enable_script( 0.1, 8, 4, 6000, 9000, 0.01, 0.0 );
	maps\_art::dof_disable_script( 0.0 );
}

create_player_going_underwater_effects()
{
	// Underwater vision
	// THERE CAN BE NO DELAYS BETWEEN ANY OF THESE VISION CHANGES
//	if( IsDefined( level.cw_bloom_under ) )
//		level.player thread vision_set_changes( level.cw_bloom_under, 0 );
	if( IsDefined( level.cw_vision_under ) )
		level.player thread vision_set_changes( level.cw_vision_under, 0 );
	if( IsDefined( level.cw_fog_under ) )
		level.player thread fog_set_changes( level.cw_fog_under, 0 );
	
 	thread fx_waterwipe_under();
 	
	// Underwater Sound Effect
	thread audio_water_level_logic( "submerge" );

	//dof_underwater = [];
//	maps\_art::dof_enable_script( 0.1, 20, 4.8, 200, 600, 1.9, 0.0 );
	maps\_art::dof_enable_script( 0.1, 20, 4.8, 100, 1000, 10, 0.0 );
}

player_do_surfacing_models( state )
{
//	PreCacheModel( "acr_reflex" );
//	maps\flood::mission_precache();
	
	switch( state )
	{
		case "create":
			player_rig = spawn_anim_model( "player_rig" );
			player_rig Hide();
//			player_weapon = spawn_anim_model( "player_weapon" );
//			player_weapon Hide();
			break;
		case "kill":
//			player_rig Delete();
			break;
	}
}

player_breath_timer( endon_event )
{
	//Stop this script when the player comes up
	level endon( endon_event );
	level endon( "cw_player_abovewater" );
	level endon( "cw_player_out_of_water" );

//	IPrintLn( "1: " + GetDvar( "controls_autoaimConfig" ) );
//	IPrintLn( "2: " + level.player GetLocalPlayerProfileData( "autoAim" ) );
//	IPrintLn( "3: " + GetDvar( "input_autoaim" ) );
//	IPrintLn( "4: " + GetDvar( "aim_aimAssistRangeScale" ) );
//	IPrintLn( "5: " + GetDvar( "aim_autoAimRangeScale" ) );
//	IPrintLn( "6: " + GetDvar( "autoaim_enabled" ) );
	
	JKUprint( "water: " + level.cw_player_allowed_underwater_time + " allowed" );
	wait level.cw_player_allowed_underwater_time;
	
	if( level.cw_player_damage_underwater_time_exceeded )
		thread player_deal_underwater_damage( GetTime(), 6000, 20, endon_event );
	
	// no more hiding from enemies if you're spewing bubbles
	JKUprint( "water: nh!" );

	// Play the underwater breathing/choking sfx
	thread audio_underwater_choke();
	
	thread player_abovewater_defaults();
	
	// lots of bubbles for a little while then we'll make you stand
	delay_with_bubbles( 6, 0.5, true, false, endon_event );
	
	// fx stuff other than bubbles
	thread player_do_toolong_fx( endon_event );
	level waittill( "toolong_exit" );
	
	thread audio_underwater_breath_surfacing();
	
	cw_player_make_stand();
	
	// only disallow crouch if it's not already disallowed
//	if( !flag( "cw_player_crouch_disabled" ) )
//		thread player_water_crouch_timer( endon_event );
}

// for when you've been underwater too long and I make you stand.  Don't allow you to crouch back underwater for a little while
player_water_crouch_timer( endon_event )
{
//	IPrintLn( "water: dc" );
	// make sure we're not submerged when this script starts
//	flag_waitopen( "cw_player_underwater");
	flag_set( "cw_player_crouch_disabled" );
	
	level endon( endon_event );
//	level endon( "cw_player_underwater" );
	level endon( "cw_player_out_of_water" );	

	start_time = GetTime();
	while( ( GetTime() - start_time ) < 5000 )
	{
		if( level.player GetStance() == "crouch" )
		{
			// if you go underwater, reset the timer.  need to spend xxx seconds above water before we let you go underneath
			start_time = GetTime();
			if( !flag( "cw_player_make_stand" ) )
			{
				flag_set( "cw_player_make_stand" );
				delayThread( 1, ::cw_player_make_stand );
			}
		}
		wait 0.05;
	}
	
//	IPrintLn( "water: ec" );
	flag_clear( "cw_player_crouch_disabled" );
}

cw_player_make_stand()
{
	while( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
		wait 1;
		
		player_make_bubbles();
		level.player DoDamage( 20, level.player.origin );
	}

	flag_clear( "cw_player_make_stand" );
	JKUprint( "water: ms" );
}

delay_with_bubbles( count, time, nosound, nofx, endon_event )
{
	level endon( endon_event );
	level endon( "cw_player_abovewater" );
	level endon( "cw_player_out_of_water" );
	
	for( i = 0; i < count; i++ )
	{
		if( !nofx )
			player_make_bubbles();
		
		// Play bubble sfx
		if( !nosound )
			thread audio_underwater_breath_bubbles();
		
		wait time;
	}
}

player_do_toolong_fx( endon_event )
{
//	level endon( endon_event );
//	level endon( "cw_player_abovewater" );
//	level endon( "cw_player_out_of_water" );
	
	default_fov = GetDvarInt( "cg_fov" );
//	IPrintLn( default_fov );
	
	time1 = 0.4;
	time2 = 0.3;
	time3 = 0.2;
	
	fov_amount1 = 0.97;
	fov_amount2 = 0.95;
	fov_amount3 = 0.85;
	
	blur_amount1 = 1;
	blur_amount2 = 1;
	blur_amount3 = 2;

	level.player AllowAds( false );
	
	thread delay_with_bubbles( 1, 0, false, false, endon_event );
	thread set_blur( blur_amount1, time1 );
	level.player thread lerp_fov_overtime( time1, default_fov * fov_amount1 );
	wait time1;
	thread set_blur( 0, time1 );
	level.player thread lerp_fov_overtime( time1, default_fov );
	wait time1;
	
	if( flag( "cw_player_abovewater" ) || flag( "cw_player_out_of_water" ) )
	{
		level.player AllowAds( true );
		level notify( "toolong_exit" );
		return;
	}

	thread delay_with_bubbles( 1, 0, false, false, endon_event );
	thread set_blur( blur_amount2, time2 );
	level.player thread lerp_fov_overtime( time2, default_fov * fov_amount2 );
	wait time2;
	thread set_blur( 0, time2 );
	level.player thread lerp_fov_overtime( time2, default_fov );
	wait time2;

	if( flag( "cw_player_abovewater" ) || flag( "cw_player_out_of_water" ) )
	{
		level.player AllowAds( true );
		level notify( "toolong_exit" );
		return;
	}
	
	for( i = 0; i < 2; i++ )
	{
		thread delay_with_bubbles( 1, 0, false, false, endon_event );
		thread set_blur( blur_amount3, time3 );
		// FIX JKU vision set swapping removed because it messes with the normal vision set swapping when you go in and out of water.
//		thread set_vision_set( "flood_underwater_dark", time3 );
		level.player thread lerp_fov_overtime( time3, default_fov * fov_amount3 );
		wait time3;
		thread set_blur( 0, time3 );
//		thread set_vision_set( "flood_underwater", time3 );
		level.player thread lerp_fov_overtime( time3, default_fov );
		wait time3;

		if( flag( "cw_player_abovewater" ) || flag( "cw_player_out_of_water" ) )
		{
			level.player AllowAds( true );
			level notify( "toolong_exit" );
			return;
		}
	}
	
	level.player AllowAds( true );
	level notify( "toolong_exit" );
}

player_make_bubbles()
{
	setup_player_view_water_fx_source();
		
	PlayFXOnTag( getfx( "scuba_bubbles_breath_player" ), level.cw_player_view_bubble_source, "tag_origin" );
	//PlayFXOnTag( getfx( "vfx_warehouse_surface_bubbles" ), level.cw_player_view_bubble_source, "tag_origin" );
}

player_stop_bubbles()
{
	KillFXOnTag( getfx( "scuba_bubbles_breath_player" ), level.cw_player_view_bubble_source, "tag_origin" );
	//KillFXOnTag( getfx( "vfx_warehouse_surface_bubbles" ), level.cw_player_view_bubble_source, "tag_origin" );
}

player_deal_underwater_damage( time, time_allowed, damage, endon_event )
{
	level endon( endon_event );
	level endon( "cw_player_abovewater" );
	level endon( "cw_player_out_of_water" );
	
	level.cw_player_drowning_damage_count = 0;
	
	while( 1 )
	{
		if( ( GetTime() - time ) >= time_allowed ) 
		{
			if( !IsDefined( level.cw_player_is_drowning ) && level.cw_player_drowning_animate )
				thread player_animate_underwater_damage();

			player_make_bubbles();
			level.cw_player_is_drowning = true;
			level.player DoDamage( damage, level.player.origin );
			level.cw_player_drowning_damage_count += 1;
//			level.player ShellShock( "default", 0.5 );
		}
		wait 1;
	}
}

player_animate_underwater_damage()
{
	level.player DisableWeapons();
	// this is to give time for the gun to be stowed, this should go away if the real anim for this has this timed out properly
	wait 0.4;
	player_rig = spawn_anim_model( "player_rig" );
	player_rig.origin = level.player.origin;
	player_rig.angles = level.player.angles;
	player_rig LinkToPlayerView( level.player, "tag_origin", ( 4, 0, -64 ), ( 0, 0, 0 ), true );
	
	while( IsDefined( level.cw_player_is_drowning ) && level.cw_player_is_drowning )
	{
//		player_rig thread maps\_anim::anim_single_solo( player_rig, "flood_sweptaway_L" );
//		anim_length = GetAnimLength( player_rig getanim( "flood_sweptaway_L" ) );
//		wait anim_length;
		waitframe();
	}
	
	player_rig Delete();
	// slight delay so you don't instantly get your gun back when you come out of the water
	wait 0.4;
	level.player EnableWeapons();
}

ai_enemy_tracking( state, endon_event )
{
	//Stop this script when the player comes up
//	level endon( endon_event );
//	level endon( "cw_player_out_of_water" );
//	level endon( "cw_player_abovewater" );
//	level endon( "cw_player_underwater" );
	
	// distance the player has to be from the baddy for the baddy to quickly lose the player
	dumb_dist = 168;
	
	switch( state )
	{
		case "underwater":
//			player_seek_enable
			
			// get an array of all the players enemies.  Hope axis is good enough for this...
			baddies = GetAIArray( "axis" );
//			IPrintLn( baddies.size );
			
			// remove any enemy not currently attacking you
			foreach( baddy in baddies )
			{
				if( IsDefined( baddy.enemy ) && baddy.enemy != level.player )
					baddies = array_remove( baddies, baddy );
				if( !IsDefined( baddy.enemy ) )
					baddies = array_remove( baddies, baddy );
			}
//			IPrintLn( baddies.size );
			
			// check baddy distance and react accordingly.  you're at a disadvantage if you go underwater close to a guy
			if( baddies.size > 0 )
			{
				foreach( baddy in baddies )
				{
//					IPrintLn( Distance2D( level.player.origin, baddy.origin ) );
					// if a guy is really close to you we can early out bc we want them all to be able to see you for longer
					if( Distance2D( level.player.origin, baddy.origin ) < dumb_dist )
					{
						// only do the longer attack player stuff if he actually can see the player go into water
						if( baddy CanSee( level.player ) )
						{
							thread ai_enemy_target_underwater( dumb_dist, 5 );
							JKUprint( "player underwater but close" );
							return;
						}
					}
				}
				
				thread ai_enemy_target_underwater( dumb_dist, 1 );
				return;
			}

			thread player_underwater_set();
			break;
		case "abovewater":
			thread player_abovewater_set();
			break;
	}
////	level.player.threatbias = -1000;
//	enemies = GetAIArray( "axis" );
//	foreach ( enemy in enemies )
//	{
////		self thread ai_player_tracking();
//		if ( isdefined ( self.enemy ) && self.enemy == level.player )
//			enemy ClearEnemy();
//		enemy.ignoreall = 1;
////		self SetThreatBiasGroup( "oblivious" );
//	}
}

ai_enemy_target_underwater( dumb_dist, track_time )
{
	level endon( "cw_player_abovewater" );
	level endon( "cw_player_out_of_water" );
	
//	IPrintLn( "tracked player underwater" );
	
//	level.player.flood_seen_going_underwater = true;
	level.player.attackeraccuracy = 0.1;
	// wait for a moment before they can't see you anymore
	wait track_time;
	
	// hmm  maybe I want to recheck the players dist to baddies before making them ignore him.
	// might feel too gamey if a guy right next to me starts ignoring you...
//	IPrintLn( "ai really setting underwater" );

	// Player is only visible under a certain distance underwater to guys in stealth
	level.player.maxvisibledist = 32;
	level.player thread set_ignoreme( true );
//	self.alertlevel = "alert";
}

player_underwater_set()
{
//	IPrintLn( "untracked player underwater" );

//	level.player.flood_seen_going_underwater = false;
	level.player.attackeraccuracy = 0.1;
	level.player.maxvisibledist = 32;
	level.player thread set_ignoreme( true );
}

player_abovewater_set()
{
	level endon( "cw_player_underwater" );
//	level endon( "cw_player_out_of_water" );	
	
//	IPrintLn( "player abovewater" );
	// wait for a moment before they can see you again
	wait 1;

//	IPrintLn( "really setting abovewater" );
	thread player_abovewater_defaults();
}

player_abovewater_defaults()
{
	level endon( "cw_player_underwater" );
	
	level.player.attackeraccuracy = 1;
	level.player.maxvisibledist = 8192;
	level.player set_ignoreme( false );
}

player_water_on_face()
{
	// These flag triggers are placed wherever water is falling from above
	flag_wait( "water_on_face");
	level.player SetWaterSheeting( 1, 0 );
	flag_waitopen( "water_on_face");
	level.player SetWaterSheeting( 1, 0.2 );
	
	// Start this script over again
	player_water_on_face();
}

// debug
// use this to make sure speeds are getting set correctly.  g_speed is the max speed the player is allowed to go.
print_player_speed()
{
	while( 1 )
	{
		JKUprint( "player max pos speed: " + GetDvar( "g_speed" ) );
		vel = level.player GetVelocity();
		// figure out the length of the vector to get the speed (distance from world center = length)
		speed = Distance( ( vel[ 0 ], vel[ 1 ], 0 ), ( 0, 0, 0 ) );  // don't care about Z velocity
		JKUprint( "curr speed: " + speed );
		wait 1;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree("generic_human");
init_waistwater_archetype()
{
	if ( !isDefined( anim.archetypes ) || !isDefined( anim.archetypes[ "waist_water" ] ) )
	{
		archetype = [];
		mains = [];
		turns = [];
		pains = [];
		deaths = [];
		
	//	initAnimSet[ "sprint"		] = %flood_ai_walk_CQB_F;
	//	initAnimSet[ "sprint_short" ] = %flood_ai_walk_CQB_F;
	//	initAnimSet[ "straight" ]	  = %flood_ai_walk_CQB_F;	// %run_CQB_F_search_v2
		
		mains[ "straight"	 ] = %flood_ai_walk_CQB_F;
		mains[ "straight_v2" ] = %flood_ai_walk_CQB_F;
		mains[ "move_f"		 ] = %flood_ai_walk_CQB_F;
		mains[ "move_l"		 ] = %flood_ai_walk_left;
		mains[ "move_r"		 ] = %flood_ai_walk_right;
		mains[ "move_b"		 ] = %flood_ai_walk_backward;
//		mains[ "move_l"		 ] = %walk_left;
//		mains[ "move_r"		 ] = %walk_right;
//		mains[ "move_b"		 ] = %walk_backward;

		turns[ "0" ] = %flood_ai_CQB_walk_turn_2;
		turns[ "1" ] = %flood_ai_CQB_walk_turn_1;
		turns[ "2" ] = %flood_ai_CQB_walk_turn_4;
		turns[ "3" ] = %flood_ai_CQB_walk_turn_7;
		turns[ "5" ] = %flood_ai_CQB_walk_turn_9;
		turns[ "6" ] = %flood_ai_CQB_walk_turn_6;
		turns[ "7" ] = %flood_ai_CQB_walk_turn_3;
		turns[ "8" ] = %flood_ai_CQB_walk_turn_2;
	
		// removing corner_standl_paind corner_standl_paine
		pains[ "cover_left_stand" ] = [ %corner_standl_painB, %corner_standl_painC ];
		// removing run_pain_fallonknee run_pain_fallonknee_02 run_pain_fallonknee_03 run_pain_fall
		pains[ "run_long" ]	  = [ %run_pain_leg, %run_pain_shoulder, %run_pain_stomach_stumble, %run_pain_head, %run_pain_stomach, %run_pain_stumble, %run_pain_stomach_fast, %run_pain_leg_fast ];
		pains[ "run_medium" ] = [ %run_pain_stomach, %run_pain_stumble, %run_pain_stomach_fast, %run_pain_leg_fast ];
		pains[ "run_short" ]  = [ %run_pain_stumble, %run_pain_stomach_fast ];
		// removing stand_exposed_extendedpain_chest, stand_extendedpainB, stand_extendedpainC stand_exposed_extendedpain_feet_2_crouch stand_exposed_extendedpain_gut stand_exposed_extendedpain_head_2_crouch
		// stand_exposed_extendedpain_hip_2_crouch stand_exposed_extendedpain_neck stand_exposed_extendedpain_shoulder_2_crouch stand_exposed_extendedpain_stomach stand_exposed_extendedpain_neck
		pains[ "torso_upper" ]				= [ %exposed_pain_face ];
		pains[ "head"		 ]				= [ %exposed_pain_face ];
		pains[ "damage_shield_pain_array" ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		pains[ "default_extended"		  ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		pains[ "torso_lower_extended"	  ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		pains[ "leg_extended"			  ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		pains[ "foot_extended"			  ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		pains[ "torso_upper_extended"	  ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		pains[ "head_extended"			  ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		pains[ "left_arm_extended"		  ] = [ %stand_exposed_extendedpain_hip, %stand_exposed_extendedpain_shoulderswing, %exposed_pain_face, %exposed_pain_groin ];
		
		
		deaths[ "running_forward" ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %run_death_facedown, %run_death_roll, %run_death_fallonback, %run_death_flop ];
		
		deaths[ "stand_lower_body"			]  = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death_groin	 , %stand_death_leg ];
		deaths[ "stand_lower_body_extended" ]  = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %stand_death_crotch	 , %stand_death_guts ];
		deaths[ "stand_head"				]  = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death_headshot, %exposed_death_flop ];
		deaths[ "stand_neck" ]				   = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death_neckgrab ];
		deaths[ "stand_left_shoulder" ]		   = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death_twist, %stand_death_shoulder_spin, %stand_death_shoulderback ];
		deaths[ "stand_torso_upper" ]		   = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %stand_death_tumbleforward, %stand_death_stumbleforward ];
		deaths[ "stand_torso_upper_extended" ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %stand_death_fallside ];
	
		deaths[ "stand_front_head" ]		   = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %stand_death_face, %stand_death_headshot_slowfall ];
		deaths[ "stand_front_head_extended"	 ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %stand_death_head_straight_back ];
		deaths[ "stand_front_torso"			 ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %stand_death_tumbleback ];
		deaths[ "stand_front_torso_extended" ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %stand_death_chest_stunned ];
	
		deaths[ "stand_back" ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death_falltoknees, %exposed_death_falltoknees_02 ];
		
		deaths[ "stand_default"		   ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death_02		, %exposed_death_nerve ];
		deaths[ "stand_default_firing" ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death_firing_02, %exposed_death_firing ];
		deaths[ "stand_backup_default" ] = [ %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %flood_ai_death_fallback_01, %flood_ai_death_fallfront_01, %exposed_death ];
	
		
		// replacing cqb_stand_reload_knee
		archetype[ "cqb_stand" ][ "reload_crouchhide" ] = [ %CQB_stand_reload_steady ];
		
		// removing exposed_squat_down_grenade_F exposed_squat_idle_grenade_F
		archetype[ "grenade" ]["cower_squat"] = %exposed_idle_reactB;
		archetype[ "grenade" ]["cower_squat_idle"] = %exposed_idle_twitch_v4;
	
		// cover anims
		archetype[ "cover_right_stand" ][ "alert_to_look"	   ] = %flood_ai_corner_standR_alert_2_look;
		archetype[ "cover_right_stand" ][ "look_to_alert"	   ] = %flood_ai_corner_standR_look_2_alert;
		archetype[ "cover_right_stand" ][ "look_to_alert_fast" ] = %flood_ai_corner_standR_look_2_alert_fast;
		archetype[ "cover_right_stand" ][ "look_idle"		   ] = %flood_ai_corner_standr_look_idle;
//		archetype[ "cover_right_stand" ][ "stance_change"	   ] = %CornerCrR_stand_2_alert;

		archetype[ "cover_left_stand" ][ "alert_to_look"	  ] = %flood_ai_corner_standL_alert_2_look;
		archetype[ "cover_left_stand" ][ "look_to_alert"	  ] = %flood_ai_corner_standL_look_2_alert;
		archetype[ "cover_left_stand" ][ "look_to_alert_fast" ] = %flood_ai_corner_standl_look_2_alert_fast_v1;
		archetype[ "cover_left_stand" ][ "look_idle"		  ] = %flood_ai_corner_standl_look_idle;
//		archetype[ "cover_left_stand" ][ "stance_change"	  ] = %CornerCrL_stand_2_alert;
		
		// main movement anims
		archetype[ "run"  ] = mains;
		archetype[ "walk" ] = mains;
		archetype[ "cqb"  ] = mains;
		
		// turns
		archetype[ "run_turn"  ] = turns;
		archetype[ "cqb_turn"  ] = turns;
	
		// pain
		archetype[ "pain"  ] = pains;
		
		// death
		archetype[ "death"  ] = deaths;
		
		register_archetype( "waist_water", archetype );
	}
}

init_waistwater_out_archetype()
{
	if ( !isDefined( anim.archetypes ) || !isDefined( anim.archetypes[ "waist_water_out" ] ) )
	{
		archetype = [];
		mains = [];
		turns = [];
		pains = [];
		
		walk_mains[ "straight" ] = %walk_CQB_F;
		walk_mains[ "move_f"   ] = %walk_CQB_F;
		walk_mains[ "move_l"   ] = %walk_left;
		walk_mains[ "move_r"   ] = %walk_right;
		walk_mains[ "move_b"   ] = %walk_backward;
		
		run_mains[ "straight" ] = %run_lowready_F;
		run_mains[ "move_f"	  ] = %walk_forward;
		run_mains[ "move_l"	  ] = %walk_left;
		run_mains[ "move_r"	  ] = %walk_right;
		run_mains[ "move_b"	  ] = %walk_backward;
		
		cqb_mains[ "straight"	 ] = %run_CQB_F_search_v1;
		cqb_mains[ "straight_v2" ] = %run_CQB_F_search_v2;
		cqb_mains[ "move_f"		 ] = %walk_CQB_F;
		cqb_mains[ "move_l"		 ] = %walk_left;
		cqb_mains[ "move_r"		 ] = %walk_right;
		cqb_mains[ "move_b"		 ] = %walk_backward;
		
		run_turns[ "0" ] = %run_turn_180;
		run_turns[ "1" ] = %run_turn_L135;
		run_turns[ "2" ] = %run_turn_L90;
		run_turns[ "3" ] = %run_turn_L45;
		run_turns[ "5" ] = %run_turn_R45;
		run_turns[ "6" ] = %run_turn_R90;
		run_turns[ "7" ] = %run_turn_R135;
		run_turns[ "8" ] = %run_turn_180;
	
		cqb_turns[ "0" ] = %CQB_walk_turn_2;
		cqb_turns[ "1" ] = %CQB_walk_turn_1;
		cqb_turns[ "2" ] = %CQB_walk_turn_4;
		cqb_turns[ "3" ] = %CQB_walk_turn_7;
		cqb_turns[ "5" ] = %CQB_walk_turn_9;
		cqb_turns[ "6" ] = %CQB_walk_turn_6;
		cqb_turns[ "7" ] = %CQB_walk_turn_3;
		cqb_turns[ "8" ] = %CQB_walk_turn_2;
	
		// replacing cqb_stand_reload_knee
		archetype[ "cqb_stand" ][ "reload_crouchhide" ] = [ %CQB_stand_reload_knee ];
		
		// removing corner_standl_paind corner_standl_paine
		pains[ "cover_left_stand" ] = [ %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE ];
		// removing run_pain_fallonknee run_pain_fallonknee_02 run_pain_fallonknee_03 run_pain_fall
		pains[ "run_long" ]	  = [ %run_pain_leg, %run_pain_shoulder, %run_pain_stomach_stumble, %run_pain_head, %run_pain_fallonknee_02, %run_pain_stomach, %run_pain_stumble, %run_pain_stomach_fast, %run_pain_leg_fast, %run_pain_fall ];
		pains[ "run_medium" ] = [ %run_pain_fallonknee_02, %run_pain_stomach, %run_pain_stumble, %run_pain_stomach_fast, %run_pain_leg_fast, %run_pain_fall ];
		pains[ "run_short" ]  = [ %run_pain_fallonknee, %run_pain_fallonknee_03 ];
		// removing stand_exposed_extendedpain_chest, stand_extendedpainB, stand_extendedpainC stand_exposed_extendedpain_feet_2_crouch stand_exposed_extendedpain_gut stand_exposed_extendedpain_head_2_crouch
		// stand_exposed_extendedpain_hip_2_crouch stand_exposed_extendedpain_neck stand_exposed_extendedpain_shoulder_2_crouch stand_exposed_extendedpain_stomach stand_exposed_extendedpain_neck
		pains[ "torso_upper" ]				= [ %exposed_pain_face, %stand_exposed_extendedpain_neck ];
		pains[ "head"		 ]				= [ %exposed_pain_face, %stand_exposed_extendedpain_neck ];
		pains[ "damage_shield_pain_array" ] = [ %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch ];
		pains[ "default_extended" ]			= [ %stand_extendedpainC, %stand_exposed_extendedpain_chest ];
		pains[ "torso_lower_extended" ]		= [ %stand_exposed_extendedpain_gut, %stand_exposed_extendedpain_stomach, %stand_exposed_extendedpain_hip_2_crouch, %stand_exposed_extendedpain_feet_2_crouch, %stand_exposed_extendedpain_stomach ];
		pains[ "leg_extended" ]				= [ %stand_exposed_extendedpain_hip_2_crouch, %stand_exposed_extendedpain_feet_2_crouch, %stand_exposed_extendedpain_stomach ];
		pains[ "foot_extended" ]			= [ %stand_exposed_extendedpain_feet_2_crouch ];
		pains[ "torso_upper_extended" ]		= [ %stand_exposed_extendedpain_gut, %stand_exposed_extendedpain_stomach, %stand_exposed_extendedpain_head_2_crouch ];
		pains[ "head_extended"	   ]		= [ %stand_exposed_extendedpain_head_2_crouch ];
		pains[ "left_arm_extended" ]		= [ %stand_exposed_extendedpain_shoulder_2_crouch ];
		
		// removing exposed_squat_down_grenade_F exposed_squat_idle_grenade_F
		archetype[ "grenade" ]["cower_squat"] = %exposed_squat_down_grenade_F;
		archetype[ "grenade" ]["cower_squat_idle"] = %exposed_squat_idle_grenade_F;	
	
		// main movement anims
		archetype[ "run"  ] = run_mains;
		archetype[ "walk" ] = walk_mains;
		archetype[ "cqb"  ] = cqb_mains;
		
		// turns
		archetype[ "run_turn"  ] = run_turns;
		archetype[ "cqb_turn"  ] = cqb_turns;
	
		// pain
		archetype[ "pain"  ] = pains;
		
		register_archetype( "waist_water_out", archetype );
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
//                                                                                     //
//                                      FX                                             //
//                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////

setup_player_view_water_fx_source()
{	
	if( !IsDefined( level.cw_player_view_fx_source ) )
	{
		level.cw_player_view_fx_source = Spawn( "script_model", ( 0, 0, 0 ) );
		level.cw_player_view_fx_source SetModel( "tag_origin" );
		level.cw_player_view_fx_source LinkToPlayerView( level.player, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
		
		// FIX JKU seperate ent for the scuba bubbles because they are designed to be offset.
		level.cw_player_view_bubble_source = Spawn( "script_model", level.cw_player_view_fx_source.origin + ( 10, 0, -60 ) );
		level.cw_player_view_bubble_source SetModel( "tag_origin" );
		level.cw_player_view_bubble_source LinkTo( level.cw_player_view_fx_source );
	}	
}
	
fx_waterwipe_under()
{
	// stop the version of this fx for the other direction as we only every want one playing
	KillFXOnTag( getfx( level.cw_waterwipe_above ), level.cw_player_view_fx_source, "tag_origin" );
	level.cw_waterwipe_above_playing = false;
	
	if( !level.cw_waterwipe_under_playing )
	{
		level.cw_waterwipe_under_playing = true;
		
		PlayFXOnTag( getfx( level.cw_waterwipe_under ), level.cw_player_view_fx_source, "tag_origin" );
		PlayFXOnTag( getfx( "vfx_warehouse_surface_bubbles_run" ), level.cw_player_view_bubble_source, "tag_origin" );

		wait 0.5;
		level.cw_waterwipe_under_playing = false;
	}
}

fx_waterwipe_above()
{
	KillFXOnTag( getfx( level.cw_waterwipe_under ), level.cw_player_view_fx_source, "tag_origin" );
	KillFXOnTag( getfx( "vfx_warehouse_surface_bubbles_run" ), level.cw_player_view_bubble_source, "tag_origin" );

	level.cw_waterwipe_under_playing = false;
	
	if( !level.cw_waterwipe_above_playing )
	{
		level.cw_waterwipe_above_playing = true;
		
		PlayFXOnTag( getfx( level.cw_waterwipe_above ), level.cw_player_view_fx_source, "tag_origin" );
		
		wait 0.5;
		level.cw_waterwipe_above_playing = false;
	}
}

kill_above_water_fx()
{
	thread maps\flood_fx::fx_create_bokehdots_source();
	
	KillFXOnTag( getfx( "scrnfx_water_splash_med" ), level.cw_player_view_fx_source, "tag_origin");
	waitframe();
	KillFXOnTag( getfx( "scrnfx_water_splash_high" ), level.cw_player_view_fx_source, "tag_origin");
	waitframe();
	KillFXOnTag( getfx( "scrnfx_water_splash_low" ), level.cw_player_view_fx_source, "tag_origin");
	waitframe();
	KillFXOnTag( GetFX( "bokehdots_and_waterdrops_heavy" ), level.flood_source_bokehdots, "tag_origin" );
	waitframe();
	KillFXOnTag( GetFX( "waterdrops_20_inst" ), level.flood_source_bokehdots, "tag_origin" );
	waitframe();
	KillFXOnTag( GetFX( "waterdrops_3" ), level.flood_source_bokehdots, "tag_origin" );
	waitframe();
	KillFXOnTag( GetFX( "bokehdots_close" ), level.flood_source_bokehdots, "tag_origin" );
	KillFXOnTag( GetFX( "bokehdots_far" ), level.flood_source_bokehdots, "tag_origin" );
}

splash_on_player( end_flag )
{
	level endon( end_flag );
	
	model1 = Spawn( "script_model", ( 0, 0, 20 ) );
	model1 SetModel( "tag_origin" );
	model2 = Spawn( "script_model", ( 0, 0, 20 ) );
	model2 SetModel( "tag_origin" );

	while( 1 )
    {
//    	flag_set( "do_bokehdot" );
    	if( flag( "do_bokehdot" ) )
    	{
	    	/*
			if( flag( "fx_player_watersheeting" ) )
			{
				//IPrintLnBold ( "under a water spout" );
				splash_type = RandomInt( 3 );
			    switch( splash_type )
			    {
			    	case 0:
						level.splash_FX = "splash_body_shallow";
						break;
			    	case 1:
			    	case 2:
						level.splash_FX = "factory_single_splash_plr";
						break;
			    }
			}
			else
			{
				//level.splash_FX = "glow_green_light_30_nolight";
				level.splash_FX = "factory_single_splash_plr";
				//IPrintLnBold ( "standard" );
			}
			*/
			level.splash_FX = "factory_single_splash_plr";
	
			self splash_on_player_choose_location();
			model1 LinkToPlayerView( self, level.splash_tag, ( level.splash_X, level.splash_Y, level.splash_Z ), level.splash_angles, true );
	        PlayFXOnTag( getfx( level.splash_FX ), model1, "tag_origin" );
	        
	        wait RandomFloatRange( 0.2, 0.4 );
	        model1 UnlinkFromPlayerView( level.player );
	        
			self splash_on_player_choose_location();
			model2 LinkToPlayerView( self, level.splash_tag, ( level.splash_X, level.splash_Y, level.splash_Z ), level.splash_angles, true );
	        PlayFXOnTag( getfx( level.splash_FX ), model2, "tag_origin" );
	
	        wait RandomFloatRange( 0.1, 0.3 );
	        model2 UnlinkFromPlayerView( level.player );
    	}
    	waitframe();
    }
}

splash_on_player_choose_location()
{
//	location = 0;
	location = RandomInt( 3 );
    switch( location )
    {
    	// FIX JKU need to account for all weapons in here.  maybe pp90 could use the m9 values and maybe AK could use CZ?
    	case 0:
			if ( self GetCurrentWeapon() == "m9a1" )
			{
				level.splash_tag	= "tag_flash";
				level.splash_X		= RandomFloatRange( -10, -1 );
				level.splash_Y		= RandomFloatRange( -0.5, 0.5 );
				level.splash_Z		= RandomFloatRange( 0.0, 0.5 );
				level.splash_angles = ( 0, 0, 0 );
	    		break;
			}
			else if ( self GetCurrentWeapon() == "flood_knife" )
			{
				level.splash_tag	= "tag_weapon";
				level.splash_X		= RandomFloatRange( 0.5, 9.5 );
				level.splash_Y		= RandomFloatRange( -0.5, 0.5 );
				level.splash_Z		= RandomFloatRange( -0.5, 0.5 );
				level.splash_angles = ( 90, 0, 0 );
	    		break;
			}
			else
			{
				level.splash_tag	= "tag_flash";
				level.splash_X		= RandomFloatRange( -16, -12 );
				level.splash_Y		= RandomFloatRange( -0.5, 0.5 );
				level.splash_Z		= RandomFloatRange( -10, -2 );
				level.splash_angles = ( 0, 0, 0 );
//				IPrintLn( level.splash_X + " " + level.splash_Y + " " + level.splash_Z );
	    		break;
			}
    	case 1:
			// On the forearm
			level.splash_tag	= "j_elbow_le";
			level.splash_X		= RandomFloatRange( 0, 18 );
			level.splash_Y		= RandomFloatRange( -1, 1 );
			level.splash_Z		= RandomFloatRange( -3, 2 );
			level.splash_angles = ( 90, 0, 0 );
    		break;
    	case 2:
			// On the hand
			level.splash_tag	= "j_thumb_le_0";
			level.splash_X		= RandomFloatRange( -2, 2 );
			level.splash_Y		= RandomFloatRange( 0.5, 1.5 );
			level.splash_Z		= RandomFloatRange( -1, 1 );
			level.splash_angles = ( 90, 0, 0 );
    		break;
	}
}


drip_on_player( end_flag )
{
	level endon( end_flag );
	level endon( "cw_player_underwater" );
	
	if( IsDefined( level.drip_ent1 ) )
	{
		level.drip_ent1 Delete();
	}
		
	if( IsDefined( level.drip_ent2 ) )
	{
		level.drip_ent2 Delete();
	}

//	level.splash_FX = "factory_single_splash_plr";
	level.splash_FX = "cw_player_drips";

	for( i = 0; i < 8; i++ )
    {
//		IPrintLn( "dripping" );
		self drip_on_player_choose_location();
		level.drip_ent1 = Spawn( "script_model", ( 0, 0, 20 ) );
		level.drip_ent1 SetModel( "tag_origin" );
		level.drip_ent1 LinkToPlayerView( self, level.splash_tag, ( level.splash_X, level.splash_Y, level.splash_Z ), level.splash_angles, true );
		PlayFXOnTag( getfx( level.splash_FX ), level.drip_ent1, "tag_origin" );
		
		wait RandomFloatRange( 0.25, 0.4 );
		level.drip_ent1 Delete();
			
		self drip_on_player_choose_location();
		level.drip_ent2 = Spawn( "script_model", ( 0, 0, 20 ) );
		level.drip_ent2 SetModel( "tag_origin" );
		level.drip_ent2 LinkToPlayerView( self, level.splash_tag, ( level.splash_X, level.splash_Y, level.splash_Z ), level.splash_angles, true );
		PlayFXOnTag( getfx( level.splash_FX ), level.drip_ent2, "tag_origin" );

    	wait RandomFloatRange( 0.25, 0.4 );
		level.drip_ent2 Delete();
    }
	
//	level.drip_ent1 Delete();
//	level.drip_ent2 Delete();
}

drip_on_player_choose_location()
{
	location = 0;
//	location = RandomInt( 3 );
    switch( location )
    {
    	// FIX JKU need to account for all weapons in here.  maybe pp90 could use the m9 values and maybe AK could use CZ?
    	case 0:
			if ( self GetCurrentWeapon() == "m9a1" )
			{
				level.splash_tag	= "tag_flash";
				level.splash_X		= RandomFloatRange( -10, -1 );
				level.splash_Y		= RandomFloatRange( -0.5, 0.5 );
				level.splash_Z		= RandomFloatRange( 0.0, 0.5 );
				level.splash_angles = ( 0, 0, 0 );
	    		break;
			}
			else if ( self GetCurrentWeapon() == "flood_knife" )
			{
				level.splash_tag	= "tag_weapon";
				level.splash_X		= RandomFloatRange( 0.5, 9.5 );
				level.splash_Y		= RandomFloatRange( -0.5, 0.5 );
				level.splash_Z		= RandomFloatRange( -0.5, 0.5 );
				level.splash_angles = ( 90, 0, 0 );
	    		break;
			}
			else
			{
				level.splash_tag	= "tag_flash";
				level.splash_X		= RandomFloatRange( -16, -12 );
				level.splash_Y		= RandomFloatRange( -0.5, 0.5 );
				level.splash_Z		= RandomFloatRange( -10, -2 );
				level.splash_angles = ( 0, 0, 0 );
//				IPrintLn( level.splash_X + " " + level.splash_Y + " " + level.splash_Z );
	    		break;
			}
    	case 1:
			// On the forearm
			level.splash_tag	= "j_elbow_le";
			level.splash_X		= RandomFloatRange( 0, 18 );
			level.splash_Y		= RandomFloatRange( -1, 1 );
			level.splash_Z		= RandomFloatRange( -3, 2 );
			level.splash_angles = ( 90, 0, 0 );
    		break;
    	case 2:
			// On the hand
			level.splash_tag	= "j_thumb_le_0";
			level.splash_X		= RandomFloatRange( -2, 2 );
			level.splash_Y		= RandomFloatRange( 0.5, 1.5 );
			level.splash_Z		= RandomFloatRange( -1, 1 );
			level.splash_angles = ( 90, 0, 0 );
    		break;
	}
}


/////////////////////////////////////////////////////////////////////////////////////////
//                                                                                     //
//                                    AUDIO                                            //
//                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////

audio_underwater_breath_surfacing()
{
	//IPrintLnBold("Gasp");
	wait 0.2;
	level.player PlaySound("breath_surfacing_gasp");
	flag_set("underwater_forced_surface");
}

audio_underwater_breath_bubbles()
{
	level.player PlaySound("breath_underwater_bubbles");
}

audio_underwater_choke()
{
	if ( !isdefined( level.underwater_choke_node) )
	{
	level.underwater_choke_node = spawn( "script_origin", level.player.origin );
	level.underwater_choke_node LinkTo( level.player );
	level.underwater_choke_node PlaySound("breath_underwater_choke");
	// Plays a secondary alias for bubbles while choke sfx play
	}
}

// Stop the choke sfx if player emerges early
audio_stop_choke()
{
	if ( isdefined( level.underwater_choke_node ))
	{
		if (!flag("underwater_forced_surface"))
		{
			level.underwater_choke_node stopsounds();
			wait 0.1;
			if ( isdefined( level.underwater_choke_node ))
			{			
				level.underwater_choke_node delete();
			}
		}
		else
		{
			wait 1;
			if ( isdefined( level.underwater_choke_node ))
			{			
				level.underwater_choke_node stopsounds();
			}
			
			wait 0.1;
			if ( isdefined( level.underwater_choke_node ))
			{			
				level.underwater_choke_node delete();
			}
		}
	}
	
	flag_clear("underwater_forced_surface");
}

audio_wait_to_delete_water_node( node_variable )
{
	wait 0.2;
	if ( isdefined( node_variable ) )
	{
		node_variable stopsounds();
	}
	wait 0.1;
	if ( isdefined( node_variable ) )
	{
		node_variable delete();
	}
}

audio_water_level_logic( position )
{
	if ( position == "submerge" )
	{
		if ( isdefined( level.emerge_node ) )
		{
			thread audio_wait_to_delete_water_node( level.emerge_node );
		}
		level.submerge_node = spawn( "script_origin", level.player.origin );
		level.submerge_node playsound( "flood_plr_water_submerge_ss", "sounddone" );
		level.submerge_node waittill( "sounddone" );
		if ( isdefined( level.submerge_node ) )
		{
			level.submerge_node delete();
		}
	}
	else if ( position == "emerge" )
	{
		thread audio_stop_choke();
		
		if ( isdefined( level.submerge_node ) )
		{
			thread audio_wait_to_delete_water_node( level.submerge_node );
		}
		level.emerge_node = spawn( "script_origin", level.player.origin );
		level.emerge_node playsound( "flood_plr_water_emerge_ss", "sounddone" );
		level.emerge_node waittill( "sounddone" );
		if ( isdefined( level.emerge_node ) )
		{
			level.emerge_node delete();
		}
	}
}

//JL: Hacky... We need to change this once we figure out how we want to handle deathsdoor stuff on flood
sfx_set_audio_zone_after_deathsdoor()
{
	level.player waittill( "player_has_red_flashing_overlay" );	
	waittillframeend;
	
	while( 1 )
	{
		if( !level.player ent_flag( "player_has_red_flashing_overlay" ) )
		{
			if( flag( "cw_player_underwater" ) )
			{
//				IPrintLnBold("Below Water");
				//set_audio_zone("flood_underwater", 0.01);
				//thread maps\_audio::set_filter( "filter_underwater", 0 );
				break;
			}
			else
			{
//				IPrintLnBold("Above Water");
				//IPrintLnBold(level.current_audio_zone);
				//set_audio_zone(level.current_audio_zone, 0.01);
				//thread maps\_audio::set_filter( "filter_default", 0 );
				break;
			}
		}
		wait 0.01;
	}
	thread sfx_set_audio_zone_after_deathsdoor();
}


/////////////////////////////////////////////////////////////////////////////////////////
//                                                                                     //
//                                 FLASHBANGS                                          //
//                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////

fizzle_flashbangs_think()
{
	if( !IsDefined( level.cw_fizzle_flashbangs_thinking ) )
	{
		level.cw_fizzle_flashbangs_thinking = true;
		
		while( 1 )
		{
			grenades = GetEntArray( "grenade", "classname" );
			foreach( grenade in grenades )
			{
				if( !IsDefined( grenade.fizzle_tracked ) && grenade.model == "projectile_m84_flashbang_grenade" )
				{
					grenade.fizzle_tracked = true;
					grenade thread flashbang_fizzle();
				}
			}
			waitframe();
		}
	}
}

// FIX JKU  really should do this via a callback when the grenade is actaully about to explode
// check to see if grenade is underwater, if grenade is underwater delete it and create a new one that fizzles?
flashbang_fizzle()
{
	self endon( "death" );
	
	create_time = GetTime();
	
	// flashes explode in 1 second, we need to check one frame before that
	while( GetTime() - create_time < 950 )
		waitframe();
	
	foreach( vol in level.cw_trigger_volumes )
	{
		if( self IsTouching( vol ) )
		{
//			IPrintLn( "grenade fizzles" );
			// put fx for flash bangs fizzling here!
			PlayFX( GetFX( "cw_fizzle_flashbang" ), self.origin );
			self Delete();
			break;
		}
	}
}

JKUprint( msg )
{
	if( IsDefined( level.JKUdebug ) && level.JKUdebug )
	{
		IPrintLn( msg );
	}
}