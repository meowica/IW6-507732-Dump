// Hanging light that swings when shot
#include common_scripts\_destructible;
#include maps\interactive_models\_interactive_utility;

main()
{
	if( common_scripts\utility::isSP() )
	{
		destructible_create( "toy_hanging_light_off", "tag_origin", 0 );
			destructible_function( ::hanging_light_off );
	}
}

hanging_light_off()
{
	startAngles = self.angles;
	AssertEx ( abs( startAngles[0] ) < 5 && abs( startAngles[2] ) < 5, "Hanging_light script assumes light is hanging straight down.  Pitch and roll must be 0 or weirdness will result." );
	invStartFwd = AnglesToForward( startAngles );
	invStartRight = ( invStartFwd[1]    ,      invStartFwd[0]  , 0 );
	invStartFwd   = ( invStartFwd[0]    , -1 * invStartFwd[1]  , 0 );
	if ( IsDefined( self.script_angles ) )	// self.script_angles is used as a maximum deflection
		maxAngles = ( self.script_angles[2], self.script_angles[0], self.script_angles[1] );	// (Pitch, yaw, roll) is actually (y,z,x)
	else
		maxAngles = (90,90,90);
	if ( IsDefined( self.script_duration ) )	// self.script_duration is used as the period of swing
		sixthSwingTime = ( self.script_duration / 6 ) * RandomFloatRange( 0.9, 1.1 );
	else
		sixthSwingTime = 0.4 * RandomFloatRange( 0.9, 1.1 );
	// RotateTo() stutters if times don't line up with server frames, so clamp the time 
	sixthSwingTime = ( int( sixthSwingTime * 20 ) / 20 );
	
	// Wait for damage.
	while(1)
	{
		self waittill( "damage", amount, attacker, direction, point, type );
		type = destructible_scripts\toy_lv_trash_can_vegas::destructible_ModifyDamageType( type );
		amount = destructible_scripts\toy_lv_trash_can_vegas::destructible_ModifyDamageAmount( amount, type, attacker );

		force = [];
		if ( type == "splash" )
		{
			direction = VectorNormalize( direction );// Explosion direction is not normalized by default.
			point = ( RandomFloatRange(-100,100), RandomFloatRange(-100,100), -400 );	// Choose a point that might be near the middle of the model
			point *= sixthSwingTime;	// Use swing time as a stand-in for the size of the model
			point += self.origin;
		}
		// Find the distance from the shot vector to the swivel axis.
		leverageVec = VectorFromLineToPoint( point, point+direction, self.origin );
		// Handle pitch, yaw and roll each as a 2D system
		for ( axis = 0; axis < 3; axis++ )
		{
			leverage2d = zeroComponent( leverageVec, axis );
			leverage2d = rotate90AroundAxis ( leverage2d, axis );
			direction2d = zeroComponent( direction, axis );
			force[axis] = VectorDot( leverage2d, direction2d );		// 'force' is now positive for counter-clockwise.			
		}
		
		// Transform force into the model's space.  Assume the model's pitch and roll angles are 0, so we can leave force[2] alone.
		force = ( force[0] * invStartFwd ) + ( force[1] * invStartRight ) + ( 0, 0, force[2] );
		
		force /= sixthSwingTime * sixthSwingTime * 40;	// Arbitrary number.  Divide by swing time as a stand-in for mass.
		
		self notify( "new swing" );
		// Swizzle force here because (pitch, yaw, roll) is actually (y,z,x)
		self thread hanging_light_swing( ( force[1], force[2], force[0] ), startAngles, sixthSwingTime, maxAngles );
	}	
}

hanging_light_swing( force, restAngles, sixthSwingTime, maxAngles )
{
	self endon( "new swing" );
	
	// First time through, start from current position, use instant acceleration.
	targetAngles = self.angles+force;
	// Clamp to angle limits set in Radiant
	targetAngles = ( clamp( targetAngles[0], restAngles[0]-maxAngles[0], restAngles[0]+maxAngles[0] ),
				     clamp( targetAngles[1], restAngles[1]-maxAngles[1], restAngles[1]+maxAngles[1] ), 
				     clamp( targetAngles[2], restAngles[2]-maxAngles[2], restAngles[2]+maxAngles[2] ) );
	// If the motion was clamped, don't wait as long or the light will appear to freeze
	firstSwingTime = Length( targetAngles - self.angles ) / Length( force );
	firstSwingTime *= sixthSwingTime;
	firstSwingTime = ( int( firstSwingTime * 20 ) / 20 );
	if ( firstSwingTime < 0.1 ) firstSwingTime = 0.1;	// 0.05 is not enough time for RotateTo to do anything useful.

	self RotateTo( targetAngles, firstSwingTime * 3/2, 0, firstSwingTime );
	wait ( firstSwingTime * 3/2 );
	
	// Now we're at the apex of our swing, just reverse all the angles for the next angle.
	force = targetAngles - restAngles;
	largestComp = max ( max ( abs( force[0] ), abs( force[1] ) ), abs( force[2]) );
	while ( force[0] != 0 || force[1] != 0 || force[2] != 0 )
	{
		scaleFactor = ( ( largestComp * 0.9 ) - 0.5 ) / largestComp;	// Reduce by an amount as well as scale, so it doesn't go forever.
		if ( scaleFactor < 0 ) scaleFactor = 0;
		largestComp *= scaleFactor;
		force *= scaleFactor * -1;
		targetAngles = restAngles+force;
		self RotateTo( targetAngles, sixthSwingTime*3, sixthSwingTime, sixthSwingTime );
		wait ( sixthSwingTime * 3 );
	}
}