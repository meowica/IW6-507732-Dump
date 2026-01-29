#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#include maps\_utility;
#using_animtree( "vehicles" );

main( model, type, classname, norumble )
{
	if ( model == "vehicle_submarine_sdv" || model == "vehicle_mini_sub_iw6" )
		build_template( "submarine_sdv", model, type, classname );
	else
		build_template( "blackshadow_730", model, type, classname );
	build_localinit( ::init_local );
	build_deathmodel( model );
	build_life( 999, 500, 1500 );

	if  ( model == "vehicle_mini_sub_iw6" )
	{
		build_unload_groups( ::unload_groups );
		build_aianims( ::setanims, ::set_vehicle_anims );
	}

	if (!isDefined(norumble) || !norumble)
	{
		if (model == "vehicle_mini_sub_iw6")
			build_rumble( "subtle_tank_rumble", 0.05, 1.5, 900, 1, 1 );
		//else
		//	build_rumble( "stryker_rumble", 0.005, 1.0, 400, 0.3, 0.1 );
	}
	build_team( "allies" );
	
	level._effect[ "sdv_prop_wash_1" ]	 					= loadfx( "fx/water/sdv_prop_wash_2" );
	level._effect[ "mini_sub_prop_wash" ]					= loadfx( "vfx/moments/ship_graveyard/mini_sub_propeller_bubbles" );
	level._effect[ "sdv_headlights" ]	 					= loadfx( "fx/misc/spotlight_submarine_sdv" );
	
}

init_local()
{
	self ent_flag_init( "moving" );
	self ent_flag_init( "lights" );
	
	self.light_tag = self spawn_tag_origin();
	self.light_tag linkTo( self, "TAG_BIG_LIGHT1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	if  ( self.model == "vehicle_mini_sub_iw6" )
		self.moving_unload = true;
	
	self thread cleanup_sdv();
	self thread handle_move();
	self thread handle_lights();
}

handle_move()
{
	//for engine exhaust, sounds, etc.
	self endon("sdv_done");
	self endon("death");

	while (true)
	{	
		/*-----------------------
		SDV STARTS MOVING
		-------------------------*/	
		self ent_flag_wait( "moving" );
		self thread play_sound_on_tag( "sdv_start", "TAG_PROPELLER" );
		self delaythread( 1,::play_loop_sound_on_tag, "sdv_move_loop", "TAG_PROPELLER", true );
		
		/*-----------------------
		SDV PROP WASH FX
		-------------------------*/	
		if ( self.model == "vehicle_mini_sub_iw6" )
			self thread mini_sub_prop_wash();
		else
			playfxontag( getfx( "sdv_prop_wash_1" ), self, "TAG_PROPELLER" );
		
	
		/*-----------------------
		SDV STOPPING
		-------------------------*/	
		self ent_flag_waitopen( "moving" );
		if ( self.model == "vehicle_mini_sub_iw6" )
			self thread mini_sub_prop_wash_stop();
		else
			stopfxontag( getfx( "sdv_prop_wash_1" ), self, "TAG_PROPELLER" );
		self notify( "stop sound" + "sdv_move_loop" );
		self thread play_sound_on_tag( "sdv_stop", "TAG_PROPELLER" );
	}
}

mini_sub_prop_wash()
{
	playfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propellerbottom" );
	waitframe();
	playfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller1_le" );
	playfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller1_ri" );
	waitframe();
//	playfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller2_le" );
//	playfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller2_ri" );
}

mini_sub_prop_wash_stop()
{
	stopfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propellerbottom" );
	waitframe();
	stopfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller1_le" );
	stopfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller1_ri" );
	waitframe();
//	stopfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller2_le" );
//	stopfxontag( getfx( "mini_sub_prop_wash" ), self, "j_propeller2_ri" );
}

cleanup_sdv()
{
	self waittill_either("sdv_done", "death");
	stopfxontag( getfx( "sdv_headlights" ), self.light_tag, "TAG_ORIGIN" );
	
	if ( isdefined( self ) && self ent_flag("moving") )
	{
		stopfxontag( getfx( "sdv_prop_wash_1" ), self, "TAG_PROPELLER" );
		self notify( "stop sound" + "sdv_move_loop" );
	}
	deleteme = self.light_tag;
	wait( 0.2 );
	deleteme delete();
}

handle_lights()
{
	//for the sdv headlights
	self endon("sdv_done");
	self endon("death");

	while (true)
	{	
		self ent_flag_wait( "lights" );
		playfxontag( getfx( "sdv_headlights" ), self.light_tag, "TAG_ORIGIN" );
		
		self ent_flag_waitopen( "lights" );
		stopfxontag( getfx( "sdv_headlights" ), self.light_tag, "TAG_ORIGIN" );
	}
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = SpawnStruct();

	positions[ 0 ].idle = %minisub_enemy_idle_R_01;
	positions[ 1 ].idle = %minisub_enemy_idle_R_02;
	positions[ 2 ].idle = %minisub_enemy_idle_R_03;
	positions[ 3 ].idle = %minisub_enemy_idle_L_01;
	positions[ 4 ].idle = %minisub_enemy_idle_L_02;
	positions[ 5 ].idle = %minisub_enemy_idle_L_03;

	positions[ 0 ].sittag = "tag_guy1";
	positions[ 1 ].sittag = "tag_guy2";
	positions[ 2 ].sittag = "tag_guy3";
	positions[ 3 ].sittag = "tag_guy6";
	positions[ 4 ].sittag = "tag_guy5";
	positions[ 5 ].sittag = "tag_guy4";

	positions[ 0 ].getout = %minisub_enemy_dismount_R_01;
	positions[ 1 ].getout = %minisub_enemy_dismount_R_02;
	positions[ 2 ].getout = %minisub_enemy_dismount_R_03;
	positions[ 3 ].getout = %minisub_enemy_dismount_L_01;
	positions[ 4 ].getout = %minisub_enemy_dismount_L_02;
	positions[ 5 ].getout = %minisub_enemy_dismount_L_03;

	positions[ 0 ].getoutstance = "stand";
	positions[ 1 ].getoutstance = "stand";	
	positions[ 2 ].getoutstance = "stand";
	positions[ 3 ].getoutstance = "stand";
	positions[ 4 ].getoutstance = "stand";
	positions[ 5 ].getoutstance = "stand";
	
	return positions;
}

set_vehicle_anims( positions )
{
	return positions;
}

unload_groups()
{
	unload_groups[ "left"		] = [];
	unload_groups[ "right"		] = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "default"	] = [];

	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 0;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 1;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 2;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 3;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 4;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 5;
	
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 0;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 1;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 2;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 3;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 4;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 5;
	
	unload_groups[ "default" ] = unload_groups[ "passengers" ];

	return unload_groups;
}

/*QUAKED script_vehicle_submarine_sdv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_submarine_sdv::main( "vehicle_submarine_sdv", undefined, "script_vehicle_submarine_sdv" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_submarine_sdv_submarine_sdv
sound,vehicle_submarine_sdv,vehicle_standard,all_sp


defaultmdl="vehicle_submarine_sdv"
default:"vehicletype" "submarine_sdv"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_submarine_minisub (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_submarine_sdv::main( "vehicle_mini_sub_iw6", undefined, "script_vehicle_submarine_minisub" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_submarine_sdv_submarine_sdv
sound,vehicle_submarine_sdv,vehicle_standard,all_sp
xmodel,vehicle_mini_sub_iw6

defaultmdl="vehicle_mini_sub_iw6"
default:"vehicletype" "submarine_sdv"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_blackshadow (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_submarine_sdv::main( "vehicle_blackshadow_730", undefined, "script_vehicle_blackshadow" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_blackshadow
sound,vehicle_submarine_sdv,vehicle_standard,all_sp


defaultmdl="vehicle_blackshadow_730"
default:"vehicletype" "blackshadow_730"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_blackshadow_player (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_submarine_sdv::main( "vehicle_blackshadow_730_viewmodel", undefined, "script_vehicle_blackshadow_player" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_blackshadow
sound,vehicle_submarine_sdv,vehicle_standard,all_sp


defaultmdl="vehicle_blackshadow_730_viewmodel"
default:"vehicletype" "blackshadow_730"
default:"script_team" "allies"
*/
