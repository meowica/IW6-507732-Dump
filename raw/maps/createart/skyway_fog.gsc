// _createart generated.  modify at your own risk. 
main()
{
        sunflare();

	ent = maps\_utility::create_vision_set_fog( "skyway" );
	ent.startDist = 6050;
	ent.halfwayDist = 44683;
	ent.red = 0.502;
	ent.green = 0.623;
	ent.blue = 0.636;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.5;
	ent.sunGreen = 0.57;
	ent.sunBlue = 0.597;
	ent.HDRSunColorIntensity = 1;
	ent.sunDir = (0, 0, -1);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 79;
	ent.normalFogScale = 3.1;
	ent.skyFogIntensity = 0;
	ent.skyFogMinAngle = 0;
	ent.skyFogMaxAngle = 0;
	
	maps\_utility::vision_set_fog_changes( "skyway", 0 );
	 	
 	ent = maps\_utility::create_vision_set_fog( "skyway_rogstrike" );
	ent.startDist = 6050;
	ent.halfwayDist = 44683;
	ent.red = 0.502;
	ent.green = 0.623;
	ent.blue = 0.636;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.5;
	ent.sunGreen = 0.570;
	ent.sunBlue = 0.597;
	ent.sunDir = (0,0,-1);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 79;
	ent.normalFogScale = 3.1;
		
	ent = maps\_utility::create_vision_set_fog( "skyway_pip" );
	ent.startDist = 0;
	ent.halfwayDist = 2049;
	ent.red = 0.632813;
	ent.green = 0.617188;
	ent.blue = 0.53125;
	ent.maxOpacity = 0.476563;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.862916;
	ent.sunGreen = 0.842104;
	ent.sunBlue = 0.816201;
	ent.sunDir = (0.843772, -0.411199, 0.344911);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 59.373;
	ent.normalFogScale = 0.300968;
}

sunflare()
{
	ent = maps\_utility::create_sunflare_setting( "default" );
	ent.position = (-28.1567, 89.649, 0);
	maps\_art::sunflare_changes( "default", 0 );
}



	

