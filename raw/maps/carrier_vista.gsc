#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;

run_vista()
{
//	thread sparrow_launchers();
	thread phalanx_guns();
	thread destroyer_battle();
	thread cruiser_battle();
	thread jet_battle();
	thread water_effects();
}

sparrow_launchers()
{

}

phalanx_guns()
{		
	fx_array = getentarray( "fx_phalanx", "targetname" ); 
	foreach ( fx in fx_array )
	{
       	playfx( level._effect[ "antiair_runner" ], fx.origin );
	}   		
}

destroyer_battle()
{
	level endon( "pre_odin_strike" );
	
	usboat1 = getent( "us_destroyer_1", "targetname" );
    usboat1_target = getstruct( usboat1.target, "targetname" );
    usboat1 MoveTo( usboat1_target.origin, 200 );
    
    //wait(RandomFloatRange(30,60));
//    wait 3;
//    playfx( level._effect[ "aa_explosion_super" ],usboat1.origin);
//    	
    
    fedboat1 = getent( "fed_destroyer_1", "targetname" );
    fedboat1_target = getstruct( fedboat1.target, "targetname" );
    fedboat1 MoveTo(fedboat1_target.origin, 210 );

    usboat2 = getent( "us_destroyer_2", "targetname" );
    usboat2_target = getstruct( usboat2.target, "targetname" );
    usboat2 MoveTo( usboat2_target.origin, 320 );
    
    fedboat2 = getent( "fed_destroyer_2", "targetname" );
    fedboat2_target = getstruct( fedboat2.target, "targetname" );
    fedboat2 MoveTo(fedboat2_target.origin, 325 );
    
    usboat3 = getent( "us_destroyer_3", "targetname" );
    usboat3_target = getstruct( usboat3.target, "targetname" );
    usboat3 MoveTo( usboat3_target.origin, 300 );
    
    fedboat3 = getent( "fed_destroyer_3", "targetname" );
    fedboat3_target = getstruct( fedboat3.target, "targetname" );
    fedboat3 MoveTo(fedboat3_target.origin, 300);
    
	usboat4	 = GetEnt( "us_destroyer_4", "targetname" );
    
    fedboat4 = getent( "fed_destroyer_4", "targetname" );
    fedboat4_target = getstruct( fedboat4.target, "targetname" );
    fedboat4 MoveTo(fedboat4_target.origin, 250 );
    
    usboat5 = getent( "us_destroyer_5", "targetname" );
    
    usboat6 = getent( "us_destroyer_6", "targetname" );
    usboat6_target = getstruct( usboat6.target, "targetname" );
    usboat6 MoveTo( usboat6_target.origin, 250 );
    
    usboat7 = getent( "us_destroyer_7", "targetname" );
    usboat7_target = getstruct( usboat7.target, "targetname" );
    usboat7 MoveTo( usboat7_target.origin, 250 );
    
    usboat8 = getent( "us_destroyer_8", "targetname" );
    usboat8_target = getstruct( usboat8.target, "targetname" );
    usboat8 MoveTo( usboat8_target.origin, 250 );
    
    usboat9 = getent( "us_destroyer_9", "targetname" );
    usboat9_target = getstruct( usboat9.target, "targetname" );
    usboat9 MoveTo( usboat9_target.origin, 250 );
    
    usboat10 = getent( "us_destroyer_10", "targetname" );
    usboat10_target = getstruct( usboat10.target, "targetname" );
    usboat10 MoveTo( usboat10_target.origin, 250 );
    
    usboat11 = getent( "us_destroyer_11", "targetname" );
    usboat11_target = getstruct( usboat11.target, "targetname" );
    usboat11 MoveTo( usboat11_target.origin, 250 );
    
   	boats_array = [usboat1,fedboat1,usboat2,fedboat2,usboat3,fedboat3,fedboat4,usboat4,usboat5,usboat6,usboat7,usboat8,usboat9,usboat10,usboat11];
   	array_thread( boats_array, ::antiair_fx );
   	array_thread( boats_array, ::ship_wakes );
    wait 8;
   	while ( true )
    {
        boat = random( boats_array );
        playfx( level._effect[ "ny_battleship_explosion" ], boat.origin,(0,0,-100));     
        wait RandomintRange( 2, 6 );
    }
}
ship_wakes()
{
	playfx( level._effect[ "ny_dvora_wakebow_chback" ], self.origin,(300,0,0),(0,0,-100) );
	wait RandomintRange( 2, 4 );
}

antiair_fx()
{
	playfx( level._effect[ "antiair_runner" ], self.origin );
}

cruiser_battle()
{
	level endon( "pre_odin_strike" );
	
	fedboat1 = getent( "fed_cruiser_1", "targetname" );
    fedboat1_target = getstruct( fedboat1.target, "targetname" );
    fedboat1 MoveTo( fedboat1_target.origin,320 );
    
    usboat1 = getent( "us_cruiser_1", "targetname" );
    usboat1_target = getstruct( usboat1.target, "targetname" );
    usboat1 MoveTo( usboat1_target.origin, 300 );
    
    fedboat2 = getent( "fed_cruiser_2", "targetname" );
    fedboat2_target = getstruct( fedboat2.target, "targetname" );
    fedboat2 MoveTo( fedboat2_target.origin, 310 );
    
    
    usboat2 = getent( "us_cruiser_2", "targetname" );
    usboat2_target = getstruct( usboat2.target, "targetname" );
    usboat2 MoveTo( usboat2_target.origin, 350 );
    
    usboat3 = getent( "us_cruiser_3", "targetname" );
    usboat3_target = getstruct( usboat3.target, "targetname" );
    usboat3 MoveTo( usboat3_target.origin, 350 );
    
    fedboat3 = getent( "fed_cruiser_3", "targetname" );
    fedboat3_target = getstruct( fedboat3.target, "targetname" );
    fedboat3 MoveTo( fedboat3_target.origin, 310 );
    
    usboat4 = getent( "us_cruiser_4", "targetname" );
    usboat4_target = getstruct( usboat4.target, "targetname" );
    usboat4 MoveTo( usboat4_target.origin, 350 );
    
    usboat5 = getent( "us_cruiser_5", "targetname" );
    usboat5_target = getstruct( usboat5.target, "targetname" );
    usboat5 MoveTo( usboat5_target.origin, 350 );
    
    boats_array = [usboat1,fedboat1,fedboat2,usboat2,usboat3,fedboat3,usboat4,usboat5];
    array_thread( boats_array, ::antiair_fx );
    wait 8;
    while ( true )
    {
        boat = random( boats_array );
       	wait RandomintRange( 2, 4);
    }
 }



jet_battle()
{
	level endon( "jet_battle_end" );
	while (true)
	{
		spawn_vehicle_from_targetname_and_drive("enemy_jet_1");
		spawn_vehicle_from_targetname_and_drive("good_jet_1");
		
		wait 15;
		
		spawn_vehicle_from_targetname_and_drive("enemy_jet_2");
		spawn_vehicle_from_targetname_and_drive("good_jet_2");
		
		wait 20;
		
		spawn_vehicle_from_targetname_and_drive("enemy_jet_3");
		spawn_vehicle_from_targetname_and_drive("good_jet_3");
		
		wait 10;
		
		spawn_vehicle_from_targetname_and_drive("enemy_jet_4");
		spawn_vehicle_from_targetname_and_drive("good_jet_4");
		spawn_vehicle_from_targetname_and_drive("good_jet_5");
		
		wait 8;
		spawn_vehicle_from_targetname_and_drive("enemy_jet_1");
		spawn_vehicle_from_targetname_and_drive("good_jet_1");
		
		wait 15;
		
		spawn_vehicle_from_targetname_and_drive("enemy_jet_2");
		spawn_vehicle_from_targetname_and_drive("good_jet_2");
		
		wait 8;
		
		spawn_vehicle_from_targetname_and_drive("enemy_jet_3");
		spawn_vehicle_from_targetname_and_drive("good_jet_3");
		
		wait 13;
		
		spawn_vehicle_from_targetname_and_drive("enemy_jet_4");
		spawn_vehicle_from_targetname_and_drive("good_jet_4");
		spawn_vehicle_from_targetname_and_drive("good_jet_5");
		
		wait 15;
	}
}

water_effects()
{
//carrier wake effect
	wake_waves = getent("wake","targetname");
	PlayLoopedFX(level._effect[ "water_wake_lg" ],0.5,wake_waves.origin);	
	
//attack splash effects
	splash_array = getentarray( "splash", "targetname" );
	
    while ( true )
    {        
        fx = random( splash_array );
       	playfx( level._effect[ "water_splash_large_eiffel_tower_bigger" ], fx.origin);
	    wait RandomintRange( 1, 6);
    }

}