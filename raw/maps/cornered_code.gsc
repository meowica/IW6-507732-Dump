#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;
#include maps\_hud_util;
#include maps\_stealth_utility;
	
setup_common()
{
	// find-and-replace these as necessary
	level.const_baker = 0;
	level.const_rorke = 1;

	level.decrementing_slide = false;
}

setup_player()
{
	tp			= level.start_point + "_start";
	startstruct = getstruct( tp, "targetname" );
	
	if ( IsDefined( startstruct ) )
	{
		level.player SetOrigin( startstruct.origin );
		if ( IsDefined( startstruct.angles ) )
			level.player SetPlayerAngles( startstruct.angles );
		else
			IPrintLnBold( "Your script_struct " + level.start_point + "_start has no angles! Set some." );			
	}
	else
	{
	/#
		IPrintLn( "Add scriptstruct with targetname " + level.start_point + "_start to set player start pos." );
	#/
	}
	setup_common();	
	
	level.player player_flap_sleeves_setup();
}

spawn_allies()
{
	level.allies				  = [];
	level.allies[ 0 ]			  = spawn_ally( "baker" );
	level.allies[ 0 ].animname	  = "baker";
	level.allies[ 1 ]			  = spawn_ally( "rorke" );
	level.allies[ 1 ].animname	  = "rorke";
	level.allies[ 1 ].grenadeammo = 0;	// We're using the Nikolai model from Payback for this character.  We end up with a conflict with the default grenadeammo amount (3) because this character's grenadeweapon is "none."	He doesn't know how to throw 3 "none" grenades.

}

spawn_ally( allyName, overrideSpawnPointName )
{
	spawnname = undefined;
    if ( !IsDefined( overrideSpawnPointName ) )
    {
        spawnname = level.start_point + "_" + allyName;
    }
    else
    {
        spawnname = overrideSpawnPointName + "_" + allyName;
    	
    }

    ally = spawn_targetname_at_struct_targetname( allyName, spawnname );
    if ( !IsDefined( ally ) )
    {
    	return undefined;
    }
    ally make_hero();
    if ( !IsDefined( ally.magic_bullet_shield ) )
    {
    	ally magic_bullet_shield();
	}
    
    
					 //   newWeapon 		     targetSlot   
	//ally forceUseWeapon( "usp_silencer"		, "secondary" );
	if ( ( level.start_point == "bar" ) || ( level.start_point == "junction" ) || ( level.start_point == "rappel" ) || ( level.start_point == "garden" ) || ( level.start_point == "hvt_capture" ) || ( level.start_point == "stairwell" ) || ( level.start_point == "atrium" ) )
	{
						 //   newWeapon    targetSlot   
		ally forceUseWeapon( "kriss+eotechsmg_sp+silencer_sp"	, "primary" );
		//ally forceUseWeapon( "p226"		, "secondary" );
	}
	else
	{
	    ally forceUseWeapon( "imbel+acog_sp+silencer_sp", "primary" );
	}
	
	ally.lastWeapon = ally.weapon;	// needed to avoid animscript SRE later
	
	if ( level.start_point != "intro" )
	{
	    ally thread ally_goggle_glow_on();
	}
	
    return ally;
}

spawn_targetname_at_struct_targetname( tname, sname )
{
    spawner = GetEnt( tname, "targetname" );
	sstart = getstruct( sname, "targetname" );
	if ( IsDefined( spawner ) && IsDefined( sstart ) )
	{
		spawner.origin = sstart.origin;
		if ( IsDefined( sstart.angles ) )
		{
			spawner.angles = sstart.angles;
		}
		spawned = spawner spawn_ai();
	    return spawned;
	}
	if ( IsDefined( spawner ) )
	{
		spawned = spawner spawn_ai();
    	IPrintLnBold( "Add a script struct called: " + sname + " to spawn him in the correct location." );
    	spawned Teleport( level.player.origin, level.player.angles );
    	return spawned;
		
	}
	IPrintLnBold( "failed to spawn " + tname + " at " + sname );
	
	return undefined;
}

//USE smart_dialog or smart_radio_dialog or derivitives instead
/*radio_dialog_add_and_go( alias, timeout )
{
	radio_add( alias );
	radio_dialogue( alias, timeout );
}

radio_dialog_add_and_overlap( alias, timeout )
{
	radio_add( alias );
	radio_dialogue_overlap( alias );
}

char_dialog_add_and_go( alias )
{
	level.scr_sound[ self.animname ][ alias ] = alias;
	self dialogue_queue( alias );
}*/

ally_goggle_glow_on()
{
	AssertEx( !IsDefined( self.glowmodel ), "An ally can only have one glowmodel defined." );
	
	glow_org		 = self GetTagOrigin( "j_head" );
	glow_ang		 = self GetTagAngles( "j_head" );
	glowmodel		 = Spawn( "script_model", glow_org );
	glowmodel.angles = glow_ang;
	glowmodel SetModel( "head_cnd_test_goggles_glow" );
	waittillframeend;
	//self Attach( glowmodel, "j_head" );
	glowmodel LinkTo( self, "j_head" );
	
	self.glowmodel = glowmodel;
}

ally_goggle_glow_off()
{
	//self Detach( self.glowmodel, "j_head" );
	self.glowmodel Unlink();
	self.glowmodel Delete();
}

cornered_falling_death()
{
	level endon( "c_rappel_player_on_rope" );
	level endon( "player_is_starting_zipline" );
	level endon( "player_has_exited_the_building" );
	
	while ( !level.player IsTouching( self ) )
	{
		wait( 0.1 );
	}

	player_rig		  = spawn_anim_model( "player_bldg_fall" );
	player_rig.origin = level.player.origin;
	player_rig.angles = ( 0, level.player.angles[ 1 ], 0 );
	
	player_rig thread anim_single_solo( player_rig, "player_icepicker_left_fall" );
	level.player PlayerLinkToBlend( player_rig, "tag_player", 1 );
	level.player _disableWeapon();
	level.player FreezeControls( true );
	flag_set( "player_falling" );
			 
	wait( 2.0 );
	
	fade_out( 2.5 );
	
	wait( 3.0 );
	MissionFailed();
}

anim_generic_gravity_run( guy, anime, tag, rate )
{
	self thread anim_generic_gravity( guy, anime, tag );
	
	if ( IsDefined( rate ) )
	{
		guy thread anim_set_rate_internal( anime, rate, "generic" );
	}
	
	Length = GetAnimLength( getanim_generic( anime ) );
	wait Length - 0.2;
	guy ClearAnim( getanim_generic( anime ), .2 );
	guy notify( "killanimscript" );
	
	if ( IsDefined( rate ) )
	{
		guy set_moveplaybackrate( rate );
	}
}

handle_intro_fx()
{
	fans = GetEntArray("intro_fans","targetname");
	foreach (fan in fans)
	{
		fan thread rotateFan();
	}
	/*level.vista_pivot = GetEnt	 ( "air_vista_pivot", "targetname" );

	vfxarry = get_exploder_array( 9999 );

	// Smoke columns effects
	level.rotating_effects = [];
	level.fx_handler_array = [];
	
	foreach ( ent in vfxarry )
	{
		fx_up												  = AnglesToUp( ent.v[ "angles" ] );
		fx_fwd												  = AnglesToForward( ent.v[ "angles" ] );
		fx													  = SpawnFx( level._effect[ ent.v[ "fxid" ]], ent.v[ "origin" ], fx_fwd, fx_up );
		level.rotating_effects[ level.rotating_effects.size ] = fx;
		tag_origin											  = spawn_tag_origin(); // Spawn on ent doesnt work
		tag_origin.origin									  = ent.v[ "origin" ];
		tag_origin.angles									  = ent.v[ "angles" ];
		tag_origin LinkTo( level.vista_pivot );
		level.fx_handler_array	[ level.fx_handler_array.size ] 	 = tag_origin;
		TriggerFX( fx, -2240 );
		//delete(fx);
	}*/
}
rotateFan()
{
	self endon( "death" );
	while(true)
	{
		self RotateYaw(-360,1);
		wait(1);
	}
}
//hide_player_hud()
//{
//	SetSavedDvar( "ui_hidemap"	  , 1 );
//	SetSavedDvar( "hud_showStance", "0" );
//	SetSavedDvar( "compass"		  , "0" );
//	SetDvar( "old_compass", "0" );
//	SetSavedDvar( "ammoCounterHide" , "1" );
//	SetSavedDvar( "cg_drawCrosshair", 0 );
//}
//
//show_player_hud()
//{
//	SetSavedDvar( "ui_hidemap"	  , 0 );
//	SetSavedDvar( "hud_showStance", "1" );
//	SetSavedDvar( "compass"		  , "1" );
//	SetDvar( "old_compass", "1" );
//	SetSavedDvar( "ammoCounterHide" , "0" );
//	SetSavedDvar( "cg_drawCrosshair", 1 );
//}
//
//ai_random_fire_at_ents( not_near_player_ents )
//{
//	self endon( "death" );
//	self endon( "alerted" );
//	
//	near_player_ents = GetEntArray( "dummy_targets", "targetname" );
//	
//	ents = not_near_player_ents;
//	
//	while ( true )
//	{
//		/*
//		if ( flag( "enemy_sniper_to_shoot" ) )
//		{
//			if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "sniper" )
//			{
//				//ents = near_player_ents;
//				if(IsAlive(self))
//				{
//					self ClearEntityTarget();
//					break;
//				}
//			}
//		}
//		*/
//		target_idx = RandomInt( ents.size );
//		Assert( IsDefined( ents[ target_idx ] ) );
//		Assert( IsDefined( self ) );
//		self SetEntityTarget( ents[ target_idx ] );
//		if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "sniper" )
//		{
//			wait( RandomFloatRange( 4, 8 ) );
//	}
//		else
//		{
//			wait( RandomFloatRange( 1, 3 ) );
//		}
//	}
//}

//delete_at_path_end()
//{
//	self waittill( "reached_path_end" );
//	
//	if ( IsAlive( self ) )
//	{
//		self Kill();
//	}
//	
//	wait( 0.1 );
//	
//	if ( IsDefined( self ) )
//	{
//		self Delete();
//	}
//}
//
//ignore_and_delete_at_path_end()
//{
//	self endon( "death" );
//	
//	self ignore_everything();
//	
//	self waittill( "reached_path_end" );
//	
//	if ( IsDefined( self ) )
//	{
//		self Delete();
//	}
//}
//
//ignore_til_pathend_or_damage()
//{
//	self endon( "death" );
//	
//	self ignore_everything();
//	self waittill_either( "reached_path_end", "damage" );
//	self clear_ignore_everything();
//}
//
//ignore_til_pathend()
//{
//	self endon( "death" );
//	
//	self ignore_everything();
//	self waittill( "reached_path_end" );
//	self clear_ignore_everything();
//}
//
//ignore_everything()
//{
//	self.ignoreall					 = true;
//	self.grenadeAwareness			 = 0;
//	self.ignoreexplosionevents		 = true;
//	self.ignorerandombulletdamage	 = true;
//	self.ignoresuppression			 = true;
//	self.fixednode					 = false;
//	self.disableBulletWhizbyReaction = true;
//	self disable_pain();
//	
//	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
//	self.newEnemyReactionDistSq	   = 0;
//}
//
//clear_ignore_everything()
//{
//	self.ignoreall					 = false;
//	self.grenadeAwareness			 = 1;
//	self.ignoreexplosionevents		 = false;
//	self.ignorerandombulletdamage	 = false;
//	self.ignoresuppression			 = false;
//	self.fixednode					 = true;
//	self.disableBulletWhizbyReaction = false;
//	self enable_pain();
//	
//	if ( IsDefined( self.og_newEnemyReactionDistSq ) )
//	{
//		self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
//	}
//}

unlimited_ammo()
{
	self endon( "death" );
	level endon( "stop_manage_player_rappel_movement" );
	
	wait( 0.1 );
	
	current_weapon = self GetCurrentWeapon();
	
    while ( 1 )
    {
        self GiveMaxAmmo( current_weapon );
        wait( 1 );
    }
}

check_ai_array_for_death( ai_array, flag_to_set, number )	
{
	if ( IsDefined( number ) )
	{
		waittill_dead_or_dying( ai_array, number );
	}
	else
	{
		waittill_dead_or_dying( ai_array );
	}
	flag_set( flag_to_set );
}

//check_ai_array_for_living( ai_array, flag_to_set, number )
//{
//	
//	while ( 1 )
//	{
//		ai_array = array_removeDead_or_dying( ai_array );
//		if ( ai_array.size <= number )
//		{
//			flag_set( flag_to_set );
//			break;
//		}
//		wait( 0.05 );
//	}
//	
//}
//
//check_ai_array_for_death_by_player( flag_to_set )
//{
//	level endon( flag_to_set );
//	
//	self waittill( "damage", amount, attacker, direction_vec, point, type );
//	
//	self Kill();	
//	
//	if ( IsDefined( attacker ) && IsPlayer( attacker ) )
//	{
//		flag_set( flag_to_set );
//	}
//}
//
//light_blink( ran1, ran2, ran_intense )
//{
//	self SetLightIntensity( 0 );
//	wait ran1;
//	self SetLightIntensity( ran_intense );
//	wait ran2;
//}

//---------------------------------------------------------------------------------------------------------------------
//Code for balcony deaths

death_func()
{	
	self endon( "stop_death_func" );
	
	self.health = 9999;
	
	deathAnims	   = getGenericAnim( "regular_death" );
	self.deathanim = deathAnims[ RandomInt( deathAnims.size ) ];
	
	self waittill( "damage", amount, attacker, direction_vec, point, type );
	
	self notify( "enemy_above_shot" );
	self notify( "stop_loop" );
	
	if ( !IsDefined( level.enemies_above_killed ) )
		level.enemies_above_killed = 0;
	level.enemies_above_killed++;
	
	if ( IsDefined( attacker ) && IsPlayer( attacker ) )
		level notify( "player_shot_above_enemy" ); //stops nag VO
	
	// these guys get stuck unless they just fall off
	if ( self.script_noteworthy == "p1_junction" )
	{
		balcony_death_func();
		return;
	}
				
	if ( level.balcony_fall_deaths < 2 && balcony_check() )
		return;
	
	self Kill();
	level.total_balcony_deaths++;
	level.last_balcony_death = false;
}

balcony_check()
{
	if ( !IsDefined( self ) )
		return false;
	
	if ( self.a.pose == "prone" )	// allow crouch
		return false;
	
	if ( !IsDefined( self.prevnode ) )
		return false;
	
	if ( !IsDefined( self.prevnode.script_balcony ) )
		return false;
	
	angleAI	  = self.angles			[ 1 ];
	angleNode = self.prevnode.angles[ 1 ];
	angleDiff = abs( AngleClamp180( angleAI - angleNode ) );
	if ( angleDiff > 45 )
		return false;
	
	d = Distance( self.origin, self.prevnode.origin );
	if ( d > 16 )
	{
		if ( IsDefined( self.isAnimating ) && !self.isAnimating )
		{
			return false;
		}
	}
	
	if ( level.last_balcony_death )
		return false;

	
	if ( !level.last_balcony_death )
	{
		if ( IsDefined( level.last_balcony_death_time ) )
		{
			elapsedTime = GetTime() - level.last_balcony_death_time;
	
			// if one just happened within 5 seconds dont do it
			if ( elapsedTime < 5 * 1000 )
			{
				return false;
			}
		}
	}
	
	level.last_balcony_death_time = GetTime();
	
	self thread balcony_death_func();
	level.balcony_fall_deaths++;
	level.total_balcony_deaths++;
	level.last_balcony_death = true;
	return true;
}

balcony_death_func()
{
	if ( !IsAlive( self ) )
		return;
	
	self.dontDoNotetracks = true;
	self.ignoreme		  = true;
    self SetLookAtText( "", &"" );
	self gun_remove();
    self SetCanDamage( false );
	self.team	   = "neutral";
	self.a.nodeath = true;
	
    self thread watch_hit_player();
	idx				= RandomIntRange( 1, 3 );
	if ( idx == level.last_balcony_death_idx )
	{
		idx++;
		if ( idx >= 2 )
			idx = 1;
	}
	
	level.last_balcony_death_idx = idx;
	
    random_anim = "balcony_death_" + idx; // randomly choose between the anims
	self thread anim_single_solo( self, random_anim );
	
	while ( true )
	{
		self waittill( "single anim", note );
		
		if ( note == "start_ragdoll" || note == "end" )
		{
			self StartRagdoll();
			waitframe();
			self Kill();
			break;
		}
	}
}

watch_hit_player()
{
	self endon( "death" );
	//self endon( "play_balcony_deathanim_stop" );
	
	while ( 1 )
	{
		distance_between = Distance( level.player.origin, self.origin );
		
		dmgamt = level.player.maxhealth * 0.5;
		
		if ( distance_between <= 120 )
		{
			level.player EnableDeathShield( true );
			level.player DoDamage( dmgamt, level.player.origin );
			level.player EnableDeathShield( false );
			//self notify( "stop_something" );
			//self notify( "play_balcony_deathanim_stop" );
			//self StartRagdoll();
			//PhysicsExplosionSphere( level.player.origin, 500, 300, 1 );
			break;
		}
		wait( 0.05 );
	}
}

waittill_enemies_above_killed( num_killed, timeout )
{
	end_time = GetTime() + ( timeout * 1000 );
	while ( GetTime() < end_time )
	{
		if ( level.enemies_above_killed >= num_killed )
			return;
		
		waitframe();
	}
}

/////////////////////
// --AI Functions--
/////////////////////

death_only_ragdoll()
{
	self StopAnimScripted();
	self StartRagdoll();
}

////////////////////
// --Animation--
/////////////////////

generic_prop_raven_anim( animnode, animmodel, anime, ent1, ent2, match_angles, flag_to_wait, delete_on_end )
{
	//This is for objects attached to generic_prop_raven that play one animation and are done.
	//It handles attaching items to either joint (j_prop_1 or j_prop_2).
	//It assumes you are doing a setup and waiting for a flag to get set.
	//It does cleanup at the end of the ents and rig or just the rig.
	
	AssertEx( IsDefined( animnode )	   , "generic_prop_xmodel() - Must have an animnode defined." );
	AssertEx( IsDefined( animmodel )   , "generic_prop_xmodel() - Must have an animmodel defined." );
	AssertEx( IsDefined( anime )	   , "generic_prop_xmodel() - Must have an animation defined." );
	AssertEx( IsDefined( flag_to_wait ), "generic_prop_xmodel() - Must have an flag_wait defined." );
	
	obj1 = undefined;
	obj2 = undefined;
	
	if ( !IsDefined( match_angles ) )
	{
		match_angles = true;
	}
		
	rig = spawn_anim_model( animmodel );
	if ( IsDefined( ent1 ) )
	{
		obj1 = GetEnt( ent1, "targetname" );	
	}
	if ( IsDefined( ent2 ) )
	{
		obj2 = GetEnt( ent2, "targetname" );
	}
	
	animnode anim_first_frame_solo( rig, anime );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	j2_origin = rig GetTagOrigin( "J_prop_2" );
	j2_angles = rig GetTagAngles( "J_prop_2" );
	
	waitframe();
	
	if ( IsDefined( ent1 ) && obj1.classname == "script_model" )
	{
		obj1.origin = j1_origin;
		if ( match_angles == true )
		{
			obj1.angles = j1_angles;
		}
	}
	if ( IsDefined( ent2 ) && obj2.classname == "script_model" )
	{
		obj2.origin = j2_origin;
		if ( match_angles == true )
		{
			obj2.angles = j2_angles;
		}
	}
	
	waitframe();

	if ( IsDefined( ent1 ) )
	{
		obj1 LinkTo( rig, "J_prop_1" );
	}
	if ( IsDefined( ent2 ) )
	{
		obj2 LinkTo( rig, "J_prop_2" );
	}
	
	flag_wait( flag_to_wait );
	
	if ( IsDefined( self.script_delay ) )
	{
		wait( self.script_delay );
	}
	
	animnode anim_single_solo( rig, anime );
	
	if ( IsDefined( delete_on_end ) && delete_on_end == true )
	{
		if ( IsDefined( ent1 ) )
		{
			obj1 Delete();
		}
		if ( IsDefined( ent2 ) )
		{
			obj2 Delete();
		}
		rig Delete();
	}
	else
	{
		if ( IsDefined( ent1 ) )
		{
			obj1 Unlink();
		}
		if ( IsDefined( ent2 ) )
		{
			obj2 Unlink();
		}
		rig Delete();
	}
}

////////////////////
// --Sliding Props--
/////////////////////

setup_object_friction_mass()
{
	level.objectmass								  = [];
	level.objectmass[ "me_fruit_orange"				] = 0.5; //physics preset: fruit_small
	level.objectmass[ "me_fruit_mango_green"		] = 0.5; //physics preset: fruit_small
	level.objectmass[ "me_fruit_mango_redorange"	] = 0.5; //physics preset: fruit_small
	level.objectmass[ "paris_fruit_apple"			] = 0.5; //physics preset: fruit_small
	level.objectmass[ "com_computer_keyboard"		] = 8;	 //physics preset: laptop
	level.objectmass[ "com_computer_mouse"			] = 8;	 //physics preset: laptop
	level.objectmass[ "com_widescreen_monitor"		] = 8;	 //physics preset: laptop
	level.objectmass[ "hjk_tablet_01"				] = 8;	 //physics preset: laptop
	level.objectmass[ "bowl_wood_modern_01"			] = 0.75;//physics preset: metal_dinnerware, was .25 //changing, bowl can't be less than fruit!
	level.objectmass[ "paris_bookstore_book01"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book02"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book03"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book04"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book05"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book06"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book07"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book08"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book09"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book10"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book11"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book12"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book13"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book14"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book15"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book16"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book17"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "paris_bookstore_book18"		] = 5;	 //physics preset: picture_frame
	level.objectmass[ "debris_rubble_chunk_01_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_02_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_03_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_04_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_05_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_06_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_07_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_08_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_09_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_10_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_11_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "debris_rubble_chunk_12_phys" ] = 20;	 //physics preset: pillar_piece
	level.objectmass[ "cnd_coffee_air_pot_open_01"	] = 6;	 //physics preset: bucket_metal
	level.objectmass[ "cnd_coffee_cup_crunched_01"	] = 0.1; //physics preset: bottle_plastic
	level.objectmass[ "cnd_office_chair_01_phys"	] = 3;	 //physics preset: wood_chair
	level.objectmass[ "cnd_conference_chair_red_01" ] = 3;	 //physics preset: wood_chair
		
	level.objectfriction									  = [];
	level.objectfriction	[ "me_fruit_orange"				] = 0.41;//physics preset: fruit_small //changing from .5 so it doesn't go at same time as other stuff
	level.objectfriction	[ "me_fruit_mango_green"		] = 0.43;//physics preset: fruit_small //changing from .3 so it doesn't go at same time as other stuff
	level.objectfriction	[ "me_fruit_mango_redorange"	] = 0.43;//physics preset: fruit_small //changing from .3 so it doesn't go at same time as other stuff
	level.objectfriction	[ "paris_fruit_apple"			] = 0.41;//physics preset: fruit_small //changing from .3 so it doesn't go at same time as other stuff
	level.objectfriction	[ "com_computer_keyboard"		] = 0.3; //physics preset: laptop
	level.objectfriction	[ "com_computer_mouse"			] = 0.24;//physics preset: laptop //changing from .3 so it doesn't go at same time as other stuff
	level.objectfriction	[ "com_widescreen_monitor"		] = 0.45;//physics preset: laptop //changing from .3 so it doesn't go at same time as other stuff
	level.objectfriction	[ "hjk_tablet_01"				] = 0.27;//physics preset: laptop //changing from .3 so it doesn't go at same time as other stuff
	level.objectfriction	[ "bowl_wood_modern_01"			] = 0.46;//physics preset: metal_dinnerware //changing from .4 so it doesn't go at same time as other stuff
	level.objectfriction	[ "paris_bookstore_book01"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book02"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book03"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book04"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book05"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book06"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book07"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book08"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book09"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book10"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book11"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book12"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book13"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book14"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book15"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book16"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book17"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "paris_bookstore_book18"		] = 0.3; //physics preset: picture_frame
	level.objectfriction	[ "debris_rubble_chunk_01_phys" ] = 0.6; //physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_02_phys" ] = 0.59;//physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_03_phys" ] = 0.58;//physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_04_phys" ] = 0.53;//physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_05_phys" ] = 0.53;//physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_06_phys" ] = 0.6; //physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_07_phys" ] = 0.6; //physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_08_phys" ] = 0.6; //physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_09_phys" ] = 0.6; //physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_10_phys" ] = 0.57;//physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_11_phys" ] = 0.6; //physics preset: pillar_piece
	level.objectfriction	[ "debris_rubble_chunk_12_phys" ] = 0.55;//physics preset: pillar_piece
	level.objectfriction	[ "cnd_coffee_air_pot_open_01"	] = 0.5; //physics preset: bucket_metal
	level.objectfriction	[ "cnd_coffee_cup_crunched_01"	] = 0.3; //physics preset: bottle_plastic
	level.objectfriction	[ "cnd_office_chair_01_phys"	] = 0.2; //physics preset: wood_chair
	level.objectfriction	[ "cnd_conference_chair_red_01" ] = 0.2; //physics preset: wood_chair
}

//sliding_debris( ents, angle_modifier )
//{
//	junk = GetEntArray( ents, "targetname" );
//	foreach ( object in junk )
//	{
//		ran_force = RandomIntRange( 27, 32 );
//		object thread launch_object( ran_force, ( 0, -1, 0.1 ), angle_modifier );
//	}
//}
//
//launch_object( force_amount, force_dir, angle_modifier )
//{
//	// Using physics_preset 'friction' to determine when to move (as angle tilt increases, objects with lowest friction should go first)
//	// Using physics_preset 'mass' to determine how much force to move with
//	// Angle at which friction is overcome is inverse tangent of the coefficient of static friction).  We have to modify this for game purposes with an angle_modifier.
//	
//	// angle modifier is so we can get similar behavior of stuff going at different times but at different base angles
//	// example: if we want a 0.6 friction object to start sliding at 17 degrees, angle_modifier should be 0.55
//	// example: if we want a 0.6 friction object to start sliding at 25 degrees, angle_modifier should be 0.81
//	
//	slideangle = ( ATan( level.objectfriction[ self.model ] ) ) * angle_modifier;
//	
//	if ( !IsDefined( level.player_ref_ent.angles[ 2 ] ) )
//	{
//		current_angle = -5;
//	}
//	angle	= abs( level.player_ref_ent.angles[ 2 ] );
//	
//	while ( angle < slideangle )
//	{
//		wait( 0.05 );
//		angle = abs( level.player_ref_ent.angles[ 2 ] );
//	}
//	
//	force_amount *= level.objectmass[ self.model ];
//	force = ( force_dir[ 0 ], force_dir[ 1 ], force_dir[ 2 ] * force_amount );
//
//	self PhysicsLaunchClient( ( self.origin + ( 0, 0, -6 ) ), force );
//}

////////////////////
// --Thrown Props--
/////////////////////

debris_spawner( time_min, time_max, base_force, force_direction, randomX, randomY )
{
	level endon( "begin_atrium_fall" );
	level endon( "teleported" );
	
	//setPhysicsGravityDir( (0, -.45, -1) );
	
	while ( 1 )
	{
		if( IsDefined( randomX ))
		{
			randx = RandomIntRange( -104, 104 );
		}
		else
		{
			randx = 0;
		}
		if( IsDefined( randomY ))
		{
			randy = RandomIntRange( -104, 104 );
		}
		else
		{
			randy = 0;
		}
		randz	= RandomIntRange( 0, 16 );
	
		item			 = RandomIntRange( 0, 12 );
		level.randomitem = undefined;
		pick_debris( item );

		item1 = Spawn( "script_model", self.origin + ( randx, randy, randz ) );
		item1 SetModel( level.randomitem );
		
		force_dir	 = force_direction;
		force_amount = base_force * level.objectmass[ item1.model ];
		force		 = force_dir * force_amount;
		
		item1 PhysicsLaunchClient( item1.origin, force );
		
		item1 thread debris_remove_after_time( 7.0 );
		
		randomtime = RandomFloatRange( time_min, time_max );
		wait( randomtime );
	}
}

debris_remove_after_time( time )
{
	wait ( time );
	self Delete();
}

pick_debris( item )
{
		switch( item )
		{
			case 0:
				level.randomitem = "debris_rubble_chunk_04_phys";
				break;
			case 1:
				level.randomitem = "debris_rubble_chunk_05_phys";
				break;
			case 2:
				level.randomitem = "debris_rubble_chunk_12_phys";
				break;
			case 3:
				level.randomitem = "com_computer_keyboard";
				break;
			case 4:
				level.randomitem = "com_computer_mouse";
				break;
			case 5:
				level.randomitem = "paris_bookstore_book01";
				break;
			case 6:
				level.randomitem = "paris_bookstore_book02";
				break;
			case 7:
				level.randomitem = "paris_bookstore_book03";
				break;
			case 8:
				level.randomitem = "paris_bookstore_book04";
				break;
			case 9:
				level.randomitem = "paris_bookstore_book05";
				break;
			case 10:
				level.randomitem = "paris_bookstore_book06";
				break;
			case 11:
				level.randomitem = "paris_bookstore_book07";
				break;
			case 12:
				level.randomitem = "paris_bookstore_book08";
				break;
			case 13:
				level.randomitem = "hjk_tablet_01";
				break;
		}
}

//spawn_falling_guy( spawner, start_location, remove_time )
//{
//	// spawn the guy (can't be a drone because of the teleport)
//	guy = spawner spawn_ai( true, false );
//	if ( IsDefined( guy ) )
//	{
//		guy.ignoreme = true;
//		guy Kill();
//		guy ForceTeleport( start_location, ( 0, 0, 0 ) );
//		guy StartRagdoll();
//		if ( IsDefined( remove_time ) )
//		{
//			wait( remove_time );
//			if ( IsDefined( guy ) ) // in case it gets autodeleted
//			{
//				guy Delete();
//			}
//		}
//	}
//	else
//	{
//		AssertMsg( "spawn_falling_guy unable to spawn guy" );
//	}
//
//}
//
//// hide the entity this function is called on, and show the model it's targetted to for a short time, then swap.
//flicker_model()
//{
//	self endon( "stop_flicker_model" );
//	
//	off_model = GetEnt( self.target, "targetname" );
//	off_model Hide();
//	
//	while ( 1 )
//	{
//		wait( RandomFloatRange( 0.1, 0.3 ) );
//		self Hide();
//		off_model Show();
//		wait( RandomFloatRange( 0.25, 0.5 ) );
//		off_model Hide();
//		self Show();		
//	}
//	
//}
//
//random_flicker_model_grouped( light_group, stopper )
//{
//	level endon( stopper );
//	
//	off_model_array = [];
//	
//	foreach ( light in light_group )
//	{
//		off_model_element					 = off_model_array.size;
//		off_model_array[ off_model_element ] = GetEnt( light.target, "targetname" );
//		off_model_array[ off_model_element ] Hide();
//	}
//	
//	while ( 1 )
//	{
//		wait( RandomFloatRange( 0.05, 0.15 ) ); // on
//		light_group		= array_removeUndefined( light_group );
//		off_model_array = array_removeUndefined( off_model_array );
//		foreach ( light in light_group )
//		{	
//			light Hide();
//		}
//		foreach ( off_light in off_model_array )
//		{
//			off_light Show();
//		}
//		wait( RandomFloatRange( 0.2, 0.4 ) ); // off
//		light_group		= array_removeUndefined( light_group );
//		off_model_array = array_removeUndefined( off_model_array );
//		foreach ( off_light in off_model_array )
//		{
//			off_light Hide();
//		}
//		foreach ( light in light_group )
//		{	
//			light Show();
//		}
//	}
//}
//
//lights_on( light_array )
//{
//	foreach ( light in light_array )
//	{
//		light Show();
//		off_model = GetEnt( light.target, "targetname" );
//		off_model Hide();
//	}	
//}
//
//lights_off( light_array )
//{
//	foreach ( light in light_array )
//	{
//		light Hide();
//		off_model = GetEnt( light.target, "targetname" );
//		off_model Show();
//	}	
//}	

// -- utility funcitons --
///*
//=============
/////ScriptDocBegin
//"Name: flag_wait_and_spawn( <flag_to_watch>, <spawner_targetname )"
//"Summary: waits on the flag and then activates the ai spawners with the given targetname"
//"Mandatory Arg: <flag_to_watch>: Wait on this flag."
//"Mandatory Arg: <spawner_targetname>: The target name of the AI spawners"
//"Example: flag_wait_and_spawn( "trigger_wave_01", "wave_01_spawners" )"
//"SPMP: singleplayer"
/////ScriptDocEnd
//=============
//*/
//flag_wait_and_spawn( flag_to_watch, spawner_targetname )
//{
//	flag_wait( flag_to_watch );
//	targetname_spawn( spawner_targetname );
//}
//
///*
//=============
/////ScriptDocBegin
//"Name: targetname_spawn( <targetname )"
//"Summary: activates the ai spawners with the given targetname"
//"Mandatory Arg: <targetname>: The target name of the AI spawners."
//"Example: targetname_spawn( "wave_01_spawners" )"
//"SPMP: singleplayer"
/////ScriptDocEnd
//=============
//*/
//targetname_spawn( targetname )
//{
//	enemies = GetEntArray( targetname, "targetname" );
//	
//	// handle coop only spawning in spec ops SP
//	if ( is_specialop() && !is_coop() )
//	{
//		foreach ( enemy in enemies )
//		{		
//			// if this enemy is marked as COOP ONLY, remove him from spawn array			
//			if ( IsDefined( enemy.script_parameters ) && ( enemy.script_parameters == "coop_only" ) )
//			{
//				enemies = array_remove( enemies, enemy );
//			}
//		}
//	}
//	
//	array_thread( enemies, ::spawn_ai );
//}

//chopper spotlights
littlebird_handle_spotlight( delay, follow_player, offset, variance, script_origin, target_random_ent_in_array )
{
	self ent_flag_init( "spotlight_on" );

	self.spotlight = SpawnTurret( "misc_turret", self GetTagOrigin( "tag_flash" ), "heli_spotlight" );
	
	self.spotlight SetMode( "manual" );
	self.spotlight SetModel( "com_blackhawk_spotlight_on_mg_setup" );
	self.spotlight LinkTo( self, "tag_flash", ( 0, 0, -7 ), ( -20, 0, 0 ) );

	self thread littlebird_spotlight_think( delay, follow_player, offset, variance, script_origin, target_random_ent_in_array );
	self thread littlebird_spotlight_death();
	
}

littlebird_spotlight_death()
{
    spotlight = self.spotlight;
    self waittill ( "death" );
    
    if ( IsDefined( spotlight ) )
    	spotlight Delete();
    
}

littlebird_spotlight_on()
{
  PlayFXOnTag( getfx( "spotlight" ), self.spotlight, "tag_flash" );
}

littlebird_spotlight_off()
{
	StopFXOnTag( getfx( "spotlight" ), self.spotlight, "tag_flash" );
}

littlebird_spotlight_think( delay, follow_player, offset, variance, script_origin, target_random_ent_in_array )
{
  self endon ( "death" );

	self notify( "stop_littlebird_spotlight" );
	self endon( "stop_littlebird_spotlight" );

	if ( !IsDefined( delay ) )
	{
		delay = 0;
	}
	
	if ( !IsDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	
	if ( !IsDefined( variance ) )
	{
		variance = 0;
	}

	if ( delay > 0 )
	{
		//allow time for spotlight to orient
		self delayThread( delay, ::littlebird_spotlight_on );
	}
	else
	{
		self littlebird_spotlight_on();
	}

	if ( IsDefined( follow_player ) && follow_player )
	{
		while ( 1 )
		{
			self.spotlight SetTargetEntity( level.player, offset + randomvector( variance ) );
	
			wait( RandomFloatRange( 2, 3 ) );
		}
	}
	else if ( IsDefined( script_origin ) )
	{
		while ( 1 )
		{
			self.spotlight SetTargetEntity( script_origin, offset + randomvector( variance ) );
	
			wait( RandomFloatRange( 2, 3 ) );
		}
	}
	else if ( IsDefined( target_random_ent_in_array ) )
	{
		//make convergence time lower so it looks like the guy on the spotlight is searching between targets quicker
		self.spotlight SetConvergenceTime( 0.5, "yaw" );
		self.spotlight SetConvergenceTime( 0.5, "pitch" );
		
		while ( 1 )
		{
			ent = random( target_random_ent_in_array );
			
			max_time = RandomFloatRange( 1.5, 3.0 );
			
			time = 0.0;
			
			while ( time <= max_time )
			{
				self.spotlight SetTargetEntity( ent, offset + randomvector( variance ) );
				
				time += 0.05;
				
				wait( 0.05 );
			}
		}
	}
	else
	{
		forward		= AnglesToForward( self.spotlight.angles );
		spot_target = Spawn( "script_origin", self.spotlight.origin + forward * 500 + ( 0, 0, -500 ) );
		spot_target LinkTo( self );
		
		self.spotlight SetTargetEntity( spot_target, offset + randomvector( variance ) );
		
		time = 1;
		
		while ( 1 )
		{
			self.spotlight SetTargetEntity( spot_target, offset + randomvector( variance ) );
			
			wait( RandomFloatRange( 2, 3 ) );
		}
	}
}

send_to_node_and_set_flag_if_specified_when_reached( node, flag_to_set_when_reached_node )
{
	self set_goalradius( 16 );
	self SetGoalNode( node );
	
	if ( IsDefined( flag_to_set_when_reached_node ) )
	{
		self waittill( "goal" );
		flag_set( flag_to_set_when_reached_node );
	}
}

// temp_dialogue() - mock subtitle for a VO line not yet recorded and processed
//   <speaker>: Who is saying it?
//   <text>: What is being said?
//   <duration>: [optional] How long is to be shown? (default 4 seconds)

temp_dialogue( speaker, text, duration )
{
	level notify( "temp_dialogue", speaker, text, duration );
	level endon( "temp_dialogue" );
	
	if ( !IsDefined( duration ) )
	{
		duration = 4;
	}
	
	if ( IsDefined( level.tmp_subtitle ) )
	{
		level.tmp_subtitle Destroy();
		level.tmp_subtitle = undefined;
	}
	
	level.tmp_subtitle	 = NewHudElem();
	level.tmp_subtitle.x = -60;
	level.tmp_subtitle.y = -62;
	level.tmp_subtitle SetText( "^2" + speaker + ": ^7" + text );
	level.tmp_subtitle.fontScale   = 1.46;
	level.tmp_subtitle.alignX	   = "center";
	level.tmp_subtitle.alignY	   = "middle";
	level.tmp_subtitle.horzAlign   = "center";
	level.tmp_subtitle.vertAlign   = "bottom";
	//level.tmp_subtitle.vertAlign = "middle";
	level.tmp_subtitle.sort		   = 1;

	wait duration;

	thread temp_dialogue_fade();
}

temp_dialogue_fade()
{
	level endon( "temp_dialogue" );
	for ( alpha = 1.0; alpha > 0.0; alpha -= 0.1 )
	{
		level.tmp_subtitle.alpha = alpha;
		wait 0.05;
	}
	level.tmp_subtitle Destroy();
}

watch_player_pitch_in_volume( volume_name, event, flag, time, endon_string )
{
	self endon( "death" );
	
	if ( IsDefined( endon_string ) )
		level endon( endon_string );
	
	volume = GetEnt( volume_name, "targetname" );
	
	count = 0;
	
	while ( !flag( flag ) )
	{
		yaw_current	  = self GetPlayerAngles()[ 1 ];
		pitch_current = self GetPlayerAngles()[ 0 ];
		
		if ( self IsTouching( volume ) )
		{
			if ( event == "copymachine" )
			{
				if ( pitch_current < -30 )
				{
					//if ( abs( 0 - yaw_current ) < 40 )
					if ( yaw_current < 25 && yaw_current > -110 )
					{
						flag_set( flag );
					}
				}
			}
			else if ( event == "player_has_looked_up_for_count" )
			{
				if ( pitch_current < -30 )
				{
					if ( yaw_current < 50 && yaw_current > -30 )
					{
						if ( count == time )
						{
							flag_set( flag );
						}
						else
						{
							count++;
						}
					}
					else
					{
						if ( count > 0 )
						{
							count = 0;	
						}
					}
				}
			}
			else if ( event == "fx" )
			{
				if ( pitch_current > -30 )
				{
					flag_set( flag );
				}
			}
			else if ( event == "grenade" )
			{
				if ( pitch_current > -30 )
				{
					if ( yaw_current > -45 && yaw_current < -15 )
					{
						if ( count == time )
						{
							flag_set( flag );
						}
						else
						{
							count++;
						}
					}
					else
					{
						if ( count > 0 )
						{
							count = 0;	
						}
					}
				}
			}
			else if ( event == "rorke_building_entry" )
			{
				if ( pitch_current > -30 )
				{
					if ( yaw_current < -25 ) //&& yaw_current > -98 )
					{
						flag_set( flag );
					}
				}
			}
		}
		wait( 0.01 );
	}
}

wait_till_shot( flag_to_end_on, flag_to_set, notify_to_set )
{
	self endon( "death" );
	
	if ( IsDefined( flag_to_end_on ) )
	{
		level endon( flag_to_end_on );
	}
	
	self AddAIEventListener( "grenade danger" );
	self AddAIEventListener( "gunshot" );
	self AddAIEventListener( "gunshot_teammate" );
	self AddAIEventListener( "silenced_shot" );
	self AddAIEventListener( "bulletwhizby" );
	self AddAIEventListener( "projectile_impact" );

    self waittill( "ai_event", eventtype );
    
    if ( IsDefined( flag_to_set ) )
    {
    	flag_set( flag_to_set ); //this is meant to break stealth for all
    }
    
    if ( IsDefined( notify_to_set ) )
    {
    	self notify( notify_to_set ); //this is meant to break stealth for one
    }
}

alert_all( flag_to_wait_on, flag_to_wait_on2, flag_to_wait_on3 )
{
	self endon( "death" );
	
	if ( IsDefined( flag_to_wait_on3 ) )
	{
		flag_wait_any( "enemies_aware", flag_to_wait_on, flag_to_wait_on2, flag_to_wait_on3 );		
	}
	else if ( IsDefined( flag_to_wait_on2 ) )
	{
		flag_wait_any( "enemies_aware", flag_to_wait_on, flag_to_wait_on2 );
	}
	else if ( IsDefined( flag_to_wait_on ) )
	{
		flag_wait_any( "enemies_aware", flag_to_wait_on );
	}
	else
	{
		flag_wait( "enemies_aware" );
	}
	
	self notify( "enemy_aware" );
}

watch_for_death_and_alert_all_in_volume( flag_to_end_on, flag_to_set )
{
	self endon( "enemy_aware" );
	if ( IsDefined( flag_to_end_on ) )
	{
		level endon( flag_to_end_on );
	}
	
	self waittill( "death" );
	
	ai_in_volume = self.volume get_ai_touching_volume( "axis" );

	if ( IsDefined ( ai_in_volume ) && ai_in_volume.size != 0 )
	{
		if ( IsDefined( flag_to_set ) )
		{
			flag_set( flag_to_set );
		}
		else
		{
			foreach ( ai in ai_in_volume )
			{
				ai notify( "enemy_aware" );	
			}
		}
	}
}

watch_for_player_to_shoot_while_in_volume( volume, flag_to_set, flag_to_end_while_loop )
{
	while ( !flag( flag_to_end_while_loop ) )
	{
		if ( self IsTouching( volume ) )
		{
			if ( self AttackButtonPressed() )
			{	
				flag_set( flag_to_set );
				break;
			}
		}
		wait( 0.01 );
	}
}

coordinated_kills( ally, enemy_array, flag_to_wait_on, flag_to_end_on, flag_to_set )
{
	level endon( flag_to_end_on );
	//level endon( "enemies_aware" );
	
	if ( IsDefined( flag_to_set ) )
	{
		level endon( flag_to_set );
	}
	
	flag_wait( flag_to_wait_on );
	
	// give the player a moment to shoot them all
	level.player waittill_notify_or_timeout( "damage", 1 );
	
	if ( IsDefined( flag_to_set ) )
	{
		thread ally_to_magicbullet( ally, enemy_array, flag_to_set );
	}
	else
	{
		thread ally_to_magicbullet( ally, enemy_array );
	}
}

ally_to_magicbullet( ally, dude_array, flag_to_set )
{	
	
	dude_array			  = array_removeDead( dude_array );
	last_known_array_size = dude_array.size;
	
	if ( dude_array.size > 0 )
	{
		index		= RandomInt( dude_array.size );
		random_dude = dude_array[ index ];
		
		while ( IsDefined( random_dude ) && IsAlive( random_dude ) )
		{
			ally_head  = ally GetTagOrigin( "j_head" );
			enemy_head = random_dude GetTagOrigin( "j_head" );
			
			vector			   = VectorNormalize( enemy_head - ally_head );
			start			   = ally_head + vector * ( Distance( enemy_head, ally_head ) - 10 );
			random_dude.health = 1;
			MagicBullet( ally.weapon, start, enemy_head );
			wait( 0.1 );
		}	
	}
	
	if ( IsDefined( flag_to_set ) )
	{
		flag_set( flag_to_set );
	}
}

time_to_pass_before_hint( time_to_pass_before_hint_int, hint_to_display, flag_to_set, timeout_length )
{
	count = 0;
		
	while ( 1 )
	{
		if ( count == time_to_pass_before_hint_int )
		{
			if ( IsDefined( flag_to_set ) && flag( flag_to_set ) )
			{
				break;
			}
			else
			{
				if ( IsDefined( timeout_length ) )
				{
				   	level.player display_hint_timeout( hint_to_display, timeout_length );
				}
				else
				{
					level.player thread display_hint( hint_to_display );
				}
				break;
			}
		}
		wait( 1 );
		count++;
	}
}

watch_player_in_volume( volume, flag_to_set, flag_to_end_on, time )
{
	if ( IsDefined( flag_to_end_on ) )
	{
		level endon( flag_to_end_on );
	}
	
	count = 0;
	
	while ( 1 )
	{
		if ( level.player IsTouching( volume ) )
		{
			if ( IsDefined( time ) )
			{
				if ( count == time )
				{
					flag_set( flag_to_set );
					break;
				}
				else
				{
					count++;
				}
			}
			else
			{
				flag_set( flag_to_set );
				break;				
			}
		}
		else
		{
			if ( IsDefined( time ) )
			{
				if ( count > 0 )
				{
					count = 0;	
				}
			}
		}
		wait( 0.05 );
	}
}

nag_until_flag( nag_lines_array, ender_flag, min_wait, max_wait, increment )
{
	if ( flag( ender_flag )	 ) // don't play lines if flag already set
	{
		return;
	}
	
	last_line = -1;
		
	while ( !flag( ender_flag ) )
	{	
		wait_time = RandomFloatRange( min_wait, max_wait );
		wait ( wait_time );
		vo_index = RandomInt( nag_lines_array.size );
		if ( vo_index == last_line )
		{
			vo_index++;
			if ( vo_index >= nag_lines_array.size )
				vo_index = 0;
		}
		random_vo = nag_lines_array[ vo_index ];

		if ( flag( ender_flag ) )
		{
			break;
		}
		
		thread smart_radio_dialogue( random_vo );
		
		last_line = vo_index;
		min_wait  = min_wait + increment;
		max_wait  = max_wait + increment;
	}
}

entity_cleanup( flag_to_wait_on )
{
	if ( IsDefined( flag_to_wait_on ) )
	{
		flag_wait( flag_to_wait_on );
	}
	
	if ( IsDefined( self ) )
	{
		self Delete();
	}
}

////////////////////////////
// BAR
////////////////////////////

FADE_OUT_TIME = 0.3;

custom_fade_out( time, shader, alpha )
{
	if ( !IsDefined( time ) )
		time	= FADE_OUT_TIME;

	overlay = maps\_hud_util::get_optional_overlay( shader );

	if ( time > 0 )
		overlay FadeOverTime( time );
	
	if ( !IsDefined( alpha ) )
	{
		overlay.alpha	= 1;
	}
	else
	{
		overlay.alpha = alpha;
	}
	
	wait( time );
}

//---------------------------------------------------------
// Limp Section - copied from london_code.gsc - cleaned up unused stuff
//---------------------------------------------------------
/*limp()
{
	if ( !flag_exist( "limp" ) )
	{
		flag_init( "limp" );
	}

	flag_set( "limp" );

	level.limping		 = true;
	level.ground_ref_ent = Spawn( "script_model", ( 0, 0, 0 ) );
	level.player PlayerSetGroundReferenceEnt( level.ground_ref_ent );

	thread limp_stun( undefined, true );

	// Threads.
	thread limp_slowmo();

	unsteady_scale = 4.1;
	unsteady_max   = 4.1;
	//limp_time	   = 15 * 20; // 20 is for server framerate - 300
	limp_time	   = 60 * 20;		 //20 is for server framerate - 300
	unsteady_inc   = 4.1 / limp_time;//0.014

	movement_slow	  = 0.2;
	movement_slow_inc = ( 1 - movement_slow ) / limp_time;
	//movement_fast	  = 0.8;
	movement_fast	  = 0.6;
	movement_fast_inc = ( 1 - movement_fast ) / limp_time;
	level.player SetMoveSpeedScale( 0.3 );

	time		= 0.1;
	pitch_sin	= 0;
	last_angles = level.player GetPlayerAngles()[ 1 ];
	prev_s		= 0;

	limp_dir = "down";

	for ( ;; )
	{
		new_angles	= level.player GetPlayerAngles()[ 1 ];
		dif			= new_angles - last_angles;
		yaw			= dif;
		last_angles = new_angles;

		player_speed = Length( level.player GetVelocity() );

		if ( player_speed == 0 )
		{
			wait( 0.05 );
			continue;
		}

		unsteady_ratio = unsteady_scale / unsteady_max;
		pitch_sin += player_speed * 0.06;

		s = Sin( pitch_sin );
		s = abs( s );

		movement_fast += movement_fast_inc;
		movement_slow += movement_slow_inc;

		if ( prev_s != s )
		{
			if ( prev_s - s > 0 )
			{
				if ( limp_dir != "up" )
				{
					limp_dir = "up";
					level.player blend_movespeedscale( movement_fast, 0.25 );
				}
			}
			else
			{
				if ( limp_dir != "down" )
				{
					thread limp_stun( unsteady_ratio );
					limp_dir = "down";
					level.player blend_movespeedscale( movement_slow, 0.1 );
				}
			}
		}

		if ( unsteady_scale > 0 )
		{
			unsteady_scale -= unsteady_inc;
			unsteady_scale = max( unsteady_scale, 0 );
		}

		pitch  = s * 4 * unsteady_scale;
		prev_s = s;

		angles = ( pitch * 0.5 * -1, 0, pitch * 0.6 );
		level.ground_ref_ent RotateTo( angles, time, time * 0.5, time * 0.5 );
			
		wait( 0.05 );

		if ( unsteady_scale == 0 )
		{
			break;
		}
	}

	flag_clear( "limp" );
	SetSlowMotion( 0.95, 1, 0.5 );

	level.limping = undefined;

	overlay = get_black_overlay();
	overlay FadeOverTime( 0.5 );
	overlay.alpha = 0;
	wait( 1 );
	overlay Destroy();

	// Make sure we don't have any blur when fully recovered
	SetBlur( 0, 1 );
}

limp_stun( scale, skip_speed )
{
	level endon( "limp" );
	level notify( "stop_limp_stun" );
	level endon( "stop_limp_stun" );

	if ( !flag( "limp" ) )
	{
		return;
	}

	if ( !IsDefined( scale ) )
	{
		scale = 1;
	}

	if ( scale < 0.2 )
	{
		return;
	}

	if ( !IsDefined( skip_speed ) )
	{
		while ( 1 )
		{
			player_speed = Distance( ( 0, 0, 0 ), level.player GetVelocity() );
	
			if ( player_speed > 80 )
			{
				break;
			}
	
			wait( 0.05 );
		}
	}

	stun_time = 2.3 * scale;
	level.player thread play_sound_on_entity( "breathing_hurt" );
				  //   timer    func 	   param1     param2   
	noself_delayCall( 0.5	 , ::SetBlur, 4 * scale, .25 );
	noself_delayCall( 1.2	 , ::SetBlur, 0		   , 1 );

	delayThread( stun_time, ::limp_random_blur );
	thread limp_fade( stun_time );

	level.player PlayRumbleOnEntity( "damage_light" );
}

limp_fade( stun_time )
{
	if ( !flag( "limp" ) )
	{
		return;
	}
	
	black_overlay = get_black_overlay();
	black_overlay FadeOverTime( stun_time * 3 );
	//black_overlay.alpha = RandomFloatRange( 0.9, 0.95 );
	black_overlay.alpha	  = RandomFloatRange( 0.7, 0.75 );

	wait( stun_time );

	if ( !flag( "limp" ) )
	{
		return;
	}

	black_overlay FadeOverTime( stun_time );
	black_overlay.alpha = 0;
}

limp_random_blur()
{
	level endon( "limp" );
	level notify( "stop_random_blur" );
	level endon( "stop_random_blur" );

	if ( !flag( "limp" ) )
	{
		return;
	}

	while ( true )
	{
		wait( 0.05 );
		if ( RandomInt( 100 ) > 10 )
		{
			continue;
		}

		blur		  = RandomInt( 3 ) + 2;
		blur_time	  = RandomFloatRange( 0.3, 0.7 );
		recovery_time = RandomFloatRange( 0.3, 1 );

		SetBlur( blur * 1.2, blur_time );
		wait( blur_time );
		SetBlur( 0, recovery_time );
		wait( 3 );
	}
}

limp_slowmo()
{
	level endon( "limp" );
	timescale = 1;
	time	  = 3;

	if ( !flag( "limp" ) )
	{
		return;
	}

	wait( 3 );

	for ( ;; )
	{
		SetSlowMotion( timescale, 0.89, time );
		wait( time + RandomFloat( 1 ) );
		SetSlowMotion( timescale, 1.06, time );
		wait( time + RandomFloat( 1 ) );
	}
}

get_black_overlay()
{
	if ( !IsDefined( level.black_overlay ) )
	{
		level.black_overlay = create_client_overlay( "black", 0, level.player );
	}

	level.black_overlay.sort	   = -1;
	level.black_overlay.foreground = false;
	return level.black_overlay;
}*/

////////////////////////////
// STEALTH
////////////////////////////
#using_animtree( "generic_human" );
custom_cornered_stealth_settings()
{
	ai_event[ "ai_eventDistDeath"		   ] = [];
	ai_event[ "ai_eventDistPain"		   ] = [];
	ai_event[ "ai_eventDistExplosion"	   ] = [];
	ai_event[ "ai_eventDistBullet"		   ] = [];
	ai_event[ "ai_eventDistFootstep"	   ] = [];
	ai_event[ "ai_eventDistFootstepWalk"   ] = [];
	ai_event[ "ai_eventDistFootstepSprint" ] = [];
	ai_event[ "ai_eventDistGunShot"		   ] = [];
	ai_event[ "ai_eventDistGunShotTeam"	   ] = [];
	ai_event[ "ai_eventDistNewEnemy"	   ] = [];

	ai_event[ "ai_eventDistDeath" ][ "spotted" ] = 1024;
	ai_event[ "ai_eventDistDeath" ][ "hidden"  ] = 128;

	ai_event[ "ai_eventDistPain" ][ "spotted" ] = 512;
	ai_event[ "ai_eventDistPain" ][ "hidden"  ] = 128;

	ai_event[ "ai_eventDistExplosion" ][ "spotted" ] = 4000;
	ai_event[ "ai_eventDistExplosion" ][ "hidden"  ] = 4000;

	ai_event[ "ai_eventDistBullet" ][ "spotted" ] = 96;
	ai_event[ "ai_eventDistBullet" ][ "hidden"	] = 64;

	ai_event[ "ai_eventDistFootstep" ][ "spotted" ] = 256;
	ai_event[ "ai_eventDistFootstep" ][ "hidden"  ] = 64;

	ai_event[ "ai_eventDistFootstepWalk" ][ "spotted" ] = 128;
	ai_event[ "ai_eventDistFootstepWalk" ][ "hidden"  ] = 32;
	
	ai_event[ "ai_eventDistFootstepSprint" ][ "spotted" ] = 400;
	ai_event[ "ai_eventDistFootstepSprint" ][ "hidden"	] = 256;
	
	ai_event[ "ai_eventDistGunShot" ][ "spotted" ] = 2048;
	ai_event[ "ai_eventDistGunShot" ][ "hidden"	 ] = 2048;

	ai_event[ "ai_eventDistGunShotTeam" ][ "spotted" ] = 750;
	ai_event[ "ai_eventDistGunShotTeam" ][ "hidden"	 ] = 750;
	
	ai_event[ "ai_eventDistNewEnemy" ][ "spotted" ] = 750;
	ai_event[ "ai_eventDistNewEnemy" ][ "hidden"  ] = 512;
	
	stealth_ai_event_dist_custom( ai_event );
	
	rangesHidden[ "prone"  ] = 200;
	rangesHidden[ "crouch" ] = 300;
	rangesHidden[ "stand"  ] = 400;

	rangesSpotted[ "prone"	] = 400;
	rangesSpotted[ "crouch" ] = 600;
	rangesSpotted[ "stand"	] = 1200;
	
	stealth_detect_ranges_set( rangesHidden, rangesSpotted );

	array[ "player_dist" ] = 500;
	array[ "sight_dist"	 ] = 500;
	array[ "detect_dist" ] = 200;
	
	stealth_corpse_ranges_custom( array );
}

//This is cool because you can change settings for an event then change them back again just by calling the previous function.
custom_bar_stealth_setting()
{
	//level.corpse_behavior_doesnt_require_player_sight = true;
	
	rangesHidden[ "prone"  ] = 200;
	rangesHidden[ "crouch" ] = 240;
	rangesHidden[ "stand"  ] = 300;

	rangesSpotted[ "prone"	] = 300;
	rangesSpotted[ "crouch" ] = 400;
	rangesSpotted[ "stand"	] = 550;
	
	stealth_detect_ranges_set( rangesHidden, rangesSpotted );
	
	array[ "player_dist" ] = 400;
	array[ "sight_dist"	 ] = 400;
	array[ "detect_dist" ] = 256;
	
	stealth_corpse_ranges_custom( array );	
}

custom_bar_enemy_state_spotted( internal )
{
	//everything is the same as enemy_state_spotted but without battlechatter.  This is used if the light is shot out.
	
	self.fovcosine	   = 0.01;// 90 degrees to either side...180 cone...default view cone
	self.ignoreall	   = false;
	self.dontattackme  = undefined;
	self.dontevershoot = undefined;
	if ( IsDefined( self.oldfixednode ) )
		self.fixednode = self.oldfixednode;

	if ( self.type != "dog" )
	{
		self.dieQuietly	= false;

		if ( !IsDefined( internal ) )
		{
			self clear_run_anim();
			self maps\_stealth_shared_utilities::enemy_stop_current_behavior();
		}
	}
	else
	{
		self.script_growl  = undefined;
		self.script_nobark = undefined;
	}

	if ( IsDefined( internal ) )
		return;
	
	if ( IsDefined( level._stealth.group.spotted_enemy ) )
	{
		enemy = level._stealth.group.spotted_enemy[ self.script_stealthgroup ];
		if ( IsDefined( enemy ) )
			self GetEnemyInfo( enemy );
	}
}

//wait_till_every_thing_stealth_normal_for( time )
//{
//	while ( 1 )
//	{
//		if ( stealth_is_everything_normal() )
//		{
//			wait time;	
//			if ( stealth_is_everything_normal() )
//				return;
//		}
//		wait 1;
//	}
//}
//
//custom_bar_corpse_found_behavior()
//{
//	node = custom_enemy_find_free_pathnode_near( level._stealth.logic.corpse.last_pos, 192, 8 );
//
//	if ( !IsDefined( node ) )
//		return;
//
//	self thread maps\_stealth_shared_utilities::enemy_runto_and_lookaround( node );
//}
//
//// -running custom pathnode find to change height check down below-
//custom_enemy_find_free_pathnode_near( origin, radius, min_radius )
//{
//	array = custom_enemy_get_nearby_pathnodes( origin, radius, min_radius );
//
//	if ( !IsDefined( array ) || array.size == 0 )
//		return;
//
//	node  = array[ RandomInt( array.size ) ];
//	array = array_remove( array, node );
//	
//	while ( IsDefined( node.owner ) )
//	{
//		if ( array.size == 0 )
//			return;
//			
//		node  = array[ RandomInt( array.size ) ];
//		array = array_remove( array, node );
//	}
//	
//	level._stealth.node_search.nodes_array = array;
//	
//	return node;
//}
//
//custom_enemy_get_nearby_pathnodes( origin, radius, min_radius )
//{
//	if ( !IsDefined( min_radius ) )
//		min_radius = 0;
//
//	if ( IsDefined( level._stealth.node_search.nodes_array ) &&
//		 DistanceSquared( origin, level._stealth.node_search.origin ) < 64 * 64 &&
//		 radius == level._stealth.node_search.radius &&
//		 min_radius == level._stealth.node_search.min_radius )
//		return level._stealth.node_search.nodes_array;
//
//	level._stealth.node_search.origin	  = origin;
//	level._stealth.node_search.radius	  = radius;
//	level._stealth.node_search.min_radius = min_radius;
//	
//	level._stealth.node_search.nodes_array = GetNodesInRadius( origin, radius, min_radius, 160, "Path" ); //Don't want bar enemies going upstairs.  Default is 512.
//	
//	return level._stealth.node_search.nodes_array;
//}

ally_stealth_settings()
{
	self endon( "death" );
	level endon( "rorke_stealth_end" );
	
	while ( true )
	{
		flag_waitopen( "_stealth_spotted" );
		
		self ClearEnemy();
		//self thread set_battlechatter( false );
		self.grenadeammo = 0;
		self.ignoreme	 = true;
		self enable_dontevershoot();
		self enable_cqbwalk();
		self set_ignoreall( true );
		self set_baseaccuracy( 1 );
		self PushPlayer( true );
		
		flag_wait( "_stealth_spotted" );
		
		//self thread set_battlechatter( true );
		self.grenadeammo = 3;
		self.ignoreme	 = false;
		self disable_dontevershoot();
		self disable_cqbwalk();
		self set_ignoreall( false );
		self set_baseaccuracy( 0.75 );
		//self enable_arrivals();
		//self enable_exits();
		self PushPlayer( false );
		self AllowedStances( "prone", "crouch", "stand" );
		//self enable_ai_color();
	}
}

////dialogue stack
////call this on a guy with the vo line you want added to his vo stack
//dialogue( msg )
//{
//	if ( !IsDefined( self.scripted_dialogue_struct ) )
//	{
//		self.scripted_dialogue_struct = SpawnStruct();
//	}
//	
//	self.scripted_dialogue_struct function_stack( ::dialogue_stack, self, msg );
//}
//
//dialogue_stack( guy, msg )
//{
//	guy maps\_utility_code::add_to_dialogue( msg );
//	guy maps\_utility::dialogue_queue( msg );
//}
//
////clear a guy's vo stack if he has one
//clear_dialogue_stack()
//{	
//	if ( IsDefined( self.scripted_dialogue_struct ) )
//	{
//		if ( IsDefined( self.function_stack ) && ( self.function_stack.size > 0 ) )
//		{
//			self.scripted_dialogue_struct maps\_utility::function_stack_clear();
//		}
//	}
//}

// wrapped built-ins for use with array_thread
delete_wrapper()
{
	self Delete();
}

//anim_struct is temp, should all play on level.zipline_anim_struct eventually
launch_rope( anim_struct, rope, fire_anim_alias, rest_loop_anim_alias )
{	
	anim_struct anim_single_solo( rope, fire_anim_alias );
	anim_struct thread anim_loop_solo( rope, rest_loop_anim_alias, "stop_" + rest_loop_anim_alias );

	
	flag_wait( "player_detach" );
	anim_struct notify( "stop_" + rest_loop_anim_alias );
	rope Delete();
}

delete_building_glow()
{
	building_glow_card = GetEnt( "building_glow", "targetname" );
	if ( IsDefined( building_glow_card ) )
		building_glow_card Delete();
}

delete_window_reflectors()
{
	window_reflectors = GetEntArray( "window_reflectors", "targetname" );
	foreach ( window_reflector in window_reflectors )
	{
		if ( IsDefined( window_reflector ) )
			window_reflector Delete();
	}

}

//lerp_player_view_to_position_and_view_angles_accurate( origin, angles, right_arc, left_arc, top_arc, bottom_arc, lerptime )
//{
//	player_angles = level.player GetPlayerAngles();
//	pitch		  = player_angles[ 0 ];
//	yaw			  = player_angles[ 1 ];
//	
//	min_pitch = AngleClamp180( angles[ 0 ] ) - bottom_arc;
//	max_pitch = AngleClamp180( angles[ 0 ] ) + top_arc;
//	min_yaw	  = AngleClamp180( angles[ 1 ] ) - left_arc;
//	max_yaw	  = AngleClamp180( angles[ 1 ] ) - right_arc;
//	
//	if ( pitch < min_pitch )
//		pitch = min_pitch;
//	else if ( pitch > max_pitch )
//		pitch = max_pitch;
//	
//	if ( yaw < min_yaw )
//		yaw = min_yaw;
//	else if ( yaw > max_yaw )
//		yaw = max_yaw;
//		
//	new_angles = ( pitch, yaw, 0 );
//		
//	lerp_player_view_to_position_accurate( origin, new_angles, lerptime );
//}

lerp_entity_to_position_accurate( ent, origin, angles, lerptime )
{
	linker = Spawn( "script_model", ent.origin );
	linker SetModel( "tag_origin" );
	linker.angles = ent.angles;

	ent LinkTo( linker, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );

	linker MoveTo( origin, lerptime );
	linker RotateTo( angles, lerptime );
	wait( lerptime );
	linker Delete();
}

//lerp_player_view_to_position_accurate( origin, angles, lerptime )
//{
//	linker = Spawn( "script_model", level.player GetOrigin() );
//	linker SetModel( "tag_origin" );
//	linker.angles = level.player GetPlayerAngles();
//
//	level.player PlayerLinkTo( linker, "tag_origin", 0, 0, 0, 0, 0, false );
//
//	linker MoveTo( origin, lerptime );
//	linker RotateTo( angles, lerptime );
//	wait( lerptime );
//	linker Delete();
//}

setup_trig_constants()
{
	level.cosine[ "1" ] = Cos( 1 );
	level.cosine[ "2" ] = Cos( 2 );
	level.cosine[ "3" ] = Cos( 3 );
	level.cosine[ "4" ] = Cos( 4 );
	level.cosine[ "5" ] = Cos( 5 );
}

to_string( num )
{
	return( "" + num );
}

within_player_rappel_fov_2d( player, target, fov_cos )
{
	Assert( IsDefined( player ) );
	Assert( IsDefined( target ) && IsAI( target ) );

	player_angles_relative	 = self GetPlayerAngles();
	player_angles_worldspace = CombineAngles( level.plyr_rpl_groundref.angles, player_angles_relative );

	in_fov = within_fov_2d( player GetEye(), player_angles_worldspace, target GetTagOrigin( "j_spine4" ), fov_cos );
	return in_fov;
}

player_get_favorite_enemy( max_distance )
{
	if ( !self AdsButtonPressed() )
	{
		return;
	}

	all_enemies = GetAIArray( "axis" );
	
	best_enemy		= undefined;
	best_dist_sq	= undefined;
	angle_min		= 1;
	angle_max		= 5;
	angle_increment = 1;
	max_distance_sq = max_distance * max_distance;
	
	for ( angle = angle_min; angle <= angle_max; angle += angle_increment )
	{
		foreach ( enemy in all_enemies )
		{
			if ( !within_player_rappel_fov_2d( self, enemy, level.cosine[ to_string( angle ) ] ) )
			{
				continue;
			}
			
			dist_sq = DistanceSquared( self.origin, enemy.origin );
			
			if ( dist_sq > max_distance_sq )
			{
				continue;
			}
			 
			if ( !IsDefined( best_dist_sq ) || dist_sq < best_dist_sq )
			{
				best_enemy	 = enemy;
				best_dist_sq = dist_sq;
			}
		}
		
		if ( IsDefined( best_enemy ) )
		{
			break;
		}
	}
	
	return best_enemy;
}

//player_rappel_draw_custom_angle_fov( angle )
//{
//	while ( true )
//	{
//		fov_yaw					 = angle;
//		player_angles_relative	 = self GetPlayerAngles();
//		player_angles_worldspace = CombineAngles( level.plyr_rpl_groundref.angles, player_angles_relative );
//		eye_yaw					 = player_angles_worldspace[ 1 ];
//		eye_pitch				 = player_angles_worldspace[ 0 ];
//		if ( eye_yaw < 0 )
//		{
//			eye_yaw = 360 + eye_yaw;
//		}
//		
//		leftDir	 = AnglesToForward( ( eye_pitch, eye_yaw + fov_yaw, 0 ) );
//		rightDir = AnglesToForward( ( eye_pitch, eye_yaw - fov_yaw, 0 ) );
//		
//		viewDist  = 1500;
//		start	  = self.origin;
//		left_end  = start + leftDir * viewDist;
//		right_end = start + rightDir * viewDist;
//		
//		Line( start, left_end , ( 1, 0, 0 ) );
//		Line( start, right_end, ( 1, 0, 0 ) );
//				
//		waitframe();
//	}
//}

rappel_get_angle_facing_wall( rappel_type )
{
	if ( rappel_type == "combat" )
		return -33.7; // or .6
	else // "inverted" or "stealth"
		return 90.0;
}

rappel_get_plane_normal_left( rappel_type )
{
	if ( rappel_type == "combat" )
	{
		yaw_to_wall = rappel_get_angle_facing_wall( "combat" );
		yaw_out		= yaw_to_wall + 180;
		angles_out	= ( 0, yaw_out, 0 );
		vec			= VectorNormalize( AnglesToRight( angles_out ) );
		return vec;
	}
	else
	{
		return ( -1, 0, 0 ); // stealth is on the grid
	}
}

rappel_get_plane_normal_out( rappel_type )
{
	if ( rappel_type == "combat" )
	{
		yaw_to_wall = rappel_get_angle_facing_wall( "combat" );
		yaw_out		= yaw_to_wall + 180;
		angles_out	= ( 0, yaw_out, 0 );
		vec			= VectorNormalize( AnglesToForward( angles_out ) );
		return vec;
	}
	else
	{
		return ( 0, -1, 0 ); // stealth is on the grid
	}
}

rappel_get_plane_d( plane_normal, angle_origin )
{
	plane_d = -1 * VectorDot( plane_normal, angle_origin ); // d in plane equation
	return plane_d;
}

waittill_player_looking_at_rorke( timeout )
{
	rorke		= level.allies[ level.const_rorke ];
	success_dot = 0.7; // ~ Cos(45)
	waittill_player_looking_at_ent( rorke, timeout, success_dot );
}

waittill_player_looking_at_ent( ent, timeout, success_dot )
{
	Assert( IsDefined( ent ) );
	
	if ( !IsDefined( success_dot ) )
		success_dot = 0.9; // ~ Cos(25)
	
	end_time = GetTime() + ( timeout * 1000 );
	
	while ( GetTime() < end_time )
	{
		target_vector  = VectorNormalize( ent.origin - level.player.origin );
		player_angles  = get_rappel_player_angles();
		player_forward = AnglesToForward( player_angles );

		dot = VectorDot( player_forward, target_vector );
		if ( dot >= success_dot )
			return;
			
		waitframe();
	}	
}

get_rappel_player_angles()
{
	player_angles_relative = level.player GetPlayerAngles();
	
	if ( !IsDefined( level.plyr_rpl_groundref ) )
		return player_angles_relative;
	
	player_angles_worldspace = CombineAngles( level.plyr_rpl_groundref.angles, player_angles_relative );
	return player_angles_worldspace;
}

waittill_player_close_to( ent, radius )
{
	Assert( IsDefined( ent ) );
	
	radius_sq = radius * radius;
	
	while ( IsDefined( ent ) )
	{
		dist_sq = Distance2DSquared( level.player.origin, ent.origin );
		if ( dist_sq < radius_sq )
			break;
		
		waitframe();
	}
}

#using_animtree( "player" );
player_flap_sleeves_setup( is_arms )
{
	//SetDvarIfUninitialized( "sleeves_enabled", "0" );
	
	//if ( GetDvar( "sleeves_enabled" ) == "0" )
	//	return;
	
	if ( !IsDefined( is_arms ) )
		is_arms = false;
	
	self.sleeve_flap_l = Spawn( "script_model", self.origin );
	self.sleeve_flap_l.angles = self.angles;
	self.sleeve_flap_l SetModel( "cnd_sleeve_flap_LE" );
	self.sleeve_flap_l UseAnimTree(#animtree);
	if ( !is_arms )
	{
		self.sleeve_flap_l LinkToPlayerView( self, "J_WristTwist_LE", (0, 0, 0), (0, 0, 0), true );
		self.sleeve_flap_l.is_view_linked = true;
	}
	else
	{
		self.sleeve_flap_l LinkTo( self, "J_WristTwist_LE", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	}
	
	self.sleeve_flap_r = Spawn( "script_model", self.origin );
	self.sleeve_flap_r.angles = self.angles;
	self.sleeve_flap_r SetModel( "cnd_sleeve_flap_RI" );
	self.sleeve_flap_r UseAnimTree(#animtree);
	if ( !is_arms )
	{
		self.sleeve_flap_r LinkToPlayerView( self, "J_WristTwist_RI", (0, 0, 0), (0, 0, 0), true );
		self.sleeve_flap_r.is_view_linked = true;
	}
	else
	{
		self.sleeve_flap_r LinkTo( self, "J_WristTwist_RI", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	}
	
	if ( !is_arms )
		self thread player_hide_flaps_death();
	
	self _sleeves_idle();
}

player_hide_flaps_death()
{
	self waittill( "death" );
	
	self player_HideViewModelSleeveFlaps();
}

player_flap_sleeves()
{
	//if ( GetDvar( "sleeves_enabled" ) == "0" )
	//	return;
		
	if ( IsDefined( self.sleeves_flapping ) && self.sleeves_flapping )
		return;
	
	self.sleeves_flapping = true;
	self thread _sleeves_flap_internal();
}

player_stop_flap_sleeves()
{
	//if ( GetDvar( "sleeves_enabled" ) == "0" )
	//	return;
		
	self.sleeves_flapping = undefined;
	self notify( "stop_sleeves" );
}

_sleeves_idle( blend_time )
{
	if ( !IsDefined( blend_time ) )
		blend_time = 1.0;
	
	self.sleeve_flap_l SetAnimKnob( %player_sleeve_pose, 1.0, blend_time, 1.0 );
	self.sleeve_flap_r SetAnimKnob( %player_sleeve_pose, 1.0, blend_time, 1.0 );
}

_sleeves_flap_internal()
{
	min_wait = 0.2;
	max_wait = 5.0;
	min_random_rate = 0.8;
	max_random_rate = 1.2;
	min_wind_rate = 0.45;
	
	while ( IsDefined( self.sleeves_flapping ) )
	{
		rate = RandomFloatRange( min_random_rate, max_random_rate );
		blend_time = 0.2;
		has_wind = false;
		
		if ( IsDefined( level.rpl ) && IsDefined( level.rpl.wind_strength ) )
		{ 
			wind = level.rpl.wind_strength;
			rate = clamp( wind, min_wind_rate, wind );
			has_wind = true;
		}
		
		self.sleeve_flap_l SetAnimKnob( %player_sleeve_flapping, 1.0, blend_time, rate );
		self.sleeve_flap_r SetAnimKnob( %player_sleeve_flapping, 1.0, blend_time, rate );
		
		time = RandomFloatRange( min_wait, max_wait );
		if ( has_wind )
			time = 0.05;
			
		msg = self waittill_notify_or_timeout_return( "stop_sleeves", time );
		
		if ( !IsDefined( msg ) )
		{
			self thread _sleeves_idle();
			return;
		}
	}
}

hide_player_arms()
{
	level.cornered_player_arms Hide();
	hide_player_arms_sleeve_flaps();
}

show_player_arms()
{
	level.cornered_player_arms Show();
	show_player_arms_sleeve_flaps();
}

hide_player_arms_sleeve_flaps()
{
	if ( IsDefined( level.cornered_player_arms.sleeve_flap_l ) )
		level.cornered_player_arms.sleeve_flap_l Hide();
	if ( IsDefined( level.cornered_player_arms.sleeve_flap_r ) )
		level.cornered_player_arms.sleeve_flap_r Hide();
}

show_player_arms_sleeve_flaps()
{
	if ( IsDefined( level.cornered_player_arms.sleeve_flap_l ) )
		level.cornered_player_arms.sleeve_flap_l Show();
	if ( IsDefined( level.cornered_player_arms.sleeve_flap_r ) )
		level.cornered_player_arms.sleeve_flap_r Show();
}

player_HideViewModel()
{
	Assert( IsPlayer( self ) );
	self HideViewModel();
	self player_HideViewModelSleeveFlaps();
}

player_ShowViewModel()
{
	Assert( IsPlayer( self ) );
	self ShowViewModel();
	self player_ShowViewModelSleeveFlaps();
}

player_HideViewModelSleeveFlaps()
{
	if ( IsDefined( self.sleeve_flap_l ) && self.sleeve_flap_l.is_view_linked )
	{
		self.sleeve_flap_l.is_view_linked = false;
		self.sleeve_flap_l UnlinkFromPlayerView( self );
		self.sleeve_flap_l Hide();
	}
	if ( IsDefined( self.sleeve_flap_r ) && self.sleeve_flap_r.is_view_linked )
	{
		self.sleeve_flap_r.is_view_linked = false;
		self.sleeve_flap_r UnlinkFromPlayerView( self );
		self.sleeve_flap_r Hide();
	}
}

player_ShowViewModelSleeveFlaps()
{
	if ( IsDefined( self.sleeve_flap_l ) && !self.sleeve_flap_l.is_view_linked )
	{
		self.sleeve_flap_l.is_view_linked = true;
		self.sleeve_flap_l LinkToPlayerView( self, "J_WristTwist_LE", (0, 0, 0), (0, 0, 0), true );
		self.sleeve_flap_l Show();
	}
	if ( IsDefined( self.sleeve_flap_r ) && !self.sleeve_flap_r.is_view_linked )
	{
		self.sleeve_flap_r.is_view_linked = true;
		self.sleeve_flap_r LinkToPlayerView( self, "J_WristTwist_RI", (0, 0, 0), (0, 0, 0), true );
		self.sleeve_flap_r Show();
	}
}

/#
debug_star( origin, color )
{
	size = 8;
	Line( origin + ( size, 0, 0 ), origin - ( size, 0, 0 ), color, 1.0, 1, 1 );
	Line( origin + ( 0, size, 0 ), origin - ( 0, size, 0 ), color, 1.0, 1, 1 );
	Line( origin + ( 0, 0, size ), origin - ( 0, 0, size ), color, 1.0, 1, 1 );
}

debug_star_time( origin, color, frames )
{
	size = 8;
	Line( origin + ( size, 0, 0 ), origin - ( size, 0, 0 ), color, 1.0, 1, frames );
	Line( origin + ( 0, size, 0 ), origin - ( 0, size, 0 ), color, 1.0, 1, frames );
	Line( origin + ( 0, 0, size ), origin - ( 0, 0, size ), color, 1.0, 1, frames );
}

debug_axis( origin, angles )
{
	size = 8;

	forward = AnglesToForward( angles ) * size;
	right	= AnglesToRight( angles ) * size;
	up		= AnglesToUp( angles ) * size;
	Line( origin, origin + forward, ( 1, 0, 0 ), 1.0, 1, 1 );
	Line( origin, origin + up	  , ( 0, 1, 0 ), 1.0, 1, 1 );
	Line( origin, origin + right  , ( 0, 0, 1 ), 1.0, 1, 1 );
}

debug_axis_time( origin, angles, frames )
{
	size = 8;

	forward = AnglesToForward( angles ) * size;
	right	= AnglesToRight( angles ) * size;
	up		= AnglesToUp( angles ) * size;
	Line( origin, origin + forward, ( 1, 0, 0 ), 1.0, 1, frames );
	Line( origin, origin + up	  , ( 0, 1, 0 ), 1.0, 1, frames );
	Line( origin, origin + right  , ( 0, 0, 1 ), 1.0, 1, frames );
}

////////////////////////////
//Stealth Debug Code
////////////////////////////
enable_stealth_debugging()
{
	add_global_spawn_function( "axis", ::enemy_debug_stealth );
	level thread debug_stealth_system();
}

MAX_EVENTS_TO_RECORD = 20;
enemy_debug_stealth()
{
	enemy_info 					= SpawnStruct();
	enemy_info.num 				= self GetEntityNumber();
	enemy_info.last_origin 		= self.origin;
	enemy_info.enemy			= undefined;
	enemy_info.event_history	= [];
	
	self thread enemy_debug_stealth_death_timer(enemy_info);
	self thread enemy_record_event_awareness(enemy_info);
	self thread enemy_update_origin(enemy_info);
	self thread enemy_debug_stealth_got_enemy(enemy_info);
	self thread enemy_draw_debug(enemy_info);
}

enemy_record_event_awareness(enemy_info)
{
	self endon( "death" );
	self endon( "stealth_stop_recording" );
	while ( true )
	{
		self waittill("known_event", enemy, reason, time, position );
		enemy_info thread enemy_record_event(enemy, reason, time, position);
	}
}

enemy_ignored( enemy )
{
	if ( !IsSentient( enemy ) )
		return false;
	
	if ( GetDvarInt( "stealth_debug_include_ignoreme" ) )
		return false;
		
	if ( IsDefined( enemy.ignoreme ) && enemy.ignoreme )
		return true;
	
	return false;
}

enemy_record_event(enemy, reason, time, position)
{
	if ( enemy_ignored( enemy ) )
		return;
	
	enemy_num = -1;
	if ( IsDefined( enemy ) )
	{
		enemy_num = enemy GetEntityNumber();
	}
	
	// remove the oldest record if we are the max number of events
	if ( self.event_history.size >= MAX_EVENTS_TO_RECORD )
	{
		self.event_history = array_remove_index( self.event_history, 0 );
	}

	s 			= SpawnStruct();
	s.time 		= time;
	s.type		= get_event_string(reason);
	s.pos		= position;
	s.text		= "$" + self.num + " - " + s.time + ": " + s.type + " -> $" + enemy_num;
	s.enemy		= enemy;
		
	self.event_history[self.event_history.size] = s;
	
	if ( GetDvarInt( "stealth_debug" ) > 0 )
		PrintLn( "Stealth System: Actor ($" + self.num + ") at " + self.last_origin + " had event (" + s.type + ") with entity ($" + enemy_num + ") at " + s.pos + " in time: (" + time + ")" );
}

enemy_debug_stealth_got_enemy(enemy_info)
{
	enemy_info endon( "post_death_stealth_timer" );	
	
	self waittill( "enemy" );
	
	enemy_info.enemy = self.enemy;
		
	enemy_origin = (0,0,0);
	
	if ( IsDefined( self.enemy ) && IsDefined( self.enemy.origin ) )
	{
		enemy_origin = self.enemy.origin;
	}
	
	enemy_info thread enemy_record_event( self.enemy, "ENEMY", GetTime(), enemy_origin );
	
	self notify( "stealth_stop_recording" );  // there is no recovery from stealth so just stop recording
}

enemy_debug_stealth_death_timer(enemy_info)
{
	self waittill( "death" );
	wait GetDvarFloat( "stealth_debug_post_death_time" );
	enemy_info notify( "post_death_stealth_timer" );
}

enemy_update_origin(enemy_info)
{
	while ( true )
	{
		if ( IsDefined( self ) && IsAlive( self ) )
		{
			enemy_info.last_origin = self.origin;
		}
		else
		{
			return;
		}
		waitframe();
	}
}

enemy_draw_debug(enemy_info)
{
	enemy_info endon( "post_death_stealth_timer" );
	
	while ( true )
	{
		waitframe();
		
		dvar_value = getDvarInt( "stealth_debug" );
		if ( dvar_value == 0 )
		{
			continue;
		}
		
		num_to_show = GetDvarInt( "stealth_debug_num_events" );
		z = 10 * num_to_show;
		
		up = (0,0,z);
		eye = (0,0,50);
		blue = (0,0,1);
		red = (1,0,0);
		green = (0,1,0);
		has_enemy = false;
		
		origin = undefined;
		if ( IsDefined( self ) &&  IsAlive( self ) )
		{
			origin = self.origin;
		}
		else
		{
			origin = enemy_info.last_origin;
		}
					
		//Print event history
		k = 0;
		
		for ( j = int(max( 0, enemy_info.event_history.size - num_to_show )); j < enemy_info.event_history.size && k < num_to_show; j++ )
		{
			text = enemy_info.event_history[j].text;
			
			up = up + (0,0,-10);
			color = blue;
			if ( enemy_info.event_history[j].type == "ENEMY" )
			{
				color = red;
				has_enemy = true;
			}

			print3d( origin+up, text, color, 1, .75 );
			
			if ( dvar_value >= 2 )
			{
				start = origin+eye;
				end = enemy_info.event_history[j].pos;
				color = green;
				maxvisibledistance = 0;
				if ( !IsDefined(enemy_info.event_history[j].enemy) && end == (0,0,0) ) // probably not the correct position, show as red
				{
					color = red;
				}
				else
				{
					if ( IsDefined(enemy_info.event_history[j].enemy.maxvisibledist) )
					{
						maxvisibledistance = enemy_info.event_history[j].enemy.maxvisibledist;
					}
				}
				max_dist_text = "MaxVisibleDistance: " + maxvisibledistance;
					
				line( start, enemy_info.event_history[j].pos, color, 1, false, 1 );
				midpoint = (start[0]+end[0]/2, start[1]+end[1]/2, start[1]+end[1]/2);
				print3d( midpoint, max_dist_text, blue, 1, .75);
			}
			
			k++;
		}
			
		if ( dvar_value >= 3 && IsDefined( self ) && IsAlive( self ) )
		{
			self thread enemy_draw_fov_cone(enemy_info, 0.05);
		}
	}
}
	
//Draws fov code
enemy_draw_fov_cone(enemy_info, time)
{
	dot = self.fovcosine;
	if(isDefined(self.enemy))	//this does not exectly match what native code does
	{
		dot = self.fovcosinebusy;
	}
	
	fov_yaw = ACos(dot);
	eye_yaw = self gettagangles( "TAG_EYE" )[ 1 ];
	
	leftDir = AnglesToForward((0,eye_yaw+fov_yaw,0));
	rightDir = AnglesToForward((0,eye_yaw-fov_yaw,0));
	
	viewDist = level.player.maxvisibledist;
	start = self.origin;
	left_end = start + leftDir*viewDist;
	right_end = start + rightDir*viewDist;
	
	thread draw_line_for_time(start,left_end,1,0,0,time);
	thread draw_line_for_time(start,right_end,1,0,0,time);
	
	//FOV Arc
	arc_segs = 10;
	arcpoints = [];
	angleFrac = (fov_yaw*2.0)/arc_segs;
	for ( j = 1; j < arc_segs-1; j++ )
	{
		angle = eye_yaw-fov_yaw + ( angleFrac * j );
		dir = AnglesToForward((0,angle,0));
		arcpoints[ arcpoints.size ] = (dir*viewDist) + start;
	}
	arcpoints[ arcpoints.size ] = left_end;
	
	arc_seg_start = right_end;
	arc_seg_end = undefined;
	for(j=0;j<arcpoints.size;j++)
	{
		arc_seg_end = arcpoints[j];
		thread draw_line_for_time(arc_seg_start,arc_seg_end,1,0,0,time);
		arc_seg_start = arc_seg_end;
	}	
}

debug_stealth_system()
{
	// stealth_debug 0 - off
	// stealth_debug 1 - show events
	// stealth_debug 2 - also show lines to last position
	// stealth_debug 3 - also show fov cones
	SetDevDvarIfUninitialized( "stealth_debug", 0 );
	
	SetDevDvar( "stealth_debug_num_events", 5 );			// how many events above the head to show
	SetDevDvar( "stealth_debug_post_death_time", 30 );		// how long to show events after death
	SetDevDvar( "stealth_debug_include_ignoreme", 0 );		// hide/show events for ai/players in notarget/ignoreme
}

get_event_string(reason)
{
	if ( IsString(reason) )
	{
		return reason;
	}
	
	switch ( reason )
	{
			// associated with an ai_event_t 
		case 0:
			return "AI_KNOWN_EV_FOOTSTEP";
		case 1:
			return "AI_KNOWN_EV_FOOTSTEP_WALK";
		case 2:
			return "AI_KNOWN_EV_FOOTSTEP_SPRINT";
		case 3:
			return "AI_KNOWN_EV_NEW_ENEMY";
		case 4:
			return "AI_KNOWN_EV_PAIN";
		case 5:
			return "AI_KNOWN_EV_DEATH";
		case 6:
			return "AI_KNOWN_EV_EXPLOSION";
		case 7:
			return "AI_KNOWN_EV_GRENADE_PING";
		case 8:
			return "AI_KNOWN_EV_PROJECTILE_PING";
		case 9:
			return "AI_KNOWN_EV_GUNSHOT";
		case 10:
			return "AI_KNOWN_EV_GUNSHOT_TEAMMATE";
		case 11:
			return "AI_KNOWN_EV_SILENCED_SHOT";
		case 12:
			return "AI_KNOWN_EV_BULLET";
		case 13:
			return "AI_KNOWN_EV_PROJECTILE_IMPACT";
		
			// associated with spawning
		case 14:
			return "AI_KNOWN_PERFECT_ENEMY_INFO";		// set by spawner flag PERFECTENEMYINFO
		case 15:
			return "AI_KNOWN_SPAWN_SHARE_INFO";			// set at spawn when others around have enemy info to share
			
			// associated with script
		case 16:
			return "AI_KNOWN_FAVORITE_ENEMY";			// set by script field 'favoriteenemy'
		case 17:
			return "AI_KNOWN_HIGHLY_AWARE_RADIUS";		// set by script field 'highlyawareradius'
		case 18:
			return "AI_KNOWN_SET_ATTACKER";				// set by script function 'setattacker'
		case 19:
			return "AI_KNOWN_GET_ENEMY_INFO";			// set by script function 'getenemyinfo'
		
			// associated with native code
		case 20:
			return "AI_KNOWN_GRENADE_ESCAPE";
		case 21:
			return "AI_KNOWN_GRENADE_RETURN";
		case 22:
			return "AI_KNOWN_EXPOSED_TOUCH";
		case 23:
			return "AI_KNOWN_TURRET_TOUCH";
		case 24:
			return "AI_KNOWN_CAN_SEE";
		default:
			return "UNKNOWN:"+reason;
	}
}

#/