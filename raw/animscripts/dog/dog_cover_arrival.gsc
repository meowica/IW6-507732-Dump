#using_animtree( "dog" );

main()
{
	self endon( "killanimscript" );

	self thread animscripts\dog\dog_move::HandleFootstepNotetracks();

	//self AnimMode( "zonly_physics" );
	self ClearAnim( %dog_move, 0.2 );

	self SetFlaggedAnimKnobAllRestart( "dog_stop", self.dogArrivalAnim, %body, 1, 0.2, self.movePlaybackRate );
	self animscripts\shared::DoNotetracks( "dog_stop" );

	self.dogArrivalAnim = undefined;
}
