#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	info 					= SpawnStruct();
	info.targetname			= "interactive_oilrig_jumpsuit";
	info.name 				= "oilrig_jumpsuit";
	info.animtree			= #animtree;

	//Naming Anims depending on whether or not it's Single Player game
	if ( isSP() ) {
		info.anims[ "idle1" ]				= %oilrig_jumpsuit_idle1;
		info.anims[ "idle2" ]				= %oilrig_jumpsuit_idle2;
		info.anims[ "move_b_large" ]		= %oilrig_jumpsuit_move_b_large;
		info.anims[ "move_b_small" ]		= %oilrig_jumpsuit_move_b_small;
		info.anims[ "move_bl_large" ]		= %oilrig_jumpsuit_move_bl_large;
		info.anims[ "move_bl_small" ]		= %oilrig_jumpsuit_move_bl_small;
		info.anims[ "move_br_large" ]		= %oilrig_jumpsuit_move_br_large;
		info.anims[ "move_br_small" ]		= %oilrig_jumpsuit_move_br_small;
		info.anims[ "move_f_large" ]		= %oilrig_jumpsuit_move_f_large;
		info.anims[ "move_f_small" ]		= %oilrig_jumpsuit_move_f_small;
		info.anims[ "move_fl_large" ]		= %oilrig_jumpsuit_move_fl_large;
		info.anims[ "move_fl_small" ]		= %oilrig_jumpsuit_move_fl_small;
		info.anims[ "move_fr_large" ]		= %oilrig_jumpsuit_move_fr_large;
		info.anims[ "move_fr_small" ]		= %oilrig_jumpsuit_move_fr_small;
	} else {
		info.anims[ "idle1" ]				= "oilrig_jumpsuit_idle1";
		info.anims[ "idle2" ]				= "oilrig_jumpsuit_idle2";
		info.anims[ "move_b_large" ]		= "oilrig_jumpsuit_move_b_large";
		info.anims[ "move_b_small" ]		= "oilrig_jumpsuit_move_b_small";
		info.anims[ "move_bl_large" ]		= "oilrig_jumpsuit_move_bl_large";
		info.anims[ "move_bl_small" ]		= "oilrig_jumpsuit_move_bl_small";
		info.anims[ "move_br_large" ]		= "oilrig_jumpsuit_move_br_large";
		info.anims[ "move_br_small" ]		= "oilrig_jumpsuit_move_br_small";
		info.anims[ "move_f_large" ]		= "oilrig_jumpsuit_move_f_large";
		info.anims[ "move_f_small" ]		= "oilrig_jumpsuit_move_f_small";
		info.anims[ "move_fl_large" ]		= "oilrig_jumpsuit_move_fl_large";
		info.anims[ "move_fl_small" ]		= "oilrig_jumpsuit_move_fl_small";
		info.anims[ "move_fr_large" ]		= "oilrig_jumpsuit_move_fr_large";
		info.anims[ "move_fr_small" ]		= "oilrig_jumpsuit_move_fr_small";
	}

	//Gets anim length
	keys = GetArrayKeys( info.anims );
	foreach ( key in keys ) {
		info.animLengths[ key ] = GetAnimLength( info.anims[ key ] );
	}
	
	if ( !IsDefined ( level._interactive ) )
		level._interactive = [];
	level._interactive[ info.name ] = info;
	
	thread oilrig_jumpsuits( info );
}

oilrig_jumpsuits( info )
{
	level waittill ( "load_finished" );
	/#
		SetDevDvarIfUninitialized( "interactives_debug", 0 );
	#/
	if ( !IsDefined( level._interactive[ info.name+"_setup" ] ) ) {
		level._interactive[ info.name+"_setup" ] = true;
		jumpsuits = GetEntArray( info.targetname, "targetname" );
		foreach ( jumpsuit in jumpsuits ) {
			jumpsuit thread oilrig_jumpsuit( info );
		}
	}
}

oilrig_jumpsuit( info )
{
	level endon( "game_ended" );
	
	oilrig_jumpsuit_precache();
	
	hitbox = GetEnt( self.target, "targetname" );
	hitbox Hide();
	hitbox thread oilrig_jumpsuit_hitbox_onDamage( self );
	self thread oilrig_jumpsuit_onDamage( info.anims, info.animLengths );
}

oilrig_jumpsuit_precache( anims )
{	
	if ( !isSP() ) {
		foreach ( animName in anims ) {
			call [[ level.func[ "precacheMpAnim" ] ]]( animName );
		}
/*		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_idle1" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_idle2" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_b_large" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_b_large_lim18" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_b_large_rail" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_b_small" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_bl_large" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_bl_large_lim18" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_bl_large_rail" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_bl_small" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_br_large" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_br_large_lim18" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_br_large_rail" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_br_small" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_f_large" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_f_large_rail" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_f_small" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_fl_large" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_fl_large_rail" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_fl_small" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_fr_large" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_fr_large_rail" );
		call [[ level.func[ "precacheMpAnim" ] ]]( "oilrig_jumpsuit_move_fr_small" );
*/	}
//	PreCacheModel( "oilrig_jumpsuit" );
}

oilrig_jumpsuit_onDamage( anims, animLengths )
{
	level endon( "game_ended" );
	
	if ( IsDefined( level.func[ "useanimtree" ] ) )
		self call [[ level.func[ "useanimtree" ] ]]( #animtree );
		
	clearAnimFunc 	= ter_op( isSP(), level.func[ "clearanim" ], level.func[ "scriptModelClearAnim" ] );
	setAnimFunc		= ter_op( isSP(), level.func[ "setanim" ], level.func[ "scriptModelPlayAnim" ] );
		
	for ( ; ; )
	{
		strength 		= undefined;
		animIndex		= undefined;
		explosion_delay = undefined;
		distance_to_midpoint = undefined;
		
		//self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
		self waittill( "damage", damage, attacker, direction_vec, point, type );
		
		animIndex 	= "move_";
		yaw 		= self.angles[ 1 ];
		dirYaw		= AngleClamp( VectOrToYaw( direction_vec ) );
		 
		yawTolerance = 15;
		
		mag 		= ter_op( dirYaw - yaw > 0, 1, -1 );
		deltaYaw 	= dirYaw - yaw;
		deltaYaw 	= ter_op( abs( deltaYaw ) > 180, -1 * mag * ( 360 - abs( deltaYaw ) ), mag * abs( deltaYaw ) );
			
		// If damage is coming in FRONT
		if ( Abs( deltaYaw ) > 90 )
		{
			// move BACK RIGHT, damage from FRONT LEFT
			if ( deltaYaw > 0 && 180 - Abs( deltaYaw ) > yawTolerance )
				animIndex += "br";
			else
			// move BACK LEFT, damage from FRONT RIGHT
			if ( deltaYaw < 0 && 180 - Abs( deltaYaw ) > yawTolerance )
				animIndex += "bl";
			// move BACK
			else
				animIndex += "b";
		}
		else
		// If damage is coming from BEHIND
		if ( Abs( deltaYaw ) < 90 )
		{
			// move FRONT LEFT, damage from BACK RIGHT
			if ( deltaYaw < 0 && Abs( deltaYaw ) > yawTolerance )
				animIndex += "fl";
			else
			// move FRONT RIGHT, damage form BACK LEFT
			if ( deltaYaw > 0 && Abs( deltaYaw ) > yawTolerance )
				animIndex += "fr";
			// move FRONT
			else
				animIndex += "f";
		}
		
		strength = "small";
		explosion_delay = 0;	
		if ( IsDefined( type ) )
		{
			switch( type )
			{
				case "MOD_EXPLOSIVE":
				case "MOD_EXPLOSIVE_SPLASH":
				case "MOD_GRENADE":
				case "MOD_GRENADE_SPLASH":
					distance_to_midpoint = Length( direction_vec - ( 0, 0, 100 ) );	// The curtain origin is at the top
					explosion_delay = ( distance_to_midpoint - 50 ) / 400;
					explosion_delay = max( explosion_delay, 0 );
					if (explosion_delay > 1) explosion_delay = 0;	// direction_vec is being misreported for m203 explosions.
					if ( damage > 85 )	// This should probably be tuned more thoroughly but 85 works 
										// well for grenade explosions.
						strength = "large"; 
					break;
			}
		}		
		animIndex += "_" + strength ;
		
		if ( IsDefined (self.script_parameters) )
		{
			if ( IsDefined ( anims[ animIndex + "_" + self.script_parameters ] ) )
			{
				animIndex += "_" + self.script_parameters;
			}
		}
		
		wait ( explosion_delay );
		
		AssertEx ( IsDefined ( anims[ animIndex ] ), "Industrial curtain tried to call animation index that does not exist in anims: [" + animIndex +"]"  );
		
		if ( isSP() )
		{
			self call [[ clearAnimFunc ]]( anims[ "idle1" ], 0 );
			self call [[ clearAnimFunc ]]( anims[ "idle2" ], 0 );
		}
		else
			self call [[ clearAnimFunc ]]();
		
		if ( isSP() )
			self call [[ setAnimFunc ]]( anims[ animIndex ], 1, 0, 1 );
		else
			self call [[ setAnimFunc ]]( anims[ animIndex ] );
		
		yaw				= undefined;
		dirYaw			= undefined;
		yawTolerance	= undefined;
		mag				= undefined;
		deltaYaw		= undefined;
		
		damage 			= undefined;
		attacker 		= undefined;
		direction_vec 	= undefined; 
		point 			= undefined; 
		type 			= undefined; 
//		modelName 		= undefined; 
//		tagName 		= undefined; 
//		partName 		= undefined; 
//		dflags 			= undefined; 
//		weapon 			= undefined;

		wait animlengths[ animIndex ];
		
		if ( isSP() )
			self call [[ clearAnimFunc ]]( anims[ animIndex ], 0 );
		else
			self call [[ clearAnimFunc ]]();
		self thread oilrig_jumpsuit_playIdleAnim( anims, animLengths );
	}
}

oilrig_jumpsuit_playIdleAnim( anims, animLengths )
{
	
	level endon( "game_ended" );
	self endon( "damage" );
	
	clearAnimFunc 	= ter_op( isSP(), level.func[ "clearanim" ], level.func[ "scriptModelClearAnim" ] );
	setAnimFunc		= ter_op( isSP(), level.func[ "setanim" ], level.func[ "scriptModelPlayAnim" ] );
	
	randomCount = RandomIntRange( 1, 3 );

	for ( i = 0; i < randomCount; i++ )
	{
		if ( isSP() )
			self call [[ setAnimFunc ]]( anims[ "idle1" ], 1, 0, 1 );
		else
			self call [[ setAnimFunc ]]( anims[ "idle1" ] );
		wait animlengths[ "idle1" ];
		
		if ( isSP() )
			self call [[ clearAnimFunc ]]( anims[ "idle1" ], 0 );
		else
			self call [[ clearAnimFunc ]]();
	}
	
	if ( isSP() )
		self call [[ setAnimFunc ]](  anims[ "idle2" ], 1, 0, 1 );
	else
		self call [[ setAnimFunc ]](  anims[ "idle2" ] );
	wait animlengths[ "idle2" ];
	wait RandomFloat( 3 );
	
	if ( isSP() )
		self call [[ clearAnimFunc ]]( anims[ "idle2" ], 0 );
	else
		self call [[ clearAnimFunc ]]();
}

oilrig_jumpsuit_hitbox_onDamage( owner )
{
	level endon( "game_ended" );
	
	self SetCanDamage( true );
	
	for ( ; ; )
	{
		damage 			= undefined;
		attacker 		= undefined;
		direction_vec 	= undefined; 
		point 			= undefined; 
		type 			= undefined; 
//		modelName 		= undefined; 
//		tagName 		= undefined; 
//		partName 		= undefined; 
//		dflags 			= undefined; 
//		weapon 			= undefined;
		
		//self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
		self waittill( "damage", damage, attacker, direction_vec, point, type );
		owner notify( "damage", damage, attacker, direction_vec, point, type );
	}
}
