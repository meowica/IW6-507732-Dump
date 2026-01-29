// _createart generated.  modify at your own risk. 
main()
{
	ent = maps\_utility::create_vision_set_fog( "oilrocks" );
	ent.startDist = 11.1739;
	ent.halfwayDist = 23293.9;
	ent.red = 0.309463;
	ent.green = 0.347044;
	ent.blue = 0.399733;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.567975;
	ent.sunGreen = 0.431674;
	ent.sunBlue = 0.30319;
	ent.sunDir = (0.654484, 0.424796, 0.684713);
	ent.sunBeginFadeAngle = 0.990927;
	ent.sunEndFadeAngle = 56.3946;
	ent.normalFogScale = 0.137762;
 
	ent = maps\_utility::create_vision_set_fog( "oilrocks_intro" );
	ent.startDist = 0;
	ent.halfwayDist = 17987;
	ent.red = 0.906954;
	ent.green = 0.850416;
	ent.blue = 0.794648;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 1;
	ent.sunGreen = 0.725195;
	ent.sunBlue = 0.610339;
	ent.sunDir = (0.0366702, -0.998205, -0.047344);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 107.384;
	ent.normalFogScale = 1;
 
	ent = maps\_utility::create_vision_set_fog( "oilrocks_infantry" );
	ent.startDist = 10987.8;
	ent.halfwayDist = 70533.1;
	ent.red = 0.919337;
	ent.green = 0.922066;
	ent.blue = 1;
	ent.maxOpacity = 0.273353;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
 
	ent = maps\_utility::create_vision_set_fog( "oilrocks_canyon" );
	ent.startDist = 4201.2;
	ent.halfwayDist = 19735;
	ent.red = 0.57114;
	ent.green = 0.655362;
	ent.blue = 0.697905;
	ent.maxOpacity = 0.572285;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.870101;
	ent.sunGreen = 0.584597;
	ent.sunBlue = 0.452244;
	ent.sunDir = (0.632019, 0.33738, 0.372642);
	ent.sunBeginFadeAngle = 17.9259;
	ent.sunEndFadeAngle = 36.3376;
	ent.normalFogScale = 1.84929;
 
	maps\_utility::vision_set_fog_changes( "oilrocks", 0 );
}
