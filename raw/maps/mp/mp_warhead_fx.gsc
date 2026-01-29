main()
{
	level._effect["engine_smoke_light"]							= loadfx( "fx/smoke/battlefield_smokebank_s" );
	level._effect["engine_smoke_heavy"]							= loadfx( "fx/smoke/bg_smoke_plume_mp" );
	
	level._effect["engine_smoke_fill"]							= loadfx( "fx/smoke/factory_ambush_smoke_grenade" );
	
	level._effect["engine_fire"]								= loadfx( "fx/fire/jet_engine_fire" );
	//level._effect["engine_fire"]								= loadfx( "fx/_requests/mp_warhead/shuttle_engine_fire" );
	
/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_warhead_fx::main();
#/

}
