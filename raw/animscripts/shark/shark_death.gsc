#using_animtree( "animals" );

main()
{
	self clearanim( %root, 0.2 );
	model = Spawn( "script_model", self.origin );
	model.angles = self.angles;
	model setModel( self.model );
	self Hide();
	//model MoveGravity( (0,0,0), 30 );
	model MoveGravity( (0,0,0), 30 );
	
	can_trace = true;
	
	model moveto(model.origin - (0,0,1000), 100, 0, 100);
	
	while (can_trace)
	{
		can_trace = BulletTracePassed (model.origin, model.origin - (0,0,10), true, self);
		wait 0.05;
	}
	
	model moveto(model.origin - (0,0,1), 1, 0, 1);
}