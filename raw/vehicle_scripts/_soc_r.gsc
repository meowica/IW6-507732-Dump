#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

/*
BONE 0 -1 "TAG_ORIGIN"
BONE 1 0 "body_animate_JNT"
BONE 2 0 "TAG_BODY"
BONE 3 1 "TAG_DRIVER"
BONE 4 1 "TAG_GUY_BACK"
BONE 5 1 "TAG_GUY_FRONT_LEFT"
BONE 6 1 "TAG_GUY_FRONT_RIGHT"
BONE 7 1 "TAG_GUY_MIDDLE_LEFT"
BONE 8 1 "TAG_GUY_MIDDLE_RIGHT"
BONE 9 1 "TAG_PROPELLER_LEFT"
BONE 10 1 "TAG_PROPELLER_RIGHT"
BONE 11 1 "TAG_SPLASH_BACK"
BONE 12 1 "TAG_SPLASH_FRONT"
BONE 13 1 "TAG_TURRET_BACK"
BONE 14 1 "TAG_TURRET_FRONT_LEFT"
BONE 15 1 "TAG_TURRET_FRONT_RIGHT"
BONE 16 1 "TAG_TURRET_MIDDLE_LEFT"
BONE 17 1 "TAG_TURRET_MIDDLE_RIGHT"
*/

main( model, type, classname )
{
	//not doing build_turret, so manually precaching
	PreCacheModel( "vehicle_seal_boat_turret"); 
	PreCacheTurret( "minigun_hummer" );
	
	build_template( "soc_r", model, type, classname );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_localinit( ::init_local );//builds turrets based on a kvp
	build_deathmodel( "vehicle_zodiac" );
	//build_turret( "minigun_hummer", "TAG_TURRET_BACK", "vehicle_seal_boat_turret", undefined, undefined, undefined, undefined, undefined, (0,0,-30) );
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_unload_groups( ::Unload_Groups );
}

init_local()
{
	build_turrets();	
}

build_turrets()
{
	if(!IsDefined( self.script_parameters ) )
		return;
	
	array_params = StrTok( self.script_parameters, " " );
	tag = undefined;

	pos = 1;
	foreach( i, param in array_params )
	{
		switch ( param )
		{
			case "back":
				tag = "TAG_TURRET_BACK";
				break;
			
			case "front_left":
				tag = "TAG_TURRET_FRONT_LEFT";
				break;
				
			case "front_right":
				tag = "TAG_TURRET_FRONT_RIGHT";
				break;
				
			case "middle_left":
				tag = "TAG_TURRET_MIDDLE_LEFT";
				break;
				
			case "middle_right":
				tag = "TAG_TURRET_MIDDLE_RIGHT";
				break;					
		}
		
		boat_mginit( "minigun_hummer", tag, "vehicle_seal_boat_turret" );							
	}	
	
	//re-config the array so the sitting positions match the index of this array. This way _vehicle_aianim::guy_man_turret() puts him on the right turret
	self.mgturret = maps\_utility::array_index_by_script_index( self.mgturret  );
}

boat_mginit( weapon_type, tag, model )
{
	//taken from _vehicle_code::mginit() which normally handles this stuff
	classname = self.classname;

	mgangle = 0;
	if ( IsDefined( self.script_mg_angle ) )
		mgangle = self.script_mg_angle;

	if( !isdefined( self.mgturret ) )
	{
		self.mgturret = [];
	}
	

	turret = SpawnTurret( "misc_turret", ( 0, 0, 0 ), weapon_type );

	turret LinkTo( self, tag, ( 0, 0, 0 ), ( 0, -1 * mgangle, 0 ) );
		
	turret SetModel( model );
	turret.angles	= self.angles;
	turret.isvehicleattached = true;// lets mgturret know not to mess with this turret
	turret.ownerVehicle		 = self;
	Assert( IsDefined( self.script_team ) );
	turret.script_team = self.script_team;// lets mgturret know not to mess with this turret
	turret thread maps\_mgturret::burst_fire_unmanned();
	turret MakeUnusable();
	maps\_vehicle_code::set_turret_team( turret );
	
	if ( IsDefined( self.script_fireondrones ) )
		turret.script_fireondrones = self.script_fireondrones;

	self.mgturret = common_scripts\utility::array_add( self.mgturret, turret );
	
	//doing this so I can re organize the array so the sit pos matches the the array index. This way _vehicle_aianim::guy_man_turret() puts him on the right turret
	turret.script_index  = get_position_from_tag( tag );		

	if ( !IsDefined( self.script_turretmg ) )
		self.script_turretmg = true;

	if ( self.script_turretmg == 0 )
		self thread maps\_vehicle_code::_mgoff();
	else
	{
		self.script_turretmg = 1;
		self thread maps\_vehicle_code::_mgon();
	}
}

set_vehicle_anims( positions )
{
	return positions;
}

#using_animtree( "generic_human" );

/*BONE 3 1 "TAG_DRIVER"
BONE 4 1 "TAG_GUY_BACK"
BONE 5 1 "TAG_GUY_FRONT_LEFT"
BONE 6 1 "TAG_GUY_FRONT_RIGHT"
BONE 7 1 "TAG_GUY_MIDDLE_LEFT"
BONE 8 1 "TAG_GUY_MIDDLE_RIGHT"*/

setanims()
{
	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "TAG_DRIVER";
	positions[ 1 ].sittag = "TAG_GUY_FRONT_LEFT";
	positions[ 2 ].sittag = "TAG_GUY_FRONT_RIGHT";
	positions[ 3 ].sittag = "TAG_GUY_MIDDLE_LEFT";
	positions[ 4 ].sittag = "TAG_GUY_MIDDLE_RIGHT";
	positions[ 5 ].sittag = "TAG_GUY_BACK";
	
	//this puts AI on the turrets when the vehicle is loaded	
	positions[ 0 ].bHasGunWhileRiding = false;
	positions[ 1 ].mgturret = 1;
	positions[ 2 ].mgturret = 2;
	positions[ 3 ].mgturret = 3;
	positions[ 4 ].mgturret = 4;
	positions[ 5 ].mgturret = 5;

	positions[ 0 ].idle = %heat_stand_aim_5;
	positions[ 1 ].idle = %oilrig_civ_escape_2_seal_A;
	positions[ 2 ].idle = %oilrig_civ_escape_3_A;
	positions[ 3 ].idle = %oilrig_civ_escape_4_A;
	positions[ 4 ].idle = %oilrig_civ_escape_5_A;
	positions[ 5 ].idle = %oilrig_civ_escape_6_A;

	positions[ 0 ].getout = %pickup_driver_climb_out;
	positions[ 1 ].getout = %pickup_driver_climb_out;
	positions[ 2 ].getout = %pickup_passenger_climb_out;
	positions[ 3 ].getout = %pickup_passenger_climb_out;
	positions[ 4 ].getout = %pickup_passenger_climb_out;
	positions[ 5 ].getout = %pickup_passenger_climb_out;

	return positions;
}


get_position_from_tag( tag )
{
	switch ( tag )
	{
		case "TAG_TURRET_FRONT_LEFT":
			return 1;
			
		case "TAG_TURRET_FRONT_RIGHT":
			return 2;
			
		case "TAG_TURRET_MIDDLE_LEFT":
			return 3;
			
		case "TAG_TURRET_MIDDLE_RIGHT":
			return 4;
						
		case "TAG_TURRET_BACK":
			return 5;	
	}	
	
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "all" ] = [];

	group = "passengers";
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;

	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}


/*QUAKED script_vehicle_soc_r (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_soc_r::main( "vehicle_soc_r", undefined, "script_vehicle_soc_r" );
=-=-=-=-=-
TURRET INFO:

For each desired turret add one of these values to ONE script_parameters key/value pair in radiant:

back
front_left
front_right
middle_left
middle_right

For example if you want a back and front-left turret, the kvp in radiant would be:

script_paremeters
back front_left

=-=-=-=-=-
These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_soc_r
sound,vehicle_soc_r,vehicle_standard,all_sp

defaultmdl="vehicle_seal_boat"
default:"vehicletype" "soc_r"
default:"script_team" "allies"
*/


