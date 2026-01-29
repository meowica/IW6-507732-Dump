// _createart generated.  modify at your own risk. 
main()
{
	ent = maps\_utility::create_vision_set_fog( "patriot_crib_proto" );
	ent.startDist = 1074;
	ent.halfwayDist = 3080;
	ent.red = 0.54;
	ent.green = 0.63;
	ent.blue = 0.68;
	ent.maxOpacity = 0.51;
	ent.transitionTime = 0;
	ent.sunFogEnabled = 0;
	
 	maps\_utility::vision_set_fog_changes( "patriot_crib_proto", 0 );
}
