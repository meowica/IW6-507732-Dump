// _createart generated.  modify at your own risk. 
main()
{
	ent = maps\_utility::create_vision_set_fog( "nextgentest" );
	ent.startDist = 972.479;
	ent.halfwayDist = 722.394;
	ent.red = 0.334755;
	ent.green = 0.298906;
	ent.blue = 0.31653;
	ent.maxOpacity = 0.463015;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.797875;
	ent.sunGreen = 0.577248;
	ent.sunBlue = 0.474737;
	ent.sunDir = (0.130292, 0.986982, 0.0942954);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 23.4075;
	ent.normalFogScale = 1.10202;
 
	ent = maps\_utility::create_vision_set_fog( "nextgen_interior" );
	ent.startDist = 3002.82;
	ent.halfwayDist = 4441.94;
	ent.red = 0.274278;
	ent.green = 0.269338;
	ent.blue = 0.292162;
	ent.maxOpacity = 0.933133;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.sunRed = 0.803764;
	ent.sunGreen = 0.706592;
	ent.sunBlue = 0.519137;
	ent.sunDir = (0.178125, 0.951636, 0.25032);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 46.8412;
	ent.normalFogScale = 0.272347;
 
	maps\_utility::vision_set_fog_changes( "nextgentest", 0 );
}
