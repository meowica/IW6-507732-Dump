#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;

enable_wounded_ai()
{
	
	if( isdefined( self.wounded_ai ) )
		return;
	
	self disable_turnAnims();
	self disable_surprise();
	
	//self disable_arrivals();
	//self disable_exits();
	
	//self.animArchetype 					= "wounded_ai";
	self.wounded_ai						= true;
	self.no_pistol_switch				= true;
	self.ignoresuppression				= true;
	
	self.dontmelee 						= true;
	self.noRunReload					= true;
	self.ammoCheatInterval				= 2000;
	self.disableBulletWhizbyReaction	= true;
	self.useChokePoints					= false;
	self.disableDoorBehavior			= true;
	self.combatmode						= "no_cover";
	self.oldgrenadeawareness			= self.grenadeawareness;
	self.grenadeawareness				= 0;
	self.oldGrenadeReturnThrow			= self.noGrenadeReturnThrow;
	self.noGrenadeReturnThrow			= true;
	
	//self SetEngagementMinDist( 300, 200 );
	//self SetEngagementMaxDist( 600, 800 );
	
	self init_wounded_ai_animset();

	self.a.pose = "stand";
	self allowedStances( "stand" );
	//self set_casual_killer_run_n_gun();

	//self.customMoveTransition = ::wounded_ai_startMoveTransition;
//	self.permanentCustomMoveTransition = true;
////
//	self.approachTypeFunc = ::wounded_ai_approach_type;
//	self.approachConditionCheckFunc = ::wounded_ai_approach_conditions;
//	self.disableCoverArrivalsOnly = true;
	
}

disable_hurt_ai()
{
	if( !isdefined( self.wounded_ai ) )
		return;
		
	self enable_turnAnims();
		
	self.wounded_ai 					= undefined;		
	self.no_pistol_switch 				= undefined;
	self.ignoresuppression 				= false;
	self.maxFaceEnemyDist 				= 512;
	self.noRunReload 					= undefined;
	self.disableBulletWhizbyReaction 	= undefined;
	self.useChokePoints 				= true;
	self.disableDoorBehavior 			= undefined;
	self.combatmode						= "cover";
	self.grenadeawareness 				= self.oldgrenadeawareness;
	self.noGrenadeReturnThrow 			= self.oldGrenadeReturnThrow;
	
	self.walkDist = self.old_walkDist;
	self.walkDistFacingMotion = self.old_walkDistFacingMotion;

	self animscripts\animset::clear_custom_animset();
	
	self.prevMoveMode = "none";
	
	self allowedStances( "stand", "crouch", "prone" );
	
	//self animscripts\animset::set_animset_run_n_gun();
	
	self.customMoveTransition = undefined;
	self.permanentCustomMoveTransition = undefined;
	self.approachTypeFunc = undefined;
	self.approachConditionCheckFunc = undefined;
	self.disableCoverArrivalsOnly = undefined;
}

#using_animtree( "generic_human" );
init_wounded_ai_animset()
{
	
	animset = [];
	
	// used when sprint is enabled ( enable_sprint() )
	animset[ "sprint" ] = %combat_jog; // sprint1_loop  
	
	// used when sprint is NOT enabled  ( enable_sprint() ) and
	// the AI either has no enemies or ignoreAll = true
	animset[ "straight" ] = %vegas_baker_limp; // run_lowready_F
	
	// stance = stand
	animset[ "move_f" ] = %wounded_walk_f ; // walk_forward // wounded_walk_f
	animset[ "move_l" ] = %walk_left;
	animset[ "move_r" ] = %walk_right;
	animset[ "move_b" ] = %walk_backward;
	
	// stance = crouch
	animset[ "crouch" ] = %crouch_fastwalk_F;
	animset[ "crouch_l" ] = %crouch_fastwalk_L;
	animset[ "crouch_r" ] = %crouch_fastwalk_R;
	animset[ "crouch_b" ] = %crouch_fastwalk_B;
	
	animset[ "stairs_up" ] = %traverse_stair_run_01;
	animset[ "stairs_down" ] = %traverse_stair_run_down;
		
	self.customMoveAnimSet[ "run" ] = animset;
	self.customMoveAnimSet[ "crouch" ] = animset;
	self.customMoveAnimSet[ "walk" ] = animset;
	
	// crouch movement when engaging enemies
	//self.crouchrun_combatanim = %wounded_walk_f;
	
//	self.customIdleAnimSet = [];
//	self.customIdleAnimSet[ "stand" ] 		= [ %vegas_baker_pillar_stand_idle, %vegas_baker_pillar_stand_idle_twitch_checkclip, %vegas_baker_pillar_stand_idle_twitch_pain ];
//	self.customIdleAnimWeights[ "stand" ] 		= [ 3, 1, 2 ];
	
	self.a.pose = "stand";
	self allowedstances( "stand" );
	
	// combat animations
	animset = anim.animsets.defaultStand;

	self animscripts\animset::init_animset_complete_custom_stand( animset );
	
//	wounded_ai_transition_anims();
}

wounded_ai_transition_anims()
{
	
	//arrivals
	archetype["cover_trans"]["wounded_ai"][1] = %vegas_baker_pillar_stand_approach_1; //vegas_baker_pillar_stand_approach_1
	archetype["cover_trans"]["wounded_ai"][2] = %vegas_baker_pillar_stand_approach_2;
	archetype["cover_trans"]["wounded_ai"][3] = %vegas_baker_pillar_stand_approach_3;
	archetype["cover_trans"]["wounded_ai"][4] = undefined;
	archetype["cover_trans"]["wounded_ai"][7] = undefined;
	archetype["cover_trans"]["wounded_ai"][8] = undefined;
	archetype["cover_trans"]["wounded_ai"][9] = undefined;

//	initAnimset[ "crouch" ][ 1 ] = %covercrouch_run_in_ML;
//	initAnimset[ "crouch" ][ 2 ] = %covercrouch_run_in_M;
//	initAnimset[ "crouch" ][ 3 ] = %covercrouch_run_in_MR;
//	initAnimset[ "crouch" ][ 4 ] = %covercrouch_run_in_L;
//	initAnimset[ "crouch" ][ 6 ] = %covercrouch_run_in_R;
	
	//anim.coverTrans[ "casual_killer_sprint" ] = [];
//	archetype["cover_trans"]["casual_killer_sprint"][1] = %casual_killer_jog_stop;
//	archetype["cover_trans"]["casual_killer_sprint"][2] = %casual_killer_jog_stop;
//	archetype["cover_trans"]["casual_killer_sprint"][3] = %casual_killer_jog_stop;
//	archetype["cover_trans"]["casual_killer_sprint"][4] = %casual_killer_jog_stop;
//	archetype["cover_trans"]["casual_killer_sprint"][6] = %casual_killer_jog_stop;
//	archetype["cover_trans"]["casual_killer_sprint"][7] = %casual_killer_jog_stop;
//	archetype["cover_trans"]["casual_killer_sprint"][8] = %casual_killer_jog_stop;
//	archetype["cover_trans"]["casual_killer_sprint"][9] = %casual_killer_jog_stop;
	
	wounded_aiTransTypes = [];
	wounded_aiTransTypes[0] = "wounded_ai";
//	wounded_aiTransTypes[1] = "casual_killer_sprint";
	
	for ( j = 0; j < wounded_aiTransTypes.size; j++ )
	{
		trans = wounded_aiTransTypes[ j ];

		for ( i = 1; i <= 9; i++ )
		{
			if ( i == 5 )
				continue;
				
			if ( isdefined( archetype["cover_trans"][trans][i] ) )
			{
				archetype["cover_trans_dist"][trans][i] = getMoveDelta( archetype["cover_trans"][trans][i], 0, 1 );
			}
		}
	}	
	
	archetype["cover_trans_angles"][ "wounded_ai" ][ 1 ] = 45;
	archetype["cover_trans_angles"][ "wounded_ai" ][ 2 ] = 0;
	archetype["cover_trans_angles"][ "wounded_ai" ][ 3 ] = -45;
	archetype["cover_trans_angles"][ "wounded_ai" ][ 4 ] = 90;
	archetype["cover_trans_angles"][ "wounded_ai" ][ 6 ] = -90;	
	archetype["cover_trans_angles"][ "wounded_ai" ][ 8 ] = 180;
	
//	archetype["cover_trans_angles"][ "casual_killer_sprint" ][ 1 ] = 45;
//	archetype["cover_trans_angles"][ "casual_killer_sprint" ][ 2 ] = 0;
//	archetype["cover_trans_angles"][ "casual_killer_sprint" ][ 3 ] = -45;
//	archetype["cover_trans_angles"][ "casual_killer_sprint" ][ 4 ] = 90;
//	archetype["cover_trans_angles"][ "casual_killer_sprint" ][ 6 ] = -90;	
//	archetype["cover_trans_angles"][ "casual_killer_sprint" ][ 8 ] = 180;

//	archetype["run_n_gun"]["F"] = %casual_killer_walk_shoot_F;
//	archetype["run_n_gun"]["L"] = %casual_killer_walk_shoot_L;
//	archetype["run_n_gun"]["R"] = %casual_killer_walk_shoot_R;
//	archetype["run_n_gun"]["LB"] = %casual_killer_walk_shoot_L;
//	archetype["run_n_gun"]["RB"] = %casual_killer_walk_shoot_R;

	maps\_utility::register_archetype( "wounded_ai", archetype, false );
	
	anim.arrivalEndStance[ "wounded_ai" ] = "stand";
//	anim.arrivalEndStance[ "casual_killer_sprint" ] = "stand";
	
}

wounded_ai_idle_variance()
{
	self endon( "death" );
	
	customIdleAnimSet = [];
	customIdleAnimWeights = [];
	
	customIdleAnimSet[ 0 ][ 0 ] = %vegas_baker_pillar_stand_idle;
	customIdleAnimSet[ 0 ][ 1 ] = %vegas_baker_pillar_stand_idle_twitch_pain;
	customIdleAnimSet[ 0 ][ 2 ] = %vegas_baker_pillar_stand_idle_twitch_checkclip;
	customIdleAnimSet[ 0 ][ 3 ] = %vegas_baker_pillar_stand_idle_twitch_lookright;
	customIdleAnimWeights[ 0 ][ 0 ] = 10;
	customIdleAnimWeights[ 0 ][ 1 ] = 1;
	customIdleAnimWeights[ 0 ][ 2 ] = 1;
	
	lastIdleSet = 0;
	self.customIdleAnimSet = [];
	while ( true )
	{
		idleSet = RandomInt( customIdleAnimSet.size );
		
		// don't play the same idle in a row
		if ( idleSet == lastIdleSet )
		{
			idleSet = ( lastIdleSet + 1 ) % customIdleAnimSet.size;
		}
		lastIdleSet = idleSet;
		
		self.customIdleAnimSet[ "stand" ] = animscripts\utility::anim_array( customIdleAnimSet[ idleSet ], customIdleAnimWeights[ idleSet ] );
		
		while ( true )
		{
			self waittill( "idle", note );
			if ( IsDefined( note ) && note == "end" )
			{
				break;
			}
		}
		
		// pick out an animation for the next cycle, this is so it can be
		//   deterministic instead of having the idle loop possibly double up
		waittillframeend;
	}
}

wounded_ai_approach_type()
{
	return "wounded_ai";	
}

wounded_ai_approach_conditions( node )
{
	return true;
}

wounded_ai_startMoveTransition()
{
	if ( isdefined( self.disableExits ) )
		return;
		
	self orientmode( "face angle", self.angles[1] );
	self animmode( "zonly_physics", false );

	rate = randomfloatrange( 0.9, 1.1 );
	

//	if( self casual_killer_is_jogging() )
//		startAnim = %casual_killer_jog_start;
//	else
	startAnim = %vegas_baker_pillar_exit_l;
	
	self setFlaggedAnimKnobAllRestart( "startmove", startAnim, %body, 1, .1, rate );
	self animscripts\shared::DoNoteTracks( "startmove" );

	self OrientMode( "face default" );
	self animmode( "none", false );
	
	if ( animHasNotetrack( startAnim, "code_move" ) )
		self animscripts\shared::DoNoteTracks( "startmove" );	// return on code_move
}