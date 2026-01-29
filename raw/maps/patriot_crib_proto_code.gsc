#include common_scripts\utility;
#include maps\_anim;
#include maps\_audio;
#include maps\_hud_util;
#include maps\_utility;

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Misc.
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

hud_hide()
{
	setsavedDvar( "g_friendlyNameDist", 0 );
	SetSavedDvar( "compass", "0" );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
}

hud_show()
{
	setsavedDvar( "g_friendlyNameDist", 15000 );
	SetSavedDvar( "compass", "1" );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Cinematic Logic (Stolen from india intro and modified)
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

prep_cinematic( cinematic_name )
{
	SetSavedDvar( "cg_cinematicFullScreen", "0" );	// don't draw while paused
	CinematicInGame( cinematic_name, 1 );	// start it paused
	level.current_cinematic = cinematic_name;
}

play_cinematic( cinematic_name, no_pause, flag_stop )
{
	
	if ( IsDefined( level.current_cinematic ) )
	{
		Assert( level.current_cinematic == cinematic_name );
		PauseCinematicInGame( 0 );
		SetSavedDvar( "cg_cinematicFullScreen", "1" );	// start drawing
		level.current_cinematic = undefined;
	}
	else
	{
		CinematicInGame( cinematic_name );
	}
	
	if ( !IsDefined( no_pause ) || !no_pause )
	{
		SetSavedDvar( "cg_cinematicCanPause", "1" );	// allow pausing during movie
	}
	
	wait 1.0;
	
	while ( IsCinematicPlaying() )
	{
		if ( IsDefined( flag_stop ) && flag_exist( flag_stop ) && flag( flag_stop ) )
		{
			break;
		}
		
		wait 0.05;
	}
	
	if ( IsCinematicPlaying() )
	{
		StopCinematicInGame();
	}
	
	if ( !IsDefined( no_pause ) || !no_pause )
	{
		SetSavedDvar( "cg_cinematicCanPause", "0" );	// back to the default
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		NPC Activity Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

npc_setup( remove_gun, targetname )
{
	if ( IsSentient( self ) )
	{
		self set_ignoreme( true );
		self set_ignoreall( true );
	}
	
	run_anim = "npc_jog_armed";
	self.npc_has_weapon = true;
	if ( IsDefined( remove_gun ) && remove_gun && self.type != "dog" )
	{
		self gun_remove();
		run_anim = "npc_jog_unarmed";
		self.npc_has_weapon = false;
	}
	
	AssertEx( IsDefined( targetname ), "targetname must be passed to npc_setup." );
	self.targetname = targetname;

	self thread npc_interact_player_weapon_hide();

	self disable_arrivals();
	self disable_exits();
	self disable_surprise();
	self disable_turnAnims();
	self magic_bullet_shield( true );
//	self PushPlayer( true );
	self set_generic_run_anim( run_anim );
	self setFlashbangImmunity( true );
	
	self.disableBulletWhizbyReaction = true;
	self.ignoreExplosionEvents		 = true;
	self.IgnoreRandomBulletDamage	 = true;
	self.animname					 = "generic";
	self.combatmode					 = "no_cover";
	self.disableBulletWhizbyReaction = true;
	self.disableDoorBehavior		 = true;
	self.goalradius					 = 32;
	self.grenadeawareness			 = 0;
	self.ignoresuppression			 = true;
	self.maxFaceEnemyDist			 = 0;
	self.no_pistol_switch			 = true;
	self.nododgemove				 = true;
	self.noGrenadeReturnThrow		 = true;
	self.noRunReload				 = true;
	self.useChokePoints				 = false;
	self.walkDist					 = 0;
	self.walkDistFacingMotion		 = 0;
}

TABLE_NPC_SPAWN_DATA					= "sp/patriot_crib_proto_spawn_data.csv";
TABLE_NPC_STATE_DATA					= "sp/patriot_crib_proto_state_data.csv";

npcs_precache()
{
	PreCacheString( &"PATRIOT_CRIB_PROTO_HINT_NPC_TALK" );
	
	PreCacheModel( "open_book_static" );
	PreCacheModel( "machinery_welder_handle" );
}

npcs_get_array( array_targetnames )
{
	npc_array = [];
	ai_array  = GetAIArray( "allies" );
	
	foreach ( name in array_targetnames )
	{
		ai = get_living_ai( name, "targetname" );
		if ( IsDefined( ai ) )
		{
			npc_array[ npc_array.size ] = ai;
		}
	}
	
	return npc_array;
}

npc_get( targetname )
{
	npcs = npcs_get_array( [ targetname ] );
	AssertEx( npcs.size == 1, "npc_get() did not find 1 npc." );
	return npcs[ 0 ];
}

npc_spawn( spawner_targetname, remove_gun, loc_object )
{
	spawner = GetEnt( spawner_targetname, "targetname" );
	spawner.count = 1;
	
	targetname = npc_create_name_from_spawner_name( spawner_targetname );
	
	ai = spawner spawn_ai( true );
	ai npc_setup( remove_gun, targetname );
	
	if ( IsDefined( loc_object ) )
	{
		if ( IsDefined( loc_object.animation ) )
		{
			ai thread npc_animate( loc_object );
		}
		else
		{
			ai ForceTeleport( loc_object.origin, loc_object.angles );
			ai SetGoalPos( ai.origin );
		}
	}
	
	return ai;
}

npcs_spawn( noteworthy, flag_enable_interact )
{
	array_spawn_function_noteworthy( noteworthy, ::on_spawn_npc_interact, flag_enable_interact );
	array_spawn_noteworthy( noteworthy, true );
}

npc_create_name_from_spawner_name( spawner_name )
{
	name_parts = StrTok( spawner_name, "_" );
	
	AssertEx( name_parts.size >= 2, "Spawner name should have be at least two parts using delim \"_\"" );
	
	return name_parts[ 0 ] + "_" + name_parts[ 1 ];
}

on_spawn_npc_interact( flag_enable_interact, skip_interact )
{
	self endon( "death" );
	
	if ( !IsDefined( self.spawner ) || !IsDefined( self.spawner.targetname ) )
		return;
	
	targetname = npc_create_name_from_spawner_name( self.spawner.targetname );
	
	npc_anim_ent = self.spawner;
	
	// If the animation node has to be in the air the
	// spawner can't be used as reference because it
	// drops to the floor. Instead use a linked ent
	if ( IsDefined( self.spawner.script_linkto ) )
	{
		linked_ent = self.spawner get_linked_structs()[ 0 ];
		if ( IsDefined( linked_ent ) )
		{
			npc_anim_ent = linked_ent;
		}
	}
	
	self npc_setup( true, targetname );
	self npc_animate( npc_anim_ent );
	
	if ( IsDefined( flag_enable_interact ) )
	{
		flag_wait( flag_enable_interact );
	}
	
	if ( IsDefined( skip_interact ) && skip_interact )
		return;
	
	self npc_interact();
}

npcs_spawn_no_interact( noteworthy )
{
	array_spawn_function_noteworthy( noteworthy, ::on_spawn_npc_interact, undefined, true );
	array_spawn_noteworthy( noteworthy, true );
}

// JC-ToDo: Should be read from a table (anims, lines, head tracking, next state, etc).
npc_interact()
{
	lines		= undefined;
	head_track	= false;
	
	AssertEx( IsDefined( self.targetname ), "npc_interact() called on ai without field targetname." );
	
	// Add dialog sequences according to targetname
	switch ( self.targetname )
	{
		case "npc_lt":
			head_track = true;
			lines =	[
						"safehouse_lt_hellofaday",
						"safehouse_lt_prettyquiet",
						"safehouse_lt_checkoutarmory",
						"safehouse_lt_finishchapter"
					];
			break;
		
		case "npc_carlos":
			lines =	[
						"safehouse_cls_comenearme",
						"safehouse_cls_sitherewaiting",
						"safehouse_cls_somespace",
						"safehouse_cls_stepback"
					];
			break;
		
		case "npc_grinch":
			head_track = true;
			lines =	[
						"safehouse_grn_triedtorun",
						"safehouse_grn_newtoys",
						"safehouse_grn_shuteye",
						"safehouse_grn_getsomerest"
					];
			break;
		
		case "npc_tommy":
			lines =	[
						"safehouse_tmy_onepiece",
						"safehouse_tmy_joyriding",
						"safehouse_tmy_ontherange",
						"safehouse_tmy_backtowork"
					];
			break;
		
		case "npc_fletch":
			head_track = true;
			lines =	[
						"safehouse_ptl_questionsright",
						"safehouse_ptl_newgear",
						"safehouse_ptl_badside"
					];
			break;
		
		default:
			break;
	}
	
	if ( IsDefined( lines ) )
	{
		self npc_interact_think( lines, head_track );
	}
}

npc_animate( npc_anim_ent )
{		
	npc_anim = ter_op( IsDefined( npc_anim_ent.animation ), npc_anim_ent.animation, undefined );
	
	// If no animation was found on the spawner or a linked ent early out
	if ( IsDefined( npc_anim ) )
	{
		// Add props, sound and fx according to animation
		switch ( npc_anim )
		{	
			case "civilian_reader_2":
				self Attach( "open_book_static", "tag_inhand" );
				break;
			case "cliffhanger_welder_wing":
				self Attach( "machinery_welder_handle", "tag_inhand" );
				self thread flashing_welding();
				self thread play_loop_sound_on_entity( "scn_trainer_welders_working_loop" );
				break;
			default:
				break;
		}
	}
	
	self thread npc_anim_reach_and_idle( npc_anim_ent, true );
}

npc_anim_reach_and_idle_name( ent_name, instant )
{
	ent = get_target_ent( ent_name );
	
	AssertEx( IsDefined( ent ), "npc_anim_reach_and_idle_name() given invalid ent name." );
	
	if ( !IsDefined( ent ) )
		return;
	
	self npc_anim_reach_and_idle( ent, instant );
}

npc_anim_reach_and_idle( ent, instant )
{
	self npc_animate_stop();
	
	animation = undefined;
	
	if ( IsDefined( ent.animation ) )
	{
		animation = ent.animation;
	}
	else
	{
		animation = "npc_idle_unarmed";
		
		if ( IsDefined( self.npc_has_weapon ) && self.npc_has_weapon )
		{
			animation = "npc_idle_armed";
		}
	}
	
	self.npc_anim_ent = ent;
		
	if ( IsDefined( instant ) && instant )
	{
		ent anim_generic_loop( self, animation );
	}
	else
	{
		ent anim_reach_and_idle_solo( self, animation, animation );
	}
}

npc_animate_stop()
{
	// Stop current animation
	self StopAnimScripted();
	
	if ( !IsDefined( self.npc_anim_ent ) )
		return;
	
	self.npc_anim_ent notify( "stop_loop" );
	
	if ( IsDefined( self.npc_anim_ent.animation ) )
	{
		// Clean up props, sound and fx according to animation
		switch ( self.npc_anim_ent.animation )
		{	
			case "civilian_reader_2":
				self Detach( "open_book_static", "tag_inhand" );
				break;
			case "cliffhanger_welder_wing":
				self Detach( "machinery_welder_handle", "tag_inhand" );
				self notify( "stop sound" + "scn_trainer_welders_working_loop" );
				break;
			default:
				break;
		}
	}
	
	self notify( "npc_animate_stop" );
	
	self.npc_anim_ent = undefined;
}

CONST_NPC_INTERACT_RADIUS					= 120;
CONST_NPC_INTERACT_HEIGHT					= 180;

npc_interact_think( dialogue_lines, head_track )
{
	self endon( "death" );
	self endon( "stop_npc_interact_think" );
	
	trigger_radius = Spawn( "trigger_radius", self.origin, 0, CONST_NPC_INTERACT_RADIUS, CONST_NPC_INTERACT_HEIGHT );
	trigger_radius EnableLinkTo();
	trigger_radius LinkTo( self, "tag_origin", (0, 0, -1 * CONST_NPC_INTERACT_HEIGHT * 0.5 ), (0,0,0) );
	
	self thread npc_interact_think_clean_up( trigger_radius );
	
	player = undefined;
	
	idx = 0;
	
	while ( 1 )
	{	
		// Wait until the player is close to the NPC
		player = self npc_interact_wait_player_close( trigger_radius );
	
		// Wait until the player looks at the NPC or leaves the trigger
		msg = self npc_interact_wait_player_look_or_leave( trigger_radius, player );
		
		if ( msg == "trigger_exit" )
		{
			self SetLookAtEntity();
			continue;
		}
		else if ( msg == "trigger_look" )
		{
			if ( IsDefined( head_track ) && head_track )
			{
				self SetLookAtEntity( player );
			}
			
			self dialogue_queue( dialogue_lines[ idx ] );
			
			wait( RandomFloatRange( 1.8, 2.25 ) );
			
			if ( !player IsTouching( trigger_radius ) )
			{
				self SetLookAtEntity();
			}
			
			idx++;
			if ( idx >= dialogue_lines.size )
			{
				break;
			}
		}
	}
	
	self notify( "npc_interact_finished" );
	self npc_interact_stop();
}

npc_interact_think_clean_up( trigger )
{
	self waittill_any( "death", "stop_npc_interact_think" );
	
	if ( IsDefined( self ) && IsAlive( self ) )
	{
		self SetLookAtEntity();
	}
	
	if ( IsDefined( trigger ) )
	{
		trigger Unlink();
		
		// Don't delete on the same frame as unlinking
		wait 0.05;
		trigger Delete();
	}
}

npc_interact_player_weapon_hide_disable()
{
	if ( self ent_flag_exist( "player_weapon_hide_disable" ) )
	{
		self ent_flag_set( "player_weapon_hide_disable" );
	}
}

CONST_NPC_PLAYER_WEAPON_RADIUS					= 120;
CONST_NPC_PLAYER_WEAPON_HEIGHT					= 180;

npc_interact_player_weapon_hide()
{
	// Disable previous instances of weapon hide
	self npc_interact_player_weapon_hide_disable();
	
	if ( !self ent_flag_exist( "player_weapon_hide_disable" ) )
	{
		self ent_flag_init( "player_weapon_hide_disable" );
	}
	else if ( self ent_flag( "player_weapon_hide_disable" ) )
	{
		self ent_flag_clear( "player_weapon_hide_disable" );
	}
	
	self endon( "death" );
	self endon( "player_weapon_hide_disable" );
	
	trigger = Spawn( "trigger_radius", self.origin, 0, CONST_NPC_PLAYER_WEAPON_RADIUS, CONST_NPC_PLAYER_WEAPON_HEIGHT );
	trigger EnableLinkTo();
	trigger LinkTo( self, "tag_origin", (0, 0, -1 * CONST_NPC_INTERACT_HEIGHT * 0.5 ), (0,0,0) );
	
	self thread npc_interact_player_weapon_clean_up( trigger );
	
	while ( 1 )
	{
		// Wait until the player is close to the NPC
		player = npc_interact_wait_player_close( trigger );
		
		self thread npc_interact_player_weapon_hide_on_look( player );
		
		while ( 1 )
		{
			if ( !player IsTouching( trigger ) )
			{
				self notify( "npc_interact_player_weapon_exit" );
				if ( IsDefined( self.player_weapon_disabled ) )
				{
					player _enableWeapon();
					self.player_weapon_disabled = undefined;
				}
				break;
			}
			
			wait 0.05;
		}
	}
}

npc_interact_player_weapon_clean_up( trigger )
{
	if ( self ent_flag( "player_weapon_hide_disable" ) )
		return;
	
	self waittill_either( "death", "player_weapon_hide_disable" );
	
	if ( IsDefined( self.player_weapon_disabled ) )
	{
		self.player_weapon_disabled _enableWeapon();
		self.player_weapon_disabled = undefined;
	}
	
	if ( IsDefined( trigger ) )
	{
		trigger Unlink();
		
		// Don't delete on the same frame as unlinking
		wait 0.05;
		trigger Delete();
	}
}

npc_interact_player_weapon_hide_on_look( player )
{
	if ( self ent_flag( "player_weapon_hide_disable" ) )
		return;
	
	self endon( "death" );
	self endon( "npc_interact_player_weapon_exit" );
	self endon( "player_weapon_hide_disable" );
	player endon( "death" );
	
	
	self.player_weapon_disabled = undefined;
	
	tag = "j_SpineUpper";
	if ( self.type == "dog" )
	{
		tag = "tag_origin";
	}
	
	while ( 1 )
	{
		// Disable weapon on look
		while ( 1 )
		{
			if ( player player_looking_at( self GetTagOrigin( tag ), undefined, undefined, self ) )
			{
				player _disableWeapon();
				self.player_weapon_disabled = player;
				break;
			}
			
			wait 0.05;
		}
		
		// Enable weapon on look away
		while ( 1 )
		{
			if ( !player player_looking_at( self GetTagOrigin( tag ), undefined, undefined, self ) )
			{
				player _enableWeapon();
				self.player_weapon_disabled = undefined;
				break;
			}
			
			wait 0.05;
		}
	}
}

npc_interact_wait_player_close( trigger )
{
	trigger endon( "death" );
	
	trigger waittill( "trigger", player );
	
	return player;
}

npc_interact_wait_player_look_or_leave( trigger, player )
{
	self endon( "death" );
	trigger endon( "death" );
	player endon( "death" );
	
	tag = "j_SpineUpper";
	if ( self.type == "dog" )
	{
		tag = "tag_origin";
	}
	
	msg = undefined;
	
	while ( 1 )
	{	
		if ( !player IsTouching( trigger ) )
		{
			msg = "trigger_exit";
			break;
		}
		
		if ( player player_looking_at( self GetTagOrigin( tag ), undefined, undefined, self ) )
		{
			msg = "trigger_look";
			break;
		}
		
		wait 0.05;
	}
	
	return msg;
}

npc_interact_stop()
{
	self notify( "stop_npc_interact_think" );
}

trigger_player_weapon_hide()
{	
	if ( !self ent_flag_exist( "player_weapon_hide_disable" ) )
	{
		self ent_flag_init( "player_weapon_hide_disable" );
	}
	else if ( self ent_flag( "player_weapon_hide_disable" ) )
	{
		self ent_flag_clear( "player_weapon_hide_disable" );
	}
	
	self endon( "death" );
	self endon( "player_weapon_hide_disable" );
	
	self thread trigger_player_weapon_hide_clean_up();
	
	while ( 1 )
	{
		self waittill( "trigger", activator );
		
		activator _disableWeapon();
		self.player_weapon_disabled = activator;
		
		while ( activator IsTouching( self ) )
		{
			wait 0.05;
		}
		
		activator _enableWeapon();
		self.player_weapon_disabled = undefined;
	}
}

trigger_player_weapon_hide_clean_up()
{
	self waittill_any( "death", "player_weapon_hide_disable" );
	
	if ( IsDefined( self.player_weapon_disabled ) )
	{
		self.player_weapon_disabled _enableWeapon();
		self.player_weapon_disabled = undefined;
	}
}

trigger_player_weapon_hide_disable()
{
	if ( self ent_flag_exist( "player_weapon_hide_disable" ) )
	{
		self ent_flag_set( "player_weapon_hide_disable" );
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Special Animation Prop Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

flashing_welding()
{
	self endon( "npc_animate_stop" );
	self endon( "death" );
	self thread stop_sparks();
	while( true )
	{
		self waittillmatch( "looping anim", "spark on" );
		self thread start_sparks();
	}
}

start_sparks()
{
	self endon( "npc_animate_stop" );
	self endon( "death" );
	self notify( "starting sparks" );
	self endon( "starting sparks" );
	self endon( "spark off" );
	while( true )
	{
		PlayFXOnTag( getfx( "welding_runner" ), self, "tag_tip_fx" );
		self PlaySound( "elec_spark_welding_bursts" );
		wait( randomfloatRange( .25, .5 ) );
	}
}

stop_sparks()
{
	self endon( "npc_animate_stop" );
	self endon( "death" );
	while( true )
	{
		self waittillmatch( "looping anim", "spark off" );
		self notify( "spark off" );
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Weapon Loadout Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

CONST_ARMORY_WEAPON_ATTACHMENT_FOV_TIME				= 0.15;		// Time to take when adjusting FOV for weapon load out transitions
CONST_FOV_DEFAULT									= 65;
armory_precache()
{
	PreCacheString( &"PATRIOT_CRIB_PROTO_HINT_CUSTOMIZE_WEAPON" );
	PreCacheString( &"PATRIOT_CRIB_PROTO_HINT_CUSTOMIZE_POSE" );
	PreCacheString( &"PATRIOT_CRIB_PROTO_HINT_CUSTOMIZE_ATTACHMENT" );
	
	PreCacheModel( "viewhands_delta" );
	PreCacheModel( "viewhands_player_delta" );
	
	// JC-ToDo: Should not have to precache rumbles for weapons
	PreCacheRumble( "silencer_fire" );
	
	// JC-ToDo: Should be loading all possible weapons from a string table.
	// For now just precache the two weapons being used for this prototype.
	PreCacheItem( "iw5_fnfiveseven_mp" );
	
	PreCacheItem( "iw5_mp5_mp" );
	PreCacheModel( "viewmodel_mp5_iw5" );
	PreCacheItem( "iw5_ump45_mp" );
	PreCacheModel( "viewmodel_ump45_iw5" );
	
	PreCacheItem( "iw5_acr_mp" );
	PreCacheModel( "viewmodel_remington_acr_iw5" );
	PreCacheItem( "iw5_ak47_mp" );
	PreCacheModel( "viewmodel_ak47_iw5" );
	
	// Attachments
	PreCacheModel( "viewmodel_reflex_iw5" );
	PreCacheModel( "viewmodel_eotech" );
	PreCacheModel( "viewmodel_acog" );
	PreCacheModel( "viewmodel_silencer_01" );
	PreCacheModel( "viewmodel_m320" );
	PreCacheModel( "viewmodel_gp25" );
	PreCacheModel( "projectile_m203grenade" );
	PreCacheModel( "viewmodel_shotgun" );
	
	PreCacheModel( "viewmodel_mag_dual_mp5" );
	PreCacheModel( "viewmodel_mag_reverse_mp5" );
	PreCacheModel( "viewmodel_mag_ext_mp5" );

	PreCacheModel( "viewmodel_reticle_reflex" );
	PreCacheModel( "viewmodel_reticle_eotech" );
	PreCacheModel( "viewmodel_reticle_acog" );
}

armory_init()
{
	level.armory_weapon_info = [];
	
	// JC-ToDo: This should be dynamic
	weapon_pose_attachment_info_create( "iw5_mp5_mp" );
	weapon_pose_attachment_info_create( "iw5_ump45_mp" );
	weapon_pose_attachment_info_create( "iw5_ak47_mp" );
//	weapon_pose_attachment_info_create( "iw5_acr_mp" );
	
	thread armory_weapons_manager();
}

armory_weapons_manager()
{
	thread armory_catch_weapon_collects();
	
	array_thread( level.players, ::armory_player_on_weapon_drop );
	
	// JC-ToDo: Should step through weapons on the ground and set their ammo
	array_thread( level.players, ::armory_player_on_weapon_change );
	array_thread( level.players, ::armory_weapon_customize_manager );

	// Script is now leaning on the weapon "pickup" and the current weapon to decide
	// what to customize. The below logic could be rolled into specialty items like equipment.
	
//	while ( 1 )
//	{
//		// JC-ToDo: For now individual weapons can be picked up. Probably should be a GUI.
//		array_thread( weapon_loc_ents, ::on_use_weapon );
//		
//		level waittill( "armory_weapon_selected", player, weapon_loc_ent );
//		
//		AssertEx( IsDefined( player ) && IsPlayer( player ), "Invalid player passed on \"armory_weapon_selected\" notify." );
//		
//		player weapon_player_collect( weapon_loc_ent );
//		
//		// Wait until frame end so that disable use on weapons can run. This won't be an
//		// issue when weapon collection goes right into weaponfdlskfjsd
//		waittillframeend;
//	}
}

armory_player_on_weapon_drop()
{
	player = self;
	
	player endon( "death" );
	
	while ( 1 )
	{
		player waittill( "pickup", weapon_ent_collected, weapon_ent_dropped );
		
		// Let the armory_weapon_on_collect() function waiting on weapon notify( "trigger" ) 
		// get ahead of this thread in case the origin and angles of the recently collected
		// weapon are needed.
		waittillframeend;
		
		// Figure out if the weapon swapped out was correct or if it should stay in the 
		// player's inventory and another weapon should be dropped.
		
		if ( IsDefined( level.weapons_collected_last[ player.unique_id ] ) )
		{
			weapon_collected		= level.weapons_collected_last[ player.unique_id ][ "weapon" ];
			weapon_collected_slot	= armory_weapon_slot_type( weapon_collected );
			weapon_dropped_slot		= undefined;
			if ( IsDefined( weapon_ent_dropped ) )
			{
				weapon_dropped_slot = armory_weapon_slot_type( GetSubStr( weapon_ent_dropped.classname, 7 ) );
			}
			
			// If the weapon dropped and the weapon collected are of the same slot type nothing
			// needs to be done, else give the dropped weapon back to the player and take away
			// the weapon of the correct slot type
			if ( IsDefined( weapon_ent_dropped ) && IsDefined( weapon_dropped_slot ) && weapon_collected_slot == weapon_dropped_slot )
			{
				// The correct swap happened so no action is needed
			}
			else
			{
				// If a new weapon was spawned give it back to the player because it was the 
				// wrong weapon to swap out
				if ( IsDefined( weapon_ent_dropped ) )
				{
					// JC-ToDo: Need to find out dropped weapon ammo and give that amount back
					player GiveWeapon( GetSubStr( weapon_ent_dropped.classname, 7 ) );
					weapon_ent_dropped Delete();
				}
				
				weapon_to_remove	= undefined;
				weapon_list			= player GetWeaponsList( "primary" );
				
				foreach ( weapon_held in weapon_list )
				{
					if ( WeaponInventoryType( weapon_held ) == "altmode" )
					{
						weapon_held = GetSubStr( weapon_held, 4 );
					}
					
					if ( weapon_held == weapon_collected )
						continue;
					
					if ( armory_weapon_slot_type( weapon_held ) == weapon_collected_slot )
					{
						weapon_to_remove = weapon_held;
						break;
					}
				}
				
				if ( IsDefined( weapon_to_remove ) )
				{
					player TakeWeapon( weapon_to_remove );
					weapon_ent_dropped			= Spawn( "weapon_" + weapon_to_remove, level.weapons_collected_last[ player.unique_id ][ "origin" ] );
					weapon_ent_dropped.angles	= level.weapons_collected_last[ player.unique_id ][ "angles" ];
				}
			}
		}
		
		if ( IsDefined( weapon_ent_dropped ) )
		{
			weapon_ent_dropped armory_weapon_ent_setup();
		}
		
		// Clear the weapon collected data
		level.weapons_collected_last[ player.unique_id ] = undefined;
	}
}

armory_weapon_ent_setup()
{
	self thread armory_weapon_suspend();
	self thread armory_weapon_on_collect();
}

armory_catch_weapon_collects()
{
	level.weapons_collected_last = [];
	
	all_ents = GetEntArray();
	foreach ( ent in all_ents )
	{
		if ( IsDefined( ent ) && IsDefined( ent.classname ) && string_starts_with( ent.classname, "weapon_" ) )
		{
			ent thread armory_weapon_on_collect();
		}
	}
}

armory_weapon_on_collect()
{
	weapon_ref = self;
	
	weapon = GetSubStr( weapon_ref.classname, 7 );
	origin = weapon_ref.origin;
	angles = weapon_ref.angles;
	
	
	weapon_ref waittill( "trigger", activator );
	
	AssertEx( IsDefined( activator ) && IsPlayer( activator ) );
	
	// Store the origin and angles of the last collected weapon under
	// the key value of the player's unique id.
	level.weapons_collected_last[ activator.unique_id ] = [];
	level.weapons_collected_last[ activator.unique_id ][ "weapon" ] = weapon;
	level.weapons_collected_last[ activator.unique_id ][ "origin" ] = origin;
	level.weapons_collected_last[ activator.unique_id ][ "angles" ] = angles;
	
	activator notify( "armory_weapon_collected", weapon );
}

armory_weapon_suspend()
{
	weapon_ref = self;
	
	ent_link = Spawn( "script_origin", weapon_ref.origin );
	ent_link.angles = weapon_ref.angles;
	
	weapon_ref LinkTo( ent_link );
	
	weapon_ref waittill( "trigger" );
	
	if ( IsDefined( weapon_ref ) )
	{
		weapon_ref Unlink();
	}
	
	wait 0.05; // Do not delete right after unlink call, code does not like
	if ( IsDefined( ent_link ) )
	{
		ent_link Delete();
	}
}

armory_player_on_weapon_change()
{
	self endon( "death" );
	
	while ( 1 )
	{
		self waittill( "weapon_change", weapon );
		
		if ( WeaponClass( weapon ) == "none" ||  WeaponInventoryType( weapon ) == "altmode" )
			continue;
		
		self SetWeaponAmmoClip( weapon, WeaponClipSize( weapon ) );
		self SetWeaponAmmoStock( weapon, WeaponMaxAmmo( weapon ) );
	
		alt_weapon = WeaponAltWeaponName( weapon );
		if ( alt_weapon != "none" )
		{
			self SetWeaponAmmoClip( alt_weapon, WeaponClipSize( alt_weapon ) );
			self SetWeaponAmmoStock( alt_weapon, WeaponMaxAmmo( alt_weapon ) );
		}
	}
}

armory_weapon_customize_manager()
{
	level endon( "armory_weapon_customize_disable" );
	
	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player in armory_weapon_customize_manager() function." );
	
	player = self;
	
	hud_elem_custom = self createClientFontString( "hudsmall", 1.0 );
	hud_elem_custom.hidewheninmenu = true;
	hud_elem_custom setPoint( "LEFT", "BOTTOM LEFT", 10, -25 );
	
	player thread armory_weapon_customize_on_disable( hud_elem_custom );
	
	if ( weapon_is_customizable( player GetCurrentWeapon() ) )
	{
		hud_elem_custom SetText( &"PATRIOT_CRIB_PROTO_HINT_CUSTOMIZE_WEAPON" );
	}
	else
	{
		hud_elem_custom SetText( "" );
	}
	
	player NotifyOnPlayerCommand( "BUTTON_CUSTOMIZE_WEAPON", "+actionslot 1" );
	
	while ( 1 )
	{
		hud_elem_custom.alpha = 1.0;
		
		msg = player waittill_any_return( "BUTTON_CUSTOMIZE_WEAPON", "weapon_change", "death" );
		
		weapon_name = player GetCurrentWeapon();
		weapon_customizable = weapon_is_customizable( weapon_name );
		
		if ( msg == "BUTTON_CUSTOMIZE_WEAPON" && player isWeaponEnabled() )
		{
			if ( weapon_customizable )
			{
				hud_elem_custom SetText( "" );
				player weapon_player_customize( weapon_name );
			}
		}
		else if ( msg == "weapon_change" )
		{
			if ( weapon_customizable )
			{
				hud_elem_custom SetText( &"PATRIOT_CRIB_PROTO_HINT_CUSTOMIZE_WEAPON" );
			}
			else
			{
				hud_elem_custom SetText( "" );
			}
		}
		else if ( msg == "death" )
		{
			break;
		}
	}
	
	hud_elem_custom destroyElem();
}

armory_weapon_customize_disable()
{
	level notify( "armory_weapon_customize_disable" );
}

armory_weapon_customize_on_disable( hud_elem )
{
	level waittill( "armory_weapon_customize_disable" );
	
	if ( IsDefined( hud_elem ) )
	{
		hud_elem destroyElem();
	}
}

//weapon_placed_setup()
//{
//	AssertEx( IsDefined( self ) && IsDefined( self.script_noteworthy ), "Weapon place entity doesn't have script_noteworthy which should be the initial weapon name." );
//	
//	if ( IsDefined( self.script_noteworthy ) )
//	{
//		weapon_placed_create( self, self.script_noteworthy );
//	}
//}
//
//weapon_placed_create( weapon_loc_ent, weapon_name )
//{
//	weapon_pose_attachment_info_create( weapon_name );
//	
//	flags = 1; // Make the weapon suspended
//	
//	weapon_ent = Spawn( "weapon_" + weapon_name, weapon_loc_ent.origin, flags );
//	weapon_ent.angles = weapon_loc_ent.angles;
//	
//	weapon_ent ItemWeaponSetAmmo( WeaponClipSize( weapon_name ), WeaponMaxAmmo( weapon_name ) );
//
//	alt_weapon = WeaponAltWeaponName( weapon_name );
//	if( alt_weapon != "none" )
//	{
//		alt_clip		= Int( max( 1, WeaponClipSize( alt_weapon ) ) );
//		alt_stock		= Int( max( 1, WeaponMaxAmmo( alt_weapon ) ) );
//		weapon_ent		ItemWeaponSetAmmo( alt_clip, alt_stock, alt_clip, 1 );
//	}
//	
//	//weapon_ent LinkTo( weapon_loc_ent );
//	//weapon_ent MakeUnusable();
//	
//	//weapon_loc_ent.weapon_name	= weapon_name;
//	//weapon_loc_ent.weapon_ent	= weapon_ent;
//}

//weapon_hint_string( weapon_name )
//{
//	name_simple = weapon_name_simple( weapon_name );
//	
//	hint = undefined;
//	
//	if ( name_simple == "mp5" )
//	{
//		hint = &"PATRIOT_CRIB_PROTO_CUSTOMIZE_MP5_HINT";
//	}
//	else if ( name_simple == "ak47" )
//	{
//		hint = &"PATRIOT_CRIB_PROTO_CUSTOMIZE_ACR_HINT";
//	}
//	else
//	{
//		AssertMsg( "Invalid script_noteworthy weapon type on weapon entity." );
//		hint = "";
//	}
//	
//	return hint;
//}
//
//on_use_weapon()
//{
//	level endon( "armory_weapon_selected" );
//	
//	weapon_loc_ent = self;
//	
//	if ( !IsDefined( weapon_loc_ent.weapon_name ) )
//		return;
//	
//	weapon_loc_ent thread weapon_use_off();
//	weapon_loc_ent MakeUsable();
//	weapon_loc_ent SetHintString( weapon_hint_string( weapon_loc_ent.weapon_name ) );
//	
//	while ( 1 )
//	{
//		weapon_loc_ent waittill( "trigger", activator );
//		
//		if ( IsDefined( activator ) && IsPlayer( activator ) )
//		{
//			level notify( "armory_weapon_selected", activator, weapon_loc_ent );
//			break;
//		}
//	}
//}
//
//weapon_use_off()
//{
//	level waittill( "armory_weapon_selected" );
//	
//	self MakeUnusable();
//}
//
//weapon_player_collect( weapon_loc_ent )
//{
//	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player when trying to swap out a weapon." );
//	AssertEx( IsDefined( weapon_loc_ent ), "weapon_loc_ent not valid entity to swap new weapon." );
//	
//	player = self;
//	
//	weapon_old = undefined;
//	// Store the current weapon name and remove it
//	if ( IsDefined( player.weapon_name ) )
//	{
//		weapon_old = player.weapon_name;
//		player TakeWeapon( weapon_old );
//	}
//	
//	player.weapon_name = weapon_loc_ent.weapon_name;
//	
//	player weapon_player_pick_up( weapon_loc_ent );
//	
//	if ( IsDefined( weapon_old ) )
//	{	
//		weapon_placed_create( weapon_loc_ent, weapon_old );
//	}
//	
//	// JC-ToDo: This should be always possible, not just on weapon collect
//	weapon_player_customize( player.weapon_name );
//}

customize_hud_init()
{
	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player in customize_hud_init()" );
	
	// Create weapon customization hud
	self.hud_elem_pose = self createClientFontString( "hudbig", 1.0 );
	self.hud_elem_pose.hidewheninmenu = true;
	self.hud_elem_pose.color = ( 1.0, 1.0, 0.0 );
	self.hud_elem_pose.glowalpha = 0.25;
	self.hud_elem_pose.glowcolor = ( 0.2, 0.2, 0.2 );
	self.hud_elem_pose setPoint( "LEFT", "TOP LEFT", 0, 50 );
	
	self.hud_elem_pose_count = self createClientFontString( "hudbig", 0.75 );
	self.hud_elem_pose_count.hidewheninmenu = true;
	self.hud_elem_pose_count setPoint( "LEFT", "TOP LEFT", 100, 50 );
	
	self.hud_elem_attach = self createClientFontString( "hudsmall", 1.0 );
	self.hud_elem_attach.hidewheninmenu = true;
	self.hud_elem_attach.glowalpha = 0.25;
	self.hud_elem_attach.glowcolor = ( 0.2, 0.2, 0.2 );
	self.hud_elem_attach setPoint( "LEFT", "TOP LEFT", 10, 75 );
	
	self.hud_elem_attach_info = self createClientFontString( "hudsmall", 1.0 );
	self.hud_elem_attach_info.hidewheninmenu = true;
	self.hud_elem_attach_info setPoint( "LEFT", "TOP LEFT", 10, 90 );
	
	self.hud_elem_pose_instruct = self createClientFontString( "hudsmall", 1.0 );
	self.hud_elem_pose_instruct.hidewheninmenu = true;
	self.hud_elem_pose_instruct setPoint( "LEFT", "BOTTOM LEFT", 10, 0 );
	self.hud_elem_pose_instruct SetText( &"PATRIOT_CRIB_PROTO_HINT_CUSTOMIZE_POSE" );
	
	
	self.hud_elem_attach_instruct = self createClientFontString( "hudsmall", 1.0 );
	self.hud_elem_attach_instruct.hidewheninmenu = true;
	self.hud_elem_attach_instruct setPoint( "LEFT", "BOTTOM LEFT", 10, -25 );
	self.hud_elem_attach_instruct SetText( &"PATRIOT_CRIB_PROTO_HINT_CUSTOMIZE_ATTACHMENT" );
}

customize_hud_update( pose, attachment, attach_index, attach_count )
{
	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player in customize_hud_udpate()" );
	
	self.hud_elem_pose SetText( pose );
	
	if ( IsDefined( attach_index ) && IsDefined( attach_count ) )
	{
		self.hud_elem_pose_count SetText( attach_index + "/" + attach_count );
	}
	else
	{
		self.hud_elem_pose_count SetText( "" );
	}
	
	if ( !IsDefined( attachment ) || attachment == "" )
	{
		self.hud_elem_attach SetText( "" );
		self.hud_elem_attach_info SetText( "" );
	}
	else
	{
		attach_name = attachment_name_text( attachment );
		attach_info = attachment_info_text( attachment );
	
		self.hud_elem_attach SetText( attach_name );
		self.hud_elem_attach_info SetText( attach_info );
	}
}

customize_hud_destroy()
{
	if ( IsDefined( self ) )
	{
		if ( IsDefined( self.hud_elem_pose ) )
		{
			self.hud_elem_pose destroyElem();
		}
		
		if ( IsDefined( self.hud_elem_pose_count ) )
		{
			self.hud_elem_pose_count destroyElem();
		}
		
		if ( IsDefined( self.hud_elem_attach_info ) )
		{
			self.hud_elem_attach_info destroyElem();
		}
		
		if ( IsDefined( self.hud_elem_attach ) )
		{
			self.hud_elem_attach destroyElem();
		}
		
		if ( IsDefined( self.hud_elem_pose_instruct ) )
		{
			self.hud_elem_pose_instruct destroyElem();
		}
		
		if ( IsDefined( self.hud_elem_attach_instruct ) )
		{
			self.hud_elem_attach_instruct destroyElem();
		}
	}
}

// JC-ToDo: Should use actual string table with weapon attachment names
attachment_name_text( attachment )
{
	name = undefined;
	
	switch ( attachment )
	{
		case "none":
			name = "None";
			break;
		
		case "clip_reg":
			name = "Standard";
			break;
		
		case "clip_xmags":
			name = "Extended Mags";
			break;
		
		case "clip_reload":
			name = "Fast Reload";
			break;
		
		case "silencer":
			name = "Silencer";
			break;
		
		case "iron_sight":
			name = "Iron Sight";
			break;
		
		case "red_dot":
			name = "Red Dot";
			break;
		
		case "acog":
			name = "ACOG";
			break;
		
		case "gl":
			name = "Launcher";
			break;
		
		case "shotgun":
			name = "Shotgun";
			break;
		
		default:
			AssertMsg( "Unhandled weapon attachment name: \"" + attachment + "\"" );
			break;
	}
	
	return name;
}

// JC-ToDo: Should use actual string table with weapon attachment descriptions
attachment_info_text( attachment )
{
	info = undefined;
	
	switch ( attachment )
	{
		case "none":
			info = "No attachment";
			break;
		
		case "clip_reg":
			info = "Standard issue magazine";
			break;
		
		case "clip_xmags":
			info = "Larger magazine";
			break;
		
		case "clip_reload":
			info = "Two magazines strapped";
			break;
		
		case "silencer":
			info = "Firing sounds suppressed";
			break;
		
		case "iron_sight":
			info = "Basic weapon sight";
			break;
		
		case "red_dot":
			info = "Mid range weapon sight";
			break;
		
		case "acog":
			info = "Mid to longe range scope";
			break;
		
		case "gl":
			info = "Underbarrel grenade launcher";
			break;
		
		case "shotgun":
			info = "Underbarrel shotgun";
			break;
		
		default:
			AssertMsg( "Unhandled weapon attachment name: \"" + attachment + "\"" );
			break;
	}
	
	return info;
}

weapon_player_customize( weapon_name )
{
	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player in weapon_player_customize()." );
	AssertEx( IsDefined( weapon_name ), "weapon_name not defined in weapon_player_customize()." );	
	
	player = self;
	
	// Stop gun from getting clipped by near clip plane
	SetSavedDvar( "sv_znear", "1" );
	
	hud_hide();
	
	
	player customize_hud_init();
	
	if ( WeaponInventoryType( weapon_name ) == "altmode" )
	{
		weapon_name = GetSubStr( weapon_name, 4 );
	}
	
	if ( player HasWeapon( weapon_name ) )
	{
		player TakeWeapon( weapon_name );
	}
	
	player enable_weapons_and_stance( false );
	
	player_rig = spawn_anim_model( "player_rig" );
	player_rig.origin = player.origin;
	player_rig.angles = player.angles;
	
	player PlayerLinkToBlend( player_rig, "tag_player", 0.2 );
	
	weapon_attachments_curr = player weapon_viewmodel_attach_populate( player_rig, weapon_name );
	weapon_pose_curr = "clip";
	weapon_name_simple = weapon_name_simple( weapon_name );
	
	anim_pullout = weapon_anim_pull_out( weapon_name );

	fake_tag = spawn_tag_origin();
	fake_tag.origin = player.origin;
	fake_tag.angles = player.angles;
	
	// Update HUD before pullout animation
	player customize_hud_update( weapon_pose_curr );
	
	fake_tag anim_single_solo( player_rig, anim_pullout, "tag_origin" );
	
	// Player input management
	player NotifyOnPlayerCommand( "BUTTON_ATTACH_NEXT", "+actionslot 1" );
	player NotifyOnPlayerCommand( "BUTTON_ATTACH_PREV", "+actionslot 2" );
	player NotifyOnPlayerCommand( "BUTTON_POSE_NEXT", "+actionslot 3" );
	player NotifyOnPlayerCommand( "BUTTON_POSE_PREV", "+actionslot 4" );
	player NotifyOnPlayerCommand( "BUTTON_EXIT", "+attack" );
	if ( level.console )
		player NotifyOnPlayerCommand( "BUTTON_EXIT", "+stance" );		// Consoles
	else
		player NotifyOnPlayerCommand( "BUTTON_EXIT", "skip" ); 			// PC
	
	anim_idle = weapon_anim_pose_idle( weapon_name, weapon_pose_curr, weapon_attachments_curr[ weapon_pose_curr ] );
	anim_idle_prev = "";
	
	weapon_pose_change = undefined;
	
	while ( 1 )
	{
		if ( IsDefined( weapon_pose_change ) )
		{
			player customize_hud_update( weapon_pose_change );
			
			// If the attachment FOV is different than the default, update it after the pose
			// change anim otherwise update it before.
			fov_new = weapon_attachment_fov( weapon_name, weapon_pose_change, weapon_attachments_curr[ weapon_pose_change ] );
			if ( fov_new == CONST_FOV_DEFAULT )
			{
				player LerpFOV( fov_new, CONST_ARMORY_WEAPON_ATTACHMENT_FOV_TIME );
			}
			
			anim_trans = weapon_anim_pose_trans( weapon_name, weapon_pose_curr, weapon_pose_change );
			fake_tag anim_single_solo( player_rig, anim_trans );
			
			if ( fov_new != CONST_FOV_DEFAULT )
			{
				player LerpFOV( fov_new, CONST_ARMORY_WEAPON_ATTACHMENT_FOV_TIME );
			}
			
			anim_idle = weapon_anim_pose_idle( weapon_name, weapon_pose_change, weapon_attachments_curr[ weapon_pose_change ] );
			
			weapon_pose_curr = weapon_pose_change;
			weapon_pose_change = undefined;
		}
		
		array_attachments = weapon_pose_attachment_order( weapon_name, weapon_pose_curr );
		index = array_find( array_attachments, weapon_attachments_curr[ weapon_pose_curr ] );
		
		player customize_hud_update( weapon_pose_curr, weapon_attachments_curr[ weapon_pose_curr ], 1 + Int( index ), array_attachments.size );
		
		if ( anim_idle != anim_idle_prev )
		{
			fake_tag notify( "stop_loop" );
			fake_tag thread anim_loop_solo( player_rig, anim_idle );
			anim_idle_prev = anim_idle;
		}
			
		msg = player waittill_any_return( "BUTTON_ATTACH_NEXT", "BUTTON_ATTACH_PREV", "BUTTON_POSE_NEXT", "BUTTON_POSE_PREV", "BUTTON_EXIT" );	
		
		if ( msg == "BUTTON_POSE_NEXT" || msg == "BUTTON_POSE_PREV" )
		{
			if ( msg == "BUTTON_POSE_NEXT" )
			{
				weapon_pose_change = weapon_pose_next( weapon_name, weapon_pose_curr );
			}
			else
			{
				weapon_pose_change = weapon_pose_prev( weapon_name, weapon_pose_curr );
			}
		}
		else if ( msg == "BUTTON_ATTACH_NEXT" ||  msg == "BUTTON_ATTACH_PREV" )
		{
			weapon_attach_change = undefined;
			
			if ( msg == "BUTTON_ATTACH_NEXT" )
			{
				weapon_attach_change = weapon_pose_attachment_next( weapon_name, weapon_pose_curr, weapon_attachments_curr[ weapon_pose_curr ] );
			}
			else
			{
				weapon_attach_change = weapon_pose_attachment_prev( weapon_name, weapon_pose_curr, weapon_attachments_curr[ weapon_pose_curr ] );
			}
			
			if ( IsDefined( weapon_attach_change ) )
			{
				player weapon_attachment_hide( player_rig, weapon_name, weapon_pose_curr, weapon_attachments_curr[ weapon_pose_curr ] );
				player weapon_attachment_show( player_rig, weapon_name, weapon_pose_curr, weapon_attach_change, true );
				
				if ( weapon_attach_change != weapon_attachments_curr[ weapon_pose_curr ] )
				{
					player PlaySound( "weap_mp5k_clipin_plr", "new_attachment_sound", true );
				}
				
				weapon_attachments_curr[ weapon_pose_curr ] = weapon_attach_change;
				
				anim_idle = weapon_anim_pose_idle( weapon_name, weapon_pose_curr, weapon_attachments_curr[ weapon_pose_curr ] );
			}
		}
		else if ( msg == "BUTTON_EXIT" )
		{
			player LerpFOV( CONST_FOV_DEFAULT, CONST_ARMORY_WEAPON_ATTACHMENT_FOV_TIME );
			
			anim_exit = weapon_anim_put_away( weapon_name, weapon_pose_curr );
			fake_tag anim_single_solo( player_rig, anim_exit );
			break;
		}
		else
		{
			AssertMsg( "Invalid weapon customize notification: \"" + msg + "\"" );
		}
	}
	
	player Unlink();
	
	fake_tag Delete();
	player_rig Delete();
	
	player enable_weapons_and_stance( true );
	
	weapon_name_new = weapon_name_from_pose_attachment_array( weapon_name, weapon_attachments_curr );
	
	player GiveWeapon( weapon_name_new );
	player SwitchToWeaponImmediate( weapon_name_new );
	
	// Set near clip plane back to default (0 seems to do this).
	SetSavedDvar( "sv_znear", "0" );

	player customize_hud_destroy();
	
	hud_show();
	
}

enable_weapons_and_stance( bool )
{
	if ( bool )
	{
		self AllowCrouch( true );
		self AllowProne( true );
		self _enableWeapon();
	}
	else
	{
		self SetStance( "stand" );
		self AllowCrouch( false );
		self AllowProne( false );
		self _disableWeapon();
	}
}

// JC-ToDo: This should be a code function that takes a full weapon name
weapon_viewmodel( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	viewmodel = "";
	switch ( name_simple )
	{
		case "mp5":
			viewmodel = "viewmodel_mp5_iw5";
			break;

		case "ump45":
			viewmodel = "viewmodel_ump45_iw5";
			break;
			
		case "acr":
			viewmodel = "viewmodel_remington_acr_iw5";
			break;
			
		case "ak47":
			viewmodel = "viewmodel_ak47_iw5";
			break;
		
		default:
			AssertMsg( "weapon_viewmodel() script function doesn't have a viewmodel entry for the simple weapon name: \"" + name_simple + "\"" );
			break;
	}
	
	return viewmodel;
}

weapon_viewmodel_attach_populate( player_rig, weapon_name )
{
	name_simple	= weapon_name_simple( weapon_name );
	viewmodel	= weapon_viewmodel( weapon_name );
	
	player_rig Attach( viewmodel, "tag_weapon", true );
	
	// Step through all possible attachments and hide gun parts
	// An example is iron sights need to be hidden in case the first
	// scope attachment is a red dot, acog, ect...
	weapon_poses = weapon_pose_order( weapon_name );
	foreach ( pose in weapon_poses )
	{
		weapon_attachments = weapon_pose_attachment_order( weapon_name, pose );
		foreach ( attachment_name in weapon_attachments )
		{
			attachment_data_array = weapon_pose_attachment_data_array( weapon_name, pose, attachment_name );

			if ( IsDefined( attachment_data_array[ "part_tag" ] ) )
			{
				player_rig HidePart( attachment_data_array[ "part_tag" ] );
			}
		}
	}
	
	// Next boil down weapon into attachment infos for prototype viewmodel shit
	attachments_curr = weapon_pose_attachments_array_from_name( weapon_name );
	
	// Now show all attachments
	foreach ( pose, attachment in attachments_curr )
	{
		self weapon_attachment_show( player_rig, weapon_name, pose, attachment );
	}
	
	return attachments_curr;
}

weapon_pose_attachments_array_from_name( weapon_name )
{
	weapon_poses = weapon_pose_order( weapon_name );
	attachments_curr = [];
	foreach ( pose in weapon_poses )
	{
		attachments_curr[ pose ] = weapon_pose_attachment_from_name( weapon_name, pose );
	}
	
	return attachments_curr;
}

weapon_pose_attachment_from_name( weapon_name, pose )
{
	attachment_name = undefined;
	
	if ( pose == "clip" )
	{
		if ( IsSubStr( weapon_name, "_xmags") )
			attachment_name = "clip_xmags";
		else
			attachment_name = "clip_reg";
	}
	else if ( pose == "barrel" )
	{
		if ( IsSubStr( weapon_name, "_silencer") )
			attachment_name = "silencer";
		else if ( IsSubStr( weapon_name, "_gl" ) || IsSubStr( weapon_name, "_m320" ) || IsSubStr( weapon_name, "_gp25" ) )
			attachment_name = "gl";
		else if ( IsSubStr( weapon_name, "_shotgun" ) )
			attachment_name = "shotgun";
		else
			attachment_name = "none";
	}
	else if ( pose == "scope" )
	{
		if ( IsSubStr( weapon_name, "_reflex") )
			attachment_name = "red_dot";
		else if ( IsSubStr( weapon_name, "_acog" ) )
			attachment_name = "acog";
		else if ( IsSubStr( weapon_name, "_eotech" ) )
			attachment_name = "eotech";
		else
			attachment_name = "iron_sight";
	}
	
	AssertEx( IsDefined( attachment_name ), "Could not create loadout attachment name from weapon name: \"" + weapon_name + "\" and pose name: \"" + pose + "\"" );
	AssertEx( array_contains( weapon_pose_attachment_order( weapon_name, pose ), attachment_name ), "Weapon does not have attachment: \"" + attachment_name + "\"" );
	
	return attachment_name;
}

weapon_name_from_pose_attachment_array( weapon_name, pose_attachment_array )
{
	name_simple = weapon_name_simple( weapon_name );
	weapon_name_new = "iw5_" + name_simple + "_mp";
	
	// Generate the weapon attachment strings
	weapon_attachment_names = [];
	foreach ( pose, attachment in pose_attachment_array )
	{
		if ( pose == "clip" )
		{
			if ( attachment == "clip_xmags" )
				weapon_attachment_names[ weapon_attachment_names.size ] = "xmags";
		}
		else if ( pose == "barrel" )
		{
			if ( attachment == "none" )
				continue;
			else if ( attachment == "silencer" )
				weapon_attachment_names[ weapon_attachment_names.size ] = "silencer";
			else if ( attachment == "gl" )
				weapon_attachment_names[ weapon_attachment_names.size ] = weapon_attachment_gl( weapon_name );
			else if ( attachment == "shotgun" )
				weapon_attachment_names[ weapon_attachment_names.size ] = "shotgun";
		}
		else if ( pose == "scope" )
		{
			if ( attachment == "iron_sight" )
				continue;
			else if ( attachment == "red_dot" )
				weapon_attachment_names[ weapon_attachment_names.size ] = "reflex";
			else if ( attachment == "eotech" )
				weapon_attachment_names[ weapon_attachment_names.size ] = "eotech";
			else if ( attachment == "acog" )
				weapon_attachment_names[ weapon_attachment_names.size ] = "acog";
		}
	}
	
	// Update scope attachment strings according to weapon type
	weapon_type = weapon_type( weapon_name );
	foreach ( index, attachment_name in weapon_attachment_names )
	{
		if ( attachment_name == "reflex" || attachment_name == "eotech" || attachment_name == "acog" )
		{
			if ( weapon_type == "smg" )
			{
				weapon_attachment_names[ index ] += "smg";
				//attachment_name += "smg";
			}
		}
	}
	
	weapon_attachment_names = alphabetize( weapon_attachment_names );
	
	foreach ( index, attachment_name in weapon_attachment_names )
	{
		weapon_name_new += "_" + attachment_name;
	}
	
	return weapon_name_new;
}

// Wrapper to allow weapons to have different attachment poses
weapon_pose_order( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	pose_order = undefined;
	
	if ( IsDefined( level.armory_weapon_info[ name_simple ] ) )
	{
		pose_order = level.armory_weapon_info[ name_simple ].pose_order;
	}
	else
	{
		// Should be read from a table if weapons are going to have different poses
		pose_order = [ "clip", "barrel", "scope" ];
	}
	
	return pose_order;
}

weapon_pose_attachment_order( weapon_name, pose )
{
	name_simple = weapon_name_simple( weapon_name );
	
	attachment_order = undefined;
	
	
	if ( IsDefined( level.armory_weapon_info[ name_simple ] ) )
	{
		attachment_order = level.armory_weapon_info[ name_simple ].pose_data[ pose ].attachment_order;
	}
	else
	{
		if ( pose == "clip" )
		{
			attachment_order = [ "clip_reg" ];
			
			if ( weapon_name_simple( weapon_name ) == "mp5" )
			{
				attachment_order[ attachment_order.size ] = "clip_reload";
				attachment_order[ attachment_order.size ] = "clip_xmags";
			}
		}
		else if ( pose == "barrel" )
		{
			attachment_order = [ "none", "silencer" ];
			if ( weapon_type( weapon_name ) == "rifle" )
			{
				attachment_order[ attachment_order.size ] = "gl";
				attachment_order[ attachment_order.size ] = "shotgun";
			}
		}
		else if ( pose == "scope" )
		{
			attachment_order = [ "iron_sight", "red_dot", "acog" ];
		}
	}
		
	
	return attachment_order;
}

weapon_pose_attachment_data_array( weapon_name, pose, attachment_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	return level.armory_weapon_info[ name_simple ].pose_data[ pose ].attachment_data[ attachment_name ];
}

// JC-ToDo: Should come from string table where attachment data is stored
// Returns an array of structs with data on them for each attachment
weapon_pose_attachment_info_create( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	if ( IsDefined( level.armory_weapon_info[ name_simple ] ) )
		return;
	
	weapon_info = SpawnStruct();
	
	weapon_info.pose_order = weapon_pose_order( weapon_name );
	weapon_info.pose_data = [];
	
	foreach ( pose in weapon_info.pose_order )
	{
		weapon_info.pose_data[ pose ] = SpawnStruct();
		weapon_info.pose_data[ pose ].attachment_order	= weapon_pose_attachment_order( weapon_name, pose );
		weapon_info.pose_data[ pose ].attachment_data	= [];
		
		attachment_names = weapon_pose_attachment_order( weapon_name, pose );
		foreach ( name in attachment_names )
		{
			weapon_info.pose_data[ pose ].attachment_data[ name ] = weapon_attachment_info_create( weapon_name, name );
		}
	}
	
	level.armory_weapon_info[ name_simple ] = weapon_info;
}

//	Example attachment data
//		attachment[ "viewmodel" ]					= undefined;
//		attachment[ "viewmodel_tag_weap" ]			= undefined;
//		attachment[ "viewmodel_tag_hide" ]			= undefined;
//		attachment[ "viewmodel_reticle" ]			= undefined;
//		attachment[ "viewmodel_reticle_tag" ]		= undefined;
//		attachment[ "part_tag" ]					= undefined;
//		attachment[ "fov" ]							= undefined;
//		attachment[ "anim" ]						= undefined;


weapon_attachment_info_create( weapon_name, attachment_name )
{
	attachment = [];
	
	if ( attachment_name == "clip_reg" )
	{
		attachment[ "viewmodel" ]				= undefined;
		attachment[ "viewmodel_tag_weap" ]		= undefined;
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= "tag_clip";
		attachment[ "fov" ]						= undefined;
		attachment[ "anim" ]					= undefined;
	}
	else if ( attachment_name == "clip_reload" )
	{
		attachment[ "viewmodel" ]				= "viewmodel_mag_reverse_mp5";
		attachment[ "viewmodel_tag_weap" ]		= "tag_clip";
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= undefined;
		attachment[ "anim" ]					= undefined;
	}
	else if ( attachment_name == "clip_xmags" )
	{
		attachment[ "viewmodel" ]				= "viewmodel_mag_ext_mp5";
		attachment[ "viewmodel_tag_weap" ]		= "tag_clip";
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= undefined;
		attachment[ "anim" ]					= undefined;
	}
	else if ( attachment_name == "silencer" )
	{
		attachment[ "viewmodel" ]				= "viewmodel_silencer_01";
		attachment[ "viewmodel_tag_weap" ]		= "tag_silencer";
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= undefined;
		attachment[ "anim" ]					= undefined;
	}
	else if ( attachment_name == "gl" )
	{
		attachment[ "viewmodel" ]				= weapon_viewmodel_gl( weapon_name );
		attachment[ "viewmodel_tag_weap" ]		= weapon_tag_gl( weapon_name );
		attachment[ "viewmodel_tag_hide" ]		= weapon_tag_gl_projectile( weapon_name );
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= undefined;
		attachment[ "anim" ]					= undefined;
	}
	else if ( attachment_name == "shotgun" )
	{
		attachment[ "viewmodel" ]				= "viewmodel_shotgun";
		attachment[ "viewmodel_tag_weap" ]		= "tag_shotgun";
		attachment[ "viewmodel_tag_hide" ]		= "j_ammo_shotgun";
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= undefined;
		attachment[ "anim" ]					= undefined;
	}
	else if ( attachment_name == "iron_sight" )
	{
		attachment[ "viewmodel" ]				= undefined;
		attachment[ "viewmodel_tag_weap" ]		= undefined;
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= weapon_tag_iron_sight( weapon_name );
		attachment[ "fov" ]						= weapon_fov_ads_iron_sight( weapon_name );
		attachment[ "anim" ]					= undefined;
	}
	else if ( attachment_name == "red_dot" )
	{
		attachment[ "viewmodel" ]				= "viewmodel_reflex_iw5";
		attachment[ "viewmodel_tag_weap" ]		= "tag_red_dot";
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= "viewmodel_reticle_reflex";
		attachment[ "viewmodel_reticle_tag" ]	= "tag_reticle_attach";
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= 50;
		attachment[ "anim" ]					= true;
	}
	else if ( attachment_name == "eotech" )
	{
		attachment[ "viewmodel" ]				= "viewmodel_eotech";
		attachment[ "viewmodel_tag_weap" ]		= "tag_eotech";
		attachment[ "viewmodel_tag_hide" ]		= "viewmodel_reticle_eotech";
		attachment[ "viewmodel_reticle" ]		= "tag_reticle_attach";
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= 45;
		attachment[ "anim" ]					= true;
	}
	else if ( attachment_name == "acog" )
	{
		attachment[ "viewmodel" ]				= "viewmodel_acog";
		attachment[ "viewmodel_tag_weap" ]		= "tag_acog_2";
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= "viewmodel_reticle_acog";
		attachment[ "viewmodel_reticle_tag" ]	= "tag_reticle_attach";
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= 30;
		attachment[ "anim" ]					= true;
	}
	else if ( attachment_name == "none" )
	{
		attachment[ "viewmodel" ]				= undefined;
		attachment[ "viewmodel_tag_weap" ]		= undefined;
		attachment[ "viewmodel_tag_hide" ]		= undefined;
		attachment[ "viewmodel_reticle" ]		= undefined;
		attachment[ "viewmodel_reticle_tag" ]	= undefined;
		attachment[ "part_tag" ]				= undefined;
		attachment[ "fov" ]						= undefined;
		attachment[ "anim" ]					= undefined;
	}
	else
	{
		AssertMsg( "Invalid attachment name: \"" + attachment_name + "\"" );
	}
	
	return attachment;
}

weapon_attachment_perk_give( attachment_name )
{
	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player when giving weapon attachment perk." );
	
	if ( attachment_name == "clip_reload" )
	{
		self SetPerk( "specialty_fastreload", true, false );
	}
}

weapon_attachment_perk_take( attachment_name )
{
	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player when removing weapon attachment perk." );
	
	if ( attachment_name == "clip_reload" )
	{
		self UnSetPerk( "specialty_fastreload", true );
	}
}

weapon_attachment_show( player_rig, weapon_name, pose, attachment_name, in_focus )
{
	name_simple = weapon_name_simple( weapon_name );
	
	attachment_array = level.armory_weapon_info[ name_simple ].pose_data[ pose ].attachment_data[ attachment_name ];
	
	if ( IsDefined( attachment_array[ "viewmodel" ] ) )
	{
		player_rig Attach( attachment_array[ "viewmodel" ], attachment_array[ "viewmodel_tag_weap" ], true );
		
		if ( IsDefined( attachment_array[ "viewmodel_tag_hide" ] ) )
		{
			player_rig HidePart( attachment_array[ "viewmodel_tag_hide" ] );
		}
		
		if ( IsDefined( attachment_array[ "viewmodel_reticle" ]  ) )
		{
			player_rig Attach( attachment_array[ "viewmodel_reticle" ], attachment_array[ "viewmodel_reticle_tag" ], true );
		}
	}
	
	if ( IsDefined( attachment_array[ "part_tag" ] ) )
	{
		player_rig ShowPart( attachment_array[ "part_tag" ] );
	}
	
	if ( IsDefined( in_focus ) && in_focus )
	{
		AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player in weapon_attachment_show() so fov cannot be adjusted." );
		
		fov = weapon_attachment_fov( weapon_name, pose, attachment_name );
		
		self LerpFOV( fov, CONST_ARMORY_WEAPON_ATTACHMENT_FOV_TIME );
	}
	
	self weapon_attachment_perk_give( attachment_name );
}

weapon_attachment_hide( player_rig, weapon_name, pose, attachment_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	attachment_array = level.armory_weapon_info[ name_simple ].pose_data[ pose ].attachment_data[ attachment_name ];
	
	if ( IsDefined( attachment_array[ "viewmodel" ] ) )
	{
		if ( IsDefined( attachment_array[ "viewmodel_reticle" ]  ) )
		{
			player_rig Detach( attachment_array[ "viewmodel_reticle" ], attachment_array[ "viewmodel_reticle_tag" ] );
		}
		
		player_rig Detach( attachment_array[ "viewmodel" ], attachment_array[ "viewmodel_tag_weap" ], true );
	}
	
	if ( IsDefined( attachment_array[ "part_tag" ] ) )
	{
		player_rig HidePart( attachment_array[ "part_tag" ] );
	}
	
	self weapon_attachment_perk_take( attachment_name );
}


weapon_attachment_fov( weapon_name, pose, attachment_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	attachment_array = level.armory_weapon_info[ name_simple ].pose_data[ pose ].attachment_data[ attachment_name ];
	
	fov = CONST_FOV_DEFAULT;
	if ( IsDefined( attachment_array[ "fov" ] ) )
	{
		fov = attachment_array[ "fov" ];
	}
	
	return fov;
}

weapon_anim_pull_out( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	return "crib_" + name_simple + "_pullout_2_clip";
}

weapon_anim_pose_trans( weapon_name, pose, pose_next )
{
	name_simple = weapon_name_simple( weapon_name );
	return "crib_" + name_simple + "_" + pose + "_2_" + pose_next;
}

weapon_anim_put_away( weapon_name, pose )
{
	name_simple = weapon_name_simple( weapon_name );
	return "crib_" + name_simple + "_" + pose + "_putaway";
}

weapon_anim_pose_idle( weapon_name, pose, attachment_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	attachment_array = level.armory_weapon_info[ name_simple ].pose_data[ pose ].attachment_data[ attachment_name ];
	
	anim_idle = "crib_" + name_simple + "_" + pose;
	
	if ( IsDefined( attachment_array[ "anim" ] ) )
	{
		switch ( attachment_name )
		{
			case "red_dot":
				anim_idle += "_reflex";		
				break;
			
			case "acog":
				anim_idle += "_acog";
			default:
			
				break;
		}
	}
	
	anim_idle += "_idle";
	
	return anim_idle;
}

weapon_name_simple( weapon_name )
{
	name_simple = undefined;
	
	weapon_parts = StrTok( weapon_name, "_" );
	
	if ( weapon_parts.size == 1 )
	{
		name_simple = weapon_parts[ 0 ];
	}
	else
	{
		index = 1;
		if ( weapon_parts[ 0 ] == "alt" )
		{
			index = 2;
		}
	
		if ( weapon_parts.size > index )
		{
			name_simple = weapon_parts[ index ];
		}
	}
	
	return name_simple;
}

weapon_is_customizable( weapon_name )
{
	return IsDefined( level.armory_weapon_info[ weapon_name_simple( weapon_name ) ] );
}

// Should be WeaponClass() but machine pistols come back as smgs
weapon_type( weapon_name )
{
	weapon_type = WeaponClass( weapon_name );
	
	if ( weapon_type == "smg" )
	{
		if ( IsSubStr( weapon_name, "_skorpion_" ) || IsSubStr( weapon_name, "_mp9_" ) || IsSubStr( weapon_name, "_g18_" ) )
		{
			weapon_type = "machine_pistol";
		}
	}
	
	return weapon_type;
}

armory_weapon_slot_type( weapon_name )
{
	weapon_type = weapon_type( weapon_name );
	slot_type = undefined;
	
	switch ( weapon_type )
	{
		case "rifle":
		case "smg":
			slot_type = "slot_primary";
			break;
		case "spread":
		case "pistol":
		case "machine_pistol":
			slot_type = "slot_secondary";
			break;
			
		default:
			AssertMsg( "A slot type could not be found for weapon: \"" + weapon_name + "\"" );
			break;
	}
	
	return slot_type;
}

weapon_tag_iron_sight( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	tag_iron = undefined;
	switch ( name_simple )
	{
		case "acr":
		case "mp5":
		case "ump45":
			tag_iron = "tag_sight_on";
			break;
		
		case "ak47":
			// No tag to be hidden for this weapon.
			break;
		
		default:
			AssertMsg( "The following weapon is not defined in the weapon_tag_iron_sight() function: \"" + weapon_name + "\"" );
			break;
	}
	
	return tag_iron;
}

weapon_fov_ads_iron_sight( weapon_name )
{
	weapon_type = weapon_type( weapon_name );
	
	fov = CONST_FOV_DEFAULT;
	
	switch ( weapon_type )
	{
		case "smg":
			fov = 55;
			break;
			
		case "rifle":
			fov = 50;
			break;
		
		default:
			AssertMsg( "weapon_fov_ads_iron_sight() function not set up to handle weapon type: \"" + weapon_type + "\"" );
			break;
	}

	return fov;
}

weapon_viewmodel_gl( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	viewmodel = undefined;
	
	switch ( name_simple )
	{
		case "ak47":
			viewmodel = "viewmodel_gp25";
			break;
		case "acr":
			viewmodel = "viewmodel_m320";
			
		default:
			AssertMsg( "Failed to get the grenade launcher viewmodel name for the following weapon: \"" + weapon_name + "\"" );
			break;
	}
	
	return viewmodel;
}

weapon_tag_gl( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	tag_gl = undefined;
	
	switch ( name_simple )
	{
		case "ak47":
			tag_gl = "tag_gp25";
			break;
		
		case "acr":
			tag_gl = "tag_m230";
			break;
		
		default:
			AssertMsg( "Failed to get the grenade launcher tag for weapon: \"" + weapon_name + "\"" );
			break;
	}
	
	return tag_gl;
}

weapon_tag_gl_projectile( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	tag_projectile = undefined;
	
	switch ( name_simple )
	{
		case "acr":
			tag_projectile = "j_grenade_m320";
			break;
		
		case "ak47":
			tag_projectile = "j_grenade_gp25";
			break;
			
		default:
			AssertMsg( "Failed to get the grenade launcher projectile tag for weapon: \"" + weapon_name + "\"" );
			break;
	}
	
	return tag_projectile;
}

weapon_attachment_gl( weapon_name )
{
	name_simple = weapon_name_simple( weapon_name );
	
	gl_str = undefined;
	
	switch ( name_simple )
	{
		case "acr":
			gl_str = "m320";
			break;
		
		case "ak47":
			gl_str = "gp25";
			break;
		
		default:
			AssertMsg( "Failed to get the grenade launcher attachment name for the following weapon: \"" + weapon_name + "\"" );
			break;
	}
	
	return gl_str;
}

weapon_pose_next( weapon_name, pose_current )
{
	array_poses = weapon_pose_order( weapon_name );
	
	index = array_find( array_poses, pose_current );
	
	index++;
	if ( index >= array_poses.size )
	{
		index = 0;
	}
	
	return array_poses[ index ];
}

weapon_pose_prev( weapon_name, pose_current )
{
	array_poses = weapon_pose_order( weapon_name );
	
	index = array_find( array_poses, pose_current );
	
	index--;
	if ( index < 0 )
	{
		index = array_poses.size - 1;
	}
	
	return array_poses[ index ];
}

weapon_pose_attachment_next( weapon_name, pose, attachment_current )
{
	array_attachments = weapon_pose_attachment_order( weapon_name, pose );
	
	index = array_find( array_attachments, attachment_current );

	index++;
	if ( index >= array_attachments.size )
	{
		index = 0;
	}
	
	return array_attachments[ index ];
}

weapon_pose_attachment_prev( weapon_name, pose, attachment_current )
{
	array_attachments = weapon_pose_attachment_order( weapon_name, pose );
	
	index = array_find( array_attachments, attachment_current );
	
	index--;
	if ( index < 0 )
	{
		index = array_attachments.size - 1;
	}
	
	return array_attachments[ index ];
}

weapon_player_pick_up( weapon_loc_ent )
{
	AssertEx( IsDefined( self ) && IsPlayer( self ), "self not player when trying to pick up a weapon." );
	AssertEx( IsDefined( weapon_loc_ent ), "weapon_loc_ent not valid or for weapon pick up." );
	AssertEx( IsDefined( weapon_loc_ent.weapon_name ), "weapon_loc_ent doesn't have weapon_name defined for pick up." );
	
	player = self;
	
	player.weapon_name = weapon_loc_ent.weapon_name;
	player GiveWeapon( weapon_loc_ent.weapon_name );
	player SwitchToWeapon( weapon_loc_ent.weapon_name );
	
	weapon_loc_ent_scrub( weapon_loc_ent );
}

weapon_loc_ent_scrub( weapon_loc_ent )
{
	AssertEx( IsDefined( weapon_loc_ent ), "weapon_loc_ent not defined when scrubbing location data." );
	
	weapon_loc_ent.weapon_name = undefined;
	if ( IsDefined( weapon_loc_ent.weapon_ent ) )
	{
		weapon_loc_ent.weapon_ent Delete();
		weapon_loc_ent.weapon_ent = undefined;
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Target logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	// Grabbed from so_deltacamp.gsc and ripped apart. If a pit is
	// added to the safehouse, rip this again with all the bells
	// and whistles

has_script_parameter( parameter, delimiter )
{
	Assert( IsDefined( parameter ) );
	Assert( IsDefined( delimiter ) );
	
	if ( !IsDefined( self ) || !IsDefined( self.script_parameters ) )
	{
		return false;
	}
	
	array_params = StrTok( self.script_parameters, delimiter );
	
	return array_contains( array_params, parameter );
}

course_target_reset()
{
	AssertEx( IsDefined( level.group_structs ) && level.group_structs.size, "course_target_reset() called with no course set up." );
	
	level notify( "course_target_reset" );
	
	level.breachEnemies_active = 0;
	
	foreach ( group_struct in level.group_structs )
	{
		foreach ( target in group_struct.targets )
		{
			// Have the target self damage so that it knows to reset
			target.target_model DoDamage( 1, target.origin, target );
		}
		
		group_struct notify( "all_targets_down" );
	}
}

course_target_setup( group_struct_names )
{
	level.target_rail_start_points		= getentarray( "target_rail_start_point", "targetname" );
	level.target_rail_path_start_points	= getentarray( "target_rail_path_start_point", "targetname" );
	level.speakers 						= getentarray( "speakers", "targetname" );
	level.group_structs					= [];
	
	// Hide melee clips until they are needed
	level.melee_clips = GetEntArray( "melee_clip", "targetname" );
	array_thread( level.melee_clips, ::hide_entity );
	
	// Build array of target group structs
	foreach ( name in group_struct_names )
	{
		struct = get_target_ent( name );
		level.group_structs[ level.group_structs.size ] = struct;
	}
	
	// Set up the targets under each group struct
	foreach ( struct in level.group_structs )
	{
		struct.doors_before			= [];
		struct.doors_after			= [];
		struct.targets				= [];
		struct.targets_friendly		= [];
		struct.targets_enemy		= [];
		struct.targets_enemy_killed	= 0;
		
		linked_ents = struct get_linked_ents();
		
		foreach ( ent in linked_ents )
		{
			if ( !IsDefined( ent.code_classname ) )
				continue;
			
			if ( ent.code_classname == "script_brushmodel" )
			{
				if ( !is_coop() && ent has_script_parameter( "coop_only", ";" ) )
				{
					ent target_delete();
					continue;
				}
				
				if ( IsDefined( ent.script_noteworthy ) && IsSubStr( ent.script_noteworthy, "target_" ) )
				{
					if ( ent.script_noteworthy == "target_enemy" )
					{
						struct.targets_enemy[ struct.targets_enemy.size ] = ent;
					}
					else if ( ent.script_noteworthy == "target_friendly" )
					{
						struct.targets_friendly[ struct.targets_friendly.size ] = ent;
					}
					else
					{
						AssertMsg( "Target at " + ent.origin + " needs a script_noteworthy with either target_enemy or target_friendly." );
						continue;
					}
					
					ent thread target_think( StrTok( ent.script_noteworthy, "_" )[ 1 ] );
					struct.targets[ struct.targets.size ] = ent;
					
					if ( ent has_script_parameter( "invisible", ";" ) )
					{
						target_hide( ent );
					}
					
					continue;
				}
				
				if ( ent has_script_parameter( "door", ";" ) )
				{
					if ( ent has_script_parameter( "door_before", ";" ) )
					{
						struct.doors_before[ struct.doors_before.size ] = ent;
					}
					else if ( ent has_script_parameter( "door_after", ";" ) )
					{
						struct.doors_after[ struct.doors_after.size ] = ent;
					}
					else
					{
						Assert( "Door at " + ent.origin + " had no door_after or door_before script parameter." );
						continue;
					}
					
					ent thread door_think();
				}
			}
			
			if ( ent.code_classname == "script_model" )
			{
				if ( ent has_script_parameter( "door", ";" ) )
				{
					if ( ent has_script_parameter( "door_before", ";" ) )
					{
						struct.doors_before[ struct.doors_before.size ] = ent;
					}
					else if ( ent has_script_parameter( "door_after", ";" ) )
					{
						struct.doors_after[ struct.doors_after.size ] = ent;
					}
					else
					{
						Assert( "Door at " + ent.origin + " had no door_after or door_before script parameter." );
						continue;
					}
					
					ent thread door_think();
				}
			}
			
			if ( ent.code_classname == "trigger_multiple" && IsDefined( ent.classname ) )
			{
				if (
						ent.classname == "trigger_multiple_flag_set"
					&&	IsDefined( ent.script_flag )
					&&	flag_exist( ent.script_flag )
					)
				{
					AssertEx( !IsDefined( struct.script_flag ), "The struct.script_flag field was already set." );
					struct.script_flag = ent.script_flag;
					continue;
				}
				else if ( ent.classname == "trigger_multiple" )
				{
					struct.trig_required = ent;
					struct.trig_required trigger_off();
					continue;
				}
			}
		}
	}
}

target_think( target_type )
{
	// Early out if the target has already had the think
	// thread applied
	if ( IsDefined( self.thinking ) )
		return;
	
	self.thinking = true;
	
	self.meleeonly = undefined;
	
	brushmodel_targets = GetEntArray( self.target, "targetname" ) ;
	foreach ( target_ent in brushmodel_targets )
	{
		if ( target_ent.classname == "script_origin" )
		{
			self.orgEnt = target_ent;
			continue;
		}
		else if ( target_ent.classname == "script_model" )
		{
			self.target_model = target_ent;
			if ( IsDefined( self.target_model.target ) )
			{
				self.target_model.gear_pieces = GetEntArray( self.target_model.target, "targetname" );
			}
			
			continue;
		}
		
		AssertMsg( "Invalid ent in training target prefab of classname: " + target_ent.classname );
	}
	
	// Set up origin ent
	Assert( IsDefined( self.orgEnt ) );
	self LinkTo( self.orgEnt );
	aim_assist_target = GetEnt( self.orgEnt.target, "targetname" );
	aim_assist_target Hide();
	aim_assist_target NotSolid();
	aim_assist_target LinkTo( self );
	
	// Set up script_model
	AssertEx( IsDefined( self.target_model ), "The target does not have a script_model targeted by the script_brushmodel" );
	self.target_model LinkTo( self.orgEnt );
	if ( IsDefined( self.target_model.gear_pieces ) )
	{
		foreach ( piece in self.target_model.gear_pieces )
		{
			piece LinkTo( self.orgEnt );
		}
	}
	
	if ( self has_script_parameter( "reverse", ";" ) )
	{
		self.orgEnt RotatePitch( 90, 0.25 );
	}
	else if ( self has_script_parameter(  "sideways_right", ";" ) )
	{
		self.orgEnt RotateYaw( -180, 0.35 );
	}
	else if ( self has_script_parameter(  "sideways_left", ";" ) )
	{
		self.orgEnt RotateYaw( 180, 0.35 );
	}
	else if ( self has_script_parameter( "vertical", ";" ) )
	{
		self.orgEnt MoveTo( self.orgEnt.origin - (0,0,36), 0.25 );
	}
	else
	{
		self.orgEnt RotatePitch( -90, 0.25 );
	}
	
	// SETUP LATERALLY MOVING TARGETS
	
	if ( self has_script_parameter( "use_rail", ";" ) )
	{
		self.lateralMovementOrgs	= undefined;
		self.lateralStartPosition	= undefined;
		self.lateralEndPosition		= undefined;
		
		self.lateralStartPosition = getclosest( self.orgEnt.origin, level.target_rail_start_points, 10 );
		AssertEx( IsDefined( self.lateralStartPosition ), "Pop up target at " + self.origin + " has its script_parameters set to 'use_rail' but there is no valid rail start org within 10 units " );
		self.lateralEndPosition = GetEnt( self.lateralStartPosition.target, "targetname" );
		AssertEx( IsDefined( self.lateralEndPosition ),  "Pop up target at " + self.origin + " has a rail start position that is not targeting an end rail position" );
		self.lateralMovementOrgs = [];
		self.lateralMovementOrgs[ 0 ] = self.lateralStartPosition;
		self.lateralMovementOrgs[ 1 ] = self.lateralEndPosition;
		
		foreach ( org in self.lateralMovementOrgs )
		{
			AssertEx( org.code_classname == "script_origin", "Pop up targets that move laterally need to be targeting 2 script_origins" );
		}
		self target_lateral_reset_start_pos();
	}
	
	if ( self has_script_parameter( "use_rail_path", ";" ) )
	{
		self.move_orgs = [];
		path_ent = getClosest( self.orgEnt.origin, level.target_rail_path_start_points, 10 );
		while ( IsDefined( path_ent ) )
		{
			self.move_orgs[ self.move_orgs.size ] = path_ent;
			
			if ( IsDefined( path_ent.target ) )
			{
				path_ent = path_ent get_target_ent();
			}
			else
			{
				path_ent = undefined;
			}
		}
	}
	
	while ( true )
	{
		
		// TARGET POPS UP WHEN NOTIFIED
		
		self waittill ( "pop_up", parent_struct );
		
		AssertEx( IsDefined( parent_struct ), "Target notified to pop up without a defined parent struct." );
		AssertEx( IsDefined( parent_struct.targets_enemy_killed ) && parent_struct.targets_enemy_killed == 0, "Target notified to pop up without a defined parent_struct.targets_enemy_killed set to 0." );
		
		if ( self has_script_parameter( "breach", ";" ) )
		{
			level.breachEnemies_active++;
		}
	
		if ( IsDefined( self.script_delay ) )
		{
			wait self.script_delay;
		}

		so_player_tooclose_wait();
		
		if ( self has_script_parameter( "invisible", ";" ) )
		{
			target_show( self );
		}
		
		if ( self has_script_parameter( "melee", ";" ) )
		{
			AssertEx( level.melee_clips.size, "Training mission has a melee target but no melee clips" );
			melee_clip_close = getClosest( self.origin, level.melee_clips, 120 );
			AssertEx( IsDefined( melee_clip_close ), "No melee clip could be found for melee target at origin: " + self.origin );
			
			self.meleeonly = true;
			self.melee_clip = melee_clip_close;
			self.melee_clip show_entity();
		}
		
		// Get breach targets up super fast
		pop_time = 0.25;
		if ( !self has_script_parameter( "breach", ";" ) )
		{
			wait RandomFloatRange ( 0, .2 );
		}
		else
		{
			pop_time = 0.05;
		}
		
		self Solid();
		self PlaySound( "target_up_metal" );
		self.target_model SetCanDamage( true );
		
		if ( self has_script_parameter( "dog_bark", ";" ) )
		{
			self thread target_play_dog_bark();
		}
		
		if ( target_type != "friendly" )
		{
			aim_assist_target EnableAimAssist();
		}
		
		if ( self has_script_parameter( "reverse", ";" ) )
		{
			self.orgEnt RotatePitch( -90, pop_time );
		}
		else if ( self has_script_parameter( "sideways_right", ";" ) )
		{
			self.orgEnt RotateYaw( 180, pop_time );
		}
		else if ( self has_script_parameter( "sideways_left", ";" ) )
		{
			self.orgEnt RotateYaw( -180, pop_time );
		}
		else if ( self has_script_parameter( "vertical", ";" ) )
		{
			self.orgEnt MoveTo( self.orgEnt.origin + (0,0,36), pop_time );
		}
		else
		{
			self.orgEnt RotatePitch( 90, pop_time );
		}
		
		wait pop_time;
		
		if ( IsDefined( self.lateralStartPosition ) )
		{
			self thread target_lateral_movement();
		}
		else if ( IsDefined( self.move_orgs ) && self.move_orgs.size )
		{
			self thread target_path_movement();
		}
		
		//-----------------------
		// TARGET IS DAMAGED
		//-------------------------
		while ( true )
		{
			target_being_reset = false;
			
			self.target_model waittill ( "damage", amount, attacker, direction_vec, point, type, model, tag, part, flags, weapon );
			
			if ( !IsDefined( attacker ) )
				continue;
			
			if ( attacker == self )
			{
				target_being_reset = true;
			}
			else
			{
				if ( !IsDefined( type ) )
					continue;
				if ( type == "MOD_IMPACT" )
					continue;
			}
			
			if ( target_being_reset )
			{
				break;
			}
			else if ( IsPlayer( attacker ) )
			{
				if ( IsDefined( self.meleeonly ) && type != "MOD_MELEE" )
				{
					continue;
				}
				
				self PlaySound( "target_metal_hit" );
				
				if ( target_type == "friendly" )
				{
//					thread HUD_civilian_hit();
					
					speaker = getclosest( attacker.origin, level.speakers );
					speaker PlaySound( "target_mistake_buzzer" );

					attacker.civs_hit++;
					level.civs_hit++;
					level notify( "civilian_killed", attacker );
				}
				else
				{
					attacker maps\_player_stats::register_kill( self, type, weapon );
					attacker notify( "ui_kill_count", attacker.stats[ "kills" ] );
					
					level notify( "target_killed" );
					
					if ( self has_script_parameter( "breach", ";" ) )
					{
						level.breachEnemies_active--;
					}
					
					parent_struct.targets_enemy_killed++;
					
					if ( parent_struct.targets_enemy_killed >= parent_struct.targets_enemy.size )
					{
						parent_struct notify( "all_targets_down" );
					}
				}
				
				if ( type == "MOD_GRENADE_SPLASH" )
				{
					self notify( "hit_with_grenade" );
				}
				
				break;
			}
		}
		
		//-----------------------
		// TARGET OUT OF PLAY TILL TOLD TO POP UP AGAIN
		// -------------------------
		if ( IsDefined( self.meleeonly ) )
		{
			self.melee_clip hide_entity();
		}
		
		self notify ( "hit" );
		self notify ( "target_going_back_down" );
		self.health = 1000;
		aim_assist_target DisableAimAssist();
		self NotSolid();
		
		// If the target was bouncing as it moved
		// make sure to set it back to the last valid
		// position
		if ( IsDefined( self.orgEnt.drop_origin ) )
		{
			self.orgEnt.origin = self.orgEnt.drop_origin;
		}
		
		if ( self has_script_parameter( "reverse", ";" ) )
		{
			self.orgEnt RotatePitch( 90, 0.25 );
		}
		else if ( self has_script_parameter( "sideways_right", ";" ) )
		{
			self.orgEnt RotateYaw( -180, 0.35 );
		}
		else if ( self has_script_parameter( "sideways_left", ";" ) )
		{
			self.orgEnt RotateYaw( 180, 0.35 );
		}
		else if ( self has_script_parameter( "vertical", ";" ) )
		{
			self.orgEnt MoveTo( self.orgEnt.origin - (0,0,36), 0.25 );
		}
		else
		{
			self.orgEnt RotatePitch( -90, 0.25 );
		}
		
		self.target_model SetCanDamage( false );
		wait 0.35;
	}
}

target_group_pop_and_wait( group_struct, thermal )
{
	if ( IsDefined( thermal ) && thermal )
	{
		dummy_models = [];
		
		foreach ( target in group_struct.targets )
		{
			dummy_models[ dummy_models.size ] = target.target_model;
		}
		
		array_thread( group_struct.targets, ::target_thermal_think );
	}
	
	// Clear targets killed in case targets are being re-used
	group_struct.targets_enemy_killed = 0;
	
	array_notify( group_struct.targets, "pop_up", group_struct );
	group_struct waittill( "all_targets_down" );
}

target_group_pop_and_wait_name( group_struct_name, thermal )
{
	group_struct = undefined;
	
	foreach ( struct in level.group_structs )
	{
		if ( IsDefined( struct.targetname ) && struct.targetname == group_struct_name )
		{
			group_struct = struct;
			break;
		}
	}
	
	AssertEx( IsDefined( group_struct ), "target_group_pop_and_wait_name() called with targetname: " + group_struct_name + " but no set up struct of that name could be found." );
	
	target_group_pop_and_wait( group_struct, thermal );
}

target_thermal_think()
{
	self.target_model ThermalDrawEnable();
	
	if ( IsDefined( self.target_model.gear_pieces ) && self.target_model.gear_pieces.size )
	{
		array_call( self.target_model.gear_pieces, ::ThermalDrawEnable );
	}
	
	self waittill( "target_going_back_down" );
	
	self.target_model ThermalDrawDisable();
	
	if ( IsDefined( self.target_model.gear_pieces ) && self.target_model.gear_pieces.size )
	{
		array_call( self.target_model.gear_pieces, ::ThermalDrawDisable );
	}
}

so_player_tooclose_wait()
{
	origin = self.origin;

	y_check = undefined;
	if ( self has_script_parameter( "melee", ";" ) )
	{
		origin = ( -5723, 2547, -49 ); // Just under the melee target
		y_check = 2520;
	}

	while ( 1 )
	{
		close = false;
		foreach ( player in level.players )
		{
			dist_test = 56 * 56;
			if ( Length( player GetVelocity() ) > 200 )
			{
				dist_test = 128 * 128;
			}

			if ( DistanceSquared( player.origin, origin ) < dist_test )
			{
				close = true;

				if ( IsDefined( y_check ) && player.origin[ 1 ] < y_check )
				{
					close = false;
				}
			}
		}

		if ( !close )
		{
			return;
		}

		wait( 0.05 );
	}
}

target_lateral_movement()
{
	dummy = Spawn( "script_origin", ( 0, 0, 0 ) );
	dummy.angles = self.orgEnt.angles;
	dummy.origin = self.orgEnt.origin;
	self.orgEnt thread target_move_with_dummy( dummy );
	
	dummy endon( "deleted_because_player_was_too_close" );
	dummy endon( "death" );
	foreach ( player in level.players )
	{
		dummy thread delete_when_player_too_close( player );
	}

	self thread dummy_delete_when_target_goes_back_down( dummy );
	
	// Targets in MW2 moved one ft per second so presever that here
	// unless over written by script_speed field.
	feet_per_sec = ter_op( IsDefined( self.script_speed ), self.script_speed, 1 );
	
	dist = Distance( self.lateralMovementOrgs[ 0 ].origin, self.lateralMovementOrgs[ 1 ].origin );
	time = dist / ( 12.0 * feet_per_sec );
	while ( true )
	{
		dummy MoveTo( self.lateralEndPosition.origin, time );
		wait( time );
		dummy MoveTo( self.lateralStartPosition.origin, time );
		wait( time );
	}
}

target_play_dog_bark()
{
	level endon( "special_op_terminated" );
	self endon( "target_going_back_down" );
	
	while ( 1 )
	{
		self PlaySound( "anml_dog_bark", "bark_done" );
		self waittill( "bark_done" );
		
		wait( RandomFloatRange( 0.1, 0.5 ) );
	}
}

target_path_movement()
{
	dummy = Spawn( "script_origin", ( 0, 0, 0 ) );
	dummy.angles = self.orgEnt.angles;
	dummy.origin = self.orgEnt.origin;
	
	if ( self has_script_parameter( "bounce", ";" ) )
	{
		self.orgEnt thread target_move_with_dummy( dummy, 8, 2.0 );
	}
	else
	{
		self.orgEnt thread target_move_with_dummy( dummy, 0, 0.0 );
	}
	
	dummy endon( "deleted_because_player_was_too_close" );
	dummy endon( "death" );
	foreach ( player in level.players )
	{
		dummy thread delete_when_player_too_close( player );
	}

	self thread dummy_delete_when_target_goes_back_down( dummy );
	
	for ( i = 0; i < self.move_orgs.size - 1; i++ )
	{
		// Targets in MW2 moved one ft per second so presever that here
		// unless over written by script_speed field.
		feet_per_sec = ter_op( IsDefined( self.script_speed ), self.script_speed, 1 );
		
		dist = Distance( self.move_orgs[ i ].origin, self.move_orgs[ i + 1 ].origin );
		time = dist / ( 12.0 * feet_per_sec );
		
		dummy MoveTo( self.move_orgs[ i + 1 ].origin, time );
		wait( time );
	}
	
	dummy Delete();
}

dummy_delete_when_target_goes_back_down( dummy )
{
	dummy endon( "death" );
	//self --> the target
	self waittill( "target_going_back_down" );
	dummy Delete();
}

delete_when_player_too_close( player )
{
	//want to stop lateral movement if player is too close to avoid getting stuck
	self endon( "death" );
	dist = 128;
	distSquared = dist * dist;
	while ( true )
	{
		wait( 0.05 );
		if ( DistanceSquared( player.origin, self.origin ) < distSquared )
			break;
	}
	self notify( "deleted_because_player_was_too_close" );
	self Delete();
}

target_move_with_dummy( dummy, bounce_height, bounce_ft_per_sec )
{
	dummy endon( "death" );
	
	moving_up					= true;
	vertical_move_each_update	= 0;
	vertical_offset				= 0;
	
	if ( IsDefined( bounce_height ) && IsDefined( bounce_ft_per_sec ) )
	{
		// convert ft per second 
		bounce_inches_per_sec = 12.0 * bounce_ft_per_sec;
		vertical_move_each_update = bounce_inches_per_sec / 20.0;
	}
	else
	{
		bounce_height = 0.0;
	}
	
	while ( true )
	{
		wait( 0.05 );
		
		if ( moving_up )
		{
			vertical_offset += vertical_move_each_update;
			if ( vertical_offset > bounce_height )
			{
				vertical_offset = bounce_height;
				moving_up = false;
			}
		}
		else
		{
			vertical_offset -= vertical_move_each_update;
			if ( vertical_offset < 0.0 )
			{
				vertical_offset = 0.0;
				moving_up = true;
			}
		}
		
		self.drop_origin = dummy.origin;
		self.origin = dummy.origin + ( 0, 0, vertical_offset );
	}
}

target_lateral_reset_start_pos()
{
	if ( self.lateralMovementOrgs[ 0 ] has_script_parameter( "force_start_here", ";" ) )
	{
		self.lateralStartPosition = self.lateralMovementOrgs[ 0 ];
		self.lateralEndPosition = self.lateralMovementOrgs[ 1 ];
	}
	else if ( self.lateralMovementOrgs[ 1 ] has_script_parameter( "force_start_here", ";" ) )
	{
		self.lateralStartPosition = self.lateralMovementOrgs[ 1 ];
		self.lateralEndPosition = self.lateralMovementOrgs[ 0 ];
	}
	else if ( cointoss() )
	{
		self.lateralStartPosition = self.lateralMovementOrgs[ 0 ];
		self.lateralEndPosition = self.lateralMovementOrgs[ 1 ];
	}
	else
	{
		self.lateralStartPosition = self.lateralMovementOrgs[ 1 ];
		self.lateralEndPosition = self.lateralMovementOrgs[ 0 ];
	}

	self.orgEnt MoveTo( self.lateralStartPosition.origin, .1 );

}

door_think()
{
	rotation = -90;
	
	if ( IsDefined( self.script_goalyaw ) )
	{
		rotation = self.script_goalyaw;
	}
		
	self waittill( "open" );
	
	self RotateYaw( rotation, 0.5, 0.2, 0.1 );
}

target_hide( target_brush_model )
{
	target_brush_model hide_entity();
	target_brush_model.target_model hide_entity();
}

target_show( target_brush_model )
{
	target_brush_model show_entity();
	target_brush_model.target_model show_entity();
}

// JC-ToDo: This currently doesn't delete attached models along with the main model
target_delete()
{
	target_parts = [];
	target_parts[ target_parts.size ] = self;
	
	// The brush model (self) targets both the script_origin ent
	// and the script_model visual
	targeted_ents = GetEntArray( self.target, "targetname" );
	foreach ( ent in targeted_ents )
	{
		if ( ent.classname == "script_origin" )
		{
			target_parts [ target_parts.size ] = GetEnt( ent.target, "targetname" );
		}
		
		target_parts [ target_parts.size ] = ent;
	}
	
	array_call( target_parts, ::Delete );
}

