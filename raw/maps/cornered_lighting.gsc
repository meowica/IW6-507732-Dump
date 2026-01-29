#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\_lights;

main()
{
	init_lights();
	
	level.spec_cg = 3.3;
	level.spec_ng = 15.0;
    setsaveddvar_cg_ng( "r_specularcolorscale", level.spec_cg, level.spec_ng );    
	setsaveddvar_cg_ng( "r_diffusecolorscale", 1.5, 1.5 );
	
	level.spec_cg_fireworks_low = 2;
	level.spec_cg_fireworks_high = 2.6;
	
	level.spec_ng_fireworks_low = 1.5;
	level.spec_ng_fireworks_high = 2;

	// Turn on mipchain depth-of-field (expensive)...but worth it:)
    //setdvar( "r_dof_hq", "1" );  
}

init_post_main()
{
	thread horizontal_sunlight();
	thread setup_fixtures();
}

//===========================================
// 			init_lights
//===========================================
init_lights()
{
	
    cnd_fire_rappel_light = getentarray( "cnd_fire_rappel_light", "targetname" );
	array_thread( cnd_fire_rappel_light, maps\cornered_lighting::cnd_fire_rappel_light );
	
    cnd_fire_horizontal_light = getentarray( "cnd_fire_horizontal_light", "targetname" );
    array_thread( cnd_fire_horizontal_light, maps\cornered_lighting::cnd_fire_horizontal_light );
    
    cnd_shaft_flickering = getentarray( "cnd_shaft_flickering", "targetname" );
    array_thread( cnd_shaft_flickering, maps\cornered_lighting::cnd_shaft_flickering );
}

horizontal_sunlight()
{
	flag_wait( "teleport" );
	
	thread horizontal_sunlight_flicker();
}

horizontal_sunlight_flicker()
{
    // tweakable values
	// -------------------------------------------
	// this is the base light color, this is pulled off of the stage volume and will need to be updated if ever changed there
	light_val_base = (1, 0.58, 0.3);
	
	// this is the intensity range applied to the base light color (max needs to be greater than min)
	light_scale_min = 0.65;
	light_scale_max = 1.5;
	
	// this is the range of time randomly picked to modulate the intensity between (max needs to be greater than min)
	light_modulate_time_min = 0.10;
	light_modulate_time_max = 0.37;
	// -------------------------------------------
	
	while( true )
	{
        scale = randomfloatrange( light_scale_min, light_scale_max );
		
        time = randomfloatrange( light_modulate_time_min, light_modulate_time_max );
		end = light_val_base * scale;
		start = light_val_base;
		
		sun_lerp_value( start, end, time );
        time = randomfloatrange( light_modulate_time_min, light_modulate_time_max );
		sun_lerp_value( end, start, time );
	}
}

sun_lerp_value(start, end, time)
{
    timeleft = time;
	pct = 0;
    while(timeleft > 0)
	{
        timeleft -= 0.05;
        pct = (time - timeleft) / time;
		
		val = start + (end - start) * pct;
        setsunlight(val[0], val[1], val[2]);
        level.currentsunlightcolor = (val[0], val[1], val[2]);
		waitframe();
	}	
}




















//stairwell_rumble_lights()
//{
//    lights = getentarray( "stairwell_blinker", "targetname" ); //intensity 1
//	
//    //todo hook up fixtures with on/off models
//	
//	//needs to run for ~1.5 seconds
//	for( i=0; i<7; i++ )
//	{
//		foreach( light in lights )
//		{ 
//            light setlightintensity( 0 );
//		}
//		
//		wait randomfloatrange( 0.05, 0.1 ); // ~0.075
//		rand_intensity = randomfloatrange( 0.5, 1.2 );
//		foreach( light in lights )
//		{ 
//            light setlightintensity( rand_intensity );
//		}
//		
//		wait randomfloatrange( 0.1, 0.2 ); // ~0.15
//	}
//
//	foreach( light in lights )
//	{ 
//        light setlightintensity( 1 );
//	}	
//}

//  call this function on a light to start it flickering.  if the light is linked (has script_linkto set) to models with script_noteworthys of "off" and "on," it'll show/hide the models appropriate to its current state
// generic_flickering in _lights.gsc



//===========================================
//             light animations
//===========================================

//courtyard reception elevator
cnd_reception_elevator()
{
    light = getent( "rec_elevator_light", "targetname" );
	
    org_intensity = light getlightintensity();
    light setlightintensity( 0.01 );
	
	flag_wait( "courtyard_intro_elevator_opening" );
	
    light setlightintensity( org_intensity );
}

//fire light for rapple floor
cnd_fire_rappel_light()
{
    full = self getlightintensity();

	old_intensity = full;

	for ( ;; )
	{
		intensity = randomfloatrange( full * 0.3, full * 1.5 );
		timer = randomfloatrange( 0.05, 0.1 );
		timer *= 15;

		for ( i = 0; i < timer; i++ )
		{
			new_intensity = intensity * ( i / timer ) + old_intensity * ( ( timer - i ) / timer );

            self setlightintensity( new_intensity );
			wait( 0.02 );
		}

		old_intensity = intensity;
	}
}


//fire light for the horizontal section.
cnd_fire_horizontal_light()
{
    full = self getlightintensity();

	old_intensity = full;

	for ( ;; )
	{
		intensity = randomfloatrange( full * 1.1, full * 1.8 );
		timer = randomfloatrange( 0.05, 0.2);
		timer *= 15;

		for ( i = 0; i < timer; i++ )
		{
			new_intensity = intensity * ( i / timer ) + old_intensity * ( ( timer - i ) / timer );

            self setlightintensity( new_intensity );
			wait( 0.02 );
		}

		old_intensity = intensity;
	}
}

//===========================================
//utilities needed for scripted light events
//===========================================


cnd_restarteffect()
{
	self common_scripts\_createfx::restart_fx_looper();
}


/*ent_flag_wait( msg )
{
    assertex( ( !issentient( self ) && isdefined( self ) ) || isalive( self ), "attempt to check a flag on entity that is not alive or removed" );

    while ( isdefined( self ) && !self.ent_flag[ msg ] )
		self waittill( msg );
}

ent_flag( message )
{
    assertex( isdefined( message ), "tried to check flag but the flag was not defined." );
    assertex( isdefined( self.ent_flag[ message ] ), "tried to check flag " + message + " but the flag was not initialized." );

	return self.ent_flag[ message ];
}
*/
cnd_ent_flag_clear( message )
{
/#
     assertex( isdefined( self ), "attempt to clear a flag on entity that is not defined" );
    assertex( isdefined( self.ent_flag[ message ] ), "attempt to set a flag before calling flag_init: " + message + " on entity." );
    assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = false;
#/
	//do this check so we don't unneccessarily send a notify
	if ( 	self.ent_flag[ message ] )
	{
		self.ent_flag[ message ] = false;
		self notify( message );
	}
}

cnd_ent_flag_set( message )
{
/#
     assertex( isdefined( self ), "attempt to set a flag on entity that is not defined" );
    assertex( isdefined( self.ent_flag[ message ] ), "attempt to set a flag before calling flag_init: " + message + " on entity." );
    assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = true;
#/
	self.ent_flag[ message ] = true;
	self notify( message );
}

cnd_ent_flag_init( message )
{
    if ( !isdefined( self.ent_flag ) )
	{
		self.ent_flag = [];
		self.ent_flags_lock = [];
	}

	/#
    if ( isdefined( level.first_frame ) && level.first_frame == -1 )
        assertex( !isdefined( self.ent_flag[ message ] ), "attempt to reinitialize existing message: " + message + " on entity." );
	#/

	self.ent_flag[ message ] = false;
/#
	self.ent_flags_lock[ message ] = false;
#/
}

cnd_is_light_entity( ent )
{
	return ent.classname == "light_spot" || ent.classname == "light_omni" || ent.classname == "light";
}

cnd_getclosests_flickering_model( origin )
{
	//stuff in prefabs bleh. non of this script_noteworthy or linkto stuff works there. so doing closest thing with the light_flicker_model targetname
	array = getentarray( "light_flicker_model", "targetname" );
	return_array = [];
	model = getclosest( origin, array );
	if ( isdefined( model ) )
		return_array[ 0 ] = model;
    return return_array;// i'm losing my mind

}

//===========================================
//tied models for scripted lights
//===========================================


cnd_shaft_flickering()
{
	
	self endon( "stop_dynamic_light_behavior" );
	
	
	self.linked_models = false;
	self.lit_models = undefined;
	self.unlit_models = undefined;
	self.linked_lights = false;
	self.linked_light_ents = [];
	self.linked_prefab_ents = undefined;
	self.linked_things = [];
	/*
    //prefab linkto scripts. finds lit and unlit models.
    if ( isdefined( self.script_linkto ) )
	{
		self.linked_prefab_ents = self get_linked_ents();
        assertex( self.linked_prefab_ents.size == 2, "dynamic light at " + self.origin + " needs to script_linkto a prefab that contains both on and off light models" );
		foreach( ent in self.linked_prefab_ents )
		{
			if ( ( isdefined( ent.script_noteworthy ) ) && ( ent.script_noteworthy == "on" ) )
			{
				if (!isdefined(self.lit_models))
					self.lit_models[0] = ent;
				else
					self.lit_models[self.lit_models.size] = ent;
				continue;
			}
			if ( ( isdefined( ent.script_noteworthy ) ) && ( ent.script_noteworthy == "off" ) )
			{
				if (!isdefined(self.unlit_models))
					self.unlit_models[0] = ent;
				else
					self.unlit_models[self.unlit_models.size] = ent;
				self.unlit_model = ent;
				continue;
			}
			if ( cnd_is_light_entity( ent ) )
			{
				self.linked_lights = true;
				self.linked_light_ents[ self.linked_light_ents.size ] = ent;
			}
		}
        assertex( isdefined( self.lit_models ), "dynamic light at " + self.origin + " needs to script_linkto a prefab contains a script_model light with script_noteworthy of 'on' " );
        assertex( isdefined( self.unlit_models ), "dynamic light at " + self.origin + " needs to script_linkto a prefab contains a script_model light with script_noteworthy of 'on' " );
		self.linked_models = true;
	}
	*/
		//----------old way of getting linked lights and models....still supported--------------//
	
	if ( isdefined( self.script_noteworthy ) )
		self.linked_things = getentarray( self.script_noteworthy, "targetname" );
	
	if ( ( ! self.linked_things.size ) && ( !isdefined( self.linked_prefab_ents ) ) )
		self.linked_things = cnd_getclosests_flickering_model( self.origin );
	
	
	for ( i = 0; i < self.linked_things.size; i++ )
	{
		if ( cnd_is_light_entity( self.linked_things[ i ] ) )
		{
			self.linked_lights = true;
			self.linked_light_ents[ self.linked_light_ents.size ] = self.linked_things[ i ];
		}
		if ( self.linked_things[ i ].classname == "script_model" )
		{
			lit_model = self.linked_things[ i ];
			if (!isdefined(self.lit_models))
				self.lit_models[0] = lit_model;
			else
				self.lit_models[self.lit_models.size] = lit_model;
			if (!isdefined(self.unlit_models))
				self.unlit_models[0] = getent( lit_model.target, "targetname" );
			else
				self.unlit_models[self.unlit_models.size] = getent( lit_model.target, "targetname" );
			self.linked_models = true;
		}
	}
	if (isdefined(self.lit_models))
	{
		foreach (lit_model in self.lit_models)
		{
			if (isdefined(lit_model) && isdefined(lit_model.script_fxid))
			{	// the light has an fx that we want to flicker as well
                lit_model.effect = createoneshoteffect(lit_model.script_fxid);
				offset = ( 0, 0, 0);
				angles = ( 0, 0, 0);
				if (isdefined(lit_model.script_parameters))
                {    // expect an offset of the form x y z
					tokens = strtok(lit_model.script_parameters, ", ");
					if (tokens.size < 3)
					{
						assertmsg( "lit_model script_parameters are expected to have three numbers for the offset");
					}
					else if (tokens.size == 6)
					{
                        x = float(tokens[0]);
                        y = float(tokens[1]);
                        z = float(tokens[2]);
						offset = ( x, y, z );
                        x = float(tokens[3]);
                        y = float(tokens[4]);
                        z = float(tokens[5]);
						angles = ( x, y, z );
					}
					else
					{
                        x = float(tokens[0]);
                        y = float(tokens[1]);
                        z = float(tokens[2]);
						offset = ( x, y, z );
					}
				}
				lit_model.effect.v[ "origin" ] = ( lit_model.origin + offset );
				lit_model.effect.v[ "angles" ] = ( lit_model.angles + angles );
			}
		}
	}
	
//calls light functions that will tie to the models.        
	self thread cnd_generic_flicker_msg_watcher();
	self thread cnd_generic_flicker();
}



//monitors level notifies to toggle the flicker light
cnd_generic_flicker_msg_watcher()
{
	self cnd_ent_flag_init("flicker_on");
	if(isdefined(self.script_light_startnotify) && self.script_light_startnotify != "nil") 
	{
		for(;;)
		{
			level waittill(self.script_light_startnotify);
			self cnd_ent_flag_set("flicker_on");
			if(isdefined(self.script_light_stopnotify) && self.script_light_stopnotify != "nil") 
			{
				level waittill(self.script_light_stopnotify);
				self cnd_ent_flag_clear("flicker_on");
			}
		}
		
	}
	else self cnd_ent_flag_set("flicker_on");
	
}



cnd_generic_flicker_pause()
{
    //if its turned off then, turn everything off and wait till it turns back on
	//	otherwise just exit
    f_on = self getlightintensity();
	if(! self ent_flag("flicker_on"))
	{
        //turn the light models off
		if ( self.linked_models )
		{
			if (isdefined(self.lit_models))
			{
				foreach (lit_model in self.lit_models)
				{
					lit_model hide();
					if (isdefined(lit_model.effect))
					{
                        lit_model.effect pauseeffect();
					}
				}
			}
			if (isdefined(self.unlit_models))
			{
				foreach (unlit_model in self.unlit_models)
					unlit_model show();
			}
		}
        //turn the light intensity off
        self setlightintensity( 0 );
		if ( self.linked_lights )
		{
			for ( i = 0; i < self.linked_light_ents.size; i++ )
                self.linked_light_ents[ i ] setlightintensity( 0 );
		}
		
        //wait here til the light is turned back on
		self waittill("flicker_on");
        //turn the light intensity back on
        self setlightintensity( f_on );
		if ( self.linked_lights )
		{
			for ( i = 0; i < self.linked_light_ents.size; i++ )
                self.linked_light_ents[ i ] setlightintensity( f_on );
		}
        //turn the light models back on
		if ( self.linked_models )
		{
			if (isdefined(self.lit_models))
			{
				foreach (lit_model in self.lit_models)
				{
					lit_model show();
					if (isdefined(lit_model.effect))
					{
                        lit_model.effect cnd_restarteffect();
					}
				}
			}
			if (isdefined(self.unlit_models))
			{
				foreach (unlit_model in self.unlit_models)
					unlit_model hide();
			}
		}
		
	}
}


cnd_generic_flicker()
{
	self endon( "stop_dynamic_light_behavior" );
	self endon( "death" );
	
	
	
	min_flickerless_time = .2;
	max_flickerless_time = 1.0;

    on = self getlightintensity();
	off = 0;
	curr = on;
	num = 0;
	
    //make the light flicker
	while( isdefined( self ) ) 
	{
        //adding a flag start/stop here
		self cnd_generic_flicker_pause();
		
		
		num = randomintrange( 1, 10 );
		while ( num )
		{
            //adding a flag start/stop here
			self cnd_generic_flicker_pause();
			
			
			wait( randomfloatrange( .05, .1 ) );
			if ( curr > .2 )
			{
				curr = randomfloatrange( 0, .3 );
				if ( self.linked_models )
				{
					foreach (lit_model in self.lit_models)
					{
						lit_model hide();
						if (isdefined(lit_model.effect))
						{
                            lit_model.effect pauseeffect();
						}
					}
				}
				if (isdefined(self.unlit_models))
				{
					foreach (unlit_model in self.unlit_models)
						unlit_model show();
				}
			}
			else
			{
				curr = on;
				if ( self.linked_models )
				{
					if (isdefined(self.lit_models))
					{
						foreach (lit_model in self.lit_models)
						{
							lit_model show();
							if (isdefined(lit_model.effect))
							{
                                lit_model.effect cnd_restarteffect();
							}
						}
					}
					if(isdefined(self.unlit_models))
					{
						foreach (unlit_model in self.unlit_models)
						{
							unlit_model hide();
							//maps\_audio::aud_send_msg("light_flicker_on", unlit_model);
						}
					}
				}
			}

            self setlightintensity( curr );
			if ( self.linked_lights )
			{
				for ( i = 0; i < self.linked_light_ents.size; i++ )
                    self.linked_light_ents[ i ] setlightintensity( curr );
			}
			num -- ;
		}
		
        //this section sets the light back on for flickerless time
		
        //adding a flag start/stop here
		self cnd_generic_flicker_pause();
		
		
        self setlightintensity( on );
		if ( self.linked_lights )
		{
			for ( i = 0; i < self.linked_light_ents.size; i++ )
                self.linked_light_ents[ i ] setlightintensity( on );
		}
		if ( self.linked_models )
		{
			if (isdefined(self.lit_models))
			{
				foreach (lit_model in self.lit_models)
				{
					lit_model show();
					if (isdefined(lit_model.effect))
					{
                        lit_model.effect cnd_restarteffect();
					}
				}
			}
			if (isdefined(self.unlit_models))
			{
				foreach (unlit_model in self.unlit_models)
					unlit_model hide();
			}
		}
		wait( randomfloatrange( min_flickerless_time, max_flickerless_time ) );
	}
}


// ****************************
// * fixtures/flashing lights *
// *********************************************************************************************************************************************************************


setup_fixtures()
{
    fixtures_off = getentarray( "hvt_office_light_fixture_off", "targetname" );
	foreach ( fixture in fixtures_off )
        fixture hide();
	
    fixtures_off = getentarray( "stairwell_light_fixture_off", "targetname" );
	foreach ( fixture in fixtures_off )
        fixture hide();
}

hvt_office_light()
{
    lights                 = getentarray( "hvt_office_light", "targetname" );
    fixtures_on             = getentarray( "hvt_office_light_fixture_on", "targetname" );
    fixtures_off         = getentarray( "hvt_office_light_fixture_off", "targetname" );
	on_intensity_min	= 0.5;
	on_intensity_max 	= 1.65;
	num_times			= 18;
	off_time_min		= 0.03; // ~0.075 
	off_time_max		= 0.12;
	on_time_min			= 0.05; // ~0.15
	on_time_max			= 0.15;
	
	thread fixture_blink_lights( lights, fixtures_on, fixtures_off, on_intensity_min, on_intensity_max, num_times, off_time_min, off_time_max, on_time_min, on_time_max );
}

stairwell_light( num_flickers )
{
    lights                 = getentarray( "stairwell_light_blink", "targetname" );
    fixtures_on             = getentarray( "stairwell_light_fixture_on", "targetname" );
    fixtures_off         = getentarray( "stairwell_light_fixture_off", "targetname" );
	on_intensity_min	= 0.5;
	on_intensity_max 	= 1.45;
	num_times			= num_flickers;
	off_time_min		= 0.06; // ~0.075 
	off_time_max		= 0.12;
	on_time_min			= 0.05; // ~0.15
	on_time_max			= 0.1;

	thread fixture_blink_lights( lights, fixtures_on, fixtures_off, on_intensity_min, on_intensity_max, num_times, off_time_min, off_time_max, on_time_min, on_time_max );
}

//lowpower_light_continuous( stop_notify )
//{
//	level endon( stop_notify );
//	
//    lights                 = getentarray( "lowpower", "targetname" );
//    fixtures_on             = getentarray( "lowpower_fixture_on", "targetname" );
//    fixtures_off         = getentarray( "lowpower_fixture_off", "targetname" );
//	on_intensity_min	= 0.3;
//	on_intensity_max 	= 0.7;
//	num_times			= 100;
//	off_time_min		= 0.1;
//	off_time_max		= 0.7;
//	on_time_min			= 0.1;
//	on_time_max			= 0.2;
//
//	while ( true )
//	{
//		fixture_blink_lights( lights, fixtures_on, fixtures_off, on_intensity_min, on_intensity_max, num_times, off_time_min, off_time_max, on_time_min, on_time_max );
//	}
//}

fixture_blink_lights( lights, fixtures_on, fixtures_off, on_intensity_min, on_intensity_max, num_times, off_time_min, off_time_max, on_time_min, on_time_max )
{
	level notify( "stop_blinking_fixtures" );
	level endon( "stop_blinking_fixtures" );
	
	thread cleanup_fixtures( lights, fixtures_on, fixtures_off, on_intensity_max, "stop_blinking_fixtures" );
	
	for ( i = 0; i < num_times; i++ )
	{
		foreach ( light in lights )
            light setlightintensity( 0 );
		foreach ( fixture in fixtures_on )
            fixture hide();
		foreach ( fixture in fixtures_off )
            fixture show();
		
        wait randomfloatrange( off_time_min, off_time_max );
		
        rand_intensity = randomfloatrange( on_intensity_min, on_intensity_max );
		foreach( light in lights )
            light setlightintensity( rand_intensity );
		foreach ( fixture in fixtures_on )
            fixture show();
		foreach ( fixture in fixtures_off )
            fixture hide();
		
        wait randomfloatrange( on_time_min, on_time_max );
	}
	
	level notify( "stop_blinking_fixtures" );
}

cleanup_fixtures( lights, fixtures_on, fixtures_off, on_intensity_max, notify_stop )
{
	level waittill( notify_stop );
	
	foreach( light in lights )
        light setlightintensity( on_intensity_max );
	foreach ( fixture in fixtures_on )
        fixture show();
	foreach ( fixture in fixtures_off )
        fixture hide();
}

// ****************************
// * fireworks                *
// *********************************************************************************************************************************************************************

fireworks_intro()
{
    assert( !isdefined( level.fireworks ) );
    assert( !IsDefined( level.fireworkStructs));
    assert( !isdefined( level.meteorfireworks ) );
    assert( !isdefined( level.meteorfireworkStructs ) );
	//exploder("fireworks_intro_smoke");
	location = "intro";
	
	waitframe();
	
	fireworks_init( location );
	
    /// start off with a bang
    fireworks_finale(66);
	
	// script the opening sequence of fireworks
	// right
	// 0 = blue small
	// 1 = blue large
	// 2 = red small
	// 3 = red large
	// 4 = meteor
	// left
	// 5 = blue small
	// 6 = blue large
	// 7 = red small
	// 8 = red large
	//// 9 = meteor
	//wait 0.2;
	//activate_firework( 0 );
	//wait 0.8;
	//activate_firework( 7 );
	//wait 0.2;
	//activate_firework( 1 );
	//wait 1;
	//activate_firework( 4 );
	//wait 0;
	//activate_firework( 9 );
	//wait 1.85;
	//activate_firework( 2 );
	//wait 2.35;
	//activate_firework( 6 );
	//wait 1.9;
	//activate_firework( 4 );
	//wait 2.35;
	//activate_firework( 3 );
	//activate_firework( 9 );
	//wait 2;
	//activate_firework( 4 );
	//wait 1.15;
	//activate_firework( 5 );
	//wait 1;
	//activate_firework( 9 );
	//wait 1.8;
	//activate_firework( 2 );
	//activate_firework( 4 );
	//wait 1.9;
	//activate_firework( 8 );
	//wait 1;
	//activate_firework( 9 );
	//wait 2.1;
	//activate_firework( 1 );
	//activate_firework( 4 );
	//wait 1;
	//activate_firework( 9 );
	//wait 1.1;
	//activate_firework( 7 );
	//activate_firework( 4 );
	//wait 2.3;
	//activate_firework( 0 );
	//activate_firework( 9 );
	//wait 1;
	//activate_firework( 8 );
	//wait 0.5;
	last_scripted_firework = 0;
	
	//activate_firework( last_scripted_firework );
	//wait 1;
	
	// let it go random now
	thread _fireworks_internal( location, last_scripted_firework );
	thread _fireworks_meteor_internal( location, last_scripted_firework );
}

fireworks_intro_post()
{
	waitframe();
		
	thread fireworks_start( "intro" );
}

fireworks_stealth_rappel()
{
	waitframe();
	
	thread fireworks_start( "stealth" );
}

fireworks_courtyard()
{
    assert( !isdefined( level.fireworks ) );
    assert( !IsDefined( level.fireworkStructs));
    assert( !isdefined( level.meteorfireworks ) );
    assert( !isdefined( level.meteorfireworkStructs ) );
	
	location = "courtyard";
	fireworks_init( location );
	waitframe();
	
	thread fireworks_courtyard_stairs();
    //fireworks_finale(32);
	// 0 = blue small
	// 1 = blue large
	// 2 = red small
	// 3 = red large
	// 4 = meteor
	//activate_firework_with_sun( 1 );
	//wait 3;
	//activate_firework_with_sun( 2 );
	//wait 3;
	//activate_firework_with_sun( 4 );
	//wait 1;
	//activate_firework_with_sun( 3 );
	//wait 4;
	last_scripted_firework = 0;
	//activate_firework_with_sun( last_scripted_firework );
	//wait 0.5;
	
	// let it go random now
	thread _fireworks_internal( location, last_scripted_firework );
	thread _fireworks_meteor_internal( location, last_scripted_firework );
}

fireworks_courtyard_post()
{
	waitframe();
	
	thread fireworks_start( "courtyard_stairs" );
}

// fireworks location near the stairs of the courtyard checkpoint
fireworks_courtyard_stairs()
{
	flag_wait( "move_to_courtyard_entrance" );
	
	thread fireworks_start( "courtyard_stairs" );
}

fireworks_junction()
{
    assert( !isdefined( level.fireworks ) );
    assert( !IsDefined( level.fireworkStructs));
    assert( !isdefined( level.meteorfireworks ) );
    assert( !isdefined( level.meteorfireworkStructs ) );
	
	location = "junction";
	fireworks_init( location );

	waitframe();
	
	// 0 = blue small
	// 1 = blue small
	// 2 = red small
	// 3 = red small
	// 4 = meteor
	//activate_firework_with_sun( 4 );
	//wait 0.5;
	//activate_firework_with_sun( 2 );
	//wait 0.8;
	//activate_firework_with_sun( 0 );
	//wait 1;
	//activate_firework_with_sun( 3 );
	//wait 2;
	//activate_firework_with_sun( 4 );
	//wait 0.1;
	//activate_firework_with_sun( 1 );
	//wait 1.5;
	last_scripted_firework = 0;
	//activate_firework_with_sun( last_scripted_firework );
	//wait 0.5;
	
	// let it go random now
	thread _fireworks_internal( location, last_scripted_firework );
	thread _fireworks_meteor_internal( location, last_scripted_firework );
}

fireworks_junction_post()
{
	waitframe();
		
	thread fireworks_start( "junction" );
}
firework_light(space,index,tint,transitiontime,transitionouttime)
{
    if (!isdefined(tint))
	{
		tint = (0,0,0);
	}
    if (!isdefined(transitiontime))
    {
        transitiontime = 1;
    }
    if (!isdefined(transitionouttime))
	{
        transitionouttime =  5;
	}
    steps = 10*transitiontime;

    //fullintensity = self getlightintensity();
    if (!isdefined(self.script_parameters))
    {
        fullintensity = 10.0;
    }
   	else
   	{
           fullintensity = int(self.script_parameters);
   	}
    
    //currentintensity = .01;
    currentintensity = self getlightintensity();
    self SetLightColor(tint);
    //fullintensity = 10; // test
    lightstep = (fullintensity-currentintensity)/steps;
    outsteps = 10*transitionouttime;
    lightoutstep = fullintensity/outsteps;
    //self setlightcolor(tint);
    
    tracker = level.fireworklightindextracker[space];
	for ( i = 0; i < steps; i++ )
	{
        if (!(level.fireworklightindextracker[space] == tracker))
		{
			break;
		}
        currentintensity+=lightstep;
        self setlightintensity(min(currentintensity,fullintensity));
		wait(.05);
	}
    if ((level.fireworklightindextracker[space] == tracker))
	{
        for ( i = 0; i < outsteps; i++ )
		{
            if (!(level.fireworklightindextracker[space] == tracker))
			{
				break;
			}
            currentintensity-=lightoutstep;
            self setlightintensity(max(.01,currentintensity));
			wait(.05);
		}
        //self setlightcolor((0,0,0));
    }
}
startfireworklightsonsection(space,tint)
{
	if (space >= 0 && space <= 3)
	{
	    lights = level.fireworklights[space];
	
	    level.fireworklightindextracker[space]+=1;
	    if (level.fireworklightindextracker[space] >48)
	{
	        level.fireworklightindextracker[space] = 0;
	}
	    for ( i = 0; i < level.fireworklights[space].size; i++ )
	{
	        level.fireworklights[space][i] thread firework_light(space,i,tint);
	}
	}
}

fireworks_start( location )
{
    fireworks_already_started = (isdefined( level.fireworks ) || isdefined( level.meteorfireworks )|| isdefined( level.fireworkStructs )|| isdefined( level.meteorfireworkStructs ));
	
	fireworks_init( location );
	
	if ( fireworks_already_started )
		return;
	
	thread _fireworks_internal( location );
	thread _fireworks_meteor_internal( location);
}

fireworks_stop()
{
    if ( !isdefined( level.fireworks ) || !isdefined( level.meteorfireworks ) || !isdefined( level.fireworkStructs )|| !isdefined( level.meteorfireworkStructs ))
		return;
		
	level notify( "stop_fireworks" );
	
	thread _fireworks_cleanup();
}


fireworks_init( location )
{
	level.fireworks = [];
    level.fireworkStructs = [];
    level.meteorfireworks = [];
    level.meteorfireworkStructs = [];
    level.currentFireworksLocation = location;
	
    if (is_gen4())
    {
		meteor   = ( 203, 144, 85 )  / 256.0;
		red	     = ( 225, 138,  8 )  / 256.0;
		blue     = ( 149, 235, 239)  / 256.0;
		purple   = ( 166,  90, 192)  / 256.0;
		green    = ( 129,  242, 96 )/ 256.0;
		white    = ( 255, 155, 55 )  / 256.0;
	}
    else
	{
        meteor   = ( 203, 144, 85  ) / 256.0;
        red      = ( 225, 161,  182) / 256.0;
        blue     = ( 161, 191, 225 ) / 256.0;
        purple   = ( 167,  0, 230)   / 256.0;
        green    = ( 161,  225, 181) / 256.0;
        white    = ( 192, 192, 192 ) / 256.0;
	}
		
		
    left   = 0;
    center = 1;	
    right  = 2; 
    none   = -1;
    if (location =="intro")
	{
    	if (is_gen4())
    	{
	    	suncolor = (0.819608, 0.976471, 1);
    	}
    	else
    	{
	    	suncolor = (0.823529, 0.980392, 1);
    		
    	}
	    colormultiplier = .6;
	    meteor   = (suncolor+(meteor)*colormultiplier)/2;
	    red      = (suncolor+(red	)*colormultiplier)/2;
	    blue     = (suncolor+(blue  )*colormultiplier)/2;
	    purple   = (suncolor+(purple)*colormultiplier)/2;
	    green    = (suncolor+(green )*colormultiplier)/2;
	    white    = (suncolor+(white )*colormultiplier)/2; 
	}
		
    level.fireworklights[left]     = getentarray( "firework_light_02", "targetname" ); // left
    level.fireworklights[center]   = getentarray( "firework_light_01", "targetname" ); // center
    level.fireworklights[right]    = getentarray( "firework_light_03", "targetname" ); // right
																			
    // temporary hack for previs/testing
    for ( i = 0; i < 3; i++ )
	{
        level.fireworklightindextracker[i] = 0;
        for ( j = 0; j < level.fireworklights[i].size; j++ )
		{
            intensity = level.fireworklights[i][j] getlightintensity();
            level.fireworklights[i][j].script_parameters = intensity;
            level.fireworklights[i][j] SetLightIntensity(0.01);
		}
		}
    //end
		
		
    colors = [meteor,red,blue,purple,green,white];
		
    /* These are not separated to another function for customization on amount of certain fireworks to play */
    //
    if (location == "intro" )
		{
        positions = [(-32596, 53993, 14595), (2067, 37400.75, 17595.8), (35664, 7879.75, 16595.8)];
        angles = [(271, 360, 0), (271, 360, 0), (271, 360, 0)];
        screenPositions = [0,1,2];
        setup_current_fireworks(positions,angles,screenPositions,colors);
        
        positions = [(-15299, 46161, 19744), (5834, 14505.75, 21545.8)];
        setup_current_fireworks(positions,angles,[.5,1.5],colors,true);
        
		}
    else if ( location == "junction") // these are for when you go through the junction right before and during combat rappel
		{
        positions = [(-67465,8665, 21595),  (-40058, 48365.75, 21595)];
        angles = [(271, 360, 0), (271, 360, 0)];
        screenPositions = [-1,2];
        setup_current_fireworks(positions,angles,screenPositions,colors);
        
		}
    //
    else if (location == "garden"  ) // these are for when you go through the junction right before and during combat rappel
	{
        positions = [(-34561, 42696, 21595), (9465, 30726, 21595), (18776, -870, 21595)];
        angles = [(271, 360, 0), (271, 360, 0), (271, 360, 0)];
        screenPositions = [0,1,2];
        setup_current_fireworks(positions,angles,screenPositions,colors);
		}
    //
    else if (location == "stealth") // these are for when you are going down the corridor after stealth rappel and the ai enemy are watching them out of the window.
		{
        positions = [(13800, -7987.75, 19595.8)];
        angles = [(271, 360, 0)];
        screenPositions = [2];
        setup_current_fireworks(positions,angles,screenPositions,colors);
        
        // Distant fireworks
        positions = [(-54000,-20000,16500)];
        angles = [(271, 360, 0)];
        screenPositions = [-1];
        setup_current_fireworks(positions,angles,screenPositions,colors,undefined,true);
		}
    //
    else if (location == "courtyard" || location == "courtyard_stairs" ) // these are for when you are going down the corridor after stealth rappel and the ai enemy are watching them out of the window.
		{
        positions = [(-30321, 49026, 21595), (3630, 32949, 21595), (30216, 500, 21595)];
        angles = [(271, 360, 0), (271, 360, 0), (271, 360, 0)];
        screenPositions = [0,1,2];
        setup_current_fireworks(positions,angles,screenPositions,colors);
		}
		else
		{
//    	IPrintLnBold(location);	
		}
		
		
    level.fireworks_sun         = _get_location_sunlight( location );
    level.fireworks_location     = location;
	}
		
setup_current_fireworks(positions,angels,screenPositions,colors,filler,distantonly)
{
	meteor   = colors[0];
	red      = colors[1];
	blue     = colors[2];
	purple   = colors[3];
	green    = colors[4];
	white    = colors[5];
	iterator = 0;
	if (!isdefined (distantonly))
    {
		if (!isdefined (filler))
		{
			foreach ( screenPos in screenPositions)
			{
				translate = positions[iterator];
				fwd = AnglesToForward(angels[iterator]);
			    up = AnglesToUp(angels[iterator]);
			    FW_BLUE_LRG     = SpawnFx(level._effect["fireworks_blue_lrg"],              		translate,fwd,up);
			    FW_RED_LRG      = SpawnFx(level._effect["fireworks_red_lrg"],               		translate,fwd,up);
			    FW_GREEN_LRG  = SpawnFx(level._effect["fireworks_green_lrg"],             		translate,fwd,up);
			    //FW_PURPLE_LRG   = SpawnFx(level._effect["fireworks_purple_lrg"],            		translate,fwd,up);
			    FW_WHITE_LRG    = SpawnFx(level._effect["fireworks_white_lrg"],             		translate,fwd,up);
			    FW_BLUE_SM      = SpawnFx(level._effect["fireworks_blue"],                  		translate,fwd,up);
			    FW_RED_SM       = SpawnFx(level._effect["fireworks_red"],                   		translate,fwd,up);
			    FW_GREEN_SM   = SpawnFx(level._effect["fireworks_green"],                    		translate,fwd,up);
			    //FW_PURPLE_SM    = SpawnFx(level._effect["fireworks_purple"],                		translate,fwd,up);
			    FW_WHITE_SM     = SpawnFx(level._effect["fireworks_white"],                 		translate,fwd,up);
			    FW_METEOR_01    = SpawnFx(level._effect["vfx_fireworks_ground_straight"],     		translate,fwd,up);
			    FW_METEOR_02    = SpawnFx(level._effect["fireworks_popping"],                    	translate,fwd,up);
			    FW_METEOR_03    = SpawnFx(level._effect["vfx_fireworks_groundflare_oneshot3"],   	translate,fwd,up);
			    FW_METEOR_04    = SpawnFx(level._effect["vfx_fireworks_groundflare_oneshot2"],   	translate,fwd,up);
			    FW_METEOR_05    = SpawnFx(level._effect["vfx_fireworks_groundflare_oneshot"],   	translate,fwd,up);
			    FW_METEOR_06    = SpawnFx(level._effect["vfx_fireworks_ground_straight_single"], 	translate,fwd,up);
			    FW_METEOR_07    = SpawnFx(level._effect["vfx_fireworks_meteors_trails"],         	translate,fwd,up);
			    add_large_firework(FW_BLUE_LRG,      blue,   screenPos ,6 );
			    add_large_firework(FW_RED_LRG,       red,    screenPos ,6 );
			    add_large_firework(FW_GREEN_LRG,   green,  screenPos ,6 );
			    //add_large_firework(FW_PURPLE_LRG,    purple, screenPos ,3 );
			    add_large_firework(FW_WHITE_LRG,     white,  screenPos ,6 );
			    add_small_firework(FW_BLUE_SM,       blue,   screenPos ,8 );
			    add_small_firework(FW_RED_SM,        red,    screenPos ,8 );
			    add_small_firework(FW_GREEN_SM,    green,  screenPos ,8 );
			    //add_small_firework(FW_PURPLE_SM,     purple, screenPos ,4 );
			    add_small_firework(FW_WHITE_SM,      white,  screenPos ,8 );
			    add_meteor_firework(FW_METEOR_01,    meteor, screenPos ,4 );
			    add_meteor_firework(FW_METEOR_02,    meteor, screenPos ,4 );
			    add_meteor_firework(FW_METEOR_03,    meteor, screenPos ,4 );
			    add_meteor_firework(FW_METEOR_04,    meteor, screenPos ,4 );
			    add_meteor_firework(FW_METEOR_05,    meteor, screenPos ,4 );
			    add_meteor_firework(FW_METEOR_06,    meteor, screenPos ,4 );
			    add_meteor_firework(FW_METEOR_07,    meteor, screenPos ,4 );
			    iterator+=1;
			}
		}
		else
		{
			iterator = 0;
			foreach ( screenPos in screenPositions)
			{
				translate = positions[iterator];
				fwd = AnglesToForward(angels[iterator]);
			    up = AnglesToUp(angels[iterator]);
			    FW_BLUE_LRG     = SpawnFx(level._effect["fireworks_blue_lrg"],              		translate,fwd,up);
			    FW_RED_LRG      = SpawnFx(level._effect["fireworks_red_lrg"],               		translate,fwd,up);
			    FW_GREEN_LRG  = SpawnFx(level._effect["fireworks_green_lrg"],             			translate,fwd,up);
			    FW_WHITE_LRG    = SpawnFx(level._effect["fireworks_white_lrg"],             		translate,fwd,up);
			    FW_BLUE_SM      = SpawnFx(level._effect["fireworks_blue"],                  		translate,fwd,up);
			    FW_RED_SM       = SpawnFx(level._effect["fireworks_red"],                   		translate,fwd,up);
			    FW_GREEN_SM   = SpawnFx(level._effect["fireworks_green"],                    		translate,fwd,up);
			    FW_WHITE_SM     = SpawnFx(level._effect["fireworks_white"],                 		translate,fwd,up);
			    add_small_firework(FW_BLUE_LRG,      blue,   screenPos ,1 );
			    add_small_firework(FW_RED_LRG,       red,    screenPos ,1 );
			    add_small_firework(FW_GREEN_LRG,     green,  screenPos ,1 );
			    add_small_firework(FW_WHITE_LRG,     white,  screenPos ,1 );
			    add_small_firework(FW_BLUE_SM,       blue,   screenPos ,2 );
			    add_small_firework(FW_RED_SM,        red,    screenPos ,2 );
			    add_small_firework(FW_GREEN_SM,      green,  screenPos ,2 );
			    add_small_firework(FW_WHITE_SM,      white,  screenPos ,2 );
			    iterator+=1;
			}
		}
	}
	else
	{
		foreach ( screenPos in screenPositions)
		{
			translate = positions[iterator];
			fwd = AnglesToForward(angels[iterator]);
		    up = AnglesToUp(angels[iterator]);
		    FW_BLUE_SM      = SpawnFx(level._effect["fireworks_blue_sm"],                  		translate,fwd,up);
		    FW_RED_SM       = SpawnFx(level._effect["fireworks_red_sm"],                   		translate,fwd,up);
		    FW_GREEN_SM     = SpawnFx(level._effect["fireworks_green_sm"],                    	translate,fwd,up);
		    FW_WHITE_SM     = SpawnFx(level._effect["fireworks_white_sm"],                 		translate,fwd,up);
		    FW_ALL_SM     = SpawnFx(level._effect["fireworks_all_sm"],                 		translate,fwd,up);
		    add_small_firework(FW_BLUE_SM,     blue,   screenPos ,4 );
		    add_small_firework(FW_RED_SM,      red,    screenPos ,4 );
		    add_small_firework(FW_GREEN_SM,    green,  screenPos ,4 );
		    add_small_firework(FW_WHITE_SM,    white,  screenPos ,4 );
		    add_small_firework(FW_ALL_SM,      white,  screenPos ,8 );
		    iterator+=1;
		}
		
	}
} 
		
add_meteor_firework( fx, color, loc,multiplier )
{
	if (!multiplier)
	{
		multiplier = 1;	
	}
	for ( i = 0; i < multiplier; i++ )
	{
        setup_meteor_firework(fx, color, 2.5, "meteor", 1, loc );
	}
}
add_small_firework( fx, color, loc,multiplier )
{
	if (!multiplier)
	{
		multiplier = 1;	
	}
	for ( i = 0; i < multiplier; i++ )
	{
        setup_firework(fx, color, 3, "small", 2, loc );
	}
}
// The effect, Color, Screen location, Relative Frequency
add_large_firework( fx, color, loc,multiplier )
{
	if (!multiplier)
	{
		multiplier = 1;	
	}
	for ( i = 0; i < multiplier; i++ )
	{
        setup_firework(fx, color, 6, "large", 3, loc );
	}
}

// The effect, Color, Time on screen, Size/Type, Radius, Screen Location
setup_firework( fx, color, time, type, girth, loc )
{
		num = level.fireworks.size;
    level.fireworkStructs[ num ]         = spawnstruct();
    level.fireworkStructs[ num ].color  = color;
    level.fireworkStructs[ num ].time     = time;
    level.fireworkStructs[ num ].type     = type;
    level.fireworkStructs[ num ].girth  = girth;
    level.fireworkStructs[ num ].loc     = loc;
    level.fireworks[num] = fx;
	}
setup_meteor_firework( fx, color, time, type, girth, loc )
{
    num = level.meteorfireworks.size;
    level.meteorfireworkStructs[ num ]         = spawnstruct();
    level.meteorfireworkStructs[ num ].color = color;
    level.meteorfireworkStructs[ num ].time     = time;
    level.meteorfireworkStructs[ num ].type     = type;
    level.meteorfireworkStructs[ num ].girth = girth;
    level.meteorfireworkStructs[ num ].loc     = loc;
    level.meteorfireworks[num] = fx;
}
fireworks_finale(num)
{
	thread fireworks_finale_streamers(num/3);
	thread fireworks_finale_explosions(num);
}
fireworks_finale_streamers(ct)
{
	num=0;
	wait(.5);
	for ( i = 0; i < ct; i++ )
	{
		num = get_random_streamer_num(num);
		activate_firework(num,"meteor");
        wait (randomfloatrange(.55,.71));
	}
}
fireworks_finale_explosions(ct)
{
	
	sunlight = level.fireworks_sun;
	if ( sunlight != level.fireworks_sun )
		sunlight = level.fireworks_sun;
	num=0;
	wait(.5);
	for ( i = 0; i < ct; i++ )
	{
		num = get_random_firework_num(num);
        if (level.fireworkStructs[num].type == "large")
		{
			thread _firework_sunlight( num, sunlight );
			if (is_gen4())
			{
                if (level.fireworkStructs[num].loc != -1)
                {
                	if (level.fireworkStructs[num].loc == 0.5)
                	{
                    	level thread startfireworklightsonsection(0,level.fireworkStructs[num].color);
                    	level thread startfireworklightsonsection(1,level.fireworkStructs[num].color);
                	}
                	else if (level.fireworkStructs[num].loc == 1.5)
                	{
                    	level thread startfireworklightsonsection(1,level.fireworkStructs[num].color);
                    	level thread startfireworklightsonsection(2,level.fireworkStructs[num].color);
                	}
                	else
                	{
                	
                    	level thread startfireworklightsonsection(level.fireworkStructs[num].loc,level.fireworkStructs[num].color);	
                	}
                }
			}
			
		}
		activate_firework(num);
        wait (randomfloatrange(.40,.51));
	}
}
_fireworks_internal( location, prev_num )
{
	level endon( "stop_fireworks" );
	
    println( "fireworks starting: " + location );
    /# setdvarifuninitialized( "fireworks_debug", "0" ); #/
		
	num = 0;//get_random_firework_num( prev_num );
	while ( true )
	{
		//num = get_random_firework_num( num );
		sunlight = level.fireworks_sun;
		if ( sunlight != level.fireworks_sun )
			sunlight = level.fireworks_sun;
		if ( location != level.fireworks_location )
		{
			location = level.fireworks_location;
			num = get_random_firework_num();
		}
        if (level.fireworkStructs[num].type == "large")
		{
			thread _firework_sunlight( num, sunlight );
				
			if (is_gen4())
			{
                if (level.fireworkStructs[num].loc != -1)
                {
                	if (level.fireworkStructs[num].loc == 0.5)
                	{
                    	level thread startfireworklightsonsection(0,level.fireworkStructs[num].color);
                    	level thread startfireworklightsonsection(1,level.fireworkStructs[num].color);
                	}
                	else if (level.fireworkStructs[num].loc == 1.5)
                	{
                    	level thread startfireworklightsonsection(1,level.fireworkStructs[num].color);
                    	level thread startfireworklightsonsection(2,level.fireworkStructs[num].color);
                	}
                	else
                	{
                	
                    	level thread startfireworklightsonsection(level.fireworkStructs[num].loc,level.fireworkStructs[num].color);	
                	}
				}
                
			}
        }
		activate_firework( num ,"explosion");
		next_num = get_random_firework_num(num);
		_firework_wait( num, next_num, location,"explosion" );
        //IPrintLnBold("explosion Playing");
		num=next_num;
		wait(.05);
	}
}

_fireworks_meteor_internal( location, prev_num )
{
	level endon( "stop_fireworks" );
    println( "fireworks starting: " + location );
    /# setdvarifuninitialized( "fireworks_debug", "0" ); #/
	
	snum = 0;//get_random_firework_num( prev_num );
	
	while ( true )
	{
		if ( location != level.fireworks_location )
		{
			location = level.fireworks_location;
			snum = get_random_streamer_num();
		}
		
		//snum = get_random_streamer_num(snum);
		activate_firework( snum ,"meteor");
		next_num = get_random_streamer_num(snum);
		_firework_wait( snum, next_num, location ,"meteor");
        //IPrintLnBold("Meteor Playing");
		snum=next_num;
		wait(.05);
	}
}

//activate_firework_with_sun( num ,typ)
//{
//	activate_firework( num,typ);
//	
//	thread _firework_sunlight( num, level.fireworks_sun );
//}
activate_firework( num ,typ)
{
    if (!isdefined(typ))
	{
		typ = "explosion";
	}
	if (typ == "explosion")
	{
		if (num == -1)
		{
			num = get_random_firework_num();
		}
        if (num >= level.fireworkStructs.size)
		{
            num = level.fireworkStructs.size-1;    
		}
		fw = level.fireworks[num];
        //iprintlnbold(fw.id);
        TriggerFX(fw);
        //maps\cornered_fx::activate_fireworks_exploder( fw.id );
	}
	else if (typ == "meteor")
	{
		if (num == -1)
		{
			num = get_random_streamer_num();
		}
        if (num >= level.meteorfireworkStructs.size)
		{
            num = level.meteorfireworkStructs.size-1;    
		}
        fw = level.meteorfireworks[num];
        //iprintlnbold(fw.id);
        TriggerFX(fw);
        //maps\cornered_fx::activate_fireworks_exploder( fw.id );
	}
	// start the firework exploder
	
	
/#
    if ( getdvar( "fireworks_debug", "0" ) != "0" )
	{
        if ( isdefined( level.last_firework_time ) )
		{
            wait_time = ( gettime() - level.last_firework_time ) / 1000.0;
            println( "wait " + wait_time + ";" );
		}
		
        println( "activate_firework_with_sun( " + num + " );" );
        level.last_firework_time = gettime();
	}
#/ 
}
get_random_streamer_num( current_num )
{
    if (!isdefined(current_num))
	{
		current_num = 0;
	}
    next_num = randomintrange( 0, level.meteorfireworkStructs.size -1);
	
	if (current_num == next_num)
	{
		next_num+=1;
        if (next_num+1 > level.meteorfireworkStructs.size)
		{
			next_num = 0;
		}
	}
	// make sure random looks good
    if ( isdefined( current_num ) )
	{
        fw = level.meteorfireworkStructs[next_num];
        last_fw = level.meteorfireworkStructs[current_num];
		
		same_as_last = next_num == current_num;
		same_girth = fw.girth == last_fw.girth;
		
		// if the same girth in different locations allow for it
        if ( same_girth && isdefined( fw.loc ) && isdefined( last_fw.loc ) && fw.loc != last_fw.loc )
			same_girth = false;
		
		if ( same_as_last || same_girth )
            next_num = ( ( current_num + 2 ) % level.meteorfireworkStructs.size );
	}
    if (next_num ==level.meteorfireworkStructs.size)
	{
		next_num -=1;
	}
	return next_num;
}
get_random_firework_num( current_num )
{
    if (!isdefined(current_num))
	{
		current_num = 0;
	}
    next_num = randomintrange( 0, level.fireworkStructs.size-1 );
	if (current_num == next_num)
	{
		next_num+=1;
        if (next_num+1 > level.fireworkStructs.size)
		{
			next_num = 0;
		}
	}
	// make sure random looks good
    if ( isdefined( current_num ) )
	{
        fw = level.fireworkStructs[next_num];
        last_fw = level.fireworkStructs[current_num];
		
		same_as_last = next_num == current_num;
		same_girth = fw.girth == last_fw.girth;
		
		// if the same girth in different locations allow for it
        if ( same_girth && isdefined( fw.loc ) && isdefined( last_fw.loc ) && fw.loc != last_fw.loc )
			same_girth = false;
		
		if ( same_as_last || same_girth )
            next_num = ( ( current_num + 2 ) % level.fireworkStructs.size );
	}
    if (next_num ==level.fireworkStructs.size)
	{
		next_num -=1;
	}
	return next_num;
}

_firework_wait( current_num, next_num, location,typ )
{
    if (!isdefined(typ))
	{
		typ = "meteor";
	}
	
	// determine when to launch the next firework, let them overlap in certain cases
	//fw = level.fireworks[current_num];
	//next_fw = level.fireworks[next_
	min_wait = .8;
	max_wait = 1.0;
	if (  ( location == "junction" || location == "intro" ) )
	{
		if (typ == "explosion")
		{
			
			min_wait = .53;
			max_wait = .8;
		}
		else
		{
			// streamers
			min_wait = 1.2;
			max_wait = 1.7;
		}
	}
	else
	{
		if (typ == "explosion")
		{
			
			min_wait = .95;
			max_wait = 1.4;
		}
		else
		{
			// streamers
			min_wait = 2.7;
			max_wait = 3.4;
		}
	}
	
    wait_time = randomfloatrange( min_wait, max_wait );
	wait wait_time;
}

_firework_sunlight( num, sunlight )
{
	level notify( "new_firework" );
	level endon( "new_firework" );
	
    fw = level.fireworkStructs[num];
	
	switch ( fw.type )
	{
		case "large":
			_firework_large( sunlight, fw.color, fw.time );
			break;
		//case "small":
		//	_firework_small( sunlight, fw.color, fw.time );
		//	break;
		//case "meteor":
		//	_firework_meteor( sunlight, fw.color, fw.time );
		//	break;	
	}
}

//_firework_small( sunlight, color, time )
//{
//	time_ramp_up 	= time * 0.1;
//	time_on 		= time * 0.2;
//	time_ramp_down 	= time * 0.7;
//	
//    if (isdefined(level.currentsunlightcolor))
//	{
//        sunlight = level.currentsunlightcolor;    
//	}
//	sun_lerp_value( sunlight, color, time_ramp_up );
//	
//	wait time_on;
//	
//	sun_lerp_value( color, sunlight, time_ramp_down );
//}

_firework_large( sunlight, color, time )
{
	time_ramp_up 	= .6;
	time_on 		= .5;
	time_ramp_down 	= 2.8;
		
    if (isdefined(level.currentsunlightcolor))
	{
        sunlight = level.currentsunlightcolor;    
	}
    if (IsDefined(level.currentFireworksLocation))
    {
    	baseColor = _get_location_sunlight(level.currentFireworksLocation);
    	if ( flag( "do_specular_sun_lerp" ) )
    		thread lerp_spec_color_scale( level.spec_cg_fireworks_high, level.spec_ng_fireworks_high, time_ramp_up );
		sun_lerp_value( sunlight, color, time_ramp_up );
		wait time_on;
    	if ( flag( "do_specular_sun_lerp" ) )
			thread lerp_spec_color_scale( level.spec_cg_fireworks_low, level.spec_ng_fireworks_low, time_ramp_down );
		sun_lerp_value( color, baseColor, time_ramp_down );
    }
}

do_specular_sun_lerp( value )
{
	if ( value )
		thread _turn_on_spec_sun_lerp();
	else
		thread _turn_off_spec_sun_lerp();
}

_turn_on_spec_sun_lerp()
{
	lerp_spec_color_scale( level.spec_cg_fireworks_low, level.spec_ng_fireworks_low, 1 );
	flag_set( "do_specular_sun_lerp" );
}

_turn_off_spec_sun_lerp()
{
	flag_clear( "do_specular_sun_lerp" );
	thread lerp_spec_color_scale( level.spec_cg, level.spec_ng, 1 );
}

//_firework_meteor( sunlight, color, time )
//{
//	time_off		= time * 0.8;
//	time_ramp_up 	= time * 0.1;
//	time_ramp_down 	= time * 0.1;
//	
//    if (isdefined(level.currentsunlightcolor))
//	{
//        sunlight = level.currentsunlightcolor;    
//	}
//	sun_lerp_value( sunlight, color, time_ramp_up );
//	
//	sun_lerp_value( color, sunlight, time_ramp_down );
//}

_fireworks_cleanup()
{
	level.fireworks = undefined;
    level.fireworkStructs = undefined;
    level.meteorfireworks = undefined;
    level.meteorfireworkStructs = undefined;
	level.fireworks_stop = undefined;
	level.fireworks_sun = undefined;
	level.fireworks_location = undefined;	
}

_get_location_sunlight( location )
{
	// these are pulled off of the stage volumes, will need to be manually updated if ever changed there
	switch ( location )
	{
		case "junction":
			return ( ( 255, 214, 156 ) / 256.0 ) * 0.35;
		case "garden":
			return ( ( 255, 251, 221 ) / 256.0 ) * 1.0;
		case "intro":
	    	if (is_gen4())
	    	{
		    	return (0.819608, 0.976471, 1);
	    	}
	    	else
	    	{
		    	return (0.823529, 0.980392, 1);
	    	}
		case "stealth":
		case "courtyard":
		case "courtyard_stairs":
			return ( ( 255, 251, 221 ) / 256.0 ) * 0.6; // no stage volume, worldspawn settings
		default:
            assertmsg( "_get_location_sunlight called with unknown location: " + location );
			break;
	}
}

// ****************************
// * fog tweaks               *
// ****************************

get_fog_ent( vision_set )
{
	current_vision_set = "";
    if ( isdefined( vision_set ) )
	{
		current_vision_set = vision_set;	
	}
    else if ( isdefined( level.player.vision_set_transition_ent ) )
	{
		current_vision_set = level.player.vision_set_transition_ent.vision_set;
	}
	else
	{
		current_vision_set = level.vision_set_transition_ent.vision_set;
	}
	return level.vision_set_fog[ current_vision_set ];
}

set_fog_ent( ent, transition_time )
{
    if ( !isdefined( transition_time ) )
	{
		transition_time = ent.transitiontime;
	}
	set_fog_to_ent_values( ent, transition_time );
	wait( transition_time );
}

handle_fog_changes()
{
	flag_wait( "parachute_exfil" );	// set when player teleports to exterior
	ent					  = get_fog_ent( "cornered_09" );
    ent.sundir = ( 0, 0, 1 );

	set_fog_ent( ent, 1 );
}


// ****************************
// * changing spec            *
// *********************************************************************************************************************************************************************
lerp_spec_color_scale( value_cg, value_ng, time_sec )
{
	level notify( "lerp_spec_color_scale" );
	level endon( "lerp_spec_color_scale" );
	
	time_step = 0.05;
	
	value = value_cg;
	if ( is_gen4() )
		value = value_ng;
	
	current = GetDvarFloat( "r_specularcolorscale" );
	
	if ( current == value )
		return;
	
	diff = value - current;
	num_steps = time_sec / time_step;
	step = diff / num_steps;
	
	for ( cur_step = 0; cur_step < num_steps; cur_step++ )
	{
		current += step;
		SetSavedDvar( "r_specularcolorscale", current );
//		PrintLn( "SPEC: " + current );
		
		wait time_step;
	}
	
	SetSavedDvar( "r_specularcolorscale", value );
//	PrintLn( "SPEC: " + current );
}
