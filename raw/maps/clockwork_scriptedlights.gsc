#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\clockwork_code;
#include maps\clockwork_interior_nvg;


//gsc for setting up scripted light functions in clockwork.
main()
{
	init_lights();
}


//===========================================
// 			init_lights
//===========================================
init_lights()
{
	
	cw_thermite_charge_light = GetEntArray( "cw_thermite_charge_light", "targetname" );
    array_thread( cw_thermite_charge_light, maps\clockwork_scriptedlights::cw_thermite_charge_light );
    
	cw_lights_out_script_1 = GetEntArray( "cw_lights_out_script_1", "targetname" );
    array_thread( cw_lights_out_script_1, maps\clockwork_scriptedlights::cw_lights_out_script_1 );
    
    cw_lights_out_script_2 = GetEntArray( "cw_lights_out_script_2", "targetname" );
    array_thread( cw_lights_out_script_2, maps\clockwork_scriptedlights::cw_lights_out_script_2 );
    
    cw_lights_out_script_3 = GetEntArray( "cw_lights_out_script_3", "targetname" );
    array_thread( cw_lights_out_script_3, maps\clockwork_scriptedlights::cw_lights_out_script_3 );
    
    cw_lights_out_script_4 = GetEntArray( "cw_lights_out_script_4", "targetname" );
    array_thread( cw_lights_out_script_4, maps\clockwork_scriptedlights::cw_lights_out_script_4 );

    cw_lights_out_script_5 = GetEntArray( "cw_lights_out_script_5", "targetname" );
    array_thread( cw_lights_out_script_5, maps\clockwork_scriptedlights::cw_lights_out_script_5 );
    
    cw_snowmobile_light = GetEntArray( "cw_snowmobile_light", "targetname" );
    array_thread( cw_snowmobile_light, maps\clockwork_scriptedlights::cw_snowmobile_light );
    
    cw_chaos_vault_light = GetEntArray( "cw_thermite_charge_light", "targetname" );
    array_thread( cw_chaos_vault_light, maps\clockwork_scriptedlights::cw_chaos_vault_light );
    
    cw_snowmobile_headlight = GetEntArray( "cw_snowmobile_headlight", "targetname" );
    array_thread( cw_snowmobile_headlight, maps\clockwork_scriptedlights::cw_snowmobile_headlight );
    
}


//===========================================
// 			setup_light_animations
//===========================================

//Turns off snowmobile headlight.
cw_snowmobile_headlight()
{
	self GetLightIntensity();
	
	flag_wait("FLAG_intro_light_off");
	
	self SetLightIntensity(0.0);
	self SetLightRadius(12);
}

//thermite light, occurs when thermite charge is detonated
cw_thermite_charge_light()
{
	// Level Start Setup //
	self GetLightRadius();
	self SetLightIntensity( 0.1 );
	self SetLightRadius( 12 );
	self SetLightColor((1.0, 0.9, 0.6));

	flag_wait("glow_start");
	flag_wait("thermite_start");  // temp? hack - comment out if we want to start glow based on glow_start notetrack
	// start low, orangy glow //

	self SetLightRadius( 350 );
	self SetLightColor((1, 0.85, 0.65));
	self SetLightFovRange( 119, 10 );

	self SetLightIntensity( 0.25 );  // 1st light
	wait 0.5;
	self SetLightIntensity( 0.5 );  // 2nd light
	wait 0.5;
	self SetLightIntensity( 0.75 ); // 3rd light on, 1st light off
	wait 0.5;
	self SetLightIntensity( 0.5 );  // back down to 2 lights
	wait 0.5;
	self SetLightIntensity( 0.25 );  // only 1 light
	
	flag_wait("thermite_start");  // redundant but keeping incase we go back to note-track timeed thermite
	
	// Thermite Flashing Start //
	flag_wait("thermite_start");
	self SetLightIntensity( 0.6 );
    full = self getLightIntensity();
	old_intensity = full;

	self SetLightRadius( 400 );

	time_out = GetTime() + 6000;

	while ( !flag("thermite_stop") )
	{
		
		intensity = randomfloatrange( full * 1.0, full * 5.0 );
		timer = randomfloatrange( 0.05, 0.1 );
		timer *= 15;

		for ( i = 0; i < timer; i++ )
		{
			new_intensity = intensity * ( i / timer ) + old_intensity * ( ( timer - i ) / timer );

			self setLightIntensity( new_intensity );
			wait( 0.05 );
		}

		old_intensity = intensity;
	}
	    
	
	// Temporary Hack for Orangy Glow //
	self SetLightRadius( 350 );
	self SetLightColor((1, 0.85, 0.65));
	self SetLightIntensity( 0.75 );
	self SetLightFovRange( 119, 10 );
	wait 30;	
	self SetLightIntensity( 0.1 );
	self SetLightRadius( 12 );
	
	// Using as spill light for after lights come back on //
	flag_wait("lights_on");
	self SetLightRadius( 300 );
	self SetLightIntensity( 0.5 );
	self SetLightColor((0.87, 0.87, 1.0));
	
}


//NVG Lights out and back on scripts. COOL COLOR
cw_lights_out_script_1()
{
	old_light_int = self GetLightIntensity();
	old_light_radi = self GetLightRadius();
	old_intensity = old_light_int;
	
	wait 5;
	//color =  VectorLerp((0, 0, 0), (0.76, 0.83, 1), 3);
	self SetLightColor((1.0, 1.0, 1.0)); //ADD COLOR VALUE HERE (Neutral/White)
	
	flag_wait("lights_out");
	
	self SetLightIntensity( 0.01 );
	self SetLightRadius( 12 );
	
	flag_wait("lights_on");
	vision_set_changes("clockwork_indoor", 3);
		
	self SetLightIntensity( old_light_int );
	self SetLightRadius( old_light_radi );
}


//NVG Lights out and back on scripts. WARM COLOR

cw_lights_out_script_2()
{
	old_light_int = self GetLightIntensity();
	old_light_radi = self GetLightRadius();
	old_intensity = old_light_int;
	
	wait 5;
	//color =  VectorLerp((0, 0, 0), (0.76, 0.83, 1), 3);
	self SetLightColor((0.8666, 0.9372, 1));  //ADD COLOR VALUE HERE (Blue)
	
	flag_wait("lights_out");
	
	self SetLightIntensity( 0.01 );
	self SetLightRadius( 12 );
	
	flag_wait("lights_on");
	vision_set_changes("clockwork_indoor", 3);
	
	
	self SetLightIntensity( old_light_int );
	self SetLightRadius( old_light_radi );
}

//NVG Lights out and back on scripts. NEUTRAL COLOR

cw_lights_out_script_3()
{
	old_light_int = self GetLightIntensity();
	old_light_radi = self GetLightRadius();
	old_intensity = old_light_int;
	
	wait 5;
	//color =  VectorLerp((0, 0, 0), (0.76, 0.83, 1), 3);
	self SetLightColor((0.9921, 0.8666, 0.8));  //ADD COLOR VALUE HERE (Red)
	
	flag_wait("lights_out");
	
	self SetLightIntensity( 0.01 );
	self SetLightRadius( 12 );
	
	flag_wait("lights_on");
	vision_set_changes("clockwork_indoor", 3);
	
	
	self SetLightIntensity( old_light_int );
	self SetLightRadius( old_light_radi );
}

cw_lights_out_script_4()
{
	old_light_int = self GetLightIntensity();
	old_light_radi = self GetLightRadius();
	old_intensity = old_light_int;
	
	wait 5;
	//color =  VectorLerp((0, 0, 0), (0.76, 0.83, 1), 3);
	self SetLightColor((1.0, 0.9568, 0.7568));  //ADD COLOR VALUE HERE (Yellow)
	
	flag_wait("lights_out");
	
	self SetLightIntensity( 0.01 );
	self SetLightRadius( 12 );
	
	flag_wait("lights_on");
	vision_set_changes("clockwork_indoor", 3);
	
	
	self SetLightIntensity( old_light_int );
	self SetLightRadius( old_light_radi );
}

cw_lights_out_script_5()
{
	old_light_int = self GetLightIntensity();
	old_light_radi = self GetLightRadius();
	old_intensity = old_light_int;
	
	wait 5;
	//color =  VectorLerp((0, 0, 0), (0.76, 0.83, 1), 3);
	self SetLightColor((0.5137, 0.7019, 1));  //ADD COLOR VALUE HERE (Neon Blue)
	
	flag_wait("lights_out");
	
	self SetLightIntensity( 0.01 );
	self SetLightRadius( 12 );
	
	flag_wait("lights_on");
	vision_set_changes("clockwork_indoor", 3);
	
	
	self SetLightIntensity( old_light_int );
	self SetLightRadius( old_light_radi );
}

//SNOWMOBILE SCRIPTED LIGHT
cw_snowmobile_light()
{
	full = self getLightIntensity();

	old_intensity = full;

	for ( ;; )
	{
		intensity = randomfloatrange( full * 0.3, full * 1.1 );
		timer = randomfloatrange( 0.05, 0.1 );
		timer *= 15;

		for ( i = 0; i < timer; i++ )
		{
			new_intensity = intensity * ( i / timer ) + old_intensity * ( ( timer - i ) / timer );

			self setLightIntensity( new_intensity );
			wait( 0.05 );
		}

		old_intensity = intensity;
	}
}

cw_chaos_vault_light()
{
//	
//	flag_wait("glow_start");
//	flag_wait("thermite_start");  // temp? hack - comment out if we want to start glow based on glow_start notetrack
//	// start low, orangy glow //
//	
//	// Level Start Setup //
//	self GetLightRadius();
//	self SetLightIntensity( 0.1 );
//	self SetLightRadius( 12 );
//	self SetLightColor((1.0, 0.9, 0.6));
////
//	self SetLightRadius( 350 );
//	self SetLightColor((1, 0.85, 0.65));
//	self SetLightFovRange( 119, 10 );
//
//	self SetLightIntensity( 0.25 );  // 1st light
//	wait 0.5;
//	self SetLightIntensity( 0.5 );  // 2nd light
//	wait 0.5;
//	self SetLightIntensity( 0.75 ); // 3rd light on, 1st light off
//	wait 0.5;
//	self SetLightIntensity( 0.5 );  // back down to 2 lights
//	wait 0.5;
//	self SetLightIntensity( 0.25 );  // only 1 light
//	
//	flag_wait("thermite_start");  // redundant but keeping incase we go back to note-track timeed thermite
//	
//	// Thermite Flashing Start //
//	flag_wait("thermite_start");
//	self SetLightIntensity( 0.6 );
//    full = self getLightIntensity();
//	old_intensity = full;
//
//	self SetLightRadius( 400 );
//
//	time_out = GetTime() + 6000;
//
//	while ( !flag("thermite_stop") )
//	{
//		
//		intensity = randomfloatrange( full * 1.0, full * 5.0 );
//		timer = randomfloatrange( 0.05, 0.1 );
//		timer *= 15;
//
//		for ( i = 0; i < timer; i++ )
//		{
//			new_intensity = intensity * ( i / timer ) + old_intensity * ( ( timer - i ) / timer );
//
//			self setLightIntensity( new_intensity );
//			wait( 0.05 );
//		}
//
//		old_intensity = intensity;
//	}
//	    
//	// Temporary Hack for Orangy Glow //
//	self SetLightRadius( 350 );
//	self SetLightColor((1, 0.85, 0.65));
//	self SetLightIntensity( 0.75 );
//	self SetLightFovRange( 119, 10 );
//	wait 30;	
//	self SetLightIntensity( 0.1 );
//	self SetLightRadius( 12 );
	
	// Using as spill light for after lights come back on //
	flag_wait("lights_on");
	self SetLightRadius( 300 );
	self SetLightIntensity( 0.75 );
	self SetLightColor((0.87, 0.87, 1.0));	
}