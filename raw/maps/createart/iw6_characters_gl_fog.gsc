// _createart generated.  modify at your own risk. 
main()
{
	ent = maps\_utility::create_vision_set_fog( "nextgentest_day" );
	ent.startDist = 720.818;
	ent.halfwayDist = 2699.15;
	ent.red = 0.629272;
	ent.green = 0.654037;
	ent.blue = 0.663329;
	ent.maxOpacity = 0.730441;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 1;
	ent.sunRed = 0.788155;
	ent.sunGreen = 0.776585;
	ent.sunBlue = 0.705601;
	ent.sunDir = (0.681224, -0.647833, 0.340949);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 59.0007;
	ent.normalFogScale = 1.96032;
 
	ent = maps\_utility::create_vision_set_fog( "nextgen_interior_day" );
	ent.startDist = 102.746;
	ent.halfwayDist = 441.418;
	ent.red = 0.778546;
	ent.green = 0.904002;
	ent.blue = 0.893509;
	ent.maxOpacity = 0.0592389;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
 
	maps\_utility::vision_set_fog_changes( "nextgentest_day", 0 );
}
