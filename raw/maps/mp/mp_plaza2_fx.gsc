main()
{
	//level._effect[ "test_effect" ]										 = loadfx( "fx/misc/moth_runner" );
/#
    if ( getdvar( "clientSideEffects", "1" ) != "1" )
        maps\createfx\mp_plaza2_fx::main();
#/

//ambient fx
	level._effect[ "floating_room_dust" ]								      = loadfx( "fx/misc/floating_room_dust" ); 
	level._effect[ "falling_dirt_frequent_runner" ] 					= loadfx( "fx/dust/falling_dirt_frequent_runner" );
  level._effect[ "dust_wind_slow_paper" ]								    = loadfx( "fx/dust/dust_wind_slow_paper" );
	level._effect[ "trash_spiral_runner" ]								    = loadfx( "fx/misc/trash_spiral_runner" );
  level._effect[ "room_dust_200_blend_mp_vacant" ]					= loadfx( "fx/dust/room_dust_200_blend_mp_vacant" );	
  level._effect[ "insects_carcass_flies" ] 		      				= loadfx( "fx/misc/insects_carcass_flies" );	
	level._effect[ "spark_fall_runner_mp" ] 		              = loadfx( "fx/explosions/spark_fall_runner_mp" );
  level._effect[ "embers_prague_light" ]								            = loadfx( "fx/weather/embers_prague_light" );
  level._effect[ "thin_black_smoke_s_fast" ] 		                    = loadfx( "fx/smoke/thin_black_smoke_s_fast" );
	level._effect[ "falling_dirt_frequent_runner" ]                   = loadfx( "fx/dust/falling_dirt_frequent_runner" );
  level._effect[ "building_hole_smoke_mp" ] 		                    = loadfx( "fx/smoke/building_hole_smoke_mp" );
  level._effect[ "car_fire_mp" ] 		                                = loadfx( "fx/fire/car_fire_mp" );
	level._effect[ "firelp_small_cheap_mp" ] 		              		    = loadfx( "fx/fire/firelp_small_cheap_mp" );
	level._effect[ "falling_ash_mp" ] 		            				        = loadfx( "fx/misc/falling_ash_mp" );	
  level._effect[ "insects_light_hunted_a_mp" ] 		                  = loadfx( "fx/misc/insects_light_hunted_a_mp" );
	level._effect[ "bootleg_alley_steam" ] 		                        = loadfx( "fx/smoke/bootleg_alley_steam" );
	level._effect[ "building_hole_paper_fall_mp" ] 		      				  = loadfx( "fx/misc/building_hole_paper_fall_mp" );
	level._effect[ "ground_fog_mp" ] 		      				                = loadfx( "fx/weather/ground_fog_mp" );
  level._effect[ "oil_drip_puddle" ]								                = loadfx( "fx/misc/oil_drip_puddle" );
	level._effect[ "antiair_runner_cloudy" ]								          = loadfx( "fx/misc/antiair_runner_cloudy" );
	level._effect[ "leaves_spiral_runner" ]								            = loadfx( "fx/misc/leaves_spiral_runner" );
	level._effect[ "fire_falling_runner_point" ] 		                  = loadfx( "fx/fire/fire_falling_runner_point" );
	level._effect[ "ceiling_smoke_seatown" ]													= loadfx( "fx/weather/ceiling_smoke_seatown" );	
	level._effect[ "large_battle_smoke_mp" ] 		                      = loadfx( "fx/smoke/large_battle_smoke_mp" );
	level._effect[ "light_glow_white" ] 		      				            = loadfx( "fx/misc/light_glow_white" );	
	level._effect[ "building_hole_embers_mp" ] 		                    = loadfx( "fx/fire/building_hole_embers_mp" );	
  level._effect[ "room_dust_200_z150_mp" ]							            = loadfx( "fx/dust/room_dust_200_z150_mp" );	
	level._effect[ "building_hole_elec_short_runner" ] 		            = loadfx( "fx/explosions/building_hole_elec_short_runner" );
	level._effect[ "thick_black_smoke_mp" ] 		                      = loadfx( "fx/smoke/thick_black_smoke_mp" );	
	level._effect[ "leaves_fall_gentlewind_green" ]								    = loadfx( "fx/misc/leaves_fall_gentlewind_green" );
	level._effect[ "smoke_plume_grey_02" ] 		                        = loadfx( "fx/smoke/smoke_plume_grey_02" );	
	level._effect[ "burned_vehicle_sparks" ] 		              		    = loadfx( "fx/fire/burned_vehicle_sparks" );	

}
