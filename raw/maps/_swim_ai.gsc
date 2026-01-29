#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_swim_ai_common;

#using_animtree( "generic_human" );
init_ai_swim()
{
	level._effect[ "swim_ai_blood_impact"	]	= loadfx( "vfx/gameplay/blood/underwater_blood_impact"		 );
	level._effect[ "swim_ai_death_blood"	]	= loadfx( "vfx/moments/ship_graveyard/vfx_deathfx_bloodpool_uw" );
	level._effect[ "swim_kick_bubble"		]	= loadfx( "vfx/gameplay/footsteps/swim_kick_bubbles"	 );
	level._effect[ "jump_into_water_splash" ]	= loadfx( "vfx/moments/ship_graveyard/bubbles_diver_drop_underwater"	 );
	level._effect[ "jump_into_water_trail"	]	= loadfx( "vfx/moments/ship_graveyard/vfx_dive_bubbles_geotrail"				 );
	
	level.scr_anim[ "generic" ][ "swimming_heli_deploy" ][0] = %ship_graveyard_water_entry_idle;
	level.scr_anim[ "generic" ][ "swimming_heli_deploy_end" ] = %ship_graveyard_water_entry;
	
	SetSavedDvar( "phys_gravity_ragdoll", -10 );
	SetSavedDVar( "phys_gravity", -10 );
	SetSavedDVar( "ragdoll_max_life", 15000 );
	SetSavedDVar( "phys_autoDisableLinear", 0.25 );
	
	thread override_footsteps();
	
	battlechatter_off( "axis" );
}

enable_swim()
{
	if ( !isAI( self ) )
		return;
	
	self.health = 50;
	
	self.grenadeammo = 0;
	self.goalradius = 128;
	self.goalheight = 96;
	self.swimmer = true;
	
	//self disable_turnAnims();
	self disable_surprise();

	self thread unlimited_ammo();
    self forceUseWeapon( "aps_underwater+swim", "primary" );
	//self forceUseWeapon( "iw5_mp5underwaterprojectile_swim", "primary" );
	self thread glint_behavior();
	
	self.dontmelee						= true;
	self.no_pistol_switch  				= true;
	self.ignoresuppression 				= true;
	self.noRunReload 					= true;
	self.disableBulletWhizbyReaction 	= true;
	self.useChokePoints 				= false;
	self.disableDoorBehavior 			= true;
	self.combatmode						= "cover";
	self.oldgrenadeawareness 			= self.grenadeawareness;
	self.grenadeawareness 				= 0;
	self.oldGrenadeReturnThrow 			= self.noGrenadeReturnThrow;
	self.noGrenadeReturnThrow 			= true;
	self.noRunNGun 						= true;
	
	self init_ai_swim_animsets();
	self thread maps\_underwater::friendly_bubbles();
	self thread underwater_blood();

	assert( IsDefined( anim.archetypes ) && IsDefined( anim.archetypes["soldier"] ) );
	if ( !IsDefined( anim.archetypes[ "soldier" ][ "swim" ] ) )
		init_swim_anims();

	self animscripts\swim::Swim_Begin();
}

disable_swim()
{
	self.customMoveTransition = undefined;
	self.permanentCustomMoveTransition = false;

	self animscripts\swim::Swim_End();
	self notify( "stop_glint_thread" );
}

// required for animscripts/swim.gsc to work properly.
init_swim_anims()
{
	swimAnims = [];

	swimAnims[ "forward" ] = %swimming_forward;
	//swimAnims[ "forward_twitch" ] = %swimming_forward_twitch_1;
	swimAnims[ "forward_aim" ] = %swimming_aiming_move_F;

	swimAnims[ "idle_to_forward" ] = [];
	swimAnims[ "idle_to_forward" ][ 2 ] = [];
	swimAnims[ "idle_to_forward" ][ 2 ][ 4 ] = %swimming_idle_to_forward_l90;
	swimAnims[ "idle_to_forward" ][ 4 ] = [];
	swimAnims[ "idle_to_forward" ][ 4 ][ 2 ] = %swimming_idle_to_forward_u90;
	swimAnims[ "idle_to_forward" ][ 4 ][ 3 ] = %swimming_idle_to_forward_u45;
	swimAnims[ "idle_to_forward" ][ 4 ][ 4 ] = %swimming_idle_to_forward;
	swimAnims[ "idle_to_forward" ][ 4 ][ 5 ] = %swimming_idle_to_forward_d45;
	swimAnims[ "idle_to_forward" ][ 4 ][ 6 ] = %swimming_idle_to_forward_d90;
	swimAnims[ "idle_to_forward" ][ 6 ] = [];
	swimAnims[ "idle_to_forward" ][ 6 ][ 4 ] = %swimming_idle_to_forward_r90;

	swimAnims[ "idle_ready_to_forward" ] = [];
	swimAnims[ "idle_ready_to_forward" ][ 4 ] = [];
	swimAnims[ "idle_ready_to_forward" ][ 4 ][ 4 ] = %swimming_idle_ready_to_forward;

	swimAnims[ "aim_stand_D" ] = %swimming_fire_D;
	swimAnims[ "aim_stand_U" ] = %swimming_fire_U_extended;
	swimAnims[ "aim_stand_L" ] = %swimming_fire_L;
	swimAnims[ "aim_stand_R" ] = %swimming_fire_R;

	swimAnims[ "aim_move_R" ] = %swimming_aiming_move_f_fire_r;
	swimAnims[ "aim_move_L" ] = %swimming_aiming_move_f_fire_l;
	swimAnims[ "aim_move_U" ] = %swimming_aiming_move_f_fire_u_extended;
	swimAnims[ "aim_move_D" ] = %swimming_aiming_move_f_fire_d_extended;	//%swimming_aiming_move_f_fire_d;

	swimAnims[ "strafe_B" ] = %swimming_aiming_move_B;
	swimAnims[ "strafe_L" ] = %swimming_aiming_move_L;
	swimAnims[ "strafe_R" ] = %swimming_aiming_move_R;

	swimAnims[ "strafe_L_aim_R" ] = %swimming_aiming_move_l_fire_r;
	swimAnims[ "strafe_L_aim_L" ] = %swimming_aiming_move_l_fire_l;
	swimAnims[ "strafe_L_aim_U" ] = %swimming_aiming_move_l_fire_u;
	swimAnims[ "strafe_L_aim_D" ] = %swimming_aiming_move_l_fire_d;

	swimAnims[ "strafe_R_aim_R" ] = %swimming_aiming_move_r_fire_r;
	swimAnims[ "strafe_R_aim_L" ] = %swimming_aiming_move_r_fire_l;
	swimAnims[ "strafe_R_aim_U" ] = %swimming_aiming_move_r_fire_u;
	swimAnims[ "strafe_R_aim_D" ] = %swimming_aiming_move_r_fire_d;

	swimAnims[ "strafe_B_aim_R" ] = %swimming_aiming_move_b_fire_r;
	swimAnims[ "strafe_B_aim_L" ] = %swimming_aiming_move_b_fire_l;
	swimAnims[ "strafe_B_aim_U" ] = %swimming_aiming_move_b_fire_u;
	swimAnims[ "strafe_B_aim_D" ] = %swimming_aiming_move_b_fire_d;

	swimAnims[ "turn_left_45" ] = %swimming_aiming_turn_L45;
	swimAnims[ "turn_left_90" ] = %swimming_aiming_turn_L90;
	swimAnims[ "turn_left_135" ] = %swimming_aiming_turn_L135;
	swimAnims[ "turn_left_180" ] = %swimming_aiming_turn_L180;
	swimAnims[ "turn_right_45" ] = %swimming_aiming_turn_R45;
	swimAnims[ "turn_right_90" ] = %swimming_aiming_turn_R90;
	swimAnims[ "turn_right_135" ] = %swimming_aiming_turn_R135;
	swimAnims[ "turn_right_180" ] = %swimming_aiming_turn_R180;

	swimAnims[ "idle_turn" ] = [];
	swimAnims[ "idle_turn" ][ 2 ] =  %swimming_idle_turn_90r;
	swimAnims[ "idle_turn" ][ 3 ] =  %swimming_idle_turn_45r;
	swimAnims[ "idle_turn" ][ 5 ] =  %swimming_idle_turn_45l;
	swimAnims[ "idle_turn" ][ 6 ] =  %swimming_idle_turn_90l;

	swimAnims[ "surprise_stop" ] = %swimming_surprise_stop;


	// swimAnims[ "arrival_*" ][ yaw ][ pitch ]
	// 45 degree increments, so...
	// -180, -135, -90, -45, 0, 45, 90, 135, 180
	swimAnims[ "arrival_cover_corner_r" ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 2 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 2 ][ 4 ] = %swimming_aiming_move_to_cover_r1_r90;
	swimAnims[ "arrival_cover_corner_r" ][ 3 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 3 ][ 3 ] = %swimming_aiming_move_to_cover_r1_r45_u45;
	swimAnims[ "arrival_cover_corner_r" ][ 3 ][ 4 ] = %swimming_aiming_move_to_cover_r1_r45;
	swimAnims[ "arrival_cover_corner_r" ][ 3 ][ 5 ] = %swimming_aiming_move_to_cover_r1_r45_d45;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 2 ] = %swimming_aiming_move_to_cover_r1_u90;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 3 ] = %swimming_aiming_move_to_cover_r1_u45;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 4 ] = %swimming_aiming_move_to_cover_r1;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 5 ] = %swimming_aiming_move_to_cover_r1_d45;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 6 ] = %swimming_aiming_move_to_cover_r1_d90;
	swimAnims[ "arrival_cover_corner_r" ][ 5 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 5 ][ 3 ] = %swimming_aiming_move_to_cover_r1_l45_u45;
	swimAnims[ "arrival_cover_corner_r" ][ 5 ][ 4 ] = %swimming_aiming_move_to_cover_r1_l45;
	swimAnims[ "arrival_cover_corner_r" ][ 5 ][ 5 ] = %swimming_aiming_move_to_cover_r1_l45_d45;
	swimAnims[ "arrival_cover_corner_r" ][ 6 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 6 ][ 4 ] = %swimming_aiming_move_to_cover_r1_l90;

	swimAnims[ "arrival_cover_corner_l" ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 2 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 2 ][ 4 ] = %swimming_aiming_move_to_cover_l1_r90;
	swimAnims[ "arrival_cover_corner_l" ][ 3 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 3 ][ 3 ] = %swimming_aiming_move_to_cover_l1_r45_u45;
	swimAnims[ "arrival_cover_corner_l" ][ 3 ][ 4 ] = %swimming_aiming_move_to_cover_l1_r45;
	swimAnims[ "arrival_cover_corner_l" ][ 3 ][ 5 ] = %swimming_aiming_move_to_cover_l1_r45_d45;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 2 ] = %swimming_aiming_move_to_cover_l1_u90;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 3 ] = %swimming_aiming_move_to_cover_l1_u45;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 4 ] = %swimming_aiming_move_to_cover_l1;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 5 ] = %swimming_aiming_move_to_cover_l1_d45;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 6 ] = %swimming_aiming_move_to_cover_l1_d90;
	swimAnims[ "arrival_cover_corner_l" ][ 5 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 5 ][ 3 ] = %swimming_aiming_move_to_cover_l1_l45_u45;
	swimAnims[ "arrival_cover_corner_l" ][ 5 ][ 4 ] = %swimming_aiming_move_to_cover_l1_l45;
	swimAnims[ "arrival_cover_corner_l" ][ 5 ][ 5 ] = %swimming_aiming_move_to_cover_l1_l45_d45;
	swimAnims[ "arrival_cover_corner_l" ][ 6 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 6 ][ 4 ] = %swimming_aiming_move_to_cover_l1_l90;

	swimAnims[ "arrival_cover_u" ] = [];
	swimAnims[ "arrival_cover_u" ][ 2 ] = [];
	swimAnims[ "arrival_cover_u" ][ 2 ][ 4 ] = %swimming_aiming_move_to_cover_u1_r90;
	swimAnims[ "arrival_cover_u" ][ 3 ] = [];
	swimAnims[ "arrival_cover_u" ][ 3 ][ 3 ] = %swimming_aiming_move_to_cover_u1_r45_u45;
	swimAnims[ "arrival_cover_u" ][ 3 ][ 4 ] = %swimming_aiming_move_to_cover_u1_r45;
	swimAnims[ "arrival_cover_u" ][ 3 ][ 5 ] = %swimming_aiming_move_to_cover_u1_r45_d45;
	swimAnims[ "arrival_cover_u" ][ 4 ] = [];
	swimAnims[ "arrival_cover_u" ][ 4 ][ 2 ] = %swimming_aiming_move_to_cover_u1_u90;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 3 ] = %swimming_aiming_move_to_cover_u1_u45;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 4 ] = %swimming_aiming_move_to_cover_u1;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 5 ] = %swimming_aiming_move_to_cover_u1_d45;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 6 ] = %swimming_aiming_move_to_cover_u1_d90;
	swimAnims[ "arrival_cover_u" ][ 5 ] = [];
	swimAnims[ "arrival_cover_u" ][ 5 ][ 3 ] = %swimming_aiming_move_to_cover_u1_l45_u45;
	swimAnims[ "arrival_cover_u" ][ 5 ][ 4 ] = %swimming_aiming_move_to_cover_u1_l45;
	swimAnims[ "arrival_cover_u" ][ 5 ][ 5 ] = %swimming_aiming_move_to_cover_u1_l45_d45;
	swimAnims[ "arrival_cover_u" ][ 6 ] = [];
	swimAnims[ "arrival_cover_u" ][ 6 ][ 4 ] = %swimming_aiming_move_to_cover_u1_l90;

	swimAnims[ "arrival_exposed" ] = [];
	swimAnims[ "arrival_exposed" ][ 4 ] = [];
	swimAnims[ "arrival_exposed" ][ 4 ][ 4 ] = %swimming_forward_to_idle_ready;			//%swimming_forward_to_fire;
	
	// these anims are named as what direction he is swimming, not what direction he is coming from.
	swimAnims[ "arrival_exposed_noncombat" ] = [];
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ] = [];
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 2 ] = %swimming_forward_90d_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 3 ] = %swimming_forward_45d_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 4 ] = %swimming_forward_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 5 ] = %swimming_forward_45u_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 6 ] = %swimming_forward_90u_to_idle;

	swimAnims[ "exit_cover_corner_r" ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 2 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 2 ][ 4 ] = %swimming_cover_r1_to_aiming_move_r90;
	swimAnims[ "exit_cover_corner_r" ][ 3 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 3 ][ 3 ] = %swimming_cover_r1_to_aiming_move_r45_u45;
	swimAnims[ "exit_cover_corner_r" ][ 3 ][ 4 ] = %swimming_cover_r1_to_aiming_move_r45;
	swimAnims[ "exit_cover_corner_r" ][ 3 ][ 5 ] = %swimming_cover_r1_to_aiming_move_r45_d45;
	swimAnims[ "exit_cover_corner_r" ][ 4 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 2 ] = %swimming_cover_r1_to_aiming_move_u90;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 3 ] = %swimming_cover_r1_to_aiming_move_u45;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 4 ] = %swimming_cover_r1_to_aiming_move;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 5 ] = %swimming_cover_r1_to_aiming_move_d45;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 6 ] = %swimming_cover_r1_to_aiming_move_d90;
	swimAnims[ "exit_cover_corner_r" ][ 5 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 5 ][ 3 ] = %swimming_cover_r1_to_aiming_move_l45_u45;
	swimAnims[ "exit_cover_corner_r" ][ 5 ][ 4 ] = %swimming_cover_r1_to_aiming_move_l45;
	swimAnims[ "exit_cover_corner_r" ][ 5 ][ 5 ] = %swimming_cover_r1_to_aiming_move_l45_d45;
	swimAnims[ "exit_cover_corner_r" ][ 6 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 6 ][ 4 ] = %swimming_cover_r1_to_aiming_move_l90;

	swimAnims[ "exit_cover_corner_l" ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 2 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 2 ][ 4 ] = %swimming_cover_l1_to_aiming_move_r90;
	swimAnims[ "exit_cover_corner_l" ][ 3 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 3 ][ 3 ] = %swimming_cover_l1_to_aiming_move_r45_u45;
	swimAnims[ "exit_cover_corner_l" ][ 3 ][ 4 ] = %swimming_cover_l1_to_aiming_move_r45;
	swimAnims[ "exit_cover_corner_l" ][ 3 ][ 5 ] = %swimming_cover_l1_to_aiming_move_r45_d45;
	swimAnims[ "exit_cover_corner_l" ][ 4 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 2 ] = %swimming_cover_l1_to_aiming_move_u90;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 3 ] = %swimming_cover_l1_to_aiming_move_u45;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 4 ] = %swimming_cover_l1_to_aiming_move;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 5 ] = %swimming_cover_l1_to_aiming_move_d45;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 6 ] = %swimming_cover_l1_to_aiming_move_d90;
	swimAnims[ "exit_cover_corner_l" ][ 5 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 5 ][ 3 ] = %swimming_cover_l1_to_aiming_move_l45_u45;
	swimAnims[ "exit_cover_corner_l" ][ 5 ][ 4 ] = %swimming_cover_l1_to_aiming_move_l45;
	swimAnims[ "exit_cover_corner_l" ][ 5 ][ 5 ] = %swimming_cover_l1_to_aiming_move_l45_d45;
	swimAnims[ "exit_cover_corner_l" ][ 6 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 6 ][ 4 ] = %swimming_cover_l1_to_aiming_move_l90;

	swimAnims[ "exit_cover_u" ] = [];
	swimAnims[ "exit_cover_u" ][ 2 ] = [];
	swimAnims[ "exit_cover_u" ][ 2 ][ 4 ] = %swimming_cover_u1_to_aiming_move_r90;
	swimAnims[ "exit_cover_u" ][ 3 ] = [];
	swimAnims[ "exit_cover_u" ][ 3 ][ 3 ] = %swimming_cover_u1_to_aiming_move_r45_u45;
	swimAnims[ "exit_cover_u" ][ 3 ][ 4 ] = %swimming_cover_u1_to_aiming_move_r45;
	swimAnims[ "exit_cover_u" ][ 3 ][ 5 ] = %swimming_cover_u1_to_aiming_move_r45_d45;
	swimAnims[ "exit_cover_u" ][ 4 ] = [];
	swimAnims[ "exit_cover_u" ][ 4 ][ 2 ] = %swimming_cover_u1_to_aiming_move_u90;
	swimAnims[ "exit_cover_u" ][ 4 ][ 3 ] = %swimming_cover_u1_to_aiming_move_u45;
	swimAnims[ "exit_cover_u" ][ 4 ][ 4 ] = %swimming_cover_u1_to_aiming_move;
	swimAnims[ "exit_cover_u" ][ 4 ][ 5 ] = %swimming_cover_u1_to_aiming_move_d45;
	swimAnims[ "exit_cover_u" ][ 4 ][ 6 ] = %swimming_cover_u1_to_aiming_move_d90;
	swimAnims[ "exit_cover_u" ][ 5 ] = [];
	swimAnims[ "exit_cover_u" ][ 5 ][ 3 ] = %swimming_cover_u1_to_aiming_move_l45_u45;
	swimAnims[ "exit_cover_u" ][ 5 ][ 4 ] = %swimming_cover_u1_to_aiming_move_l45;
	swimAnims[ "exit_cover_u" ][ 5 ][ 5 ] = %swimming_cover_u1_to_aiming_move_l45_d45;
	swimAnims[ "exit_cover_u" ][ 6 ] = [];
	swimAnims[ "exit_cover_u" ][ 6 ][ 4 ] = %swimming_cover_u1_to_aiming_move_l90;

	swimAnims[ "turn" ] = [];
	// swimAnims[ "turns" ][ yaw ][ pitch ]
	swimAnims[ "turn" ] = [];
	swimAnims[ "turn" ][ 0 ] = [];
	swimAnims[ "turn" ][ 0 ][ 4 ] = %swimming_swim_turn_l180;
	swimAnims[ "turn" ][ 1 ] = [];
	swimAnims[ "turn" ][ 1 ][ 4 ] = %swimming_swim_turn_l135;
	swimAnims[ "turn" ][ 2 ] = [];
	swimAnims[ "turn" ][ 2 ][ 4 ] = %swimming_swim_turn_l90;
	swimAnims[ "turn" ][ 3 ] = [];
	swimAnims[ "turn" ][ 3 ][ 3 ] = %swimming_swim_turn_D45_L45;
	swimAnims[ "turn" ][ 3 ][ 4 ] = %swimming_swim_turn_L45;
	swimAnims[ "turn" ][ 3 ][ 5 ] = %swimming_swim_turn_U45_L45;
	swimAnims[ "turn" ][ 4 ] = [];
	swimAnims[ "turn" ][ 4 ][ 3 ] = %swimming_swim_turn_D45;
	swimAnims[ "turn" ][ 4 ][ 5 ] = %swimming_swim_turn_U45;
	swimAnims[ "turn" ][ 5 ] = [];
	swimAnims[ "turn" ][ 5 ][ 3 ] = %swimming_swim_turn_D45_R45;
	swimAnims[ "turn" ][ 5 ][ 4 ] = %swimming_swim_turn_R45;
	swimAnims[ "turn" ][ 5 ][ 5 ] = %swimming_swim_turn_U45_R45;
	swimAnims[ "turn" ][ 6 ] = [];
	swimAnims[ "turn" ][ 6 ][ 4 ] = %swimming_swim_turn_r90;
	swimAnims[ "turn" ][ 7 ] = [];
	swimAnims[ "turn" ][ 7 ][ 4 ] = %swimming_swim_turn_r135;
	swimAnims[ "turn" ][ 8 ] = [];
	swimAnims[ "turn" ][ 8 ][ 4 ] = %swimming_swim_turn_l180;

	swimAnims[ "turn_add_r" ] = %swimming_slight_turn_R;
	swimAnims[ "turn_add_l" ] = %swimming_slight_turn_L;
	swimAnims[ "turn_add_u" ] = %swimming_slight_turn_U;
	swimAnims[ "turn_add_d" ] = %swimming_slight_turn_D;

	swimAnims[ "cover_corner_r" ] = [];
	swimAnims[ "cover_corner_r" ][ "straight_level" ] = %swimming_fire;
	swimAnims[ "cover_corner_r" ][ "alert_idle" ] = %swimming_cover_r1_loop;
	swimAnims[ "cover_corner_r" ][ "alert_to_A" ] = [ %swimming_cover_r1_full_expose ];
	swimAnims[ "cover_corner_r" ][ "alert_to_B" ] = [ %swimming_cover_r1_full_expose ];
	swimAnims[ "cover_corner_r" ][ "A_to_alert" ] = [ %swimming_cover_r1_full_hide];
	//swimAnims[ "cover_corner_r" ][ "A_to_alert_reload" ] = [];
	swimAnims[ "cover_corner_r" ][ "A_to_B" ] = [ %swimming_fire ];
	swimAnims[ "cover_corner_r" ][ "B_to_alert" ] = [ %swimming_cover_r1_full_hide ];
	//swimAnims[ "cover_corner_r" ][ "B_to_alert_reload" ] = [];
 	swimAnims[ "cover_corner_r" ][ "B_to_A" ] = [ %swimming_fire ];
	swimAnims[ "cover_corner_r" ][ "lean_to_alert" ] = [ %swimming_cover_r1_hide ];
	swimAnims[ "cover_corner_r" ][ "alert_to_lean" ] = [ %swimming_cover_r1_expose ];
	swimAnims[ "cover_corner_r" ][ "look" ] = %swimming_cover_r1_expose;
	swimAnims[ "cover_corner_r" ][ "reload" ] = [ %swimming_cover_r1_reload ];//array( %corner_standL_reload_v1 );// , %corner_standL_reload_v2 );
	//swimAnims[ "cover_corner_r" ][ "alert_to_over" ] = [ %swimming_cover_r1_expose ];
	//swimAnims[ "cover_corner_r" ][ "over_to_alert" ] = [ %swimming_cover_r1_hide ];
	//swimAnims[ "cover_corner_r" ][ "over_idle" ] = [ %swimming_cover_r1_exposed_idle ];

	//swimAnims[ "cover_corner_r" ][ "blind_fire" ] = [];
	
	swimAnims[ "cover_corner_r" ][ "alert_to_look" ] = %swimming_cover_r1_expose;
	swimAnims[ "cover_corner_r" ][ "look_to_alert" ] = %swimming_cover_r1_hide;
	swimAnims[ "cover_corner_r" ][ "look_to_alert_fast" ] = %swimming_cover_r1_hide;
	swimAnims[ "cover_corner_r" ][ "look_idle" ] = %swimming_cover_r1_exposed_idle;
	//swimAnims[ "cover_corner_r" ][ "stance_change" ] = %swimming_cover_r1_loop;

	swimAnims[ "cover_corner_r" ][ "lean_aim_down" ] = %swimming_cover_r1_exposed_aim_d;
	swimAnims[ "cover_corner_r" ][ "lean_aim_left" ] = %swimming_cover_r1_exposed_aim_l;
	swimAnims[ "cover_corner_r" ][ "lean_aim_straight" ] = %swimming_cover_r1_exposed_fire;
	swimAnims[ "cover_corner_r" ][ "lean_aim_right" ] = %swimming_cover_r1_exposed_aim_r;
	swimAnims[ "cover_corner_r" ][ "lean_aim_up" ] = %swimming_cover_r1_exposed_aim_u;
	swimAnims[ "cover_corner_r" ][ "lean_reload" ] = %swimming_cover_r1_reload;
	swimAnims[ "cover_corner_r" ][ "lean_idle" ] = [ %swimming_cover_r1_exposed_idle ];
	swimAnims[ "cover_corner_r" ][ "lean_single" ] = %swimming_cover_r1_exposed_fire;
	swimAnims[ "cover_corner_r" ][ "lean_fire" ] = %swimming_cover_r1_exposed_fire;


	swimAnims[ "cover_corner_r" ][ "add_aim_down" ] = %swimming_fire_D;
	swimAnims[ "cover_corner_r" ][ "add_aim_left" ] = %swimming_fire_L;
	swimAnims[ "cover_corner_r" ][ "add_aim_straight" ] = %swimming_firing;
	swimAnims[ "cover_corner_r" ][ "add_aim_right" ] = %swimming_fire_R;
	swimAnims[ "cover_corner_r" ][ "add_aim_up" ] = %swimming_fire_U_extended;
	swimAnims[ "cover_corner_r" ][ "add_aim_idle" ] = %swimming_firing_idle;

	swimAnims[ "cover_corner_l" ] = [];

	swimAnims[ "cover_corner_l" ][ "straight_level" ] = %swimming_fire;
	swimAnims[ "cover_corner_l" ][ "alert_idle" ] = %swimming_cover_l1_idle;
	swimAnims[ "cover_corner_l" ][ "alert_to_A" ] = [ %swimming_cover_l1_full_expose ];
	swimAnims[ "cover_corner_l" ][ "alert_to_B" ] = [ %swimming_cover_l1_full_expose ];
	swimAnims[ "cover_corner_l" ][ "A_to_alert" ] = [ %swimming_cover_l1_full_hide];
	swimAnims[ "cover_corner_l" ][ "A_to_B" ] = [ %swimming_fire ];
	swimAnims[ "cover_corner_l" ][ "B_to_alert" ] = [ %swimming_cover_l1_full_hide ];
 	swimAnims[ "cover_corner_l" ][ "B_to_A" ] = [ %swimming_fire ];
	swimAnims[ "cover_corner_l" ][ "lean_to_alert" ] = [ %swimming_cover_l1_hide ];
	swimAnims[ "cover_corner_l" ][ "alert_to_lean" ] = [ %swimming_cover_l1_expose ];
	swimAnims[ "cover_corner_l" ][ "look" ] = %swimming_cover_l1_expose;
	swimAnims[ "cover_corner_l" ][ "reload" ] = [ %swimming_cover_l1_reload ];

	swimAnims[ "cover_corner_l" ][ "alert_to_look" ] = %swimming_cover_l1_expose;
	swimAnims[ "cover_corner_l" ][ "look_to_alert" ] = %swimming_cover_l1_hide;
	swimAnims[ "cover_corner_l" ][ "look_to_alert_fast" ] = %swimming_cover_l1_hide;
	swimAnims[ "cover_corner_l" ][ "look_idle" ] = %swimming_cover_l1_exposed_idle;

	swimAnims[ "cover_corner_l" ][ "lean_aim_down" ] = %swimming_cover_l1_exposed_aim_d;
	swimAnims[ "cover_corner_l" ][ "lean_aim_left" ] = %swimming_cover_l1_exposed_aim_l;
	swimAnims[ "cover_corner_l" ][ "lean_aim_straight" ] = %swimming_cover_l1_exposed_fire;
	swimAnims[ "cover_corner_l" ][ "lean_aim_right" ] = %swimming_cover_l1_exposed_aim_r;
	swimAnims[ "cover_corner_l" ][ "lean_aim_up" ] = %swimming_cover_l1_exposed_aim_u;
	swimAnims[ "cover_corner_l" ][ "lean_reload" ] = %swimming_cover_l1_reload;
	swimAnims[ "cover_corner_l" ][ "lean_idle" ] = [ %swimming_cover_l1_exposed_idle ];
	swimAnims[ "cover_corner_l" ][ "lean_single" ] = %swimming_cover_l1_exposed_fire;
	swimAnims[ "cover_corner_l" ][ "lean_fire" ] = %swimming_cover_l1_exposed_fire;

	swimAnims[ "cover_corner_l" ][ "add_aim_down" ] = %swimming_fire_D;
	swimAnims[ "cover_corner_l" ][ "add_aim_left" ] = %swimming_fire_L;
	swimAnims[ "cover_corner_l" ][ "add_aim_straight" ] = %swimming_firing;
	swimAnims[ "cover_corner_l" ][ "add_aim_right" ] = %swimming_fire_R;
	swimAnims[ "cover_corner_l" ][ "add_aim_up" ] = %swimming_fire_U_extended;
	swimAnims[ "cover_corner_l" ][ "add_aim_idle" ] = %swimming_firing_idle;

	swimAnims[ "cover_u" ] = [];
	swimAnims[ "cover_u" ][ "straight_level" ] = %swimming_fire;
	swimAnims[ "cover_u" ][ "alert_idle" ] = %swimming_cover_u1_idle;
	swimAnims[ "cover_u" ][ "alert_to_A" ] = [ %swimming_cover_u1_full_expose ];
	swimAnims[ "cover_u" ][ "alert_to_B" ] = [ %swimming_cover_u1_full_expose ];
	swimAnims[ "cover_u" ][ "A_to_alert" ] = [ %swimming_cover_u1_full_hide];
	swimAnims[ "cover_u" ][ "A_to_B" ] = [ %swimming_fire ];
	swimAnims[ "cover_u" ][ "B_to_alert" ] = [ %swimming_cover_u1_full_hide ];
 	swimAnims[ "cover_u" ][ "B_to_A" ] = [ %swimming_fire ];
	swimAnims[ "cover_u" ][ "lean_to_alert" ] = [ %swimming_cover_u1_hide ];
	swimAnims[ "cover_u" ][ "alert_to_lean" ] = [ %swimming_cover_u1_expose ];
	swimAnims[ "cover_u" ][ "look" ] = %swimming_cover_u1_expose;
	swimAnims[ "cover_u" ][ "reload" ] = [ %swimming_cover_u1_reload ];

	swimAnims[ "cover_u" ][ "alert_to_look" ] = %swimming_cover_u1_expose;
	swimAnims[ "cover_u" ][ "look_to_alert" ] = %swimming_cover_u1_hide;
	swimAnims[ "cover_u" ][ "look_to_alert_fast" ] = %swimming_cover_u1_hide;
	swimAnims[ "cover_u" ][ "look_idle" ] = %swimming_cover_u1_exposed_idle;

	swimAnims[ "cover_u" ][ "lean_aim_down" ] = %swimming_cover_u1_exposed_aim_d;
	swimAnims[ "cover_u" ][ "lean_aim_left" ] = %swimming_cover_u1_exposed_aim_l;
	swimAnims[ "cover_u" ][ "lean_aim_straight" ] = %swimming_cover_u1_exposed_fire;
	swimAnims[ "cover_u" ][ "lean_aim_right" ] = %swimming_cover_u1_exposed_aim_r;
	swimAnims[ "cover_u" ][ "lean_aim_up" ] = %swimming_cover_u1_exposed_aim_u;
	swimAnims[ "cover_u" ][ "lean_reload" ] = %swimming_cover_u1_reload;
	swimAnims[ "cover_u" ][ "lean_idle" ] = [ %swimming_cover_u1_exposed_idle ];
	swimAnims[ "cover_u" ][ "lean_single" ] = %swimming_cover_u1_exposed_fire;
	swimAnims[ "cover_u" ][ "lean_fire" ] = %swimming_cover_u1_exposed_fire;

	swimAnims[ "cover_u" ][ "add_aim_down" ] = %swimming_fire_D;
	swimAnims[ "cover_u" ][ "add_aim_left" ] = %swimming_fire_L;
	swimAnims[ "cover_u" ][ "add_aim_straight" ] = %swimming_firing;
	swimAnims[ "cover_u" ][ "add_aim_right" ] = %swimming_fire_R;
	swimAnims[ "cover_u" ][ "add_aim_up" ] = %swimming_fire_U_extended;
	swimAnims[ "cover_u" ][ "add_aim_idle" ] = %swimming_firing_idle;

	anim.archetypes["soldier"]["swim"] = swimAnims;

	anim.archetypes["soldier"]["swim"]["maxDelta"] = [];

	init_swim_anim_deltas( "soldier", "arrival_exposed" );
	init_swim_anim_deltas( "soldier", "arrival_exposed_noncombat" );
	init_swim_anim_deltas( "soldier", "arrival_cover_corner_r" );
	init_swim_anim_deltas( "soldier", "arrival_cover_corner_l" );
	init_swim_anim_deltas( "soldier", "arrival_cover_u" );
	init_swim_anim_deltas( "soldier", "exit_cover_corner_r", false );
	init_swim_anim_deltas( "soldier", "exit_cover_corner_l", false );
	init_swim_anim_deltas( "soldier", "exit_cover_u", false );
	init_swim_anim_deltas( "soldier", "idle_to_forward", false );
}

init_swim_anim_deltas( archetype, animType, a_bMaxDelta )
{
	animType_delta = animType + "_delta";
	animType_angleDelta = animType + "_angleDelta";

	bMaxDelta = true;
	if ( IsDefined( a_bMaxDelta ) )
		bMaxDelta = a_bMaxDelta;

	anim.archetypes[archetype]["swim"][ animType_delta ] = [];
	foreach ( yaw, pitchArray in anim.archetypes[archetype]["swim"][ animType ] )
	{
		if ( !IsDefined( anim.archetypes[archetype]["swim"][ animType_delta ][ yaw ] ) )
		{
			anim.archetypes[archetype]["swim"][ animType_delta ][ yaw ] = [];
			anim.archetypes[archetype]["swim"][ animType_angleDelta ][ yaw ] = [];
		}

		maxDeltaSq = 0;

		foreach ( pitch, swimAnim in pitchArray )
		{
			delta = GetMoveDelta( swimAnim, 0, 1 );
			anim.archetypes[archetype]["swim"][ animType_delta ][ yaw ][ pitch ] = delta;
			anim.archetypes[archetype]["swim"][ animType_angleDelta ][ yaw ][ pitch ] = GetAngleDelta3D( swimAnim, 0, 1 );

			if ( bMaxDelta )
			{
				deltaDistSq = LengthSquared( delta );
				if ( deltaDistSq > maxDeltaSq )
					maxDeltaSq = deltaDistSq;
			}
		}
		if ( bMaxDelta )
			anim.archetypes[archetype]["swim"][animType]["maxDelta"] = sqrt( maxDeltaSq );
	}
}

init_ai_swim_animsets()
{
	self.customIdleAnimSet = [];
	self.customIdleAnimSet[ "stand" ] = %swimming_idle;
	
	self.a.pose = "stand";
	self allowedStances( "stand" );
	
	// combat animations
	animset = anim.archetypes["soldier"]["default_stand"];
	animset[ "straight_level" ] = %swimming_idle_ready;
	
	animset[ "add_aim_up" ] = %swimming_idle_ready_aim_u_extended;//%swimming_fire_U_extended;
	animset[ "add_aim_down" ] = %swimming_idle_ready_aim_d_extended;//%swimming_fire_D;
	animset[ "add_aim_left" ] = %swimming_idle_ready_aim_l;//%swimming_fire_L;
	animset[ "add_aim_right" ] = %swimming_idle_ready_aim_r;//%swimming_fire_R;

/*
	animset[ "fire" ] = %swimming_firing;
	animset[ "single" ] = [ %swimming_firing ];

	// remove this burst, semi nonsense soon
	animset[ "burst2" ] = %swimming_firing;
	animset[ "burst3" ] = %swimming_firing;
	animset[ "burst4" ] = %swimming_firing;
	animset[ "burst5" ] = %swimming_firing;
	animset[ "burst6" ] = %swimming_firing;
	animset[ "semi2" ] = %swimming_firing;
	animset[ "semi3" ] = %swimming_firing;
	animset[ "semi4" ] = %swimming_firing;
	animset[ "semi5" ] = %swimming_firing;
*/

	animset[ "exposed_idle" ] = undefined;//[ %exposed_idle_alert_v1 ];			// <-- get a swim idle twitch, yo'.
	animset[ "reload" ] = [ %swimming_reload ];
	animset[ "reload_crouchhide" ] = [ %swimming_reload ];
	
	animset[ "turn_left_45" ] = %swimming_aiming_turn_L45;
	animset[ "turn_left_90" ] = %swimming_aiming_turn_L90;
	animset[ "turn_left_135" ] = %swimming_aiming_turn_L135;
	animset[ "turn_left_180" ] = %swimming_aiming_turn_L180;
	animset[ "turn_right_45" ] = %swimming_aiming_turn_R45;
	animset[ "turn_right_90" ] = %swimming_aiming_turn_R90;
	animset[ "turn_right_135" ] = %swimming_aiming_turn_R135;
	animset[ "turn_right_180" ] = %swimming_aiming_turn_R180;
	
	self animscripts\animset::init_animset_complete_custom_stand( animset );
	self animscripts\animset::init_animset_complete_custom_crouch( animset );	
	
	self.painFunction = ::ai_swim_pain;
	self.deathFunction = ::ai_swim_death;
}


ai_swim_pain()
{
	if ( self.a.movement == "run" )
		painAnim = %swimming_pain_1;
	else
	{
		painAnim = random( [ %swimming_firing_pain_1, %swimming_firing_pain_2 ] );
	}
	// TEMP make all pain faster
	// rate = 1.5;
	rate = 1;

	self setFlaggedAnimKnobAllRestart( "painanim", painAnim, %body, 1, .1, rate );

	if ( self.a.pose == "prone" )
		self UpdateProne( %prone_legs_up, %prone_legs_down, 1, 0.1, 1 );

	if ( animHasNotetrack( painAnim, "start_aim" ) )
	{
		self thread animscripts\pain::notifyStartAim( "painanim" );
		self endon( "start_aim" );
	}

	if ( animHasNotetrack( painAnim, "code_move" ) )
		self animscripts\shared::DoNoteTracks( "painanim" );

	self animscripts\shared::DoNoteTracks( "painanim" );
}


unlimited_ammo()
{
	self endon( "death" );
	while( 1 )
	{
		self.a.rockets = 100;
		wait( 0.2 );
	}
}

ai_swim_death()
{
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), self, "j_spineupper" );
	if ( !isdefined( self.deathanim ) )
    {
		if ( ( self.damageyaw > - 60 ) && ( self.damageyaw <= 60 ) )
		{
			self.deathanim = %swimming_idle_death_behind;
		}
		else if ( self.a.movement == "run" )
		{
			self.deathanim = %swimming_death_1;
		}
		else
		{
			if ( animscripts\utility::damageLocationIsAny( "left_arm_upper" ) )
			{
				self.deathanim = %swimming_firing_death_1;
			}	
			else if ( animscripts\utility::damageLocationIsAny( "head", "helmet" ) )
			{
				self.deathanim = %swimming_firing_death_2;
			}
			else
			{
				self.deathanim = Random( [ %swimming_firing_death_1, %swimming_firing_death_2, %swimming_firing_death_3 ] );
			}
		}
    }
	if ( !isdefined( self.noDeathSound ) )
		self animscripts\death::PlayDeathSound();
	
	return false;
}

underwater_blood()
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction, point, damage_type );

		if ( damage_type != "MOD_EXPLOSIVE" )
		{
			if ( direction != (0,0,0) )
				PlayFX( getfx( "swim_ai_blood_impact" ), point, direction );
		}
	}
}

jumpIntoWater( target_pos )
{
	self endon( "death" );
	offset = ( 0, 0, 5 );
	
	start_z = level.water_level_z + 64;
	
	if ( !isdefined( target_pos ) )
	{
		start_pos = ( self.origin[0], self.origin[1], start_z );
		trace = BulletTrace( start_pos - (0,0,10), start_pos - (0,0,700), false, self );
		target_pos = trace[ "position" ];
    }
	else
	{
		start_pos = ( target_pos[0], target_pos[1], start_z );
	}
	
	start_pos += offset;
	
	mover = spawn_tag_origin();
	mover.origin = start_pos;
	
	mover2 = spawn_tag_origin();	
	
	self ForceTeleport( start_pos, self.angles );
	self linkTo( mover );
	
	mover2 linkTo( self, "tag_origin", (0,0,0), (90,0,0) );
	
	self Hide();
//	mover thread anim_generic_loop( self, "swimming_heli_deploy", "end_heli_deploy", "tag_origin" );
	mover thread anim_generic_first_frame( self, "swimming_heli_deploy_end", "tag_origin" );
	self script_delay();
	self Show();
	self.allowdeath = true;
	
	rate = 400;
	dist = start_z - target_pos[2];

	d2 = Min( dist - 100, dist * 0.9 );
	d1 = dist - d2;
	t1 = d1 / rate;
	t2 = d2 / (rate/2);
	self PlaySound( "enemy_water_splash" ); 
	PlayFX( getfx( "jump_into_water_splash" ), start_pos - (0,0,64), (0,0,-1), (1,0,0) );
	PlayFXOnTag( getfx( "jump_into_water_trail" ), mover2, "tag_origin" );
	
	/*
	mover moveZ( -1*d1, t1, 0, t1 * 0.4 );
	wait( t1 ); 
	*/
	mover moveZ( -1*d2, t2, 0, 0 );
	wait( t2*0.9 );
	/*
	mover moveZ( 32, 1, 0.5, 0.5 );
	wait( 1 );
	*/
	//mover notify( "end_heli_deploy" );
	mover notify( "stop_first_frame" );
	self notify( "stop_first_frame" );
	mover2 thread mover_delete();
	if ( isAlive( self ) )
	{
		self unlink();
		if ( !self.swimmer )
			self thread enable_swim();
	}
	self notify( "done_jumping_in" );
	//StopFXOnTag( getfx( "jump_into_water_trail" ), self, "j_spinelower" );
	if ( !flag_exist( "_stealth_spotted" ) || !flag( "_stealth_spotted" ) || !flag_exist( "_stealth_enabled" ) || !flag( "_stealth_enabled" ) )
	{
		self disable_exits();
		mover anim_generic_run( self, "swimming_heli_deploy_end" );
		mover delete();
		wait( 0.1 );
		self enable_exits();
	}
	else
	{
		mover delete();
	}
}

mover_delete()
{
	wait( 1.5 );
	StopFXOnTag( getfx( "jump_into_water_trail" ), self, "tag_origin" );
	wait( 1 );
	self unlink();
	wait( 1 );
	self delete();
}

glint_behavior()
{
	self notify( "new_glint_thread" );
	self endon( "new_glint_thread" );
	self endon( "stop_glint_thread" );
	self endon( "death" );
	
	if ( !isdefined( level._effect[ "sniper_glint" ] ) )
	{
		println( "^3Warning, sniper glint is not setup for sniper with classname " + self.classname );
		return;
	}
	
	if ( !isAlive( self.enemy ) )
		return;
	
	//if ( !isPlayer( self.enemy ) )
	//	return;
		
	fx = getfx( "sniper_glint" );
	
	wait 0.2;
		
	for ( ;; )
	{
		if ( self.weapon == self.primaryweapon && animscripts\combat_utility::player_sees_my_scope() && isdefined( self.enemy ) )
		{
			if ( distanceSquared( self.origin, self.enemy.origin ) > 256 * 256 )
				PlayFXOnTag( fx, self, "tag_eye" );
				
			timer = randomfloatrange( 3, 5 );
			wait( timer );
		}
		wait( 0.2 );
	}
}