main()
{
	level._effect[ "rod_of_god_shockwave" ] 	= loadfx( "fx/maps/mp_strikezone/rod_of_god_shockwave" );
	level._effect[ "mp_sz_debris" ]				= loadfx( "fx/maps/mp_lonestar/mp_ls_quake_debris" );
	level._effect[ "mp_sz_debris_lrg" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_quake_debris_lrg" );
	level._effect[ "mp_sz_dust_int" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_quake_dust_int" );
	level._effect[ "mp_sz_dustkickup" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_dustkickup" );
	level._effect[ "mp_sz_chunks" ] 			= loadfx( "fx/maps/mp_lonestar/mp_ls_quake_chunks" );
	level._effect[ "mp_sz_panel" ] 				= loadfx( "fx/maps/mp_lonestar/mp_ls_panel" );
	level._effect[ "mp_sz_trim" ] 				= loadfx( "fx/maps/mp_lonestar/mp_ls_trim" );
	level._effect[ "cloud_ash_embers_mp" ] 		= loadfx( "vfx/moments/mp_strikezone/vfx_sz_cloud_ash_embers_mp" );

/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_strikezone_fx::main();
#/

}
