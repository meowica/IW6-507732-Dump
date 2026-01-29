// _createart generated.  modify at your own risk. 
main()
{
	sunflare();

	ent = maps\_utility::create_vision_set_fog( "carrier" );
	ent.startDist = 13827.3;
	ent.halfwayDist = 24850.4;
	ent.red = 0.555696;
	ent.green = 0.597785;
	ent.blue = 0.656403;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 84.2;
	ent.skyFogMaxAngle = 90.85;
 
	ent = maps\_utility::create_vision_set_fog( "carrier_flashback" );
	ent.startDist = 500;
	ent.halfwayDist = 322;
	ent.red = 0.0851242;
	ent.green = 0.105686;
	ent.blue = 0.126648;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 116;
	ent.skyFogMaxAngle = 105;
 
	ent = maps\_utility::create_vision_set_fog( "carrier_fever_dream" );
	ent.startDist = 8218.31;
	ent.halfwayDist = 32469.8;
	ent.red = 0.465734;
	ent.green = 0.45853;
	ent.blue = 0.352753;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 0;
	ent.skyFogMinAngle = 0;
	ent.skyFogMaxAngle = 0;
 
	ent = maps\_utility::create_vision_set_fog( "prague_escape_flashback" );
	ent.startDist = 17346.3;
	ent.halfwayDist = 32487.6;
	ent.red = 0.583682;
	ent.green = 0.52939;
	ent.blue = 0.302793;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 0;
	ent.skyFogMinAngle = 0;
	ent.skyFogMaxAngle = 0;
 
	ent = maps\_utility::create_vision_set_fog( "carrier_intro" );
	ent.startDist = 712.933;
	ent.halfwayDist = 24193.7;
	ent.red = 0.306861;
	ent.green = 0.314145;
	ent.blue = 0.342254;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 81.46;
	ent.skyFogMaxAngle = 93.83;
 
	ent = maps\_utility::create_vision_set_fog( "carrier_sparrow" );
	ent.startDist = 0;
	ent.halfwayDist = 14566.8;
	ent.red = 0.589054;
	ent.green = 0.597721;
	ent.blue = 0.601251;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 84.2;
	ent.skyFogMaxAngle = 90.85;
 
	ent = maps\_utility::create_vision_set_fog( "carrier_rog" );
	ent.startDist = 0;
	ent.halfwayDist = 20033.9;
	ent.red = 0.537678;
	ent.green = 0.596887;
	ent.blue = 0.600211;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 1;
	ent.skyFogMinAngle = 84.2;
	ent.skyFogMaxAngle = 90.85;
 
	ent = maps\_utility::create_vision_set_fog( "ac130_thermal" );
	ent.startDist = 1000;
	ent.halfwayDist = 12000;
	ent.red = 0;
	ent.green = 0;
	ent.blue = 0;
	ent.maxOpacity = 0.8;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.sunRed = 0;
	ent.sunGreen = 0;
	ent.sunBlue = 0;
	ent.sunDir = (0, 0, 0);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 0;
	ent.normalFogScale = 0;
 
	ent = maps\_utility::create_vision_set_fog( "ac130_enhanced" );
	ent.startDist = 1024;
	ent.halfwayDist = 13243.8;
	ent.red = 0.523226;
	ent.green = 0.58013;
	ent.blue = 0.587826;
	ent.maxOpacity = 0.681619;
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
	ent.position = (-30, 85, 0);
	maps\_art::sunflare_changes( "default", 0 );
}
