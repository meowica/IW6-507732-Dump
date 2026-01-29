// _createart generated.  modify at your own risk. 
main()
{
	sunflare();

	ent = maps\_utility::create_vision_set_fog( "iplane" );
	ent.startDist = 9266;
	ent.halfwayDist = 60852.7;
	ent.red = 0.561796;
	ent.green = 0.530604;
	ent.blue = 0.439498;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.sunRed = 0.5;
	ent.sunGreen = 0.5;
	ent.sunBlue = 0.5;
	ent.HDRSunColorIntensity = 1;
	ent.sunDir = (-0.98165, 0.166975, -0.0920999);
	ent.sunBeginFadeAngle = 11.2717;
	ent.sunEndFadeAngle = 19.6979;
	ent.normalFogScale = 4.19862;
 
}

sunflare()
{
	ent = maps\_utility::create_sunflare_setting( "default" );
	ent.position = (-30, 85, 0);
	maps\_art::sunflare_changes( "default", 0 );
}
