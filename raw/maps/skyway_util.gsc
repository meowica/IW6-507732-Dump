#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

SCRIPT_NAME = "skyway_util.gsc";
STOP_TRAIN_WITH_ADS = false;

//*******************************************************************
//																	*
//		TRAIN SCRITPS												*
//*******************************************************************

//**************************************************************
//		Train Data Structure Reference
//**************************************************************
/*
 * 		Train
 * 		  + cars[]		// array of train cars
 * 			- anim_models	// body models set up for animation (has a targetanme and _anim in script_parameters)
 * 			- body			// animated skeleton of the traincar (hidden)
 * 			- body_ext[]	// additional external body models (stuff that can be seen from outside)
 * 			- body_int[]	// additional internal body models (stuff inside the train)
 * 			- ref_end		// reference ent that moves with train
 * 			- ref_start		// reference ent that doesn't move
 * 			- sus_b			// rear suspension
 * 			- sus_f			// front suspension
 * 			- trigs[]		// array of every trigger on the car
 * 			- other_linked_parts[] // array of all the other linked parts not accounted for above
 * 			- other_linked_parts_count // a count of all "other linked parts" for debugging purposes
 * 		  + note		// string notify sent to level -- starts new train path anim
 * 		  + path		// currently playing path anim
 * 			- anim_org		// animation reference ent
 * 			- anime			// animation name
 * 			- end			// reference ent for the start of the next anim
 * 			- start			// reference ent for the world space start of this anim
 * 		  + path_array[]// array of upcoming path data structures
 *		  + other_linked_parts_count // a count of all "other linked parts" from each car for debugging purposes
 */

//**************************************************************
//		Train Setup Scripts
//**************************************************************
train_build( train_array, new_anim_notify )
{
	// init train
	new_train = SpawnStruct();
	new_train ent_flag_init( "train_teleporting" );
	new_train.cars = [];
	
	// create anim vars
	new_train.note		 = new_anim_notify;
	new_train.path_array = [];
	
	// build train cars
	foreach ( note in train_array )
	{
		// init car & get parts
		parts	  = GetEntArray( note, "script_noteworthy" );
		car		  = SpawnStruct();
		car.body_ext = [];
		car.body_int = [];
		car.anim_models = [];
		car.trigs = [];
		
		// build traincar and suspension
		foreach ( part in parts )
		{
			// check for traincar and suspension
			if ( !IsDefined( part.script_parameters ) )
				continue;
			
			// Bool to keep important parts out of "other_linked_parts" array
			part._essential_part = true;
			
			// init traincar and suspension
			if ( part.script_parameters == "body" )
			{
				// setup animated part
				part assign_animtree( note + "_body" );
				part Hide();
				
				car.body				  = part;
				car.anim_models[ "body" ] = part;
				
			}
			else if ( IsSubStr( part.script_parameters, "body_ext" ) && IsDefined( part.targetname ) )
			{
				// setup animated part
				if ( IsSubStr( part.script_parameters, "anim" ) )
				{
					part assign_animtree( note + part.targetname );
					car.anim_models[ part.targetname ] = part;
				}
				
				car.body_ext[ part.targetname ] = part;
			}
			else if ( IsSubStr( part.script_parameters, "body_int" ) && IsDefined( part.targetname ) )
			{
				// setup animated part
				if ( IsSubStr( part.script_parameters, "anim" ) )
				{
					part assign_animtree( note + part.targetname );
					car.anim_models[ part.targetname ] = part;
				}
				
				car.body_int[ part.targetname ] = part;	
				part._essential_part = undefined;				
			}
			else if ( part.script_parameters == "sus_f" )
			{
				// setup animated part
				part assign_animtree( note + "_sus_f" );
				
				car.sus_f = part;
				car.body_ext[ "sus_f" ] = part;
			}
			else if ( part.script_parameters == "sus_b" )
			{
				// setup animated part
				part assign_animtree( note + "_sus_b" );
				
				car.sus_b = part;
				car.body_ext[ "sus_b" ] = part;
			}
			else if( part.script_parameters == "body_ext" )
				car.body_ext[ car.body_ext.size ] = part;
			else if( part.script_parameters == "body_int" )
				car.body_int[ car.body_int.size ] = part;
			else if ( part.script_parameters == "sus_f_link" )
				car.sus_fl = part;
			else if ( part.script_parameters == "sus_b_link" )
				car.sus_bl = part;
			else
				part._essential_part = undefined;
		}
		
		// find and link suspension collision
		if ( IsDefined( car.sus_fl ) )
			car.sus_fl LinkTo( car.sus_f );
		if ( IsDefined( car.sus_bl ) )
			car.sus_bl LinkTo( car.sus_b );
			
		// create reference orgs for spawn teleporting
		car.ref_start		 = spawn_tag_origin();
		car.ref_start.origin = car.body GetTagOrigin( "j_spineupper" );
		car.ref_start.angles = car.body GetTagAngles( "j_spineupper" );
		
		car.ref_end = spawn_tag_origin();
		car.ref_end LinkTo( car.body, "j_spineupper", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		
		// remove body from parts array... it shouldn't get linked to itself
		parts = array_remove( parts, car.body );
		
		// Keep track of linked parts
		car.other_linked_parts = [];
		car.other_linked_parts_count = 0;
		
		// link traincar linkers
		foreach ( part in parts )
		{
			// skip already linked and dont_link parts
			if ( part IsLinked() || ( IsDefined( part.script_parameters ) && IsSubStr( part.script_parameters, "dont_link" ) ) )
				continue;
			
			//**********************************************************
			//		Aditional Saves & Setup
			
			// check and save triggers
			if ( IsSubStr( part.classname, "trigger_" ) )
			{
				part EnableLinkTo();
				car.trigs[ car.trigs.size ] = part;
			}
			
			// setup spawners and add teleport spawn function
			if ( IsSubStr( part.classname, "actor_" ) )
			{
				// Setup spawners and train teleport
				part.car	   = car;
				part add_spawn_function( ::teleport_ai_instant );
				
				// spawners cannot link
				continue;
			}
			
			//**********************************************************
			//		Linking
			
			// skip unlinkable stuff (at least some of this needs to be made linkable)
			if ( IsSubStr( part.classname, "script_vehicle_" ) )
				continue;
			
			// make link-able
			if ( IsSubStr( part.classname, "_volume" ) )
				part EnableLinkTo();
			
			part LinkTo( car.body, "j_spineupper" );
			
			// Keep track of linked parts
			if( !IsDefined( part._essential_part ) )
			{
				if( !IsDefined( car.other_linked_parts[ part.classname ] ))
					car.other_linked_parts[ part.classname ] = [];				
				car.other_linked_parts[ part.classname ] = array_add( car.other_linked_parts[ part.classname ], part );
				car.other_linked_parts_count++;
			}
		}
		
		// cleanup traincar build
		car.sus_fl = undefined;
		car.sus_bl = undefined;
		
		// add traincar to train
		new_train.cars[ note ] = car;
	}
	
	// Count all non-essential linked parts for each car
	new_train.other_linked_parts_count = 0;
	foreach( car in new_train.cars )
		new_train.other_linked_parts_count += car.other_linked_parts_count;
	
	// Will stop the train if the player presses ADS button
	/#
	if( STOP_TRAIN_WITH_ADS )
		thread debug_stop_train();
	#/
	
	return new_train;
}

/#
debug_stop_train()
{
	while( 1 )
	{
		if( level.player ADSButtonPressed() )
		{
			foreach( car in level._train.cars )
				car.body StopAnimScripted();
			return;
		}
		wait( 0.05 );
	}
}
#/

//**************************************************************
//		Train Pathing Scripts
//**************************************************************

// queue any number of path anims with the same start/end node
// the first will queue with an opt_action, play_now, and force_anim_relative (the rest will queue with default actions)
train_queue_path_anims( new_anims, start_node, end_node, opt_action, play_now, force_anim_relative )
{
	self train_queue_path_anim( new_anims[ 0 ], start_node, end_node, opt_action, play_now, force_anim_relative );
	
	for ( i = 1; i < new_anims.size; i++ )
		self thread train_queue_path_anim( new_anims[ i ], start_node, end_node );
}
	
train_queue_path_anim( new_anim, start_node, end_node, opt_action, play_now, force_anim_relative )
{
	// If previously looping, clear loop array var
	self.loop_array = undefined;
	
	// init passed vars
	if( !IsDefined( opt_action ) )
		opt_action = "none";
	
	// creat new anim struct
	path	   = SpawnStruct();
	path.anime = new_anim;
	path.start = getstruct( start_node, "targetname" );
	path.end   = getstruct( end_node, "targetname" );
	Assert( IsDefined( path.start ));
	Assert( IsDefined( path.end ));
	path.a_rel = force_anim_relative;
	
	// check for optional actions
	if ( opt_action == "none" )
		self.path_array[ self.path_array.size ] = path;
	else if ( opt_action == "next" )
		self.path_array = array_merge( [ path ], self.path_array );
	else if ( opt_action == "clear" )
		self.path_array = [ path ];
	
	// check for changes to end_org
	// a new end_org has been requested || a non-relative anim needs a new end_org because the next anim has changed
	if ( IsDefined( self.need_end_org ) || ( IsDefined( self.path ) && !isTrue( self.path.a_rel ) && ( opt_action == "next" || opt_action == "clear" ) ) )
	{
		self.path.end_org = path.start spawn_tag_origin();
		self.need_end_org = undefined;
	}
	
	// check for a play now request
	if ( isTrue( play_now ) )
		level notify( self.note );
}

train_queue_path_anim_loop( new_anims, start_node, end_node )
{
	loop_array = [];
	
	// Queue the anims like normal paths
	for( i = 0; i < new_anims.size; i++ )
	{
		if( i == 0 )
			self train_queue_path_anim( new_anims[ i ], start_node, end_node, undefined, undefined, true );
		else
			self train_queue_path_anim( new_anims[ i ], start_node, end_node );
		
		// Add looping path to loop array
		loop_array[ i ] = self.path_array[ self.path_array.size - 1 ];
	}
	
	// Set loop array container on train
	self.loop_array = loop_array;
}

train_path()
{
	self notify( "end_train_path" );
	self endon( "end_train_path" );
	
	// debug no_move
	if( IsDefined( level.debug_no_move ) && isTrue( level.debug_no_move ) )
		return;	
	
	// update path array
	self.path		= self.path_array[ 0 ];
	self.path_array = array_remove_index( self.path_array, 0 );
	
	// init path orgs
	self.path.anim_org = self.path.start spawn_tag_origin();
	
	// thread path anims
	foreach ( car in self.cars )
	{
		// start vignetted anims on train body and suspensions
		self.path.anim_org thread anim_single_solo( car.body, self.path.anime );
		car.sus_f thread anim_single_solo( car.sus_f, self.path.anime );
		car.sus_b thread anim_single_solo( car.sus_b, self.path.anime );
		
		// start layerd anims on the suspension wheels
		car.sus_f setanim( level.scr_anim[ car.sus_f.animname ][ "wheels" ] );
		car.sus_b setanim( level.scr_anim[ car.sus_b.animname ][ "wheels" ] );
		car thread train_wheel_anims();
	}
		
	// quick wait to throw out first frame notifications
	wait( 0.15 );
	
	while ( 1 )
	{
		// waittill a new anim is notified
		level waittill( self.note );
		
		// wait till train finishes teleport
		while( self ent_flag( "train_teleporting" ) )
			wait( 0.05 );
		
		// reset path vars
		self train_get_next_path();
		
		// thread path anims & teleport proc
		foreach ( car in self.cars )
		{
			// vignetted anims on train body and suspensions
			self.path.anim_org thread anim_single_solo( car.body, self.path.anime );
			car.sus_f thread anim_single_solo( car.sus_f, self.path.anime );
			car.sus_b thread anim_single_solo( car.sus_b, self.path.anime );
			
			// notify traincar layered anim loop
			car notify( "train_start_new_anims" );
		}
		//send out notify for overlay anims
		level notify( "notify_restart_overlay_anims" );
		
		self thread train_teleport();
		
		// quick wait to throw out first frame notifications
		level waittill_notify_or_timeout( self.note, 0.15 );
		
		// temp print
		IPrintLn( "New anim started: " + self.path.anime );
	}
}

train_get_next_path()
{
	self endon( "end_train_path" );
	
	// check for new anims
	if ( self.path_array.size < 1 )
	{
		if( IsDefined( self.loop_array ))
		{
			// We are looping, refresh the path
			self.path_array = self.loop_array;
		}
		else
		{
		        // cleanup path
		        self.need_end_org = undefined;
		        if( IsDefined( self.path.start_org ) )
			        self.path.start_org Delete();
		        if( IsDefined( self.path.end_org ) )
			        self.path.end_org Delete();
		
		        // end pathing
	         	self notify( "end_train_path" );
	     }	
	}	
	
	// reset path anim_org ( asuming non-relative animation )
	anim_org = self.path_array[ 0 ].start;
	
	// check if anim is forced relative || if it has different start points and isn't forced non-relative
	if ( isTrue( self.path_array[ 0 ].a_rel ) || ( self.path.start.origin != self.path_array[ 0 ].start.origin && !IsDefined( self.path_array[ 0 ].a_rel ) ) )
	{
		// reset path anim_org for a relative anim
		self.path_array[ 0 ].a_rel = true;
		anim_org				   = self.path.end;
	}
	
	// cleanup path
	self.path.anim_org Delete();
	if( IsDefined( self.path.start_org ) )
		self.path.start_org Delete();
	if( IsDefined( self.path.end_org ) )
		self.path.end_org Delete();
	
	// update path array
	self.path		= self.path_array[ 0 ];
	self.path_array = array_remove_index( self.path_array, 0 );
	
	// init path vars
	self.path.anim_org = anim_org spawn_tag_origin();
	
	// init path orgs, start and end for anims
	if ( isTrue( self.path.a_rel ) )
	{
		// teleport from the relative start of this anim to the actual start of this anim
		self.path.start_org = self.path.anim_org spawn_tag_origin();
		self.path.end_org	= self.path.start spawn_tag_origin();
	}
	else if( self.path_array.size > 0 )
	{
		// teleport from the end of this anim to the start of the next
		self.path.start_org = self.path.end spawn_tag_origin();
		self.path.end_org	= self.path_array[ 0 ].start spawn_tag_origin();
	}
	else
	{
		// teleport from the end of this anim to the start of the next anim once its queued
		self.path.start_org = self.path.end spawn_tag_origin();
		
		// set bool to create end_org once next anim is queued
		self.need_end_org = true;
	}
}


//call this on a traincar if its path animation changes, like when the suspensions break and you need a new suspension animation to override the current animation.
train_new_sus_path_anims( traincar, scenario )
{
	// debug no_move
	if ( IsDefined( level.debug_no_move ) && isTrue( level.debug_no_move ) )
		return;	
	
	//change the anims
	maps\skyway_anim::update_train_path_anims( scenario );
	
	// new vignetted anims on train body and suspensions
	//self.path.anim_org thread anim_single_solo( self.cars[ traincar ].body, self.path.anime );
	self.cars[ traincar ].sus_f thread anim_single_solo( self.cars[ traincar ].sus_f, self.path.anime );
	self.cars[ traincar ].sus_b thread anim_single_solo( self.cars[ traincar ].sus_b, self.path.anime );
	
	//get the anim time for the current path anim
	animtime = self.cars[ traincar ].body GetAnimTime( level.scr_anim[ self.cars[ traincar ].body.animname ][ self.path.anime ] );
	
	//self.cars[ traincar ].body SetAnimTime( level.scr_anim[ self.cars[ traincar ].body.animname ][ self.path.anime ], animtime );
	self.cars[ traincar ].sus_f SetAnimTime( level.scr_anim[ self.cars[ traincar ].sus_f.animname ][ self.path.anime ], animtime );
	self.cars[ traincar ].sus_b SetAnimTime( level.scr_anim[ self.cars[ traincar ].sus_b.animname ][ self.path.anime ], animtime );
	
	// notify traincar layered anim loop
	self.cars[ traincar ] notify( "train_start_new_anims" );
	level notify( "notify_restart_overlay_anims" );
	
	// temp print
	IPrintLn( "Path anim reinitialized(notify sent): " + self.path.anime );
}

//**************************************************************
//		Train Teleport Scripts
//**************************************************************
train_teleport()
{
	self notify( "end_train_teleport" );
	self endon( "end_train_teleport" );
	
	// wait for teleport
	self waittill( "train_teleport_ready" );
	self ent_flag_set( "train_teleporting" );
	
	// link each train body to its anim_org
	foreach ( car in self.cars )
	{
		// check for real train car
		if ( !IsDefined( car.body ) )
			continue;
		
		// mark for teleport
		car.body LinkTo( self.path.anim_org );
	}
	
	// wait for link
	wait( 0.05 );
	
	// do the teleport
	self.path.anim_org TeleportEntityRelative( self.path.start_org, self.path.end_org );
	TeleportScene();
	
	// unlink train from anim_org
	wait( 0.05 );
	foreach ( car in self.cars )
	{
		// check for real train car
		if ( !IsDefined( car.body ) )
			continue;
		
		// mark for teleport
		car.body Unlink();
	}
	
	// cleanup force relative anim for next animation
	if( self.path_array.size > 0 )
		self.path_array[0].a_rel = undefined;
	
	// teleport done
	self ent_flag_clear( "train_teleporting" );
	self notify( "train_teleporting_done" );
	IPrintLn( "Teleport train done" ); // TEMP TEMP
}

train_setup_teleport_triggers( player_train )
{
	// setup tele trigs for the player train
	trigs = GetEntArray( "player_train_trig_teleport", "script_noteworthy" );
	array_thread( trigs, ::train_tele_trig_proc, player_train );
}

train_tele_trig_proc( train )
{
	self endon( "death" );
	self endon( "stop_train_tele_trig" );
	level endon( "stop_train_tele_trigs" );
	
	while ( 1 )
	{
		// teleport train when player hits trigger
		self waittill( "trigger" );
		train notify( "train_teleport_ready" );
		
		// wait till train teleports to avoid multiple triggers
		while( train ent_flag( "train_teleporting" ) )
			wait( 0.05 );
	}
}

//**************************************************************
//		Train Anim Scripts
//**************************************************************

train_init_accessories_sway( accessories )
{
	i = 0;
	ents = [];
	foreach( accessory in accessories )
	{		
		// Rocket sway
		ent = GetEnt( accessory, "targetname" );
		if( !IsDefined( ent.animname ))
		{
			ent.animname = accessory;
			ent SetAnimTree();
		}
		ent setanim( level.scr_anim[ accessory ][ "sway" ] );

		ents[i] = ent;
		
		i ++;
	}
	
	return ents; 	
}

player_sway()
{
	level.player_default_sway_weight = 0.11;
	level.player_sway_weight = level.player_default_sway_weight;
	
	player_ground_ref_mover		   = spawn_anim_model( "player_rig" );
	player_ground_ref_mover.origin = level.player.origin;
	//player_ground_ref_node	   = spawn_tag_origin();
	
	//player_ground_ref.animname = "tag_origin";
	//player_ground_ref setanimtree();
	
	player_ground_ref		 = spawn_tag_origin();
	player_ground_ref.origin = player_ground_ref_mover GetTagOrigin( "tag_player" );
	player_ground_ref.angles = player_ground_ref_mover GetTagAngles( "tag_player" );
	
	player_ground_ref LinkTo( player_ground_ref_mover, "tag_player" );
	
	level.player PlayerSetGroundReferenceEnt( player_ground_ref );
	
	wait( 0.5 );
	
	while( 1 )
	{
		player_ground_ref_mover SetAnim( level.scr_anim[ "player_rig" ][ "player_sway_static" ]	 , level.player_sway_weight );
		player_ground_ref_mover SetAnim( level.scr_anim[ "player_rig" ][ "player_nosway_static" ], ( 1 - level.player_sway_weight ) );
		wait( level.TIMESTEP );
	}
}


player_sway_blendto( time, target_weight, target_frequency )
{
	level endon( "notify_change_player_sway" );
	
	if( time == 0 )
		time = 0.05;
	
	if( !IsDefined( target_weight ) )
		target_weight = level.player_default_sway_weight;
	
	weight = level.player_sway_weight;
	
	diff = ( target_weight - level.player_sway_weight );	
	diff_per_frame = diff * ( level.TIMESTEP/time  );
	
	while( time > 0 )
	{
		
		 weight += diff_per_frame;
		 
		 if( weight > 1 )
		 	weight = 1;
		 if( weight < 0  )
		 	weight = 0;
		 
		 level.player_sway_weight = weight;
		
		wait( level.timestep );
		time -= level.TIMESTEP;
	}
	
	level.player_sway_weight = target_weight;
	
	level notify( "notify_sway_blend_complete" );
}

player_sway_bump( time_in, hold_time, time_out, target_weight )
{

	level notify( "notify_change_player_sway" );
	level endon( "notify_change_player_sway" );
	
	thread player_sway_blendto( time_in, target_weight );
	level waittill( "notify_sway_blend_complete" );
	wait( hold_time );
	thread player_sway_blendto( time_out );
	
}

player_const_quake()
{
	
	level.player_quake_weight = 0.0001;
	
	while( 1 )
	{
		if( !flag( "flag_quake" ) && ( level.player_quake_weight > 0.001 ) )
			Earthquake( level.player_quake_weight, 0.1, level.player.origin, 5000 );
		wait( 0.05 );
	}
	
}

player_const_quake_blendto( target_weight, time )
{
	level notify( "notify_change_player_quake" );
	level endon( "notify_change_player_quake" );
	
	if( time == 0 )
		time = 0.05;
	
	if( !IsDefined( target_weight ) )
		target_weight = 0.0;
	
	if( target_weight <= 0 )
		target_weight = 0.0001;
	
	weight = level.player_sway_weight;
	
	diff = ( target_weight - level.player_sway_weight );	
	diff_per_frame = diff * ( level.TIMESTEP/time  );
	
	while( time > 0 )
	{
		
		 weight += diff_per_frame;
		 
		 if( weight > 1 )
		 	weight = 1;
		 if( weight < 0  )
		 	weight = 0;
		 
		 level.player_quake_weight = weight;
		
		wait( level.timestep );
		time -= level.TIMESTEP;
	}
	
	level.player_quake_weight = target_weight;

}

player_rumble()
{
	
	level.player_rumble_ent = get_rumble_ent();
	level.player_rumble_ent rumble_ramp_to( 0, 0.1 );

}

player_rumble_bump( mag_1, mag_2, time_in, hold_time, time_out )
{
	
	level.player_rumble_ent rumble_ramp_to( mag_1, time_in );
	wait( time_in + hold_time );
	level.player_rumble_ent rumble_ramp_to( mag_2, time_out );

}

//ahhh....the rythmic rumble of the moving train.  Set level.player_do_rythme_rumble to false to stop the rumbles
player_train_rythme_rumble_quake()
{
	level.player_do_rythme_rumble = true;
	
	while( 1 )
	{
		
		if( level.player_do_rythme_rumble == true )
		{
			Earthquake( 0.17, 0.2, level.player.origin, 5000  );
			level.player PlayRumbleOnEntity( "damage_light" );
		}
		
		wait( 0.1 );
		
		if( level.player_do_rythme_rumble == true )
		{
			Earthquake( 0.12, 0.2, level.player.origin, 5000  );
			level.player PlayRumbleOnEntity( "damage_light" );
		}
		
		wait( 0.8 );
		
	}

}

train_wheel_anims()
{
	self endon( "death" );
	self endon( "stop_wheel_anims" );
	
	while ( 1 )
	{
		self waittill( "train_start_new_anims" );

		// layerd anims on the suspension wheels
		wheeltime = self.sus_f GetAnimTime( level.scr_anim[ self.sus_f.animname ][ "wheels" ] );
		self.sus_f SetAnim( level.scr_anim[ self.sus_f.animname ][ "wheels" ] );
		self.sus_b SetAnim( level.scr_anim[ self.sus_b.animname ][ "wheels" ] );
			
		self.sus_f SetAnimTime( level.scr_anim[ self.sus_f.animname ][ "wheels" ], wheeltime );
		self.sus_b SetAnimTime( level.scr_anim[ self.sus_b.animname ][ "wheels" ], wheeltime );
	}
}



blend_link_over_time( blend_ent, org1, org2, time )
{
	
	whole_time = time;
	normalized_time = 1;
	
		
	while( time > 0 )
	{

		normalized_time = normalize_value( 0, whole_time, time );
		
		org = ( ( org1.origin * normalized_time ) + ( org2.origin * ( 1 - normalized_time)) );
		ang = ( ( org1.angles * normalized_time ) + ( org2.angles * ( 1 - normalized_time)) );
		
		blend_ent.origin = org; 
		blend_ent.angles = ang; 
			 
//		time = ( time - level.timestep );
		
		IPrintLn( "moveit!" );
		
		time = time - level.timestep;
		
		wait level.timestep;
	}
	
	blend_ent linkto( org2 );
	
}



vision_hit_transition( vision1, vision2, time_in, hold_time, time_out )
{
	level notify( "notify_vision_set_transition" );
	level endon( "notify_vision_set_transition" );
	
	vision_set_fog_changes( vision1, time_in );
	wait( hold_time );
	vision_set_fog_changes( vision2, time_out );
	
}


sun_hit_transition( intensity, time_in, hold_time, time_out )
{
	
	sun_color = GetMapSunLight();
	sun_color_bright = ( sun_color[0] * intensity, sun_color[1] * intensity, sun_color[2] * intensity );
	
	sun_light_fade( sun_color, sun_color_bright, time_in );
	wait( hold_time );
	sun_light_fade( sun_color_bright, sun_color, time_in );
	
}


train_overlay( anime, opt_action )
{
	
	foreach ( car in self.cars )
	{
		car thread train_overlay_solo( anime, opt_action );
	}
}


train_overlay_solo( anime, opt_action, looping )
{
	if( !isdefined( opt_action )  )
		opt_action = "nothing";
	if( !isdefined( looping ))
	   looping = false;

	if( opt_action == "waitforpreviousanim" )
		self waittill( "notify_train_overlay_complete" );
	else
		self notify( "notify_end_train_overlay" );
	
	self endon( "notify_end_train_overlay" );
	self endon( "notify_train_overlay_complete" );
	
	//IPrintLnBold( "hit!" );
	self.body SetAnimknobRestart( level.scr_anim[ self.body.animname ][ anime ] );
	self.sus_f SetAnimknobRestart( level.scr_anim[ self.sus_f.animname ][ anime ] );
	self.sus_b SetAnimknobRestart( level.scr_anim[ self.sus_b.animname ][ anime ] );
	
	if( !looping  ) //if not looping, kill the thread when anim is complete
		self thread notify_delay( "notify_train_overlay_complete", GetAnimLength( level.scr_anim[ self.body.animname ][ anime ] ) );
	
	while ( 1 )
	{
		level waittill( "notify_restart_overlay_anims" );

		self thread train_overlay_auto_restart( anime );
	}
}

train_overlay_auto_restart( anime )
{
		//self waittill( "train_start_new_anims" );

		// layerd anims on the suspension wheels
		animtime = self.body GetAnimTime( level.scr_anim[ self.body.animname ][ anime ] );
		self.body SetAnim( level.scr_anim[ self.body.animname ][ anime ], 1, 0 );
		self.sus_f SetAnim( level.scr_anim[ self.sus_f.animname ][ anime ], 1, 0 );
		self.sus_b SetAnim( level.scr_anim[ self.sus_b.animname ][ anime ], 1, 0 );
			
		self.body SetAnimTime( level.scr_anim[ self.body.animname ][ anime ], animtime );
		self.sus_f SetAnimTime( level.scr_anim[ self.sus_f.animname ][ anime ], animtime );
		self.sus_b SetAnimTime( level.scr_anim[ self.sus_b.animname ][ anime ], animtime );	
}

play_anim_and_idle( guy, anime_init, anime_idle, flag_no_idle, ender, tag )
{
	
	self anim_single_solo( guy, anime_init, tag, 0.2 );
	
	if ( !flag( flag_no_idle ) )
	{
		self anim_loop_solo( guy, anime_idle, ender, tag );
	}
}

//**************************************************************
//		test/proto Scripts
//**************************************************************

rooftop_jumpcheck( timeout, myFlag )
{
	level endon( "rooftop_jumpfail" );
	
	// tracking jump button until player is in jump zone
	jump_held = false;
	while( !flag( myFlag ) )
	{
		jump_held = level.player JumpButtonPressed();
		wait( 0.05 );
	}
	
	// delay timout thread
	delayThread( timeout, ::rooftop_jumpfail );
	
	// jumpcheck loop
	while( 1 )
	{
		if( level.player JumpButtonPressed() )
		{
			if( !jump_held && flag( myFlag ) )
				return;
			else if( !jump_held )
				jump_held = true;
		}
		else
			jump_held = false;
		
		wait( 0.05 );
	}
}

rooftop_jumpfail()
{
	//fall to your doom....eventually replaced with a death anim that gets spawned on the player origin.
	wait( 100 );
}

cleanup_roofjump_on_notify( player_rig )
{
		level waittill( "notify_player_end_vignette" );
		
		// re-set player
		level.player EnableWeapons();
		level.player EnableOffhandWeapons();
		level.player EnableWeaponSwitch();
		level.player AllowCrouch( true );
		level.player AllowProne( true );
		level.player ShowViewModel();
		level.player unlink();
		
		// cleanup
		player_rig delete();
}

train_quake( scale, duration, source, radius, time_delay )
{
	level notify( "train_quake" );
	
	// process radius for use on a train
	radius = max( duration * 3000, radius );
	
	self thread train_quake_proc( scale, duration, source, radius, time_delay );
}

train_quake_proc( scale, duration, source, radius, time_delay )
{
	level endon( "train_quake" );
	
	// check for delay
	if ( IsDefined( time_delay ) )
		wait( time_delay );
	
	// check if quake is greater than ambient quake
	if ( scale > level.player_quake_weight )
	{
		flag_set( "flag_quake" );
		Earthquake( scale, duration, source, radius );
		thread train_quake_tele_check( scale, duration, source, radius );
		
		// earthquake scales to 0... shortcut this by modifying duration via scale vs const scale
		mod = ( scale - level.player_quake_weight ) / scale;
		wait( duration * mod );
		flag_clear( "flag_quake" );
	}
	
	// clear tele thread
	level notify( "train_quake" );
}

train_quake_tele_check( scale, duration, source, radius )
{
	level endon( "train_quake" );
	
	// save duration
	my_duration = duration;
	
	// loop until teleport or timeout
	while ( duration > 0 )
	{
		// wait and capture whether notified or waited
		msg = level._train waittill_notify_or_timeout_return( "train_teleporting_done", 0.05 );
		
		// decrement duration
		my_duration -= 0.05;
		
		// if teleported - thread a new quake (which will auto-end this thread)
		if ( !IsDefined( msg ) || msg != "timeout" )
		{
			// compute new scale (assuming quake magnitude scales linearly) and thread a quake at the new location
			scale *= ( my_duration / duration );
			self thread train_quake( scale, my_duration, source, radius );
		}
	}
	
	
}

delay_multi_fx( time, ents, fx_on, fx_off, tag )
{
	// init vars
	if ( !IsArray( ents ) )
		ents = [ ents ];
	if ( !IsDefined( fx_on ) )
		fx_on = [];
	else if ( !IsArray( fx_on ) )
		fx_on = [ fx_on ];
	if ( !IsDefined( fx_off ) )
		fx_off = [];
	else if ( !IsArray( fx_off ) )
		fx_off = [ fx_off ];
	if( !IsDefined( tag ) )
		tag = "tag_origin";
	
	thread delay_multi_fx_proc( time, ents, fx_on, fx_off, tag );
}

delay_multi_fx_proc( time, ents, fx_on, fx_off, tag )
{	
	if ( time > 0 )
		wait( time );
	
	// play fx on ents
	foreach ( ent in ents )
	{
		foreach ( fx in fx_off )
			StopFXOnTag( getfx( fx ), ent, tag );
		
		foreach ( fx in fx_on )
			PlayFXOnTag( getfx( fx ), ent, tag );
	}
}

test_func_on_button()
{
	level endon( "stop_cody_debug" );
	
	press_number = 0;
	
	while( 1 )
	{
		
		if( level.player buttonpressed( "DPAD_DOWN" ) )
		{
			
//			maps\skyway_rooftops::Tele_jump__a3();
			IPrintLn( "test_request = " + press_number  );
			if( press_number == 0 )
			{
				level._train train_queue_path_anim( "bc_1", "anim_track_bc_start", "anim_track_bc_end", "clear", true, false );			
				level._train train_queue_path_anim( "bc_2", "anim_track_bc_start", "anim_track_bc_end" );	
				level._train train_queue_path_anim( "bc_3", "anim_track_bc_start", "anim_track_bc_end" );	
				level._train train_queue_path_anim( "loop_a1", "anim_track_loop_a_start", "anim_track_loop_a_end" );	
				level._train train_queue_path_anim( "loop_a2", "anim_track_loop_a_start", "anim_track_loop_a_end" );	
				level._train train_queue_path_anim_loop( [ "loop_a1", "loop_a2" ], "anim_track_loop_a_start", "anim_track_loop_a_end" );
				wait(  3 );
				vision_set_fog_changes( "skyway", 2 );
				press_number = 1;
				IPrintLn( "test pt1"  );
			}
			else if( press_number == 1 )
			{
				level notify( "notify_test_progress_1" );
				press_number = 2;
				IPrintLn( "test pt2"  );
			}
			else if( press_number == 2 )
			{
				level notify( "notify_test_progress_2" );
				press_number = 3;
				IPrintLn( "test pt2"  );
			}
			else if( press_number == 3 )
			{
				level notify( "notify_test_progress_3" );
				press_number = 0;
				IPrintLn( "test pt3...reset"  );
			}
			wait( 2.0 );
		}
		
		wait level.timestep;
	}
	
}

//**************************************************************
//		Train Misc Scripts
//**************************************************************

//*******************************************************************
//																	*
//		ALLY SCRITPS												*
//*******************************************************************

// Alpha team
spawn_allies()
{
	CONST_EXPECTED_NUM_ALLIES = 1;		//How many allies do we expect?
	
	// Get Spawners
	spawners = GetEntArray( "spawner_allies", "script_noteworthy" );	
	AssertEx( spawners.size == CONST_EXPECTED_NUM_ALLIES, "Alpha squad has " + spawners.size + " spawners (expecting " + CONST_EXPECTED_NUM_ALLIES + ")" );
	
	// Add ally spawn function
	foreach ( guy in spawners )	
		guy add_spawn_function( ::spawnfunc_ally );
	
	// Spawn and load into global
	level._allies = spawn_allies_group( spawners );
	level._ally	  = level._allies[ 0 ];
}

spawn_allies_group( spawners )
{
	spawned_allies = [];
	
	foreach ( spawner in spawners )
	{		
		Assert( IsDefined( spawner.targetname ) );
		
		if ( IsSubStr( spawner.targetname, "ally_01" ) )
		{			
			spawner.script_friendname = "Hesh";
			ally					  = spawner spawn_ai();
			Assert( IsDefined( ally ) );			
			ally.animname = "ally1";
			spawned_allies[ 0 ] = ally;							
		}
		else if ( IsSubStr( spawner.targetname, "ally_02" ) )
		{
			spawner.script_friendname = "Merrick";
			ally					  = spawner spawn_ai();
			Assert( IsDefined( ally ) );
			ally.animname = "ally2";
			spawned_allies[ 1 ] = ally;
		}
		else
		{
			AssertMsg( "Unknown ally '" + spawner.targetname );
		}		
	}
	
	Assert( spawned_allies.size == spawners.size );
	
	return spawned_allies;
}

// Spawnfunc for Alpha team members
spawnfunc_ally()
{
	self magic_bullet_shield();	
	self.hero = true;
}

spawn_boss()
{
	boss = GetEnt( "actor_boss", "targetname" ) spawn_ai( true );
	boss.animname = "boss";
	boss magic_bullet_shield();
	level._boss = boss;
}

//*******************************************************************
//																	*
//		RETREAT SCRIPTS												*
//*******************************************************************

delay_retreat( group, time, op_count, flg, trigs, b_delete, notes )
{
	// thread opfor count retreat condition
	if ( IsDefined( op_count ) )
	{
		thread opfor_retreat( group, op_count, flg, trigs, b_delete, notes );
	}
	
	// wait
	flag_wait_or_timeout( flg, time );
	
	// check flag
	if ( flag( flg ) )
		return;
	
	// TEMP TEMP
	// IPrintLnBold( "Retreat timeout: " + time + " seconds" );
	
	// start retreat
	thread retreat_proc( flg, trigs, b_delete, notes );
}

opfor_retreat( group, op_count, flg, trigs, b_delete, notes )
{
	// wait for enemy deaths
	if ( op_count > 0 )
	{
		// wait for op_count enemies to be left
		while ( get_ai_group_sentient_count( group ) > op_count && !flag( flg ) )
			wait( 0.1 );
	}
	else
	{
		// wait for op_count enemies to be killed
		for ( i = op_count; i < 0; i++ )
		{
			level waittill( "ai_killed", guy );
			
			// check if ai is part of the right group
			if ( !IsDefined( guy.script_aigroup ) || guy.script_aigroup != group )
				i--;
		}
	}
	
	
	// check flag
	if ( flag( flg ) )
		return;
	
	// TEMP TEMP
	// IPrintLnBold( "Retreat kills: " + get_ai_group_sentient_count( group ) + " left" );
	
	// start retreat
	thread retreat_proc( flg, trigs, b_delete, notes );
}

retreat_proc( flg, trigs, b_delete, notes )
{
	// make sure trigs is an array
	if ( IsDefined( trigs ) && !IsArray( trigs ) )
		trigs = [ trigs ];
	
	// get triggers
	if ( IsDefined( trigs ) )
	{
		t_array = [];
		foreach ( trig in trigs )
		{
			trig = GetEnt( trig, "targetname" );
			if ( IsDefined( trig ) )
				t_array[ t_array.size ] = trig;
		}
		
		if ( t_array.size > 0 )
			trigs = t_array;
		else
			trigs = undefined;
	}
	
	// trigger trigs
	if ( IsDefined( trigs ) )
	{
		trigs[ 0 ] notify( "trigger" );
		
		// delete trigger ( if bool is set )
		if ( IsDefined( b_delete ) && b_delete )
			array_call( trigs, ::Delete );
	}
	
	// set flag
	if ( !flag( flg ) )
		flag_set( flg );
	
	// check notes
	if ( IsDefined( notes ) && !IsArray( notes ) )
		notes = [ notes ];
	
	// send notes
	if ( IsDefined( notes ) )
		foreach ( note in notes )
			level notify( note );
}
	
//*******************************************************************
//                                                                  *
//     Realistic Ammo Reload Test                                   *
//*******************************************************************

real_reload()
{
	self endon( "death" );
	
	while( 1 )
	{
		self waittill( "reload_start" );
		myWeap = self GetCurrentWeapon();
		myAmmo = self GetCurrentWeaponClipAmmo();
		
		self thread real_reload_proc( myWeap, myAmmo );
	}
}

real_reload_proc( myWeap, myAmmo )
{
	self endon( "death" );
	self endon( "weapon_fire" );
	self endon( "weapon_change" );
	self endon( "weapon_dropped" );
	
	self waittill( "reload" );
	
	if( myWeap == self GetCurrentWeapon() && myAmmo != self GetCurrentWeaponClipAmmo() )
	{
		myStock = self GetWeaponAmmoStock( myWeap );
		self SetWeaponAmmoStock( myWeap, myStock - myAmmo );
	}
}

//*******************************************************************
//																	*
//		MISC SCRIPTS												*
//*******************************************************************

isTrue( bool )
{
	if( IsDefined( bool ) && bool )
		return true;
	
	return false;
}

player_start( player_start_name )
{
	// Grab struct
	player_start = player_start_name;
	if ( IsString( player_start_name ) )
		player_start = GetEnt( player_start_name, "targetname" );
	
	// Move player to start
	level.player SetOrigin( player_start.origin );
	level.player SetPlayerAngles( player_start.angles );
}

teleport_ai_instant()
{
	self endon( "death" );
	
	// teleport ai to relative position on train
	self TeleportEntityRelative( self, self.spawner );
	self TeleportEntityRelative( self.car.ref_start, self.car.ref_end );
//	TeleportScene();
}

flag_wait_badplace_brush( start_flag, bad_name, bad_time, volumes, kill_flag )
{
	if ( !IsArray( start_flag ) )
		start_flag = [ start_flag, 0 ];
	
	if ( !IsArray( volumes ) )
		volumes = [ volumes ];
	
	// wait till start flag is triggerd
	flag_wait( start_flag[ 0 ] );
	
	// additional wait (with possible flag timeout)
	if ( start_flag.size > 2 )
		flag_wait_or_timeout( start_flag[ 2 ], start_flag[ 1 ] );
	else
		wait( start_flag[ 1 ] );
	
	// set volumes to badplace
	foreach ( i, vol in volumes )
		BadPlace_Brush_Moving( bad_name + i, bad_time, vol, "axis", kill_flag );
}

BadPlace_Brush_Moving( name, duration, brush_ent, team, kill_flag )
{
	brush_ent endon( "death" );
	
	if ( IsDefined( kill_flag ) && !IsArray( kill_flag ) )
		kill_flag = [ kill_flag, 0 ];
	
	// flatten angles
	brush_ent.angles *= ( 0, 1, 0 );
	
	BadPlace_Brush( name, duration, brush_ent, team );
	
	// continue to flatten angles to avoid crash
	brush_ent thread BadPlace_Brush_flatten_angles();
	
	if ( IsDefined( kill_flag[ 0 ] ) )
	{
		flag_wait( kill_flag[ 0 ] );
		wait( kill_flag[ 1 ] );
		
		brush_ent Delete();
	}
}

BadPlace_Brush_flatten_angles()
{
	self endon( "death" );

	// continue to flatten angles to avoid crash
	while ( 1 )
	{
		wait( 0.05 );
		self.angles *= ( 0, 1, 0 );
	}
}

// Takes a value and returns a 0 - 1 float based a min and max
normalize_value( min_val, max_val, val_to_normalize )
{

	if ( val_to_normalize > max_val )
	{
		return 1.0;
	}
	else if ( val_to_normalize < min_val )
	{
		return 0.0;
	}	
	return (( val_to_normalize - min_val ) / ( max_val -  min_val ));
}

// Use a 0 - 1 float to generate a value based on min and max values
// zero is the min value, 1 is the max value, anything in between would be factored.
factor_value_min_max( min_val, max_val, factor_val )
{
	return ( max_val * factor_val ) + ( min_val * ( 1 - factor_val ));
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

temp_dialogue_line( name, msg, time )
{
	if ( GetDvarInt( "loc_warnings", 0 ) )
		return;// I'm not localizing your damn temp dialog lines - Nate.

	if ( !isdefined( level.dialogue_huds ) )
	{
		level.dialogue_huds = [];
	}

	for ( index = 0; ; index++ )
	{
		if ( !isdefined( level.dialogue_huds[ index ] ) )
			break;
	}
	color = "^3";
	
	if( !IsDefined( time ) )
		time = 1;
	time = max( 1, time );

	level.dialogue_huds[ index ] = true;

	hudelem = maps\_hud_util::createFontString( "default", 1.5 );
	hudelem.location = 0;
	hudelem.alignX = "left";
	hudelem.alignY = "top";
	hudelem.foreground = 1;
	hudelem.sort = 20;

	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.5 );
	hudelem.alpha = 1;
	hudelem.x = 40;
	hudelem.y = 260 + index * 18;
	hudelem.label = " " + color + "< " + name + " > ^7" + msg;
	hudelem.color = ( 1, 1, 1 );

	wait( time );
	timer = 0.5 * 20;
	hudelem FadeOverTime( 0.5 );
	hudelem.alpha = 0;

	for ( i = 0; i < timer; i++ )
	{
		hudelem.color = ( 1, 1, 0 / ( timer - i ) );
		wait( 0.05 );
	}
	wait( 0.25 );

	hudelem Destroy();

	level.dialogue_huds[ index ] = undefined;
}

debug_show_pos()
{
	while( 1 )
	{
		print3d( self.origin, "(.)", (1,1,1), 1, 1, 1 );
		wait( 0.05 );
	}
}


notifyanimcomplete( anim_ent, anime, the_notify, end_early )
{
	
	if( !IsDefined( end_early ))
		end_early = 0.0;
	
	waittime = getAnimLength( level.scr_anim[ anim_ent.animname ][ anime ] );
	
	waittime -= end_early;
	if( waittime < 0 )
		waittime = 0;
	
	wait( waittime );
	
	level notify( the_notify );
	
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

show_train_geo( train_show_array, parts_to_hide_array )
{
	Assert( IsArray( train_show_array ));
	if( !IsDefined( parts_to_hide_array ))
		parts_to_hide_array = [];
	Assert( IsArray( parts_to_hide_array ));
				
	car_names = GetArrayKeys( level._train.cars );
	cars = level._train.cars;	
	level._train.hidden_parts = 0;
	
	foreach( car_name in car_names )
	{	
		car = cars[ car_name ];
		part_names = GetArrayKeys( car.other_linked_parts );
		
		//
		// This whole car needs to be seen
		//
		
		if( IsDefined( array_find( train_show_array, car_name )))
		{
			car.sus_f show_if_defined();
			car.sus_b show_if_defined();			
			
			foreach( parts in car.other_linked_parts )				
				array_thread( parts, ::show_if_defined );
			
			continue;
		}
	
		//
		// Hide main car parts
		//
		
		if( parts_to_hide_array.size == 0 )
		{
			// No parts are defined, hide all main components
			car.sus_f hide_if_defined();
			car.sus_b hide_if_defined();
			
			level._train.hidden_parts = 4;	

			// Fill hide list with all parts
			parts_to_hide_array = part_names;			
		}
		else
		{
			// Make sure main compenents are unhidden
			car.sus_f show_if_defined();
			car.sus_b show_if_defined();
		}
		
		//
		// Hide specific parts
		//
		
		foreach( part_name in part_names )	
		{
			parts = car.other_linked_parts[ part_name ];
			
			if( IsDefined( array_find( parts_to_hide_array, part_name )))
			{
				array_thread( parts, ::hide_if_defined );
				level._train.hidden_parts += parts.size;
			}
			else
			{
				array_thread( parts, ::show_if_defined );
			}
		}
	}
}

show_if_defined()
{
	if( !IsDefined( self ) || IsDefined( self.noshow ) && self.noshow )
		return;
	
	self Show();
}

hide_if_defined()
{
	if( !IsDefined( self ) || IsDefined( self.nohide ) && self.nohide )
		return;
	
	self Hide();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// Hide objects so they are immune to optimization "showing"
HideNoShow()
{
	self Hide();
	self SetNoShow( true );
}

ShowNoShow()
{
	self Show();
	self SetNoShow( false );
}

SetNoShow( val )
{
	self.noshow = val;
}

SetNoHide( val )
{
	self.nohide = val;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

//object to attach view particles to
create_view_particle_source()
{
	if( !IsDefined( level.view_particle_source )  )
	{
		level.view_particle_source = spawn( "script_model", ( 0, 0, 0 ) );
		level.view_particle_source setmodel( "tag_origin" );
		level.view_particle_source.origin = level.player.origin;
		level.view_particle_source LinkToPlayerView( level.player, "tag_origin", (0,0,0), (0,0,0), true );
		
		// Frame for link
		wait( 0.05 );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// Links object to train car
LinkToTrain( car_name )
{
	Assert( IsDefined( level._train.cars[ car_name ] ));
	self LinkTo( level._train.cars[ car_name ].body, "j_spineupper" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// Checks for if ent is inside a trigger.  Runs function if true.  Runs a different function if false.
trig_watcher( trig, function_start, function_end, stop_notify )
{
	AssertEX( IsDefined( function_start ), "No start function for trig_watcher()" );
	AssertEX( IsDefined( function_end ), "No end function for trig_watcher()" );
	
	if( IsDefined( stop_notify ))
		level endon( stop_notify );
	
	// Create a flag based on trigger name
	flag = "flag_" + trig;
	if( !flag_exist( flag ))
		flag_init( flag );
	
	while( 1 )
	{		
		// If inside trigger, run the start function
		trigger_wait_targetname( trig );
		if( IsDefined( function_start ) && !flag( flag ))
			thread [[ function_start ]]();		
		flag_set( flag );
		level notify( flag + "set" );
		
		// Wait two frames, then clear the flag (func will be killed if still in trigger)
		thread trig_watcher_off( flag, function_end );
	}
}

trig_watcher_off( flag, function_end, stop_notify )
{			
	if( IsDefined( stop_notify ))
		level endon( stop_notify );
	level endon( flag + "set" );
	
	// Wait two frames, then run end function
	wait( 0.1 );
	flag_clear( flag );	
	if( IsDefined( function_end ))
		thread [[ function_end ]]();	
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// Nag dialogue script
dialogue_nag( nag_lines, endon_notify, timeout_func )
{
	level endon( endon_notify );
	
	// First pass, say in order
	foreach( nag in nag_lines )
	{
		wait( RandomFloatRange( 5, 8 ));
		self thread smart_dialogue( nag );
	}
	
	// After nag lines, if there is a timeout string or function defined
	if( IsDefined( timeout_func ))
	{
		thread [[timeout_func]]();
		return;
	}
	
	nag_array = nag_lines;
	
	// Play random nags until the end of time (or player acts)
	while( 1 )
	{
		if( nag_array.size == 0 )
			nag_array = nag_lines;
		
		wait( 13 );
		nag = random( nag_array );
		nag_array = array_remove( nag_array, nag );
		self thread smart_dialogue( nag );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

spawn_tag_origin_from_tag( tag_name, linkto_obj )
{
	obj = spawn_tag_origin();
	obj.origin = self GetTagOrigin( tag_name );
	obj.angles = self GetTagAngles( tag_name );	
	if( IsDefined( linkto_obj ))
		obj LinkTo( linkto_obj );
	return obj;	
}
//*******************************************************************
//																	*
//																	*
//*******************************************************************

kill_plane_death()
{	
	flag_wait( "flag_kill_plane" );
	SetDvar( "ui_deadquote", &"SKYWAY_FAIL_KILL_PLANE" );
	MissionFailedWrapper();
}

/*
=============
///ScriptDocBegin
"Name: setup_player_for_animated_sequence( <do_player_link>, <link_clamp_angle>, <rig_origin>, <rig_angles>, <do_player_restrictions>, <do_player_restrictions_by_notify> )"
"Summary: Automate the process of spawning a rig, mover, linking player for an animated sequence."
"Module: Player"
"OptionalArg: <do_player_link>: defaults to true"
"OptionalArg: <link_clamp_angle>: defaults to 60"
"OptionalArg: <rig_origin>: defaults to player's origin"
"OptionalArg: <rig_angles>: defaults to player's angles"
"OptionalArg: <do_player_restrictions>: defaults to true"
"OptionalArg: <do_player_restrictions_by_notify>: defaults to false"
"Example: maps\black_ice_util::setup_player_for_animated_sequence()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
setup_player_for_animated_sequence( do_player_link, link_clamp_angle, rig_origin, rig_angles, do_player_restrictions, do_player_restrictions_by_notify, mover_model )
{
	// Setup default variables
	if ( !IsDefined( do_player_link) )
	{
		do_player_link = true;
	}
	
	if ( do_player_link )
	{
		if ( !IsDefined( link_clamp_angle ) )
		{
			link_clamp_angle = 60;
		}
	}
	
	if ( !IsDefined( rig_origin ) )
	{
		rig_origin = level.player.origin;
	}
		
	if ( !IsDefined( rig_angles ) )
	{
		rig_angles = level.player.angles;
	}
	
	if ( !IsDefined( do_player_restrictions ) )
	{
		do_player_restrictions = true;
	}
	
	// Setup player rig for anims
	player_rig = spawn_anim_model( "player_rig", rig_origin );
	level.player_rig = player_rig;
	player_rig.angles = rig_angles;
	//player_rig hide();
	
	player_rig.animname = "player_rig";
	
	if ( IsDefined( mover_model ) )
	{
		player_mover = spawn_anim_model( mover_model );
	}
	else
	{
		player_mover = spawn_tag_origin();
	}
	
	level.player_mover = player_mover;
	player_mover.origin = rig_origin;
	player_mover.angles = rig_angles;
	player_rig LinkTo( player_mover );
	
	if ( do_player_link )
	{
		level.player PlayerLinkToDelta( player_rig, "tag_player", 1, link_clamp_angle, link_clamp_angle, link_clamp_angle, link_clamp_angle, true );
	}
	
	if ( do_player_restrictions )
	{
		thread player_animated_sequence_restrictions( do_player_restrictions_by_notify );
	}
}

/*
=============
///ScriptDocBegin
"Name: player_animated_sequence_restrictions( <do_player_restrictions_by_notify> )"
"Summary: All the restrictions necessary for the player to do an animated sequence."
"Module: Player"
"OptionalArg: <do_player_restrictions_by_notify>: defaults to false"
"Example: maps\black_ice_util::player_animated_sequence_restrictions()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
player_animated_sequence_restrictions( do_player_restrictions_by_notify )
{
	if( IsDefined( do_player_restrictions_by_notify ) && do_player_restrictions_by_notify )
		level.player waittill( "notify_player_animated_sequence_restrictions" );
	
	level.player.disableReload = true;
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player DisableWeaponSwitch();

	level.player AllowCrouch( false );
	level.player AllowJump( false );
	//level.player AllowLean( false );
	level.player AllowMelee( false );
	level.player AllowProne( false );
	level.player AllowSprint( false );
}

/*
=============
///ScriptDocBegin
"Name: player_animated_sequence_cleanup()"
"Summary: Re-enables all the previous restrictions after a player goes through an animated sequence."
"Module: Player"
"Example: maps\black_ice_util::player_animated_sequence_cleanup()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
player_animated_sequence_cleanup()
{
	if ( !IsDefined( level.player.early_weapon_enabled ) || !level.player.early_weapon_enabled )
	{
		level.player.early_weapon_enabled = undefined;
		
		level.player.disableReload = false;
		level.player EnableWeapons();
		level.player EnableOffhandWeapons();
		level.player EnableWeaponSwitch();
	}

	level.player AllowCrouch( true );
	level.player AllowJump( true );
	//level.player AllowLean( true );
	level.player AllowMelee( true );
	level.player AllowProne( true );
	level.player AllowSprint( true );
	
	level.player Unlink();
	
	if ( IsDefined( level.player_mover ) )
	{
		level.player_mover Delete();
	}
	
	if ( IsDefined( level.player_rig ) )
	{
		level.player_rig Delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
check_anim_time( animname, anime, time )
{
	curr_time = self GetAnimTime( level.scr_anim[ animname ][ anime ] );
	if ( curr_time >= time )		
	{
		return true;
	}

	return false;
}
//*******************************************************************
//      LIGHTING SCRIPTS                                            *
//                                                                  *
//*******************************************************************
dynamic_sun_sample_size()
{
	val_1 = 1.0;
	val_2 = 0.3;
	
	target_val = 0.25;
	
	while(true)
	{
		p_angles = level.player GetPlayerAngles();
		world_angles = CombineAngles((0,-90,0), p_angles);
		world_angles = AnglesToForward(world_angles);
		
		result = VectorDot(VectorNormalize(world_angles), (0,0,-1));
		result = clamp(result, 0,1);
		value_scale = (val_2-val_1);
		target_val = (value_scale * result) + val_1;
		
		// IPrintLn(result + " | " + target_val);
		
		SetSavedDvar("sm_sunSampleSizeNear", target_val);
		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flag_watcher( flag, function_start, function_end, end_notify )
{
	if( IsDefined( end_notify ))
		level endon( end_notify );
	
	if( !flag_exist( flag ))
		flag_init( flag );
			
	active = false;
	
 	while( 1 )
	{
		if( flag( flag ) && !active )
		{
			if( IsDefined( function_start ))
				self thread [[ function_start ]]();
			
			active = true;
		}
		else if( !flag( flag ) && active )
		{
			if( IsDefined( function_end ))
				self thread [[ function_end ]]();
			
			active = false;
		}
		
		wait( 0.05 );
	}	
}