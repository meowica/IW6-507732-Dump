//#include maps\interactive_models\_interactive_utility;
#include common_scripts\_destructible;
#using_animtree( "destructibles" );

// MP: Trash can whose lid blows off when shot.
// SP: Trash can that falls over as a dynent, then loses its lid when it hits the ground.
// Although this is called "Destructible" it's scripted almost entirely outside the destructible system.
main()
{
	if( common_scripts\utility::isSP() )
	{
		destructible_create( "toy_lv_trash_can_vegas", "tag_origin", 0 );
			destructible_function( ::lv_trash_can_vegas );
		main_sp();
	}
	else
	{
		destructible_create( "toy_lv_trash_can_vegas", "tag_origin", 0 );
			destructible_state( "tag_origin", undefined, 100 );
//				destructible_damage_threshold( 99 );	// Ignore smaller amounts of damage than this
		destructible_part( "tag_lid", "lv_trash_can_vegas_lid", 50 );
				destructible_physics( "tag_lid", (20,0,0) );
			destructible_state( undefined );
	}
}

// I was attaching the lid to the destructible this way, but the HidePart(tagName) code function needs to know 
// the name of the attached model, which would require me to modify the destructible system to store the name 
// and pass it through.  Not worth the effort at this stage.
AttachLid()
{
	self Attach( "lv_trash_can_vegas_lid", "tag_lid" );
}

// Once-off info, shared between all instances of this model.
main_sp()
{
	// I'm duplicating a lot of the functionality of a destructible here.  I can't use a regular destructible because 
	// I have to re-spawn the physics ent every time it gets shot, and the destructible system relies on the ent 
	// remaining in existence.  I have to re-spawn the physics ent in order to push it for each impact, because 
	// server-side physics ents don't react to bullets.
	info = SpawnStruct();

	info.parts = [];
	
	info.parts[0] = SpawnStruct();
	info.parts[0].states = [];
	info.parts[0].states[0] = SpawnStruct();
	info.parts[0].states[0].model = undefined;		// Use the model is already has
	info.parts[0].states[0].health = undefined;		// Undefined == infinite health
	info.parts[0].states[0].damageCallback[0] = ::ServerPhysicsObj;				// To do the server physics thread
	info.parts[0].states[0].damageCallback[1] = ::lv_trash_can_vegas_hitFloor;	// To deal damage when it hits the floor

	info.parts[0].states[1] = SpawnStruct();		// Since state 0 has undefined health, state 1 can only be reached by magic.  In this case I'll force it when the trash can falls over.
	info.parts[0].states[1].model = undefined;		// Use the model is already has
	info.parts[0].states[1].health = undefined;		// Undefined == infinite health
	info.parts[0].states[1].FX = [];
	info.parts[0].states[1].FXTags = [];
	info.parts[0].states[1].FX[0] = LoadFX( "fx/props/trash_bottles" );
	info.parts[0].states[1].FXTags[0] = "tag_fx";
	info.parts[0].states[1].FX[1] = LoadFX( "fx/misc/trash_spiral_runner" );	// This is a little dust storm with paper in it, might be fun to have to show up after the trash spills out.
	info.parts[0].states[1].FXTags[1] = "tag_fx";
	info.parts[0].states[1].sound = "exp_trashcan_sweet";
	info.parts[0].states[1].soundTag = "tag_fx";
	
	info.parts[1] = SpawnStruct();
	info.parts[1].tag = "tag_lid";
	info.parts[1].parent = 0;						// Set the parts up in a tree structure.
	info.parts[1].alsoDamageParent = 1;
	info.parts[1].states = [];
	info.parts[1].states[0] = SpawnStruct();
	info.parts[1].states[0].model = undefined;		// No model until after it's damaged.  Besides, I haven't written support for attached models yet.
	info.parts[1].states[0].showTag = true;
	info.parts[1].states[0].health = 50;
	
	info.parts[1].states[1] = SpawnStruct();		// Second state
	info.parts[1].states[1].physicsModel = "lv_trash_can_vegas_lid";
	info.parts[1].states[1].physicsPush = ( 0,0,2000 );	// Added to the impact from bullet or grenade.  I don't understand why it needs to be so large...
	info.parts[1].states[1].physicsMultiply = 3;	// Multiply the push given by bullets or grenade, so it is pushed further.
	info.parts[1].states[1].physicsDefaultDamagePush = ( 0,0,0 );	// Used if no damage impact is found
	info.parts[1].states[1].health = undefined;
	
	// These variables are only used by the custom lv_trash_can_vegas_hitFloor() function.
	// Define a sphere at the top that we use to detect when the trash can is tipped over.
	info.impactTag = "tag_lid";
	info.impactRadius = 15;
	// When it hits the floor, we want both parts to go to a particular state.  
	info.parts[0].hitFloorState = 1;
	info.parts[1].hitFloorState = 1;

	if ( !IsDefined ( level._interactive ) )
		level._interactive = [];
	level._interactive[ "lv_trash_can_vegas" ] = info;
	//thread interactive_fall_and_break();	// This is now handled by a destructible_function() call

}

lv_trash_can_vegas()
{
	objTracker = SpawnStruct();
	objTracker.obj = self;
	objTracker.type = "lv_trash_can_vegas";
	interactive_fall_and_break( objTracker );
}

interactive_fall_and_break( objTracker )
{
	// This system uses a struct called objTracker to keep track of each entity.  This is the reason it's 
	// separate from the regular destructibles system.  In order to fall and break, the item must use 
	// server-side physics.  Server-side physics don't respond to bullets, so each time the object is shot, 
	// it's deleted and a new object is spawned.  Thus we need a pointer to the object.
	
	info = level._interactive[ objTracker.type ];
	
	objTracker.partStates = [];
	objTracker.partHealths = [];
	for ( i=0; i < info.parts.size; i++ )
	{
		objTracker.partStates[i] = 0;
		objTracker.partHealths[i] = info.parts[i].states[0].health;
	}

	// Precache.
	foreach ( part in info.parts ) foreach (state in part.states ) 
	{
		if ( IsDefined( state.model ) )
			precacheModel( state.model );
		if ( IsDefined( state.physicsModel ) )
			precacheModel( state.physicsModel );
	}
	
	// Check for valid values
	foreach ( part in info.parts )
	{
		if ( IsDefined( part.alsoDamageParent ) ) Assert( IsDefined( part.parent ) );
	}
	
	// Wait for damage.
	while(1)
	{
		objTracker.obj waittill( "damage", amount, attacker, direction, point, type, modelNameBullshit, tagNameBullshit, partName );
		type = destructible_ModifyDamageType( type );
		amount = destructible_ModifyDamageAmount( amount, type, attacker );

		if ( isDefined( partName ) )
		{
			partIndex = FandB_FindPartIndex( objTracker.type, partName );
		}
		else
		{
			partIndex = 0;
		}
		FandB_DoDamage( objTracker, partIndex, amount, attacker, direction, point, type );
	}
}

// This emulates what _destructible.gsc does to the "type" it gets from damage
destructible_ModifyDamageType( type )
{
	newType = getDamageType( type );	// Simplify the type into a few categories
	Assert( IsDefined( newType ) );
	return newType;
}

// These are (HACK!) just copied from _destructible.gsc.  Ultimately, I'd like to find a way to reference them instead.
SP_DAMAGE_BIAS = 0.5;
SP_EXPLOSIVE_DAMAGE_BIAS = 9.0;

MP_DAMAGE_BIAS = 1.0;
MP_EXPLOSIVE_DAMAGE_BIAS = 13.0;

SP_SHOTGUN_BIAS = 8.0;
MP_SHOTGUN_BIAS = 4.0;

// This emulates what _destructible.gsc does to the amount of damage
destructible_ModifyDamageAmount( damage, type, attacker )
{
	if ( common_scripts\utility::isSP() )
		damage *= SP_DAMAGE_BIAS;
	else
		damage *= MP_DAMAGE_BIAS;
	
	assert ( damage >= 0 );
	
	if ( is_shotgun_damage( attacker, type ) )
	{
		if ( common_scripts\utility::isSP() )
			damage *= SP_SHOTGUN_BIAS;
		else
			damage *= MP_SHOTGUN_BIAS;
	}
	if ( type == "splash" )
	{
		if ( common_scripts\utility::isSP() )
			damage *= SP_EXPLOSIVE_DAMAGE_BIAS;
		else
			damage *= MP_EXPLOSIVE_DAMAGE_BIAS;
	}
	return damage;
}



/*
=============
///ScriptDocBegin
"Name: FandB_DoDamage( <objTracker> , <partIndex> , <indexToIgnore> )"
"Summary: Fall and Break worker function.  Removes the health from the part."
"Module: Entity"
"CallOn: nothing"
"MandatoryArg: <objTracker>: Pointer to the object that is being damaged."
"MandatoryArg: <partIndex>: Index to the part we want to remvoe health from."
"MandatoryArg: <amount>: Amount of damage to do."
"MandatoryArg: <attacker>: Attacker, as supplied by waittill( "damage" )"
"MandatoryArg: <direction>: Direction of damage, as supplied by waittill( "damage" )"
"MandatoryArg: <point>: Point at which damage was done, as supplied by waittill( "damage" )"
"MandatoryArg: <type>: Type of damage, as supplied by waittill( "damage" )"
"OptionalArg: <indexToIgnore>: Index of the part this fn was called from, if any.  This prevents damage from being bounced around indefinitely."
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

FandB_DoDamage( objTracker, hitPartIndex, amount, attacker, direction, point, type, indexToIgnore )
{
	// If it's splash damage, we need to damage all parts
	if ( type == "splash" )
	{
		partIndexList = [];
		for ( i = 0; i < level._interactive[ objTracker.type ].parts.size; i++ )
			partIndexList[i] = i;
	}
	else	// If not splash damage, only damage the single part that was hit
	{
		partIndexList = [];
		partIndexList[0] = hitPartIndex;
	}
	
	foreach ( partIndex in partIndexList )
	{
		infoPart = level._interactive[ objTracker.type ].parts[partIndex];
		remainingDamage = amount;
		while ( ( remainingDamage > 0 ) && ( IsDefined( infoPart.states[ objTracker.partStates[partIndex] ] ) ) )
		{
			// Check for damage callback function.
			if ( IsDefined( infoPart.states[objTracker.partStates[partIndex]].damageCallback ) )
			{
				foreach ( damageCallback in infoPart.states[objTracker.partStates[partIndex]].damageCallback )
				    objTracker [[damageCallback]]( amount, attacker, direction, point, type );
			}
			
			// Apply the damage
			if ( IsDefined( objTracker.partHealths[partIndex] ) )
			{
				objTracker.partHealths[partIndex] -= remainingDamage;
			
				// Check for state transition
				if ( objTracker.partHealths[partIndex] < 0 )
				{
					remainingDamage = -1 * objTracker.partHealths[partIndex];
					objTracker FandB_GoToState( partIndex, objTracker.partStates[partIndex]+1, amount, attacker, point, direction, type );
				}
				else // This state absorbed all the damage.
					remainingDamage = 0;
			}
			else	// Undefined health means infinite health.
				remainingDamage = 0;
		}
		
		// Transmit damage to parent and children
		if ( ( type != "splash" )	&&
			( IsDefined( infoPart.alsoDamageParent ) && infoPart.alsoDamageParent > 0  ) &&
		    ( !isDefined( indexToIgnore ) || infoPart.parent != indexToIgnore )
		   )
		{
			FandB_DoDamage( objTracker, infoPart.parent, amount * infoPart.alsoDamageParent, attacker, direction, point, type, partIndex );
		}
		// Eventually I intend to cycle through all parts here, and if they have the receiveDamageFromParent value and they are children of current part, damage them too.
	}
}

FandB_GoToState( partIndex, stateIndex, amount, attacker, point, direction, type )
{
	infoPart = level._interactive[ self.type ].parts[partIndex];
	prevState = self.partStates[partIndex];
	self.partStates[partIndex] = stateIndex;
	stateChanged = ( prevState != stateIndex );
	if ( IsDefined( infoPart.states[ self.partStates[partIndex] ] ) )
	{
		
		// Some stuff only happens on a state transition, so suppress it it we're just creating a model that's already in this state
		if ( stateChanged )
		{
			self.partHealths[partIndex] = infoPart.states[ self.partStates[partIndex] ].health;
			infoState = infoPart.states[self.partStates[partIndex]];
			if ( IsDefined( amount ) ) amount *= infoState.physicsMultiply;
			self.obj FandB_ThrowPhysicsModel( infoState.physicsModel, infoPart.tag, infoState.physicsPush, infoState.physicsDefaultDamagePush, amount, point, direction );
			self.obj FandB_FX( infoState.FX, infoState.FXTags );
			self.obj FandB_PlaySound( infoState.sound, infoState.soundTag );
			// Also explosions, one-off sounds.
		}
		// Other stuff is necessary whenever we're in this state.
		self.obj FandB_HideShowTag( infoPart.states[self.partStates[partIndex]].showTag, infoPart.tag );
		// Also looping FX, looping sounds, clip brushes.
	}
}

// Note: All parameters are optional, but modelname is only required if the tag has a model attached to it.
FandB_HideShowTag( showTag, tag, modelname )
{
	if ( IsDefined( tag ) )
	{
		if ( IsDefined( showTag ) && showTag )
		{
			if ( IsDefined( modelname ) )
			{
				self ShowPart( tag, modelname );
			}
			else
			{
				self ShowPart( tag );
			}
		}
		else
		{
			if ( IsDefined( modelname ) )
			{
				self HidePart( tag, modelname );
			}
			else
			{
				self HidePart( tag );
			}
		}
	}
}

FandB_ThrowPhysicsModel( physicsModel, tag, extraPush, defaultDamagePush, amount, point, direction )
{
	if ( IsDefined( physicsModel ) )
	{
		physEnt = Spawn( "script_model", self GetTagOrigin( tag ) );
		physEnt.angles = self GetTagAngles( tag );
		/#physEnt.targetname = physicsModel + " (thrown by physics)";#/	// To make it easy to identify in g_entinfo
		physEnt SetModel( physicsModel );
		if ( IsDefined( point ) )
			pushPoint = point;
		else
			pushPoint = physEnt.origin;
		if ( ( !IsDefined( direction ) || !IsDefined( amount ) ) && ( IsDefined( defaultDamagePush ) ) )
		{
			push = defaultDamagePush;
		}
		else
			push = (0,0,0);
		if ( IsDefined( extraPush ) )
		{
			push += extraPush;
			pushPoint = ( pushPoint + physEnt.origin ) / 2;	// We could do a physically correct moment calculation, but let's just average the position for now
		}
		// Change from tag space to world space
		pushF = push[0] * AnglesToForward( physEnt.angles );
		pushR = push[1] * AnglesToRight( physEnt.angles );
		pushU = push[2] * AnglesToUp( physEnt.angles );
		push = pushF + pushR + pushU;
		// Now add push from damage (which is already in world space)
		if ( IsDefined( direction ) && IsDefined( amount ) )
			push += direction * amount;
		physEnt PhysicsLaunchClient( pushPoint, push );
	}					
}

FandB_FX( FXArray, TagArray )
{
	if ( IsDefined( FXArray ) )
	{
		for ( i = 0; i < FXArray.size; i++ )
		{
			// Because I keep deleting and recreating models, I can't just play the FX on a tag.  Sad.
			tagOrigin  = self GetTagOrigin( TagArray[ i ] );
			tagAngles  = self GetTagAngles( TagArray[ i ] );
			tagForward = AnglesToForward( tagAngles );
			tagUp	   = AnglesToUp( tagAngles );
			PlayFX( FXArray[ i ], tagOrigin, tagForward, tagUp );
		}
	}
}

FandB_PlaySound( soundAlias, tag )
{
	if ( IsDefined( soundAlias ) )
	{
		thread common_scripts\_destructible::play_sound( soundAlias, tag );
	}
}

FandB_FindPartIndex( interactive_type, partName )
{
	info = level._interactive[ interactive_type ];
	for ( i=0; i< info.parts.size; i++ )
	{
		if ( IsDefined( info.parts[i].tag ) && info.parts[i].tag == partName )
			return i;
	}
	// This probably means either that the tag isn't listed in the parts for the model, or that the damage is 
	// splash damage. Either way, just return the root.
	return 0;
}

// Responds to damage by spawning a new server physics object, because server physics objects don't resond to damage
// (or maybe they just stop being physics objects as soon as they stop moving.)  Uses the struct objTracker as a 
// pointer to the current instance of the object, since it keeps changing.
ServerPhysicsObj( amount, attacker, direction, point, type )
{
	newEnt = Spawn( "script_model", self.obj.origin );
	newEnt.angles = self.obj.angles;
	newEnt SetModel( self.obj.model );
	direction = VectorNormalize( direction );	// Grenade damage direction is not normalized by default
	if ( type != "splash" )	amount *= 10;		// Scale up force so behavior more closely matches client-side physics objects
	else amount *= 2;
	newEnt PhysicsLaunchServer( point, amount*direction );
	self.obj Delete();
	self.obj = newEnt;
	self.obj SetCanDamage( true );
	
	// Set the correct state
	for ( partIndex = 0; partIndex < level._interactive[ self.type ].parts.size; partIndex++ )
	{
		self FandB_GoToState( partIndex, self.partStates[partIndex] );
	}
}

// Monitors the object to see if it has hit to floor yet, and when it does, spawns models and effects.
lv_trash_can_vegas_hitFloor( amount, attacker, direction, point, type )
{
	if ( !IsDefined( self.startedFallMonitor ) )
	{
		self.startedFallMonitor = true;
		self thread lv_trash_can_vegas_hitFloor_internal();
	}
}
lv_trash_can_vegas_hitFloor_internal()
{
	info = level._interactive[ "lv_trash_can_vegas" ];

	groundHeight = self.obj.origin[2];
	impactCheckPos = self.obj GetTagOrigin( info.impactTag );
	while ( impactCheckPos[2] - groundHeight > info.impactRadius )
	{
		// TODO Add a timeout or something here, in case the trash can is shot but never knocked over
		wait ( 0.05 );
		impactCheckPos = self.obj GetTagOrigin( info.impactTag );
	}
	
	newEnt = Spawn( "script_model", self.obj.origin );
	newEnt.angles = self.obj.angles;
	newEnt SetModel( self.obj.model );
	newEnt PhysicsLaunchClient( );
	self.obj Delete();
	self.obj = newEnt;
	self.obj SetCanDamage( true );
	
	// Set the correct state.
	for ( partIndex = 0; partIndex < info.parts.size; partIndex++ )
	{
		self FandB_GoToState( partIndex, info.parts[partIndex].hitFloorState );
	}
}