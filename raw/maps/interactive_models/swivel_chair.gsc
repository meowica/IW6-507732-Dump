// Chair that rotates when shot
#include common_scripts\_destructible;
//#include destructible_scripts\toy_lv_trash_can_vegas;	// Current home to the Fall_and_Break stuff, which replicates a lot of destructibles functionality in individual functions.
#using_animtree( "destructibles" );

main()
{
	if( common_scripts\utility::isSP() )
	{
		destructible_create( "toy_swivel_chair", "tag_origin", 0 );
			destructible_function( ::gambling_chair_1 );
	}
}

gambling_chair_1()
{
	self AddYaw( RandomFloatRange(-20,20) );					// Random initial rotation, for a little variety

	swivel_point_2d = ( self.origin[0], self.origin[1], 0 );	// Assume the swivel is vertical.  It makes everything much simpler.
	yaw_start = self.angles[1];
	
	// Wait for damage.
	while(1)
	{
		self waittill( "damage", amount, attacker, direction, point, type );
		type = destructible_scripts\toy_lv_trash_can_vegas::destructible_ModifyDamageType( type );
		amount = destructible_scripts\toy_lv_trash_can_vegas::destructible_ModifyDamageAmount( amount, type, attacker );

		if ( type != "splash" )
		{
			// Find the distance from the shot vector to the swivel axis, when viewed along the swivel axis (which is Z).
			point_2d = ( point[0], point[1], 0 );
			direction_2d = ( direction[0], direction[1], 0 );
			leverageVec = VectorFromLineToPoint( point_2d, point_2d+direction_2d, swivel_point_2d );
			// Is the force clockwise or counter-clockwise?
			leverageVec = ( leverageVec[1], -1 * leverageVec[0], 0 );	// Rotate leverageVec clockwise 90 degrees around Z.
			force = VectorDot( leverageVec, direction_2d );				// 'force' is now positive for counter-clockwise.
		}
		else
		{
			// Explosion, presumably.
			force = amount * RandomFloatRange( -0.2, 0.2 );	
			force = clamp( force, -100, 100 );
		}
		force *= 10;													// Arbitrary multiplier.  Could be data driven.
		
		if ( force != 0 )
		{
			limit = 110;												// Temp(?) hard coded limit - could be object-specific.
			// If the chair has a stopper so it can't turn all the way around, make it bounce off
			if ( isDefined( limit ) )
			{
				currentYaw = AngleClamp180( self.angles[1] - yaw_start );
				while ( currentYaw + force > limit || currentYaw + force < -1 * limit )
				{
					if ( currentYaw + force > 0 )
						angle = limit - currentYaw;
					else
						angle = -1 * limit - currentYaw;
					timeSpinning  = sqrt(abs(force)) / 5;
					timeSpinning -= sqrt(abs(force-angle)) / 5;
					timeSpinning = RoundToServerFrame( timeSpinning );
					if ( timeSpinning > 0 )
					{
						self RotateYaw( angle, timeSpinning );			// It's not easy to have it decelerate without actually stopping, so go with constant speed.
						wait ( timeSpinning + 0.05 );
						currentYaw = AngleClamp180( self.angles[1] - yaw_start );
					}
					force -= angle;
					force *= -0.4;
				}
			}
			
			timeSpinning = sqrt(abs(force)) / 5;
			self RotateYaw( force, timeSpinning, 0, timeSpinning );
		}
	}	
}

RoundToServerFrame( inputTime )
{
	// RotateTo(), RotateYaw() etc stutter if times don't line up with server frames, so clamp the time 
	return ( int( inputTime * 20 ) / 20 );
}