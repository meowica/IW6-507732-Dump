#include maps\_utility;
#include maps\_anim;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#include maps\_vehicle_code;
#include common_scripts\utility;
#using_animtree( "vehicles" );

CONST_BP_HEIGHT		= 300;

init_silenthawk_landing()
{
	if ( IsDefined( level.little_bird_landing_init ) )
		return;
	level.little_bird_landing_init = true;
	thread init_silenthawk_landing_thread();
}

init_silenthawk_landing_thread()
{
	waittillframeend; // let structs init 
			  //   entities 														     process 							 
	array_thread( getstructarray( "gag_stage_silenthawk_unload", "script_noteworthy" ), ::setup_gag_stage_silenthawk_unload );
	array_thread( getstructarray( "gag_stage_silenthawk_load", "script_noteworthy" )  , ::setup_gag_stage_silenthawk_load );
}

silenthawk_landing()
{
	self endon ( "death" );
	
	self ent_flag_init( "prep_unload" );
	self ent_flag_wait( "prep_unload" );
	
	self turn_unloading_drones_to_ai();

	landing_node = self get_landing_node();
	landing_node silenthawk_lands_and_unloads( self );
	self vehicle_paths( landing_node );
}

stage_guy( guy, side, otherguy, stag_objected )
{
	scene	   = "stage_silenthawk_" + side;
	array	   = [];
	array[ 0 ] = guy;

	stag_objected anim_generic_reach( array[ 0 ], scene, "tag_detach_" + side );
	stag_objected anim_generic(	array[ 0 ], scene, "tag_detach_" + side ); //anim_generic
	
	ent_flag_set( "staged_guy_" + side );

	guy SetGoalPos( drop_to_ground( guy.origin ) );
	guy.goalradius = 16;

	ent_flag_wait( "guy2_in_" + side );
	
	thread maps\_vehicle_aianim::load_ai( [ guy ], undefined, side );

	//ent_flag_wait( "loaded" );
	//ent_flag_set( "all_aboard" );
}

// feel free to tear this apart once you have a real context
setup_gag_stage_silenthawk_unload()
{
	Assert( IsDefined( self.targetname ) );
	Assert( IsDefined( self.angles ) );

	while ( 1 )
	{
		self waittill( "trigger", vehicle );
		silenthawk_lands_and_unloads( vehicle );
	}
}

setup_gag_stage_silenthawk_load()
{
	Assert( IsDefined( self.targetname ) );
	Assert( IsDefined( self.angles ) );
	while ( 1 )
	{
		self waittill( "trigger", vehicle );

		vehicle SetDeceleration( 6 );
		vehicle SetAcceleration( 4 );
		vehicle SetTargetYaw( self.angles[ 1 ] );
		vehicle Vehicle_SetSpeed( 20, 7, 7 );

		while ( Distance( flat_origin( vehicle.origin ), flat_origin( self.origin ) ) > 256 )
			wait 0.05;

		vehicle endon( "death" );
		vehicle thread vehicle_land_beneath_node( 220, self );

		vehicle waittill( "near_goal" );

		vehicle Vehicle_SetSpeed( 20, 22, 7 );
		vehicle thread vehicle_land_beneath_node( 16, self );
		vehicle waittill( "near_goal" );

		vehicle waittill_stable();
		vehicle notify( "touch_down", self );
		vehicle Vehicle_SetSpeed( 20, 8, 7 );
	}
}

silenthawk_lands_and_unloads( vehicle )
{
	vehicle SetDeceleration( 6 );
	vehicle SetAcceleration( 4 );
	AssertEx( IsDefined( self.angles ), "Landing nodes must have angles set." );
	vehicle SetTargetYaw( self.angles[ 1 ] );

	vehicle Vehicle_SetSpeed( 20, 7, 7 );

	while ( Distance( flat_origin( vehicle.origin ), flat_origin( self.origin ) ) > 512 )
		wait 0.05;

	vehicle endon( "death" );

	badplace_name = "landing" + RandomInt( 99999 );
	BadPlace_Cylinder( badplace_name, 30, self.origin, 200, CONST_BP_HEIGHT, "axis", "allies", "neutral", "team3" );
	

	vehicle thread vehicle_land_beneath_node( 424, self );

	vehicle waittill( "near_goal" );
	
	BadPlace_Delete( badplace_name );
	BadPlace_Cylinder( badplace_name, 30, self.origin, 200, CONST_BP_HEIGHT, "axis", "allies", "neutral", "team3" );

	vehicle notify( "groupedanimevent", "pre_unload" );
	vehicle thread maps\_vehicle_aianim::animate_guys( "pre_unload" );

	vehicle Vehicle_SetSpeed( 20, 22, 7 );
	vehicle notify( "nearing_landing" );

	if ( IsDefined( vehicle.custom_landing ) )
	{
		switch( vehicle.custom_landing )
		{
			case "hover_then_land":
				vehicle Vehicle_SetSpeed( 10, 22, 7 );
				vehicle thread vehicle_land_beneath_node( 32, self, 64 );
				vehicle waittill( "near_goal" );
				vehicle notify( "hovering" );
				wait( 1 );
				break;
				
			default:
				AssertMsg( "Unsupported vehicle.custom_landing" );
				break;
		}
	}


	vehicle thread vehicle_land_beneath_node( 16, self );
	vehicle waittill( "near_goal" );
	BadPlace_Delete( badplace_name );
	//BadPlace_Cylinder( badplace_name, 6, self.origin, 200, CONST_bp_height, "axis", "allies", "neutral", "team3" );

	self script_delay();

	vehicle vehicle_unload();
	vehicle waittill_stable();
	vehicle Vehicle_SetSpeed( 20, 8, 7 );
	wait 0.2;
	vehicle notify( "stable_for_unlink" );
	wait 0.2;

	if ( IsDefined( self.script_flag_set ) )
	{
		flag_set( self.script_flag_set );
	}

	if ( IsDefined( self.script_flag_wait ) )
	{
		flag_wait( self.script_flag_wait );
	}

	vehicle notify( "silenthawk_liftoff" );
}

/*
=============
///ScriptDocBegin
"Name: set_stage( <pickup_node_before_stage>, <guys>, <side> )"
"Summary: Used for getting setting up AI around the landing area of a silenthawk with benches"
"Module: Vehicles"
"MandatoryArg: <pickup_node_before_stage>: A script_origin or struct on a helicopter path that is right before the linked stage prefab"
"MandatoryArg: <guys>: group of 3 AI that will load on either the right or left side"
"MandatoryArg: <side>: " Left" or "right" side bench of silenthawk"
"Example: silenthawk_wingman set_stage( pickup_node_before_stage, aRoof_riders_left, "left" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_stage( pickup_node_before_stage, guys, side )
{
	if ( !ent_flag_exist( "staged_guy_" + side ) )
		ent_flag_init( "staged_guy_" + side );
	else
		ent_flag_clear( "staged_guy_" + side );

	if ( !ent_flag_exist( "guy2_in_" + side ) )
		ent_flag_init( "guy2_in_" + side );
	else
		ent_flag_clear( "guy2_in_" + side );

	//if ( ! ent_flag_exist( "all_aboard" ) )
		//ent_flag_init( "all_aboard" );
	//else
		//ent_flag_clear( "all_aboard" );
	
	nodes = get_stage_nodes( pickup_node_before_stage, side );
	Assert( nodes.size );
	heli_node  = getstruct( pickup_node_before_stage.target, "targetname" );
	stage_heli = Spawn( "script_model", ( 0, 0, 0 ) );
	stage_heli SetModel( self.model );
	
	//sholmes 4.2011: drop to ground is not working with this model..
	//so I'm manually setting the origin of stage_heli. 
	//This fixed a nasty issue with the anims popping into the sky relative to the (not dropped) model.
	if ( IsDefined( self.new_stage_heli_spawn ) )
	{
		stage_heli.origin = self.origin;
	}
	else
	{
		stage_heli.origin = drop_to_ground( heli_node.origin ) + ( 0, 0, self.originheightoffset );
	}	
	
	stage_heli.angles = heli_node.angles;
	stage_heli Hide();

	hop_on_guy1				= undefined;
	patting_back_second_guy = undefined;
	stage_guy				= undefined;


	foreach ( node in nodes )
	{
		guy = undefined;
		
		//check to see if there is already a guy destined for this node with .script_startingposition
		foreach ( rider in guys )
		{
			if ( ( IsDefined( rider.script_startingposition ) ) && ( rider.script_startingposition == node.script_startingposition ) )
			{
				guy = rider;
				break;
			}
		}
		
		if ( !IsDefined( guy ) )
		{
			guy = getClosest( node.origin, guys );
		}
		
		Assert( IsDefined( guy ) );

		//used to associate this node with a position
		Assert( IsDefined( node.script_startingposition ) );
		guy.script_startingposition = node.script_startingposition;

		if ( guy.script_startingposition == 2 || guy.script_startingposition == 5 )
		{
				hop_on_guy1 = guy;			
				guy maps\_spawner::go_to_node_set_goal_node( node );
		}
		else if ( guy.script_startingposition == 3 || guy.script_startingposition == 6 )
		{
			 stage_guy = guy;
		}
		else if ( guy.script_startingposition == 4 || guy.script_startingposition == 7 )
		{
			patting_back_second_guy = guy;
			guy maps\_spawner::go_to_node_set_goal_node( node );
		}

		guys = array_remove( guys, guy );
	}

	Assert( IsDefined( hop_on_guy1 ) );
	Assert( IsDefined( patting_back_second_guy ) );
	Assert( IsDefined( stage_guy ) );

	self thread stage_guy( stage_guy, side, patting_back_second_guy, stage_heli );
	self thread delete_on_death( stage_heli );

}

get_stage_nodes( pickup_node_before_stage, side )
{
	Assert( IsDefined( pickup_node_before_stage.target ) );
	targeted_nodes	 = GetNodeArray( pickup_node_before_stage.target, "targetname" );
	stage_side_nodes = [];
	foreach ( node in targeted_nodes )
	{
		Assert( IsDefined( node.script_noteworthy ) );
		if ( node.script_noteworthy == "stage_" + side )
			stage_side_nodes[ stage_side_nodes.size ] = node;
	}
	return stage_side_nodes;
}

get_landing_node()
{
	node = self.currentnode;
	for ( ;; )
	{
		nextnode = getent_or_struct( node.target, "targetname" );
		AssertEx( IsDefined( nextnode ), "Was looking for landing node with script_unload but ran out of nodes to look through." );
		if ( IsDefined( nextnode.script_unload ) )
			return nextnode;
		node = nextnode;
	}
}

/*
=============
///ScriptDocBegin
"Name: load_side( <side>, <riders> )"
"Summary: Used for loading AI onto a silenthawk with benches"
"Module: Vehicles"
"MandatoryArg: <riders>: group of 3 AI that will load on either the right or left side"
"MandatoryArg: <side>: " Left" or "right" side bench of silenthawk"
"Example: silenthawk_wingman_02 thread load_side( "left", aRoof_riders_left );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
load_side( side, riders )
{

	hop_on_guy1				= undefined;
	patting_back_second_guy = undefined;
	stage_guy				= undefined;
	foreach ( rider in riders )
	{
		Assert( IsDefined( rider.script_startingposition ) );
		if ( rider.script_startingposition == 2 || rider.script_startingposition == 5 )
			hop_on_guy1 = rider;
		else if ( rider.script_startingposition == 3 || rider.script_startingposition == 6 )
			 stage_guy = rider;
		else if ( rider.script_startingposition == 4 || rider.script_startingposition == 7 )
			patting_back_second_guy = rider;
	}
	Assert( IsDefined( hop_on_guy1 ) );
	Assert( IsDefined( patting_back_second_guy ) );
	Assert( IsDefined( stage_guy ) );

	ent_flag_wait( "staged_guy_" + side );

	thread vehicle_load_ai_single( hop_on_guy1, undefined, side );
	//waittill he's just starting to play out his animation before sending the other guys to get in the way.
	hop_on_guy1 waittill( "boarding_vehicle" );
	// send the third guy off to jump in
	thread vehicle_load_ai_single( patting_back_second_guy, undefined, side );
	patting_back_second_guy waittill( "boarding_vehicle" );
	ent_flag_set( "guy2_in_" + side );
}

vehicle_land_beneath_node( neargoal, node, height )
{
	if ( !IsDefined( height ) )
		height = 0;
	
	self notify( "newpath" );
	if ( ! IsDefined( neargoal ) )
		neargoal = 2;
	self SetNearGoalNotifyDist( neargoal );
	self SetHoverParams( 0, 0, 0 );
	self ClearGoalYaw();
	self SetTargetYaw( flat_angle( node.angles )[ 1 ] );
	
	self _setvehgoalpos_wrap( groundpos( node.origin ) + ( 0, 0, height ), 1 );
	self waittill( "goal" );
}
