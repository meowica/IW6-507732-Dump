#include animscripts\utility;
#include animscripts\traverse\shared;

check_kill_traversal( traverseData )
{
	if( self.team != "allies" )
		return false;
	self endon( "killanimscript" );
	
	start_node = self getNegotiationStartNode();
	end_node = self getNegotiationEndNode();
	
	enemies = GetAIArray( "axis" );
	
	//If there are any enemies nearby the player, attack them as a priority.
	best_target = undefined;
	clump = dog_get_within_range( end_node.origin, enemies, 90 );
	if( clump.size > 0 )
	{
		victim = clump[ 0 ];
		dist_nodes2 = LengthSquared( start_node.origin - end_node.origin );
		dist_vic2 = LengthSquared( start_node.origin - victim.origin );

		if( dist_vic2 < dist_nodes2 )
		{
			self.syncedMeleeTarget2 = victim;
			victim.syncedMeleeTarget2 = self;
			victim.traverseData = traverseData;
			
			/#
//			IPrintLnBold( "Drawing enemies tag_sync for traversal kill");
		
//			victim thread draw_tag( "tag_sync" );
			#/
			//handle fx.
			fx = [];
			fx[0][0] = 400;
			fx[0][1] = "blood_small";
			fx[0][2] = "J_Neck";
			fx[1][0] = 2300;
			fx[1][1] = "blood_medium";
			fx[1][2] = "J_Neck";
			fx[2][0] = 2600;
			fx[2][1] = "blood_medium";
			fx[2][2] = "J_Neck";
			fx[3][0] = 3300;
			fx[3][1] = "blood_heavy";
			fx[3][2] = "J_Neck";

			victim thread monitorfx( fx );
			
			
			victim  animcustom( ::human_traverse_kill );
			self OrientMode( "face angle", start_node.angles[ 1 ] );
			dog_traverse_kill( traverseData );
			return true;
		}
	}
	return false;

}





dog_get_within_range( org, array, dist )
{
	guys = [];
	for ( i = 0; i < array.size; i++ )
	{
		if ( Distance( array[ i ].origin, org ) <= dist )
			guys[ guys.size ] = array[ i ];
	}
	return guys;
}

#using_animtree( "dog" );

dog_traverse_kill( traverseData )
{
	self.safeToChangeScript = false;
	self.orig_flashBangImmunity = self.flashBangImmunity;
	self.flashBangImmunity = true;
	self.pushable = false;
	self traverseMode( "nogravity" );
	self traverseMode( "noclip" );
	self clearpitchorient();
	self setcandamage( false );

	self clearanim( %body, 0.1 );
	
	self setflaggedanimrestart( "dog_traverse", level.scr_anim[ "generic" ][ traverseData[ "traverseAnim" ]][0], 1, 0.2, 1 );
	self animscripts\shared::DoNoteTracks( "dog_traverse" );
	
	self Unlink();
	self setcandamage( true );
	self traverseMode( "gravity" );
	self.pushable = true;
	self.safeToChangeScript = true;
	self.flashBangImmunity = self.orig_flashBangImmunity;
}

#using_animtree( "generic_human" );
//little blood at 400 loads at 3300.
human_traverse_kill()
{
	self endon( "killanimscript" );
	self endon( "death" );

	self OrientMode( "face point", self.syncedMeleeTarget2.origin, 1 );
	self animMode( "nogravity" );

	self.a.pose = "stand";
	self.a.special = "none";

	if ( usingSidearm() )
		self animscripts\shared::placeWeaponOn( self.primaryweapon, "right" );

	self clearanim( %body, 0.1 );

	self setflaggedanimrestart( "aianim", level.scr_anim[ "generic" ][ self.traverseData[ "traverseAnim" ]][1], 1, 0.1, 1 );
	if( IsDefined( self.traverseData[ "linkMe" ] ) )
	{
		thread dog_link();
	}
	
	self animscripts\shared::DoNoteTracks( "aianim" );

	self waittillmatch( "aianim", "end" );
	
	if ( IsAlive( self ) &&  !isdefined( self.magic_bullet_shield ) )
	{
		self.a.nodeath = true;
		self animscripts\shared::DropAllAIWeapons();
		self kill();
	}

}

dog_alt_combat_check()
{
	if(  self.enemy.a.special == "dying_crawl" )
	{
		last_stand_dog_takedown();
		return true;
	}
	if( do_dog_quick_kill() )
	{
		return true;	
	}
	return false;	
}

last_stand_dog_takedown()
{
	//250 1500 2400
	kill_data = [];
	kill_data[ "killAnim" ] = "dog_last_stand_kill";
	kill_data[ "linkMe" ] = "1";
	self.syncedMeleeTarget2 = self.enemy;
	self.enemy.syncedMeleeTarget2 = self;
	self.enemy.kill_data = kill_data;
	
	self.enemy animcustom( ::human_anim_kill );
	self OrientMode( "face default" );
	self traverseMode( "nogravity" );
	self traverseMode( "noclip" );

	fx = [];
	fx[0][0] = 250;
	fx[0][1] = "blood_small";
	fx[0][2] = "J_Wrist_RI";
	fx[1][0] = 1500;
	fx[1][1] = "blood_medium";
	fx[1][2] = "J_Neck";
	fx[2][0] = 2200;
	fx[2][1] = "blood_heavy";
	fx[2][2] = "J_Neck";

	self.enemy thread monitorfx( fx );

	self dog_anim_kill( kill_data );
	self TraverseMode( "gravity" );
	self Unlink();
}

//little blood at 1000, loads at 2000.
do_dog_quick_kill()
{
	if( IsDefined( self.force_quick_kill ) && self.force_quick_kill == false )
	{
		self.enemy.syncedMeleeTarget2 = self;
		self.force_quick_kill = undefined;
		return false;
	}
	
	if( IsDefined( self.force_quick_kill ) || ( RandomInt( 100 ) > 50 ) )
	{
		self.force_quick_kill = undefined;
		kill_data = [];
		kill_data[ "killAnim" ] = "dog_attack_fast";
		kill_data[ "start_enemy_offset" ] = 0;
		          
		kill_data[ "linkMe" ] = "1";
		
		
				//handle fx.
			fx = [];
			fx[0][0] = 1000;
			fx[0][1] = "blood_small";
			fx[0][2] = "J_Neck";
			fx[1][0] = 2000;
			fx[1][1] = "blood_heavy";
			fx[1][2] = "J_Neck";
			/*
			blood_head_kick" 
			blood_hyena_bite"
			blood_throat_stab
			*/
			self.enemy thread monitorfx( fx );

	
		self.syncedMeleeTarget2 = self.enemy;
		self.enemy.syncedMeleeTarget2 = self;
		self.enemy.kill_data = kill_data;
		
		self.enemy animcustom( ::human_anim_kill );
		self OrientMode( "face default" );
		self dog_anim_kill( kill_data );
		self Unlink();
	
		return true;
	}
		/#
		self.enemy.syncedMeleeTarget2 = self;
//		IPrintLnBold( "Drawing enemies tag_sync from IW Animation");
		
//		self.enemy thread draw_tag( "tag_sync" );
		#/

	return false;
}

calc_offset( kill_data )
{
	offset = self.enemy.origin;
	if( IsDefined( kill_data[ "start_enemy_offset" ] ) )
	{
		vec_to = self.origin - self.enemy.origin;
		vec_to = VectorNormalize( vec_to );
		vec_to = vec_to * kill_data[ "start_enemy_offset" ] ;
		offset = self.enemy.origin + vec_to;
	}
/#
//	draw = offset + ( 0,0,45);
//	thread draw_loc( self.angles, offset, 5 );
#/
	return offset;
}
#using_animtree( "dog" );

dog_anim_kill( kill_data )
{
	self.safeToChangeScript = false;
	self.orig_flashBangImmunity = self.flashBangImmunity;
	self.flashBangImmunity = true;
//	self animMode( "nogravity" );
	self animMode( "zonly_physics" );
	self.pushable = false;
	self clearpitchorient();
	self setcandamage( false );

	angles = vectorToAngles( self.origin - self.enemy.origin );
	angles = (0, angles[1], 0);

	
	self clearanim( %body, 0.1 );
	offset = calc_offset( kill_data );
	self animrelative( "meleeanim", offset, angles, level.scr_anim[ "generic" ][ kill_data[ "killAnim" ]][0] );
	self animscripts\shared::DoNoteTracks( "meleeanim");

	self animMode( "none" );
	self setcandamage( true );
	self.pushable = true;
	self.safeToChangeScript = true;
	self.flashBangImmunity = self.orig_flashBangImmunity;
}


#using_animtree( "generic_human" );

human_anim_kill( kill_data )
{
	self endon( "killanimscript" );
	self endon( "death" );

	self OrientMode( "face point", self.syncedMeleeTarget2.origin, 1 );
	//self animMode( "gravity" );
	self animMode( "zonly_physics" );

	self.a.special = "none";

//	if ( usingSidearm() )
//		self animscripts\shared::placeWeaponOn( self.primaryweapon, "right" );

	self clearanim( %body, 0.1 );
	
	self.dogAttackAllowTime = gettime() + 10000;// he is going to die- make sure no one else tries to attack him.
	
	
		
	self setflaggedanimrestart( "aianim", level.scr_anim[ "generic" ][ self.kill_data[ "killAnim" ]][1], 1, 0.1, 1 );
	if( IsDefined( self.kill_data[ "linkMe" ] ) )
	{
		thread dog_link();
	}
	self animscripts\shared::DoNoteTracks( "aianim" );

	self waittillmatch( "aianim", "end" );
	
	if ( IsAlive( self ) &&  !isdefined( self.magic_bullet_shield ) )
	{
		self.a.nodeath = true;
		self animscripts\shared::DropAllAIWeapons();
		self kill();
	}
}
monitorfx( fx )
{
	self endon( "death" );
	fx_num = 0;
	start_time = GetTime();
	while( fx_num < fx.size )
	{
		anim_time = GetTime() - start_time;
		if( anim_time >= fx[fx_num][0] )
		{
			PlayFXOnTag( level._effect[ fx[fx_num][1] ], self, fx[fx_num][2] );
//			IPrintLnBold( "FX: " + fx[fx_num][1] + " at " +anim_time );
//			thread draw_tag( fx[fx_num][2] );
			fx_num++;
		}
		wait 0.05;
	}
}
dog_link()
{
	self thread draw_tag( "tag_sync" );
	wait 0.15;// also wait a bit before tag_sync in AI animation to settle to right spot
	self.syncedMeleeTarget2 linkto( self, "tag_sync", ( 0, 0, 0 ), ( 0, 0, 0 ) );
}

draw_tag( tagname )
{
	self endon( "death" );
//	start = GetTime();
	
	
	
	while ( 1 )
	{
//		time = GetTime() - start;
//		IPrintLn( "anim time: " + time );
		angles = self gettagangles( tagname );	
		origin = self gettagorigin( tagname );
//		draw_orient( angles, origin );
		wait 0.05;
	}
}

draw_loc( angles, origin, duration )
{

	self endon( "death" );
	//IPrintLnBold(" started drawing loc " + origin);
	end_time = 0;
	while ( end_time < 100 )
	{
		draw_orient( angles, origin );
		end_time++;
		wait 0.05;
	}
	//IPrintLnBold(" finished drawing loc");
	
}

draw_orient( angles, origin )
{
	range = 25;
	forward = anglestoforward( angles );
	forward = forward * range;
	right = anglestoright( angles );
	right =  right * range ;
	up = anglestoup( angles );
	up = up * range;
	line( origin, origin + forward, ( 1, 0, 0 ), 1 );
	line( origin, origin + up, ( 0, 1, 0 ), 1 );
	line( origin, origin + right, ( 0, 0, 1 ), 1 );
}
