#include animscripts\utility;
#include maps\_utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

// Special traverse logic just for Space movement
DoSpaceTraverse( traverseData )
{
 	self endon( "killanimscript" );

	// do not do code prone in this script
	self.desired_anim_pose = "stand";
	animscripts\utility::UpdateAnimPose();

	// orient to the Negotiation start node
    startnode = self getNegotiationStartNode();
 	endNode = self getNegotiationEndNode();

    assert( isDefined( startnode ) );
    assert( isDefined( endNode ) );

    //self OrientMode( "face angle", startnode.angles[ 1 ] );

	self.traverseHeight = traverseData[ "traverseHeight" ];
	self.traverseStartNode = startnode;

	traverseAnim = traverseData[ "traverseAnim" ];
	traverseToCoverAnim = traverseData[ "traverseToCoverAnim" ];  // traversals that end up with 180-degree spins into cover at the end

	self traverseMode( "nogravity" );
	self traverseMode( "noclip" );

	/*
	self.traverseStartZ = self.origin[ 2 ];
	if ( !animHasNotetrack( traverseAnim, "traverse_align" ) )
	{
		 /# println( "^1Warning: animation ", traverseAnim, " has no traverse_align notetrack" ); #/
		self handleTraverseAlignment();
	}
	*/

	toCover = false;
	/*
	if ( isDefined( traverseToCoverAnim ) && isDefined( self.node ) && self.node.type == traverseData[ "coverType" ] && distanceSquared( self.node.origin, endNode.origin ) < 25 * 25 )
	{
		if ( AbsAngleClamp180( self.node.angles[ 1 ] - endNode.angles[ 1 ] ) > 160 )
		{
			toCover = true;
			traverseAnim = traverseToCoverAnim;
		}
	}
	*/

	/*
	if ( toCover )
	{
		if ( isdefined( traverseData[ "traverseToCoverSound" ] ) )
		{
			self thread play_sound_on_entity( traverseData[ "traverseToCoverSound" ] );
		}
	}
	else
	{
		if ( isdefined( traverseData[ "traverseSound" ] ) )
		{
			self thread play_sound_on_entity( traverseData[ "traverseSound" ] );
		}
	}
	*/
	self.traverseAnim = traverseAnim;
	self.traverseAnimRoot = %root;
	self setFlaggedAnimKnoballRestart( "traverseAnim", traverseAnim, %root, 1, .2, 1 );

	self.traverseDeathIndex = 0;
	self.traverseDeathAnim = traverseData[ "interruptDeathAnim" ];
	self animscripts\shared::DoNoteTracks( "traverseAnim", ::handleTraverseNotetracks );
	//self traverseMode( "gravity" );
	iprintlnbold( "after notetracks" );

	/*
	if ( self.delayedDeath )
		return;

	self.a.nodeath = false;
	if ( toCover && isDefined( self.node ) && distanceSquared( self.origin, self.node.origin ) < 16 * 16 )
	{
		self.a.movement = "stop";
		self teleport( self.node.origin );
		iprintlnbold( "teleport" );
	}
	else if( IsDefined( traverseData[ "traverseStopsAtEnd" ] ) )
	{
		self.a.movement = "stop";
	}
	else
	{
		self.a.movement = "run";
		//self setAnimKnobAllRestart( animscripts\run::GetRunAnim(), %body, 1, 0.0, 1 );
		self clearanim( traverseAnim, 0.2 );
	}
	*/
	
	self.traverseAnimRoot = undefined;
	self.traverseAnim = undefined;
	self.deathAnim = undefined;
}