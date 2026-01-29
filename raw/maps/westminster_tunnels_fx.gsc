#include common_scripts\utility;
#include maps\_utility;

main()
{
	thread precacheFX();
}

precacheFX()
{

	if ( getdvarint( "sm_enable" ) && getdvar( "r_zfeather" ) != "0" )
		level._effect[ "spotlight_truck_player" ]						 = loadfx( "fx/misc/london_player_truck_spotlight" );
	else
		level._effect[ "spotlight_truck_player" ]						 = loadfx( "fx/misc/london_player_truck_spotlight_cheap" );
		
	if ( getdvarint( "sm_enable" ) && getdvar( "r_zfeather" ) != "0" )
		level._effect[ "spotlight_train" ]						 = loadfx( "fx/misc/train_spot_light" );
	else
		level._effect[ "spotlight_train" ]						 = loadfx( "fx/misc/train_spot_light_cheap" );
		
		
    level._effect[ "spotlight_train_cheap" ]						 = loadfx( "fx/misc/docks_heli_spotlight_model_cheap" );
    level._effect[ "spotlight_truck_player_cheap" ] = loadfx( "fx/misc/london_player_truck_spotlight_cheap" );

    level._effect[ "sparks_subway_scrape_line" ] = loadfx( "fx/misc/sparks_subway_scrape_line" );
    level._effect[ "sparks_subway_scrape_line_short" ] = loadfx( "fx/misc/sparks_subway_scrape_line_short" );


    level._effect[ "spotlight_train_cheap" ]						 = loadfx( "fx/misc/docks_heli_spotlight_model_cheap" );

    level._effect[ "copypaper_box_exp" ]						 = loadfx( "fx/props/copypaper_box_exp" );
    
    level._effect[ "vehicle_scrape_sparks" ]			= loadfx( "fx/misc/vehicle_scrape_sparks" );
    
    level._effect[ "subway_cart_guy_damage" ] 				 = loadfx( "fx/impacts/flesh_hit_head_fatal_exit_exaggerated" );
}

