#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
setup_spotlight_heli( start_path_node_targetname, vehicle_targetname, first_heli )
{
	if ( !IsDefined( first_heli ) )
	{
		first_heli = true;
	}

	// Grab the heli
	spotlight_heli = spawn_vehicle_from_targetname_and_drive( vehicle_targetname );
	//spotlight_heli = spawn_vehicle_from_targetname( vehicle_targetname );
	level.spotlight_heli = spotlight_heli;
	//node = GetStruct( start_path_node_targetname, "targetname" );
	//spotlight_heli thread vehicle_paths( node );

	spotlight_heli thread heli_target_dialogue();

	// Sanity check
	if ( !IsDefined( spotlight_heli ) )
	{
		return;
	}

	spotlight_heli endon( "death" );

	//spotlight_heli maps\_vehicle::set_heli_move( "faster" );
	
	// Set up some vars
	spotlight_heli.state = "reveal";
	spotlight_heli.section = "market";
	spotlight_heli.spotTarget_last_known_pos = ( 0, 0, 0 );
	spotlight_heli.default_speed = 18;
	spotlight_heli.evade_health_threshold = 0.9;
	spotlight_heli.num_evasions = 2;
	spotlight_heli.reacquire_player_time = GetTime() + 9000;
	spotlight_heli.focus_ally = false;
	spotlight_heli.damage_fx = "none";

	// Play progressive damage fx
	//spotlight_heli thread spotlight_heli_damage_fx_process();

	// Heli runs away when the player attacks
	//spotlight_heli thread spotlight_heli_evasive_think();

	spotlight_heli thread spotlight_heli_on_death();

	spotlight_heli thread spotlight_heli_trigger_death();

	// Initiate pathing
	//spotlight_heli thread maps\_attack_heli::heli_circling_think( "attack_heli_circle_node", 50, maps\_attack_heli::heli_circle_node_choice );
	spotlight_heli gopath();
	spotlight_heli Vehicle_SetSpeed( spotlight_heli.default_speed, 15, 15 );

	// Set up spotlight
	spotlight_heli.eTarget = level.player;
	spotlight_heli vehicle_scripts\_attack_heli::heli_default_target_setup();
	spotlight_heli thread vehicle_scripts\_attack_heli::heli_spotlight_on( "tag_barrel" , false, true );
	spotlight_heli thread vehicle_scripts\_attack_heli::heli_spotlight_aim( ::spotlight_heli_think );

	spotlight_heli thread spotlight_heli_check_vision_set();

	// Slow down the rotation
	spotlight_heli spotlight_heli_update_spotlight_speed( 0.33 );

	if ( first_heli )
	{
		// Point in front of player
		forward = AnglesToForward( level.player.angles );
		forwardfar = forward * 500;
		spot_vect = forwardfar + randomvector( 50 );
		spotlight_heli.spotTarget = Spawn( "script_origin", ( level.player.origin + forwardfar ) );
		spotlight_heli vehicle_scripts\_attack_heli::heli_spotlight_destroy_default_targets();
		spotlight_heli vehicle_scripts\_attack_heli::heli_spotlight_create_default_targets( spotlight_heli.spotTarget );
	}

	return spotlight_heli;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
heli_target_dialogue()
{
	self endon( "death" );
	//flag_wait( "heli_intro_dialogue_complete" );
	
	wait 0.5;
	current_target = undefined;

	while ( 1 )
	{
		if ( isDefined( self.spottarget ) )
		{
			if ( !isDefined( current_target ) || current_target != self.spottarget )
			{
				current_target = self.spottarget;
				if ( isDefined( current_target ) && isPlayer( current_target ) )
				{
					//level.baker radio_dialogue( "exf_bak_helo_outofsight" ); // Spotlight's drawing heat!  Get out of sight!
					return; // Only do this dialogue once
				}
			}
		}
		wait 1.0;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_on_death()
{
	self waittill( "death" );

	//spotlight_heli_set_threatbias( "none" );

	//VisionSetNaked( "nx_exfil", 0.25 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_trigger_death()
{
	self endon( "death" );

	if ( IsDefined( level.spotlight_heli ) )
	{
		// Fly off and die
		back = AnglesToForward( level.spotlight_heli.angles ) * -1;

		// Magic #'s, 600 insures it goes to a lower position than the flight path
		new_pos = ( ( level.spotlight_heli.origin + ( back * 10000 ) ) * ( 1, 1, 0 ) ) + ( 0, 0, 600 );
	
		level.spotlight_heli maps\_vehicle_code::vehicle_pathdetach();
		level.spotlight_heli Vehicle_SetSpeed( 100, 40, 40 );
		level.spotlight_heli SetVehGoalPos( new_pos, true );

		level.spotlight_heli waittill( "near_goal" );

		level.spotlight_heli Delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_set_threatbias( target )
{
	ally = level.allies[ "ally1" ];

	// Force no threatbias during the last encounter (barricade)
	if ( IsDefined( level.spotlight_heli ) && level.spotlight_heli.focus_ally == true )
	{
		target = "none";
	}

	switch ( target )
	{
		case "player":
			// Set threatbias really high so enemies will target when they are in spotlight
			level.player.threatbias = 1000;
			//level.player.attackeraccuracy = 1.3;
	
			if ( IsDefined( ally ) )
			{
				ally.threatbias = 0;
			}

			break;

		case "ally":
			// Set threatbias really high so enemies will target when they are in spotlight
			if ( IsDefined( ally ) )
			{
				ally.threatbias = 1000;
			}

			level.player.threatbias = 0;
			//level.player.attackeraccuracy = 0.7;

			break;

		case "none":
			level.player.threatbias = level.default_player_threatbias;
			//level.player.attackeraccuracy = 1.0;
			
			if ( IsDefined( ally ) )
			{
				ally.threatbias = 200;
			}

			break;

		default:
			assert( "need to pass in a target to spotlight_heli_set_threatbias" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_check_vision_set()
{
	self endon( "death" );

	vision_swap_time = 0.25;

	while ( 1 )
	{
		if ( vehicle_scripts\_attack_heli::can_see_player( level.player ) )
		{
			pos = self GetTagOrigin( "TAG_FLASH" );
			angles = self GetTagAngles( "TAG_FLASH" );
			forward = AnglesToForward( angles );
	
			eye_vect = ( level.player GetEye() ) - pos;
			eye_vect = VectorNormalize( eye_vect );
	
			angle = acos( VectorDot( forward, eye_vect ) );

			if ( angle < 10 )
			{
				// In spotlight
				//vision_set = "nx_exfil_spotlight";
				//if ( self.section == "street" )
				//{
					//vision_set = "nx_exfil_spotlight_2";
				//}

				//VisionSetNaked( vision_set, vision_swap_time );
			}
			else
			{
				// Not in spotlight
				//VisionSetNaked( "nx_exfil", vision_swap_time );
			}
		}
		else
		{
			// Not in spotlight
			//VisionSetNaked( "nx_exfil", vision_swap_time );
		}

		wait vision_swap_time;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_update_spotlight_speed( speed_mult )
{
	//self SetTurretRotationSpeedMultiplier( speed_mult );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_think()
{
	self endon( "death" );

	while ( 1 )
	{
		wait( RandomFloatRange( 1, 3 ) );

		switch ( self.state )
		{
			case "reveal":
				self thread spotlight_heli_reveal_state();
				break;

			case "searching":
				self thread spotlight_heli_searching_state();
				break;

			case "targeting":
				self thread spotlight_heli_targeting_state();
				break;

			case "reacquire":
				self thread spotlight_heli_reacquire_state();
				break;

			case "waiting":
				// Do nothing
				break;

			default:
				assert( "spotlight heli has invalid state" );
				break;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_reveal_state()
{
	self endon( "death" );

	if ( GetTime() > self.reacquire_player_time )
	{
		self vehicle_scripts\_attack_heli::heli_spotlight_destroy_default_targets();

		self.state = "searching";
	}
	else
	{
		// Point in front of player
		self vehicle_scripts\_attack_heli::heli_spotlight_destroy_default_targets();
		forward = AnglesToForward( level.player.angles );
		forwardfar = forward * 500;
		spot_vect = forwardfar + randomvector( 50 );
		self.spotTarget = Spawn( "script_origin", ( level.player.origin + forwardfar ) );
		self vehicle_scripts\_attack_heli::heli_spotlight_create_default_targets( self.spotTarget );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_searching_state()
{
	self endon( "death" );

	ally = level.allies[ "ally1" ];

	can_see_player = ( ( self.focus_ally == false ) && vehicle_scripts\_attack_heli::can_see_player( level.player ) );
	can_see_ally = ( IsDefined( ally ) && vehicle_scripts\_attack_heli::can_see_player( ally ) );
	target_player = false;
	target_ally = false;

	// Both in line of sight
	if ( can_see_player && can_see_ally )
	{
		// Give player more chance to be targeted (66%)
		iRand = RandomInt( 3 );

		if ( iRand == 2 )
		{
			target_ally = true;
		}
		else
		{
			target_player = true;
		}
	}
	else if ( can_see_player )
	{
		target_player = true;
	}
	else if ( can_see_ally )
	{
		target_ally = true;
	}
	else// otherwise just aim at one of the default targets
	{
		self spotlight_heli_default_targeting();

		//spotlight_heli_set_threatbias( "none" );
	}

	if ( target_player )
	{
		self.spotTarget = level.player;
		self.state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		//spotlight_heli_set_threatbias( "player" );
	}
	else if ( target_ally )
	{
		self.spotTarget = ally;
		self.state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		//spotlight_heli_set_threatbias( "ally" );
	}
	else
	{
		// Slow down the rotation
		self spotlight_heli_update_spotlight_speed( 0.33 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_targeting_state()
{
	self endon( "death" );
	
	ally = level.allies[ "ally1" ];

	// Stay in this state as long as the heli can still see the target
	if ( IsDefined( self.spotTarget ) && vehicle_scripts\_attack_heli::can_see_player( self.spotTarget ) )
	{
		self.spotTarget_last_known_pos = self.spotTarget.origin;
		//self spotlight_heli_stop_circling();

		// Chance to re-target player
		if ( self.focus_ally == false )
		{
			if ( self.spotTarget != level.player )
			{
				iRand = RandomInt( 4 );
				if ( iRand == 2 )
				{
					if ( vehicle_scripts\_attack_heli::can_see_player( level.player ) )
					{
						self.spotTarget = level.player;
						self.spotTarget_last_known_pos = level.player.origin;

	
						// Slow down the rotation, then delay speed it up
						self spotlight_heli_update_spotlight_speed( 0.75 );
						self delayThread( 0.75, ::spotlight_heli_update_spotlight_speed, 5.0 );
	
						//spotlight_heli_set_threatbias( "player" );
					}
				}
			}
			else if ( self.spotTarget != ally ) // Chence to re-target ally
			{
				iRand = RandomInt( 7 );
				if ( iRand == 3 )
				{
					if ( vehicle_scripts\_attack_heli::can_see_player( ally ) )
					{
						self.spotTarget = ally;
						self.spotTarget_last_known_pos = ally.origin;

	
						// Slow down the rotation, then delay speed it up
						self spotlight_heli_update_spotlight_speed( 0.75 );
						self delayThread( 0.75, ::spotlight_heli_update_spotlight_speed, 5.0 );
	
						//spotlight_heli_set_threatbias( "ally" );
					}
				}
			}
		}
	}
	else
	{
		self.prevSpotTarget = self.spotTarget;
		self.spotTarget = Spawn( "script_origin", self.spotTarget_last_known_pos );
		self.spotTarget.angles = level.player.angles;
		self.reacquire_player_time = GetTime() + 3000;

		if ( self.focus_ally == false )
		{
			self.reacquire_ally_time = GetTime() + 10000;
		}
		else
		{
			self.reacquire_ally_time = GetTime() + 2500;
		}

		self vehicle_scripts\_attack_heli::heli_spotlight_destroy_default_targets();
		self vehicle_scripts\_attack_heli::heli_spotlight_create_default_targets( self.spotTarget );

		//self spotlight_heli_resume_circling();

		//spotlight_heli_set_threatbias( "none" );

		self.state = "reacquire";

		// Slow down the rotation
		self spotlight_heli_update_spotlight_speed( 0.33 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_reacquire_state()
{
	self endon( "death" );

	ally = level.allies[ "ally1" ];

	// When heli loses sight of target, it will sweep the area of target's
	// "last known position", and continue to do so until the target goes beyond
	// a certain proximity.
	if ( IsDefined( self.prevSpotTarget ) && IsDefined( self.spotTarget_last_known_pos ) && Distance( self.prevSpotTarget.origin, self.spotTarget_last_known_pos ) > 500 )
	{
		self vehicle_scripts\_attack_heli::heli_spotlight_destroy_default_targets();

		self spotlight_heli_default_targeting();

		self.state = "searching";
	}
	else if ( ( GetTime() > self.reacquire_player_time ) && vehicle_scripts\_attack_heli::can_see_player( level.player ) )
	{
		self vehicle_scripts\_attack_heli::heli_spotlight_destroy_default_targets();

		self.spotTarget = level.player;
		self.state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		//spotlight_heli_set_threatbias( "player" );
	}
	else if ( ( GetTime() > self.reacquire_ally_time ) && IsDefined( ally ) && vehicle_scripts\_attack_heli::can_see_player( ally ) )
	{
		self vehicle_scripts\_attack_heli::heli_spotlight_destroy_default_targets();

		self.spotTarget = ally;
		self.state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		//spotlight_heli_set_threatbias( "ally" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_default_targeting()
{
	self endon( "death" );

	iRand = RandomInt( level.spotlight_aim_ents.size );
	self.targetdefault = level.spotlight_aim_ents[ iRand ];
	self.spotTarget = self.targetdefault;
}