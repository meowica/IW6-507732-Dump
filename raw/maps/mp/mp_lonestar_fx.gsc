main()
{
	//Exploders
	level._effect[ "mp_ls_dustkickup_surface" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_dustkickup_surface" );
	level._effect[ "mp_ls_ground_dust" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_ground_dust" );
	level._effect[ "mp_ls_quake_chunks" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_quake_chunks" );
	level._effect[ "mp_ls_panel" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_panel" );
	level._effect[ "mp_ls_trim" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_trim" );
	level._effect[ "mp_ls_quake_debris" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_quake_debris" );
	level._effect[ "mp_ls_quake_debris_lrg" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_quake_debris_lrg" );
	level._effect[ "mp_ls_quake_dust_int" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_quake_dust_int" );
	level._effect[ "mp_ls_dustkickup" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_dustkickup" );
	level._effect[ "mp_ls_car_smash" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_car_smash" );
	level._effect[ "bats_single_spooked" ] = loadfx( "fx/animals/bats_single_spooked" );
	level._effect[ "mp_ls_concrete_smash" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_concrete_smash" );
	level._effect[ "mp_ls_gaspipe_fire" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_gaspipe_fire" );
	
	//Placed Ambient 
    level._effect[ "vfx_handflare_sov" ] = loadfx( "vfx/ambient/props/vfx_handflare_sov" );
	level._effect[ "vfx_sunflare" ] = loadfx( "vfx/ambient/atmospheric/vfx_sunflare" );
	level._effect[ "mp_ls_trash_wide_runner" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_trash_wide_runner" );
	level._effect[ "mp_ls_trash_runner" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_trash_runner" );
	level._effect[ "mp_ls_blowtrash_runner" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_blowtrash_runner" );
	level._effect[ "vfx_sand_large_gust_runner" ] = loadfx( "vfx/ambient/weather/sand/vfx_sand_large_gust_runner" );
	level._effect[ "vfx_fire_wood_ls" ] = loadfx( "vfx/ambient/fire/wall/vfx_fire_wood_ls" );
	level._effect[ "vfx_fire_ground_sov" ] = loadfx( "vfx/ambient/fire/wall/vfx_fire_ground_sov" );
	level._effect[ "vfx_dust_crack_runner" ] = loadfx( "vfx/ambient/dust/vfx_dust_crack_runner" );
	//level._effect[ "ground_dust_flat_mp" ] = loadfx( "vfx/ambient/dust/ground_dust_flat_mp" );
	level._effect[ "mp_ls_godray_taper" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_godray_taper" );
	level._effect[ "mp_ls_godray_quad" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_godray_quad" );
	level._effect[ "vfx_steam_small_up" ] = loadfx( "vfx/ambient/steam/vfx_steam_small_up" );
	level._effect[ "mp_ls_ng_vista_falling" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_ng_vista_falling" );
	//level._effect[ "mp_ls_dustspiral" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_dustspiral" );
	level._effect[ "mp_ls_vista_dust" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_vista_dust" );
    level._effect[ "mp_ls_dust_fall" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_dust_fall" );
	level._effect[ "hanging_dust_outdoor_mp" ]			= loadfx( "vfx/ambient/dust/hanging_dust_outdoor_mp" );
	level._effect[ "mp_pb_burntsmoke" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_burntsmoke" );
	level._effect[ "mp_pb_godray_thin" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_godray_thin" );
	level._effect[ "mp_pb_godray_single" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_godray_single" );	
	level._effect[ "mp_pb_godraylarge" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_godraylarge" );
	level._effect[ "mp_pb_lowfog_dustmotes" ]			= loadfx( "fx/maps/mp_lonestar/mp_ls_dustmotes" );
	level._effect[ "leaves_fall_gentlewind_green_100_mp" ]			= loadfx( "fx/misc/leaves_fall_gentlewind_green_100_mp" );	
	level._effect[ "insects_carcass_flies_dark" ]			= loadfx( "fx/misc/insects_carcass_flies_dark" );
    level._effect[ "mp_ls_ng_bricks_falling" ] = loadfx( "fx/maps/mp_lonestar/mp_ls_ng_bricks_falling" );
	level._effect[ "vfx_ls_leaves_falling" ] = loadfx( "vfx/ambient/atmospheric/vfx_ls_leaves_falling" );

	
	
	
	
/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_lonestar_fx::main();
#/

}
