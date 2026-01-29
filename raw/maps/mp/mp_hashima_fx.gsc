main()
{

/#
    if ( GetDvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_hashima_fx::main();
#/
	level._effect[ "mp_frag_button_off" ] = LoadFX( "fx/lights/lights_green_sm" );
	level._effect[ "mp_frag_button_on" ]  = LoadFX( "fx/lights/lights_red_sm" );
	level._effect[ "claymore_explosion" ] = LoadFX( "fx/explosions/claymore_explosion" );
}
