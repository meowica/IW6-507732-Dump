// _createart generated.  modify at your own risk. 
main()
{
	sunflare();

	ent = maps\_utility::create_vision_set_fog( "odin" );
	ent.startDist = 100000;
	ent.halfwayDist = 150000;
	ent.red = 0.00784314;
	ent.green = 0.419608;
	ent.blue = 0.509804;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 0.3538;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 0;
	ent.skyFogMinAngle = 0;
	ent.skyFogMaxAngle = 90;
 
}

sunflare()
{
	ent = maps\_utility::create_sunflare_setting( "default" );
	ent.position = (5,160,0);
	maps\_art::sunflare_changes( "default", 0 );
}
