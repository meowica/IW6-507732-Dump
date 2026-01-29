#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	build_template( "hind_battle", model, type, classname );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_battle_hind" );

	// this doesn't happen very much but it's a nicer cleaner format than the case statement.
	hind_death_fx = [];
	hind_death_fx[ "vehicle_battle_hind" ] = "fx/explosions/helicopter_explosion_hind_chernobyl";
	hind_death_fx[ "vehicle_battle_hind_no_lod" ] = "fx/explosions/helicopter_explosion_hind_chernobyl";

	hind_aerial_death_fx = [];
	hind_aerial_death_fx[ "vehicle_battle_hind" ] = "fx/explosions/aerial_explosion_hind_chernobyl";
	hind_aerial_death_fx[ "vehicle_battle_hind_no_lod" ] = "fx/explosions/aerial_explosion_hind_chernobyl";

	build_drive( %battle_hind_spinning_rotor, undefined, 0 ); //battle_hind_spinning_rotor

	deathfx = hind_death_fx[ model ];
			   //   effect 							    tag 			    sound 						     bEffectLooping    delay      bSoundlooping    waitDelay    stayontag    notifyString 			 
	build_deathfx( "fx/explosions/grenadeexp_default", "tag_engine_left" , "hind_helicopter_hit"		  , undefined		, undefined, undefined		, 0.2		 , true		  , undefined );
	build_deathfx( "fx/explosions/grenadeexp_default", "tail_rotor_jnt"	 , "hind_helicopter_secondary_exp", undefined		, undefined, undefined		, 0.5		 , true		  , undefined );
	build_deathfx( "fx/fire/fire_smoke_trail_L"		 , "tail_rotor_jnt"	 , "hind_helicopter_dying_loop"	  , true			, 0.05	   , true			, 0.5		 , true		  , undefined );
	build_deathfx( "fx/explosions/aerial_explosion"	 , "tag_engine_right", "hind_helicopter_secondary_exp", undefined		, undefined, undefined		, 2.5		 , true		  , undefined );
	build_deathfx( "fx/explosions/aerial_explosion"	 , "tag_deathfx"	 , "hind_helicopter_secondary_exp", undefined		, undefined, undefined		, 4.0		 , undefined  , undefined );
	build_deathfx( deathfx							 , undefined		 , "hind_helicopter_crash"		  , undefined		, undefined, undefined		, - 1		 , undefined  , "stop_crash_loop_sound" );

	build_rocket_deathfx( hind_aerial_death_fx[ model ], 	"tag_deathfx", 	"hind_helicopter_crash",			undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );

	build_treadfx( classname, "default", "fx/treadfx/heli_dust_default", false );

	build_life( 999, 500, 1500 );

	build_team( "axis" );

	build_aianims( ::setanims, ::set_vehicle_anims );

	randomStartDelay = RandomFloatRange( 0, 1 );

			 //   classname    name 				     tag 				    effect 								    group 	    delay 			 
	build_light( classname	, "cockpit_blue_cargo01"  , "tag_light_cargo01"	 , "fx/misc/aircraft_light_cockpit_red"	 , "interior", 0.0 );
	build_light( classname	, "cockpit_blue_cockpit01", "tag_light_cockpit01", "fx/misc/aircraft_light_cockpit_blue" , "interior", 0.1 );
	build_light( classname	, "white_blink"			  , "tag_light_belly"	 , "fx/misc/aircraft_light_white_blink"	 , "running" , randomStartDelay );
	build_light( classname	, "white_blink_tail"	  , "tag_light_tail"	 , "fx/misc/aircraft_light_red_blink"	 , "running" , randomStartDelay );
	build_light( classname	, "wingtip_green"		  , "tag_light_L_wing"	 , "fx/misc/aircraft_light_wingtip_green", "running" , randomStartDelay );
	build_light( classname	, "wingtip_red"			  , "tag_light_R_wing"	 , "fx/misc/aircraft_light_wingtip_red"	 , "running" , randomStartDelay );
	build_light( classname	, "spot"				  , "tag_passenger"		 , "fx/misc/aircraft_light_hindspot"	 , "spot"	 , 0.0 );

	build_bulletshield( true );
	build_is_helicopter();

}

init_local()
{
	self.script_badplace = false;// All helicopters dont need to create bad places
	maps\_vehicle::vehicle_lights_on( "running" );
}

set_vehicle_anims( positions )
{

}

#using_animtree( "generic_human" );

setanims()
{

}

/*QUAKED script_vehicle_hind_battle (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\hind::main( "vehicle_battle_hind", "hind_battle", "script_vehicle_hind_battle" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_hind_battle
sound,vehicle_hind,vehicle_standard,all_sp


defaultmdl="vehicle_battle_hind"
default:"vehicletype" "hind_battle"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_battle_hind_no_lod (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\hind::main( "vehicle_battle_hind_no_lod", "hind_battle", "script_vehicle_battle_hind_no_lod" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_battle_hind_no_lod
sound,vehicle_hind,vehicle_standard,all_sp


defaultmdl="vehicle_battle_hind_no_lod"
default:"vehicletype" "hind_battle"
default:"script_team" "axis"
*/
