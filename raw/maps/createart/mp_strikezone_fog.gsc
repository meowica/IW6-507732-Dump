// _createart generated.  modify at your own risk. 
main()
{
	ent = maps\mp\_art::create_vision_set_fog( "mp_strikezone" );
	ent.startDist = 528.898;
	ent.halfwayDist = 9881.64;
	ent.red = 0.80;
	ent.green = 0.88;
	ent.blue = 1;
	ent.maxOpacity = 0.25;
	ent.transitionTime = 0;
	ent.stagedVisionSets = [ "mp_strikezone", "prague_escape_nuke_flash", "prague_escape_nuke_explosion", "prague_escape_nuke_end", "mp_strikezone_fogout" ];
	ent.sunFogEnabled = 1;
	ent.sunRed = 1;
	ent.sunGreen = 1;
	ent.sunBlue = .94;
	ent.sunDir = (-0.27, -0.86, 0.40);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 100;
	ent.normalFogScale = 1.0625;
	ent.HDROverride = "mp_lonestar_HDR";
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 54;
	ent.skyFogMaxAngle = 82;

	ent = maps\mp\_art::create_vision_set_fog( "mp_strikezone_after" );
	ent.startDist = 200;
	ent.halfwayDist = 3500;
	ent.red = 0.54;
	ent.green = 0.54;
	ent.blue = 0.54;
	ent.maxOpacity = 0.75;
	ent.transitionTime = 0;
	ent.stagedVisionSets = [ "mp_strikezone_after", "mp_strikezone_after", "mp_strikezone_after", "mp_strikezone_after", "mp_strikezone_fogout" ];
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.92;
	ent.sunGreen = 0.69;
	ent.sunBlue = 0.44;
	ent.sunDir = (-0.27, -0.86, 0.40);
	ent.sunBeginFadeAngle = 15;
	ent.sunEndFadeAngle = 60;
	ent.normalFogScale = 2.25;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = -90;
	ent.skyFogMaxAngle = 180;
	
	ent = maps\mp\_art::create_vision_set_fog( "mp_strikezone_fogout" );
	ent.startDist = 0.0;
	ent.halfwayDist = 16.0;
	ent.red = 0.393723;
	ent.green = 0.314233;
	ent.blue = 0.141142;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = -90;
	ent.skyFogMaxAngle = -90;

	ent = maps\mp\_art::create_vision_set_fog( "prague_escape_nuke_explosion" );
	ent.startDist = 17346.3;
	ent.halfwayDist = 32487.6;
	ent.red = 0.583682;
	ent.green = 0.52939;
	ent.blue = 0.302793;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = -90;
	ent.skyFogMaxAngle = 180;
 
	ent = maps\mp\_art::create_vision_set_fog( "prague_escape_nuke_flash" );
	ent.startDist = 17346.3;
	ent.halfwayDist = 32487.6;
	ent.red = 0.583682;
	ent.green = 0.52939;
	ent.blue = 0.302793;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = -90;
	ent.skyFogMaxAngle = 180;
 
	ent = maps\mp\_art::create_vision_set_fog( "prague_escape_nuke_end" );
	ent.startDist = 17346.3;
	ent.halfwayDist = 32487.6;
	ent.red = 0.583682;
	ent.green = 0.52939;
	ent.blue = 0.302793;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = -90;
	ent.skyFogMaxAngle = 180;
}
