#include common_scripts\utility;
#include maps\mp\_utility;
main()
{
	level._effect[ "snow_tree_impact" ] = loadfx( "fx/explosions/snow_tree_impact" );
	level._effect[ "snow_sattelite_impact" ] 		= loadfx( "fx/explosions/snow_sattelite_impact" );
	level._effect[ "insects_carcass_runner" ] 		= loadfx( "fx/misc/insects_carcass_runner" );
	level._effect[ "snow_spiral_updraft_runner" ] 	= loadfx( "vfx/ambient/weather/snow/snow_spiral_updraft_runner" );
	level._effect[ "snow_door_runner" ] 			= loadfx( "fx/snow/snow_door_runner" );
	level._effect[ "snow_window_runner" ] 			= loadfx( "fx/snow/snow_window_runner" );
	level._effect[ "vfx_fire_server_sov" ] 			= loadfx( "vfx/ambient/fire/electrical/vfx_fire_server_sov" );
	level._effect[ "drips_slow_10x10" ] 			= loadfx( "fx/misc/drips_slow_10x10" );
	level._effect[ "vfx_smk_smallfire" ] 			= loadfx( "vfx/ambient/smoke/vfx_smk_smallfire" );
	level._effect[ "vfx_firelight" ] 				= loadfx( "vfx/ambient/fire/vfx_firelight" );
	level._effect[ "vfx_tree_fire_stump" ] 			= loadfx( "vfx/ambient/fire/wood/vfx_tree_fire_stump" );
	level._effect[ "heat_vent_mp_snow" ] 			= loadfx( "vfx/ambient/misc/heat_vent_mp_snow" );
	level._effect[ "mp_snow_lighthouse" ] 			= loadfx( "vfx/moments/mp_snow/mp_snow_lighthouse" );
	level._effect[ "vfx_fog_water_mp" ] 			= loadfx( "vfx/ambient/atmospheric/vfx_fog_water_mp" );
	level._effect[ "chimney_smoke_mp_snow" ] 		= loadfx( "fx/smoke/chimney_smoke_mp_snow" );
	level._effect[ "vfx_bulb_prismatic_mp_snow" ] 	= loadfx( "vfx/ambient/lights/vfx_bulb_prismatic_mp_snow" );
	level._effect[ "vfx_int_haze_mp_snow" ] 		= loadfx( "vfx/ambient/atmospheric/vfx_int_haze_mp_snow" );
	level._effect[ "vfx_falling_dirt_cave_runner" ] = loadfx( "vfx/moments/mp_snow/vfx_falling_dirt_cave_runner" );
	level._effect[ "water_splashes_runner" ] 		= loadfx( "vfx/moments/mp_snow/water_splashes_runner" );
	level._effect[ "vfx_ground_embers_mp" ] 		= loadfx( "vfx/moments/mp_snow/vfx_ground_embers_mp" );
	level._effect[ "vfx_orange_flare_mp" ] 			= loadfx( "vfx/moments/mp_snow/vfx_orange_flare_mp" );
	level._effect[ "vfx_lighthouse_flare" ] 		= loadfx( "vfx/ambient/lights/vfx_lighthouse_flare" );
	level._effect[ "snow_spray_oriented_short" ] 	= loadfx( "fx/snow/snow_spray_oriented_short" );
	level._effect[ "vfx_tree_fire_base" ] 			= loadfx( "vfx/ambient/fire/wood/vfx_tree_fire_base" );
	level._effect[ "drips_slow" ] 					= loadfx( "fx/misc/drips_slow" );
	level._effect[ "vfx_snow_trail_falling_thin" ] 	= loadfx( "vfx/ambient/weather/snow/vfx_snow_trail_falling_thin" );
	level._effect[ "snow_falling_tree_mp" ] 		= loadfx( "fx/snow/snow_falling_tree_mp" );
	level._effect[ "vfx_dust_motes_int_snow" ] 		= loadfx( "vfx/ambient/dust/vfx_dust_motes_int_snow" );
	level._effect[ "vfx_fireplace" ] 				= loadfx( "vfx/ambient/fire/vfx_fireplace" );
	level._effect[ "snow_light_mp" ] 				= loadfx( "fx/snow/snow_light_mp" );
	level._effect[ "satellite_fall" ] 				= loadfx( "vfx/moments/mp_snow/satellite_fall_parent" );
	 
/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_snow_fx::main();
#/
}


