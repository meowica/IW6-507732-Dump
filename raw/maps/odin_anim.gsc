#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_vignette_util;

main()
{
	generic_human();
	script_model();
	player();
	vehicles();
	dialog();
	
}

#using_animtree( "generic_human" );
generic_human()
{
	level.scr_anim[ "generic" ][ "traverse_inverted_192"  ] = %space_traversal_jump_180_U;
	
	//hall escape turn anims
	level.scr_anim[ "odin_ally" ][ "odin_hall_escape_turn01_ally" ] = %odin_hallway_escape_turn01_ally01;
	level.scr_anim[ "odin_ally" ][ "odin_hall_escape_turn02_ally" ] = %odin_hallway_escape_turn02_ally01;
	
	level.scr_anim[ "firstEnemy" ][ "harbor_floating_struggle_02" ] = %harbor_floating_struggle_02;
	level.scr_anim[ "odin_ally" ][ "space_pain_1" ] = %space_pain_1;
	
	// Intro
	level.scr_anim[ "odin_ally" ][ "odin_intro_kyra_satellite_idle" ][ 0 ] = %odin_intro_kyra_satellite_idle;
	level.scr_anim[ "odin_ally" ][ "intro_exterior_scene" ] = %odin_intro_kyra;
	level.scr_anim[ "odin_ally" ][ "odin_intro_kyra_idle" ][ 0 ] = %odin_intro_kyra_idle;
	level.scr_anim[ "odin_ally" ][ "odin_intro_kyra_move_to_door" ] = %odin_intro_kyra_move_to_door;
	level.scr_anim[ "odin_ally" ][ "odin_intro_kyra_door_idle" ][ 0 ] = %odin_intro_kyra_door_idle;
	
	level.scr_anim[ "odin_ally" ][ "odin_infiltrate_kyra_entrance" ] = %odin_infiltrate_kyra_entrance;
	level.scr_anim[ "odin_ally" ][ "odin_infiltrate_kyra_midpoint_idle" ][ 0 ] = %odin_infiltrate_kyra_midpoint_idle;
	
	level.scr_anim[ "odin_ally" ][ "odin_infiltrate_kyra_to_door" ] = %odin_infiltrate_kyra_to_door;
	level.scr_anim[ "odin_ally" ][ "odin_infiltrate_kyra_door_idle" ][ 0 ] = %odin_infiltrate_kyra_door_idle;
	
	level.scr_anim[ "odin_ally" ][ "odin_infiltrate_kyra" ] = %odin_infiltrate_kyra;
	level.scr_anim[ "odin_ally" ][ "odin_infiltrate_kyra_escape_idle" ][ 0 ] = %odin_infiltrate_kyra_escape_idle;
	
	//Odin Intro attack scene
	level.scr_anim[ "odin_invader_01" ][ "odin_infiltrate" ] = %odin_infiltrate_baddy_01;
	level.scr_anim[ "odin_invader_02" ][ "odin_infiltrate" ] = %odin_infiltrate_baddy_02;
	level.scr_anim[ "odin_invader_03" ][ "odin_infiltrate" ] = %odin_infiltrate_baddy_03;
	level.scr_anim[ "odin_invader_04" ][ "odin_infiltrate" ] = %odin_infiltrate_baddy_04;
	level.scr_anim[ "odin_invader_05" ][ "odin_infiltrate" ] = %odin_infiltrate_baddy_05;
	level.scr_anim[ "odin_invader_06" ][ "odin_infiltrate" ] = %odin_infiltrate_baddy_06;
	level.scr_anim[ "odin_victim_01" ][ "odin_infiltrate" ] = %odin_infiltrate_red_shirt_01;
	level.scr_anim[ "odin_victim_02" ][ "odin_infiltrate" ] = %odin_infiltrate_red_shirt_02;
	
	
	level.scr_animtree[ "odin_opfor" ] = #animtree;
	level.scr_anim[ "odin_opfor" ][ "gun_struggle_intro_throw" ] = %odin_intro_to_weapon_begin_struggle_opfor;
	level.scr_model[ "odin_opfor" ] = "fed_space_assault_body";
	// Ally Section
	//gun struggle intro anims
	level.scr_anim[ "odin_ally" ][ "gun_struggle_intro" ] = %odin_intro_to_weapon_struggle_ally;
	level.scr_anim[ "odin_opfor" ][ "gun_struggle_intro" ] = %odin_intro_to_weapon_struggle_opfor;
	level.scr_anim[ "odin_redshirt" ][ "gun_struggle_intro" ] = %odin_intro_to_weapon_struggle_redshirt;
		
	level.scr_anim[ "odin_ally" ][ "gun_struggle_intro_loop" ][0] = %odin_intro_to_weapon_struggle_loop_ally;
	level.scr_anim[ "odin_opfor" ][ "gun_struggle_intro_loop" ][0] = %odin_intro_to_weapon_struggle_loop_opfor;
	
	level.scr_anim[ "odin_ally" ][ "gun_struggle_intro_throw" ] = %odin_intro_to_weapon_begin_struggle_ally;
	addNotetrack_customFunction( "odin_ally" , "door_opens" , maps\odin_ally::struggle_door_opens);
	level.scr_anim[ "odin_opfor" ][ "gun_struggle_intro_throw" ] = %odin_intro_to_weapon_begin_struggle_opfor;
	addNotetrack_customFunction( "odin_opfor" , "start_player_knock_anim" , maps\odin_ally::set_player_anim_flag );
	addNotetrack_customFunction( "odin_opfor" , "start_spin" , maps\odin_ally::start_struggle_spin );
	
	//gun struggle range
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_range_opfor" ] = %odin_hallway_weapon_struggle_range_opfor;
	
	//gun struggle down
	level.scr_anim[ "odin_ally" ][ "odin_hallway_weapon_struggle_down_ally01" ] = %odin_hallway_weapon_struggle_down_ally01;
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_down_opfor" ] = %odin_hallway_weapon_struggle_down_opfor;
	//gun struggle up
	level.scr_anim[ "odin_ally" ][ "odin_hallway_weapon_struggle_up_ally01" ] = %odin_hallway_weapon_struggle_up_ally01;
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_up_opfor" ] = %odin_hallway_weapon_struggle_up_opfor;
	//gun struggle left
	level.scr_anim[ "odin_ally" ][ "odin_hallway_weapon_struggle_left_ally01" ] = %odin_hallway_weapon_struggle_left_ally01;
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_left_opfor" ] = %odin_hallway_weapon_struggle_left_opfor;	
	//gun struggle right
	level.scr_anim[ "odin_ally" ][ "odin_hallway_weapon_struggle_right_ally01" ] = %odin_hallway_weapon_struggle_right_ally01;
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_right_opfor" ] = %odin_hallway_weapon_struggle_right_opfor;
	//gun struggle center
	level.scr_anim[ "odin_ally" ][ "odin_hallway_weapon_struggle_center_ally01" ] = %odin_hallway_weapon_struggle_center_ally01;
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_center_opfor" ] = %odin_hallway_weapon_struggle_center_opfor;	
	//gun struggle Shoot!	
	level.scr_anim[ "odin_opfor" ][ "space_traversal_L_to_R" ] = %space_traversal_L_to_R;
	level.scr_anim[ "odin_opfor" ][ "space_traversal_R_to_L" ] = %space_traversal_R_to_L;

	
	// Escape

	// Spin
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_shoot" ] = %odin_hallway_weapon_struggle_shoot_opfor;
	level.scr_anim[ "odin_opfor" ][ "odin_hallway_weapon_struggle_shoot" ] = %odin_hallway_weapon_struggle_shoot_opfor;
		
	// Spacejump
	level.scr_anim[ "odin_ally" ][ "odin_space_jump_ally01" ] = %odin_space_jump_ally01;
	level.scr_anim[ "generic" ][ "odin_space_jump_temp_actor" ] = %odin_space_jump_ally01;

	// Satellite
}

#using_animtree( "script_model" );
script_model()
{	
	level.scr_animtree[ "space_jump_satellite" ]								 = #animtree;
	level.scr_anim[ "space_jump_satellite" ][ "odin_space_jump_satellite" ] = %odin_space_jump_satellite;
	level.scr_model[ "space_jump_satellite" ]								 = "tag_origin";
	
	level.scr_animtree[ "satellite_traversal_solar_panels" ] = #animtree;
	level.scr_anim[ "satellite_traversal_solar_panels" ][ "satellite_traversal_props" ] = %odin_satellite_traversal_solar_panels;
	level.scr_model[ "satellite_traversal_solar_panels" ] = "odin_satellite_solar_blades";
	
	level.scr_animtree[ "shuttle" ] = #animtree;
	level.scr_anim[ "shuttle" ][ "odin_intro_shuttle" ] = %odin_intro_shuttle;
	level.scr_model[ "shuttle" ] = "vehicle_space_shuttle";
} 


#using_animtree( "player" );
player()
{
	//Intro
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "intro_exterior_scene" ] = %odin_intro_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	
	//hall escape turn anims
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hall_escape_turn01_player" ] = %odin_hallway_escape_turn01_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hall_escape_turn02_player" ] = %odin_hallway_escape_turn02_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";

	level.scr_animtree[ "alt_player_rig" ] = #animtree;
	level.scr_anim[ "alt_player_rig" ][ "odin_hall_escape_turn01_player" ] = %odin_hallway_escape_turn01_player;
	level.scr_model[ "alt_player_rig" ] = "viewhands_player_us_army";
	
	level.scr_animtree[ "alt_player_rig" ] = #animtree;
	level.scr_anim[ "alt_player_rig" ][ "odin_hall_escape_turn02_player" ] = %odin_hallway_escape_turn02_player;
	level.scr_model[ "alt_player_rig" ] = "viewhands_player_us_army";
	
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "viewmodel_space_l_arm_sidepush" ] = %viewmodel_space_l_arm_sidepush;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "viewmodel_space_l_arm_downpush" ] = %viewmodel_space_l_arm_downpush;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	
	//struggleIntro
	level.scr_anim[ "player_rig" ][ "gun_struggle_intro_throw" ] 	= %odin_intro_to_weapon_begin_struggle_player;
	
	//Player gun struggle left
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_range_player" ] = %odin_hallway_weapon_struggle_range_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	
	//Player gun struggle left
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_left_player" ] = %odin_hallway_weapon_struggle_left_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	//Player gun struggle right
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_right_player" ] = %odin_hallway_weapon_struggle_right_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	//Player gun struggle center
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_center_player" ] = %odin_hallway_weapon_struggle_center_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	//Player gun struggle up
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_up_player" ] = %odin_hallway_weapon_struggle_up_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	//Player gun struggle down
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_down_player" ] = %odin_hallway_weapon_struggle_down_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	//Player gun struggle shoot
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "odin_hallway_weapon_struggle_shoot" ] = %odin_hallway_weapon_struggle_shoot_player;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	addNotetrack_customFunction( "player_rig" , "player_teleport" , maps\odin_ally::set_player_teleport_flag );
	
	//Satellite Traversal Anims

	level.scr_anim[ "player_rig" ][ "satellite_traversal_climb" ] 		= %odin_satellite_traversal_climb_player; 
	level.scr_anim[ "player_rig" ][ "satellite_traversal_climb_01" ] 	= %odin_satellite_traversal_climb_01_player; 
	level.scr_anim[ "player_rig" ][ "satellite_traversal_climb_02" ] 	= %odin_satellite_traversal_climb_02_player; 
	level.scr_anim[ "player_rig" ][ "satellite_traversal_climb_03" ] 	= %odin_satellite_traversal_climb_03_player; 
	level.scr_anim[ "player_rig" ][ "satellite_traversal_climb_04" ] 	= %odin_satellite_traversal_climb_04_player; 
	level.scr_anim[ "player_rig" ][ "satellite_traversal_climb_05" ] 	= %odin_satellite_traversal_climb_05_player; 
	level.scr_anim[ "player_rig" ][ "satellite_traversal_start" ] 		= %odin_satellite_traversal_start_idle_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r1_stop" ] 	= %odin_satellite_traversal_r1_stop_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r1_idle" ][0] 	= %odin_satellite_traversal_r1_idle_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r1_start" ] 	= %odin_satellite_traversal_r1_start_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r2_start" ] 	= %odin_satellite_traversal_r2_start_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r2_idle" ][0] 	= %odin_satellite_traversal_r2_idle_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r3_stop" ] 	= %odin_satellite_traversal_r3_stop_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r3_idle" ][0] 	= %odin_satellite_traversal_r3_idle_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r3_start" ] 	= %odin_satellite_traversal_r3_start_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r4_stop" ] 	= %odin_satellite_traversal_r4_stop_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r4_idle" ][0] 	= %odin_satellite_traversal_r4_idle_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r4_start" ]	= %odin_satellite_traversal_r4_start_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r5_stop" ] 	= %odin_satellite_traversal_r5_stop_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r5_idle" ][0] 	= %odin_satellite_traversal_r5_idle_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r5_start" ] 	= %odin_satellite_traversal_r5_start_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r6_start" ] 	= %odin_satellite_traversal_r6_start_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r6_idle" ][0] 	= %odin_satellite_traversal_r6_idle_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_rod_01_start" ] 	= %odin_satellite_traversal_rod_01_jump_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_rod_01_idle" ][0] 	= %odin_satellite_traversal_rod_01_idle_player;	
	level.scr_anim[ "player_rig" ][ "satellite_traversal_rod_02_start" ] 	= %odin_satellite_traversal_rod_02_jump_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_rod_02_idle" ][0] 	= %odin_satellite_traversal_rod_02_idle_player;	
	level.scr_anim[ "player_rig" ][ "satellite_traversal_solar_jump_start" ] 	= %odin_satellite_traversal_solar_jump_player;
	addNotetrack_customFunction( "player_rig" , "start_solar_blades" , maps\odin_satellite::sync_blades );
	level.scr_anim[ "player_rig" ][ "satellite_traversal_solar_jump_idle" ][0] 	= %odin_satellite_traversal_solar_idle_player;	
	level.scr_anim[ "player_rig" ][ "satellite_traversal_top_jump_start" ] 	= %odin_satellite_traversal_top_jump_player;
	addNotetrack_customFunction( "player_rig" , "hands_off" , maps\odin_satellite::player_has_jumped ); 
	
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r2_recoil" ] 	= %odin_satellite_traversal_r2_recoil_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r3_recoil" ] 	= %odin_satellite_traversal_r3_recoil_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r4_recoil" ] 	= %odin_satellite_traversal_r4_recoil_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r5_recoil" ] 	= %odin_satellite_traversal_r5_recoil_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r2_jump" ] 	= %odin_satellite_traversal_r2_jump_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r3_jump" ] 	= %odin_satellite_traversal_r3_jump_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r4_jump" ] 	= %odin_satellite_traversal_r4_jump_player;
	level.scr_anim[ "player_rig" ][ "satellite_traversal_r5_jump" ] 	= %odin_satellite_traversal_r5_jump_player;
	

}

#using_animtree( "vehicles" );
vehicles()
{	
}

#using_animtree( "generic_human" );
dialog()
{
}



vignettes()
{
	vignette_register( ::odin_hall_escape_turn01_ally_spawn, "odin_hall_ally_turn01" );
	vignette_register( ::odin_hall_escape_turn01_player_spawn, "odin_hall_player_turn01" );
	vignette_register( ::odin_hall_escape_turn02_ally_spawn, "odin_hall_ally_turn02" );
	vignette_register( ::odin_hall_escape_turn02_player_spawn, "odin_hall_player_turn02" );
}

odin_hall_escape_turn01_ally_spawn()
{
	hall_escape_turn01_ally = vignette_actor_spawn("ally_turn01", "hall_escape_turn01_ally"); //"value" (kvp), "anim_name"
	odin_hall_escape_turn01_ally(hall_escape_turn01_ally);
	hall_escape_turn01_ally vignette_actor_delete();
}

odin_hall_escape_turn01_ally(hall_escape_turn01_ally)
{
	node = getstruct("odin_hall_escape_turn01", "script_noteworthy");

	guys = [];
	guys["hall_escape_turn01_ally"] = hall_escape_turn01_ally;

	node anim_first_frame(guys, "odin_hall_escape_turn01_ally");

	node anim_single(guys, "odin_hall_escape_turn01_ally");
}

odin_hall_escape_turn01_player_spawn()
{
	odin_hall_escape_turn01_player();
}

odin_hall_escape_turn01_player()
{
	node = getstruct("odin_hall_escape_turn01", "script_noteworthy");

	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );
	player_rig hide();

	guys = [];
	guys["player_rig"] = player_rig;
	
	node anim_first_frame(guys, "odin_hall_escape_turn01_player");
	
	arc = 0;

	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.5, 0.15, 0.15 );
	wait 0.5;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
	player_rig show();
	
	node anim_single(guys, "odin_hall_escape_turn01_player");
	
	level.player unlink();
	
	player_rig delete();

	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );
}

odin_hall_escape_turn02_ally_spawn()
{
	hall_escape_turn02_ally = vignette_actor_spawn("ally_turn02", "hall_escape_turn02_ally"); //"value" (kvp), "anim_name"
	odin_hall_escape_turn02_ally(hall_escape_turn02_ally);
	hall_escape_turn02_ally vignette_actor_delete();

}

odin_hall_escape_turn02_ally(hall_escape_turn02_ally)
{
	node = getstruct("odin_hall_escape_turn02", "script_noteworthy");

	guys = [];
	guys["hall_escape_turn02_ally"] = hall_escape_turn02_ally;

	node anim_first_frame(guys, "odin_hall_escape_turn02_ally");
	node anim_single(guys, "odin_hall_escape_turn02_ally");
}

odin_hall_escape_turn02_player_spawn()
{
	odin_hall_escape_turn02_player();
}

odin_hall_escape_turn02_player()
{
	node = getstruct("odin_hall_escape_turn02", "script_noteworthy");

	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );
	player_rig hide();

	guys = [];
	guys["player_rig"] = player_rig;
	
	node anim_first_frame(guys, "odin_hall_escape_turn02_player");

	arc = 0;

	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.5, 0.15, 0.15 );
	wait 0.5;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
	player_rig show();

	node anim_single(guys, "odin_hall_escape_turn02_player");

	level.player unlink();

	player_rig delete();

	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );

}

// Spacejump anim
odin_spacejump_ally()
{
	node = GetEnt( "spacejump_ally_anim_node", "targetname" );

	self.animname = "odin_ally";

	node anim_first_frame_solo( self, "odin_space_jump_ally01" );
	node anim_single_solo( self, "odin_space_jump_ally01" );

	// Temp teleport because anim is no longer accurate
	wait 0.1;
	maps\odin_util::actor_teleport( level.ally, "odin_satellite_ally_tp" );
	wait 0.1;
}

// Hacky way to get the player using the same anim as ally
odin_spacejump_player()
{
	node = GetEnt( "spacejump_player_anim_node", "targetname" );

	// Spawn a temp actor
	spawner = GetEnt( "spacejump_temp_actor", "targetname" );
	spawner.team = "nuetral";
	spawner.script_friendname = "none";
	guy = spawner spawn_ai( true );
	guy.animname = "generic";

	// Hide it
	guy InvisibleNotSolid();
	guy hide();
	//guy SetCanDamage( false );

	// Link the player to the temp actor
	level.player playerLinkTo( guy );

	// Play the anim on the temp actor
	node anim_first_frame_solo( guy, "odin_space_jump_temp_actor" );
	node anim_single_solo( guy, "odin_space_jump_temp_actor", undefined, 3 );

	//iprintlnbold( "anim done" );
	level.player Unlink();
	guy delete();
	flag_set( "landed_on_satellite" );
	flag_set( "spacejump_clear" );

	// Temp teleport because anim is no longer accurate
	maps\odin_util::move_player_to_start_point( "start_odin_satellite" );
}

odin_spacejump_satellite( spin_amount, earth_rotate_speed )
{
	// Get the anim node
	//node = GetEnt( "spacejump_sat_anim_node", "targetname" );

	// Spawn a script origin
	//sat_org = spawn_anim_model( "space_jump_satellite" );
	//sat_org.origin = node.origin;
	//sat_org LinkTo( self );
	//self LinkTo( sat_org );

	// First frame to get in position
	//node anim_first_frame_solo( sat_org, "odin_space_jump_satellite" );

	// Rotate it
	self RotateRoll(( 0 - spin_amount ) * -1, earth_rotate_speed , 0 , earth_rotate_speed*0.7 );

	//node thread anim_single_solo( sat_org, "odin_space_jump_satellite" );
}


//Basic logic for satellite traversal spinning solar panel prop.
satellite_traversal_props()
{

	node = getstruct("satellite_traversal_top", "script_noteworthy");

	satellite_traversal_solar_panels = spawn_anim_model("satellite_traversal_solar_panels");


	guys = [];
	guys["satellite_traversal_solar_panels"] = satellite_traversal_solar_panels;

	node anim_single(guys, "satellite_traversal_props");

}



