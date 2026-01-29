#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;

_precache()
{
	_audio();
}

_audio()
{
	
}

_init( apache, owner )
{
	Assert( IsDefined( owner ) );
	Assert( IsDefined( apache ) );
	
	audio = SpawnStruct();
	
	// Generic system fields
	audio.owner  = owner;
	audio.apache = apache;
	
	// Audio specific fields added in start_player_apache_engine_audio()
	
	return audio;
}

_start()
{
	// Note: Self in this case is the struct audio created in _init()
	self thread start_player_apache_engine_audio();
}

_end()
{
	owner = self.owner;
	
	owner notify( "LISTEN_end_audio" );
	
}

_destroy()
{
	self _end();
	
	array_call( self.audio_entities, ::Delete );
}

start_player_apache_engine_audio()
{
	owner  = self.owner;
	apache = self.apache;
	
	owner endon( "LISTEN_end_audio" );

	//the low speed loop will play when the player speed is between 0 and the start crossfade point
	//when the speed is between the start and end crossfade points, it will fade out linearly
	//when the speed is above the end crossfade point, the volume of the low-speed loop will be 0 volume
	self.lowspeed_start_crossfade = 29.0;
	self.lowspeed_end_crossfade = 55.0;
	self.low_speed_mult = 1.0;	
	
	//the high speed loop will start to fade in when the player speed is above the start crossfade point
	//when the speed is between the start and end crossfade points, it will fade in linearly
	//when the speed is above the end crossfade point, the volume of the high-speed loop will be 100 percent volume
	self.highspeed_start_crossfade = 18.0;
	self.highspeed_end_crossfade = 65.0;
	self.high_speed_mult = 1.0;

	//these variables control the pitch of all the sounds together, so that they all pitch together
	self.overall_pitch_min = 0.9661;
	self.overall_pitch_max = 1.0299;
	self.overall_pitch = 1.0;
	
	//these variables are used to control the amount of pitch change based ont he amount of roll
	self.overall_pitch_roll_modifier = 1.0;
	self.overall_pitch_roll_modifier_max = 0.023;
	
	//the banking/rolling loop will start to fade in when the roll start value is reached
	//when the roll is between the roll start and roll end the banking loop will fade in linearly
	//when the roll value is above the roll end crossfade point the bank volume is 100 percent volume	
	//the roll mult is used for the banking loop volume, and the roll other mult is the volume value for the other assets (slow and fast loops)
	self.roll_start_crossfade = 3.0;
	self.roll_end_crossfade = 30.0;
	self.roll_max_roll = 35.0;
	self.roll_mult = 1.0;
	self.roll_other_mult = 1.0;
	
	/*
	//DR: SAVE THIS STUFF!
	//was trying out dynamically shifting the bank/roll window based on speed, so that slower speeds didn't sound like you were leaning so hard when you banked just a little...
	//...it's a work in progress...
	self.new_roll_start_crossfade = self.roll_start_crossfade;
	self.new_roll_end_crossfade = self.roll_end_crossfade;
	
	self.roll_crossfade_speed_max = 50;
	self.roll_crossfade_speed_min = 30;	
	*/	
	
	//now spawn some temp entities in order to use scale pitch and scale volume	
	
	// Add these temp entities to an array so that clean up is easy
	self.audio_entities = [];
	
	//low speed - straight
	self.audio_entities[ "low_front" ] = Spawn( "script_origin", owner.origin );
	self.audio_entities[ "low_front" ] LinkTo( owner );
	self.audio_entities[ "low_front" ] PlayLoopSound( "apache_int_slow_fronts" );
	
	self.audio_entities[ "low_rear" ] = Spawn( "script_origin", owner.origin );
	self.audio_entities[ "low_rear" ] LinkTo( owner );
	self.audio_entities[ "low_rear" ] PlayLoopSound( "apache_int_slow_rears" );	
	
	
	//high speed - straight
	self.audio_entities[ "high_front" ] = Spawn( "script_origin", owner.origin );
	self.audio_entities[ "high_front" ] LinkTo( owner );
	self.audio_entities[ "high_front" ] PlayLoopSound( "apache_int_fast_fronts" );
	
	self.audio_entities[ "high_rear" ] = Spawn( "script_origin", owner.origin );
	self.audio_entities[ "high_rear" ] LinkTo( owner );
	self.audio_entities[ "high_rear" ] PlayLoopSound( "apache_int_fast_rears" );	
	
	
	//high bank (both speeds)
	self.audio_entities[ "high_bank_front" ] = Spawn( "script_origin", owner.origin );
	self.audio_entities[ "high_bank_front" ] LinkTo( owner );
	self.audio_entities[ "high_bank_front" ] PlayLoopSound( "apache_int_bank_fronts" );
	
	self.audio_entities[ "high_bank_rear" ] = Spawn( "script_origin", owner.origin );
	self.audio_entities[ "high_bank_rear" ] LinkTo( owner );
	self.audio_entities[ "high_bank_rear" ] PlayLoopSound( "apache_int_bank_rears" );
	
	//now adjust those sounds every 100 ms	
	while ( 1 )
	{
		// Grab the apache info each update to be used
		// in the functions below
		self.audio_speed = apache Vehicle_GetSpeed();
		self.audio_roll	 = abs( apache.angles[ 2 ] );
		
		//update the pitches the overall pitch of the apache, plus any other scaling or such that will need to be taken into account
		self adjust_overall_apache_pitches();
		
		//adjust the roll/bank pitches and sounds
		self childthread adjust_helo_sound_roll();
		
		//adjust low chopper sound
		self childthread adjust_helo_sound_low();		
		
		//adjust high chopper sound
		self childthread adjust_helo_sound_high();		
		
		//wait 100 ms and repeat
		wait( 0.1 );
	}
}

adjust_overall_apache_pitches()
{
	//this will make the pitches of all the layers go up and down
	//the pitch curve will be something like min at speed 0, and max at the self.highspeed_end_crossfade
	//it also takes into account the amount of roll (roll modifier)
	
	//try to have this based on speed, too	
	self.overall_pitch_roll_modifier = ( 1.0 - ( ( abs( self.audio_speed ) / 115.0 ) * ( abs( self.audio_roll ) / 35.0 ) * self.overall_pitch_roll_modifier_max ) );
	
	if ( abs( self.audio_speed ) < self.highspeed_end_crossfade )
		self.overall_pitch = ( self.overall_pitch_roll_modifier * ( ( ( abs( self.audio_speed ) / self.highspeed_end_crossfade ) * ( self.overall_pitch_max - self.overall_pitch_min ) ) + self.overall_pitch_min ) );
	else
		self.overall_pitch = ( self.overall_pitch_max * self.overall_pitch_roll_modifier );	
	
	/*
	//DR: SAVE THIS STUFF!
	//was trying out dynamically fading int he bank asset based on speed, so that slower speeds didn't sound like you were leaning so hard when you banked a little...
	//it's a work in progress...
	
	//if roll is greater than 15, lets say, then we turn up the bank sound and fade out the regular sound
	//there needs to be a volume multiplier for both the slow and fast regular sounds so they fade out
	//self.high_bank
	
	//now also adjust the roll crossfade values so they are affected by speed, 
	//meaning they should move higher when speed goes lower, and back to normal when speed goes up
	
	if (abs(self.audio_speed) > self.roll_crossfade_speed_max)
	{
		//set the values to the normal defaults at higher speeds
		self.new_roll_start_crossfade = self.roll_start_crossfade;
		self.new_roll_end_crossfade = self.roll_end_crossfade;
	}
	else
	{
		//the speed is below 50, see if it is greater than 30
		if (abs(self.audio_speed) > self.roll_crossfade_speed_min)
		{
			//the speed is between 30 and 50 - gonna slide the roll values down as you go faster
			//percentage speed between 30 and 50 inverse translate to percentage roll between 35 and the default start and ends
			//self.new_roll_start_crossfade = ( ( ( ( self.roll_crossfade_speed_max - abs(self.audio_speed) ) / self.roll_crossfade_speed_max - self.roll_crossfade_speed_min ) / ( self.roll_max_roll - self.roll_start_crossfade ) ) );
			
			//self.new_roll_end_crossfade = ( ( ( ( self.roll_crossfade_speed_max - abs(self.audio_speed) ) / self.roll_crossfade_speed_max - self.roll_crossfade_speed_min ) / ( self.roll_max_roll - self.roll_start_crossfade ) ) );					
			
			//self.new_roll_start_crossfade = self.roll_start_crossfade + ( ( ( self.roll_crossfade_speed_max - abs(self.audio_speed) ) / self.roll_crossfade_speed_max - self.roll_crossfade_speed_min ) * ( self.roll_max_roll - self.roll_start_crossfade ) );
			
			self.new_roll_start_crossfade = ( ( 1 - ( ( abs(self.audio_speed) - self.roll_crossfade_speed_min ) / ( self.roll_crossfade_speed_max - self.roll_crossfade_speed_min  ) ) ) * ( self.roll_max_roll - self.roll_start_crossfade ) ) + self.roll_start_crossfade;
			self.new_roll_end_crossfade = ( ( 1 - ( ( abs(self.audio_speed) - self.roll_crossfade_speed_min ) / ( self.roll_crossfade_speed_max - self.roll_crossfade_speed_min  ) ) ) * ( self.roll_max_roll - self.roll_end_crossfade ) ) + self.roll_end_crossfade;
		}
		else
		{
			//speed is below 30, set the roll values so the roll sound doesn't happen
			self.new_roll_start_crossfade = 35.01;
			self.new_roll_end_crossfade = 35.02;
		}		
	}
	
	//iprintln ("roll start = " + self.new_roll_start_crossfade); // + " - " + self.new_roll_end_crossfade );
	*/
		
}

adjust_helo_sound_low()
{			
	//this adjusts the volume and pitch of the low help sound based on the players speed
	
	if ( abs( self.audio_speed ) <= self.lowspeed_start_crossfade )
	{
		//if it is less than lowspeed_start_crossfade, make the multiplier 1.0	
		self.low_speed_mult = ( self.roll_other_mult * 1.0 );
	}
	else	
	{
		//if it is between the start and end crossfade values, multiply it by a linear fade value
		if ( abs( self.audio_speed ) < self.lowspeed_end_crossfade )
		{				
			self.low_speed_mult = ( self.roll_other_mult * ( 1.0 - ( ( abs( self.audio_speed ) - self.lowspeed_start_crossfade ) / ( self.lowspeed_end_crossfade - self.lowspeed_start_crossfade ) ) ) );
		}
		else
		{
			//doing nothing
			self.low_speed_mult = 0.005;
		}
	}
	
	//now update the pitch for this sound:
	self.audio_entities[ "low_front" ] ScalePitch( self.overall_pitch, 0.1 );
	self.audio_entities[ "low_rear" ] ScalePitch( self.overall_pitch, 0.1 );

	//now update the volume	for this sound:	
	self.audio_entities[ "low_front" ] ScaleVolume( self.low_speed_mult, 0.1 );
	self.audio_entities[ "low_rear" ] ScaleVolume( self.low_speed_mult, 0.1 );
	
}

adjust_helo_sound_high()
{	
	//this adjusts the volume and pitch of the low help sound based on the players speed
	
	if ( abs( self.audio_speed ) >= self.highspeed_end_crossfade )
	{
		//if it is more than the high speed end crossfade, make the multiplier 1.0	
		self.high_speed_mult = ( self.roll_other_mult * 1.0 );
	}
	else	
	{
		//if it is between the start and end crossfade values, multiply it by a linear fade value
		if ( abs( self.audio_speed ) > self.highspeed_start_crossfade )
		{	
			//check absolute value of speed....		
			self.high_speed_mult = ( self.roll_other_mult * ( 1.0 - ( ( self.highspeed_end_crossfade - abs( self.audio_speed ) ) / ( self.highspeed_end_crossfade - self.highspeed_start_crossfade ) ) ) );
		}
		else
		{
			//doing nothing
			self.high_speed_mult = 0.005;
		}
	}
	
	//now update the pitch for this sound:
	self.audio_entities[ "high_front" ] ScalePitch( self.overall_pitch, 0.1 );
	self.audio_entities[ "high_rear" ] ScalePitch( self.overall_pitch, 0.1 );	
	
	//now update the volume	for this sound:	
	self.audio_entities[ "high_front" ] ScaleVolume( self.high_speed_mult, 0.1 );
	self.audio_entities[ "high_rear" ] ScaleVolume( self.high_speed_mult, 0.1 );
	
}


adjust_helo_sound_roll()
{
	//test to see if we're in a roll, if so, then crossfade to the banking asset
			
	if ( abs( self.audio_roll ) >= self.roll_end_crossfade )
	{
		//if we are rolling more than the crossfade end value		
		//then all others should be 0.001 and this volume should be 1.0
		self.roll_mult = 1.0;
		self.roll_other_mult = 0.001;
	}
	else	
	{
		//see if we're in the roll crossfade area
		if ( abs( self.audio_roll ) >= self.roll_start_crossfade )
		{
			//yes we're between start and end crossfade on the roll - now figure out volumes for the bank and the regular loops
			//find out what percentage we are at, and make the volumes accordingly						
			self.roll_mult = ( 1.0 - ( ( self.roll_end_crossfade - abs(self.audio_roll) )  /  ( self.roll_end_crossfade - self.roll_start_crossfade ) ) );			
			self.roll_other_mult = (1.0 * ( ( self.roll_end_crossfade - abs(self.audio_roll) )  /  ( self.roll_end_crossfade - self.roll_start_crossfade ) ) ) ;
		}
		else
		{
			//we are not rolling enough to trigger the bank/roll sound to crossfade in
			self.roll_mult = 0.001;
			self.roll_other_mult = 1.0;			
		}	
	}
	
	//now update the pitch for this sound:
	self.audio_entities[ "high_bank_front" ] ScalePitch( self.overall_pitch, 0.1 );
	self.audio_entities[ "high_bank_rear" ] ScalePitch( self.overall_pitch, 0.1 );	
	
	//now update the volume	for this sound:	
	self.audio_entities[ "high_bank_front" ] ScaleVolume( self.roll_mult, 0.1 );
	self.audio_entities[ "high_bank_rear" ] ScaleVolume( self.roll_mult, 0.1 );
}
