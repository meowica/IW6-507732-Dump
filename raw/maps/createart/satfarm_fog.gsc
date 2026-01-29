// _createart generated.  modify at your own risk. 
main()
{
	sunflare();

	ent = maps\_utility::create_vision_set_fog( "satfarm" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 0;
	ent.skyFogMinAngle = 0;
	ent.skyFogMaxAngle = 0;
 
	ent = maps\_utility::create_vision_set_fog( "satfarm_satellite_view" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 0;
	ent.skyFogMinAngle = 0;
	ent.skyFogMaxAngle = 0;
 
	ent = maps\_utility::create_vision_set_fog( "satfarm_sabot_view" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.HDRColorIntensity = 1;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	ent.skyFogIntensity = 0;
	ent.skyFogMinAngle = 0;
	ent.skyFogMaxAngle = 0;
 
	ent = maps\_utility::create_vision_set_fog( "satfarmtank20" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
 
	ent = maps\_utility::create_vision_set_fog( "satfarmtank40" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
 
	ent = maps\_utility::create_vision_set_fog( "satfarmtank60" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
 
	ent = maps\_utility::create_vision_set_fog( "satfarmtank80" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
 
	ent = maps\_utility::create_vision_set_fog( "satfarmtank100" );
	ent.startDist = 27293.1;
	ent.halfwayDist = 37539.9;
	ent.red = 0.477054;
	ent.green = 0.470709;
	ent.blue = 0.417866;
	ent.maxOpacity = 0.533192;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
 
}

sunflare()
{
	ent = maps\_utility::create_sunflare_setting( "default" );
	ent.position = (-21, 72, 0);
	maps\_art::sunflare_changes( "default", 0 );
}
