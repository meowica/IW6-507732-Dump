#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\las_vegas_code;
#include maps\_hud_util;

//#include maps\_player_limp;

#using_animtree( "generic_human" );

//---------------------------------------------------------
// Vignettes
//---------------------------------------------------------
// casino_vign_two_b_startspots
// to do
// add dust you walk into
// add escalation of heavy breath
// add limp
// add slow walk anims 
// add black and white
// try end game
// try mp nuke
// end with coup sun blind

vignettes_sequence( notstart ) 
{
	//casino_vign_startspots
	
	if( !isdefined( notstart ) )
	{
		level.fade_black = create_client_overlay( "black", 1, level.player );
		level.fade_white = create_client_overlay( "white", 0, level.player );
		level.fade_black thread fade_over_time( 0.1, 0.1 ); // fade_over_time( 1, 2 );
		waitframe();
		level.ninja set_force_color( "p" );
		level.leader set_force_color( "b" );
		set_start_locations( "casino_vign_startspots" );
		thread vignette_one_after_heli_crash();
	}
	
	thread anim_scene_get_up();

	level.ninja set_force_color( "p" );
	level.leader set_force_color( "b" );
	
//	thread intro_fade_in_from_white();
//	wait( 1 );
//	IPrintLnBold( "use a jump for this because the pathing is not working currently." );
//	thread vignette_master_controler();
	
}

vignette_master_controler()
{
//	thread play_undulating_blur();
	
	// this fade up from white feels great with the timing of the second vign
//	blur_one_start = 6;
//	blur_one_finish = 0;
//	blur_two_start = 0;
//	blur_two_finish = 3;
//	thread bloom_fadein( blur_one_start, blur_one_finish, blur_two_start , blur_two_finish );
//	level.fade_white = create_client_overlay( "white", 1, level.player );
//	thread visuals_for_vign_two();
//	thread vignette_two_high_ground_desert();	

//	blur_one_start = 6;
//	blur_one_finish = 0;
//	blur_two_start = 0;
//	blur_two_finish = 3;	
//	thread bloom_fadein( blur_one_start, blur_one_finish, blur_two_start , blur_two_finish );
	
	
	
// 	comment out for now.
	thread visuals_for_vign_one();
}

visuals_for_vign_one()
{
	delaythread ( 4, ::intro_shot_1_dof );
	wait 12;
	level.fade_white thread fade_over_time( 1, 6 );
	blur_one_start = 0;
	blur_one_finish = 6;
	blur_two_start = 3;
	blur_two_finish = 0;
	bloom_fadein( blur_one_start, blur_one_finish, blur_two_start , blur_two_finish );
//	thread play_undulating_blur();
//	thread intro_shot_7_screen_dirt_hit();
}


vignette_one_after_heli_crash()
{
	
	level.fade_black = create_client_overlay( "black", 0, level.player );
	level.fade_white = create_client_overlay( "white", 0, level.player );
//	thread vignette_master_controler();
	
//	dudes = GetAIArray( "axis" );
//	foreach( ai in dudes )
//	{
//		ai delete();
//	}
//	IPrintLnBold( "use a jump for this because the pathing is not working currently." );
//	level.leader disable_sprint();
//	level.ninja disable_sprint();
	
	vign_color_chain_ent = getent( "vign_color_chain","targetname" );
	vign_color_chain_ent activate_trigger();
	level.ninja set_force_color( "p" );
	level.leader set_force_color( "b" );
//	level.fade_black thread fade_over_time( 0, 0 );
	set_start_locations( "casino_vign_startspots" );
	thread add_dialogue_line( "Baker", "Go go, DON'T stop moving." );
	wait( 18 );
//	level.fade_black fade_over_time( 1, 6 );
//	thread vignette_two_high_ground_desert();
}

vignette_two_high_ground_desert()
{
	wait( 1.7 );
	blur_one_start = 6;
	blur_one_finish = 0;
	blur_two_start = 0;
	blur_two_finish = 3;
	thread bloom_fadein( blur_one_start, blur_one_finish, blur_two_start , blur_two_finish );
	waitframe();
	thread visuals_for_vign_two();
	
	set_start_locations( "casino_vign_two_startspots" );
//	level.fade_black thread fade_over_time( 0, 4 );
	level.player AllowSprint( true ); // but punish player for sprinting here.
	level.player player_speed_percent( 80 );
	
	level.ninja.moveplaybackrate = 0.80;
	level.leader.moveplaybackrate = 0.80;
	
	// the player can sprint but it knocks him down.
	wait( 15 );
	
	blur_one_start = 0;
	blur_one_finish = 6;
	blur_two_start = 3;
	blur_two_finish = 0;
	thread bloom_fadein( blur_one_start, blur_one_finish, blur_two_start , blur_two_finish );
	level.fade_black thread fade_over_time( 1, 6 );

	
	// updated for the level split
	// do cool night time fx
//	delayThread( 6, ::vignette_six );	
//	delayThread( 6, ::vignette_five ); 
//	delayThread( 6, ::vignette_two_b_high_ground_desert );
}

visuals_for_vign_two()
{
	fadetime = 7;
	level.fade_white thread fade_over_time( 0, 6 );
//	thread intro_fade_in_from_black( 6 );
//	thread intro_fade_in_from_white( fadetime );
	thread intro_shot_1_dof();
//	thread intro_shot_7_screen_dirt_hit();
//	delaythread ( 4, ::intro_shot_1_dof );
}

// don't use yet.
vignette_two_b_high_ground_desert()
{
	set_start_locations( "casino_vign_three_startspots" );
	level.player AllowSprint( false );
	level.leader disable_sprint();
	level.ninja disable_sprint();
	level.player player_speed_percent( 70 );
	
	wait( 1.7 );
	blur_one_start = 6;
	blur_one_finish = 0;
	blur_two_start = 0;
	blur_two_finish = 3;
	thread bloom_fadein( blur_one_start, blur_one_finish, blur_two_start , blur_two_finish );	
	level.fade_black fade_over_time( 0, 6 );
	

	
	level.ninja.moveplaybackrate = 0.7;
	level.leader.moveplaybackrate = 0.7;
	
	// the player can sprint but it knocks him down.
	wait( 15 );
	level.fade_black fade_over_time( 1, 6 );
//	thread vignette_three_roll_down_hill();
	
	
	blur_one_start = 0;
	blur_one_finish = 6;
	blur_two_start = 3;
	blur_two_finish = 0;
	thread bloom_fadein( blur_one_start, blur_one_finish, blur_two_start , blur_two_finish );
	level.fade_black thread fade_over_time( 1, 6 );
}

visuals_for_vign_three()
{
	fadetime = 7;
	level.fade_white thread fade_over_time( 0, 6 );
//	thread intro_fade_in_from_black( 6 );
//	thread intro_fade_in_from_white( fadetime );
	thread intro_shot_1_dof();
//	thread intro_shot_7_screen_dirt_hit();
//	delaythread ( 4, ::intro_shot_1_dof );
}

vignette_three_roll_down_hill()
{
	level.player maps\_player_limp::enable_limp();
	set_start_locations( "casino_vign_four_startspots" );
	level.fade_black thread fade_over_time( 0, 4 );
	level.ninja.moveplaybackrate = 0.70;
	level.leader.moveplaybackrate = 0.70;
	level.player SetStance( "crouch" );
	level.player player_speed_percent( 70 );
	wait( 18 );
	level.fade_black fade_over_time( 1, 6 );
	thread vignette_four_roll();
}

vignette_four_roll()
{
	set_start_locations( "casino_vign_five_startspots" );
	level.fade_black thread fade_over_time( 0, 4 );
	level.player SetStance( "prone" );
	level.player player_speed_percent( 30 );
	level.ninja.moveplaybackrate = 0.30;
	level.leader.moveplaybackrate = 0.30;
	wait( 19 );
	level.fade_black fade_over_time( 1, 6 );
	{
		IPrintLnBold( "End of scripting" );
		wait( 5 );
	}
//	thread vignette_five();
}

vignette_six()
{
	set_start_locations( "casino_vign_six_startspots" );
	level.fade_black thread fade_over_time( 0, 4 );
	level.player SetStance( "prone" );
	level.player player_speed_percent( 60 );
	level.ninja.moveplaybackrate = 0.60;
	level.leader.moveplaybackrate = 0.60;
	wait( 19 );
	thread vignette_three_roll_down_hill();
//	while( 1 )
//	{
//		IPrintLnBold( "End of scripting" );
//		wait( 5 );
//	}
//	level.fade_black fade_over_time( 1, 6 );
}

//vignette_six()
//{
//	set_start_locations( "casino_vign_six_startspots" );
//	level.fade_black thread fade_over_time( 0, 4 );
//	level.player SetStance( "prone" );
//	level.player player_speed_percent( 60 );
//	level.ninja.moveplaybackrate = 0.60;
//	level.leader.moveplaybackrate = 0.60;
//	wait( 19 );
//	while( 1 )
//	{
//		IPrintLnBold( "End of scripting" );
//		wait( 5 );
//	}
//	//	level.fade_black fade_over_time( 1, 6 );
//}



//////////////////////////////////////////
//// INTRO HUD AND FADE FUNCTIONS
//////////////////////////////////////////

bloom_fadein( blur_one_start , blur_one_finish, blur_two_start, blur_two_finish  )
{
		setblur( blur_one_start , blur_one_finish );
//		setblur(10,0);
//		thread vision_set_fog_changes("Intro_cinematics_gurnee",0);
		wait(.5);
//		setblur(0,3);
		setblur( blur_two_start, blur_two_finish );
//		thread vision_set_fog_changes("Intro_cinematics",2);
}

rotate_sun()
{
	setsaveddvar("sm_sunsamplesizenear",.1);
	target_sun_dir = anglestoforward((-23, 34, 0));
	setsundirection(target_sun_dir);
	
	setSunLight( 2.175, 1.575, 1.5 );	
	
	//setsaveddvar("r_specularcolorscale", .5);
	
	wait 12;
	
	//setsaveddvar("r_specularcolorscale", 2.5);
	
	resetsundirection();	
	resetSunLight();	
}

intro_sunflare()
{
	level waitframe();
//	thread maps\_shg_fx::fx_spot_lens_flare_dir("lights_intro_sunflare",(-16, 78, 0),8000);
	wait(8.5);
	flag_set("fx_spot_flare_kill");
	flag_clear("fx_spot_flare_kill");
}

intro_shot_1_dof() // this has a good feel to it and the distance blur feels good to.
{
	wait( 5 );
	
	maps\_art::dof_enable_script( 10, 500, 5, 1000, 4000, 4, 0.7 );
  	wait(3.5);
	maps\_art::dof_enable_script( 1, 10, 4, 180, 2000, 1.5, 0.7 );
	wait(5);
	maps\_art::dof_disable_script( 0.5 );
}

intro_shot_2_dof()
{
	maps\_art::dof_enable_script( 5, 50, 6, 200, 4500, 6, 0.1 );
  wait(5);
	maps\_art::dof_disable_script( 0.1 );
}

intro_shot_3_dof()
{
	maps\_art::dof_enable_script( 1, 120, 6, 180, 1600, 6, 0.1 );
  wait(4);
	maps\_art::dof_disable_script( 0.1 );
}

intro_shot_4_dof()
{
	maps\_art::dof_enable_script( 1, 120, 6, 180, 1600, 6, 0.1 );
	wait(5);
	maps\_art::dof_enable_script( 1, 10, 6, 180, 800, 6, 0.5 );
  wait(3);
	maps\_art::dof_disable_script( 0.1 );
}

intro_shot_5_dof()
{
	maps\_art::dof_enable_script( 1, 120, 6, 180, 1600, 6, 0.1 );
	wait(3);
	maps\_art::dof_enable_script( 0, 8, 4, 10, 85, 4, 1 );
  wait(5);
	maps\_art::dof_disable_script( 0.1 );
}

intro_shot_7_dof()
{
	//start of shot
	maps\_art::dof_enable_script( 10, 20, 6, 70, 800, 6, 0.1 );
  wait(1.5);
  //focus on soap
  	maps\_art::dof_enable_script( 1, 9, 6, 10, 80, 6, 3.0 );
  wait(6.0);
  //rack to wall, prepare for choopper crash
	maps\_art::dof_enable_script( 20, 60, 6, 1500, 8000, 6, 1 );
}

intro_shot_8_dof()
{ 
	//hands out of focus
	maps\_art::dof_enable_script( 20, 60, 6, 1500, 8000, 6, 0.1 );
	wait(4);
	//chopper slightly out of focus
	maps\_art::dof_enable_script( 1.4, 20, 6, 20, 300, 2.2, 1.5 );
	wait(3.5);
	//blend back to no dof
	maps\_art::dof_disable_script( 1.5 );
}

intro_shot_8_blur()
{
	//explosion blur
	setblur(8,0);
	wait(1);
	setblur(0,2);
}

//full screen blood left and right
play_fullscreen_blood(time, fadein, fadeout, max_alpha)
{
	/*sides = [];
	sides[ "bottom" ] = true;
	sides[ "left" ] = true;
	sides[ "right" ] = true;


	foreach ( type, _ in sides )
	{
		material = "fullscreen_bloodsplat_" + type;
		hud = self thread maps\_gameskill::display_screen_effect_nofade( "bloodsplat", type, material, undefined, RandomFloatRange( 0.45, 0.56 ), time );
	}*/
	
	overlay_left = NewClientHudElem( self );
	overlay_left.x = 0;
	overlay_left.y = 0;

	overlay_left SetShader( "fullscreen_bloodsplat_left", 640, 480 );
	
	overlay_left.splatter = true;
	overlay_left.alignX = "left";
	overlay_left.alignY = "top";
	overlay_left.sort = 1;
	overlay_left.foreground = 0;
	overlay_left.horzAlign = "fullscreen";
	overlay_left.vertAlign = "fullscreen";
	overlay_left.alpha = 0;
	
	overlay_right = NewClientHudElem( self );
	overlay_right.x = 0;
	overlay_right.y = 0;

	overlay_right SetShader( "fullscreen_bloodsplat_right", 640, 480 );
	
	overlay_right.splatter = true;
	overlay_right.alignX = "left";
	overlay_right.alignY = "top";
	overlay_right.sort = 1;
	overlay_right.foreground = 0;
	overlay_right.horzAlign = "fullscreen";
	overlay_right.vertAlign = "fullscreen";
	overlay_right.alpha = 0;
	
	if (!IsDefined(fadein))
		fadein = 1;
	if (!IsDefined(fadeout))
		fadeout = 1;
	if (!IsDefined(max_alpha))
		max_alpha = 1;
	
	//fade up
	step_time = 0.05;
	
	if ( fadein > 0 )
	{
		current_alpha = 0;
		increment_alpha = max_alpha / (fadein/step_time); 
		AssertEx( increment_alpha > 0, "alpha not increasing; infinite loop" );
		while ( current_alpha < max_alpha )
		{
			overlay_left.alpha = current_alpha;
			overlay_right.alpha = current_alpha;
			current_alpha = current_alpha + increment_alpha;
			wait step_time;
	}
	}
	
	overlay_left.alpha = max_alpha;
	overlay_right.alpha = max_alpha;
	
	wait(time - (fadein + fadeout));

	//fade down
	if ( fadeout > 0 )
	{
		current_alpha = max_alpha;
		decrement_alpha = max_alpha / (fadeout/step_time);
		AssertEx( decrement_alpha > 0, "alpha not decreasing; infinite loop" );
		while ( current_alpha > 0 )
		{
			overlay_left.alpha = current_alpha;
			overlay_right.alpha = current_alpha;
			current_alpha = current_alpha - decrement_alpha;
			wait step_time;
	}
	}
	
	overlay_left.alpha = 0;
	overlay_right.alpha = 0;
	
	overlay_left destroy();
	overlay_right destroy();
}

//full screen blood bottom
play_fullscreen_blood_bottom(time, fadein, fadeout, max_alpha)
{
	overlay = NewClientHudElem( self );
	overlay.x = 0;
	overlay.y = 0;

	overlay SetShader( "fullscreen_bloodsplat_bottom", 640, 480 );
	
	overlay.splatter = true;
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 1;
	overlay.foreground = 0;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 0;
	
	fade_counter = 0;
	if (!IsDefined(fadein))
		fadein = 1;
	if (!IsDefined(fadeout))
		fadeout = 1;
	if (!IsDefined(max_alpha))
		max_alpha = 1;
	
	//fade up
	step_time = 0.05;
	
	if ( fadein > 0 )
	{
		current_alpha = 0;
		increment_alpha = max_alpha / (fadein/step_time); 
		AssertEx( increment_alpha > 0, "alpha not increasing; infinite loop" );
		while ( current_alpha < max_alpha )
		{
			overlay.alpha = current_alpha;
			current_alpha = current_alpha + increment_alpha;
			wait step_time;
	}
	}
	
	overlay.alpha = max_alpha;
	
	wait(time - (fadein + fadeout));

	//fade down
	if ( fadeout > 0 )
	{
		current_alpha = max_alpha;
		decrement_alpha = max_alpha / (fadeout/step_time);
		AssertEx( decrement_alpha > 0, "alpha not decreasing; infinite loop" );
		while ( current_alpha > 0 )
		{
			overlay.alpha = current_alpha;
			current_alpha = current_alpha - decrement_alpha;
			wait step_time;
		}
	}
	
	overlay.alpha = 0;
	
	overlay destroy();
}

//full screen blood splatter_alt moderate damage
play_fullscreen_blood_splatter_alt(time, fadein, fadeout, max_alpha)
{
	overlay = NewClientHudElem( self );
	overlay.x = 0;
	overlay.y = 0;

	overlay SetShader( "splatter_alt_sp", 640, 480 );
	
	overlay.splatter = true;
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 1;
	overlay.foreground = 0;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 0;
	
	fade_counter = 0;
	if (!IsDefined(fadein))
		fadein = 1;
	if (!IsDefined(fadeout))
		fadeout = 1;
	if (!IsDefined(max_alpha))
		max_alpha = 1;
	
	//fade up
	step_time = 0.05;
	
	if ( fadein > 0 )
	{
		current_alpha = 0;
		increment_alpha = max_alpha / (fadein/step_time); 
		AssertEx( increment_alpha > 0, "alpha not increasing; infinite loop" );
		while ( current_alpha < max_alpha )
		{
			overlay.alpha = current_alpha;
			current_alpha = current_alpha + increment_alpha;
			wait step_time;
	}
	}
	
	overlay.alpha = max_alpha;
	
	wait(time - (fadein + fadeout));

	//fade down
	if ( fadeout > 0 )
	{
		current_alpha = max_alpha;
		decrement_alpha = max_alpha / (fadeout/step_time);
		AssertEx( decrement_alpha > 0, "alpha not decreasing; infinite loop" );
		while ( current_alpha > 0 )
		{
			overlay.alpha = current_alpha;
			current_alpha = current_alpha - decrement_alpha;
			wait step_time;
		}
	}
	
	overlay.alpha = 0;
	
	overlay destroy();
}

intro_shot_7_screen_dirt_hit(time, fadein, fadeout)
{
	overlay = NewClientHudElem( self );
	overlay.x = 0;
	overlay.y = 0;

	overlay SetShader( "fullscreen_dirt_right", 640, 480 );
	
	overlay.splatter = true;
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 1;
	overlay.foreground = 0;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 0;
	
	//fade up
	fade_counter = 0;
	if (!IsDefined(fadein))
		fadein = 1;
	if (!IsDefined(fadeout))
		fadeout = 1;
	
	while(fade_counter < fadein)
	{
		overlay.alpha += 0.05;	
		fade_counter += 0.05;
		wait 0.05;
	}
	overlay.alpha = 1;
	
	wait(time - (fadein + fadeout));

	//fade down
	fade_counter = 0;
	while(fade_counter < fadeout)
	{
		overlay.alpha -= 0.05;
		fade_counter += 0.05;
		wait 0.05;
	}
	overlay.alpha = 0;
	
	overlay destroy();
}

play_undulating_blur() // this feels but is not quite there.. it could be bleeding into the other blurs and and staying to blurry for too long. 
{
	while(true)
	{
		level endon("msg_fx_screenfx_end");
/*
		wait(randomFloat(2.5) + 2.5);
		time = randomFloat(0.4) + 0.35;
		blur = randomFloat(10) + 1.5;
		SetBlur(blur, time);
		time = randomFloat(1) + 0.35;
		wait(time);
		time = randomFloat(0.4) + 0.2;
		SetBlur(0, time);	
*/
		setblur((randomfloatrange (1.7, 3.3)), 1.3);
		wait(randomfloatrange (1.3, 3.3));
		setblur((randomfloatrange (.2, .7)), 1.3);
		wait(randomfloatrange (3.3, 5.3));
	}
	setblur(0,.6);
}	

soap_blink_screenfx()
{
	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( "black", 640, 480 );

//blink 1
	introblack.alpha = 0;
	introblack FadeOverTime( 0.4 );
	introblack.alpha = 0.75;
	wait( 0.225 );
	introblack FadeOverTime( 0.4 );
	introblack.alpha = 0;
	wait 0.6;
	
//blink 2
	introblack.alpha = 0;
	introblack FadeOverTime( 0.75 );
	introblack.alpha = 1.0;
	wait( 0.6 );
	introblack FadeOverTime( 1.1 );
	introblack.alpha = 0;
	
	introblack destroy();

}

soap_injured_audio()
{
//	aud_send_msg("start_gurney_heartbeat");// Jeremy turn this one.. to activate heartbeat
//	level waittill("stop_player_injured_audio");
//	aud_send_msg("stop_gurney_heartbeat");
	
//	self thread player_heartbeat();
//	self thread player_breathing();
}

//player_heartbeat()
//{
//	level endon( "stop_player_injured_audio" );
//	while ( true )
//	{
//		self play_sound_on_entity( "breathing_heartbeat" );
//		wait .75;
//	}
//}
//
//player_breathing()
//{
//	level endon( "stop_player_injured_audio" );
//	while ( true )
//	{
//		wait RandomFloatRange( .5, 2 );
//		self play_sound_on_entity( "breathing_hurt_start" );
//	}
//}

intro_fade_out_to_black( guy )
{
	black_overlay = get_black_overlay();
	black_overlay thread exp_fade_overlay ( 1, .25 );
}

intro_fade_out_to_black_slow( guy )
{
	black_overlay = get_black_overlay( false );
	black_overlay thread exp_fade_overlay ( 1, 1 );
}

intro_fade_in_from_black( setFadeTime )
{
		
	if( isdefined( setFadeTime ) )
	{
		fadetime = setFadeTime;
	}
	else
	{
		fadetime = .25;	
	}
	black_overlay = get_black_overlay();
	black_overlay thread exp_fade_overlay ( 0, fadetime );
}

intro_fade_out_to_white( guy )
{
//	aud_send_msg("intro_fade_out_to_white");
	white_overlay = get_white_overlay();
	white_overlay thread exp_fade_overlay ( 1, .25 );
}

intro_fade_out_to_white_end( guy )
{
	white_overlay = get_white_overlay();
	white_overlay thread exp_fade_overlay ( 1, 6 );
}

intro_fade_in_from_white( fadetime )
{
//	aud_send_msg("intro_fade_in_from_white");
	white_overlay = get_white_overlay();
	white_overlay thread exp_fade_overlay ( 0, 10 );
}

intro_fade_in_from_white_as_yuri()
{
	thread introscreen_generic_fade_out( "white", 1, 2, 0 );
}

intro_flash_to_white_crash( guy )
{
	//thread introscreen_generic_fade_out( "white", 1, .1, .1 );
}

intro_room_heli_crash_as_soap( guy )
{
	thread start_slowmo_crash();
	org = getstruct( "courtyard_intro_room_heli_explode_as_soap", "targetname" );
	//dirt_on_screen_from_position( org.origin);
	playfx( getfx( "slamraam_explosion" ) , org.origin );
	earthquake(.8, 3, org.origin, 1024);
	level.player playrumbleonentity( "artillery_rumble" );
	wait .5;
	thread end_slowmo_crash();
}

end_slowmo_crash( )
{
	slomoLerpTime_out = 0.5;
	
	slowmo_setlerptime_out( slomoLerpTime_out );
	slowmo_lerp_out();
	slowmo_end();
}

start_slowmo_crash( )
{
	slomoLerpTime_in = 0.5; //0.5;
	
	slowmo_start();
	
	slowmo_setspeed_slow( 0.75 );
	slowmo_setlerptime_in( slomoLerpTime_in );
	slowmo_lerp_in();
}

introscreen_generic_fade_out( shader, pause_time, fade_in_time, fade_out_time )
{
	if ( !isdefined( fade_in_time ) )
		fade_in_time = 1.5;

	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( shader, 640, 480 );

	if ( IsDefined( fade_out_time ) && fade_out_time > 0 )
	{
		introblack.alpha = 0;
		introblack FadeOverTime( fade_out_time );
		introblack.alpha = 1;
		wait( fade_out_time );
	}

	wait pause_time;

	
	
	// Fade out black
	if ( fade_in_time > 0 )
		introblack FadeOverTime( fade_in_time );

	introblack.alpha = 0;
	
	wait fade_in_time;
	
	introblack destroy();
	//SetSavedDvar( "com_cinematicEndInWhite", 0 );
	
}

get_black_overlay( is_foreground )
{
	if ( !isdefined( level.black_overlay ) )
	{
		level.black_overlay = create_client_overlay( "black", 0, level.player );
	level.black_overlay.sort = -1;
	}
	
	if ( IsDefined( is_foreground ) )
	{
		level.black_overlay.foreground = is_foreground;
	}
	
	return level.black_overlay;
}

get_white_overlay()
{
	if ( !isdefined( level.white_overlay ) )
		level.white_overlay = create_client_overlay( "white", 0, level.player );
	level.white_overlay.sort = -1;
	level.white_overlay.foreground = false;
	return level.white_overlay;
//		Iprintlnbold( "made it" );
}

blur_overlay( target, time )
{
	SetBlur( target, time );
}

exp_fade_overlay( target_alpha, fade_time )
{
	self notify( "exp_fade_overlay" );
	self endon( "exp_fade_overlay" );

	fade_steps = 4;
	step_angle = 90 / fade_steps;
	current_angle = 0;
	step_time = fade_time / fade_steps;

	current_alpha = self.alpha;
	alpha_dif = current_alpha - target_alpha;

	for ( i = 0; i < fade_steps; i++ )
	{
		current_angle += step_angle;

		self FadeOverTime( step_time );
		if ( target_alpha > current_alpha )
		{
			fraction = 1 - Cos( current_angle );
			self.alpha = current_alpha - alpha_dif * fraction;
		}
		else
		{
			fraction = Sin( current_angle );
			self.alpha = current_alpha - alpha_dif * fraction;
		}

		wait step_time;
	}
}

anim_scene_get_up()
{		
	anim_point = getstruct( "get_out_of_crash", "targetname" );
//	leader_start = getstruct( "leader", "script_parameter" );
//	wounded_ai_start = getstruct( "wounded_ai", "script_parameter" );
//	player_start = getstruct( "player", "script_paramter" );	
		
	// anims working, need structs to call this off of from proper places.
	// probably just one struct for reference.
	wait 0.3;
	anim_point thread anim_single_solo( level.ninja, "vegas_keegan_crash_getup" );
	anim_point thread anim_single_solo( level.leader, "vegas_baker_crash_getup" );
	anim_point thread anim_single_solo( level.wounded_ai, "vegas_diaz_crash_getup" );
//	player_start anim_single_solo( level.player, "vegas_keegan_crash_getup" );
}

