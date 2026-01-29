// _createart generated.  modify at your own risk. 
main()
{
	ent = maps\mp\_art::create_vision_set_fog( "mp_hashima" );
	ent.startDist = 1536;
	ent.halfwayDist = 37856;
	ent.red = 0.82;
	ent.green = 0.97;
	ent.blue = 1;
	ent.maxOpacity = 0.5;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 1;
	ent.sunGreen = 1;
	ent.sunBlue = 0.95;
	ent.sunDir = (0.097, -0.031, -0.375);
	ent.sunBeginFadeAngle = 55;
	ent.sunEndFadeAngle = 180;
	ent.normalFogScale = 2.5;
	ent.HDROverride = "mp_hashima_HDR";
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 60;
	ent.skyFogMaxAngle = 80;

	ent = maps\mp\_art::create_vision_set_fog( "mp_hashima_HDR" );
	ent.startDist = 1536;
	ent.halfwayDist = 37856;
	ent.red = 0.82;
	ent.green = 0.97;
	ent.blue = 1;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 0.5;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.87;
	ent.sunGreen = 0.93;
	ent.sunBlue = 1;
	ent.HDRSunColorIntensity = 1;
	ent.sunDir = (0.097, -0.031, -0.375);
	ent.sunBeginFadeAngle = 55;
	ent.sunEndFadeAngle = 180;
	ent.normalFogScale = 2.5;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 60;
	ent.skyFogMaxAngle = 80;
}
