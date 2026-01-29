#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	build_template( "nh90", model, type, classname );
	build_localinit( ::init_local );

	build_drive( %bh_rotors, undefined, 0 );

	death_fx						  = [];
	death_fx[ "vehicle_nh90"		] = "fx/explosions/helicopter_explosion";
	death_fx[ "vehicle_nh90_no_lod" ] = "fx/explosions/helicopter_explosion";
	death_fx[ "vehicle_nh90_cheap"		] = "fx/explosions/helicopter_explosion";
	deathmodelfx					  = death_fx[ model ];
	
			   //   effect 											      tag 			      sound 							    bEffectLooping    delay      bSoundlooping    waitDelay    stayontag    notifyString 		    
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", "tag_engine_left" , "blackhawk_helicopter_hit"			 , undefined	   , undefined, undefined	   , 0.2		, true		 , undefined );
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", "tag_body"		   , "blackhawk_helicopter_secondary_exp", undefined	   , undefined, undefined	   , 0.5		, true		 , undefined );
	build_deathfx( "fx/fire/fire_smoke_trail_L"						   , "tag_body"		   , "blackhawk_helicopter_dying_loop"	 , true			   , 0.05	  , true		   , 0.5		, true		 , undefined );
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", "tag_engine_right", "blackhawk_helicopter_secondary_exp", undefined	   , undefined, undefined	   , 2.5		, true		 , undefined );
	build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", "tag_deathfx"	   , "blackhawk_helicopter_secondary_exp", undefined	   , undefined, undefined	   , 4.0		, undefined	 , undefined );
	build_deathfx( deathmodelfx										   , undefined		   , "blackhawk_helicopter_crash"		 , undefined	   , undefined, undefined	   , - 1		, undefined	 , "stop_crash_loop_sound" );
	
	build_rocket_deathfx( "fx/explosions/aerial_explosion_heli_large", 	"tag_deathfx", 	undefined, undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0 );
	
	build_treadfx( classname, "default", "vfx/moments/flood/rooftop1_heli_dust_kickup", false );
	
	build_mainturret( );

	build_life( 999, 500, 1500 );

	build_team( "axis" );

	build_aianims( ::setanims, ::set_vehicle_anims );

	build_attach_models( ::set_attached_models );

	build_unload_groups( ::Unload_Groups );
	
	turret = "minigun_littlebird_spinnup";

	randomStartDelay = RandomFloatRange( 0, 1 );

			 //   model      name 					   tag 				      effect 							   group 	   delay 		    
	build_light( classname, "cockpit_blue_cargo01"	, "tag_light_cargo01"  , "fx/misc/aircraft_light_cockpit_red"	, "interior", 0.0 );
	build_light( classname, "cockpit_blue_cockpit01", "tag_light_cockpit01", "fx/misc/aircraft_light_cockpit_blue" , "interior", 0.1 );
	build_light( classname, "white_blink"			, "tag_light_belly"	   , "fx/misc/aircraft_light_white_blink"	, "running" , randomStartDelay );
	build_light( classname, "white_blink_tail"		, "tag_light_tail"	   , "fx/misc/aircraft_light_red_blink"	, "running" , randomStartDelay );
	build_light( classname, "wingtip_green"			, "tag_light_L_wing"   , "fx/misc/aircraft_light_wingtip_green", "running" , randomStartDelay );
	build_light( classname, "wingtip_red"			, "tag_light_R_wing"   , "fx/misc/aircraft_light_wingtip_red"	, "running" , randomStartDelay );
	build_light( classname, "spot"					, "tag_passenger"	   , "fx/misc/aircraft_light_hindspot"		, "spot"	, 0.0 );
	
	build_is_helicopter();

}

init_local()
{
	self.fastropeoffset = 744 + Distance( self GetTagOrigin( "tag_origin" ), self GetTagOrigin( "tag_ground" ) );
	self.script_badplace = false;// All helicopters dont need to create bad places
	maps\_vehicle::vehicle_lights_on( "running" );
}

set_vehicle_anims( positions )
{
//	positions[ 0 ].vehicle_getinanim = %tigertank_hatch_open;

	for ( i = 0;i < positions.size;i++ )
		positions[ i ].vehicle_getoutanim = %bh_idle;

	return positions;
}

#using_animtree( "fastrope" );

setplayer_anims( positions )
{
	positions[ 3 ].player_idle = %bh_player_idle;

	positions[ 3 ].player_getout = %bh_player_drop;
	positions[ 3 ].player_animtree = #animtree;

	return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 9;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].idle[ 0 ] = %helicopter_pilot1_idle;
	positions[ 0 ].idle[ 1 ] = %helicopter_pilot1_twitch_clickpannel;
	positions[ 0 ].idle[ 2 ] = %helicopter_pilot1_twitch_lookback;
	positions[ 0 ].idle[ 3 ] = %helicopter_pilot1_twitch_lookoutside;
	positions[ 0 ].idleoccurrence[ 0 ] = 500;
	positions[ 0 ].idleoccurrence[ 1 ] = 100;
	positions[ 0 ].idleoccurrence[ 2 ] = 100;
	positions[ 0 ].idleoccurrence[ 3 ] = 100;

	positions[ 1 ].idle[ 0 ] = %helicopter_pilot2_idle;
	positions[ 1 ].idle[ 1 ] = %helicopter_pilot2_twitch_clickpannel;
	positions[ 1 ].idle[ 2 ] = %helicopter_pilot2_twitch_lookoutside;
	positions[ 1 ].idle[ 3 ] = %helicopter_pilot2_twitch_radio;
	positions[ 1 ].idleoccurrence[ 0 ] = 450;
	positions[ 1 ].idleoccurrence[ 1 ] = 100;
	positions[ 1 ].idleoccurrence[ 2 ] = 100;
	positions[ 1 ].idleoccurrence[ 3 ] = 100;

	positions[ 0 ].bHasGunWhileRiding = false;
	positions[ 1 ].bHasGunWhileRiding = false;


	// 1, 2, 4, 5, 8,  6
	positions[ 2 ].idle = %bh_1_idle;
	positions[ 3 ].idle = %bh_2_idle;
	positions[ 4 ].idle = %bh_4_idle;
	positions[ 5 ].idle = %bh_5_idle;
	positions[ 6 ].idle = %bh_8_idle;
	positions[ 7 ].idle = %bh_6_idle;
	positions[ 8 ].idle = %bh_7_idle;


	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_detach_r";
	positions[ 3 ].sittag = "tag_detach_r";
	positions[ 4 ].sittag = "tag_detach_l";
	positions[ 5 ].sittag = "tag_detach_l";
	positions[ 6 ].sittag = "tag_detach_l";
	positions[ 7 ].sittag = "tag_detach_l";
	positions[ 8 ].sittag = "tag_detach_r";

	// 1, 2, 4, 5, 8,  6
	positions[ 2 ].getout = %bh_1_drop;
	positions[ 3 ].getout = %bh_2_drop;
	positions[ 4 ].getout = %bh_4_drop;
	positions[ 5 ].getout = %bh_5_drop;
	positions[ 6 ].getout = %bh_8_drop;
	positions[ 7 ].getout = %bh_6_drop;
	positions[ 8 ].getout = %bh_7_drop;

	// Changing from the default of "crouch", since the NH90 fastrope is currently only used in Factory.
	positions[ 2 ].getoutstance = "stand";
	positions[ 3 ].getoutstance = "stand";
	positions[ 4 ].getoutstance = "stand";
	positions[ 5 ].getoutstance = "stand";
	positions[ 6 ].getoutstance = "stand";
	positions[ 7 ].getoutstance = "stand";
	positions[ 8 ].getoutstance = "stand";


	positions[ 2 ].ragdoll_getout_death = true;
	positions[ 3 ].ragdoll_getout_death = true;
	positions[ 4 ].ragdoll_getout_death = true;
	positions[ 5 ].ragdoll_getout_death = true;
	positions[ 6 ].ragdoll_getout_death = true;
	positions[ 7 ].ragdoll_getout_death = true;
	positions[ 8 ].ragdoll_getout_death = true;

	positions[ 2 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 3 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 4 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 5 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 6 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 7 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 8 ].ragdoll_fall_anim = %fastrope_fall;
	
	positions[ 1 ].rappel_kill_achievement = 1;
	positions[ 2 ].rappel_kill_achievement = 1;
	positions[ 3 ].rappel_kill_achievement = 1;
	positions[ 4 ].rappel_kill_achievement = 1;
	positions[ 5 ].rappel_kill_achievement = 1;
	positions[ 6 ].rappel_kill_achievement = 1;
	positions[ 7 ].rappel_kill_achievement = 1;
	positions[ 8 ].rappel_kill_achievement = 1;


	// 1, 2, 4, 5, 6, & 8


	positions[ 2 ].fastroperig = "TAG_FastRope_RI";// 1
	positions[ 3 ].fastroperig = "TAG_FastRope_RI";	// 2
	positions[ 4 ].fastroperig = "TAG_FastRope_LE";	// 4
	positions[ 5 ].fastroperig = "TAG_FastRope_LE";	// 5
	positions[ 6 ].fastroperig = "TAG_FastRope_RI";// 8
	positions[ 7 ].fastroperig = "TAG_FastRope_LE";// 6
	positions[ 8 ].fastroperig = "TAG_FastRope_RI";// 7
	return setplayer_anims( positions );
}



//WIP.. posible to unload different sets of people wirh vehicle notify( "unload", set ); sets defined here.
unload_groups()
{
	unload_groups = [];
	unload_groups[ "left" ] = [];
	unload_groups[ "right" ] = [];
	unload_groups[ "both" ] = [];

	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 4;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 5;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 7;

	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 2;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 3;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 6;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 8;

	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 2;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 3;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 4;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 5;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 6;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 7;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 8;

	unload_groups[ "default" ] = unload_groups[ "both" ];

	return unload_groups;

}


set_attached_models()
{
	array = [];
	array[ "TAG_FastRope_LE" ] = spawnstruct();
	array[ "TAG_FastRope_LE" ].model = "rope_test";
	array[ "TAG_FastRope_LE" ].tag = "TAG_FastRope_LE";
	array[ "TAG_FastRope_LE" ].idleanim = %bh_rope_idle_le;
	array[ "TAG_FastRope_LE" ].dropanim = %bh_rope_drop_le;

	array[ "TAG_FastRope_RI" ] = spawnstruct();
	array[ "TAG_FastRope_RI" ].model = "rope_test_ri";
	array[ "TAG_FastRope_RI" ].tag = "TAG_FastRope_RI";
	array[ "TAG_FastRope_RI" ].idleanim = %bh_rope_idle_ri;
	array[ "TAG_FastRope_RI" ].dropanim = %bh_rope_drop_ri;

	strings = getarraykeys( array );

	for ( i = 0;i < strings.size;i++ )
	{
		precachemodel( array[ strings[ i ] ].model );
	}

	return array;
}



/*QUAKED script_vehicle_nh90 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\nh90::main( "vehicle_nh90", undefined, "script_vehicle_nh90" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_nh90
sound,vehicle_blackhawk,vehicle_standard,all_sp


defaultmdl="vehicle_nh90"
default:"vehicletype" "nh90"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_nh90_no_lod (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\nh90::main( "vehicle_nh90_no_lod", undefined, "script_vehicle_nh90_no_lod" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_nh90_no_lod
sound,vehicle_blackhawk,vehicle_standard,all_sp


defaultmdl="vehicle_nh90_no_lod"
default:"vehicletype" "nh90"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_nh90_cheap (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\nh90::main( "vehicle_nh90_cheap", undefined, "script_vehicle_nh90_cheap" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_nh90_no_lod
sound,vehicle_blackhawk,vehicle_standard,all_sp


defaultmdl="vehicle_nh90_cheap"
default:"vehicletype" "nh90"
default:"script_team" "axis"
*/
