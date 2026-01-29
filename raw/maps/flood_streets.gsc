#include maps\_utility;
#include maps\_anim;
#include maps\_vignette_util;
#include common_scripts\utility;
#include maps\_vehicle;
//#include maps\_stealth_utility;

section_main()
{
	add_hint_string( "launcher_qte", &"FLOOD_LAUNCHER_MELEE", ::mlrs_stop_qte_hint );
}

section_precache()
{
    PreCacheItem( "stinger_speedy" );
    
//    PreCacheItem( "ac130_40mm" );
//    PreCacheItem( "ac130_105mm" );
//    PreCacheItem( "btr80_ac130_turret" );
//    PreCacheItem( "weapon_ac130" );
//    PreCacheItem( "50cal_turret_ugv" );
	//used for tracer fire you can see...
//    PreCacheItem( "50cal_turret_technical" );
//    PreCacheItem( "smoke_grenade_american" );
//    PreCacheItem( "ac130_25mm_tank" );
    	
    PreCacheItem( "rpg_straight" );
    PreCacheRumble( "artillery_rumble" ); 
    PreCacheRumble( "heavy_1s" );
	PreCacheRumble( "heavy_2s" );    
    PreCacheModel("viewhands_player_ranger_dirty_urban");
//    PreCacheModel("weapon_c4_obj");
    PreCacheModel("vehicle_m880_launcher_obj");    
    PreCacheModel("com_trafficcone02");
	PreCacheModel("flood_light_generator");
	PrecacheModel("vehicle_van_mica_destroyed");
    PreCacheString(&"SCRIPT_PLATFORM_BREACH_ACTIVATE");
    PreCacheString(&"FLOOD_DISABLE_LAUNCHER");

    PreCacheShellShock( "default" );
    
//for dam vignette screen fx.  Use real thing not nightvision.
	PreCacheShader( "flood_ui_vignette" );	
//	PreCacheShader( "nightvision_overlay_goggles" );	
	
	
}

section_flag_inits()
{
//    flag_init("wave_1_seen");
//    flag_init("wave_3_seen");
//    flag_init("approaching_missiles");
    flag_init("looked_at_missiles");
    flag_init("missiles_fired");
    flag_init("missiles_ready");
//    flag_init("pushing_barrier");
    flag_init("looked_at_missiles_failsafe");
//    flag_init("embassy_door_breach");
//    flag_init("wave_2_retreat");
//    flag_init("retreat_started");
//    flag_init("start_aiming");
//    flag_init("humvee_destroyed");
    flag_init("start_flood");
    flag_init("level_faded_to_black");
    flag_init("end_of_dam");
//    flag_init("missile_destroy_keegan_ready");
    flag_init("player_on_ladder");
    flag_init("streets_to_dam_enemies_dead");
    flag_init("streets_to_dam_enemies_ALMOST_dead");    
    flag_init("enemy_advance");
    flag_init("allies_shot_at");
//    flag_init("ok_to_send_ml");
    flag_init("enemy_alerted");
    flag_init("enemy_surprised");    
    flag_init("everyone_in_garage");
  	flag_init("baker_move_up");
  	flag_init("baker_anim_done");
//  	flag_init("baker_hold_up");
	flag_init("player_ready_to_progress");
	flag_init("rpg_spawn");  	
//  	flag_init("baker_stopped");
  	flag_init("see_convoy");  	
    flag_init("player_move_up");
    flag_init("missile_launcher_in_place");
    flag_init("missile_launcher_destruction_done");
    flag_init("convoy_gone");
    flag_init("start_cover_fire");
    flag_init("rpg_fired_at_launcher");
    flag_init("close_to_checkpoint");
    flag_init("start_heli_attack");
    flag_init("vignette_lens");
    flag_init("vignette_lens_fade_out");    
    flag_init("spawn_m880");
    flag_init("m880_has_spawned");
    flag_init("enemy_tank_2_firing_at_player");
    flag_init("grenade_thrown");
    flag_init("played_radio_part_1");
    flag_init("played_radio_part_2");
}

test_tracer_fire(tracer_type, mstart, mtarget )
{
//	wait(5);
    missile_start = GetStruct( mstart, "targetname" );
    while(!isdefined(missile_start))
    {
    	missile_start = GetStruct( mstart, "targetname" );
    	wait(.1);
    }
    missile_target = GetStruct( mtarget, "targetname" );
    while(!isdefined(missile_target))
    {
    	missile_target = GetStruct( mtarget, "targetname" );
    	wait(.1);
    }
//    IPrintLn("trying to fire");
    while(1)
    {
    	fire_at_target(missile_start.origin, missile_target.origin, true, level.player,tracer_type);
//    	MagicBullet( tracer_type, missile_start.origin, missile_target.origin );
    	wait(.5);
    }
}
   

//ignore_player_on_fly_in()
//{
//	level.player.ignoreme = true;
//	level.allies[0].ignoreme = true;
//	level.allies[1].ignoreme = true;
//	level.allies[2].ignoreme = true;
//	
//	trigger = getent("streets_spawn_enemy_tank", "targetname");
//    trigger waittill("trigger");
//
//	level.player.ignoreme = false; 
//	level.allies[0].ignoreme = false;
//	level.allies[1].ignoreme = false;
//	level.allies[2].ignoreme = false;	
//	
//} 

hide_missile_launcher_collision()
{
	script_brushes = GetEntArray( "missile_launcher_collision", "targetname" );

    foreach( brush in script_brushes )
    {
        brush Hide();
        brush NotSolid();

//        if( brush.classname == "script_brushmodel" )
//        {
//            brush ConnectPaths();
//        }
    }
	
}

show_missile_launcher_collision()
{
	flag_wait("missile_launcher_in_place");
	
	script_brushes = GetEntArray( "missile_launcher_collision", "targetname" );

    foreach( brush in script_brushes )
    {
        brush Show();
        brush Solid();

//        if( brush.classname == "script_brushmodel" )
//        {
//            brush ConnectPaths();
//        }
    }
	
}

enemy_init()
{
	heli_node_1 = Getstruct("heli_start_firing_1", "script_noteworthy");
	heli_node_1 waittill("trigger");
	
	wait(2.0);
	
//	goal_volume = GetEnt("streets_wave_1_goal_volume", "targetname");
//    self SetGoalVolumeAuto(goal_volume);
    
}

infil_heli_anim_skip()
{
	animName = self getanim( "infil" );
	animTime = GetNotetrackTimes( animName, "infil_heli_takeoff" )[ 0 ];
	self delayCall( 0.05, ::SetAnimTime, animName, animTime );
}

notify_with_trigger_targetname(sNotify, sTargetname)
{
	trigger = GetEnt(sTargetname, "targetname");
	trigger waittill("trigger");
    
	self notify(sNotify);
}
    

//for debugging
draw_turret_target_line()
{
	self endon("death");
	while(1)
	{
		turret_target = self GetTurretTarget(0);
		if(isdefined(turret_target))
		{
			thread draw_line_for_time(self.origin, turret_target.origin, 1, 0, 0, .1);
						
		}
		
		wait(.1);
	}
}
	
//not used anymore
//enemy_tank_2_mg_player_and_allies()
//{f
//	too_far_forward = getent("enemy_tank_2_too_far_forward", "targetname");
//    while(level.player istouching(too_far_forward))
//    {
//    	wait(.1);
//    }
//    
////    IPrintLn("testing: 2");
//
//    enemy_tank_shoots_at_allies = GetVehicleNode( "allied_tank_middle", "targetname" );
//    enemy_tank_shoots_at_allies waittill ( "trigger");
//    
//    flag_wait("allies_shot_at");   
//}

//fire enemy mg at allied soldiers

//MM not used
//enemy_tanks_mg_everyone()
//{
////	level.enemy_tank_2.mgturret[0] SetConvergenceTime(0.0);
////	level.enemy_tank_2 SetTurretTargetEnt(level.player);
//	
////	level.enemy_tank_2 ClearTurretTarget();
////	level.enemy_tank_3 ClearTurretTarget();
//	level.enemy_tank_2 mgon();
//	level.enemy_tank_3 mgon();
//	
//}

rumble_when_tank_breaks_wall()
{
	wait(.1);
		
	level.player PlayRumbleOnEntity("artillery_rumble");	
}

fake_tank_rumble()
{
	self endon("death");
	
	while(1)
	{
		//	"tank_rumble"
		level.player PlayRumbleOnEntity("tank_rumble");
		wait(.1);
	}
}

//MM not used
//throw_smoke_grenade_at_target(org, target_ent)
//{
////	grenade = MagicGrenade( "smoke_grenade_american", org.origin, target_ent.origin );
//	grenade = MagicGrenade( "fraggrenade", org.origin, target_ent.origin );
//}

destroy_planter(planter_name)
{
	planter_array = GetEntArray(planter_name, "script_noteworthy");
	foreach ( element in planter_array)
	{
		if(isdefined(element.targetname) && element.targetname == "planter_trigger")
		{
			element notify("trigger");
		}
	}	
}

destroy_corner()
{
	planter_array = GetEntArray("corner_exploder_trigger", "script_noteworthy");
	foreach ( element in planter_array)
	{
//		if(isdefined(element.targetname) && element.targetname == "planter_trigger")
//		{
			element notify("trigger");
//		}
	}	
}

////move the target the turret is aiming at up and down in Y
//move_turret_target(target)
//{
//	self endon("death");
//	increasing = true;	
//	current_pos = target.origin;
//	
//	next_y = current_pos[1];
//	
//	while(1)
//	{
//		if(increasing)
//		{
//			next_y = next_y + 100;
//		}
//		else
//		{
//			next_y = next_y - 100;
//		}
//		
////		current_pos[0] = current_pos[0];
////		current_pos[1] = next_y;
////		current_pos[2] = current_pos[2];
//		target.origin = (current_pos[0], next_y, current_pos[2]);
//		
//		if(next_y < -10300)
//		{
//			increasing = true;
//		}
//		
//		if(next_y > -9800)
//		{
//			increasing = false;	
//		}
//		
////		IPrintLn("target pos: " + target.origin[0] + " " + target.origin[1] + " " + target.origin[2]);
//			
//		wait(.2);
//	}
//}

//MM not used
//mg_player_if_too_close()
//{
//	self endon("death");
//	while(1)
//	{
//
//		if(Distance2D(level.player.origin, self.origin) < 500)
//		{
//			self.mgturret[0] SetConvergenceTime(0.0);
//			self SetTurretTargetEnt(level.player);
//			self mgon();
//			
////			turret_origin = level.enemy_tank_2.mgturret[0] GetTagOrigin("tag_flash");
////			//hit player all the time
////			fire_at_target(turret_origin, level.player.origin + (0,0, 20), false);
//		}
//		else
//		{
//			if(Distance2D(level.player.origin, self.origin) < 700)
//			{
//				self.mgturret[0] SetConvergenceTime(5.0);
//				self SetTurretTargetEnt(level.player);
//				self mgon();
//				
////				turret_origin = level.enemy_tank_2.mgturret[0] GetTagOrigin("tag_flash");
////				//hit player some of the time
////				fire_at_target(turret_origin, level.player.origin + (0,0, 20), true);
//			}	
//		}
//		wait(.1);
//	}
//}

kill_ally_in_volume(volume)
{
	ally_array = GetAIArray("allies");
	foreach ( ally in ally_array)
	{
		if(ally istouching(volume))
		{
			if(!is_in_array(level.allies,ally))
			{
				if(IsDefined( ally.magic_bullet_shield ) && ally.magic_bullet_shield)
				{
					ally stop_magic_bullet_shield();
				}
				ally kill();
			}
		}
	}
	
}

//turn_off_chokepoints_for_allies()
//{
//	while(!flag("enemy_alerted"))
//	{
//		trigger = getent("parking_garage_doorway", "targetname");
//		trigger waittill("trigger", guy);
//		
//		guy.usechokepoints = false;
//	}
//}

//turn_on_chokepoints_for_allies()
//{
//	trigger = getent("parking_garage_doorway", "targetname");
//	trigger waittill("trigger", guy);
//		
//	ally_array = GetAIArray("allies");
//	foreach(ally in ally_array)
//	{
//		ally.usechokepoints	= true;
//	}
//}

//ally_heat_behavior(turn_on, shoot_while_moving)
//{
//	if(turn_on)
//	{
//		if(isdefined(shoot_while_moving) && shoot_while_moving)
//		{
////			level.allies[0] enable_heat_behavior(shoot_while_moving);
////			level.allies[1] enable_heat_behavior(shoot_while_moving);
////			level.allies[2] enable_heat_behavior(shoot_while_moving);
//			level.allies[0] run_faster_behavior(true);
//			level.allies[1] run_faster_behavior(true);
//			level.allies[2] run_faster_behavior(true);
//		}
//		else
//		{
////			level.allies[0] enable_heat_behavior();
////			level.allies[1] enable_heat_behavior();
////			level.allies[2] enable_heat_behavior();
//			level.allies[0] run_faster_behavior(true);
//			level.allies[1] run_faster_behavior(true);
//			level.allies[2] run_faster_behavior(true);
//		}
//	}
//	else
//	{
////		level.allies[0] disable_heat_behavior();
////		level.allies[1] disable_heat_behavior();
////		level.allies[2] disable_heat_behavior();
//		level.allies[0] run_faster_behavior(false);
//		level.allies[1] run_faster_behavior(false);
//		level.allies[2] run_faster_behavior(false);
//	}
//}

//MM Not used
run_faster_behavior(turn_on)
{
	if(turn_on)
	{
	    self.animplaybackrate = 1.2;        // Set randomly between 0.9 and 1.1 by default. How fast the actor plays certain animations, including idles and some transitions.
	    self.moveplaybackrate  = 1.2; // Speed at which movement anims are played back. 1.0 is normal speed.
	    self.movetransitionrate  = 1.2;               // Actor enters and exits cover at this speed. Defaults to a random value between 0.9 and 1.1 to keep actors from being synched.
	}
	else
	{
		self.animplaybackrate = RandomFloatRange(.9, 1.1);       
	    self.moveplaybackrate  = 1.0; 
	    self.movetransitionrate  = RandomFloatRange(.9, 1.1);
	}
}

//parking_garage_script()
//{
//	trigger = getent("into_parking_garage", "targetname");
//	trigger waittill("trigger");
//	
//	thread add_dialogue_line("Baker", "Up here!");
//}

//while player is touching "player_in_open"
//
converge_on_target(tracking_target, move_to_target, vel)
{
	self endon("new_converge");
	
	self ClearTargetEntity();
	self SetTargetEntity(tracking_target);
	
	while(1)
	{
//		IPrintLn("converge on target: " + vel);
		distance = Distance2D(move_to_target.origin, tracking_target.origin);
		if(distance < 0)
		{
			distance = abs(distance);
		}
		if(distance == 0)
		{
			distance = 1;
		}
		new_timer = distance/vel;
//		IPrintLn("new timer: " + new_timer);
//		IPrintLn("tracking_target origin: " + tracking_target.origin[0] + " , " + tracking_target.origin[1] + " , " + tracking_target.origin[2]);
		tracking_target MoveTo(move_to_target.origin + (0,0,16), new_timer);
		wait(.1);
	}	
}

//converge_on_target_new(max_x, max_y, timer)
//{
//	self endon("new_converge");
//	
//	self ClearTargetEntity();
//	
//	tracking_target = getent("enemy_tank_2_tracking_target", "targetname");
//	self SetTargetEntity(tracking_target);
////	tracking_target MoveTo(level.player.origin, timer);
////	distance = Distance2D(level.player.origin, tracking_target.origin);
////	vel = distance/timer;
//	x_change = max_x/timer*.1;
//	y_change = max_y/timer*.1;
//	
//	while(1)
//	{
////		IPrintLn("converge on target: " + vel);
//		tracking_target.origin = level.player.origin;
//		
//		rand_x = RandomFloatRange((max_x*1.25*-1), max_x);
//		rand_y = RandomFloatRange((max_y*.25*-1), max_y*1.25);
////		if(rand_y > -32 && rand_y < 64)
////		{
////			rand_y = 64;	
////		}
//		rand_z = RandomFloatRange(0, 32);
////		rand_x = 1;
////		rand_y = 256;
////		rand_z = 1;
//		
//		
//		tracking_target.origin = tracking_target.origin + (rand_x, rand_y, rand_z);
//		
////		IPrintLn("rand_y: " + rand_y);
////		IPrintLn("tracking_target origin: " + tracking_target.origin[0] + " , " + tracking_target.origin[1] + " , " + tracking_target.origin[2]);
//
//		if(max_x > x_change)
//		{
//			max_x = max_x - x_change;
//		}
//		
//		if(max_y > y_change)
//		{
//			max_y = max_y - y_change;
//		}
//		wait(.1);		
//	}
//	
//}

////make tank turret fire machine gun at a spot
////"shoot_at_this": ent to fire turret at
////"number": <optional> number of shots before stopping
//fire_fake_mg_at_target(shoot_at_this, number)
//{
//	self endon("stop_firing");
//	self endon("death");
//	level endon("end_of_streets_to_dam");
//	if(!isdefined(number))
//	{
//		number = 10000;	
//	}
//
//	while(isdefined(shoot_at_this) && number>0)
//	{
//		if(isdefined(self))
//		{
////			self setturrettargetvec( shoot_at_this.origin );
////			self waittill( "turret_on_target" );
////		//	IPrintLn("tank turret on target");
////			self FireWeapon();	
////			turret_origin = self GetTagOrigin("tag_turret");
//
//			//hit player
//			
////			self thread turret_fire_at_target("tag_turret", shoot_at_this, true, level.player,"50cal_turret_ugv");
////			self thread turret_fire_at_target("tag_turret", shoot_at_this, true, level.player,"50cal_turret_technical");
//		}
//		number--;
//		if(number>0)
//		{
//			wait(.5);
//		}
//	}
//}

fire_turret(burst_fire)
{
	self endon("stop_firing");
	self endon("death");
	
	min_burst = 5;
	max_burst = 15;
	wait_time = 1.0;
	new_burst = true;
	burst = 5;
	counter = 0;
	
	self StartFiring();
//	self SetConvergenceTime(5.0);
	while(1)
	{
		if(burst_fire)
		{
			if(new_burst)
			{
				burst = RandomFloatRange(min_burst, max_burst);
				counter = 0;
				new_burst = false;
			}
			if(counter >= burst)
			{
				new_burst = true;
				wait(RandomFloat(wait_time));
			}
		}
//		IPrintLn("shooting turret");
		self ShootTurret();
		counter = counter + 1;
		wait(.1);
	}
}

//mg_continuous_fire()
//{
//	self endon("death");
//	self.mgturret[0] StartFiring();
//}

player_forward_skip_baker_hold_up()
{
//	trigger = Getent( "spawn_scaffold_guys_trigger", "targetname" );
	trigger = Getent( "hold_up_check", "targetname" );
	
	trigger waittill( "trigger");
	
	flag_set("player_move_up");
}

//fire at allied tank
//move forward slowly till in gap
//stop and shoot at allied tank, or random spot on ground
//get killed

set_group_goalvolume( volume_targetname )
{
    enemies = self;
    goal_volume = GetEnt( volume_targetname, "targetname" );
    
    foreach( enemy in enemies )
    {
        enemy ClearGoalVolume();
        enemy SetGoalVolumeAuto( goal_volume );
    }
}
//

// fires m16 rounds from bullet origin to bullet target
// spray <optional> - set to true to allow random offsets from target
// dont_hit_player <optional> - pass in ent or array to make sure bullets don't hit them
// weapon_override <optional> - use a weapon other than current player equipped weapon
// update <optional> - update the firing position and target for each shot, requires ents or stucts to passed in
fire_at_target(bullet_origin, bullet_target, spray, dont_hit_player, weapon_override, update)
{
	level endon("stop_the_shooting");
    // Bounds for random numbers
//    startOffsetMin = 128;
//    startOffsetMax = 256;
 
    endOffsetMin = 0;
    endOffsetMax = 64;
 
    shotWaitMin = 0.08;
    shotWaitMax = 0.11;
 
    burstWaitMin = 0.5;
    burstWaitMax = 1;
 
    shotsMin = 9;
    shotsMax = 15;

    numShots = RandomIntRange( shotsMin, shotsMax );

    for( i = 0; i < numShots; i++ )
    {
    	if(isdefined(update) && update)
    	{
    		// Assuming ents or structs have been passed in...
	        startPos = bullet_origin.origin;
			groundRefPoint = bullet_target.origin;
    	}
    	else
    	{
	        // Assuming vectors have been passed in...
	        startPos = bullet_origin;
			groundRefPoint = bullet_target;
    	}
    	bad_hit = false;
    	
        if(IsDefined(spray) && spray)
        {
            endX = groundRefPoint[ 0 ] + RandomIntRange(endOffsetMin, endOffsetMax );
            endY = groundRefPoint[ 1 ] + RandomIntRange(endOffsetMin, endOffsetMax );
            endZ = groundRefPoint[ 2 ] + RandomIntRange(endOffsetMin, endOffsetMax )/2;
        }
        else
        {
            endX = groundRefPoint[ 0 ];
            endY = groundRefPoint[ 1 ];
            endZ = groundRefPoint[ 2 ];
        }
        endPos = (endX, endY, endZ);
        
        if(isdefined(dont_hit_player))
        {
        	if(!IsArray(dont_hit_player))
        	{
        		dont_hit_player = make_array(dont_hit_player);
        	}
	        // Make sure we're not going to hit the player(or whatever we passed in)
	        trace = BulletTrace( startPos, endPos, true );
	        traceEnt = trace[ "entity" ];
	
	        if( IsDefined( traceEnt ) )
	        {
	        	for ( i = 0; i < dont_hit_player.size; i++ )
	        	{
	        		if(traceEnt == dont_hit_player[i])
	        		{
	        			bad_hit = true;	
//	        			Println("hitting someone we don't want to!");
	        		}
	        	}
	        	
	            if( bad_hit )
	            {
	                continue;
	            }
	        }
        }

        if(bad_hit)
        {
//       		Println("Shooting anyway!");
        }
        
        if(IsDefined(weapon_override))
        {
        	MagicBullet( weapon_override, startPos, endPos ); 
        }
        else
        {        
	        // It's safe to fire the bullet (using player's weapon to be safe until all weapons are settled)
	        weap = level.player GetCurrentWeapon();
	        if(isdefined(weap) && weap != "none")
	        {
	        	MagicBullet( weap, startPos, endPos );   	
	        }
        }

        wait( RandomFloatRange( shotWaitMin, shotWaitMax ) );
    }
    wait( RandomFloatRange( burstWaitMin, burstWaitMax ) );

}

// fires m16 rounds from self at bullet_origin_tag to bullet target object
// spray <optional> - set to true to allow random offsets from target
// dont_hit_player <optional> - pass in ent or array to make sure bullets don't hit them
// weapon_override <optional> - use a weapon other than current player equipped weapon
turret_fire_at_target(bullet_origin_tag, bullet_target, spray, dont_hit_player, weapon_override)
{
	level endon("stop_the_shooting");
    // Bounds for random numbers
//    startOffsetMin = 128;
//    startOffsetMax = 256;
 
    endOffsetMin = 0;
    endOffsetMax = 64;
 
    shotWaitMin = 0.08;
    shotWaitMax = 0.11;
 
    burstWaitMin = 0.5;
    burstWaitMax = 1;
 
    shotsMin = 9;
    shotsMax = 15;

    numShots = RandomIntRange( shotsMin, shotsMax );

    for( i = 0; i < numShots; i++ )
    {
		// Assuming ents or structs have been passed in...
//        startPos = bullet_origin.origin;
        startPos = self GetTagOrigin(bullet_origin_tag);
		groundRefPoint = bullet_target.origin;

    	bad_hit = false;
    	
        if(IsDefined(spray) && spray)
        {
            endX = groundRefPoint[ 0 ] + RandomIntRange(endOffsetMin, endOffsetMax );
            endY = groundRefPoint[ 1 ] + RandomIntRange(endOffsetMin, endOffsetMax );
            endZ = groundRefPoint[ 2 ] + RandomIntRange(endOffsetMin, endOffsetMax )/2;
        }
        else
        {
            endX = groundRefPoint[ 0 ];
            endY = groundRefPoint[ 1 ];
            endZ = groundRefPoint[ 2 ];
        }
        endPos = (endX, endY, endZ);
        
        if(isdefined(dont_hit_player))
        {
        	if(!IsArray(dont_hit_player))
        	{
        		dont_hit_player = make_array(dont_hit_player);
        	}
	        // Make sure we're not going to hit the player(or whatever we passed in)
	        trace = BulletTrace( startPos, endPos, true );
	        traceEnt = trace[ "entity" ];
	
	        if( IsDefined( traceEnt ) )
	        {
	        	for ( i = 0; i < dont_hit_player.size; i++ )
	        	{
	        		if(traceEnt == dont_hit_player[i])
	        		{
	        			bad_hit = true;	
//	        			Println("hitting someone we don't want to!");
	        		}
	        	}
	        	
	            if( bad_hit )
	            {
	                continue;
	            }
	        }
        }

        if(bad_hit)
        {
//       		Println("Shooting anyway!");
        }
        
        if(IsDefined(weapon_override))
        {
        	MagicBullet( weapon_override, startPos, endPos ); 
        }
        else
        {        
	        // It's safe to fire the bullet (using player's weapon to be safe until all weapons are settled)
	        weap = level.player GetCurrentWeapon();
	        if(isdefined(weap) && weap != "none")
	        {
	        	MagicBullet( weap, startPos, endPos );   	
	        }
        }

        wait( RandomFloatRange( shotWaitMin, shotWaitMax ) );
    }
    wait( RandomFloatRange( burstWaitMin, burstWaitMax ) );

}

//start_enemy_retreat()
//{
//    level thread enemy_retreat_check_1();
//}
//
//enemy_retreat_check_1()
//{
//    trigger = getent("start_aim_missiles", "targetname");
//    trigger waittill("trigger");
//    
//    flag_set("retreat_started");
//}

set_goal_volume(goal_volume)
{
	self SetGoalVolumeAuto(goal_volume);
}

/*
smart_radio_dialogue( dialogue, timeout )
smart_radio_dialogue_interrupt( dialogue )
smart_dialogue( dialogue )
smart_dialogue_generic( dialogue )
*/


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_to_dam_start()
{
//	trigger = getent("flooding_ext_start_trig", "targetname");
//	trigger trigger_off();
	level.street_start_allies = [];
	maps\flood_util::player_move_to_checkpoint_start( "streets_to_dam_start" );
    
    //set_audio_zone( "flood_streets", 2 );    
    
    // spawn the allies
    maps\flood_util::spawn_allies();
    
//    level thread setup_allies_streets_to_dam();
    level thread enter_garage();
	level thread garage_opening_collapse();
    level thread aim_missiles_2();
    level thread hide_missile_launcher_collision();
    level thread hide_garage_debris();
    level thread maps\flood_infil::kill_player_past_tank();
//    level thread streets_crash_blackhawk();
    
//	level.allies[0] thread maps\flood_infil::baker_hold_up();
//    trigger = getent("streets_to_dam_autosave", "targetname");
//    trigger notify("trigger");
//
//    trigger = getent("streets_to_dam_rpg_spawn", "targetname");
//    trigger notify("trigger");        

//    flag_set("start_aiming");
	level thread hide_spire();
	level thread init_turn_off_lean_volumes();
	
	flag_set("everyone_in_garage");
	
	SetSavedDvar("sm_sunSampleSizeNear", .25);
}

streets_to_dam()
{
//	level thread autosave_now();
	
//	maps\_stealth::main();
//	maps\_patrol_anims::main();
//	level thread enter_garage();
//	level thread garage_opening_collapse();
	level thread adjust_ally_movement();
	level thread convoy_think();
	level thread streets_to_dam_sequence();
	level thread streets_to_dam_wave_1_init();
	level thread streets_to_dam_drive_missile_launcher();
	level thread wait_for_player_to_use_ladder();
//	level thread streets_to_dam_wave_2_sequence();
	level thread spawn_rpg_guys();
//	level thread magic_rpg_attack();
	level thread dialogue_streets_to_dam();
	level thread make_allies_shoot_at_targets();
//	level thread streets_to_dam_heli_flyover();	// heli flyover removed by JKU per Nics request
//	level thread turn_on_chokepoints_for_allies();
	level thread disable_combat_nodes();
	level thread disable_ally_nag_nodes();
	level thread hide_unhide_crashed_convoy(true);
//	level thread set_m880_flag();
	level thread convoy_kill_player();
	level thread block_garage_exit();
	level thread garage_autosave_before_heli_attack();
	level thread rotate_checkpoint_concrete_barrier_when_near_m880(210);
	level thread maps\flood_infil::nh90_convoy_choppers();
	
	level thread m880_open_path_init();
	level thread m880_connect_path_nodes(false);
	level thread maps\flood_anim::m880_crash_anim_init();
	level thread m880_kill_collision_change();
	exploder( "dam_pre_waterfall" );
//	level thread display_player_speed();
	
	flag_wait("player_on_ladder");
	wait(2.0);
	level thread streets_to_dam_2_side_guys_spawn_logic();
	
	trigger = getent("streets_to_dam_wave_2_start", "targetname");
    trigger waittill("trigger");
    
    level notify("end_of_streets_to_dam");
}

// FIX JKU definited need to come back and remove this
enter_garage()
{
	trigger = getent("into_parking_garage", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");	
	}
	if(IsDefined(level.enemy_tank_3))
	{
		level.enemy_tank_3 notify("stop_firing");
		level notify("stop_shooting_player");
		level.enemy_tank_3 mgoff();
		
		garage_target = getent("enemy_tank_2_garage_target", "targetname" );
		level.enemy_tank_3 setturrettargetvec( garage_target.origin );	
		trigger = getent("parking_garage_doorway", "targetname");
//		trigger = getent("player_far_enough_in_garage", "targetname");		
		if(isdefined(trigger))
		{
//			trigger waittill_notify_or_timeout("trigger", 1.0);
			trigger waittill("trigger");
		}
	
		wait(.5);
		level thread turret_too_slow_failsafe();
		level.player EnableInvulnerability();
		level.enemy_tank_3 maps\flood_infil::fire_cannon_at_target(garage_target, 1);
//		level.player stop_magic_bullet_shield();
	}
	else
	{
		wait(1.0);
	}
	level notify("firing_garage_shot");
	
	wait(1.0);
	level.player DisableInvulnerability();
	wait(1.0);
//	level.allies[0] thread smart_dialogue( "flood_bkr_uphere" );	
}

turret_too_slow_failsafe()
{
	level endon("firing_garage_shot");
	
	trigger = getent("player_far_enough_in_garage", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
	level.enemy_tank_3 FireWeapon();
	level notify("firing_garage_shot");
	
}

garage_opening_collapse()
{
	
    level waittill("firing_garage_shot");
    
    thread maps\flood_audio::sfx_parking_lot_explode();

//    wait(1.0);
    
//    fx_ent = SpawnFx(level._effect[ "tank_concrete_explosion" ], fx_pos.origin);
	PlayFx(level._effect[ "tank_concrete_explosion_omni" ], level.player.origin + (0,0,12), (0,90,0));
	PlayFx(level._effect[ "tank_concrete_explosion_omni" ], level.player.origin + (0,0,12));
	PlayFx(level._effect[ "garage_explosion_flash" ], level.player.origin);
	level.player PlayRumbleOnEntity("heavy_2s");
	exploder( "garage_dust" );
	
//    flood_infil_tank_hit
//    fx/explosions/tank_concrete_explosion
//	level.player ShellShock("default", 3);
	level thread player_vision_blind();
	level.player ShellShock( "default_nosound", 3 );
	level thread slow_player_down(4);
	
	//don't let player see the debris spawn
	make_player_look_away("garage_collapse_back_look_check", (45,0,0), .15, false);
	thread show_garage_debris();
	volume = getent("garage_collapse_push_volume", "targetname");
	vector = (-40, 40, 0);
	push_player_out_of_volume(volume, vector);
	//if player is still looking at ally teleport spots, make him look away	
	make_player_look_away("garage_collapse_side_look_check", (0,90,0), .15, false);
		
	volume = getent("inside_garage_volume", "targetname");

	ally_teleport_index[0] = getent("streets_to_dam_ally_0_failsafe", "targetname");
	ally_teleport_index[1] = getent("streets_to_dam_ally_1_failsafe", "targetname");
	ally_teleport_index[2] = getent("streets_to_dam_ally_2_failsafe", "targetname");
	
	for ( i = 0; i < level.allies.size; i++ )
	{
		if(!(level.allies[i] IsTouching(volume)))
		{
			spot = ally_teleport_index[i];
			level.allies[i] ForceTeleport(spot.origin, spot.angles);
		}
	}	
		
	flag_set("everyone_in_garage");
	
	wait(.1);
	level thread autosave_now();
}

push_player_out_of_volume(volume, vector)
{
	while(level.player istouching(volume))
	{
		level.player PushPlayerVector(vector, true);
				
		waitframe();
	}
	level.player PushPlayerVector((0, 0, 0));
}

//old version
//garage_opening_collapse()
//{
//	
//    level waittill("firing_garage_shot");
////    wait(1.0);
//    
////    fx_ent = SpawnFx(level._effect[ "tank_concrete_explosion" ], fx_pos.origin);
//	PlayFx(level._effect[ "tank_concrete_explosion_omni" ], level.player.origin + (0,0,12), (0,90,0));
//	PlayFx(level._effect[ "tank_concrete_explosion_omni" ], level.player.origin + (0,0,12));
//	PlayFx(level._effect[ "garage_explosion_flash" ], level.player.origin);
//	level.player PlayRumbleOnEntity("heavy_2s");
//	
////    flood_infil_tank_hit
////    fx/explosions/tank_concrete_explosion
////	level.player ShellShock("default", 3);
//	level thread player_vision_blind();
//	level.player ShellShock( "default_nosound", 3 );
//	level thread slow_player_down(4);
//	
//	//(45,0,0)
//	make_player_look_away("enemy_tank_2_garage_target", (45,0,0), .15, false);
//	show_garage_debris();
//		
//	loc_array = getentarray("garage_teleport_spot", "script_noteworthy");
//	
//	//check if allies are in garage
//	//if not teleport them to safe space
//	//if no space for them, turn player
//	//and then teleport allies to safe space
//	
//	volume = getent("inside_garage_volume", "targetname");
//	allies_to_teleport = [];
//	for ( i = 0; i < level.allies.size; i++ )
//	{
//		if(!(level.allies[i] IsTouching(volume)))
//		{
//			allies_to_teleport = add_to_array(allies_to_teleport, level.allies[i]);
////			IPrintLn("found someone who needs teleportin");
//		}
//	
//	}
//	
//	doorway_origin = getent("streets_to_dam_start", "targetname");
//	loc_array = get_array_of_closest(doorway_origin.origin, loc_array);
//	
//	ally_teleport_index = [];
//	teleport_index = 0;
//	//find_teleport_spots_for_allies(loc_array);
//	for ( i = 0; i < allies_to_teleport.size; i++ )
//	{
//		teleport_index = find_teleport_spot_for_ally(loc_array, teleport_index);
//		if(teleport_index == -1)
//		{
//			break;
//		}
//		else
//		{
//			ally_teleport_index[i] = loc_array[teleport_index];
//			teleport_index++;
//		}
//	}
//	
//	//couldn't find spots for everyone so make player look away
//	if(teleport_index == -1)
//	{
//		make_player_look_away("ally_0_garage_teleport_0", (0,90,0), .15, true);
//	
//	
//		teleport_index = 0;
//		for ( i = 0; i < allies_to_teleport.size; i++ )
//		{
//			teleport_index = find_teleport_spot_for_ally(loc_array, teleport_index);
//			if(teleport_index == -1)
//			{
//				break;
//			}
//			else
//			{
//				ally_teleport_index[i] = loc_array[teleport_index];
//				teleport_index++;
//			}
//		}
//		
//		if(teleport_index == -1)
//		{
//			//this shouldn't happen.  If it does, make sure we don't break the game.
//			//might not be all three, but just in case...
//			ally_teleport_index[0] = getent("streets_to_dam_ally_0_failsafe", "targetname");
//			ally_teleport_index[1] = getent("streets_to_dam_ally_1_failsafe", "targetname");
//			ally_teleport_index[2] = getent("streets_to_dam_ally_2_failsafe", "targetname");
//			
//			for ( i = 0; i < allies_to_teleport.size; i++ )
//			{
//				spot = ally_teleport_index[i];
//				allies_to_teleport[i] ForceTeleport(spot.origin, spot.angles);
//			}
//			
//			allies_to_teleport = [];
//		}
//	}
//	
//	for ( i = 0; i < allies_to_teleport.size; i++ )
//	{
//		spot = ally_teleport_index[i];
//		allies_to_teleport[i] ForceTeleport(spot.origin, spot.angles);
//	}
//
//	flag_set("everyone_in_garage");
//	
//	wait(.1);
////	level thread autosave_now();
//}

//find a spot in the loc array, starting at teleport index,
find_teleport_spot_for_ally(loc_array, teleport_index)
{
	while(teleport_index < loc_array.size)
	{
		loc = loc_array[teleport_index];
		if(isdefined(loc))
		{
			if(Distance2D(level.player.origin, loc.origin) > 32)
			{
				if(!player_looking_at(loc.origin + (0,0,16), 0.5, true))
				{
//					iprintln(teleport_index + " was used for teleport");
					return teleport_index;
				}
				else
				{
//					iprintln("index "+ teleport_index + " was being looked at by player");	
				}
			}
			else
			{
//				iprintln("index "+ teleport_index + "was too close to player");
			}
		}
		else
		{
//			IPrintLn(loc_array[teleport_index] + " was not defined");	
		}
		teleport_index++;
	}

	return(-1);
}

player_vision_blind()
{
	currVis = getdvar("vision_set_current");
	visionsetnaked("generic_flash",.2);
	wait(.1);
	visionsetnaked(currVis,.2);	
}

//find_teleport_spots_for_allies(teleport_spot_names_array)
//{
//	safe_teleport_array = [];
//	teleport_index = 0;
//	
//	volume = getent("inside_garage_volume", "targetname");
//	for ( i = 0; i < level.allies.size; i++ )
//	{
//		if(level.allies[i] IsTouching(volume))
//		{
//			safe_teleport_array[i] = "no_teleport";
////			iprintln("no teleport for ally "+ i );
////			index++;
//		}
//		else
//		{
//			while(teleport_index < teleport_spot_names_array.size)
//			{
//				loc = getstruct(teleport_spot_names_array[teleport_index], "targetname");
//				if(isdefined(loc))
//				{
//					if(Distance2D(level.player.origin, loc.origin) > 48)
//					{
//						if(!player_looking_at(loc.origin + (0,0,16)))
//						{
//							safe_teleport_array[i] = teleport_spot_names_array[teleport_index];
//							teleport_index++;
////							iprintln(teleport_spot_names_array[teleport_index] + " was used for teleport");
//							break;
//						}
//						else
//						{
////								iprintln("index "+ teleport_index + " was being looked at by player");	
//						}
//					}
//					else
//					{
////							iprintln("index "+ teleport_index + "was too close to player");
//					}
//				}
//				else
//				{
////						IPrintLn(teleport_spot_names_array[teleport_index] + " was not defined");	
//				}
//				teleport_index++;
//			}
//			
//		}
//	}
//	
//	everyone = true;
//	
//	for ( i = 0; i < level.allies.size; i++ )
//	{	
//		if(!IsDefined(safe_teleport_array[i]))
//		{
//			everyone = false;
//		}
//	}
//	
////	foreach(entry in safe_teleport_array)
////	{
////		if(!IsDefined(entry))
////		{
////			everyone = false;
////		}
////	}
//	
//	if(everyone)
//	{
//		return safe_teleport_array;
//	}
//	else
//	{	
//		safe_teleport_array = [];
//		return safe_teleport_array;
//	}
//		
//}

make_player_look_away(targetname_string, rotate_angles, lerptime, always_look_away)
{
//	IPrintLn("make_player_look_away");
	fx_pos_array = getentarray(targetname_string, "targetname");
	lookaway = false;
	foreach ( fx_pos in fx_pos_array)
	{
		if(player_looking_at(fx_pos.origin))
		{
			lookaway = true;	
		}
	}	

	if(always_look_away || lookaway)
	{	
//		level thread push_player_around(20);
		linker = Spawn( "script_origin", ( 0, 0, 0 ) );
		linker.origin = level.player.origin;
		linker.angles = level.player GetPlayerAngles();
				
//		IPrintLn("player angles: " + level.player.angles[0] + "," + level.player.angles[1] + "," + level.player.angles[2]);
//		IPrintLn("linker angles: " + linker.angles[0] + "," + linker.angles[1] + "," + linker.angles[2]);
		level.player PlayerLinkTo( linker, "", 1.0 );
//		lerptime = .25;
		linker RotateTo( rotate_angles, lerptime, lerptime * 0.25 );
		wait( lerptime/2 );
	//	IPrintLn("player angles: " + level.player.angles[0] + "," + level.player.angles[1] + "," + level.player.angles[2]);
		wait( lerptime/2 );
	//	IPrintLn("player angles: " + level.player.angles[0] + "," + level.player.angles[1] + "," + level.player.angles[2]);
		linker Delete();
	//	fx_ent delete();
	}
	
}

slow_player_down(timer)
{
	level.player SetMoveSpeedScale(.5);
	wait(timer);
	level.player SetMoveSpeedScale(.75);
	wait(timer/2);
	level.player SetMoveSpeedScale(1.0);
}

hide_garage_debris()
{
	garage_debris_array = getentarray("garage_debris", "targetname");
	
	for ( i = 0; i < garage_debris_array.size; i++ )
	{
		garage_debris_array[i] hide();
		garage_debris_array[i] NotSolid();
	}	
	
	wait(1.0);
	
	garage_opening_path_node_array = getnodearray("garage_opening_path_node", "targetname");
	
	for ( i = 0; i < garage_opening_path_node_array.size; i++ )
	{
		garage_opening_path_node_array[i] ConnectNode();
	}
	
}

show_garage_debris()
{
	wait(.5);
	garage_debris_array = getentarray("garage_debris", "targetname");
	garage_debris_origin_array = getentarray("garage_debris_origin", "targetname");
	for ( i = 0; i < garage_debris_array.size; i++ )
	{
//		garage_debris_array[i].origin = garage_debris_origin_array[i].origin;
//		garage_debris_array[i].angles = garage_debris_origin_array[i].angles;
		if(level.player IsTouching(garage_debris_array[i]))
		{
			garage_debris_array[i] maps\flood_anim::push_player_out_of_brush((0,40,0));
		}
		
		garage_debris_array[i] show();
		garage_debris_array[i] Solid();
	}
	
}

//move_allies_into_position(teleport_spots)
//{
//	wait(.25);
//	
////	volume = getent("inside_garage_volume", "targetname");
//	
//	for( i=0 ; i<level.allies.size; i++)
//	{
//		if(teleport_spots[i] != "no_teleport")
//		{
//			spot = getstruct(teleport_spots[i], "targetname");
//			level.allies[i] ForceTeleport(spot.origin, spot.angles);
//		}
//	}
//	
//}

adjust_ally_movement()
{
	
	//put vargas on his own color set for garage
	level.allies[1] set_force_color("p");
	
	foreach ( guy in level.allies)
	{
		guy ignore_everything(0.0);
	}
	
	//if we need to keep them from going to the first set of exposed nodes cause it looks bad, comment out this line
	flag_wait("everyone_in_garage");
	
//	wait(.5);
	
	level thread set_flag_when_player_ready_to_progress("player_ready_to_progress");
	flag_wait("player_ready_to_progress");
	
//	IPrintLn("setting ally path node goals");
	
	goal_node = GetNode("ally_garage_path_0", "targetname");
	level.allies[0] thread follow_path(goal_node, 650);
	goal_node = GetNode("ally_garage_path_1", "targetname");
	level.allies[1] thread follow_path(goal_node, 650);
	goal_node = GetNode("ally_garage_path_2", "targetname");
	level.allies[2] thread follow_path(goal_node, 650);
	
	flag_wait("everyone_in_garage");
	
	wait(1.0);
	
	//quack
	ducks = [];
	ducks[ ducks.size ] = "run_stumble";
	ducks[ ducks.size ] = "run_flinch";
	ducks[ ducks.size ] = "run_duck";
	
//	iprintln("stumblin!");
	
	foreach ( index, guy in level.allies )
	{
		guy thread stumble_anim( ducks[ index ] );
		wait(RandomFloat(.5));
	}
	
	playback_rates = [];
	
	for ( i = 0; i < level.allies.size; i++ )
	{
		level.allies[i] PushPlayer(true);
		playback_rates[i] = level.allies[i].moveplaybackrate;
		
		level.allies[i] enable_cqbwalk();
//		rate = 1.00 - i*.05;
//		level.allies[i] set_moveplaybackrate(rate);
	}
	
	level thread turn_off_cqb_if_player_too_far_forward();
	
	wait(5);
	
	for ( i = 0; i < level.allies.size; i++ )
	{
		level.allies[i] PushPlayer(false);
	}
	
	trigger = getent("baker_hold_up", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
	
	level notify("stop_distance_check");
	
	for ( i = 0; i < level.allies.size; i++ )
	{
		level.allies[i] disable_cqbwalk();
		level.allies[i] disable_sprint();
		level.allies[i] set_moveplaybackrate(playback_rates[i]);
	}

//re-add to put baker on his own color for garage	
	flag_wait("player_on_ladder");

	level.allies[1] set_force_color("r");	
}

set_flag_when_player_ready_to_progress(flag_to_set)
{
//	foreach ( guy in level.allies)
//	{
//		guy thread garage_progress_look_at_test(flag_to_set);	
//	}
	
	trigger = getent("player_far_enough_in_garage", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
	
	flag_set(flag_to_set);	
}

garage_progress_look_at_test(flag_to_set)
{
	self waittill_player_lookat_for_time(1.5);
	
	flag_set(flag_to_set);
}

stumble_anim( animation )
{
    animation = getgenericanim( animation );
    self.run_overrideanim = animation;
    self SetFlaggedAnimKnob( "stumble_run", animation, 1, 0.2, 1, true );
    wait( 1.5 );
    
    run_root = getgenericanim( "run_root" );
    old_time = 0;
    for ( ;; )
    {
        if ( self getAnimTime( run_root ) < old_time )
            break;
        old_time = self getAnimTime( run_root );
            
        wait( 0.05 );
    }
    self.run_overrideanim = undefined;
    self notify( "movemode" );
}

turn_off_cqb_if_player_too_far_forward(position_ent_string)
{
	level endon("stop_distance_check");

//	wait(2.0);
	
	trigger = getent("streets_to_dam_autosave", "targetname");
	if(IsDefined(trigger))
	{
		trigger waittill("trigger");
	}
	//change for lack of new bsp...
	
//	target_pos = getent("streets_to_dam_hold_up", "script_noteworthy");
	target_pos = getent("garage_hallway_position_check", "targetname");
	keep_checking = true;
	while(keep_checking)
	{
		keep_checking = false;
		player_dist = Distance2D(level.player.origin, target_pos.origin);
		player_dist = player_dist - 50;
		
		foreach ( guy in level.allies)
		{
			dist = Distance2d(guy.origin, target_pos.origin);
			if(dist < player_dist)
			{
				keep_checking = true;
			}
		}
		
		wait(.1);
	}
	
//	IPrintLn("stop cqb!");
	
	foreach ( guy in level.allies)
	{
		guy disable_cqbwalk();
	}
	
}

//garage_teleport_ai(target_name_array, volume)
//{
//	new_pos = undefined;
////	teleport_locations = [];
//	if(!(self istouching(volume)))
//	{
//		//pick one player isn't looking at or is too close to
//		for ( i = 0; i < target_name_array.size; i++ )
//		{
////			IPrintLn("checking " + target_name_array[i]);
//			loc = getstruct(target_name_array[i], "targetname");
//			if(isdefined(loc))
//			{
//				if(Distance2D(level.player.origin, loc.origin) > 16)
//				{
//					if(!player_looking_at(loc.origin))
//					{
//						new_pos = loc;
////						iprintln(target_name_array[i] + " was used for teleport");
//						break;	
//					}
//					else
//					{
////						iprintln("index "+ i + " was being looked at by player");	
//					}
//				}
//				else
//				{
////					iprintln("index "+ i + "was too close to player");
//				}
//			}
//			else
//			{
////				IPrintLn(target_name_array[i] + " was not defined");	
//			}
//		}
//			
//		//teleport ai there
//		if(IsDefined(new_pos))
//		{
////		new_pos = getstruct(target_name, "targetname");
//			self ForceTeleport(new_pos.origin, new_pos.angles);
//		}
//		else
//		{
////			iprintln("no teleport locations found");
//		}
//	}
//}

//baker_hold_up()
//{
////	self disable_heat_behavior();
////	self enable_cqbwalk(true);
//	
////	not_baker = true;
//	not_baker = false;
//	while(not_baker)
//	{
//		trigger = Getent( "baker_hold_up", "targetname" );
//		trigger waittill( "trigger", guy);
//		
//		if ( guy == self )
//		{
//			if(flag("player_move_up"))
//			{
//				break;
//			}
//			
//			not_baker = false;
//	
//			self disable_ai_color();
//			
//			node = getentarray( "streets_to_dam_hold_up", "script_noteworthy" );
//			if(IsArray(node))
//			{
//				anim_node = node[0];
////				iPrintLn("first node found at " + anim_node.origin[0] + " " + anim_node.origin[1] + " " + anim_node.origin[2]);
//			}
//			else
//			{
//				anim_node = node;	
//			}
//
//			//if player gets too close cancel the anim and just move forward to node
//			self thread cancel_baker_anim();
//			self delayThread(.1, ::enable_cqbwalk);
//			anim_node maps\_anim::anim_reach_solo( self, "ally_hold_01" );
//		
////			flag_set("baker_stopped");
//			
//			self thread play_baker_anim(anim_node);
//			
//			flag_wait("baker_anim_done");
//		}			
//	}
//	
//	flag_set("baker_stopped");
//	new_node = getnode("baker_garage_final", "targetname");
//	self SetGoalNode(new_node);
//	wait(.5);
//	
////	trigger = Getent( "spawn_scaffold_guys_trigger", "targetname" );
////	if(IsDefined(trigger))
////	{
////		trigger notify( "trigger");
////	}
//	flag_set("baker_move_up");
////	self enable_ai_color();
////	allies_cqbwalk(true);
////	wait(5);
////	self enable_cqbwalk(false);
////	
////	allies_cqbwalk(false);
//}

play_baker_anim(anim_node)
{
//	self maps\_anim::anim_single_solo( self, "signal_stop" );
	anim_node maps\_anim::anim_single_solo( self, "ally_hold_01" );
	
	flag_set("baker_anim_done");
}

//cancel_baker_anim()
//{
//	flag_wait("baker_stopped");
//	while(!flag("baker_move_up"))
//	{
//		if(flag("player_move_up"))
//		{
//			self StopAnimScripted();
//			break;
//		}
//		wait(.1);
//	}
//	flag_set("baker_anim_done");
//}

allies_cqbwalk(enable_cqb)
{
	if(enable_cqb)
	{
		level.allies[0] enable_cqbwalk(enable_cqb);
		level.allies[1] enable_cqbwalk(enable_cqb);
		level.allies[2] enable_cqbwalk(enable_cqb);
	}
	else
	{
		level.allies[0] disable_cqbwalk();
		level.allies[1] disable_cqbwalk();
		level.allies[2] disable_cqbwalk();
	}	
}

setup_allies_streets_to_dam()
{
	wait(.5);
	ally_array = level.allies;
	foreach(ally in ally_array)
	{
		ally ally_think_streets_to_dam();
	}	
}

ally_think_streets_to_dam()
{
	self enable_cqbwalk();
	
	flag_wait("baker_move_up");
	
	self disable_cqbwalk();
}

convoy_think()
{
	level.convoy = [];
//	trigger = getent("streets_to_dam_autosave", "targetname");
//    trigger waittill("trigger");

    convoy_array = GetEntArray("enemy_convoy_vehicles_broken", "targetname");
//    i = 0;
    foreach(vehicle_spawner in convoy_array)
    {
    	vehicle_spawner add_spawn_function(::convoy_spawn_func);
    	vehicle = vehicle_spawner Spawn_Vehicle_and_gopath();
		wait(.1);
    }

    level thread convoy_spawn_logic();
     
    wait(.2);
//  STILL NEED TO CHECK FOR PLAYER GETTING IN FRONT OF TRUCKS...
    level thread convoy_check();

    level thread set_flag_when_launcher_in_right_spot();

//    flag_wait("convoy_gone");
    
}

convoy_spawn_logic()
{
	convoy_array = GetEntArray("enemy_convoy_vehicles", "targetname");

    foreach(vehicle_spawner in convoy_array)
    {
		vehicle_spawner add_spawn_function(::convoy_spawn_func);
    }
    
    spawn_order = [1,2,0,1,2,1,0];
    spawn_num = 0;
    last_spawn_was_lynx = 0;
    while(!flag("spawn_m880"))
    {
    	vehicle = convoy_array[spawn_order[spawn_num]] Spawn_Vehicle_and_gopath();
    	vehicle thread maps\flood_audio::flood_convoy_sfx( spawn_num );
    	vehicle Vehicle_TurnEngineOff();
    	spawn_num++;
    	if(spawn_num >= spawn_order.size)
    	{
    		spawn_num = 0;
    	}
	
		node1 = GetVehicleNode("convoy_next_node_1", "targetname");
		node2 = GetVehicleNode("convoy_next_node_2", "targetname");

		waittill_any_ents(node1, "trigger", node2, "trigger");

		wait(.5);
    }
    
    tank_array = GetEntArray("enemy_convoy_vehicles_tank", "targetname");

    foreach ( tank in tank_array)
    {
//    	tank add_spawn_function(::tank_spawn_func);	
    	tank add_spawn_function(::convoy_spawn_func);
		tank Spawn_Vehicle_and_gopath();
		wait(.1);
    }
    	
    launcher = GetEnt("enemy_convoy_vehicles_launcher", "targetname");

	launcher add_spawn_function(::launcher_spawn_func);	
//	launcher Spawn_Vehicle_and_gopath();
	launcher = launcher Spawn_Vehicle();
	level thread ladder_spot_glow();
	wait(.1);
	launcher gopath();
	flag_set("m880_has_spawned");
	
	launcher_lynx = GetEnt("enemy_convoy_vehicles_launcher_lynx", "targetname");

	launcher_lynx add_spawn_function(::launcher_lynx_spawn_func);	
	launcher_lynx Spawn_Vehicle_and_gopath();
	
}

//MM not used
//set_m880_flag()
//{
//    trigger = getent("spawn_m880_trigger", "targetname");
////    trigger waittill("trigger");
////    level thread set_flag_on_trigger(trigger, "spawn_m880");
//    flag_wait("enemy_alerted");
//    
//    flag_set("spawn_m880");    
//}

convoy_spawn_func()
{
	self endon("death");
		
	index = level.convoy.size;
	level.convoy[index] = self;
	
	self thread convoy_death_func();
	self godon();
	//25
	self Vehicle_SetSpeed(25, 25, 25);
	
//	riders = self maps\_vehicle_code::get_vehicle_ai_riders();
	//lynx don't have riders
	if(self.vehicletype != "iveco_lynx")
	{
		while(!self.riders.size)
		{
			wait(.1);
	//		riders = self maps\_vehicle_code::get_vehicle_ai_riders();
		}
		
		total_riders = self.riders.size;
		wait(.2);
		foreach ( guy in self.riders)
		{
			rand_num = RandomInt(2);
			if(rand_num == 0 && total_riders > 2)
			{
				total_riders--;
				guy delete();
			}
			else
			{
				guy thread convoy_riders_death_func();
//				guy thread convoy_riders_react_func(self);
			}
		}
	}
	flag_wait("spawn_m880");
	
	rand = RandomIntRange(1,3);
	//25
	self Vehicle_SetSpeed(24+rand, 7, 7);
	
	while(!flag("start_heli_attack"))
	{
		convoy_spacing_func(index, 450, 600);
		wait(.25);
	}
	
	wait(2.0);
	self Vehicle_SetSpeed(25, 2, 2);
	
}

//tank_spawn_func()
//{
//	self endon("death");
//	
//	self godon();
//	
//	level.convoy_tank = self;
//	
//	//was 14, 10, 10, now 25
//	self Vehicle_SetSpeed(25, 25, 25);
//	
//	self thread convoy_death_func();
//	
//	flag_wait("start_heli_attack");
//	
////	wait(3.3);
//	wait(2.0);
//	self Vehicle_SetSpeed(25, 2, 2);
//}

launcher_spawn_func()
{
	thread maps\flood_audio::flood_convoy_exp_sfx();
	self endon("death");

	level.first_launcher = 	self;
	self.animname = "m880_crash_m880";
	
	self godon();

	//this speed was 14, now 25
	self Vehicle_SetSpeed(25, 25, 25);
	
	flag_wait("start_heli_attack");
	
	self thread maps\flood_audio::flood_launcher_crash_sfx();
	
//	wait(3.3);
	wait(2.0);
	self Vehicle_SetSpeed(25, 2, 2);
	
	//wait till in the right place for anim to start
	while(level.first_launcher.origin[1] < -9500)
	{
		wait(.1);
	}	
	

	level.first_launcher thread vehicle_stop_named("m880_crashed", 25, 25);
	level.launcher_lynx thread m880_crash_kill_player_in_lynx_volume();
	delayThread(2.5, ::m880_crash_kill_in_volume);

	maps\flood_anim::m880_crash_spawn(level.first_launcher, level.launcher_lynx);
	
	flag_set("missile_launcher_in_place");
	level notify("remove_checkpoint_kill_trigger");
	
	level thread connect_nodes_after_crash();
	
	//****************************************************
	//
	//****************************************************
	maps\flood_anim::m880_crash_loop( level.first_launcher );
	
	thread maps\flood_audio::mssl_launch_front_wheels();
	self PlayLoopSound( "scn_flood_mssl_stuck_lp" );	
	//****************************************************
	//
	//****************************************************		
//	level.first_launcher vehicle_stop_named("m880_crashed", 25, 25);
//	level.first_launcher Vehicle_SetSpeedImmediate(0);
	
	//when launcher gets to "convoy_start_path_1"
	//anim node is "vignette_m880_crash"
}

m880_crash_kill_in_volume()
{
	enemy_array = GetAIArray("axis");
	volume = getent("m880_crash_kill_volume", "targetname");
	
	foreach(guy in enemy_array)
	{
		if(guy istouching(volume))
		{
			guy kill();
		}
	}
}

m880_crash_kill_player_in_lynx_volume()
{
//	level endon("lynx_crash_end");
	
	level waittill("lynx_crash_start");
//	IPrintLn("lynx_crash_start notify");
		
	volume = getent("lynx_collision_path_200", "targetname");
	volume thread wait_then_check_if_player_touching_kill(2.00, 2.80);
	volume = getent("lynx_collision_path_250", "targetname");
	volume thread wait_then_check_if_player_touching_kill(2.50, 3.14);
	volume = getent("lynx_collision_path_290", "targetname");
	volume thread wait_then_check_if_player_touching_kill(2.90, 3.60);
	volume = getent("lynx_collision_path_330", "targetname");
	volume thread wait_then_check_if_player_touching_kill(3.30, 4.50);
	volume = getent("lynx_collision_path_385", "targetname");
	volume thread wait_then_check_if_player_touching_kill(3.85, 4.6);	
	
}

wait_then_check_if_player_touching_kill(wait_time, stop_time)
{
	self endon("stop"+wait_time);
	self endon("death");
	delay_time = stop_time - wait_time;
	wait(wait_time);
//	IPrintLn("starting touch check "+wait_time);
	self thread notify_delay("stop"+wait_time, delay_time);
	while(1)
	{
		if(level.player IsTouching(self))
		{
			level.player kill();
		}
		wait(.1);
	}
}

connect_nodes_after_crash()
{
	node_array = GetNodeArray("connect_after_crash", "targetname");
	foreach ( node in node_array)
	{
		node ConnectNode();
	}
	
	node_array = GetNodeArray("disconnect_after_crash", "targetname");
	foreach ( node in node_array)
	{
		node DisconnectNode();
	}
}

launcher_lynx_spawn_func()
{
	self endon("death");

	level.launcher_lynx = 	self;
	self.animname = "convoy_lynx";
	
	self godon();

	//this speed was 14, now 25
	self Vehicle_SetSpeed(25, 25, 25);
	
	flag_wait("start_heli_attack");
	
//	wait(3.3);
//	wait(2.0);
//	self Vehicle_SetSpeed(25, 2, 2);
	
	//wait till in the right place for anim to start
//	while(level.first_launcher.origin[1] < -9500)
//	{
//		wait(.1);
//	}	
//		
//	level.launcher_lynx thread vehicle_stop_named("m880_crashed", 25, 25);
	
//	self waittill("crash_done");
	
//	self spawn_non_vehicle_lynx();
//	self delete();
	
//	maps\flood_anim::m880_crash_spawn(level.first_launcher);	
	
}

//m880_crash_anim_init()
//{
//	wait(.1);
//	node = getstruct("vignette_m880_crash", "script_noteworthy");
//	
//	thread maps\flood_anim::m880_crash_barrels( node );	
//	
//	thread maps\flood_anim::m880_crash_debris( node );
//}

//spawn_non_vehicle_lynx()
//{
//	guys = [];
//	guys["convoy_lynx"] = self;
//	self anim_last_frame_solo(guys, "m880_crash");
////	crashed_lynx = GetEnt("crashed_lynx", "targetname");
////	crashed_lynx.origin = self.origin;
////	crashed_lynx.angles = self.angles;
//}

convoy_kill_player()
{
	level endon("remove_checkpoint_kill_trigger");
	
	trigger = getent("kill_player_checkpoint", "targetname");
	trigger waittill("trigger");
	
	level.player kill();
}

convoy_death_func()
{
	self endon("death");
		
	while(!flag("streets_to_dam_enemies_dead"))
	{
		trigger = getent("kill_convoy", "targetname");
		trigger waittill("trigger", guy);
		
		if(guy == self)
		{
			break;	
		}
	}
	
	self delete();
}

//convoy_riders_kill_func()
//{
//	while(!flag("streets_to_dam_enemies_dead"))
//	{
//		trigger = getent("kill_truck_guys", "targetname");
//		trigger waittill("trigger", guy);
//		
//		if(isdefined(guy.targetname))
//		{
//			IPrintLn("triggered by " + guy.targetname);
//		}
//		
//		if(isdefined(guy.targetname) &&  (guy.targetname == "streets_to_dam_convoy"))
//		{
//			guy delete();
//		}
//	}	
//}

convoy_riders_death_func()
{
	self endon("death");
		
	while(!flag("streets_to_dam_enemies_dead"))
	{
		trigger = getent("kill_truck_guys", "targetname");
		trigger waittill("trigger", guy);
		
		if(guy == self)
		{
			break;	
		}
	}
	
	self delete();
}

convoy_riders_react_func(vehicle)
{
	vehicle endon("death");
	
	wait(.3);
	
	foreach ( guy in vehicle.riders)
	{
		guy thread notify_on_msg(self, "riders_shot", "death");
		guy thread notify_on_msg(self, "riders_shot", "damage");
//		IPrintLn("adding notify msg to guys");
	}
	
	self waittill("riders_shot");
//	IPrintLn("received notify msg");
	wait(RandomFloat(.2));
	if(isdefined(self) && isalive(self))
	{
//		self DoDamage(self.health + 1, self.origin, level.player);
//		IPrintLn("trying to kill");	
		animpos = level.vehicle_aianims[ vehicle.classname ][ 2 ];
		self setanim( animpos.death);
//		self kill();
	}
	
//	self delete();
}

//convoy_stop_func(node_name, notify_text)
//{
//	not_time_yet = true;
//	
//	while(not_time_yet)
//	{
//		stop_node = GetVehicleNode(node_name, "targetname");
//	    stop_node waittill("trigger", vehicle);
//	    if(vehicle == self)
//	    {
//	    	not_time_yet = false;
//	    }
//	}
//	
//	self vehicle_stop_named( "convoy_stop", 15, 15);	
//	
//	level notify(notify_text);
//}
//
//speed_up_convoy_when_player_close()
//{
////    convoy_trigger = GetEnt("close_to_checkpoint", "targetname");
////    if(IsDefined(convoy_trigger))
////    {
////    	convoy_trigger waittill("trigger");
////    }
//
//    //if player waits in background, still trigger the speed up once launcher is in position
//    flag_wait_any("enemy_alerted", "close_to_checkpoint", "start_heli_attack");
//    
//	for ( i = 0; i < level.convoy.size; i++ )
//	{
//		if(IsDefined(level.convoy[i]))
//		{
//			rand = RandomIntRange(1,3);
//			level.convoy[i] Vehicle_SetSpeed(12+rand, 5, 5);
//			wait(.2);
//		}
//	}
//
//	while(1)
//	{
//		for ( i = 1; i < level.convoy.size-1; i++ )
//		{
//			convoy_spacing_func(i, 430, 600);
//		}
//		
//		//special case - tank is longer than trucks
//		i = level.convoy.size-2;
//		convoy_spacing_func(i, 650, 800);
//
//		wait(.25);
//	}
//	
//}

check_if_player_close_to_checkpoint()
{
	convoy_trigger = GetEnt("close_to_checkpoint", "targetname");
    if(IsDefined(convoy_trigger))
    {
    	convoy_trigger waittill("trigger");
    }	
    
    flag_set("close_to_checkpoint");
}

convoy_spacing_func(i, too_close, too_far)
{
	//21, 25
	//15, 19
	min_speed = 21;
	max_speed = 27;
	
	if(isdefined(level.convoy[i-1]) && isdefined(level.convoy[i]))
	{
		if(Distance2D(level.convoy[i].origin, level.convoy[i-1].origin) > too_far)
		{
//					PrintLn("level.convoy[" + i + "] is speeding up");
			current_speed = level.convoy[i] Vehicle_GetSpeed();
			delta = RandomIntRange(1,3);
//					delta = 2;
			new_speed = current_speed + delta;
			if(new_speed > max_speed)
			{
				new_speed = max_speed;	
			}
			level.convoy[i] Vehicle_SetSpeed(new_speed, 10, 10);
		}
		if(Distance2D(level.convoy[i].origin, level.convoy[i-1].origin) < too_close)
		{
//					PrintLn("level.convoy[" + i + "] is slowing down");
			current_speed = level.convoy[i] Vehicle_GetSpeed();
			delta = RandomIntRange(1,3);
//					delta = 2;
			new_speed = current_speed - delta;
			if(new_speed < min_speed)
			{
				new_speed = min_speed;	
			}		
			level.convoy[i] Vehicle_SetSpeed(new_speed, 10, 10);
		}
	}	
}

rotate_checkpoint_gate_when_near_m880(distance)
{
	gate = getent("checkpoint_gate", "targetname");
	
	end_rotation = (0, 0, -15);
	
	while(!isdefined(level.first_launcher))
	{
		wait(.1);
	}

	while(Distance2D(level.first_launcher.origin, gate.origin) > distance)
	{
		wait(.1);
	}
	
	gate RotateTo(end_rotation, .25);
}

rotate_checkpoint_concrete_barrier_when_near_m880(distance)
{
	level endon("end_of_streets_to_dam");
	concrete_barrier = getent("checkpoint_concrete_barrier_1", "targetname");
	
	concrete_barrier_2 = getent("checkpoint_concrete_barrier_2", "targetname");
	concrete_barrier_2 hide();
	
	end_rotation = concrete_barrier_2.angles;
	end_pos = concrete_barrier_2.origin;
	
	while(!isdefined(level.first_launcher))
	{
		wait(.1);
	}

	while(Distance2D(level.first_launcher.origin, concrete_barrier.origin) > distance)
	{
		wait(.1);
	}
	
		concrete_barrier RotateTo(end_rotation, .15);
		concrete_barrier MoveTo(end_pos, .15);
	//	concrete_barrier delete();
		concrete_barrier_clip = getentarray("checkpoint_concrete_barrier_1_clip", "targetname");
		foreach ( clip in concrete_barrier_clip)
	{
		clip delete();
	}
		level waittill("player_failed_stab");
		concrete_barrier hide();
	
}

streets_to_dam_sequence()
{
	trigger = getent("rpg_guys_death_trigger", "targetname");
	trigger waittill("trigger");
	
	kill_deathflag("rpg_guys");
//	trigger = getent("streets_to_dam_wave_2_start", "targetname");
//	trigger trigger_off();
//	
//	level waittill("ally_at_launcher_destruction_node");
//	
//	wait(1.0);
//	
//	trigger = getent("streets_to_dam_wave_2_start", "targetname");
//	trigger trigger_on();
}

streets_to_dam_wave_1_init()
{
//	trigger_targetname_array = [
//		"streets_to_dam_first_advance",
//		"streets_to_dam_second_advance", 
//		"streets_to_dam_wave_1_fallback"];
	
	enemies = GetEntArray("streets_to_dam_wave_1", "targetname");
    array_spawn_function(enemies , ::streets_to_dam_wave_1_spawn_func);
    
    enemies = GetEntArray("streets_to_dam_wave_1", "targetname");
    array_thread(enemies , ::spawn_ai);
    
    enemies = GetEntArray("streets_to_dam_wave_1_street_patrol", "targetname");
    array_spawn_function(enemies , ::streets_to_dam_wave_1_street_patrol_spawn_func);    
    
	enemies = GetEntArray("streets_to_dam_wave_1_street_patrol", "targetname");
    array_thread(enemies , ::spawn_ai);
    
//    enemies = GetEntArray("streets_to_dam_wave_1_runner", "targetname");
//    array_spawn_function(enemies , ::streets_to_dam_wave_1_runner_spawn_func);    
//    
//	enemies = GetEntArray("streets_to_dam_wave_1_runner", "targetname");
//    array_thread(enemies , ::spawn_ai);
    
    enemy_array = GetAIArray("axis");
    array_thread(enemy_array, ::ignore_everything);
    
    allies_array = GetAIArray("allies");
    array_thread(allies_array, ::ignore_everything);
    
    level thread block_off_road_during_convoy();
    
    level thread set_up_vignette_enemies();
    
    level thread watch_player_for_attack();
    level thread watch_enemy_for_damage();
    level thread watch_player_for_trigger();
    level thread watch_for_ally_see_convoy();
    
    level thread swap_nodes_init();
    
    flag_wait_any("see_convoy", "player_move_up","enemy_alerted");
//    
//    if(flag("baker_stopped"))
//    {
//    	IPrintLn("baker_stopped");
//    } 
    if(flag("player_move_up"))
    {
//    	IPrintLn("player_move_up");
    } 
    if(flag("enemy_alerted"))
    {
//    	IPrintLn("enemy_alerted");
    } 
    
//    if(flag("baker_stopped"))
//    {
//    	flag_wait("baker_move_up");
//    }    
    
//    IPrintLn("final node order given");
	player_trigger = getent("spawn_scaffold_guys_trigger", "targetname");    
	if(isdefined(player_trigger))
	{
		player_trigger notify("trigger");
	}
	
    //hold up
    
//    trigger = getent("streets_to_dam_rpg_spawn", "targetname");
//    if(IsDefined(trigger))
//    {
//		trigger waittill("trigger");
//    }
//    level thread block_off_road_during_convoy(8);
    
    level thread start_combat_after_seeing_launcher();
//    wait(4.0);
//	level thread heli_dialogue();
	level thread enemy_checkpoint_dialogue();
	level thread heli_strafing_run();
//    level thread diaz_gets_rpg_and_shoots_at_launcher();
//    level thread kill_guys_near_rpg();
    
    flag_wait_any("enemy_alerted", "start_cover_fire");
//    flag_wait_any("enemy_alerted", "start_cover_fire", "convoy_gone");
//    flag_wait_any("start_cover_fire", "convoy_gone");
    
//    flag_wait_or_timeout( "enemy_alerted", 13 );
    
    if(!flag("enemy_alerted"))
    {
//    	IPrintLn("Enemy Surprised!");
    	flag_set("enemy_surprised");
    	//wait for baker to give the ok
    	wait(2.5);
	    allies_array = GetAIArray("allies");
//	    level.allies[0] clear_ignore_everything();
//    	level.allies[2] clear_ignore_everything();
    	array_thread(allies_array, ::clear_ignore_everything);
    	foreach(guy in allies_array)
    	{
    		guy.ignoreme = true;
			guy.ignoresuppression = true;    		
    	}
    	level.player.ignoreme = true;
    	
    	enemy_array = GetAIArray("axis");
    	array_thread(enemy_array, ::clear_ignore_everything);
		level thread checkpoint_enemies_run_for_cover();
//		level thread checkpoint_rpg_enemies_fire_at_heli();
//    	wait(1.5);
    	wait(3.0);
    	//in case the timer went off
//    	IPrintLn("Enemy Ready!");

    }
    else
    {
    	rpg_guys = get_ai_group_ai("rpg_guys");
    	array_thread(rpg_guys, ::clear_ignore_everything);
    }
    
    allies_array = GetAIArray("allies");
    array_thread(allies_array, ::clear_ignore_everything);
    
    foreach(guy in allies_array)
    {
    	guy.ignoreme = false;	
    }
    level.player.ignoreme = false;

    
    //handle the rpg guys seperately
    rpg_guys = get_ai_group_ai("rpg_guys");
    enemy_array = GetAIArray("axis");
    enemy_array = array_remove_array(enemy_array, rpg_guys);
    array_thread(enemy_array, ::clear_ignore_everything);
    //wake them up, but stagger it
    foreach(guy in enemy_array)
    {
    	if(isdefined(guy))
    	{
	    	guy clear_ignore_everything();
	    	wait(RandomFloatRange(.2, .5));
    	}
    }
    //    level.allies[0] clear_ignore_everything();
//    level.allies[2] clear_ignore_everything();
    
//    allies_cqbwalk(false);

    //re-add this to bring scaffolding guys back in
//	level thread spawn_scaffold_guys();
	
    wait(.5);
    while((get_ai_group_sentient_count("streets_to_dam_wave_1") + get_ai_group_sentient_count("rpg_guys")) > 4)
    {
    	wait(.1);
    }
    
    flag_set("streets_to_dam_enemies_ALMOST_dead");
    
    wait(2);
    
    trigger = getent("streets_to_dam_garage_exit", "targetname");
    if(isdefined(trigger))
    {
//    	IPrintLn("streets_to_dam_garage_exit trigger");
    	trigger notify("trigger");
    }
    
//	while((get_ai_group_sentient_count("streets_to_dam_wave_1") + get_ai_group_sentient_count("rpg_guys")) > 1)
//	{
//		wait(.1);
//	}
//
//    trigger = getent("streets_to_dam_outside_garage", "targetname");
//	if(isdefined(trigger))
//	{
//   		trigger waittill("trigger");
//	}
	
//	while((get_ai_group_sentient_count("streets_to_dam_wave_1") + get_ai_group_sentient_count("rpg_guys")) > 1)
//	{
//		wait(.1);
//	}
//	
    waittill_aigroupcleared("streets_to_dam_wave_1");
    waittill_aigroupcleared("rpg_guys");
//	waittill_aigroupcleared("streets_to_dam_wave_1_5");
    wait(.5);
       
    //re-add this to bring scaffolding guys back in
//	waittill_aigroupcleared("streets_to_dam_wave_1_5_high");
	    
//    wait(5.0);
	
    flag_set("streets_to_dam_enemies_dead");
//    maps\flood_util::waittill_aigroupcount_or_trigger_targetname( "streets_to_dam_wave_1_5", 4, "run_to_gate" );
//    
//    ai_array =  get_ai_group_ai("streets_to_dam_wave_1_5");
//    ai_array set_group_goalvolume("streets_to_dam_goal_volume_1");
    
}

watch_for_ally_see_convoy()
{
	trigger = getent("baker_hold_up", "targetname");
	trigger waittill("trigger");
					 
	flag_set("see_convoy");
}

checkpoint_enemies_run_for_cover()
{
	heli_target = Spawn("script_origin", level.heli_turret.origin);
	wait(.1);
	heli_target.origin = level.heli_turret.origin + (0,0,300);
	heli_target LinkTo(level.heli_turret);
	
	node_array = GetNodeArray("checkpoint_alert_node", "script_noteworthy");
	enemy_array = get_ai_group_ai("streets_to_dam_wave_1");

	//this assumes they will all have the same goal radius...
	old_radius = enemy_array[0].goalradius;
	
	//send each ai to node it's closest to
	foreach(node in node_array)
	{
		ordered_array = get_array_of_closest(node.origin, enemy_array);
		if(ordered_array.size > 0)
		{
			ordered_array[0].goalradius = 32;
			ordered_array[0] SetGoalNode(node);
			ordered_array[0] SetEntityTarget(heli_target);
			enemy_array = array_remove(enemy_array, ordered_array[0]);
		}
	}
	
	wait(1.5);
	enemy_array = get_ai_group_ai("streets_to_dam_wave_1");
	
	foreach(guy in enemy_array)
	{
		guy.goalradius = old_radius;
		guy ClearEntityTarget();
	}
	
}

checkpoint_rpg_enemies_fire_at_heli()
{
	
//	rpg_target = Spawn("script_origin", level.heli_turret.origin);
//	wait(.1);
//	rpg_target.origin = level.heli_turret.origin + (0,-700,100);
//	rpg_target LinkTo(level.heli_turret);
	
	enemy_array = get_ai_group_ai("rpg_guys");
	while(enemy_array.size < 2)
	{
		wait(.1);
		enemy_array = get_ai_group_ai("rpg_guys");
	}

	rpg_target = getent("streets_to_dam_rpg_target_1", "targetname");
	
	enemy_array = get_array_of_closest(rpg_target.origin, enemy_array);
	//send each ai to node it's closest to
	
	//fire at heli when it is approaching and then when it is flying away
	for(i=0; i<enemy_array.size; i++)
	{
		if(IsDefined(enemy_array[i]))
		{
//			enemy_array[i] thread rpg_guy_wait_and_fire_at_target(rpg_target, ((i*500)-8000));			
			if(i != 0)
			{
				rpg_target = getent("streets_to_dam_rpg_target_2", "targetname");
			}

			enemy_array[i] thread rpg_guy_wait_and_fire_at_target(rpg_target);			
		}
	}
}

rpg_guy_wait_and_fire_at_target(mytarget)
{
	self endon("death");
	
	if(flag("enemy_surprised"))
	{
	
		self.dontEverShoot = true;
		self SetEntityTarget(mytarget);
//		self SetLookAtEntity(mytarget);
		self thread ignore_everything();
		while(level.heli_turret.origin[1] < mytarget.origin[1])
		{
			wait(.1);
		}
	
//		IPrintLn("rpg guy should fire now");
		self.dontEverShoot = undefined;

		wait(2.0);
		self ClearEntityTarget();
		
		wait(.1);
		self.dontEverShoot = undefined;
//		self SetLookAtEntity();
		self thread clear_ignore_everything();
	}
	self.ignoresuppression = true;
		
}

//rpg_guy_wait_and_fire_at_target(mytarget, y_value)
//{
//	self endon("death");
//	
//	self.dontEverShoot = true;
//	self SetEntityTarget(mytarget);
//	self SetLookAtEntity(mytarget);
//	self thread ignore_everything();
//	while(mytarget.origin[1] < y_value)
//	{
//		if(Distance2D(self.origin, mytarget.origin) < 600)
//		{
//			self ClearEntityTarget();
//		}
//		else
//		{
//			self SetEntityTarget(mytarget);
//		}
//		wait(.1);
//	}
//
//	IPrintLn("rpg guy should fire now");
//	while (!( BulletTracePassed( self GetTagOrigin("tag_weapon_left"), mytarget.origin, true, self ) ))
//	{
//		wait(.1);
//	}
//	bullet = MagicBullet("rpg", self GetTagOrigin("tag_weapon_left"), mytarget.origin + (0,0,0));
////	self.dontEverShoot = undefined;
//	self SetEntityTarget(mytarget);
//	wait(2.0);
//	self ClearEntityTarget();
//	
//	wait(.1);
//	self.dontEverShoot = undefined;
//	self thread clear_ignore_everything();
//		
//}

set_up_vignette_enemies()
{
	enemies = GetEntArray("streets_to_dam_wave_1_vignette", "targetname");
	array_spawn_function(enemies , ::streets_to_dam_wave_1_spawn_func);
	array_spawn_function(enemies , ::streets_to_dam_wave_1_vignette_spawn_func);
	i = 0;
	guys = [];
	foreach ( spawner in enemies)
	{
		guys[i] = spawner spawn_ai();
		i++;
		guys[i-1].animname = "convoy_checkpoint_opfor0" + i;
//		PrintLn(guys[i-1].animname);
	}
	
//    array_thread(enemies , ::spawn_ai);
	enemies = GetEntArray("streets_to_dam_wave_1_vignette_extra", "targetname");
	array_spawn_function(enemies , ::streets_to_dam_wave_1_spawn_func);
	array_spawn_function(enemies , ::streets_to_dame_wave_1_vignette_extra_spawn_func);
	array_spawn(enemies);
    
    wait(1.0);
    flag_wait("vignette_convoy_checkpoint_flag");
    if(!flag("enemy_alerted"))
    {
    	maps\flood_anim::convoy_checkpoint(guys[0], guys[1], guys[2], guys[3]);
    }
	
}

delete_on_flag(flag_name)
{
	self endon("death");
	
	flag_wait(flag_name);
	self delete();
}

streets_to_dam_wave_1_vignette_spawn_func()
{
	self endon("death");
	
	if(IsDefined(self.script_noteworthy))
	{
		if(self.script_noteworthy == "enemy_13")
		{
			level.enemy_13 = self;
		}
		if(self.script_noteworthy == "enemy_14")
		{
			level.enemy_14 = self;
		}
		if(self.script_noteworthy == "enemy_15")
		{
			level.enemy_15 = self;
		}
	}
	
	self ignore_everything();
	
//	flag_wait_any("enemy_alerted", "enemy_surprised", "convoy_gone", "grenade_thrown");
	
	flag_wait("enemy_alerted");
	
//	IPrintLn("stopping anim script");
	self clear_ignore_everything();
	self StopAnimScripted();
}

streets_to_dame_wave_1_vignette_extra_spawn_func()
{
	self endon("death");
	
	self.animname = "convoy_checkpoint_opfor02";
	
	self ignore_everything();
	
	node = getent("streets_to_dam_extra_waver_node", "script_noteworthy");
	
	guys = [];
	guys["convoy_checkpoint_opfor02"] = self;
//	guys["convoy_checkpoint_opfor02"] = convoy_checkpoint_opfor02;
//	guys["convoy_checkpoint_opfor03"] = convoy_checkpoint_opfor03;
//	guys["convoy_checkpoint_opfor04"] = convoy_checkpoint_opfor04;
	
	node thread anim_single(guys, "convoy_checkpoint");
	
//	flag_wait_any("enemy_alerted", "enemy_surprised", "convoy_gone", "grenade_thrown");
	flag_wait_any("enemy_alerted", "enemy_surprised", "grenade_thrown");
	
//	IPrintLn("stopping anim script");
	self clear_ignore_everything();
	self StopAnimScripted();
}

start_combat_after_seeing_launcher()
{
	flag_wait("rpg_fired_at_launcher");

//	launcher = level.convoy[level.convoy.size - 1];
//	while(launcher.origin[1] < -9750)
//	{
//		wait(.1);
//	}
	flag_set("start_cover_fire");
}

//MM not used
kill_guys_near_rpg()
{
	
	wait(2.0);
	volume = getent("enemies_near_rpg_volume", "targetname");
	kill_deathflag_in_area("streets_to_dam_checkpoint_enemies_close", volume, 2.0);
	
}

garage_autosave_before_heli_attack()
{
	flag_wait("m880_has_spawned");
	level thread autosave_now();	
}

//MM not used anymore
//heli_dialogue()
//{
//	level.allies[0] smart_dialogue("flood_bkr_holdup");
//	if(!flag("enemy_alerted"))
//	{
//		level.allies[1] smart_dialogue("flood_vrg_holdourfirelets");
//	
////		thread add_dialogue_line("Baker", "Hold your fire.");
//		
//	}
//	if(!flag("enemy_alerted"))
//	{
//		level.allies[0] smart_dialogue("flood_pri_no");
////		wait(.5);
////		thread add_dialogue_line("Baker", "Overlord, Launcher spotted east of our position. Any air support in the area?");
//	}
//	
//	if(!flag("enemy_alerted"))
//	{
//		level.allies[0] smart_dialogue("flood_pri_iwasntexpectingthis");
////		wait(.5);
////		thread add_dialogue_line("Baker", "Overlord, Launcher spotted east of our position. Any air support in the area?");
//	}
//
//	level thread allies_convoy_dialogue();
////	level.allies[0] smart_dialogue("flood_pri_helixonewevegot");
////	wait(3);
////	thread smart_radio_dialogue("flood_hlx_alreadypickeditup");
//	
////	if(!flag("enemy_alerted"))
////	{
////		thread add_dialogue_line("Overlord", "We saw it. Raptor 6 already en-route");
////		wait(1);
////	}
////	if(!flag("enemy_alerted"))
////	{
////		thread add_dialogue_line("Baker", "Hold your fire until our support arrives.");
////	}
//	flag_set("spawn_m880");
//	
//	flag_wait("m880_has_spawned");
//	wait(6);
//	smart_radio_dialogue("flood_hlx_goinghot");
//	flag_wait("rpg_fired_at_launcher");
//	if(!flag("enemy_alerted"))
//	{
//		level.allies[0] smart_dialogue("flood_bkr_convoysclearopenfire");
////		thread add_dialogue_line("Baker", "Alright lets clean this up.");
//	}
//}

allies_convoy_dialogue()
{
	//Vargas: Overlord, we've got eyes on a heavy convoy moving through grid square five-niner….
	level.allies[ 0 ] smart_dialogue( "flood_pri_helixonewevegot" );
	//Overlord: Copy that… picked it up.  Air support is on the way. Stand clear.
	smart_radio_dialogue( "flood_hlx_alreadypickeditup" );
	
	wait(.5);
	
	//Vargas: Get ready for the show, boys.
	level.allies[ 0 ] smart_dialogue( "flood_pri_getreadyforthe" );
}

enemy_checkpoint_dialogue()
{
	while(!isdefined(level.enemy_13))
	{
		wait(.1);
	}
//	IPrintLn("found enemy 13");
	while(!isdefined(level.enemy_14))
	{
		wait(.1);
	}
//	IPrintLn("found enemy 14");
	while(!isdefined(level.enemy_15))
	{
		wait(.1);
	}
	
//	IPrintLn("found enemy 15");
	
//	level.enemy_13 enemy_dialogue("flood_sp13_letsgetthisconvoy");
//	level.enemy_13 enemy_dialogue("flood_sp13_keepitmovingkeep");
//	level.enemy_13 enemy_dialogue("flood_sp13_dontslowdown");
//	level.enemy_14 enemy_dialogue("flood_sp14_letsgoletsgo");
//	level.enemy_13 enemy_dialogue("flood_sp13_weneedtohurry");
//	level.enemy_13 enemy_dialogue("flood_sp13_keepthepathclear");
//	level.enemy_13 enemy_dialogue("flood_sp13_garciawantsthesetrucks");
//	level.enemy_13 enemy_dialogue("flood_sp13_getonthatradio");
//	level.enemy_13 enemy_dialogue("flood_sp13_anyvisualonenemy");
//	level.enemy_15 enemy_dialogue("flood_sp15_convoyismovingthrough");
//	
//	level.enemy_14 enemy_dialogue("flood_sp14_whatsthatsound");
//	level.enemy_13 enemy_dialogue("flood_sp13_incoming");
}

enemy_dialogue(vo_string)
{
	if(!flag("enemy_alerted"))
	{
		self smart_dialogue(vo_string);
	}	
}

heli_strafing_run()
{
	//spawn heli and go_path
	
	flag_wait("start_heli_attack");
	
	// added by JKU.  Jet flyby, placed here because it's loosely timed to the ally chopper flying in
	level delayThread( 1, ::spawn_vehicles_from_targetname_and_drive, "convoy_flyin_jet" );
	
//	chopper = spawn_vehicle_from_targetname_and_drive( "streets_to_dam_strafe_blackhawk" );
	chopper = spawn_vehicle_from_targetname( "streets_to_dam_strafe_blackhawk" );
	chopper2 = spawn_vehicle_from_targetname( "streets_to_dam_strafe_blackhawk_2" );
	
//	chopper SetMaxPitchRoll( 10, 60 );
	chopper godon();
	chopper2 godon();
	//spawn turret?
	chopper_turret_1 = chopper thread add_turret_to_heli(1);
//	level.heli_turret = chopper_turret_1;
	chopper_turret_2 = chopper2 thread add_turret_to_heli(2);
	chopper gopath();
	chopper Vehicle_TurnEngineOff();
	chopper thread maps\flood_audio::flood_convoy_attackheli01_sfx();
	chopper2 gopath();
	chopper2 Vehicle_TurnEngineOff();
	chopper2 thread maps\flood_audio::flood_convoy_attackheli02_sfx();
//	chopper2 delayThread(0.5, maps\_vehicle::gopath);
//	chopper2 gopath();
	//when get to node start firing at target
//	chopper thread display_speed();
	chopper waittill("start_firing");
//	wait(.5);
//	chopper waittill("start_firing");
//	chopper waittill("start_firing");
	//fire at target...move target relative to heli
	chopper thread heli_strafing_think();
	//chopper2 delayThread(0.25, ::heli_strafing_think);
	
	chopper thread fire_heli_turret();
	chopper2 thread fire_heli_turret();
	
	wait(1.0);
	
//	chopper notify("stop_firing");
//	chopper2 notify("stop_firing");
	
//	chopper thread fire_heli_turret(level.heli_turret);
//	chopper2 thread fire_heli_turret(chopper_turret_2);

	//make rpgs guys fire in the air
	//delete heli at end of path
	//trigger "rpg_fired" or whatever
	flag_set("rpg_fired_at_launcher");
	wait(1.0);
//	chopper notify("stop_firing_mg");
//	thread add_dialogue_line("Baker", "Open fire!");
	wait(3.0);
	chopper notify("stop_firing_mg");
	chopper2 notify("stop_firing_mg");
	
//	wait(100);
	
//	while(isdefined(chopper))
//	{
//		wait(.1);
//	}
//	chopper_turret_1 delete();
//	while(isdefined(chopper2))
//	{
//		wait(.1);
//	}
//	chopper_turret_2 delete();
}

display_speed()
{
	self endon("death");
	while(1)
	{
	speed_val = self Vehicle_GetSpeed();
	PrintLn("heli speed is: " + speed_val);
	wait(.1);
	}
}

heli_strafing_think_old()
{
	self endon( "death" );
	self endon( "stop_firing" );
	
//	self thread crash_blackhawk_missile_impacts();
	
//	target_org = GetEnt( "crash_blackhawk_target", "targetname" );
	target_org = level.first_launcher;

//	dist = Distance2D(self.origin, target_org.origin);
	dist_vec = self.origin - target_org.origin + (0,-500, 0);
//	dist_vec = self.origin - target_org.origin;
	
	current_origin = target_org.origin;
	burst = 0;
	x_value = -300;
	
	//fire magic bullets from tag_barrel to target
    while(1)
    {	
    	endX = current_origin[ 0 ] + RandomIntRange( -25, 25 );
	    endY = current_origin[ 1 ] + RandomIntRange( 25, 50 );
	    endZ = current_origin[ 2 ];
	    
	    endPos = (endX, endY, endZ);
        
        bullet_start = self GetTagOrigin("tag_barrel");
        
        MagicBullet( "stinger_speedy", bullet_start, endPos );
        
 		//get ready for next shot       	
       	current_origin = self.origin - dist_vec;
//       	x_value = current_origin[0];
       	if(x_value < 0)
       	{
       		x_value = 100;
       	}
       	else
       	{
       		x_value = -100;
       	}
       	current_origin = (current_origin[0] + x_value, current_origin[1], -32);
       	
       	//"burst fire" 3 shots in a row
       	if(burst < 5)
        {
	       	wait( .1 );
	       	burst++;
        }
        else
        {
        	wait(.5);
        	burst = 0;	
        }
    }
}

heli_strafing_think()
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	//fire magic bullets from tag_barrel to target

	fire_heli_missile("new_streets_to_dam_heli_target_1");
    wait(.2);
    
	fire_heli_missile("new_streets_to_dam_heli_target_2");
    wait(.3);
    
	fire_heli_missile("new_streets_to_dam_heli_target_3"); 
    wait(.5);
    
	fire_heli_missile("new_streets_to_dam_heli_target_4"); 
    wait(.2);
	
    //fire_heli_missile("new_streets_to_dam_heli_target_5");
    //wait(.3);
	
    fire_heli_missile("new_streets_to_dam_heli_target_6");
    wait(.6);
	//fire_heli_missile("new_streets_to_dam_heli_target_7"); 
    //wait(.3);
    
    
	fire_heli_missile("new_streets_to_dam_heli_target_8"); 
    wait(.2);
	//fire_heli_missile("new_streets_to_dam_heli_target_10"); 
   // wait(.2);
	fire_heli_missile("new_streets_to_dam_heli_target_11"); 
    wait(.4);
	fire_heli_missile("new_streets_to_dam_heli_target_12"); 
   //pp wait(.2);
	//fire_heli_missile("new_streets_to_dam_heli_target_13"); 
    //wait(.1);
	//fire_heli_missile("new_streets_to_dam_heli_target_14"); 
    //wait(.4);
	//fire_heli_missile("new_streets_to_dam_heli_target_15"); 
   // wait(.3);
	//fire_heli_missile("new_streets_to_dam_heli_target_16"); 
    //wait(.2);
	//fire_heli_missile("new_streets_to_dam_heli_target_17");     
   
   self notify("stop_firing");
	
}

fire_heli_missile(target_ent)
{
    bullet_start = self GetTagOrigin("tag_flash");
    bullet_start = (bullet_start[0], bullet_start[1] + 50, bullet_start[2]);
   	target_org = GetEnt( target_ent, "targetname" ); 
    MagicBullet( "rpg_straight", bullet_start, target_org.origin );
}

//heli_mg_strafing_think(target_org)
//{
//	self endon( "death" );
//	self endon( "stop_firing" );
//	
////	self thread crash_blackhawk_missile_impacts();
//	
////	target_org = GetEnt( "crash_blackhawk_target", "targetname" );
////	target_org = level.first_launcher;
//
////	dist = Distance2D(self.origin, target_org.origin);
//	dist_vec = self.origin - target_org.origin + (0,-230, 0);
//	
//	current_origin = target_org.origin;
//	burst = 0;
//	x_value = -300;
//	
//	//fire magic bullets from tag_barrel to target
//    while(1)
//    {	
//    	endX = current_origin[ 0 ] + RandomIntRange( -25, 25 );
//	    endY = current_origin[ 1 ] + RandomIntRange( -25, 25 );
//	    endZ = current_origin[ 2 ];
//	    
//	    endPos = (endX, endY, endZ);
//        
//        bullet_start = self GetTagOrigin("tag_barrel");
//        
//        MagicBullet( "50cal_turret_technical", bullet_start, endPos );
//        
// 		//get ready for next shot       	
//       	current_origin = self.origin - dist_vec;
////       	x_value = current_origin[0];
//       	if(x_value < 0)
//       	{
//       		x_value = 100;
//       	}
//       	else
//       	{
//       		x_value = -100;
//       	}
//       	current_origin = (current_origin[0] + x_value, current_origin[1], -32);
//       	
//       	//"burst fire" 3 shots in a row
////       	if(burst < 4)
////        {
////	       	wait( .1 );
////	       	burst++;
////        }
////        else
////        {
////        	wait(.5);
////        	burst = 0;	
////        }
//		wait(.1);
//    }
//}

add_turret_to_heli(turret_num)
{
//	self endon( "stop_firing_mg" );
	
	spawn_pos = self GetTagOrigin("tag_doorgun");
	spawn_pos = self.origin;
	if(turret_num == 1)
	{
		level.heli_turret = SpawnTurret("misc_turret", spawn_pos, "dshk_gaz");
		
		turret = level.heli_turret;
	}
	else
	{
		turret = SpawnTurret("misc_turret", spawn_pos, "dshk_gaz");
	}
	turret SetModel("vehicle_m1a2_abrams_remote_gun");
	turret.team = "allies";
	wait(.1);
	turret.origin = self GetTagOrigin("tag_doorgun");
	turret LinkTo(self, "tag_doorgun", (0,0,0), self.angles + (0,0,90));
	
	turret setmode( "manual" );// "auto_ai", "manual", "manual_ai" and "auto_nonai"
    turret setturretteam( "allies" );
    
//    self.turret = turret;
    
//    turret_target = getent("missile_smoke_origin_3", "targetname");
//    turret settargetentity( turret_target );
//    turret startfiring();
//    
//	return turret;
    while(IsDefined(self))
    {
   		wait(1.0);
    }
    
    turret delete();
}

//fire_heli_turret(turret)
fire_heli_turret()
{
	self endon("death");
	self endon( "stop_firing_mg" );
	
	self waittill("stop_firing");
	
	turret = level.heli_turret;
	
	turret_target = getent("missile_smoke_origin_3", "targetname");
    turret settargetentity( turret_target );
    turret startfiring();
    
    while(IsDefined(turret))
    {
   		turret ShootTurret();
    	wait(.1);
    }
}

block_off_road_during_convoy()
{
	volume = getent("streets_to_dam_bad_place_brush", "targetname");
	BadPlace_Brush("street_blocker", -1, volume, "axis");
	flag_wait("convoy_gone");
	
	BadPlace_Delete("street_blocker");
}

watch_player_for_attack()
{
//	grenade_started = false;
	
	level thread watch_for_player_grenade();
	
	while( !flag("enemy_alerted") )
	{
		if( level.player AttackButtonPressed() && ( level.player GetCurrentWeaponClipAmmo() > 0 ) )
		{
			break;
		}

		wait 0.1;
	}

	flag_set( "enemy_alerted" );
}

watch_for_player_grenade()
{
	while(!flag("enemy_alerted") && !flag("grenade_thrown"))
	{
		grenades = GetEntArray( "grenade", "classname" );
		for ( i = 0; i < grenades.size; i++ )
		{
			if(isdefined(grenades[i]))
			{	
				owner = GetMissileOwner(grenades[i]);
				if(owner == level.player)
				{
					//set this to break enemies out of anim scripted so flashbangs can affect them
					flag_set("grenade_thrown");
//					IPrintLn("grenade thrown!");
					break;					
				}
			}
		}
		waitframe();
	}
	wait RandomFloatRange( 1.5, 2 );
	flag_set( "enemy_alerted" );
}

watch_player_for_trigger()
{
	trigger = getent("streets_to_dam_garage_exit", "targetname");
	trigger waittill("trigger");
	
	flag_set( "enemy_alerted" );
	
}

watch_enemy_for_damage()
{
	enemy_array = GetAIArray("axis");

	foreach(guy in enemy_array)
	{
		guy thread set_flag_if_damaged();
	}
}

set_flag_if_damaged()
{
	self waitill_damage_or_death();
	flag_set( "enemy_alerted" );
//	PrintLn("enemy alerted! at " + self.origin[0] + " " + self.origin[1] + " " + self.origin[2]);
}

notify_on_msg(notify_target, notify_string, msg_to_listen_for)
{
	self waittill(msg_to_listen_for);
	notify_target notify(notify_string);
}

waitill_damage_or_death()
{
	self endon( "damage" );
	self endon( "death" );	
	while(1)
	{
		wait(.2);
	}
}

swap_nodes_init()
{
	triggers = GetEntArray("swap_node_trigger", "targetname");
	foreach(trigger in triggers)
	{
		trigger thread swap_nodes();
	}
}

swap_nodes()
{
	level endon("end_of_streets_to_dam");
	
	if(isdefined(self.target))
	{
		while(!flag("streets_to_dam_enemies_dead"))
		{
			self waittill("trigger");
			
			wait(.5);
			
			if(level.player istouching(self))
			{
				for ( i = 0; i < level.allies.size; i++ )
				{
					if(level.allies[i] istouching(self))
					{
						new_node = GetNode(self.target, "targetname");
						level.allies[i] SetGoalNode(new_node);
					}
				}				
			}
		}
	}
}

trigger_named_and_turn_off_prior(trigger_targetname_array, end_targetname)
{
	not_done = true;
	for(i=0; i<trigger_targetname_array.size; i++)
	{
		if(not_done)
		{
			if(trigger_targetname_array[i] == end_targetname)
			{
			    trigger = getent(trigger_targetname_array[i], "targetname");
			    if(isdefined(trigger))
			    {
					trigger notify("trigger");
			    }
			    not_done = false;
			}
		    trigger = getent(trigger_targetname_array[i], "targetname");
		    if(isdefined(trigger))
		    {
		    	trigger trigger_off();
		    }
		}
	}
}

set_flag_when_launcher_in_right_spot()
{
	while(!isdefined(level.first_launcher))
	{
		wait(.1);
	}
	//was -9400
	while(level.first_launcher.origin[1] < -10500)
	{
		wait(.1);
	}
	
	flag_set("start_heli_attack");
}

//kill players who run in front of convoy
convoy_check()
{
	while(!isdefined(level.first_launcher))
	{
		wait(.1);
	}
	
//	launcher = level.convoy[level.convoy.size - 1];
	launcher = level.first_launcher;
	
//	finalY = -7400;
	finalY = -8200;
	not_gone = true;
	
	while(not_gone)
	{
		if(!isdefined(launcher))
		{
			fake_launcher = getent("missile_launcher_2", "targetname");
			if(!isdefined(fake_launcher))
			{
				break;				
			}
			else
			{
				launcher = fake_launcher;	
			}
		}
		if(launcher.origin[1] > finalY)
		{
			not_gone = false;		
		}
		
		if(level.player.origin[1] > (launcher.origin[1] - 190))
		{
			if((level.player.origin[0] > (launcher.origin[0]-100)) && (level.player.origin[0] < (launcher.origin[0] + 100)))
			{
				wait(.2);
				level.player Kill();
			}
		}
		wait(.1);
	}
	
	flag_set("convoy_gone");
}

disable_combat_nodes()
{
	node_array = GetNodeArray("nodes_to_disconnect", "targetname");
	foreach(node in node_array)
	{
		node DisconnectNode();
	}
	
	flag_wait("enemy_alerted");
	
	node_array = GetNodeArray("nodes_to_disconnect", "targetname");
	foreach(node in node_array)
	{
		node ConnectNode();
	}			
}

disable_ally_nag_nodes()
{
	node_array = GetNodeArray("nodes_to_disconnect_ally", "script_noteworthy");
	foreach(node in node_array)
	{
		node DisconnectNode();
	}
	
	flag_wait_either("player_on_ladder","streets_to_dam_enemies_dead");
	
	node_array = GetNodeArray("nodes_to_disconnect_ally", "script_noteworthy");
	foreach(node in node_array)
	{
		node ConnectNode();
	}	
}

spawn_rpg_guys()
{
//	trigger = getent("spawn_rpg_guys_failsafe", "targetname");
//   	level thread set_flag_on_trigger(trigger, "rpg_spawn");
//   	level thread set_flag_after_timer("rpg_spawn", 8);
   	
	flag_wait_any("rpg_spawn", "enemy_alerted", "enemy_surprised");
   	
//	IPrintLn("spawning rpg guys");
	
   	enemies = GetEntArray("streets_to_dam_wave_1_rpg", "targetname");
   	array_spawn_function(enemies , ::streets_to_dam_wave_1_rpg_spawn_func);
   	
   	wait(.5);
   	
   	rpg_guy_1 = GetEnt("rpg_guy_2", "script_noteworthy");
   	rpg_target = getent("streets_to_dam_rpg_target_2", "targetname");
   	rpg_guy_1 add_spawn_function(::rpg_guy_wait_and_fire_at_target, rpg_target);
   	rpg_guy_1 = rpg_guy_1 spawn_ai();
   	
//   	wait(4);
	wait(.5);

   	rpg_guy_2 = GetEnt("rpg_guy_1", "script_noteworthy");
   	rpg_target = getent("streets_to_dam_rpg_target_1", "targetname");
   	rpg_guy_2 add_spawn_function(::rpg_guy_wait_and_fire_at_target, rpg_target);
   	rpg_guy_2 = rpg_guy_2 spawn_ai();
   	
   	wait(.5);
   	
//   	rpg_guy_1 clear_ignore_everything();
//   	rpg_guy_2 clear_ignore_everything();

//   	enemies = GetEntArray("streets_to_dam_wave_1_rpg", "targetname");
//    array_thread(enemies , ::spawn_ai);
}



streets_to_dam_wave_1_rpg_spawn_func()
{
//	self ignore_everything(1.0);
	self endon("death");
	
	self thread set_flag_if_damaged();
	
//	self thread maps\_patrol::patrol();
	
	self thread remove_rpgs_on_death();
	
	flag_wait("enemy_alerted");
	self notify( "stop_going_to_node" );
	self clear_ignore_everything();
	self.ignoresuppression = true;
	if(self.script_noteworthy == "rpg_guy_1")
	{
		node = GetNode( "rpg_node_1", "targetname" );
	}
	else
	{
		node = GetNode( "rpg_node_2", "targetname" );
	}
	
	temp_radius = self.goalradius;
	self.goalradius = node.radius;
	self.goalradius = 16;
	self SetGoalNode( node );
	self waittill( "goal" );
	wait(10);
	self.goalradius = temp_radius;
	
	

}

remove_rpgs_on_death()
{
	self waittill("death");
	if(isdefined(self.weapon))
	{
		self gun_remove();
	}
}

streets_to_dam_wave_1_street_patrol_spawn_func()
{
//	self ignore_everything(1.0);
	self endon("death");
	
	self thread maps\_patrol::patrol();
	flag_wait("enemy_alerted");
	self notify( "stop_going_to_node" );
	
	if(flag("convoy_gone"))
	{
		goal_volume = getent("enemies_left_goal_volume", "targetname");
	}
	else
	{
		goal_volume = getent("enemies_convoy_goal_volume", "targetname");
	}
	self setgoalvolumeauto(goal_volume);
	
//	self.favoriteenemy = level.player;
	self.grenadeammo = RandomInt(1);
	
	while(!flag("convoy_gone"))
	{
		wait(.1);
	}
	
	goal_volume = getent("enemies_left_goal_volume", "targetname");
	self setgoalvolumeauto(goal_volume);

	flag_wait("streets_to_dam_enemies_ALMOST_dead");
	
	goal_volume = getent("enemies_left_small_goal_volume", "targetname");
	self setgoalvolumeauto(goal_volume);
}

//streets_to_dam_wave_1_runner_spawn_func()
//{
//	self endon("death");
//	
//	flag_wait("enemy_alerted");
//	
//	if(flag("convoy_gone"))
//	{
//		goal_volume = getent("enemies_left_goal_volume", "targetname");
//	}
//	else
//	{
//		goal_volume = getent("enemies_convoy_goal_volume", "targetname");
//	}
//	self setgoalvolumeauto(goal_volume);
//	
//	self.grenadeammo = RandomInt(1);
//	
//	while(!flag("convoy_gone"))
//	{
//		wait(.1);
//	}
//	
//	goal_volume = getent("enemies_left_goal_volume", "targetname");
//	self setgoalvolumeauto(goal_volume);	
//}

spawn_scaffold_guys()
{
//	IPrintLn("spawn_scaffold_guys()");

//	while(get_ai_group_sentient_count("streets_to_dam_wave_1") > 1)
//	{
//		wait(.1);
//	}
	
//	level thread scaffold_test_1();
//	level thread scaffold_test_2();
//	level thread scaffold_test_3();
	
//	level waittill("spawn_scaffold_guys");
//	IPrintLn("spawning high guys!");
	if(!flag("player_on_ladder"))
	{
//		IPrintLn("spawning high guys!");
		enemies = GetEntArray("streets_to_dam_wave_1_5_scaffold", "targetname");
//		foreach ( guy in enemies)
//		{
//			guy_name = guy spawn_ai();
//			wait(.1);
//			IPrintLn("Just spawned a guy!!");
//		}
		
	    array_thread(enemies , ::spawn_ai);
	}
	
//	while(get_ai_group_sentient_count("streets_to_dam_wave_1") > 1)
//	{
//		wait(.1);
//	}
	
	//move allies to cover against scaffold guys
	trigger = getent("scaffold_guys_fight", "targetname");
	trigger notify("trigger");
//	IPrintLn("scaffold_guys_fight trigger");
//	streets_to_dam_wave_1_5_high
	
//    IPrintLn("spawned high guys!");
}

//scaffold_test_1()
//{
//	wait(.5);
//	waittill_aigroupcount("streets_to_dam_wave_1_5", 2);
//	
//	level notify("spawn_scaffold_guys");
//}

scaffold_test_2()
{
//	IPrintLn("scaffold_test_2");
	wait(.5);

//	trigger = getent("streets_to_dam_outside_garage", "targetname");
//	if(isdefined(trigger))
//	{
//   		trigger waittill("trigger");
//	}
	
	while((get_ai_group_sentient_count("streets_to_dam_wave_1") + get_ai_group_sentient_count("rpg_guys")) > 1)
	{
		wait(.1);
	}
	
//	while(get_ai_group_sentient_count("rpg_guys") > 0)
//	{
//		wait(.1);
//	}
//	
//	IPrintLn("notify scaffold guys");
	level notify("spawn_scaffold_guys");
}

scaffold_test_3()
{
//	wait(10.0);
//	flag_wait("enemy_alerted");
	
//	flag_wait("streets_to_dam_enemies_ALMOST_dead");
	
	wait(1.0);
		
	level notify("spawn_scaffold_guys");
}

streets_to_dam_wave_1_spawn_func()
{
	self endon("death");
//	goal_volume = getent("streets_to_dam_goal_volume_1", "targetname");
	self ignore_everything();
	

//	flag_wait_either("enemy_alerted", "enemy_surprised");
	flag_wait("enemy_alerted");
	
	goal_volume = getent("enemies_convoy_goal_volume", "targetname");
	self setgoalvolumeauto(goal_volume);
	
	wait(2.0);
	
//	IPrintLn("enemy fully alert");

	if(flag("convoy_gone"))
	{
		goal_volume = getent("enemies_left_goal_volume", "targetname");
	}
	else
	{
		goal_volume = getent("enemies_convoy_goal_volume", "targetname");
	}
	self setgoalvolumeauto(goal_volume);
	
//	self.favoriteenemy = level.player;
	self.grenadeammo = RandomInt(1);
	
	while(!flag("convoy_gone"))
	{
		wait(.1);
	}
	
	goal_volume = getent("enemies_left_goal_volume", "targetname");
	self setgoalvolumeauto(goal_volume);
	
	flag_wait("streets_to_dam_enemies_ALMOST_dead");
	
	goal_volume = getent("enemies_left_small_goal_volume", "targetname");
	self setgoalvolumeauto(goal_volume);
	
//	trigger = getent("streets_to_dam_wave_1_fallback", "targetname");
//	trigger waittill("trigger");
		
//	self.favoriteenemy = level.player;
	
//	goal_volume = getent("streets_to_dam_goal_volume_1", "targetname");
//	self setgoalvolumeauto(goal_volume);
	
}

streets_to_dam_drive_missile_launcher()
{
	fake_launcher = getent("missile_launcher_2", "targetname");
	
	flag_wait("rpg_fired_at_launcher");
	
	level thread show_missile_launcher_collision();
//	flag_wait("missile_destroy_keegan_ready");
	
	//	level waittill("ally_at_launcher_destruction_node");
	
	wait(.2);
	
//	level thread fake_drive_convoy_crash();
	
	level notify( "objective_disable_launcher_1" );
	
	//thread maps\flood_audio::sfx_missile_buzzer(level.first_launcher, "sfx_launcher_destroyed");
	
	flag_wait("player_on_ladder");
	
	level.first_launcher notify("stop_crash_loop");
	level.first_launcher StopAnimScripted();
	missile_launcher_destruction_vignette();
	
	//blow up launcher
	if( level.stabbed )
	{
		wait(1.0);
    	//PlayFX( level._effect[ "blackhawk_explosion" ], level.first_launcher.origin );
	}
    
}

//fake_drive_convoy_crash()
//{
////	//get node
////	node = GetVehicleNode("tank_crash_start", "targetname");
//	//get tank
////	tank = level.convoy[level.convoy.size-2];
//	tank = level.convoy_tank;
//	tank godon();
//	
//	while(tank.origin[1] < -7100)
//	{
//		wait(.1);
//	}
//	tank godoff();
//	tank delete();
//	
////	
////	tank vehicleDriveTo(node.origin, tank Vehicle_GetSpeed());
//}

m880_open_path_init()
{
	open_path_array = GetEntArray("m880_show_to_open_path","targetname");
	foreach ( element in open_path_array)
	{
		element hide();
	}	
}

m880_open_path()
{
	open_path_array = GetEntArray("m880_delete_to_open_path","targetname");
	foreach ( element in open_path_array)
	{
		element delete();
	}
	open_path_array = GetEntArray("m880_show_to_open_path","targetname");
	foreach ( element in open_path_array)
	{
		element show();
	}
}

m880_connect_path_nodes(connect)
{
	wait(3.0);
	pathnodes = GetNodeArray("m880_kill_connect_nodes","targetname");
	foreach ( node in pathnodes)
	{
		if(connect)
		{
			node ConnectNode();
//			IPrintLn("connecting node");
		}
		else
		{
			node DisconnectNode();
//			IPrintLn("disconnecting node");
		}
	}
	
//	while(!isdefined(level.allied_tank_2))
//	{
//		wait(.1);
//	}
	
//	flag_wait("missile_launcher_destruction_done");
	
//	wait(10);
	
//	pathnodes = GetNodeArray("m880_kill_connect_nodes","targetname");
//	foreach ( node in pathnodes)
//	{
//		node ConnectNode();
//	}
	
}

missile_launcher_vo()
{
	if(!flag("player_on_ladder"))
	{
		level.allies[1] smart_dialogue("flood_diz_multiplesams");
		wait(3.0);
	}
	if(!flag("player_on_ladder"))
	{
		level.allies[0] smart_dialogue("flood_bkr_getinposition");
	}
}

missile_launcher_destruction_vignette()
{
	
	
//	level.player FreezeControls(true);
//	
//	IPrintLnBold("Player climbs up launcher and throws grenade into cab");
	
//	level thread missile_launcher_destruction_vignette_allies();
	level thread ignore_player(true);
	delayThread(2.0, ::ignore_player, false);
	
	//changing shadow draw distance for better looking shad here
	SetSavedDvar("sm_sunSampleSizeNear", .15);
	
	mlrs_kill1_spawn();
	level thread missile_launcher_destruction_vignette_allies();
	wait(.5);
	
//	level thread ignore_player(false);
//	
//	teleport_spot = getent("post_missile_launcher_location", "targetname");
//	level.player teleport_player(teleport_spot);
//		
//	level.player FreezeControls(false);
	
	level thread m880_open_path();
	
	level thread autosave_now();
	
	flag_set("missile_launcher_destruction_done");
	
	thread maps\flood_audio::sfx_stop_buzzer("sfx_launcher_destroyed");	
	
	//changing shadow draw distance back to something further
	SetSavedDvar("sm_sunSampleSizeNear", .25);
}

missile_launcher_destruction_vignette_allies()
{
	//delay so the player will see allies run to new locations
//	wait(2.5);
	
//	IPrintLn("teleport ally 0");
	teleport_spot = getent("post_missile_launcher_location_ally1", "targetname");
	level.allies[0] ForceTeleport(teleport_spot.origin, teleport_spot.angles);
	level.allies[0] ignore_everything();
//	IPrintLn("teleport ally 1");
	teleport_spot = getent("post_missile_launcher_location_ally2", "targetname");
	level.allies[1] ForceTeleport(teleport_spot.origin, teleport_spot.angles);
	level.allies[1] ignore_everything();
//	IPrintLn("teleport ally 2");
	teleport_spot = getent("post_missile_launcher_location_ally3", "targetname");
	level.allies[2] ForceTeleport(teleport_spot.origin, teleport_spot.angles);
	level.allies[2] ignore_everything();
	
//	nodes = GetEntArray("post_missile_launcher_path_node", "targetname");
//	foreach ( node in nodes)
//	{
//		node ConnectNode();
//	}
	
	//delay so the player will see allies run to new locations
	wait(7.0);
	level.allies[0] clear_ignore_everything();
	level.allies[1] clear_ignore_everything();
	level.allies[2] clear_ignore_everything();
	wait(.5);
	trigger = getent("streets_to_dam_wave_2_start", "targetname");
	if(isdefined(trigger))
	{
		trigger notify("trigger");
	}
}


mlrs_kill1_spawn()
{
//	mlrs_kill1_m880 = vignette_vehicle_spawn("dam_break_m880", "mlrs_kill1_m880"); //"value" (kvp), "anim_name"
	mlrs_kill1_m880 = level.first_launcher;
	mlrs_kill1_m880.animname = "mlrs_kill1_m880";
	mlrs_kill1_opfor = vignette_drone_spawn("vignette_mrls_kill_opfor", "mlrs_kill1_opfor"); //"value" (kvp), "anim_name"
	
	mlrs_kill1_start(mlrs_kill1_m880, mlrs_kill1_opfor);
	//MM - Use this for no prompt m880 kill
	//MM - Need to add ladder brush to get to trigger volume...or lower trigger volume.
//	mlrs_kill1_no_prompt(mlrs_kill_player_body, mlrs_kill_opfor);

	mlrs_kill1_opfor delete();
}

mlrs_kill1_start(mlrs_kill1_m880, mlrs_kill1_opfor)
{
	node = getstruct("vignette_m880_crash", "script_noteworthy");
	
	mlrs_kill1_knife = spawn_anim_model("mlrs_kill1_knife");
	mlrs_kill1_knife DontCastShadows();
	mlrs_kill1_gun = spawn_anim_model("mlrs_kill1_gun");
	
//	m880_radiation_gate = spawn_anim_model("m880_radiation_gate");
	
//	node.origin = (-1601.8, -7977.7, -63);
//	node.angles = (0, 236, 0);
	
	//set friendly name display distance to 0 for now so it doesn't display on the player leg rig
	g_friendlyNameDist_old = GetDvarInt( "g_friendlyNameDist" );
	SetSavedDvar( "g_friendlyNameDist", 0 );
	
	level.player EnableInvulnerability();
	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );
	level.player DisableWeapons();
	
//	player_speed_mod = (length(level.player GetVelocity())+.1)/45;
//	player_speed_mod = 1;
//	IPrintLn("player speed mod = " + player_speed_mod);
//	wait(.2);
	level.player stopsliding();
//	SetDvar("slide_enable", "1");

	//trying to make sure player is in "stand" before they play the anims
	if(level.player GetStance() == "prone")
	{
		level.player SetStance("crouch");
		while(level.player GetStance() != "crouch")
		{
			waitframe();
		}
	}
	
	if(level.player GetStance() == "crouch")
	{
		level.player SetStance("stand");
		while(level.player GetStance() != "stand")
		{
			waitframe();
		}
	}
	
	level.player allowprone( false );
	level.player allowcrouch( false );
	player_rig = spawn_anim_model( "player_rig" );
	player_rig DontCastShadows();
	level.player thread delay_hide_view_model(.4);	
	player_rig thread hide_and_show(.45);
	
	guys = [];
//	guys["mlrs_kill1_m880"] = mlrs_kill1_m880;
	guys["player_rig"] = player_rig;
	guys["mlrs_kill1_opfor"] = mlrs_kill1_opfor;
	guys["mlrs_kill1_knife"] = mlrs_kill1_knife;
	guys["mlrs_kill1_gun"] = mlrs_kill1_gun;
//	guys["m880_radiation_gate"] = level.m880_radiation_gate;

	node anim_first_frame(guys, "mlrs_kill1_start");
	//LinkToBlendToTag
//
//	wait( 0.05 );
//	//move anim hands to ladder before moving player	
//	node anim_set_time( guys, "mlrs_kill1_start", 0.1 );
	
	thread player_wait_link_to_blend(0.0, player_rig);
	
//	lerp_speed = .25;
//	level.player PlayerLinkToBlend( player_rig, "tag_player", lerp_speed,.125,.125);
		
//IPrintLn("moving m880");

	mlrs_kill1_m880 move_to_anim_start_point("mlrs_kill1_m880", "mlrs_kill1_start", node, 0.0);
//IPrintLn("done moving m880");

//	wait(2.0);	
	level.m880_radiation_gate thread move_to_anim_start_point("m880_radiation_gate", "mlrs_kill1_start", node, .2);
	
//	wait(2.0);
	
	//find where it is, where it needs to go, blend between them...	

	arc = 15;	

//	IPrintLn("starting link to blend");
//	lerp_speed = .25/player_speed_mod;
//	lerp_speed = .25;
//	level.player PlayerLinkToBlend( player_rig, "tag_player", lerp_speed,.125,.125);
//	IPrintLn("stopping link to blend");
//	wait(.2);
//	wait(.25 * player_speed_mod);
//	wait(2);
//	IPrintLn("after wait");
	level thread m880_kill1_start_spring_cam(player_rig,.5);	
//	level.player SpringCamEnabled( 1, 3.2, 1.6 );

	thread maps\flood_audio::mssl_launch_destory_sfx();
	
	flag_init( "qte_window_closed" );
	level.stabbed = false;
	
	//Plays barricade anims when m880 starts to back up
	thread mlrs_kill1_barricades( node );
	
	guys = [];
	guys["mlrs_kill1_m880"] = mlrs_kill1_m880;
	guys["player_rig"] = player_rig;
	guys["mlrs_kill1_opfor"] = mlrs_kill1_opfor;
	guys["mlrs_kill1_knife"] = mlrs_kill1_knife;
	guys["mlrs_kill1_gun"] = mlrs_kill1_gun;
	guys["m880_radiation_gate"] = level.m880_radiation_gate;
	
	node anim_single(guys, "mlrs_kill1_start");
		
	flag_set( "qte_window_closed" );
	
	if( !level.stabbed )
	{
		level notify("player_failed_stab");
		MagicBullet("microtar", mlrs_kill1_gun.origin, level.player.origin);
		level.lnchr_dstry_sfx StopSounds( );
		level thread player_vision_blind();
		thread m880_kill1_fail( node, player_rig, mlrs_kill1_opfor, mlrs_kill1_knife, mlrs_kill1_gun );		
		level.convoy_tall_barricade_01 hide();
		level.convoy_tall_barricade_02 hide();
		SetSlowMotion( 0.25, 1.0, 0.25 );
		wait(1.0);
		SetDvar( "ui_deadquote", &"FLOOD_LAUNCHER_QTE_FAIL" );
		level thread maps\_utility::missionFailedWrapper();
	}
	else
	{
//		thread mlrs_kill1_end( node, player_rig, mlrs_kill_player_body, mlrs_kill_opfor );
		mlrs_kill1_end_spawn( node, player_rig, mlrs_kill1_m880, mlrs_kill1_opfor, mlrs_kill1_knife, mlrs_kill1_gun, level.m880_radiation_gate );
	
//		wait(5.25);
		
		level.player unlink();
		level.player ShowViewModel();
		player_rig delete();
	
//		loc = getent("m880_kill_teleport", "targetname");
//		teleport_player(loc);
		
		level.player EnableWeapons();
		level.player FreezeControls( false );
		level.player allowprone( true );
		level.player allowcrouch( true );
	}
	//set friendly name display distance back
	SetSavedDvar( "g_friendlyNameDist", g_friendlyNameDist_old );
	level.player DisableInvulnerability();
	// added by JKU.  Chopper flyby, placed here because it's loosely timed to when you destroy the first launcher
	level delayThread( 2, ::spawn_vehicles_from_targetname_and_drive, "streets_enemy_dam_chopper" );
}

delay_hide_view_model(timer)
{
	wait(timer);
	self HideViewModel();
}

player_wait_link_to_blend(wait_time, player_rig)
{
	wait(wait_time);
	lerp_speed = .25;
	//.125
	level.player PlayerLinkToBlend( player_rig, "tag_player", lerp_speed,0,0);	
}
//display_player_speed()
//{
//	while(1)
//	{
//		player_vel = level.player GetVelocity();
//		speed = Length(player_vel);
//		IPrintLn("player speed is: " + speed);
//		wait(.1);
//	}
//}

move_to_anim_start_point(scene_name, anim_name, anim_point, timer)
{
	animation = level.scr_anim[ scene_name ][ anim_name ];
//	anim_point = node;
	struct = Spawn("script_origin", (0,0,0));
	struct.origin = GetStartOrigin( anim_point.origin, anim_point.angles, animation );
	struct.angles = GetStartAngles( anim_point.origin, anim_point.angles, animation );
	
	if(self isVehicle())
	{
//		IPrintLn("self is a vehicle");
//		wait(.2);
		
//		level.player PlayerLinkToBlend(self, "tag_ladder", .5);
//		level.player PlayerLinkedOffsetEnable();			
		
		self Vehicle_OrientTo(struct.origin, struct.angles, 0, 0);
		self waittill( "orientto_complete" );
		self notify( "suspend_drive_anims" );
//		IPrintLn("done moving vehicle");
//		level.player Unlink();
	}
	else
	{
		start_point = Spawn("script_origin", (0,0,0));
		start_point.origin = self.origin;
		start_point.angles = self.angles;	
		self LinkTo(start_point);	
		
		start_point MoveTo(struct.origin,timer);
		start_point RotateTo(struct.angles,timer);

		self Unlink();
		start_point delete();
	}
	
	struct delete();
	
}

m880_kill1_start_spring_cam(player_rig, timer)
{
	wait(timer);
	arc = 15;
	
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	level.player SpringCamEnabled( 1, 3.2, 1.6 );
}

//Fail condition
m880_kill1_fail( node, player_rig, mlrs_kill1_opfor, mlrs_kill1_knife, mlrs_kill1_gun )
{

	node = getstruct("vignette_m880_crash", "script_noteworthy");

//	mlrs_kill1_knife = spawn_anim_model("mlrs_kill1_knife");

//	mlrs_kill1_gun = spawn_anim_model("mlrs_kill1_gun");

	guys = [];
	guys["mlrs_kill1_opfor"] = mlrs_kill1_opfor;
	guys["player_rig"] = player_rig;
	guys["mlrs_kill1_knife"] = mlrs_kill1_knife;
	guys["mlrs_kill1_gun"] = mlrs_kill1_gun;

	node anim_single(guys, "m880_kill1_fail");


}

m880_kill_collision_change()
{
	collision_array = GetEntArray("clip_after_m880_kill", "targetname");
	foreach ( brush in collision_array)
	{
		brush hide();
		brush NotSolid();
	}
	
	flag_wait("missile_launcher_destruction_done");
	
	collision_array = GetEntArray("clip_after_m880_kill", "targetname");
	foreach ( brush in collision_array)
	{
		if(level.player istouching(brush))
		{
			brush thread maps\flood_anim::push_player_out_of_brush((-20,0,0));
		}
		else
		{
			brush show();
			brush Solid();
		}
		
	}
}

//MM - Use this for no prompt m880 kill
//mlrs_kill1_no_prompt(mlrs_kill_player_body, mlrs_kill_opfor)
//{
//	node = getstruct( "vignette_mlrs_kill1_node", "script_noteworthy" );
//	
////	node.origin = (-1601.8, -7977.7, -63);
////	node.angles = (0, 236, 0);
//	
//	level.player FreezeControls( true );
//	level.player allowprone( false );
//	level.player allowcrouch( false );
//	level.player DisableWeapons();
//
//	player_rig = spawn_anim_model( "player_rig" );
//	
//	guys = [];
//	guys["player_rig"] = player_rig;
//
//	player_rig hide();
//	
//	//MM - Comment this out for no prompt
////	guys["mlrs_kill_player_body"] = mlrs_kill_player_body;
//	guys["mlrs_kill_opfor"] = mlrs_kill_opfor;
//
//	thread maps\flood_audio::mssl_launch_destory_sfx();
//	
//	flag_init( "qte_window_closed" );
//	level.stabbed = false;
//	
//	//start anim 50% of the way through...
//	delaythread( 0.05, ::anim_set_time, guys, "mlrs_kill1", .5 );
//	delaythread( 0.05, ::link_player_to_anim, player_rig);
//	node anim_single( guys, "mlrs_kill1" );
//		
//	flag_set( "qte_window_closed" );
//	
//	if( !level.stabbed )
//	{
//		SetSlowMotion( 0.25, 1.0, 0.05 );
//		SetDvar( "ui_deadquote", &"FLOOD_LAUNCHER_QTE_FAIL" );
//		level thread maps\_utility::missionFailedWrapper();
//	}
//	else
//	{
//		thread mlrs_kill1_end_no_prompt( node, player_rig, mlrs_kill_player_body, mlrs_kill_opfor );
//	
//		wait(5.25);
//		
//		level.player unlink();
//		level.player ShowViewModel();
//		player_rig delete();
//	
//		loc = getent("m880_kill_teleport", "targetname");
//		teleport_player(loc);
//		
//		level.player EnableWeapons();
//		level.player FreezeControls( false );
//		level.player allowprone( true );
//		level.player allowcrouch( true );
//	}
//}

//MM - Use this for no prompt m880 kill
//link_player_to_anim(player_rig)
//{
//	arc = 15;
//	level.player PlayerLinkToBlend( player_rig, "tag_player", .5);
//}

mlrs_kill1_end_spawn( node, player_rig, mlrs_kill1_m880, mlrs_kill1_opfor, mlrs_kill1_knife, mlrs_kill1_gun, m880_radiation_gate )
{
	mlrs_kill1_end_player_legs = vignette_drone_spawn("vignette_mrls_kill_player_body", "mlrs_kill1_end_player_legs"); //"value" (kvp), "anim_name"

	mlrs_kill1_end( node, player_rig, mlrs_kill1_m880, mlrs_kill1_opfor, mlrs_kill1_knife, mlrs_kill1_gun, mlrs_kill1_end_player_legs, m880_radiation_gate );

	mlrs_kill1_end_player_legs vignette_actor_delete();
}

mlrs_kill1_end( node, player_rig, mlrs_kill1_m880, mlrs_kill1_opfor, mlrs_kill1_knife, mlrs_kill1_gun, mlrs_kill1_end_player_legs, m880_radiation_gate )
{
	mlrs_kill1_end_grenade = spawn_anim_model("mlrs_kill1_end_grenade");
	mlrs_kill1_end_grenade DontCastShadows();
	guys = [];
	//guys["mlrs_kill1_m880"] = mlrs_kill1_m880;
	guys["player_rig"] = player_rig;
	guys["mlrs_kill1_opfor"] = mlrs_kill1_opfor;
	guys["mlrs_kill1_knife"] = mlrs_kill1_knife;
	guys["mlrs_kill1_end_player_legs"] = mlrs_kill1_end_player_legs;
	guys["mlrs_kill1_end_grenade"] = mlrs_kill1_end_grenade;
	guys["mlrs_kill1_gun"] = mlrs_kill1_gun;
	guys["m880_radiation_gate"] = m880_radiation_gate;

	thread play_mlrs_m880_end( node, mlrs_kill1_m880 );
	node anim_single(guys, "mlrs_kill1_end");

	if(isdefined(mlrs_kill1_knife))
	{
		mlrs_kill1_knife delete();
	}
	
	if(isdefined(mlrs_kill1_end_grenade))
	{
		mlrs_kill1_end_grenade delete();
	}
}

play_mlrs_m880_end( node, mlrs_kill1_m880 )
{
	guys = [];
	guys["mlrs_kill1_m880"] = mlrs_kill1_m880;
	
	node anim_single(guys, "mlrs_kill1_end");
	
//	mlrs_kill1_m880 vignette_vehicle_delete();
}

mlrs_kill1_barricades( node )
{
	mlrs_kill1_barricade_01 = spawn_anim_model("mlrs_kill1_barricade_01");

	mlrs_kill1_barricade_02 = spawn_anim_model("mlrs_kill1_barricade_02");

//	mlrs_kill1_barricade_01 hide();
	mlrs_kill1_barricade_01 thread hide_and_show(1.0);
//	mlrs_kill1_barricade_02 hide();
	mlrs_kill1_barricade_02 thread hide_and_show(1.0);
	
	guys = [];
	guys["mlrs_kill1_barricade_01"] = mlrs_kill1_barricade_01;
	guys["mlrs_kill1_barricade_02"] = mlrs_kill1_barricade_02;

	node anim_single(guys, "mlrs_kill1_barricades");

}

hide_and_show(timer)
{
	self hide();
	wait(timer);
	self show();
}


//use this for no prompt m880 destruction vignette
//mlrs_kill1_end_no_prompt(node, player_rig, mlrs_kill_player_body, mlrs_kill_opfor)
//{
//	//MM Comment this in for no prompt
//	arc = 15;
//	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
//	player_rig show();
//	
//	mlrs_grenade = spawn_anim_model("mlrs_grenade");
//
//	mlrs_knife = spawn_anim_model("mlrs_knife");
//
//	guys = [];
//	guys["player_rig"] = player_rig;
//	guys["mlrs_kill_player_body"] = mlrs_kill_player_body;
//	guys["mlrs_kill_opfor"] = mlrs_kill_opfor;
//	guys["mlrs_grenade"] = mlrs_grenade;
//	guys["mlrs_knife"] = mlrs_knife;
//
//	node anim_single(guys, "mlrs_kill1_end");
//
//	if(isdefined(mlrs_knife))
//	{
//		mlrs_knife delete();
//	}
//	
//	if(isdefined(mlrs_grenade))
//	{
//		mlrs_grenade delete();
//	}
//}

mlrs_start_qte( guy )
{
	thread mlrs_qte_prompt();

	SetSlowMotion( 1.0, 0.25, 0.5 );
	
	while( 1 )
	{
		if (level.player MeleeButtonPressed())
		{
			flag_set( "qte_window_closed" );
			SetSlowMotion( 0.25, 1.0, 0.05 );
			level.stabbed = true;
			return;
		}
		
		wait( 0.05 );
	}
}

mlrs_stop_qte_hint()
{
	if( flag( "qte_window_closed" ) )
		return true;
	else
		return false;
}

//drives entity from start node to the end of the node chain
//fake_drive_missile_launcher(start_node, teleport)
//{
//	if(teleport)
//	{
//	//teleport ML to the start node
//	self.origin = start_node.origin;
//	self.angles = start_node.angles;// + (0,90,0);
//	}
//	
//	if(isdefined(start_node.target))
//	{
//		next_node = true;
//		end_node = start_node.target;
//		end_node = GetVehicleNode(end_node, "targetname");
//		node_speed = start_node.speed;
//		
//		while(next_node)
//		{
//			//self move_with_rate(end_node.origin, end_node.angles + (0,90,0), node_speed);
//			self move_with_rate(end_node.origin, end_node.angles, node_speed);
//			if(isdefined(end_node.target))
//			{
//				next_node = true;
//				//speed is set by the node you have arrived at
//				node_speed = end_node.speed;
//				//get new end_node
//				end_node = end_node.target;
//				end_node = GetVehicleNode(end_node, "targetname");
//				
//			}
//			else
//			{
//				next_node = false;
//			}
//		}
//	}
//	
//	flag_set("missile_launcher_in_place");
//
//}

ladder_spot_glow()
{
	while(!IsDefined(level.first_launcher))
	{
		wait(.1);
	}
	
	flag_wait("missile_launcher_in_place");

	objmodel = "vehicle_m880_launcher_obj";

	org = level.first_launcher GetTagOrigin( "tag_ladder" );
	spawned = Spawn( "script_model", org );
	spawned SetModel( objmodel );
	spawned LinkTo( level.first_launcher, "tag_ladder", ( 0, 0, 0 ), ( 0, 0, 0 ) );
//	level.first_launcher attach("vehicle_m880_launcher_obj", "tag_ladder", true);
	
	flag_wait("player_on_ladder");
	
	wait(3.0);
	
	spawned delete();
//	level.first_launcher Detach("vehicle_m880_launcher_obj", "tag_ladder");

}

wait_for_player_to_use_ladder()
{
//	trigger = getent("player_climb_ladder_trigger", "targetname");
	trigger = getent("player_climb_ladder_trigger_no_use", "targetname");
	trigger trigger_off();
	
	flag_wait("missile_launcher_in_place");
	//send ranger allies to final spots
	trigger = getent("checkpoint_done", "targetname");
	trigger notify("trigger");
	
	//if player hasn't gone down to street yet...turn off color trigger
	trigger = getent("streets_to_dam_garage_exit", "targetname");
	if(IsDefined(trigger))
	{
		trigger trigger_off();
	}
	
	level thread end_of_combat_autosave();
	
//	trigger = getent("player_climb_ladder_trigger", "targetname");
	trigger = getent("player_climb_ladder_trigger_no_use", "targetname");
	trigger trigger_on();
//	trigger SetHintString( &"FLOOD_DISABLE_LAUNCHER" );
//	trigger UseTriggerRequireLookAt();
	
	trigger waittill("trigger");
	
	flag_set("player_on_ladder");

	trigger = getent("player_climb_ladder_trigger", "targetname");
	trigger trigger_off();
	
	kill_deathflag("streets_to_dam_checkpoint_enemies");
	kill_deathflag("streets_to_dam_checkpoint_enemies_close");
	kill_deathflag("rpg_guys");
	
}

//Use this for no prompt m880 destruction
//Player climbs ladder brush model and then triggers flag when at top of ladder
//wait_for_player_to_use_ladder_no_prompt()
//{
//	trigger = getent("player_climb_ladder_trigger_walk_up", "targetname");
//	trigger trigger_off();
//	
//	flag_wait("missile_launcher_in_place");
//	//send ranger allies to final spots
//	trigger = getent("checkpoint_done", "targetname");
//	trigger notify("trigger");
//	
//	//if player hasn't gone down to street yet...turn off color trigger
//	trigger = getent("streets_to_dam_garage_exit", "targetname");
//	if(IsDefined(trigger))
//	{
//		trigger trigger_off();
//	}
//	
//	level thread end_of_combat_autosave();
//
//	trigger = getent("player_climb_ladder_trigger_walk_up", "targetname");
//	trigger trigger_on();
//	
//	trigger waittill("trigger");
//	
//	flag_set("player_on_ladder");
//
//	trigger = getent("player_climb_ladder_trigger_walk_up", "targetname");
//	trigger trigger_off();
//	
//	kill_deathflag("streets_to_dam_checkpoint_enemies");
//	kill_deathflag("streets_to_dam_checkpoint_enemies_close");
//	kill_deathflag("rpg_guys");
//	
//}

end_of_combat_autosave()
{
	flag_wait("streets_to_dam_enemies_dead");
	
	if(!flag("player_on_ladder"))
	{
		trigger = getent("streets_to_dam_end_combat_autosave", "targetname");
		trigger waittill("trigger");
		
		thread autosave_now();
	}
}

block_garage_exit()
{
	garage_exit = getent("garage_exit_player_clip", "targetname");
	garage_exit hide();
	garage_exit NotSolid();
	
	trigger = getent("streets_to_dam_end_combat_autosave", "targetname");
	trigger waittill("trigger");
	
	garage_exit show();
	garage_exit Solid();
	
}

teleport_failsafe()
{
	wait(10.5);
	volume = getent("streets_to_dam_end_combat_autosave", "targetname");
//	IPrintLn("teleport_failsafe checking ally 0");
	if(level.allies[0] IsTouching(volume))
	{
//		IPrintLn("teleport failsafe ally 0");
		teleport_spot = getent("post_missile_launcher_location_ally1", "targetname");
		level.allies[0] ForceTeleport(teleport_spot.origin, teleport_spot.angles);
	}
//	IPrintLn("teleport_failsafe checking ally 1");
	if(level.allies[1] IsTouching(volume))
	{
//		IPrintLn("teleport failsafe ally 1");
		teleport_spot = getent("post_missile_launcher_location_ally2", "targetname");
		level.allies[1] ForceTeleport(teleport_spot.origin, teleport_spot.angles);
	}
//	IPrintLn("teleport_failsafe checking ally 2");
	if(level.allies[2] IsTouching(volume))
	{
//		IPrintLn("teleport failsafe ally 2");
		teleport_spot = getent("post_missile_launcher_location_ally3", "targetname");
		level.allies[2] ForceTeleport(teleport_spot.origin, teleport_spot.angles);
	}
}
//magic_rpg_attack()
//{
//	trigger = getent("streets_to_dam_rpg_spawn", "targetname");
//	trigger waittill("trigger");
//	
//	start = GetEnt("rpg_origin", "targetname");
//	end = GetEnt("rpg_target", "targetname");
//	
//	missile = MagicBullet("rpg_straight", start.origin, end.origin + (-300,100,0));
////	missile = MagicBullet("stinger_speedy", start.origin, end.origin + (-300,100,0));
//}

make_allies_shoot_at_targets()
{
//	trigger = getent("run_to_gate", "targetname");
//	trigger waittill("trigger");
//	
//	waittill_aigroupcleared("streets_to_dam_wave_1");
//	waittill_aigroupcleared("streets_to_dam_wave_1_5");
	
	flag_wait_either("player_on_ladder","streets_to_dam_enemies_dead");
	if(!flag("player_on_ladder"))
	{
		trigger = getent("streets_to_dam_garage_exit", "targetname");
		if(isdefined(trigger))
		{
			trigger notify("trigger");
			wait(1.0);
		}
		wait(0.2);
//		IPrintLn("make_allies_shoot_at_targets - enemies_dead");
		go_to_node = GetNode("streets_to_dam_ally_0_node", "targetname");
		level.allies[0] SetGoalNode(go_to_node);
//		level.allies[0] thread play_ally_launcher_vignette_wrapper("launcher_callout_ally01", go_to_node, maps\flood_anim::launcher_callout_ally01, "player_on_ladder");
			
		trigger = getent("streets_to_dam_garage_exit", "targetname");
		if(isdefined(trigger))
		{
			wait(2.0);
		}
		go_to_node = GetNode("streets_to_dam_ally_1_node", "targetname");
//		level.allies[1] SetGoalNode(go_to_node);
		level.allies[1] thread play_ally_launcher_vignette_wrapper("launcher_callout_ally02", go_to_node, maps\flood_anim::launcher_callout_ally02, "player_on_ladder", (0,0,0));
		
		trigger = getent("streets_to_dam_garage_exit", "targetname");
		if(isdefined(trigger))
		{
			wait(2.0);
		}
		go_to_node = GetNode("streets_to_dam_ally_2_node", "targetname");
//		level.allies[2] SetGoalNode(go_to_node);
		level.allies[2] thread play_ally_launcher_vignette_wrapper("launcher_callout_ally03", go_to_node, maps\flood_anim::launcher_callout_ally03, "player_on_ladder", (0,225,0));
		
		flag_wait("player_on_ladder");
		
		level.allies[0] notify("player_now_on_ladder");
		level.allies[1] notify("player_now_on_ladder");
		level.allies[2] notify("player_now_on_ladder");
		level.allies[0] ClearEntityTarget();
		level.allies[1] ClearEntityTarget();
		level.allies[2] ClearEntityTarget();
	}
	else
	{
//		IPrintLn("make_allies_shoot_at_targets - player_on_ladder");	
	}
}

play_ally_launcher_vignette_wrapper(anim_name, go_to_node, anim_func, flag_to_wait_for, new_angles)
{
	old_anim = self.animname;
	old_radius = self.goalradius;
	
	self play_ally_launcher_vignette(anim_name, go_to_node, anim_func, flag_to_wait_for, new_angles);
//	if(!flag(flag_to_wait_for))
//	{
	self StopAnimScripted();
	if(IsDefined(old_anim))
	{
		self.animname = old_anim;
	}
	
	self.goalradius = old_radius;	
//	}
}

play_ally_launcher_vignette(anim_name, go_to_node, anim_func, flag_to_wait_for, new_angles)
{
	self endon("player_now_on_ladder");
//	node = GetNode(go_to_node, "targetname");
	self SetGoalNode(go_to_node);
//	old_radius = self.goalradius;
	self.goalradius = 16;
	self waittill("goal");
	
//	IPrintLn("made it to GOAL");
	
//	old_anim = self.animname;
	self.animname = anim_name;
	
	if(isdefined(flag_to_wait_for))
	{
		while(!flag(flag_to_wait_for))
		{
			level waittill("nagging");
			
			wait(RandomFloatRange(0.2,1.0));
			
			if(isdefined(new_angles))
			{
				[[anim_func]](self, go_to_node.origin, new_angles);
			}
			else
			{
				[[anim_func]](self, go_to_node.origin, go_to_node.angles);
			}
				
				
//	if(isdefined(flag_to_wait_for))
//	{
//		flag_wait(flag_to_wait_for);
//	}
		}
	}
//	self StopAnimScripted();
//	if(IsDefined(old_anim))
//	{
//		self.animname = old_anim;
//	}
//	
//	self.goalradius = old_radius;
}

hide_unhide_crashed_convoy(hide)
{
	if(hide)
	{
	//hide em
		vehicle = getent("crashed_truck", "targetname");
		if(isdefined(vehicle))
		{
		vehicle hide();
//		vehicle NotSolid();
		}
		
		vehicle = getent("crashed_tank", "targetname");
		if(isdefined(vehicle))
		{
			vehicle delete();
//			vehicle NotSolid();
		}
		
		vehicle = getent("crashed_m880", "targetname");
		if(isdefined(vehicle))
		{
			vehicle delete();
//			vehicle NotSolid();
		}
		
		flag_wait("player_on_ladder");
	
	}
//unhide em	
	vehicle = getent("crashed_truck", "targetname");
	if(isdefined(vehicle))
	{
		wait(2.0);
		vehicle show();	
	}
	
//	vehicle = getent("crashed_m880", "targetname");
//	if(isdefined(vehicle))
//	{
//		vehicle show();
//		vehicle Kill();
//	}	
}

dialogue_streets_to_dam()
{
	battlechatter_off("allies");
	
//	trigger = getent("spawn_scaffold_guys_trigger", "targetname");
//	trigger waittill("trigger");
	flag_set( "everyone_in_garage" );
	
	wait( 2.0 );
	//Oldboy: We're blocked in now.
	level.allies[ 2 ] smart_dialogue( "flood_kgn_wereblockedinnow" );
	//Vargas: Keep it tight.  Follow me.
	level.allies[ 0 ] smart_dialogue( "flood_bkr_doesntmatterweneed" );
	
	level thread nag_player_in_garage();
	
	trigger = GetEnt( "baker_hold_up", "targetname" );
	trigger waittill( "trigger" );
	
	level notify( "going_to_start_convoy_section" );
	
	//Vargas: Enemy checkpoint.  Hold your fire.
	level.allies[ 0 ] smart_dialogue( "flood_bkr_holdup" );

	level thread allies_convoy_dialogue();
	
	wait( 2.0 );

	flag_set( "spawn_m880" );
	
	flag_wait( "m880_has_spawned" );
	
	if ( flag( "enemy_alerted" ) )
	{
		battlechatter_on( "allies" );
	}
	wait( 6 );
	//Generic Pilot 1: Going hot!
	smart_radio_dialogue( "flood_hlx_goinghot" );
	flag_wait( "rpg_fired_at_launcher" );
	if ( flag( "enemy_surprised" ) )
	{
		wait( 3.0 );
		//Vargas: Weapon's free.
		level.allies[ 0 ] smart_dialogue( "flood_bkr_convoysclearopenfire" );
	}
	
/////////////////
	wait(.5);
	flag_wait_either("enemy_alerted", "enemy_surprised");
	battlechatter_on("allies");
	
	flag_wait_either("streets_to_dam_enemies_ALMOST_dead","streets_to_dam_enemies_dead");
	
	flag_wait("streets_to_dam_enemies_dead");
//	thread maps\flood_audio::sfx_missile_buzzer();
	battlechatter_off("allies");
	wait(2.0);
	
	if(!flag("player_on_ladder"))
	{	
		//Vargas: The driver's still alive! Take him out!
		level.allies[ 0 ] smart_dialogue( "flood_vrg_thedriversstillalive" );
	}
    
    wait(1);
    if(!flag("player_on_ladder"))
	{
    	flag_set( "played_radio_part_1" );
	    //Overlord: Be advised. Enemy forces are routed and leaving the city. Over.
	    smart_radio_dialogue( "flood_hqr_beadvisedenemyforces" );
	    		
    }
    
    if(!flag("player_on_ladder") && flag("played_radio_part_1"))
	{
    	flag_set( "played_radio_part_2" );
	    //Generic Soldier 1: Roger, Overlord. We have the perimeter locked down.
	    smart_radio_dialogue( "flood_gs1_rogeroverlordwehave" );	
    }

    wait(3);
    
    if(!flag("player_on_ladder"))
	{
   		nags	= [];
		//Vargas: Elias, take out the driver!
		nags[ 0 ] = "flood_vrg_eliastakeoutthe";
		//Vargas: The driver's still alive! Take him out now!
		nags[ 1 ] = "flood_vrg_thedriversstillalive";
		//Vargas: Elias! Stop the Missile Truck! Right Side!
		nags[ 2 ] = "flood_vrg_eliasstopthemissile";
		//Vargas: There's a ladder on the right side!
		nags[ 3 ] = "flood_vrg_theresaladderon";
			
		level.allies[ 0 ] thread maps\flood_util::play_nag( nags, "player_on_ladder", 10, 30, 2, 2, "flag_set" );
    }
    
	flag_wait( "player_on_ladder" );
	
	level.allies[0] notify( "flag_set" );
    
//    battlechatter_on("allies");
}

nag_player_in_garage()
{
	level endon( "going_to_start_convoy_section" );
	
	wait( 10 );
	
	while ( 1 )
	{
		if ( Distance( level.player.origin, level.allies[ 0 ].origin ) > 650 )
		{
			//Oldboy: Up here!
			level.allies[ 0 ] smart_dialogue( "flood_bkr_uphere" );
			break;
		}
		wait( 0.05 );
	}
}

streets_nag_end_on_notify( nag_handles, msg, notification )
{
	wait( 3.0 );
	
	if ( !flag( msg ) )
		level.allies[ 0 ] thread maps\flood_util::play_nag ( nag_handles, msg, 8, 30, 1, 1.5, "flag_set" );	
}

init_turn_off_lean_volumes()
{
	lean_array = GetEntArray("turn_off_lean", "targetname");
	foreach(volume in lean_array)
	{
		volume turn_off_lean();
	}
}

turn_off_lean()
{
	activated = false;
	while(!flag("end_of_dam"))
	{
		if(level.player IsTouching(self))
		{
			if(!activated)
			{
//				IPrintLn("turning off lean");
				level.player AllowLean(false);
				activated = true;
			}
		}
		else
		{
			if(activated)
			{
//				IPrintLn("turning on lean");
				level.player AllowLean(true);
				activated = false;
			}
		}
		wait(.1);
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_to_dam_2_start()
{
	maps\flood_util::player_move_to_checkpoint_start( "streets_to_dam_2_start" );
    
    //set_audio_zone( "flood_streets", 2 );    
    
    // spawn the allies
    maps\flood_util::spawn_allies();
    
    level thread aim_missiles_2();
    level thread hide_unhide_crashed_convoy(false);

//    flag_set("start_aiming");
//    flag_set("player_on_ladder");
	level thread hide_spire();
	level thread init_turn_off_lean_volumes();
	level thread streets_to_dam_2_side_guys_spawn_logic();
	level thread put_launcher_in_place();
	SetSavedDvar("sm_sunSampleSizeNear", .25);
}

streets_to_dam_2()
{
	level thread make_enemies_miss_player_at_first();
	level thread streets_to_dam_wave_2_sequence();
	level thread dialogue_streets_to_dam_2();
	level thread harassers_ignore_player();
	level thread streets_to_dam_heli_flyover_hover();
//	level thread streets_to_dam_heli_far_flyby();	// removed Bby JKU because Nic told him to!
	level thread remove_streets_ents();
	level thread teleport_failsafe();
	level thread flood_shake_tree();
	level thread hide_missile_launcher_collision();
	level thread m880_connect_path_nodes(true);
	level thread spawn_dam_harrassers();
	//exploder( "alley_flares" );

	level notify("going_to_start_convoy_section");
	
	flag_set("missile_launcher_destruction_done");
	
	trigger = getent("aim_missiles_2", "targetname");
    trigger waittill("trigger");
 
//    level notify("end_of_streets_to_dam");
    level notify("end_of_streets_to_dam_2");
}

//for loading to checkpoint
put_launcher_in_place()
{
	m880 = getent("missile_launcher_2", "targetname");
	
	m880.origin = (-1643, -6966, -64);
	m880.angles = (0, 66.5, 0);
	m880 show();	
}

make_enemies_miss_player_at_first()
{
//	IPrintLn("make_enemies_miss_player_at_first()");
	old_attacker_accuracy = level.player.gs.player_attacker_accuracy;
	level.player set_player_attacker_accuracy(0.0);
	
	trigger = getent("streets_to_dam_first_retreat", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill_notify_or_timeout("trigger", 4.0);
	}
//	wait(2.0);
	
	level.player set_player_attacker_accuracy(0.1);
	
	trigger = getent("streets_to_dam_wave_2_first_advance", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill_notify_or_timeout("trigger", 6.0);
	}
	
//	wait(4.0);
	
	level.player set_player_attacker_accuracy(old_attacker_accuracy);
//	IPrintLn("done make_enemies_miss_player_at_first()");
	
}

streets_to_dam_2_side_guys_spawn_logic()
{
	level.side_guys = [];
    enemies = GetEntArray("streets_to_dam_wave_2_side", "targetname");
    array_thread(enemies , ::add_spawn_function, ::streets_to_dam_wave_2_side_spawn_func);
    array_thread(enemies , ::spawn_ai);  
}
//wave_2 spawns, gets left goal volume
//after death/prog wave 2.5 spawns, gets right goal volume
//after death/prog wave_3 spawns and everyone gets back goal volume

streets_to_dam_wave_2_sequence()
{
	trigger_targetname_array = [
		"streets_to_dam_wave_2_1_trigger",
		"streets_to_dam_wave_2_first_advance", 
		"streets_to_dam_wave_2_5_spawn",
		"streets_to_dam_wave_2_2_trigger",
		"streets_to_dam_wave_2_second_advance", 
		"streets_to_dam_final_advance",
		"streets_to_dam_3_5_advance",
		"streets_to_dam_enemy_retreat"];
	
//	flag_wait("player_on_ladder");

	level thread throw_grenade_if_player_behind_tank();
	level thread adjust_suppression_on_enemies();
	
	vehicle = getent("crashed_tank", "targetname");
	if(isdefined(vehicle))
	{
		vehicle hide();
	}
		
	
	trigger = getent("streets_to_dam_wave_2_start", "targetname");
	trigger notify("trigger");
	
	enemies = GetEntArray("streets_to_dam_wave_2_first", "targetname");
	array_thread(enemies , ::add_spawn_function, ::streets_to_dam_wave_2_first_spawn_func);
    array_thread(enemies , ::spawn_ai);
	
    //get side guys to stop ignoring player
    foreach(guy in level.side_guys)
    {
    	guy notify("stop_ignoring_player");
    }
    
	flag_wait("missile_launcher_destruction_done");
	
	enemies = GetEntArray("streets_to_dam_wave_2", "targetname");
	array_thread(enemies , ::add_spawn_function, ::streets_to_dam_wave_2_spawn_func);
    array_thread(enemies , ::spawn_ai);
    
    wait(.1);
    
//    enemies = get_ai_group_ai("streets_to_dam_wave_2");
//	enemies set_group_goalvolume( "streets_to_dam_goal_volume_2" );
	
//	foreach(guy in enemies)
//	{
//		guy.favoriteenemy = level.player;	
//	}

	new_enemies = GetEntArray("streets_to_dam_wave_2_1", "targetname");
	array_thread(new_enemies , ::add_spawn_function, ::streets_to_dam_wave_2_1_spawn_func);
	wait(.1);
    array_thread(new_enemies , ::spawn_ai);
	
	maps\flood_util::waittill_aigroupcount_or_trigger_targetname( "streets_to_dam_wave_2", 9, "streets_to_dam_wave_2_first_advance" );

	trigger_named_and_turn_off_prior(trigger_targetname_array, "streets_to_dam_wave_2_first_advance");
	
//	trigger = getent("streets_to_dam_wave_2_5_spawn", "targetname");
//	trigger notify("trigger");
	
    wait(.1);

//    enemies = array_removeDead_or_dying(enemies);
//    enemies = array_combine(enemies, new_enemies);

//	enemies = get_ai_group_ai("streets_to_dam_wave_2");
//    enemies set_group_goalvolume( "streets_to_dam_goal_volume_2_5" );
    
//    foreach(guy in enemies)
//	{
//		guy.favoriteenemy = level.player;	
//	}
    
    maps\flood_util::waittill_aigroupcount_or_trigger_targetname( "streets_to_dam_wave_2", 7, "streets_to_dam_wave_2_2_trigger" );
    
    trigger_named_and_turn_off_prior(trigger_targetname_array, "streets_to_dam_wave_2_2_trigger");
    
//  trigger = getent("streets_to_dam_wave_2_2_trigger", "targetname");
//	trigger notify("trigger");
    
    new_enemies = GetEntArray("streets_to_dam_wave_2_5", "targetname");
    array_thread(new_enemies , ::add_spawn_function, ::streets_to_dam_wave_2_5_spawn_func);
    array_thread(new_enemies , ::spawn_ai);
    
    wait(.1);
   
	level thread send_allies_to_nodes_and_play_anim();
    
//    enemies = array_removeDead_or_dying(enemies);
//    enemies = array_combine(enemies, new_enemies);
//    enemies = get_ai_group_ai("streets_to_dam_wave_2");
//    enemies set_group_goalvolume( "streets_to_dam_goal_volume_3" );

	//wait till outside processing
	//send everyone back to the 3_5 goal volume
	maps\flood_util::waittill_aigroupcount_or_trigger_targetname( "streets_to_dam_wave_2", 1, "streets_to_dam_3_5_advance" );
//
//	enemies = get_ai_group_ai("streets_to_dam_wave_2");
//    enemies set_group_goalvolume( "streets_to_dam_goal_volume_3_5" );
    
    streets_to_dam_2_staggered_retreat();
   
    maps\flood_util::waittill_aigroupcount_or_trigger_targetname( "streets_to_dam_wave_2", 1, "streets_to_dam_final_advance" );
    trigger = getent("streets_to_dam_final_advance", "targetname");
    if(isdefined(trigger))
    {
		trigger notify("trigger");
		wait(.1);
    }
    
    maps\flood_util::waittill_aigroupcount_or_trigger_targetname( "streets_to_dam_wave_2", 1, "streets_to_dam_enemy_retreat" );

//    trigger = getent("streets_to_dam_final_advance", "targetname");
//    if(isdefined(trigger))
//    {
//		trigger notify("trigger");
//    }
    
//	level notify("send_allies_to_final_locations");
    
   	//make everyone run away
    trigger_named_and_turn_off_prior(trigger_targetname_array, "streets_to_dam_enemy_retreat");
    
//    enemies set_group_goalvolume( "dam_far_goal_volume" );
    
    region = getent("final_advance_kill_volume", "targetname");
    kill_deathflag_in_area( "streets_to_dam_wave_2", region, 0 );

    volume = getent("dam_far_goal_volume", "targetname");
    enemies = get_ai_group_ai("streets_to_dam_wave_2");
    
    //if there are less than 4 enemies have them run away, otherwise shoot at player
    if(enemies.size>4)
    {
    	foreach ( guy in enemies)
	    {
	    	guy.favoriteenemy = level.player;
//			guy SetLookAtEntity( level.player );    			
	    }
    }
    else
    {
	    foreach (guy in enemies)
	    {
	    	if(isdefined(guy) && isalive(guy))
	    	{
	    		guy SetGoalVolumeAuto(volume);
	    		wait(RandomFloatRange(.1, .5));
		    }
	    }
    }
    
}

throw_grenade_if_player_behind_tank()
{
	trigger = getent("streets_to_dam_grenade_check", "targetname");
	trigger waittill("trigger");

	wait(2.0);
	
	if(level.player IsTouching(trigger))
	{
		enemies = GetAIArray("axis");
		
		foreach(guy in enemies)
		{
			guy thread ThrowGrenadeAtPlayerASAP();
		}
	}
}

adjust_suppression_on_enemies()
{
	while(1)
	{
		trigger = getent("streets_to_dam_3_5_advance", "targetname");		
		if(isdefined(trigger))
		{
			enemies = GetAIArray("axis");
			if(enemies.size > 5)
			{
				enemies = get_array_of_farthest(level.player.origin, enemies);
				num_to_suppress = enemies.size - 5;
				for ( i = 0; i < enemies.size; i++ )
				{
					if(i < num_to_suppress)
					{
						enemies[i].suppressionwait = 5;						
					}
					else
					{
						enemies[i].suppressionwait = 1;
					}
				}				
			}
		}
		else
		{
			break;
		}
		wait(.1);
	}
}

streets_to_dam_2_staggered_retreat()
{
	enemies = get_ai_group_ai("streets_to_dam_wave_2");
	enemies = get_array_of_farthest(level.player.origin, enemies);
	
	for ( i = 0; i < enemies.size; i++ )
	{
		if((i<3) || (enemies.size>5))
		{
			if(enemies.size>5)
			{
				enemies[i].favoriteenemy = level.player;
//				enemies[i] SetEntityTarget(level.player);
			}
			volume = getent("streets_to_dam_goal_volume_3_5", "targetname");			
		}
		else
		{
			enemies[i] ignore_everything();
			volume = getent("dam_far_goal_volume", "targetname");				
		}
		enemies[i] setgoalvolumeauto(volume);
	}
}

streets_to_dam_wave_2_spawn_func()
{
	self endon("death");
	
	self.favoriteenemy = level.player;
	
	region = getent("streets_to_dam_goal_volume_2", "targetname");
	self SetGoalVolumeAuto(region);
	
	trigger = getent("streets_to_dam_wave_2_2_trigger", "targetname");
	trigger waittill("trigger");

	region = getent("streets_to_dam_goal_volume_3", "targetname");
	self SetGoalVolumeAuto(region);

	trigger = getent("streets_to_dam_wave_2_second_advance", "targetname");
	trigger waittill("trigger");
	
	region = getent("streets_to_dam_goal_volume_3_mid", "targetname");
	self SetGoalVolumeAuto(region);	
	

}

streets_to_dam_wave_2_1_spawn_func()
{
	self endon("death");
	
	region = getent("streets_to_dam_goal_volume_2_5", "targetname");
	self SetGoalVolumeAuto(region);
	
	trigger = getent("streets_to_dam_wave_2_second_advance", "targetname");
	trigger waittill("trigger");
	
	region = getent("streets_to_dam_goal_volume_3_mid", "targetname");
	self SetGoalVolumeAuto(region);
}

streets_to_dam_wave_2_5_spawn_func()
{
	self endon("death");
	
	region = getent("streets_to_dam_goal_volume_3", "targetname");
	self SetGoalVolumeAuto(region);
	
	trigger = getent("streets_to_dam_wave_2_second_advance", "targetname");
	trigger waittill("trigger");
	
	region = getent("streets_to_dam_goal_volume_3_mid", "targetname");
	self SetGoalVolumeAuto(region);
}

streets_to_dam_wave_2_first_spawn_func()
{
	self endon("death");
	
	region = getent("streets_to_dam_goal_volume_2_first", "targetname");
	self SetGoalVolumeAuto(region);
	
	
	
	if(isdefined(self.script_noteworthy) && self.script_noteworthy == "exposed_guy")
	{
		self thread exposed_guy_think();
	}
	else
	{
		self.favoriteenemy = level.player;
		flag_wait("missile_launcher_destruction_done");
		self.favoriteenemy = level.player;
		
		trigger = getent("streets_to_dam_wave_2_1_trigger", "targetname");
		trigger waittill("trigger");
//		streets_to_dam_wave_2_first_advance
//		streets_to_dam_first_retreat
		trigger = getent("streets_to_dam_wave_2_first_advance", "targetname");
		
		waittill_notify_or_timeout_return("trigger", RandomFloatRange(5.0, 7.0));
		
		wait(RandomFloat(2.0));
	
		region = getent("streets_to_dam_goal_volume_2_5", "targetname");
		self SetGoalVolumeAuto(region);
	}
	
	trigger = getent("streets_to_dam_wave_2_second_advance", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
	
	region = getent("streets_to_dam_goal_volume_3_mid", "targetname");
	self SetGoalVolumeAuto(region);
}

streets_to_dam_wave_2_side_spawn_func()
{
	self endon("death");
	
	level.side_guys[level.side_guys.size] =  self;
	
	self ignore_everything(0.0);
	
	self waittill("stop_ignoring_player");
	
	self clear_ignore_everything();
	
	region = getent("streets_to_dam_2_side_goal_volume", "targetname");
	self SetGoalVolumeAuto(region);
		
	trigger = getent("streets_to_dam_wave_2_first_advance", "targetname");
	trigger waittill("trigger");

	region = getent("streets_to_dam_2_side_2_goal_volume", "targetname");
	self SetGoalVolumeAuto(region);
	
	trigger = getent("streets_to_dam_wave_2_5_spawn", "targetname");
	trigger waittill("trigger");
	
	//make sure guy doesn't shoot player in the side
	volume = getent("force_retreat_volume", "targetname");
	if(self istouching(volume))
	{
		self thread ignore_everything(3.0);
		node = GetNode("force_retreat_goal_node", "targetname");		
		self SetGoalNode(node);
	}	

	trigger = getent("streets_to_dam_wave_2_2_trigger", "targetname");
	if(IsDefined(trigger))
	{
		trigger waittill("trigger");
	}
		
	region = getent("streets_to_dam_goal_volume_3", "targetname");
	self SetGoalVolumeAuto(region);

	trigger = getent("streets_to_dam_wave_2_second_advance", "targetname");
	trigger waittill("trigger");
	
	region = getent("streets_to_dam_goal_volume_3_mid", "targetname");
	self SetGoalVolumeAuto(region);	
}

spawn_dam_harrassers()
{
	trigger = getent("streets_to_dam_final_advance", "targetname");
	trigger waittill("trigger");	
	
	enemies = GetEntArray("dam_missile_harassers", "targetname");
	array_thread(enemies , ::add_spawn_function, ::streets_to_dam_2_harrassers_spawn_func);
    array_thread(enemies , ::spawn_ai);
    
    enemies = GetEntArray("dam_missile_harassers_close", "targetname");
	array_thread(enemies , ::add_spawn_function, ::streets_to_dam_2_harrassers_close_spawn_func);
    array_thread(enemies , ::spawn_ai);
}

//for dam checkpoint, so enemies are at cover when game starts
spawn_dam_harrassers_fake()
{
	trigger = getent("streets_to_dam_final_advance", "targetname");
	trigger waittill("trigger");	
	
	enemies = GetEntArray("dam_missile_harassers_fake", "targetname");
	array_thread(enemies , ::add_spawn_function, ::streets_to_dam_2_harrassers_spawn_func);
    array_thread(enemies , ::spawn_ai);
    
    enemies = GetEntArray("dam_missile_harassers_close_fake", "targetname");
	array_thread(enemies , ::add_spawn_function, ::streets_to_dam_2_harrassers_close_spawn_func);
    array_thread(enemies , ::spawn_ai);
}

streets_to_dam_2_harrassers_spawn_func()
{
	//how far is the goal volume? dam far.
	region = getent("dam_far_goal_volume", "targetname");
	self SetGoalVolumeAuto(region);
	self.ignoresuppression = true;

	wait(.5);
	//ignoreall KVP set on spawner
	self.ignoreall = false;	
}

streets_to_dam_2_harrassers_close_spawn_func()
{
	//how far is the goal volume? dam far.
	region = getent("dam_far_goal_volume_close", "targetname");
	self SetGoalVolumeAuto(region);		
	self.ignoresuppression = true;

	wait(.5);
	//ignoreall KVP set on spawner
	self.ignoreall = false;	
}

exposed_guy_think()
{
	self endon("death");
	
	self ignore_everything(0.0);
	
	//node_concealment
	node = GetNode("exposed_guy_node_first", "targetname");
	self SetGoalNode(node);
	old_goalradius = self.goalradius;
	self.goalradius = 16;
	self waittill("goal");
	self.goalradius = old_goalradius;
	
	trigger = getent("streets_to_dam_wave_2_1_trigger", "targetname");
	if(isdefined(trigger))
	{		
		trigger waittill_notify_or_timeout("trigger", 20.0);
	}
		exposed_node_first_volume = getent("exposed_node_first", "targetname");
		self SetGoalVolumeAuto(exposed_node_first_volume);
		node = GetNode("node_exposed", "targetname");
		self SetGoalNode(node);
//		wait(1.0);
		old_goalradius = self.goalradius;
		self.goalradius = 16;
		self waittill("goal");
		self clear_ignore_everything();
		self.goalradius = old_goalradius;

		
	//node_concealment
//	node = GetNode("node_exposed", "targetname");
//	self SetGoalNode(node);
	
//	trigger = getent("streets_to_dam_2_exposed_guy_trigger", "targetname");
//	trigger waittill("trigger");
	
//	trigger = getent("streets_to_dam_wave_2_1_trigger", "targetname");
//	if(isdefined(trigger))
//	{		
//		node = GetNode("node_exposed", "targetname");
//		self SetGoalNode(node);
//	}
	
	trigger = getent("streets_to_dam_wave_2_5_spawn", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
		
//	wait(RandomFloat(2.0));
	
	region = getent("streets_to_dam_goal_volume_2_5", "targetname");
	self SetGoalVolumeAuto(region);
}

send_allies_to_nodes_and_play_anim()
{
//	level waittill("send_allies_to_final_locations");
	trigger = getent("streets_to_dam_enemy_retreat", "targetname");
	trigger waittill("trigger");
//	
//	waittill_aigroupcleared("streets_to_dam_wave_1");
//	waittill_aigroupcleared("streets_to_dam_wave_1_5");
	
//	flag_wait_either("player_on_ladder","streets_to_dam_enemies_dead");
//	if(!flag("player_on_ladder"))
//	{
		go_to_node = GetNode("streets_to_dam_2_ally_0_node", "targetname");
		level.allies[0] SetGoalNode(go_to_node);
//		level.allies[0] thread play_ally_launcher_vignette("launcher_callout_ally01", go_to_node, maps\flood_anim::launcher_callout_ally01,"looked_at_missiles_failsafe");
//		level.allies[0] thread play_ally_launcher_vignette("launcher_callout_ally03", go_to_node, maps\flood_anim::launcher_callout_ally03,"vignette_dam_break", (0,180,0));		
	//	ally_target = getent("streets_to_dam_ally_0_target", "targetname");
	//	level.allies[0] SetEntityTarget(ally_target);
		
		go_to_node = GetNode("streets_to_dam_2_ally_2_node", "targetname");
		level.allies[1] SetGoalNode(go_to_node);
//		level.allies[1] thread play_ally_launcher_vignette("launcher_callout_ally02", go_to_node, maps\flood_anim::launcher_callout_ally02,"looked_at_missiles_failsafe", (0,180,0));
	
		go_to_node = GetNode("streets_to_dam_2_ally_1_node", "targetname");
		level.allies[2] SetGoalNode(go_to_node);
				
//		level.allies[2] thread play_ally_launcher_vignette_wrapper("launcher_callout_ally03", go_to_node, maps\flood_anim::launcher_callout_ally03, "looked_at_missiles_failsafe", (0,180,0));
		
		flag_wait("looked_at_missiles_failsafe");
		
		level.allies[0] notify("player_now_on_ladder");
		level.allies[2] notify("player_now_on_ladder");

}

/*
=============
///ScriptDocBegin
"Name: kill_deathflag_in_area( <theFlag>, <region>, <time> )"
"Summary: Kill everything associated with a deathflag within a specified area. If not in area, delete."
"MandatoryArg: <theFlag>: The flag to kill on "
"MandatoryArg: <region>: volume ai must be inside to be killed "
"OptionalArg: <time>: random amount of time to wait before death "
"Example: kill_deathflag_in_area( "tower_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
kill_deathflag_in_area( theFlag, region, time )
{
	//assertex( IsDefined( level.flag[ theFlag ] ), "Tried to kill_deathFlag on a flag " + theFlag + " which does not exist." );
	if ( !isdefined( level.flag[ theFlag ] ) )
		return;

	if ( !isdefined( region) )
		return;
	
	if ( !isdefined( time ) )
		time = 0;

	foreach ( deathTypes in level.deathFlags[ theFlag ] )
	{
		foreach ( element in deathTypes )
		{
			if ( IsAlive( element ) )
			{
				if(element istouching(region))
				{
					element thread maps\_utility_code::kill_deathflag_proc( time );
				}
			}
			else
			{
				element Delete();
			}
		}
	}
}

delete_corpse_in_volume( volume )
{
	Assert( IsDefined( volume ) );
	if ( self IsTouching( volume ) )
		self Delete();
}

//baker_handsignals()
//{
////	level.allies[0] waittill("goal");
////
////	level.allies[0] ignore_everything();
////	level.allies[0] handsignal( "go" );   // moveout, moveup, stop, onme, enemy, go
////	wait(1.0);
////	
////	level.allies[0] clear_ignore_everything();
//}

dialogue_streets_to_dam_2()
{
//	battlechatter_on("allies");
	
//	trigger = GetEnt( "streets_to_dam_wave_2_start", "targetname" );
//	if(isdefined(trigger))
//	{
//    	trigger waittill( "trigger" );
//	}
	
	wait( 3 );
	wait_time = 3;
//	if(!flag("played_radio_part_1"))
//	{
//    	flag_set("played_radio_part_1");
//	    smart_radio_dialogue("flood_hqr_beadvisedenemyforces");
//	    wait_time--;		
//    }
    
	if ( flag( "played_radio_part_1" ) && !flag( "played_radio_part_2" ) )
	{
    	flag_set( "played_radio_part_2" );
	    //Generic Soldier 1: Roger, Overlord. We have the perimeter locked down.
	    smart_radio_dialogue( "flood_gs1_rogeroverlordwehave" );
		wait_time--;
		wait_time--;
    }
	wait(wait_time);
	
    battlechatter_off( "allies" );
    //Vargas: Launcher down!!
    level.allies[ 0 ] smart_dialogue( "flood_bkr_launcherdown" );
    //Oldboy: There's still one more!
    level.allies[ 1 ] smart_dialogue( "flood_diz_stillonemore" );
    //Merrick: Then let's blow that one too.
    level.allies[ 0 ] smart_dialogue( "flood_bkr_blowthatonetoo" );
    
    battlechatter_on( "allies" );
    
    trigger = GetEnt( "streets_to_dam_final_advance", "targetname" );
    
    wait( 3.0 );
    
    if ( IsDefined( trigger ) )
    {
    	battlechatter_off( "allies" );
//    	level.allies[2] smart_dialogue("flood_mrk_werenotgoingto");
    	wait( 1.0 );
    }
    
    if ( IsDefined( trigger ) )
    {
    	//Vargas: We can't give up on this!
    	level.allies[ 0 ] smart_dialogue( "flood_pri_wecantgiveup" );
//    	wait(1.0);
    }

    if ( IsDefined( trigger ) )
    {
    	//Merrick: We've got about a dozen targets.
    	level.allies[ 1 ] smart_dialogue( "flood_vrg_wevegotabouta" );
    	//Merrick: We take 'em down, but they keep coming.
    	level.allies[ 1 ] smart_dialogue( "flood_vrg_imtryingtotake" );
    	wait( 1.0 );
    }

    if ( IsDefined( trigger ) )
    {
    	//Vargas: We can't let that launcher fire! Move faster!
    	level.allies[ 0 ] smart_dialogue( "flood_pri_wecantletthat" );
    }
    if ( IsDefined( trigger ) && !flag( "played_radio_part_1" ) )
    {
    	flag_set( "played_radio_part_1" );
	    //Overlord: Be advised. Enemy forces are routed and leaving the city. Over.
	    smart_radio_dialogue( "flood_hqr_beadvisedenemyforces" );
    }
    
	if ( IsDefined( trigger ) && !flag( "played_radio_part_2" ) )
	{
		flag_set( "played_radio_part_2" );
	    //Generic Soldier 1: Roger, Overlord. We have the perimeter locked down.
	    smart_radio_dialogue( "flood_gs1_rogeroverlordwehave" );
    }
	
    battlechatter_on("allies");
    
    if(IsDefined(trigger))
    {
    	trigger waittill( "trigger" );
    }
//    
//    level waittill("send_allies_to_final_locations");
    
    battlechatter_off("allies");
    
    //Vargas: Move!  Stop the launcher!
    level.allies[ 0 ] thread smart_dialogue( "flood_bkr_getaway" );

	battlechatter_on("allies");    
}

streets_to_dam_heli_flyover()
{
	trigger = GetEnt( "trig_dam_heli_flyover", "targetname" );
    trigger waittill( "trigger" );
    
	chopper01 = spawn_vehicle_from_targetname_and_drive( "streets_dam_flyover_1_blackhawk" );
	chopper01.path_gobbler = true;
	chopper01.script_vehicle_selfremove = true;
	chopper01 Vehicle_SetSpeed( 60 );
	
	chopper01 maps\_vehicle::gopath();
	chopper01 Vehicle_TurnEngineOff();
	
	chopper02 = spawn_vehicle_from_targetname_and_drive( "streets_dam_flyover_2_blackhawk" );
	chopper02.path_gobbler = true;
	chopper02.script_vehicle_selfremove = true;
	chopper02 Vehicle_SetSpeed( 60 );
	
	chopper02 maps\_vehicle::gopath();
	chopper02 Vehicle_TurnEngineOff();
}

streets_to_dam_heli_flyover_hover()
{	
	trigger = GetEnt( "trig_dam_heli_flyover_hover", "targetname" );
    trigger waittill( "trigger" );
    
//    flag_wait( "vignette_dam_break_m880_launch_prep" );
    
	chopper01 = spawn_vehicle_from_targetname_and_drive( "streets_dam_flyover_3_blackhawk" );
	chopper01.path_gobbler = true;
	//chopper01.script_vehicle_selfremove = true;
	chopper01 Vehicle_SetSpeed( 75 );
	
	chopper01 maps\_vehicle::gopath();
	chopper01 Vehicle_TurnEngineOff();
	
	chopper01 waittill( "reached_dynamic_path_end" );
	
	chopper01 delete();
	
//	heli_turn_node = GetStruct( "heli_turn", "targetname" );
//	
//	while( DistanceSquared( heli_turn_node.origin, chopper01.origin ) > 4000000 )
//	{
//		wait( 0.05 );
//	}
//	
//	look_org = GetEnt( "streets_flyover_heli_turn_org", "targetname" );
//	chopper01 SetLookAtEnt( look_org );
//	
//	//chopper01 waittill( "reached_dynamic_path_end" );
//	
//	chopper01 thread vehicle_detachfrompath();
//	
//	heli_flyaway_node = GetStruct( "streets_dam_heli_hover_flyaway", "targetname" );
//	
//	chopper01 SetVehGoalPos( heli_flyaway_node.origin, true );
//	chopper01 Vehicle_SetSpeed( 20 );
//	
//	flag_wait("vignette_dam_break_end_flag");
//	
//	chopper01 thread vehicle_paths( heli_flyaway_node );
}

dam_heli_flyover_hover()
{
/*
	chopper01 = spawn_vehicle_from_targetname_and_drive( "streets_dam_flyover_4_blackhawk" );
	chopper01.path_gobbler = true;
	//chopper01.script_vehicle_selfremove = true;
	chopper01 Vehicle_SetSpeed( 90 );
	
	chopper01 maps\_vehicle::gopath();
	
	heli_turn_node = GetStruct( "heli_turn", "targetname" );
	
	while( DistanceSquared( heli_turn_node.origin, chopper01.origin ) > 4000000 )
	{
		wait( 0.05 );
	}
	
	look_org = GetEnt( "streets_flyover_heli_turn_org", "targetname" );
	chopper01 SetLookAtEnt( look_org );
	
	//chopper01 waittill( "reached_dynamic_path_end" );
	
	chopper01 thread vehicle_detachfrompath();
	
	heli_flyaway_node = GetStruct( "streets_dam_heli_hover_flyaway", "targetname" );
	
	chopper01 SetVehGoalPos( heli_flyaway_node.origin, true );
	chopper01 Vehicle_SetSpeed( 20 );
	
	flag_wait("vignette_dam_break_end_flag");
	
	chopper01 thread vehicle_paths( heli_flyaway_node );
*/
}

streets_to_dam_heli_far_flyby()
{
	trigger = GetEnt( "trig_dam_heli_far_flyby", "targetname" );
    trigger waittill( "trigger" );
    
	chopper01 = spawn_vehicle_from_targetname_and_drive( "streets_dam_far_flyby_1_blackhawk" );
	chopper01.path_gobbler = true;
	chopper01.script_vehicle_selfremove = true;
	chopper01 Vehicle_SetSpeed( 100 );
	
	chopper01 maps\_vehicle::gopath();
	chopper01 Vehicle_TurnEngineOff();
	
	chopper02 = spawn_vehicle_from_targetname_and_drive( "streets_dam_far_flyby_2_blackhawk" );
	chopper02.path_gobbler = true;
	chopper02.script_vehicle_selfremove = true;
	chopper02 Vehicle_SetSpeed( 100 );
	
	chopper02 maps\_vehicle::gopath();
	chopper02 Vehicle_TurnEngineOff();
	
	end_node = GetStruct( "streets_dam_far_flyby_1", "targetname" );
	
	while( DistanceSquared( end_node.origin, chopper01.origin ) > 100 )
	{
		wait( 0.05 );
	}
	
	chopper01 Delete();
	chopper02 Delete();
}

remove_streets_ents()
{
	wait(1.0);
	delete_ent_by_targetname("streets_start");
	delete_ent_by_targetname("streets_ally_0");
	delete_ent_by_targetname("streets_ally_2");
	delete_ent_by_targetname("streets_ally_1");
	delete_ent_by_targetname("enemy_tank_2_garage_target");
	delete_ent_by_targetname("rpg_target");
	delete_ent_by_targetname("bullet_target_4");
	delete_ent_by_targetname("humvee_missile_start");
	delete_ent_by_targetname("streets_to_dam_start");	
	delete_ent_by_targetname("streets_to_dam_ally_0");
	delete_ent_by_targetname("streets_to_dam_ally_1");
	delete_ent_by_targetname("streets_to_dam_bullet_origin");
	delete_ent_by_targetname("missile_smoke_origin_3");
	delete_ent_by_targetname("bullet_origin_2");
	delete_ent_by_targetname("allied_tank_infil_destroyed");
	delete_ent_by_targetname("enemy_tank_infil_destroyed");
	delete_ent_by_targetname("streets_destroyed_tank_01");
	delete_ent_by_targetname("streets_destroyed_tank_02");
	delete_ent_by_targetname("enemy_tank");
	delete_ent_by_targetname("allied_tank");
	delete_ent_by_targetname("allied_tank_2");
	delete_ent_by_targetname("streets_enemy_tank_soldiers");
	delete_ent_by_targetname("enemy_convoy_vehicles_infil");
	delete_ent_by_targetname("enemy_tank_3");
	delete_ent_by_targetname("enemy_tank_2");
	delete_ent_by_targetname("streets_wave_2");		
	delete_ent_by_targetname("enemy_tank_2_mock_1");
	delete_ent_by_targetname("allied_tank_2_mock");
	delete_ent_by_targetname("allied_tank_mock");
	delete_ent_by_targetname("street_start_allies");
	delete_ent_by_targetname("allied_tank_2_fake");
			
	
	delete_ent_by_script_noteworthy("planter");
	delete_ent_by_script_noteworthy("planter_07");
	delete_ent_by_script_noteworthy("planter_06");
	delete_ent_by_script_noteworthy("planter_08");
	delete_ent_by_script_noteworthy("planter_02");	
	
}

remove_streets_to_dam_ents()
{
	wait(1.0);
	delete_ent_by_targetname("enemy_convoy_vehicles_launcher");
	delete_ent_by_targetname("enemy_convoy_vehicles_tank");
	delete_ent_by_targetname("enemy_convoy_vehicles");
	delete_ent_by_targetname("enemy_convoy_vehicles_broken");
	delete_ent_by_targetname("missile_launcher_2");
	delete_ent_by_targetname("crashed_m880");	
	delete_ent_by_targetname("streets_to_dam_tank_shoot_at_player");
	delete_ent_by_targetname("streets_to_dam_tank_kill_player");
	delete_ent_by_targetname("streets_to_dam_convoy");
	delete_ent_by_targetname("streets_to_dam_wave_1_vignette_extra");
	delete_ent_by_targetname("streets_to_dam_wave_1_street_patrol");
	delete_ent_by_targetname("streets_to_dam_wave_1_vignette");
	delete_ent_by_targetname("streets_to_dam_wave_1");
	delete_ent_by_targetname("streets_to_dam_wave_1_rpg");	
		
	
	delete_ent_by_script_noteworthy("planter");
	delete_ent_by_script_noteworthy("streets_helicopter_crash_location");
}

//deletes all ents of a given targetname
delete_ent_by_targetname(name_of_ent)
{
	ent_array = getentarray(name_of_ent, "targetname");
	if(IsDefined(ent_array))
	{
		if(!IsArray(ent_array))
		{
			ent_array = make_array(ent_array);
		}
		
		foreach(ent in ent_array)
		{
			if(isdefined(ent))
			{
//				PrintLn("deleting by targetname: "+name_of_ent);
				ent delete();
			}
		}
	}
}

//deletes all ents of a given script_noteworthy
delete_ent_by_script_noteworthy(name_of_ent)
{
	ent_array = getentarray(name_of_ent, "script_noteworthy");
	if(IsDefined(ent_array))
	{
		if(!IsArray(ent_array))
		{
			ent_array = make_array(ent_array);
		}
		
		foreach(ent in ent_array)
		{
			if(isdefined(ent))
			{
//				PrintLn("deleting by script_noteworthy: "+name_of_ent);
				ent delete();
			}
		}
	}
}

#using_animtree( "animated_props" );
flood_shake_tree()
{
	noteworthies = [];
	noteworthies[ 0 ] = "flood_shake_tree_left_1";
	noteworthies[ 1 ] = "flood_shake_tree_left_2";
	noteworthies[ 2 ] = "flood_shake_tree_left_3";
	noteworthies[ 3 ] = "flood_shake_tree_left_4";
	noteworthies[ 4 ] = "flood_shake_tree_left_5";
	noteworthies[ 5 ] = "flood_shake_tree_right_1";
	noteworthies[ 6 ] = "flood_shake_tree_right_2";
	noteworthies[ 7 ] = "flood_shake_tree_right_3";
	noteworthies[ 8 ] = "flood_shake_tree_right_4";
	noteworthies[ 9 ] = "flood_shake_tree_right_5";
	noteworthies[ 10 ] = "flood_shake_tree_right_6";
	
	foreach( noteworthy in noteworthies )
	{
		ent = GetEnt( noteworthy, "script_noteworthy" );
		ent thread flood_shake_tree_internal();
	}
}
	
flood_shake_tree_internal()
{		
	level waittill( self.script_noteworthy );
	
	// light dust element
//		PlayFXOnTag(level._effect["flood_streets_tree_dust"], self, "J_Tip2_Tall2");
	
	if ( RandomFloat( 1.0 ) < 0.3333 )
	{
		PlayFXOnTag( level._effect[ "birds_flood_street_birds_01" ],  self,  "J_Tip2_Tall2" );
	} 
	else 
	{
		// for near trees, make sure they always play
		if ( ( self.script_noteworthy == "flood_shake_tree_right_4" ) || ( self.script_noteworthy == "flood_shake_tree_left_4" ) || ( self.script_noteworthy == "flood_shake_tree_right_5" ) || ( self.script_noteworthy == "flood_shake_tree_right_6" ) )
		{
			PlayFXOnTag( level._effect[ "birds_flood_street_birds_01" ],  self,  "J_Tip2_Tall2" );
		}
	}
	
	windweight = 1;
	windrate = 1 + RandomFloat( 0.4 );
	self SetAnimKnobRestart( level.anim_prop_models[ self.model ][ "flood" ], windweight, 0.02, windrate );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dam_start()
{
	//SetSavedDvar( "sm_sunsamplesizenear", 1.50 ); // push the dynamic shadow distance out

	//thread set_audio_zone( "flood_streets", 2 );
    maps\flood_audio::sfx_flood_streets_emitters();
    // setup and teleport player
    maps\flood_util::player_move_to_checkpoint_start( "dam_start" );
    
    // spawn the allies
    maps\flood_util::spawn_allies();
    
    level thread spawn_dam_harrassers_fake();
    
    level thread harassers_ignore_player();
    
//    level thread aim_missiles();
    level thread aim_missiles_2();
//    level thread spawn_rorke_heli();

	level thread dam_heli_flyover_hover();
//	level thread streets_to_dam_heli_far_flyby();	// removed by JKU because Nic told him to
	level thread trigger_missile_launcher_aim_flag();

//	level thread add_dam_vignette_hud_overlay();
	
	level thread hide_spire();
	level thread remove_streets_ents();
	level thread send_allies_to_nodes_and_play_anim();
//	level thread streets_to_dam_heli_flyover_hover();
	
	level thread flood_shake_tree();
	
	SetSavedDvar("sm_sunSampleSizeNear", .25);
	
//    flag_set("start_aiming");
    
    wait(.5);
    trigger = getent("streets_to_dam_final_advance", "targetname");
	trigger notify("trigger");
	
	// CF - Removing specific lines but leaving for reference
	// this was an additional fade time DK added for greenlight only
	// DK Temp fade in for greenlight
	////if ( getdvar( "greenlight" ) == "1" )
	//if( level.start_point == "dam" )
	//	fade_to_black( .05, 3, 5 );
}

dam()
{
    flag_wait("missiles_ready");
    
	// CF - Removing specific lines but leaving for reference
	// this autosave was being removed to avoid autosave hitch
    // DK Temp greenlight clutter cleanup
	////if ( getdvar( "greenlight" ) != "1" )
	//if( level.start_point != "dam" )
    	level thread autosave_now();
    	
    level thread fire_missiles();
    level thread dialogue_dam();
    
    // wait until player gets in position

	flag_wait("start_flood");
	
//	IPrintLnBold("STARTING FLOOD");
	level.dam_break_weapon = level.player GetCurrentWeapon();
	
	level thread remove_allies();
//	level thread add_dam_vignette_hud_overlay();
	level thread ignore_player(false);
	
	flag_wait("looked_at_missiles_failsafe");
	level thread remove_streets_to_dam_ents();
	
//	PrintLn("END OF DAM");
	flag_wait("vignette_dam_break_end_flag");
	
	flag_set("end_of_dam");
}

trigger_missile_launcher_aim_flag()
{
	// CF - Removing specific lines but leaving for reference
	// another additional wait for the missile prep flag set
	// DK Temp delay for greenlight
	////if ( getdvar( "greenlight" ) == "1" )
//	if( level.start_point == "E3" )
	wait( 4.0 );
	
	flag_set("vignette_dam_break_m880_launch_prep");
}

harassers_ignore_player()
{
	trigger = GetEnt( "streets_to_dam_final_advance", "targetname" );
    trigger waittill( "trigger" );
    enemies_alive = true;
    while(enemies_alive)
    {
    	volume = GetEnt( "streets_to_dam_goal_volume_3", "targetname" );
    	ai_array = volume get_ai_touching_volume("axis");
    	num = ai_array.size;
    	volume = GetEnt( "dam_remove_dead_bodies", "targetname" );
    	ai_array = volume get_ai_touching_volume("axis");
    	num = num + ai_array.size;
//    	num = get_ai_group_sentient_count("streets_to_dam_wave_2");
    	if(num > 0)
    	{
    		wait(.1);
    	}
    	else
    	{
    		enemies_alive = false;
    	}
    }
	
//    while(get_ai_group_sentient_count("streets_to_dam_wave_2") > 0)
//    {
//   		wait(.1);
//    }
	level thread ignore_player(true);
}

ignore_player(ignore)
{
//	if(ignore)
//	{
//		IPrintLn("ignoring player");
//	}
//	else
//	{
//		IPrintLn("un-ignoring player");
//	}
	level.player.ignoreme = ignore;	
}

aim_missiles_2()
{
   	trigger = getent("aim_missiles_2", "targetname");
   	trigger waittill("trigger");
   	
   	// Delay for Transient Fast File Loads
   	wait( 1.0 );
   	
//   	ml = getent("missile_launcher_4", "targetname");
    	
	thread maps\flood_audio::sfx_missile_buzzer(level.dam_break_m880, "sfx_missiles_launched");
   	exploder("m880_redlight");

    //ml RotateYaw(-50, 1.0);
//    ml RotateYaw(-180, 1.5);
    wait(1.5);
    
    thread maps\flood_audio::sfx_rocket_aiming_sound();
    flag_set("missiles_ready");
        
    level thread c4_spot_glow();
//    level thread spawn_ml_drivers();
}

spawn_ml_drivers()
{
	drivers = GetEntArray("dam_missile_drivers", "targetname");
	foreach(driver_spawner in drivers)
	{
		driver_spawner add_spawn_function(::ml_driver_spawn_func);
	}
	
	array_spawn(drivers);
	
	
}

ml_driver_spawn_func()
{
	self ignore_everything();
	
	trigger = getent("missile_launcher_driver_kill_trigger", "targetname");
   
   	while(1)
    {
        trigger waittill("trigger", guy);
    
        if ( IsDefined( guy ) && self == guy )
        {
            break;
        }
    }
   	
   	self clear_ignore_everything();
   	goal_volume = getent("dam_far_goal_volume", "targetname");
   	self set_goal_volume(goal_volume);
   	
   	
}

fire_missiles()
{

    level thread missile_launch_failsafe();
    
    //in case player triggers without looking at the right place...
        
    flag_wait_any("looked_at_missiles","looked_at_missiles_failsafe");
    
    level thread remove_live_grenades();
    level thread remove_stuff_for_animation();
    level thread remove_dyn_objects();
    //    region = getent("dam_remove_dead_bodies", "targetname");
    volume = GetEnt( "dam_remove_dead_bodies", "targetname" );
	array_thread( GetCorpseArray(), ::delete_corpse_in_volume, volume );
    
    // Stop the buzzer sfx on the missile launcher
	thread maps\flood_audio::sfx_stop_buzzer("sfx_missiles_launched");
	thread maps\flood_audio::sfx_rocket_explosion_sound();
    
    wait(.1);
//    IPrintLnBold( "Unable to get up" );
	level thread kill_enemies();

    wait(1.0);
    level thread retreat_dam_harassers();
//    level.player FreezeControls(true);
    wait(3.0);
//    level thread temp_missile_impacts();
    wait(1.0);
    
    flag_set("start_flood");
    
    thread maps\flood_audio::sfx_flood_streets_trigger_logic( 2, 1 );
    
    //thread set_audio_zone( "flood_streets", 2 ); 
      
}

fade_to_black(fadeDownTime, blackTime, fadeUpTime)
{
	// fade to black
	level.black_overlay = maps\_hud_util::create_client_overlay( "black", 0, level.player );
	level.black_overlay FadeOverTime( fadeDownTime );
	level.black_overlay.alpha = 1;
	wait( fadeDownTime );
	
	flag_set("level_faded_to_black");

	wait( blackTime );	
	
	if(isdefined(fadeUpTime))
	{
		level.black_overlay FadeOverTime( fadeUpTime );
		level.black_overlay.alpha = 0;
	}
}

c4_spot_glow()
{
	spot_array = level.dam_break_m880;
	
	spot_array = make_array(spot_array);
	c4_array = [];
	index = 0;
	
	foreach(spot in spot_array)
	{
		objmodel = "vehicle_m880_launcher_obj";
		c4_array[index] = spawn( "script_model", spot.origin);
		c4_array[index] setmodel( "vehicle_m880_launcher_obj" );
		c4_array[index].angles = spot.angles;
		index++;
	}
		
	flag_wait("looked_at_missiles_failsafe");
	
	for(i=0;i<c4_array.size;i++)
	{
		if(IsDefined(c4_array[i]))
		{
			c4_array[i] delete();
		}
	}
}

kill_enemies()
{
    enemies = GetAIArray("axis");
    if(IsDefined(enemies))
    {
        foreach(guy in enemies)
        {
            if(isDefined(guy) && isAlive(guy))
            {
            	guy.no_pain_sound = true;
    			guy.diequietly = true;
                guy kill();
                wait(.05);
            }
        }
    }
}

retreat_dam_harassers()
{	
	enemies = get_ai_group_ai("dam_missile_harassers");
    enemies set_group_goalvolume( "dam_harrassers_retreat_goal_volume" );  
}

push_player_around(amount)
{
    level.player PushPlayerVector((0, amount, 0));
    wait(.1);
    level.player PushPlayerVector((0, amount/2, 0));
    wait(.1);
    level.player PushPlayerVector((0, amount/4, 0));
    wait(.2);
    level.player PushPlayerVector((0, 0, 0));
//    PrintLn("Done pushing player");
}

//MM notu sed anymore
temp_missile_impacts()
{
    missile_impact_array = GetEntArray( "missile_impact_origin", "targetname" );
    
    for ( i = 0; i < missile_impact_array.size; i++ )
    {
        if ( IsDefined( missile_impact_array[ i ] ) )
        {
            PlayFX( level._effect[ "temp_missile_impact" ], missile_impact_array[ i ].origin );
        }
        
        missile_pause = RandomFloatRange( 0.25, 1.0 );
        wait( missile_pause );
    }
}

missile_launch_failsafe()
{

//    trigger = GetEnt("missile_launch_failsafe", "targetname");
//    trigger waittill("trigger");
	flag_wait("vignette_dam_break");
	
	
    
    flag_set("looked_at_missiles_failsafe");
}

flee_from_flood()
{
    rangers = get_ai_group_ai("advancing_allies");
    
    rangers set_group_goalvolume( "post_dam_flee" );
}

//play_approaching_missiles_vo()
//{
////    flag_wait("approaching_missiles");
////    thread add_dialogue_line("Keegan", "You seeing this? We've got multiple SAMs coming on line, Baker.");
////    wait(3.0);
////    thread add_dialogue_line("Baker", "Control. Clear all birds out of the sky");
////    wait(2.0);
////    thread add_dialogue_line("Control", "Go again, Zero-one? No friendly birds are in your airspace.");
////    wait(3.0);
////    thread add_dialogue_line("Diaz", "Then what the hell are they aiming at?");
////    wait(2.0);
//}

//play_missiles_fired_vo()
//{
////    flag_wait("missiles_fired");
////    //after missiles fired
////    wait(5.0);
////    thread add_dialogue_line( "Diaz", "It was the Dam. His target was the Dam.  He's flooding the city. We've got to get everyone out of here." );    
////    wait(5.0);
////    thread add_dialogue_line( "Baker", "We came here for one reason, and we're not letting Rorke get away again." );
////    wait(3.0);
////    thread add_dialogue_line( "Baker", "Alright, men.  On Me.");
////    
//}

ignore_everything(timer)
{
	self endon("death");
	
    self.ignoreall = true;
    self.ignoreme = true;
    self.grenadeawareness = 0;
    self.ignoreexplosionevents = true;
    self.ignorerandombulletdamage = true;
    self.ignoresuppression = true;
    self.disableBulletWhizbyReaction = true;
    self disable_pain();
    self.dontavoidplayer = true;
    self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
    self.newEnemyReactionDistSq = 0;
    
    if(IsDefined(timer) && timer != 0.0)
    {
        wait(timer);
    
        self clear_ignore_everything();
    }
}

clear_ignore_everything()
{
    self.ignoreall = false;
    self.ignoreme = false;
    self.grenadeawareness = 1;
    self.ignoreexplosionevents = false;
    self.ignorerandombulletdamage = false;
    self.ignoresuppression = false;
    self.disableBulletWhizbyReaction = false;
    self enable_pain();
    self.dontavoidplayer = false;
    self.script_dontpeek = 0;
    if( IsDefined( self.og_newEnemyReactionDistSq ) )
    {
        self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
    }
}

dialogue_dam()
{
	trigger = GetEnt( "aim_missiles_2", "targetname" );
    trigger waittill( "trigger" );
        
    battlechatter_off( "allies" );
	//Vargas: Take that launcher out!
	level.allies[ 0 ] smart_dialogue( "flood_pri_takethatlauncherout" );
	
	if(level.start_point == "dam")
    	wait(3.0);
	
	wait( 1.0 );
    //Merrick: The SAMs gonna fire.
    level.allies[ 1 ] smart_dialogue( "flood_diz_samsgonnafire" );
    //Oldboy: What the hell is it targeting?
    level.allies[ 2 ] smart_dialogue( "flood_mrk_whatthehellis" );
		
   	//Vargas: We gotcha covered! Just take out the launcher!
   	//Vargas: Take that launcher out!
   	//Vargas: Stop the launch!
   	level.allies[ 0 ] thread streets_nag_end_on_notify( make_array( "flood_bkr_gotyoucovered", "flood_pri_takethatlauncherout", "flood_bkr_stopsequence" ), "looked_at_missiles_failsafe", "flag_set" );
	flag_wait( "looked_at_missiles_failsafe" );
	level.allies[ 0 ] StopSounds();
	level.allies[ 0 ] notify( "flag_set" );
}

remove_allies()
{
	allies = get_ai_group_ai("street_start_allies");
	
	if(allies.size > 0)
	{
		foreach(guy in allies)
		{
	//		guy stop_magic_bullet_shield();
			guy delete();
		}
	}
}

remove_live_grenades()
{
	grenades = GetEntArray( "grenade", "classname" );
	for ( i = 0; i < grenades.size; i++ )
	{
		if(isdefined(grenades[i]))
		{
			grenades[i] delete();
		}
	}
}

//using physics push to get the cones out of the way
remove_dyn_objects()
{
	PhysicsExplosionSphere(level.player.origin, 1100, 1000, 2.0);
}

remove_stuff_for_animation()
{
	wait(2.0);
	stuff = GetEntArray( "dam_break_delete", "targetname" );
	for ( i = 0; i < stuff.size; i++ )
	{
		if(isdefined(stuff[i]))
		{
			stuff[i] delete();
		}
	}	
}

add_dam_vignette_hud_overlay()
{
	//NO LONGER USING NOTETRACK FLAG
	//wait for notetrack instead of flag
	// or set flag in flood_anim...
//	flag_wait("vignette_lens");
	
	self.hud_overlay = create_hud_static_overlay("flood_ui_vignette", 0, 0.0);	
//	self.hud_overlay = create_hud_static_overlay("nightvision_overlay_goggles", 0, 1.0);

//	wait(5);
	
	//fade in
//	iprintln("fading in");
	count = 0;
	step = 7.5;
	while(count<75)
	{
		self.hud_overlay.alpha = count/100;
		count = count + step;
		wait(.1);
	}
//	iprintln("fading in done");
	//when/how to turn off...timer or notetrack
//	wait(5);
	flag_wait("vignette_lens_fade_out");
//	IPrintLn("vignette_lens_fade_out");
	//fade out
//	iprintln("fading out");
	step = 4;
	while(count>0)
	{
		self.hud_overlay.alpha = count/100;
		count = count - step;
		wait(.1);
	}
//	iprintln("fading out done");
	self.hud_overlay destroy();
}

create_hud_static_overlay(overlay, sortOrder, alphaValue)
{
	hud = NewHudElem();
	hud.x = 0;
	hud.y = 0;
	hud.sort = sortOrder;
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alpha = alphaValue;
	hud SetShader( overlay, 640, 480 );

	return hud;
}

hide_spire()
{
	spire = GetEnt("flood_church_spire", "targetname");
	spire hide();
}

mlrs_qte_prompt()
{
	maps\flood_ending::ending_create_qte_prompt( &"FLOOD_LAUNCHER_MELEE", undefined );
	thread maps\flood_ending::ending_fade_qte_prompt( 0.5, 1.0 );

	flag_wait( "qte_window_closed" );

	maps\flood_ending::ending_fade_qte_prompt( 0.25, 0.0 );
	maps\flood_ending::ending_destroy_qte_prompt();
}

dam_waterfall_hide()
{
	wait(8.3);
	waterfall_array = GetEntArray("dam_waterfall_to_hide", "targetname");
	foreach ( thing in waterfall_array)
	{
		thing delete();
	}
	
}