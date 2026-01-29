#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

cSpaceOrientFrames = 1;
cForceOrientDelay = 6500;

#using_animtree( "generic_human" );
init_ai_space()
{
	level._effect[ "swim_ai_blood_impact"	]	= LoadFX( "fx/water/blood_spurt_underwater"		 );
	level._effect[ "swim_ai_death_blood"	]	= LoadFX( "fx/impacts/deathfx_bloodpool_underwater" );
	level._effect[ "swim_kick_bubble"		]	= LoadFX( "vfx/gameplay/footsteps/swim_kick_bubbles"	 );
	level._effect[ "jump_into_water_splash" ]	= LoadFX( "vfx/moments/ship_graveyard/bubbles_diver_drop_underwater"	 );
	level._effect[ "jump_into_water_trail"	]	= LoadFX( "fx/water/diver_jump_trail"				 );
	
	level.scr_anim[ "generic" ][ "swimming_heli_deploy" ][0] = %ship_graveyard_water_entry_idle;
	level.scr_anim[ "generic" ][ "swimming_heli_deploy_end" ] = %ship_graveyard_water_entry;
	
	// aliasing temp VFX for hits and deaths
    level._effect[ "fire_extinguisher_exp" ]    = loadfx( "fx/props/fire_extinguisher_exp" );
    level._effect[ "factory_roof_steam_small_01" ]  = loadfx( "fx/smoke/factory_roof_steam_small_01" );
    level._effect[ "sp_blood_float" ]           = loadfx( "vfx/moments/ODIN/sp_blood_float" );

    SetSavedDvar( "phys_gravity_ragdoll", 0 );
	SetSavedDVar( "phys_gravity", 0 );
	SetSavedDVar( "ragdoll_max_life", 15000 );
	SetSavedDVar( "phys_autoDisableLinear", 0.25 );
	
//	thread override_footsteps();
	
	battlechatter_off( "axis" );
}

enable_space()
{
	if ( !isAI( self ) )
		return;
	
	self.grenadeammo = 0;
	self.goalradius = 128;
	self.goalheight = 96;
	self.swimmer = true;
	self.space = true;
	
	//self disable_turnAnims();
	self disable_surprise();

	self thread unlimited_ammo();
	self thread glint_behavior();
	
	self.dontmelee					 = true;
	self.no_pistol_switch			 = true;
	self.ignoresuppression			 = true;
	self.noRunReload				 = true;
	self.disableBulletWhizbyReaction = true;
	self.useChokePoints				 = false;
	self.disableDoorBehavior		 = true;
	self.combatmode					 = "cover";
	self.oldgrenadeawareness		 = self.grenadeAwareness;
	self.grenadeAwareness			 = 0;
	self.oldGrenadeReturnThrow		 = self.noGrenadeReturnThrow;
	self.noGrenadeReturnThrow		 = true;
	self.noRunNGun					 = true;
	self.jumping					 = true;
	self.approachType				 = "";
	self disable_long_death();
	
	self init_ai_space_animsets();
	
	self thread space_blood();
	//self thread space_movement_thrusters();

	assert( IsDefined( anim.archetypes ) && IsDefined( anim.archetypes["soldier"] ) );
	if ( !IsDefined( anim.archetypes[ "soldier" ][ "swim" ] ) )
		init_space_anims();

	self animscripts\swim::Swim_Begin();

	// Initial orientation
	self thread init_actor_orientation( self.script_parameters );

	// Angled nodes
	self thread handle_angled_nodes();
}

disable_space()
{
	self.customMoveTransition = undefined;
	self.permanentCustomMoveTransition = false;

	self animscripts\swim::Swim_End();
	self notify( "stop_glint_thread" );
}

// required for animscripts/swim.gsc to work properly.
init_space_anims()
{
	swimAnims = [];

	swimAnims[ "forward" ] = %space_forward;
	swimAnims[ "forward_twitch" ] = %space_forward_twitch_1;
	swimAnims[ "forward_aim" ] = %space_aiming_move_F;

	swimAnims[ "idle_to_forward" ] = [];
	swimAnims[ "idle_to_forward" ][ 2 ] = [];
	swimAnims[ "idle_to_forward" ][ 2 ][ 4 ] = %space_idle_to_forward_l90;
	swimAnims[ "idle_to_forward" ][ 4 ] = [];
	swimAnims[ "idle_to_forward" ][ 4 ][ 2 ] = %space_idle_to_forward_u90;
	swimAnims[ "idle_to_forward" ][ 4 ][ 3 ] = %space_idle_to_forward_u45;
	swimAnims[ "idle_to_forward" ][ 4 ][ 4 ] = %space_idle_to_forward;
	swimAnims[ "idle_to_forward" ][ 4 ][ 5 ] = %space_idle_to_forward_d45;
	swimAnims[ "idle_to_forward" ][ 4 ][ 6 ] = %space_idle_to_forward_d90;
	swimAnims[ "idle_to_forward" ][ 6 ] = [];
	swimAnims[ "idle_to_forward" ][ 6 ][ 4 ] = %space_idle_to_forward_r90;

	swimAnims[ "idle_ready_to_forward" ] = [];
	swimAnims[ "idle_ready_to_forward" ][ 4 ] = [];
	swimAnims[ "idle_ready_to_forward" ][ 4 ][ 4 ] = %space_idle_ready_to_forward;

	swimAnims[ "aim_stand_D" ] = %space_fire_D;
	swimAnims[ "aim_stand_U" ] = %space_fire_U_extended;
	swimAnims[ "aim_stand_L" ] = %space_fire_L;
	swimAnims[ "aim_stand_R" ] = %space_fire_R;

	swimAnims[ "aim_move_R" ] = %space_aiming_move_f_fire_r;
	swimAnims[ "aim_move_L" ] = %space_aiming_move_f_fire_l;
	swimAnims[ "aim_move_U" ] = %space_aiming_move_f_fire_u_extended;
	swimAnims[ "aim_move_D" ] = %space_aiming_move_f_fire_d_extended;	//%space_aiming_move_f_fire_d

	swimAnims[ "strafe_B" ] = %space_aiming_move_B;
	swimAnims[ "strafe_L" ] = %space_aiming_move_L;
	swimAnims[ "strafe_R" ] = %space_aiming_move_R;

	swimAnims[ "strafe_L_aim_R" ] = %space_aiming_move_l_fire_r;
	swimAnims[ "strafe_L_aim_L" ] = %space_aiming_move_l_fire_l;
	swimAnims[ "strafe_L_aim_U" ] = %space_aiming_move_l_fire_u;
	swimAnims[ "strafe_L_aim_D" ] = %space_aiming_move_l_fire_d;

	swimAnims[ "strafe_R_aim_R" ] = %space_aiming_move_r_fire_r;
	swimAnims[ "strafe_R_aim_L" ] = %space_aiming_move_r_fire_l;
	swimAnims[ "strafe_R_aim_U" ] = %space_aiming_move_r_fire_u;
	swimAnims[ "strafe_R_aim_D" ] = %space_aiming_move_r_fire_d;

	swimAnims[ "strafe_B_aim_R" ] = %space_aiming_move_b_fire_r;
	swimAnims[ "strafe_B_aim_L" ] = %space_aiming_move_b_fire_l;
	swimAnims[ "strafe_B_aim_U" ] = %space_aiming_move_b_fire_u;
	swimAnims[ "strafe_B_aim_D" ] = %space_aiming_move_b_fire_d;

	swimAnims[ "turn_left_45" ] = %space_aiming_turn_L45;
	swimAnims[ "turn_left_90" ] = %space_aiming_turn_L90;
	swimAnims[ "turn_left_135" ] = %space_aiming_turn_L135;
	swimAnims[ "turn_left_180" ] = %space_aiming_turn_L180;
	swimAnims[ "turn_right_45" ] = %space_aiming_turn_R45;
	swimAnims[ "turn_right_90" ] = %space_aiming_turn_R90;
	swimAnims[ "turn_right_135" ] = %space_aiming_turn_R135;
	swimAnims[ "turn_right_180" ] = %space_aiming_turn_R180;

	swimAnims[ "idle_turn" ] = [];
	swimAnims[ "idle_turn" ][ 2 ] =  %space_idle_turn_90r;
	swimAnims[ "idle_turn" ][ 3 ] =  %space_idle_turn_45r;
	swimAnims[ "idle_turn" ][ 5 ] =  %space_idle_turn_45l;
	swimAnims[ "idle_turn" ][ 6 ] =  %space_idle_turn_90l;

	swimAnims[ "surprise_stop" ] = %space_surprise_stop;


	// swimAnims[ "arrival_*" ][ yaw ][ pitch ]
	// 45 degree increments, so...
	// -180, -135, -90, -45, 0, 45, 90, 135, 180
	swimAnims[ "arrival_cover_corner_r" ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 2 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 2 ][ 4 ] = %space_aiming_move_to_cover_r1_r90;
	swimAnims[ "arrival_cover_corner_r" ][ 3 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 3 ][ 3 ] = %space_aiming_move_to_cover_r1_r45_u45;
	swimAnims[ "arrival_cover_corner_r" ][ 3 ][ 4 ] = %space_aiming_move_to_cover_r1_r45;
	swimAnims[ "arrival_cover_corner_r" ][ 3 ][ 5 ] = %space_aiming_move_to_cover_r1_r45_d45;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 2 ] = %space_aiming_move_to_cover_r1_u90;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 3 ] = %space_aiming_move_to_cover_r1_u45;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 4 ] = %space_aiming_move_to_cover_r1;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 5 ] = %space_aiming_move_to_cover_r1_d45;
	swimAnims[ "arrival_cover_corner_r" ][ 4 ][ 6 ] = %space_aiming_move_to_cover_r1_d90;
	swimAnims[ "arrival_cover_corner_r" ][ 5 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 5 ][ 3 ] = %space_aiming_move_to_cover_r1_l45_u45;
	swimAnims[ "arrival_cover_corner_r" ][ 5 ][ 4 ] = %space_aiming_move_to_cover_r1_l45;
	swimAnims[ "arrival_cover_corner_r" ][ 5 ][ 5 ] = %space_aiming_move_to_cover_r1_l45_d45;
	swimAnims[ "arrival_cover_corner_r" ][ 6 ] = [];
	swimAnims[ "arrival_cover_corner_r" ][ 6 ][ 4 ] = %space_aiming_move_to_cover_r1_l90;

	swimAnims[ "arrival_cover_corner_l" ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 2 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 2 ][ 4 ] = %space_aiming_move_to_cover_l1_r90;
	swimAnims[ "arrival_cover_corner_l" ][ 3 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 3 ][ 3 ] = %space_aiming_move_to_cover_l1_r45_u45;
	swimAnims[ "arrival_cover_corner_l" ][ 3 ][ 4 ] = %space_aiming_move_to_cover_l1_r45;
	swimAnims[ "arrival_cover_corner_l" ][ 3 ][ 5 ] = %space_aiming_move_to_cover_l1_r45_d45;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 2 ] = %space_aiming_move_to_cover_l1_u90;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 3 ] = %space_aiming_move_to_cover_l1_u45;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 4 ] = %space_aiming_move_to_cover_l1;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 5 ] = %space_aiming_move_to_cover_l1_d45;
	swimAnims[ "arrival_cover_corner_l" ][ 4 ][ 6 ] = %space_aiming_move_to_cover_l1_d90;
	swimAnims[ "arrival_cover_corner_l" ][ 5 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 5 ][ 3 ] = %space_aiming_move_to_cover_l1_l45_u45;
	swimAnims[ "arrival_cover_corner_l" ][ 5 ][ 4 ] = %space_aiming_move_to_cover_l1_l45;
	swimAnims[ "arrival_cover_corner_l" ][ 5 ][ 5 ] = %space_aiming_move_to_cover_l1_l45_d45;
	swimAnims[ "arrival_cover_corner_l" ][ 6 ] = [];
	swimAnims[ "arrival_cover_corner_l" ][ 6 ][ 4 ] = %space_aiming_move_to_cover_l1_l90;

	swimAnims[ "arrival_cover_u" ] = [];
	swimAnims[ "arrival_cover_u" ][ 2 ] = [];
	swimAnims[ "arrival_cover_u" ][ 2 ][ 4 ] = %space_aiming_move_to_cover_u1_r90;
	swimAnims[ "arrival_cover_u" ][ 3 ] = [];
	swimAnims[ "arrival_cover_u" ][ 3 ][ 3 ] = %space_aiming_move_to_cover_u1_r45_u45;
	swimAnims[ "arrival_cover_u" ][ 3 ][ 4 ] = %space_aiming_move_to_cover_u1_r45;
	swimAnims[ "arrival_cover_u" ][ 3 ][ 5 ] = %space_aiming_move_to_cover_u1_r45_d45;
	swimAnims[ "arrival_cover_u" ][ 4 ] = [];
	swimAnims[ "arrival_cover_u" ][ 4 ][ 2 ] = %space_aiming_move_to_cover_u1_u90;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 3 ] = %space_aiming_move_to_cover_u1_u45;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 4 ] = %space_aiming_move_to_cover_u1;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 5 ] = %space_aiming_move_to_cover_u1_d45;
	swimAnims[ "arrival_cover_u" ][ 4 ][ 6 ] = %space_aiming_move_to_cover_u1_d90;
	swimAnims[ "arrival_cover_u" ][ 5 ] = [];
	swimAnims[ "arrival_cover_u" ][ 5 ][ 3 ] = %space_aiming_move_to_cover_u1_l45_u45;
	swimAnims[ "arrival_cover_u" ][ 5 ][ 4 ] = %space_aiming_move_to_cover_u1_l45;
	swimAnims[ "arrival_cover_u" ][ 5 ][ 5 ] = %space_aiming_move_to_cover_u1_l45_d45;
	swimAnims[ "arrival_cover_u" ][ 6 ] = [];
	swimAnims[ "arrival_cover_u" ][ 6 ][ 4 ] = %space_aiming_move_to_cover_u1_l90;

	swimAnims[ "arrival_exposed" ] = [];
	swimAnims[ "arrival_exposed" ][ 4 ] = [];
	swimAnims[ "arrival_exposed" ][ 4 ][ 4 ] = %space_forward_to_idle_ready;			//%space_forward_to_fire;
	
	// these anims are named as what direction he is swimming, not what direction he is coming from.
	swimAnims[ "arrival_exposed_noncombat" ] = [];
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ] = [];
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 2 ] = %space_forward_90d_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 3 ] = %space_forward_45d_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 4 ] = %space_forward_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 5 ] = %space_forward_45u_to_idle;
	swimAnims[ "arrival_exposed_noncombat" ][ 4 ][ 6 ] = %space_forward_90u_to_idle;

	swimAnims[ "exit_cover_corner_r" ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 2 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 2 ][ 4 ] = %space_cover_r1_to_aiming_move_r90;
	swimAnims[ "exit_cover_corner_r" ][ 3 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 3 ][ 3 ] = %space_cover_r1_to_aiming_move_r45_u45;
	swimAnims[ "exit_cover_corner_r" ][ 3 ][ 4 ] = %space_cover_r1_to_aiming_move_r45;
	swimAnims[ "exit_cover_corner_r" ][ 3 ][ 5 ] = %space_cover_r1_to_aiming_move_r45_d45;
	swimAnims[ "exit_cover_corner_r" ][ 4 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 2 ] = %space_cover_r1_to_aiming_move_u90;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 3 ] = %space_cover_r1_to_aiming_move_u45;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 4 ] = %space_cover_r1_to_aiming_move;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 5 ] = %space_cover_r1_to_aiming_move_d45;
	swimAnims[ "exit_cover_corner_r" ][ 4 ][ 6 ] = %space_cover_r1_to_aiming_move_d90;
	swimAnims[ "exit_cover_corner_r" ][ 5 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 5 ][ 3 ] = %space_cover_r1_to_aiming_move_l45_u45;
	swimAnims[ "exit_cover_corner_r" ][ 5 ][ 4 ] = %space_cover_r1_to_aiming_move_l45;
	swimAnims[ "exit_cover_corner_r" ][ 5 ][ 5 ] = %space_cover_r1_to_aiming_move_l45_d45;
	swimAnims[ "exit_cover_corner_r" ][ 6 ] = [];
	swimAnims[ "exit_cover_corner_r" ][ 6 ][ 4 ] = %space_cover_r1_to_aiming_move_l90;

	swimAnims[ "exit_cover_corner_l" ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 0 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 0 ][ 4 ] = %space_cover_l1_exit_r180;
	swimAnims[ "exit_cover_corner_l" ][ 2 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 2 ][ 4 ] = %space_cover_l1_to_aiming_move_r90;
	swimAnims[ "exit_cover_corner_l" ][ 3 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 3 ][ 3 ] = %space_cover_l1_to_aiming_move_r45_u45;
	swimAnims[ "exit_cover_corner_l" ][ 3 ][ 4 ] = %space_cover_l1_to_aiming_move_r45;
	swimAnims[ "exit_cover_corner_l" ][ 3 ][ 5 ] = %space_cover_l1_to_aiming_move_r45_d45;
	swimAnims[ "exit_cover_corner_l" ][ 4 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 2 ] = %space_cover_l1_to_aiming_move_u90;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 3 ] = %space_cover_l1_to_aiming_move_u45;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 4 ] = %space_cover_l1_to_aiming_move;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 5 ] = %space_cover_l1_to_aiming_move_d45;
	swimAnims[ "exit_cover_corner_l" ][ 4 ][ 6 ] = %space_cover_l1_to_aiming_move_d90;
	swimAnims[ "exit_cover_corner_l" ][ 5 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 5 ][ 3 ] = %space_cover_l1_to_aiming_move_l45_u45;
	swimAnims[ "exit_cover_corner_l" ][ 5 ][ 4 ] = %space_cover_l1_to_aiming_move_l45;
	swimAnims[ "exit_cover_corner_l" ][ 5 ][ 5 ] = %space_cover_l1_to_aiming_move_l45_d45;
	swimAnims[ "exit_cover_corner_l" ][ 6 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 6 ][ 4 ] = %space_cover_l1_to_aiming_move_l90;
	swimAnims[ "exit_cover_corner_l" ][ 8 ] = [];
	swimAnims[ "exit_cover_corner_l" ][ 8 ][ 4 ] = %space_cover_l1_exit_r180;

	swimAnims[ "exit_cover_u" ] = [];
	swimAnims[ "exit_cover_u" ][ 2 ] = [];
	swimAnims[ "exit_cover_u" ][ 2 ][ 4 ] = %space_cover_u1_to_aiming_move_r90;
	swimAnims[ "exit_cover_u" ][ 3 ] = [];
	swimAnims[ "exit_cover_u" ][ 3 ][ 3 ] = %space_cover_u1_to_aiming_move_r45_u45;
	swimAnims[ "exit_cover_u" ][ 3 ][ 4 ] = %space_cover_u1_to_aiming_move_r45;
	swimAnims[ "exit_cover_u" ][ 3 ][ 5 ] = %space_cover_u1_to_aiming_move_r45_d45;
	swimAnims[ "exit_cover_u" ][ 4 ] = [];
	swimAnims[ "exit_cover_u" ][ 4 ][ 2 ] = %space_cover_u1_to_aiming_move_u90;
	swimAnims[ "exit_cover_u" ][ 4 ][ 3 ] = %space_cover_u1_to_aiming_move_u45;
	swimAnims[ "exit_cover_u" ][ 4 ][ 4 ] = %space_cover_u1_to_aiming_move;
	swimAnims[ "exit_cover_u" ][ 4 ][ 5 ] = %space_cover_u1_to_aiming_move_d45;
	swimAnims[ "exit_cover_u" ][ 4 ][ 6 ] = %space_cover_u1_to_aiming_move_d90;
	swimAnims[ "exit_cover_u" ][ 5 ] = [];
	swimAnims[ "exit_cover_u" ][ 5 ][ 3 ] = %space_cover_u1_to_aiming_move_l45_u45;
	swimAnims[ "exit_cover_u" ][ 5 ][ 4 ] = %space_cover_u1_to_aiming_move_l45;
	swimAnims[ "exit_cover_u" ][ 5 ][ 5 ] = %space_cover_u1_to_aiming_move_l45_d45;
	swimAnims[ "exit_cover_u" ][ 6 ] = [];
	swimAnims[ "exit_cover_u" ][ 6 ][ 4 ] = %space_cover_u1_to_aiming_move_l90;

	swimAnims[ "turn" ] = [];
	// swimAnims[ "turns" ][ yaw ][ pitch ]
	swimAnims[ "turn" ] = [];
	swimAnims[ "turn" ][ 0 ] = [];
	swimAnims[ "turn" ][ 0 ][ 4 ] = %space_swim_turn_l180;
	swimAnims[ "turn" ][ 1 ] = [];
	swimAnims[ "turn" ][ 1 ][ 4 ] = %space_swim_turn_l135;
	swimAnims[ "turn" ][ 2 ] = [];
	swimAnims[ "turn" ][ 2 ][ 4 ] = %space_swim_turn_l90;
	swimAnims[ "turn" ][ 3 ] = [];
	swimAnims[ "turn" ][ 3 ][ 3 ] = %space_swim_turn_D45_L45;
	swimAnims[ "turn" ][ 3 ][ 4 ] = %space_swim_turn_L45;
	swimAnims[ "turn" ][ 3 ][ 5 ] = %space_swim_turn_U45_L45;
	swimAnims[ "turn" ][ 4 ] = [];
	swimAnims[ "turn" ][ 4 ][ 3 ] = %space_swim_turn_D45;
	swimAnims[ "turn" ][ 4 ][ 5 ] = %space_swim_turn_U45;
	swimAnims[ "turn" ][ 5 ] = [];
	swimAnims[ "turn" ][ 5 ][ 3 ] = %space_swim_turn_D45_R45;
	swimAnims[ "turn" ][ 5 ][ 4 ] = %space_swim_turn_R45;
	swimAnims[ "turn" ][ 5 ][ 5 ] = %space_swim_turn_U45_R45;
	swimAnims[ "turn" ][ 6 ] = [];
	swimAnims[ "turn" ][ 6 ][ 4 ] = %space_swim_turn_r90;
	swimAnims[ "turn" ][ 7 ] = [];
	swimAnims[ "turn" ][ 7 ][ 4 ] = %space_swim_turn_r135;
	swimAnims[ "turn" ][ 8 ] = [];
	swimAnims[ "turn" ][ 8 ][ 4 ] = %space_swim_turn_l180;

	swimAnims[ "turn_add_r" ] = %space_slight_turn_R;
	swimAnims[ "turn_add_l" ] = %space_slight_turn_L;
	swimAnims[ "turn_add_u" ] = %space_slight_turn_U;
	swimAnims[ "turn_add_d" ] = %space_slight_turn_D;

	swimAnims[ "cover_corner_r" ] = [];
	swimAnims[ "cover_corner_r" ][ "straight_level" ] = %space_fire;
	swimAnims[ "cover_corner_r" ][ "alert_idle" ] = %space_cover_r1_loop;
	swimAnims[ "cover_corner_r" ][ "alert_to_A" ] = [ %space_cover_r1_full_expose ];
	swimAnims[ "cover_corner_r" ][ "alert_to_B" ] = [ %space_cover_r1_full_expose ];
	swimAnims[ "cover_corner_r" ][ "A_to_alert" ] = [ %space_cover_r1_full_hide];
	//swimAnims[ "cover_corner_r" ][ "A_to_alert_reload" ] = [];
	swimAnims[ "cover_corner_r" ][ "A_to_B" ] = [ %space_fire ];
	swimAnims[ "cover_corner_r" ][ "B_to_alert" ] = [ %space_cover_r1_full_hide ];
	//swimAnims[ "cover_corner_r" ][ "B_to_alert_reload" ] = [];
 	swimAnims[ "cover_corner_r" ][ "B_to_A" ] = [ %space_fire ];
	swimAnims[ "cover_corner_r" ][ "lean_to_alert" ] = [ %space_cover_r1_hide ];
	swimAnims[ "cover_corner_r" ][ "alert_to_lean" ] = [ %space_cover_r1_expose ];
	swimAnims[ "cover_corner_r" ][ "look" ] = %space_cover_r1_expose;
	swimAnims[ "cover_corner_r" ][ "reload" ] = [ %space_cover_r1_reload ];//array( %corner_standL_reload_v1 );// , %corner_standL_reload_v2 );
	//swimAnims[ "cover_corner_r" ][ "alert_to_over" ] = [ %space_cover_r1_expose ];
	//swimAnims[ "cover_corner_r" ][ "over_to_alert" ] = [ %space_cover_r1_hide ];
	//swimAnims[ "cover_corner_r" ][ "over_idle" ] = [ %space_cover_r1_exposed_idle ];

	//swimAnims[ "cover_corner_r" ][ "blind_fire" ] = [];
	
	swimAnims[ "cover_corner_r" ][ "alert_to_look" ] = %space_cover_r1_alert_to_look;		//%space_cover_r1_expose
	swimAnims[ "cover_corner_r" ][ "look_to_alert" ] = %space_cover_r1_look_to_alert;		//%space_cover_r1_hide
	swimAnims[ "cover_corner_r" ][ "look_to_alert_fast" ] = %space_cover_r1_look_to_alert;	//%space_cover_r1_hide
	swimAnims[ "cover_corner_r" ][ "look_idle" ] = %space_cover_r1_look_idle;				//%space_cover_r1_exposed_idle
	//swimAnims[ "cover_corner_r" ][ "stance_change" ] = %space_cover_r1_loop;

	swimAnims[ "cover_corner_r" ][ "lean_aim_down" ] = %space_cover_r1_exposed_aim_d;
	swimAnims[ "cover_corner_r" ][ "lean_aim_left" ] = %space_cover_r1_exposed_aim_l;
	swimAnims[ "cover_corner_r" ][ "lean_aim_straight" ] = %space_cover_r1_exposed_fire;
	swimAnims[ "cover_corner_r" ][ "lean_aim_right" ] = %space_cover_r1_exposed_aim_r;
	swimAnims[ "cover_corner_r" ][ "lean_aim_up" ] = %space_cover_r1_exposed_aim_u;
	swimAnims[ "cover_corner_r" ][ "lean_reload" ] = %space_cover_r1_reload;
	swimAnims[ "cover_corner_r" ][ "lean_idle" ] = [ %space_cover_r1_exposed_idle ];
	swimAnims[ "cover_corner_r" ][ "lean_single" ] = %space_cover_r1_exposed_fire;
	swimAnims[ "cover_corner_r" ][ "lean_fire" ] = %space_cover_r1_exposed_fire;


	swimAnims[ "cover_corner_r" ][ "add_aim_down" ] = %space_fire_D;
	swimAnims[ "cover_corner_r" ][ "add_aim_left" ] = %space_fire_L;
	swimAnims[ "cover_corner_r" ][ "add_aim_straight" ] = %space_firing;
	swimAnims[ "cover_corner_r" ][ "add_aim_right" ] = %space_fire_R;
	swimAnims[ "cover_corner_r" ][ "add_aim_up" ] = %space_fire_U_extended;
	swimAnims[ "cover_corner_r" ][ "add_aim_idle" ] = %space_firing_idle;

	swimAnims[ "cover_corner_l" ] = [];

	swimAnims[ "cover_corner_l" ][ "straight_level" ] = %space_fire;
	swimAnims[ "cover_corner_l" ][ "alert_idle" ] = %space_cover_l1_idle;
	swimAnims[ "cover_corner_l" ][ "alert_to_A" ] = [ %space_cover_l1_full_expose ];
	swimAnims[ "cover_corner_l" ][ "alert_to_B" ] = [ %space_cover_l1_full_expose ];
	swimAnims[ "cover_corner_l" ][ "A_to_alert" ] = [ %space_cover_l1_full_hide];
	swimAnims[ "cover_corner_l" ][ "A_to_B" ] = [ %space_fire ];
	swimAnims[ "cover_corner_l" ][ "B_to_alert" ] = [ %space_cover_l1_full_hide ];
 	swimAnims[ "cover_corner_l" ][ "B_to_A" ] = [ %space_fire ];
	swimAnims[ "cover_corner_l" ][ "lean_to_alert" ] = [ %space_cover_l1_hide ];
	swimAnims[ "cover_corner_l" ][ "alert_to_lean" ] = [ %space_cover_l1_expose ];
	swimAnims[ "cover_corner_l" ][ "look" ] = %space_cover_l1_expose;
	swimAnims[ "cover_corner_l" ][ "reload" ] = [ %space_cover_l1_reload ];

	swimAnims[ "cover_corner_l" ][ "alert_to_look" ] = %space_cover_l1_alert_to_look;		//%space_cover_l1_expose
	swimAnims[ "cover_corner_l" ][ "look_to_alert" ] = %space_cover_l1_look_to_alert;		//%space_cover_l1_hide
	swimAnims[ "cover_corner_l" ][ "look_to_alert_fast" ] = %space_cover_l1_look_to_alert;	//%space_cover_l1_hide
	swimAnims[ "cover_corner_l" ][ "look_idle" ] = %space_cover_l1_look_idle; 				//%space_cover_l1_exposed_idle

	swimAnims[ "cover_corner_l" ][ "lean_aim_down" ] = %space_cover_l1_exposed_aim_d;
	swimAnims[ "cover_corner_l" ][ "lean_aim_left" ] = %space_cover_l1_exposed_aim_l;
	swimAnims[ "cover_corner_l" ][ "lean_aim_straight" ] = %space_cover_l1_exposed_fire;
	swimAnims[ "cover_corner_l" ][ "lean_aim_right" ] = %space_cover_l1_exposed_aim_r;
	swimAnims[ "cover_corner_l" ][ "lean_aim_up" ] = %space_cover_l1_exposed_aim_u;
	swimAnims[ "cover_corner_l" ][ "lean_reload" ] = %space_cover_l1_reload;
	swimAnims[ "cover_corner_l" ][ "lean_idle" ] = [ %space_cover_l1_exposed_idle ];
	swimAnims[ "cover_corner_l" ][ "lean_single" ] = %space_cover_l1_exposed_fire;
	swimAnims[ "cover_corner_l" ][ "lean_fire" ] = %space_cover_l1_exposed_fire;

	swimAnims[ "cover_corner_l" ][ "add_aim_down" ] = %space_fire_D;
	swimAnims[ "cover_corner_l" ][ "add_aim_left" ] = %space_fire_L;
	swimAnims[ "cover_corner_l" ][ "add_aim_straight" ] = %space_firing;
	swimAnims[ "cover_corner_l" ][ "add_aim_right" ] = %space_fire_R;
	swimAnims[ "cover_corner_l" ][ "add_aim_up" ] = %space_fire_U_extended;
	swimAnims[ "cover_corner_l" ][ "add_aim_idle" ] = %space_firing_idle;

	swimAnims[ "cover_u" ] = [];
	swimAnims[ "cover_u" ][ "straight_level" ] = %space_fire;
	swimAnims[ "cover_u" ][ "alert_idle" ] = %space_cover_u1_idle;
	swimAnims[ "cover_u" ][ "alert_to_A" ] = [ %space_cover_u1_full_expose ];
	swimAnims[ "cover_u" ][ "alert_to_B" ] = [ %space_cover_u1_full_expose ];
	swimAnims[ "cover_u" ][ "A_to_alert" ] = [ %space_cover_u1_full_hide];
	swimAnims[ "cover_u" ][ "A_to_B" ] = [ %space_fire ];
	swimAnims[ "cover_u" ][ "B_to_alert" ] = [ %space_cover_u1_full_hide ];
 	swimAnims[ "cover_u" ][ "B_to_A" ] = [ %space_fire ];
	swimAnims[ "cover_u" ][ "lean_to_alert" ] = [ %space_cover_u1_hide ];
	swimAnims[ "cover_u" ][ "alert_to_lean" ] = [ %space_cover_u1_expose ];
	swimAnims[ "cover_u" ][ "look" ] = %space_cover_u1_expose;
	swimAnims[ "cover_u" ][ "reload" ] = [ %space_cover_u1_reload ];

	swimAnims[ "cover_u" ][ "alert_to_look" ] = %space_cover_u1_alert_to_look;			//%space_cover_u1_expose
	swimAnims[ "cover_u" ][ "look_to_alert" ] = %space_cover_u1_look_to_alert;			//%space_cover_u1_hide
	swimAnims[ "cover_u" ][ "look_to_alert_fast" ] = %space_cover_u1_look_to_alert;		//%space_cover_u1_hide
	swimAnims[ "cover_u" ][ "look_idle" ] = %space_cover_u1_look_idle;					//%space_cover_u1_exposed_idle

	swimAnims[ "cover_u" ][ "lean_aim_down" ] = %space_cover_u1_exposed_aim_d;
	swimAnims[ "cover_u" ][ "lean_aim_left" ] = %space_cover_u1_exposed_aim_l;
	swimAnims[ "cover_u" ][ "lean_aim_straight" ] = %space_cover_u1_exposed_fire;
	swimAnims[ "cover_u" ][ "lean_aim_right" ] = %space_cover_u1_exposed_aim_r;
	swimAnims[ "cover_u" ][ "lean_aim_up" ] = %space_cover_u1_exposed_aim_u;
	swimAnims[ "cover_u" ][ "lean_reload" ] = %space_cover_u1_reload;
	swimAnims[ "cover_u" ][ "lean_idle" ] = [ %space_cover_u1_exposed_idle ];
	swimAnims[ "cover_u" ][ "lean_single" ] = %space_cover_u1_exposed_fire;
	swimAnims[ "cover_u" ][ "lean_fire" ] = %space_cover_u1_exposed_fire;

	swimAnims[ "cover_u" ][ "add_aim_down" ] = %space_fire_D;
	swimAnims[ "cover_u" ][ "add_aim_left" ] = %space_fire_L;
	swimAnims[ "cover_u" ][ "add_aim_straight" ] = %space_firing;
	swimAnims[ "cover_u" ][ "add_aim_right" ] = %space_fire_R;
	swimAnims[ "cover_u" ][ "add_aim_up" ] = %space_fire_U_extended;
	swimAnims[ "cover_u" ][ "add_aim_idle" ] = %space_firing_idle;

	anim.archetypes["soldier"]["swim"] = swimAnims;

	anim.archetypes["soldier"]["swim"]["maxDelta"] = [];

	init_space_anim_deltas( "soldier", "arrival_exposed" );
	init_space_anim_deltas( "soldier", "arrival_exposed_noncombat" );
	init_space_anim_deltas( "soldier", "arrival_cover_corner_r" );
	init_space_anim_deltas( "soldier", "arrival_cover_corner_l" );
	init_space_anim_deltas( "soldier", "arrival_cover_u" );
	init_space_anim_deltas( "soldier", "exit_cover_corner_r", false );
	init_space_anim_deltas( "soldier", "exit_cover_corner_l", false );
	init_space_anim_deltas( "soldier", "exit_cover_u", false );
	init_space_anim_deltas( "soldier", "idle_to_forward", false );
}

init_space_anim_deltas( archetype, animType, a_bMaxDelta )
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

init_ai_space_animsets()
{
	self.customIdleAnimSet = [];
	self.customIdleAnimSet[ "stand" ] = %space_idle;
	
	self.a.pose = "stand";
	self allowedStances( "stand" );
	
	// combat animations
	animset = anim.archetypes["soldier"]["default_stand"];
	animset[ "straight_level" ] = %space_idle_ready;

	animset[ "add_aim_up" ] = %space_idle_ready_aim_u_extended;			//%space_fire_U_extended;
	animset[ "add_aim_down" ] = %space_idle_ready_aim_d_extended;		//%space_fire_D;
	animset[ "add_aim_left" ] = %space_idle_ready_aim_l;				//%space_fire_L;
	animset[ "add_aim_right" ] = %space_idle_ready_aim_r;				//%space_fire_R;

	animset[ "fire" ] = %space_firing;
	animset[ "single" ] = [ %space_firing ];
	animset[ "burst2" ] = %space_firing;
	animset[ "burst3" ] = %space_firing;
	animset[ "burst4" ] = %space_firing;
	animset[ "burst5" ] = %space_firing;
	animset[ "burst6" ] = %space_firing;
	animset[ "semi2" ] = %space_firing;
	animset[ "semi3" ] = %space_firing;
	animset[ "semi4" ] = %space_firing;
	animset[ "semi5" ] = %space_firing;

	animset[ "exposed_idle" ] = [ %exposed_idle_alert_v1 ];			// <-- get a swim idle twitch, yo'.
	animset[ "reload" ] = [ %space_reload ];
	animset[ "reload_crouchhide" ] = [ %space_reload ];
	
	animset[ "turn_left_45" ] = %space_aiming_turn_L45;
	animset[ "turn_left_90" ] = %space_aiming_turn_L90;
	animset[ "turn_left_135" ] = %space_aiming_turn_L135;
	animset[ "turn_left_180" ] = %space_aiming_turn_L180;
	animset[ "turn_right_45" ] = %space_aiming_turn_R45;
	animset[ "turn_right_90" ] = %space_aiming_turn_R90;
	animset[ "turn_right_135" ] = %space_aiming_turn_R135;
	animset[ "turn_right_180" ] = %space_aiming_turn_R180;
	
	self animscripts\animset::init_animset_complete_custom_stand( animset );
	self animscripts\animset::init_animset_complete_custom_crouch( animset );	
	
	self.painFunction = ::ai_swim_pain;
	self.deathFunction = ::ai_space_death;
}


ai_swim_pain()
{
	if ( self.a.movement == "run" )
		painAnim = %space_pain_1;
	else
	{
		painAnim = random( [ %space_firing_pain_1, %space_firing_pain_2 ] );
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

ai_space_death()
{
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), self, "j_spineupper" );
	PlayFXOnTag( getfx( "sp_blood_float" ), self, "j_spineupper" );
	PlayFXOnTag( getfx( "factory_roof_steam_small_01" ), self, "j_spineupper" );
	if ( !isdefined( self.deathanim ) )
    {
		if ( ( self.damageyaw > - 60 ) && ( self.damageyaw <= 60 ) )
		{
			self.deathanim = %space_idle_death_behind;
		}
		else if ( self.a.movement == "run" )
		{
			self.deathanim = %space_death_1;
		}
		else
		{
			if ( animscripts\utility::damageLocationIsAny( "left_arm_upper" ) )
			{
				self.deathanim = %space_firing_death_1;
			}	
			else if ( animscripts\utility::damageLocationIsAny( "head", "helmet" ) )
			{
				self.deathanim = %space_firing_death_2;
			}
			else
			{
				self.deathanim = Random( [ %space_firing_death_1, %space_firing_death_2, %space_firing_death_3 ] );
			}
		}
    }
	if ( !isdefined( self.noDeathSound ) )
		self animscripts\death::PlayDeathSound();
	thread spawn_space_death_impulse (self.origin);
	return false;
}

spawn_space_death_impulse (impulse_origin)
{
	wait RandomFloatRange (0.1, 2);
    new_model = spawn_tag_origin();
    new_model.origin = impulse_origin+(RandomFloatRange(-10,10),RandomFloatRange(-10,10),RandomFloatRange(-10,10));
	//IPrintLnBold ("dying impulse");
	physicsexplosionsphere ( new_model.origin, 525, 120, RandomFloatRange(0.3,2) );
	PlayFX( getfx( "fire_extinguisher_exp" ), new_model.origin );
	new_model delete();
}

space_blood()
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction, point, damage_type );

		if ( damage_type != "MOD_EXPLOSIVE" )
		{
			if ( direction != (0,0,0) )
				PlayFX( getfx( "swim_ai_blood_impact" ), point, direction );
				//PlayFX( getfx( "sp_blood_float" ), point, direction );
		}
	}
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

//================================================================================================
//	3D MOVEMENT
//================================================================================================
// Rotates a guy to match angled nodes
handle_angled_nodes()
{
	self endon( "death" );
	self.current_node_orientation = (0,0,0);
	self.nextForceOrientTime = ( getTime() + cForceOrientDelay );
	self thread force_rotation_update_listener();

	// Go to node and rotate
	current_node = self.node;
	while( 1 )
	{
		if( isDefined( self.node ))
		{
			update_orient = false;
			if( !isDefined( current_node ))
		   	{
		   		update_orient = true;
		   	}

			// Current node has changed
			if( isDefined( current_node ) && ( self.node != current_node ))
		   	{
				if( isDefined( current_node.script_angles ) && ( current_node.script_angles != self.current_node_orientation ))
				{
					update_orient = true;
				}
			}

			// Check the orientation of the current node
			if( update_orient )
			{
				current_node = self.node;
				if( isDefined( current_node.script_angles ))
				{
					new_angles = current_node.script_angles;
					self.current_node_orientation = new_angles;

					while( isDefined( self.node ) && distance( self.origin, self.node.origin ) > 92 )
					{
						wait 0.1;
					}
					
					if( isDefined( self.node ))
					{
						//self waittill( "goal" );
						self notify( "stop_rotation" );

						//iprintlnbold( "Rotating too: " + new_angles[0] + ", " + new_angles[1] + ", " + new_angles[2] );
						self thread doing_in_space_rotation( self.angles, self.node.script_angles, cSpaceOrientFrames );
					}
				}
		   	}
		}
		wait 0.1;
	}
}

// Orient an actor to the given orientation right away
init_actor_orientation( orient_parameters )
{
	if( !isDefined( orient_parameters ))
	{
		return;
	}
	if( !isDefined( self.current_node_orientation ))
	{
		self.current_node_orientation = (0,0,0);
	}

	//orient_parameters
	angles = ( self.angles[0], self.angles[1], 0);
	self thread doing_in_space_rotation( self.angles, angles, cSpaceOrientFrames );
}

doing_in_space_rotation( start_angles, end_angles, num_frame )
{
	self endon( "stop_rotation" );
	self endon( "death" );
	
	//for ( i = 0; i < num_frame; i++ )
	//{
	//	frame_angles = fake_slerp( start_angles, end_angles, i / num_frame );
	//	self OrientMode( "face angle 3d", frame_angles, 1 );
	//	wait 0.05;
	//}

	self OrientMode( "face angle 3d", end_angles, 1 );
}

fake_slerp( from, to, fraction )
{
   return (
          angle_lerp(from[0], to[0], fraction),
          angle_lerp(from[1], to[1], fraction),
          angle_lerp(from[2], to[2], fraction)
   );
}

angle_lerp( from, to, fraction )
{
	return AngleClamp( from + AngleClamp180( to - from ) * fraction );
}

// Re-orient an actor to the given angles
set_actor_space_rotation( angles, immediate )
{
	frames = cSpaceOrientFrames;
	if( isDefined( immediate ))
	{
		frames = 1;
	}
	self thread doing_in_space_rotation( self.angles, angles, frames );
}

// Force an orientation update
force_actor_space_rotation_update( check_time, blocking )
{
	// Enough time since last force orient?
	if( isDefined( check_time ) && check_time )
	{
		if( !isDefined( self.nextForceOrientTime ) || ( gettime() < self.nextForceOrientTime ))
		{
			return;
		}
	}

	// Does the actor have a current node?
	if( !isDefined( self.current_node_orientation ))
	{
		return;
	}

	new_angles = ( 0,0,0 );
	if( isDefined( self.node ))
	{
		new_angles = self.node.script_angles;
	}
	else
	{
		return;
	}

	// Only re-align if actor is more than 12 degree off his goal angles
	if( self angles_within( self.node.script_angles, 12, 12, 12 ))
	{
		return;
	}

	// Account for cover nodes with angleDeltas
	if( self.node.type == "Cover Right 3D" )
	{
		new_angles = ( new_angles[0], new_angles[1] + self.hideYawOffset, new_angles[2] );
	}
	else if( self.node.type == "Cover Left 3D" )
	{
		new_angles = ( new_angles[0], new_angles[1] + self.hideYawOffset, new_angles[2] );
	}

	//iprintlnbold( "forced orient: (" + new_angles[0] + "," + new_angles[1] + "," + new_angles[2] + ")" );

	// Blocking thread
	if( isDefined( blocking ) && blocking )
	{
		self doing_in_space_rotation( self.angles, new_angles, cSpaceOrientFrames ); 
	}
	// Non blocking thread
	else
	{
		self thread doing_in_space_rotation( self.angles, new_angles, cSpaceOrientFrames ); 
	}

	if( isDefined( self.nextForceOrientTime ))
	{
		self.nextForceOrientTime = ( getTime() + cForceOrientDelay );
	}
}

force_rotation_update_listener()
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "force_space_rotation_update", check_time, blocking );
		self force_actor_space_rotation_update( check_time, blocking );
	}
}

// Checks if self.angles is within x,y,z of the given angles
angles_within( angles, x, y, z )
{
	//x
	if( self.angles[0] < ( angles[0] + x ) && self.angles[0] > angles[0] - x )
	{
		// y
		if( self.angles[1] < ( angles[1] + y ) && self.angles[1] > angles[1] - y )
		{
			// z
			if( self.angles[2] < ( angles[2] + z ) && self.angles[2] > angles[2] - z )
			{
				return true;
			}
		}
	}
	return false;
}

// Returns an actor to upright orientation
clear_actor_space_rotation()
{
	self thread doing_in_space_rotation( self.angles, (self.angles[0], self.angles[1], 0 ), cSpaceOrientFrames );
}


/*
// JR - FIXME - Work in progress
force_more_exposed_time()
{
	self endon( "death" );
	self endon( "stop_force_more_exposed_time" );

	// Init
	peekTime = 0;
	//lookTime = self.nextAllowedLookTime;
	boredTime = 0;

	// loop and watch for changes
	while( 1 )
	{
		tP = 0;
		tL = 0;
		tB = 0;

		// Detect change in peekTime
		if( isDefined( self.nextPeekOutAttemptTime ) && peekTime != self.nextPeekOutAttemptTime )
		{
			peekTime = self.nextPeekOutAttemptTime;
			iprintlnbold( "peekTime change detected: " + peekTime );
			tP = peekTime;
		}

		// Detect change in lookTime
		//if( isDefined( self.nextAllowedLookTime ) && lookTime != self.nextAllowedLookTime )
		//{
		//	lookTime = self.nextAllowedLookTime;
		//	iprintlnbold( "lookTime change detected: " + lookTime );
		//	tL = peekTime;
		//}

		// Detect change in boredTime
		if( isDefined( self.a.getBoredOfThisNodeTime ) && boredTime != self.a.getBoredOfThisNodeTime )
		{
			boredTime = self.a.getBoredOfThisNodeTime;
			iprintlnbold( "boredTime change detected: " + boredTime );
			tB = peekTime;
		}

		//iprintlnbold( "p: " + tP + " l: " + tL + " b: " + tB );

		wait 0.1;
	}

}
*/