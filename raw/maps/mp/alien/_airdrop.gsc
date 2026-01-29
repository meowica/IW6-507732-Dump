#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\alien\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\_perk_utility;

CONST_DRILL_REARM_TIME			= 4;	// seconds: time it takes to rearm the drill, this value is increased by 1 per player
CONST_DETONATION_COUNTDOWN		= 180;	// seconds: till it explodes
CONST_DRILL_HEALTH 				= 150;	// health: of planted bomb to withstand alien attack
CONST_HEALTH_INVULNERABLE		= 20000;
CONST_DRILL_THREATBIAS			= -1000;

CONST_DRILL_MODEL				= "mp_ext_laser_drill";
CONST_DRILL_MODEL_OBJ			= "mp_ext_laser_drill_obj";

main()
{
	if ( !alien_mode_has( "airdrop" ) ) { return; }

	// state flags
	flag_init( "drill_detonated" );
	
	// inits
	init_fx();				// fx
	init_drill_drop_loc();	// drill start location
	init_hive_locs();		// strongholds
	init_drill();			// bomb carry and detonation
	
	// drill device loop
	thread drill_think();
	
	// hive location loop
	thread hive_think();
}

//=======================================================
//		Inits
//=======================================================

init_drill_drop_loc()
{
	level.drill_locs = [];
	level.drill_locs = getstructarray( "bomb_drop_loc", "targetname" );
}

init_hive_locs()
{
	level.stronghold_hive_locs = [];
	
	stronghold_hive_locs = getentarray( "stronghold_bomb_loc", "targetname" );
	
	foreach ( location_ent in stronghold_hive_locs )
	{
		// location struct targets stuff to remove
		if ( isdefined( location_ent.target ) )
		{
			targeted_ents = getentarray( location_ent.target, "targetname" );
			assert( isdefined( targeted_ents ) && targeted_ents.size > 0 );
			
			removeables = [];
			fx_ents 	= [];
			
			foreach ( ent in targeted_ents )
			{
				if ( isdefined( ent.script_noteworthy ) && ent.script_noteworthy == "fx_ent" )
					fx_ents[ fx_ents.size ] = ent;
				else
					removeables[ removeables.size ] = ent;
			}
			
			location_ent.removeables = removeables;
			location_ent.fx_ents = fx_ents;
			
			// init depths and layers
			location_ent.depth 			= CONST_DETONATION_COUNTDOWN;
			
			location_ent.layers_done	= [];	// track which layers already drilled to
			location_ent.layers 		= [];	// layers for notify when drilled to
			location_ent.layers[ 0 ]	= int( CONST_DETONATION_COUNTDOWN * 0.333 ) + 1; // default 1/3 way
			location_ent.layers[ 1 ]	= int( CONST_DETONATION_COUNTDOWN * 0.666 ) + 1; // default 2/3 way
			
			msg = "Layer deeper than max depth";
			assertex( location_ent.layers[ location_ent.layers.size - 1 ] < location_ent.depth, msg );
			
			// override layers and depth from radiant
			// in format of: "60 120 180"; ( layer_1 = 60, layer_2 = 120, total_depth = 180 )
			if ( isdefined( location_ent.script_noteworthy ) )
			{
				// override layers:
				parsed_layers = StrTok( location_ent.script_noteworthy, " " );
				
				msg = "stronghold_bomb_loc's script_noteworthy is incorrect, ex: '60 120 180'";
				assertex( parsed_layers.size, msg );
				
				location_ent.layers = [];
				for ( i = 0; i < parsed_layers.size - 1; i++ )
					location_ent.layers[ i ] = int( parsed_layers[ i ] );
				
				// override depth:
				// last value is the total depth
				location_ent.depth = int( parsed_layers[ parsed_layers.size - 1 ] );
			}
			
			// .depth changes as we drill, total_depth never changes
			location_ent.total_depth = location_ent.depth;
		}

		level.stronghold_hive_locs[ level.stronghold_hive_locs.size ] = location_ent;
	}
}

init_drill()
{
	level.drill_id 			= 0;
	level.drill_marker_id 	= 1;
	
	// carried drill
	level.drill 			= undefined;
	level.drill_carrier 	= undefined;

	//	timer
	maps\mp\alien\_hud::create_drill_timer_hud( "countdown_timer", &"ALIEN_COLLECTIBLES_COUNTDOWN_TIMER", 0 );
	level.drill_HUD["countdown_timer"].color = ( 1, 1, 1 );
	
	maps\mp\alien\_hud::create_drill_timer_hud( "countdown_timer_secondary", &"ALIEN_COLLECTIBLES_COUNTDOWN_TIMER_SECONDARY", 1 );
	level.drill_HUD["countdown_timer_secondary"].color = ( 1, 1, 0 );
}

init_fx()
{
	// fx
	level._effect[ "stronghold_explode_med" ] 	= loadfx( "fx/explosions/sentry_gun_explosion" );
	level._effect[ "stronghold_explode_large" ] = loadfx( "fx/explosions/aerial_explosion" );
	level._effect[ "stronghold_ambient_fog" ] 	= loadfx( "vfx/gameplay/alien/vfx_alien_env_ambient_fog" );
	level._effect[ "alien_hive_explode" ] 		= loadfx( "fx/explosions/alien_hive_explosion" );
	
	level.spawnGlowModel["friendly"] 			= "mil_emergency_flare_mp";
	level.spawnGlow["friendly"] 				= loadfx( "fx/misc/flare_ambient_green" );
}

//=======================================================
//	Drill object loop
//=======================================================

// loop to respawn drill object
drill_think()
{
	level endon( "game_ended" );
	
	wait 1; // padding, may not be needed later
	
	// drill initial drop location
	drop_loc = ( 2668, -33, 495 ); 	// default for "mp_alien_town"
	drop_loc_struct = getstruct( "drill_loc", "targetname" );
	if ( isdefined( drop_loc_struct ) )
		drop_loc = drop_loc_struct.origin;
	
	// TODO: remove after new model is in, and carry object is setup, 
	// currently is to remove the vest model dropped on ground when dropping drill
	marker = undefined;
	
	while ( true )
	{
		wait 0.05;

		spawn_drill_raw( CONST_DRILL_MODEL_OBJ, drop_loc, marker );
		
		level waittill( "new_drill", drop_loc, marker );
		assertex( isdefineD( drop_loc ), "Drill dropped at invalid position" );
	}
}

// drop drill spawns new drill
drop_drill( pos, marker )
{
	level notify( "new_drill", pos, marker );
}

// spawns the drill and listens for pickup
spawn_drill_raw( model, pos, marker )
{
	level.drill_carrier = undefined; // means no one is carrying drill as drill is spawned
	
	// remove previous version, <safe>
	if ( isdefined( level.drill ) )
	{
		level.drill delete();	
		level.drill = undefined;
	}
	
	// drill object
	offset = ( 0, 0, -10 );
	level.drill = spawn( "script_model", pos + offset );
	level.drill.attackable = false;
	level.drill setmodel( model );
	level.drill set_drill_icon();
	level.drill.state = "idle"; // idle meaning it can be picked up/planted
	
	//using marker to kill the dropped alien drill model.  
	//TODO: remove "marker" when we get a proper drill model and the tags are correct for makeusable
	level.drill thread drill_pickup_listener( marker );
}

// listen for pickup, updates icon from drill to carrier
drill_pickup_listener( marker )
{
	// self is level.drill, the script model
	self endon( "death" );
	
	level endon( "game_ended" );
	level endon( "new_drill" );
	
	// ======= SETUP FOR PICKUP =======
	self MakeUsable();
	self SetCursorHint( "HINT_ACTIVATE" );	
	self SetHintString( &"ALIEN_COLLECTIBLES_PICKUP_BOMB" );
	
	// ======= WAIT FOR PICKUP =======
	while( true )
	{
		self waittill( "trigger", owner );
		
		if( isPlayer( owner ) )
			break;
	}
	
	// ======= PICKED UP =======
	// tell the world who picked up the drill
	level notify( "drill_pickedup", owner );
	flag_clear( "drill_detonated" );
	self PlaySound( "scavenger_pack_pickup" );
	
	level.drill_carrier = owner;
	level.drill_carrier set_drill_icon( true );
	self.state = "carried";
	
	// player setup
	owner thread drop_drill_on_death();
	owner setLowerMessage( "go_plant", &"ALIEN_COLLECTIBLES_GO_PLANT_BOMB", 4 );
	owner.lastweapon = owner GetCurrentWeapon();
	owner _giveWeapon( "alienbomb_mp" );
	owner SwitchToWeapon( "alienbomb_mp" );
	owner DisableWeaponSwitch();
	
	// ======= CLEAN UP =======
	// clean up drill marker model after pickup
	if (IsDefined (marker) )
		marker delete();
	
	// removed from the world, also ends threads running on the pickupable object
	self delete();
}

// drop drill when player so others can pick it up
drop_drill_on_death()
{
	// self is player
	level endon( "game_ended" );
	level endon( "new_drill" );			// new drill was requested, old drill will be removed
	level endon( "drill_planted" );		// drill left hand of owner
	level endon( "drill_dropping" );	// drill left hand of owner
	
	// only one instance of this per player
	self notify( "watching_drop_drill_on_death" );
	self endon( "watching_drop_drill_on_death" );
	
	// either death or last stand mode
	self waittill_either( "death", "last_stand" );

	self Takeweapon( "alienbomb_mp" );
	self EnableWeaponSwitch();
	self SwitchToWeapon( self.lastWeapon );

	level.drill_carrier = undefined;

	assert( isdefined( self.last_death_pos ) );
	drop_drill( self.last_death_pos );
}

//===========================================================
//		Main stronghold loop: carry, plant, arm, detonate
//===========================================================

hive_think()
{
	// TODO: drill gets an objective icon, carried or not
	
	foreach ( stronghold_loc in level.stronghold_hive_locs )
		stronghold_loc thread hive_drill_listener();
}

// self is hive, hive is listening for a drill to be planted on self
hive_drill_listener()
{
	// self is stronghold_loc struct
	level endon( "game_ended" );
	
	// only one instance of listener
	self notify( "stop_listening" );
	self endon( "stop_listening" );
	
	// =========== WAIT FOR DRILL TO BE PICKED UP ===========
	level waittill( "drill_pickedup", player );
	//[!] DURING THIS TIME, level.drill IS UNDEFINED AS IT IS CARRIED BY PLAYER
	
	// show plant location icons after drill is picked up by a player
	self thread set_hive_icon( "waypoint_alien_destroy", 1300 );
	
	// =========== WAIT FOR DRILL PLANTED ===================
	planter = self wait_for_drill_plant();
	
	level notify( "drill_planted", planter, self );
	
	// clear carrier
	level.drill_carrier = undefined;
	
	// ============ DRILLING LOOP ===========================
	// setup drilling operation and for aliens to attack
	self thread drilling( self.origin, planter );	
	
	// kill other stronghold threads because this one is chosen
	self disable_other_strongholds();

	// reset bonus
	maps\mp\alien\_gamescore::reset_all_bonus();

	// ======== CYCLE FORCE START FOR EXTERNAL WAITS ========
	level notify( "force_cycle_start" );
	
	// ============ WAIT TILL DRILLING COMPLETE =============
	flag_wait( "drill_detonated" );

	// ============ DRILL DETONATE ==========================
	self drill_detonate();
	
	// remove loc from stronghold_hive_locs
	level.stronghold_hive_locs = array_remove( level.stronghold_hive_locs, self );
	
	// kill everything else
	self notify( "stop_listening" );
	
	//wait 0.05;
	//self delete();
}

wait_for_drill_plant()
{
	// self is hive location struct, where we allow planting of drill
	self endon( "stop_listening" );
	
	self MakeUsable();
	self SetCursorHint( "HINT_ACTIVATE" );	
	self SetHintString( &"ALIEN_COLLECTIBLES_PLANT_BOMB" );
	
	while( true )
	{
		self waittill( "trigger", player );
		
		if ( !isdefined( level.drill_carrier ) || level.drill_carrier != player )
		{
			player setLowerMessage( "no_bomb", &"ALIEN_COLLECTIBLES_NO_BOMB", 5 );
			wait 0.05;
			continue;
		}
		
		if( isPlayer( player ) )
		{
			// clear lower message hint to plant bomb
			player clearLowerMessage( "go_plant" );
			
			// remove the bomb and give the player back his last weapon
			player TakeWeapon( "alienbomb_mp" );
			player EnableWeaponSwitch();
			player SwitchToWeapon( player.lastweapon ); 
	
			self MakeUnusable();
			self SetHintString( "" );
			
			return player;
		}
	}
}

// loops until drilling is complete, handles being offline
drilling( pos, owner )
{
	// self is hive location struct drill is drilling
	self endon( "stop_listening" );
	
	// =======[STATE: PLANT]======= //
	self thread set_drill_state_plant( pos );

	level.drill endon( "death" );
	level.drill.owner = owner;
	
	// =======[STATE: RUN]======= //
	self thread set_drill_state_run();
	
	// main drilling loop
	while ( true )
	{
		// wait till offline
		level.drill waittill( "offline" );

		// =======[STATE: OFF]======= //
		self thread set_drill_state_offline();
		
		// scale rearm time with number of players
		num_of_players = level.players.size; // 1 second longer per player
		rearm_time = ( CONST_DRILL_REARM_TIME + num_of_players ) * 1000;
		
		// wait for user reactivation
		wait_for_reactivation( rearm_time );

		// =======[STATE: RUN]====== //
		self thread set_drill_state_run();
	}
}

// [!] function not to be used to reset drills not yet planted
set_drill_state_plant( pos )
{
	// reset drill
	if ( isdefined( level.drill ) )
	{
		level.drill delete();	
		level.drill = undefined;
	}
	
	// TODO: Replace with animated drill model
	offset = ( 0, 0, -10 );
	level.drill = spawn( "script_model", pos + offset );
	level.drill setmodel( CONST_DRILL_MODEL ); 
	level.drill.state = "planted";
	level.drill PlaySound( "detpack_plant" );
	
	// init depth marker
	self.depth_marker = gettime();
	
	level thread maps\mp\alien\_music_and_dialog::playVOForBombPlant();
	
	// remove drill icon
	destroy_drill_icon();
	
/#
	if ( GetDvarInt( "alien_debug_director" ) > 0 )
	{
		msg = "";
		foreach ( layer in self.layers )
			msg += " " + layer;
		
		msg += " [" + self.depth + "]";
		
		IPrintLnBold( "Hive layers:" + msg );		
	}
#/
}

set_drill_state_run()
{
	// self is stronghold_loc struct
	self endon( "death" );
	self endon( "stop_listening" );
	
	level.drill.state = "online";
	level.drill notify( "online" );
	
	// setup for attackable
	level.drill setCanDamage( true );
	level.drill MakeUnUsable();
	level.drill SetHintString( "" );
	
	// reset attributes
	level.drill.team				= level.drill.owner.team;
	level.drill.maxhealth 			= CONST_HEALTH_INVULNERABLE + CONST_DRILL_HEALTH;
	level.drill.health 				= CONST_HEALTH_INVULNERABLE + CONST_DRILL_HEALTH;
	level.drill.attackable 			= level.drill MakeEntitySentient( "allies" );
	level.drill.threatbias 			= CONST_DRILL_THREATBIAS;
	
	// tell aliens drill is up for attack!
	foreach ( agent in level.agentArray )
	{
		if ( isdefined( agent.wave_spawned ) && agent.wave_spawned )
			agent GetEnemyInfo( level.drill );
	}
	
	// play fx on drill when armed
	level.drill.fxEnt = SpawnFx( level.spawnGlow["friendly"], level.drill.origin );
	TriggerFx( level.drill.fxEnt );	
	
	// friendly fire and offline catch
	self thread handle_bomb_damage();

	// set new depth, self.depth was already updated by offline state
	level.drill_HUD["countdown_timer"] setTimer( max( 1, self.depth ) );
	level.drill_HUD["countdown_timer"].alpha = 1;
	level.drill_HUD["countdown_timer"].color = ( 1, 1, 1 );
	
	// update time marker, to track running time, so it can be subtracted from total when it runs again
	self.depth_marker = gettime();
	
	/#
	if ( GetDvarInt( "alien_debug_director" ) > 0 )
	{
		if ( level.drill.attackable )
			iprintln( "Drill is attackable" );
		else
			iprintln( "Failed to make drill attackable!" );
	}
	#/
	
	// thread to watch for end of drilling
	self thread monitor_drill_complete( self.depth );
	
	// set waypoint to defend location
	self thread set_hive_icon( "waypoint_defend" );
	
	// remove drill icon
	destroy_drill_icon();
}

monitor_drill_complete( depth )
{
	// self is stronghold_loc struct
	self endon( "death" );
	self endon( "stop_listening" );
	
	level.drill endon( "offline" );
	
	// depth is the remainder to be drilled
	drilled_depth = self.total_depth - depth;
	assertex( drilled_depth >= 0, "We have over-drilled somehow!!!" );

	foreach( key, layer in self.layers )
	{
		if ( drilled_depth < layer )
			self thread monitor_drill_layers( key, layer - drilled_depth );
	}

	self thread update_layer_HUD();
	
	wait( depth );
	
	// to stop monitoring of drill layers
	self notify( "drill_complete" );
	
	flag_set( "drill_detonated" );
}

monitor_drill_layers( layer_idx, remaining_layer_depth )
{
	// self is stronghold_loc struct
	self endon( "death" );
	self endon( "stop_listening" );
	self endon( "drill_complete" );	// <-- if we ended here with this, its weird somewhere!
	
	level.drill endon( "offline" );

	wait( remaining_layer_depth );
	
	earthquake_intensity = 0.4;
	warn_delay = 1.75;
	thread warn_all_players( warn_delay, earthquake_intensity );
	
	// notifies layer index reached
	// param passed ex: "reached_layer_1", 45, stronghold_loc struct
	// notify is indicated in string table, layer = seconds it took, stronghold_loc struct drilled on
	notify_msg = "reached_layer_" + ( layer_idx + 1 );
	level notify( notify_msg, remaining_layer_depth, self );
	
	//TODO: re-enable when table tweaked
	maps\mp\alien\_spawn_director::activate_spawn_event( notify_msg );
	
	// turn off layer for HUD to read
	self.layers_done[ layer_idx ] = self.layers[ layer_idx ];
	
/#
	if ( GetDvarInt( "alien_debug_director" ) > 0 )
		IPrintLnBold( "activate_spawn_event: " + notify_msg );
#/
}

warn_all_players( warn_delay, earthquake_intensity )
{
	level endon( "game_ended" );
	
	wait warn_delay;
	
	foreach ( player in level.players )
	{
		player thread warn_player( earthquake_intensity );
	}
}

warn_player( earthquake_intensity )
{
	Earthquake( earthquake_intensity, 3, self.origin, 300 ); 
	self PlaySound( "pre_quake_mtl_groan" );
	self PlayRumbleOnEntity( "heavygun_fire" );
}

update_layer_HUD()
{
	// self is stronghold_loc struct
	self endon( "death" );
	self endon( "stop_listening" );
	self endon( "drill_complete" );	// <-- if we ended here with this, its weird somewhere!
	
	level.drill endon( "offline" );

	while ( true )
	{
		layer_active = false;
		for( i = self.layers.size - 1; i >= 0; i-- )
		{
			layer = self.layers[ i ];
			if ( !array_contains( self.layers_done, layer ) )
			{
				level.drill_HUD["countdown_timer_secondary"] setTimerStatic( max( 1, self.total_depth - layer ) );
				layer_active = true;
			}
		}
		
		if ( layer_active )
			level.drill_HUD["countdown_timer_secondary"].alpha = 1;
		else
			level.drill_HUD["countdown_timer_secondary"].alpha = 0;
		
		wait 1;
	}
}

set_drill_state_offline()
{
	// self is stronghold_loc struct
	self endon( "death" );
	self endon( "stop_listening" );
	
	level.drill.state = "offline";
	//level.drill notify( "offline" ); // already notified by damage monitor
	
	// TODO: Radio dialogue
	IPrintLnBold( "Aliens knocked the beacon offline, reactivate it!" );
	
	// delete flare fx
	if ( Isdefined( level.drill.fxEnt) )
		level.drill.fxEnt Delete();
	
	// mark time
	depth_delta = ( gettime() - self.depth_marker )/1000;
	self.depth -= depth_delta;
	
	// stops timer
	level.drill_HUD["countdown_timer"] setTimerStatic( self.depth );
	level.drill_HUD["countdown_timer"].color = ( 1, 0, 0 );
		
	level.drill MakeUsable();
	level.drill SetCursorHint( "HINT_ACTIVATE" );	
	level.drill SetHintString( &"ALIEN_COLLECTIBLES_PLANT_BOMB" );
	
	level.drill setCanDamage( false );
	level.drill.attackable 	= false;
	level.drill FreeEntitySentient();
	
	// rid the defend icon
	self destroy_hive_icon();
	
	// set drill icon to signal player for reactivation
	level.drill set_drill_icon();
}

handle_bomb_damage()
{
	// self is stronghold_loc struct
	self endon( "death" );
	self endon( "stop_listening" );
	
	level.drill endon( "death" ); 
	level.drill endon( "offline" ); // no need to monitor damages if offline
	
	while ( 1 )
	{
		level.drill waittill( "damage", amount, attacker, direction_vec, point, type );
		if ( isDefined( attacker ) && ( isDefined( attacker.team ) && attacker.team == level.drill.team ) )
		{
			// No friendly fire!
			level.drill.health += amount;
			continue;
		}
		
		PlayFxOnTag( level._effect[ "bomb_impact" ], level.drill, "tag_origin" );
		
		level thread maps\mp\alien\_music_and_dialog::playVOForBomDamaged();
		
		if ( level.drill.health < CONST_HEALTH_INVULNERABLE )
		{
			// offline
			level.drill notify( "offline" );
		}
		else
		{
			// color scales to red when health is low
			health_ratio 	= ( level.drill.health - CONST_HEALTH_INVULNERABLE ) / CONST_DRILL_HEALTH;
			health_ratio 	= max( 0, min( 1, health_ratio ) );
			health_ratio	= health_ratio * health_ratio; // shows red earlier
			green 			= health_ratio;
			blue 			= green;
			self.icon.color = ( 1, green, blue );
		}
	}
}


// disables all other strongholds when a bomb is planted on one
disable_other_strongholds()
{
	foreach ( stronghold_loc in level.stronghold_hive_locs )
	{
		if ( self != stronghold_loc )
		{
			if ( isdefined( stronghold_loc.icon ) )
				stronghold_loc.icon Destroy();

			stronghold_loc MakeUnusable();
			stronghold_loc SetHintString( "" );
			stronghold_loc thread hive_drill_listener();
		}
	}
}

drill_detonate()
{
	// remove timer
	level.drill_HUD["countdown_timer"].alpha = 0;
	level.drill_HUD["countdown_timer_secondary"].alpha = 0;
	
	// final kill sequence
	if ( isAlive( level.drill ) )
	{
		// display bonus
		level thread maps\mp\alien\_hud::display_all_bonus();
		
		fx_count = 5;
		for ( i = 0; i < fx_count; i ++ )
		{
			wait randomfloatrange( 0.75, 1.5 );
			
			offset = 8;
			_x = offset - randomintrange( 0, offset*2 );
			_y = offset - randomintrange( 0, offset*2 );
			
			PlayFx( level._effect[ "alien_hive_explode" ], self.origin + ( _x, _y, 0 ) );
			self playSound( "alien_spitter_hit" );
		}
	}
	
	// delete flare fx
	if ( Isdefined( level.drill.fxEnt) )
		level.drill.fxEnt Delete();
	
	org = level.drill.origin;
	drop_drill( org );
	
	// rid hive icon if active
	self destroy_hive_icon();

	self MakeUnusable();
	self SetHintString( "" );

	PlayFX( level._effect[ "stronghold_explode_large" ], self.origin );
	self PlaySound( "explo_mine" );
	level thread maps\mp\alien\_music_and_dialog::playVOForBombDetonate();
	
	self thread delete_removables();
	self thread fx_ents_playfx();
}


wait_for_reactivation( use_time )
{
	while ( true )
	{
		// wait for friendly player to use
		level.drill waittill ( "trigger", player );

		use_time = int ( use_time * ( player perk_GetUseTimeScaler() ) );
		reactivation_success = get_activation_result( player, level.drill, use_time );
		
		if ( reactivation_success )
		{
			//player maps\mp\alien\_gamescore::update_personal_bonus( "teammate_revive" );
			
			// rearm sound
			level thread maps\mp\alien\_music_and_dialog::playVOForBombPlant();
			
			return;
		}
		else
		{
			wait 0.05;
			continue;
		}
	}
}

get_activation_result( reactivator, use_entity, use_time )
{
	if ( !isplayer( reactivator ) )
		return false;

	reactivator.isCapturingCrate = true;
	
	// links activator in place and display bar
	useEnt = use_entity createUseEnt();
	result = useEnt useHoldThink( reactivator, use_time );
	
	if ( IsDefined( useEnt ) )
		useEnt delete();
	
	reactivator.isCapturingCrate = false;
	
	return result;
}

createUseEnt()
{
	useEnt = Spawn( "script_origin", self.origin );
	useEnt.curProgress = 0;
	useEnt.useTime = 0;
	useEnt.useRate = 1;
	useEnt.inUse = false;
	useEnt thread deleteUseEnt( self );
	return useEnt;
}

deleteUseEnt( owner )
{
	self endon ( "death" );
	owner waittill( "death" );
	self delete();
}

useHoldThink( player, useTime ) 
{
	if ( IsPlayer( player ) )
		player playerLinkTo( self );
	else
		player LinkTo( self );
	player playerLinkedOffsetEnable();
    
    player _disableWeapon();
    
    self.curProgress = 0;
    self.inUse = true;
    self.useRate = 1;
    
	if ( IsDefined( useTime ) )
		self.useTime = useTime;
	else
		self.useTime = 3000;
    
	player thread personalUseBar( self );
   
    result = useHoldThinkLoop( player );
	assert ( IsDefined( result ) );
    
    if ( isAlive( player ) )
    {
        player _enableWeapon();
        player unlink();
    }
    
    if ( !IsDefined( self ) )
    	return false;

    self.inUse = false;
	self.curProgress = 0;

	return ( result );
}

personalUseBar( object )
{
    self endon( "disconnect" );
    
    useBar = createPrimaryProgressBar( 0, 25 );
    useBarText = createPrimaryProgressBarText( 0, 25 );
    useBarText setText( &"ALIEN_COLLECTIBLES_REPAIR_DRILL" );

    lastRate = -1;
    while ( isReallyAlive( self ) && IsDefined( object ) && object.inUse && !level.gameEnded )
    {
        if ( lastRate != object.useRate )
        {
            if( object.curProgress > object.useTime)
                object.curProgress = object.useTime;
               
            useBar updateBar( object.curProgress / object.useTime, (1000 / object.useTime) * object.useRate );

            if ( !object.useRate )
            {
                useBar hideElem();
                useBarText hideElem();
            }
            else
            {
                useBar showElem();
                useBarText showElem();
            }
        }    
        lastRate = object.useRate;
        wait ( 0.05 );
    }
    
    useBar destroyElem();
    useBarText destroyElem();
}

useHoldThinkLoop( player )
{
	while( !level.gameEnded && IsDefined( self ) && isReallyAlive( player ) && player useButtonPressed() && ( !isdefined( player.lastStand ) || !player.lastStand ) && self.curProgress < self.useTime )
    {
        self.curProgress += (50 * self.useRate);
		self.useRate = 1;

        if ( self.curProgress >= self.useTime )
            return ( isReallyAlive( player ) );
       
        wait 0.05;
    } 
    
    return false;
}

//==============================================================================
//		Bomb viewmodel carry and replace weapons when bomb is planted or dropped
//==============================================================================
//
watchBomb()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	
	// remove bomb on player spawn, no way they can spawn with one by default currently
	if ( self hasweapon( "alienbomb_mp" ) )
	{
		self TakeWeapon( "alienbomb_mp" );
		self EnableWeaponSwitch();
	}
	
	while ( 1 )
	{
		self waittill( "grenade_fire", alienbomb, weapname );
		if ( weapname == "alienbomb" || weapname == "alienbomb_mp" )
		{
			alienbomb.owner = self;
			alienbomb SetOtherEnt(self);
			alienbomb.team = self.team;

			alienbomb thread watchBombStuck( self );			
		}
	}
}

//Watcher for the dropped bomb to stick then spawns a new script_model bomb at the location of the dropped bomb
watchBombStuck( owner ) 
{
	// self == alienbomb projectile
	level endon( "game_ended" );
	self endon( "death" ); // if deleted or died
	
	owner endon( "death" );
	owner endon( "disconnect" );
	
	level notify( "drill_dropping" );
	self waittill( "missile_stuck" ); //to spawn pickup trigger in the correct location
	level notify( "drill_dropped" );
	
	// auto plant if dropped close to target
	foreach ( destroy_loc in level.stronghold_hive_locs )
	{
		if ( distance( destroy_loc.origin, self.origin ) < 160 )
		{
			// auto plant
			destroy_loc notify( "trigger", owner );
			
			owner TakeWeapon( "alienbomb_mp" );
			owner EnableWeaponSwitch();
			
			self delete();
			return;
		}
	}

	drop_drill( self.origin, self );
	
	owner TakeWeapon( "alienbomb_mp" );
	owner EnableWeaponSwitch();	
	
	self delete();
}


//=======================================================
//		HUD - Icons
//=======================================================

// player bomb carry init on player spawn - No longer used  TODO : Remove this
player_carry_bomb_init()
{
	// self is player
	if ( !isdefined( self.carryIcon ) )
	{
		if ( level.splitscreen )
		{
			self.carryIcon = createIcon( "hud_suitcase_bomb", 33, 33 );
			self.carryIcon setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", -50, -78 );
		}
		else
		{
			self.carryIcon = createIcon( "hud_suitcase_bomb", 50, 50 );
			self.carryIcon setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", -50, -65 );
		}
		
		self.carryIcon.hidewheninmenu = true;
		self thread hideCarryIconOnGameEnd();
	}
	
	self.carryIcon.alpha = 0;
}

hideCarryIconOnGameEnd()
{
	self endon( "disconnect" );
	
	level waittill( "game_ended" );
	
	if ( isDefined( self.carryIcon ) )
		self.carryIcon.alpha = 0;
}

set_hive_icon( shader, coll_dist )
{
	// self is stronghold_loc struct
	level endon( "game_ended" );
	
	self endon( "stop_listening" );
	
	// ================= OPTMZ =================
	// logic to not spawn new hudelems until players are close enough to see them
	// default icon vis dist
	if ( !isdefined( coll_dist ) )
		coll_dist = 1000;
	
	// wait till player is close before creating more hudelems
	someone_is_close = false;
	while ( !someone_is_close )
	{
		someone_is_close = false;
		foreach ( player in level.players )
		{
			if ( isalive( player ) && Distance( player.origin, self.origin ) <= coll_dist )
				someone_is_close = true;
		}
		wait 0.05;
	}
	// ==========================================
	
	// reset icon
	self destroy_hive_icon();
	
	self.icon = NewHudElem();
	self.icon SetShader( shader, 14, 14 );
	self.icon.alpha = 0;
	self.icon.color = ( 1, 1, 1 );
	self.icon SetWayPoint( true, true );
	self.icon.x = self.origin[ 0 ];
	self.icon.y = self.origin[ 1 ];
	self.icon.z = self.origin[ 2 ];
	
	if ( !isdefined( coll_dist ) )
	{
		self.icon.alpha = 0.5;
		return;
	}
	
	self.icon endon( "death" );
	
	while ( isdefined( self.icon ) )
	{
		someone_is_close = false;
		foreach ( player in level.players )
		{
			if ( isalive( player ) && Distance( player.origin, self.origin ) <= coll_dist )
				someone_is_close = true;
		}
		
		if ( someone_is_close )
			icon_fade_in( self.icon );		// has wait already
		else
			icon_fade_out( self.icon );		// has wait already
		
		wait 0.05;
	}
}

icon_fade_in( icon )
{
	if ( icon.alpha != 0 )
		return;

	icon FadeOverTime( 1 );
	icon.alpha = .5;
	wait( 1 );
}

icon_fade_out( icon )
{
	if ( icon.alpha == 0 )
		return;

	icon FadeOverTime( 1 );
	icon.alpha = 0;
	wait( 1 );
}

destroy_hive_icon()
{
	// self is hive loc struct	
	if ( isdefined( self.icon ) )
		self.icon Destroy();
}

set_drill_icon( link )
{
	level notify( "new_bomb_icon" );
	
	// destroy in case we used to link 
	destroy_drill_icon();
	
	level.drill_icon = NewHudElem();
	level.drill_icon SetShader( "waypoint_alien_drill", 14, 14 );
	level.drill_icon.color = ( 1, 1, 1 );
	level.drill_icon SetWayPoint( true, false );
	level.drill_icon.sort = 1;
	level.drill_icon.foreground = true;
	level.drill_icon.alpha = 0.5;
	level.drill_icon.x = self.origin[ 0 ];
	level.drill_icon.y = self.origin[ 1 ];
	level.drill_icon.z = self.origin[ 2 ] + 72;
	
	if ( isdefined( link ) && link )
		thread update_drill_icon_pos( self );
}

update_drill_icon_pos( ent )
{
	// self is hudelem
	// ent is position we follow
	level endon( "new_bomb_icon" );
	
	while ( isdefined( level.drill_icon ) && isdefined( ent ) )
	{
		level.drill_icon.x = ent.origin[ 0 ];
		level.drill_icon.y = ent.origin[ 1 ];
		level.drill_icon.z = ent.origin[ 2 ] + 64; // likely be linked to player
		
		wait 0.5;
	}
}

destroy_drill_icon()
{
	if ( isdefined( level.drill_icon ) )
		level.drill_icon Destroy();
}

//=======================================================
//		Helpers
//=======================================================

delete_removables()
{
	// self is stronghold_loc script model
	assert( isdefined( self.removeables ) );
	
	foreach ( ent in self.removeables )
	{
		ent delete();
	}
}

fx_ents_playfx()
{
	// self is stronghold_loc script model
	assert( isdefined( self.fx_ents ) );
	
	foreach ( fx_ent in self.fx_ents )
	{
		playfx( level._effect[ "stronghold_explode_med" ], fx_ent.origin );
		fx_ent delete();
	}
}