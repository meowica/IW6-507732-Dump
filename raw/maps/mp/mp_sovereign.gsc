#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	maps\mp\mp_sovereign_precache::main();
	maps\createart\mp_sovereign_art::main();
	maps\mp\mp_sovereign_fx::main();
	
	level thread maps\mp\mp_sovereign_events::assembly_line_precache();
	level thread maps\mp\_movable_cover::init();
	
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_sovereign" );
	thread maps\mp\_fx::func_glass_handler(); // Text on glass
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_sovereign" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	SetDvar("r_sky_fog_intensity","1");
	SetDvar("r_sky_fog_min_angle","60");
	SetDvar("r_sky_fog_max_angle","85");
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit" ] = "desert";

	level thread maps\mp\mp_sovereign_events::assembly_line();
	level thread maps\mp\mp_sovereign_events::halon_system();
	
	level thread walkway_collapse();
}

is_dynamic_path()
{
	return IsDefined(self.spawnflags) && self.spawnflags&1;
}

#using_animtree("animated_props");
walkway_collapse()
{
	PrecacheMpAnim("mp_sovereign_walkway_collapse_top");
	PrecacheMpAnim("mp_sovereign_walkway_collapse_bottom");
	PrecacheMpAnim("mp_sovereign_walkway_collapse_top_idle");
	PrecacheMpAnim("mp_sovereign_walkway_collapse_bottom_idle");

	
	collapse_top_length = GetAnimLength(  %mp_sovereign_walkway_collapse_top );
	collapse_bottom_length = GetAnimLength(  %mp_sovereign_walkway_collapse_bottom );
	
	swap_time = GetNotetrackTimes( %mp_sovereign_walkway_collapse_top, "bottom_anim_begin")[0];
	swap_time *= collapse_top_length;
	
	walkway_trigger_damage = GetEnt("walkway_trigger_damage", "targetname");

	animated_walkway_tank 	= GetEnt("walkway_tank_animated", "targetname");
	animated_walkway_tank ScriptModelPlayAnimDeltaMotion("mp_sovereign_walkway_collapse_top_idle");
	if(IsDefined(animated_walkway_tank.target))
	{
		animated_walkway_tank.clip = GetEnt(animated_walkway_tank.target, "targetname");
		if(IsDefined(animated_walkway_tank.clip))
		{
			animated_walkway_tank.clip LinkTo(animated_walkway_tank, "j_canister_main");
			animated_walkway_tank.clip thread walkway_collapse_FastVelocityPush();
			animated_walkway_tank.clip thread walkway_collapse_UnresolvedCollision();
		}
	}
	walkway_tank_end = GetEnt("walkway_tank_end", "targetname");
	walkway_tank_end Hide();
	
	walkway_clip_end = GetEntArray("walkway_clip_end", "targetname");
	array_thread(walkway_clip_end, ::walkway_collapse_clip_hide);
	
	walkway_tank_trigger_hurt = GetEnt("walkway_tank_trigger_hurt", "targetname");
	if(IsDefined(walkway_tank_trigger_hurt))
	{
		walkway_tank_trigger_hurt EnableLinkTo();
		walkway_tank_trigger_hurt LinkTo(animated_walkway_tank, "j_canister_main");
	}
	
	animated_walkway = GetEnt("walkway_animated", "targetname");
	animated_walkway ScriptModelPlayAnimDeltaMotion("mp_sovereign_walkway_collapse_bottom_idle");
	animated_walkway Hide();
	
	walkway_non_destroyed = walkway_collapse_group("walkway_non_destroyed");
	walkway_destroyed = walkway_collapse_group("walkway_destroyed");
	walkway_destroyed walkway_collapse_hide();
	
//	while(1)
//	{
//		walkway_wait();
//		
//		array_call(walkway_destroyed.linked, ::Unlink );
//		array_call(walkway_non_destroyed.linked, ::Unlink );
//		
//		walkway_wait();
//		
//		array_call(walkway_destroyed.linked, ::LinkTo, walkway_destroyed);
//		array_call(walkway_non_destroyed.linked, ::LinkTo, walkway_non_destroyed);
//		
//	}
	
	while(1)
	{
		walkway_wait(walkway_trigger_damage);
		
		exploder(2);
		animated_walkway_tank ScriptModelPlayAnimDeltaMotion("mp_sovereign_walkway_collapse_top");
		
		walkway_tank_trigger_hurt thread walkway_collapse_hurt_trigger();
		
		level delayThread(swap_time, ::exploder, 3);
		animated_walkway delayCall(swap_time, ::Show);
		animated_walkway delayCall(swap_time, ::ScriptModelPlayAnimDeltaMotion, "mp_sovereign_walkway_collapse_bottom");
		walkway_non_destroyed delayThread(swap_time, ::walkway_collapse_hide);
		array_thread(walkway_clip_end, ::delayThread, swap_time, ::walkway_collapse_clip_show);
		
		walkway_tank_trigger_hurt delayThread( swap_time+collapse_bottom_length, ::walkway_collapse_hurt_trigger_stop);
		walkway_destroyed delayThread(swap_time+collapse_bottom_length, ::walkway_collapse_show);
		animated_walkway delayCall(swap_time+collapse_bottom_length, ::Hide);
		animated_walkway_tank delayCall(swap_time+collapse_bottom_length, ::Hide);
		walkway_tank_end delayCall(swap_time+collapse_bottom_length, ::Show);
		if(IsDefined(animated_walkway_tank.clip))
		{
			animated_walkway_tank.clip delayThread(swap_time+collapse_bottom_length, ::walkway_collapse_clip_hide );
		}
		
		wait swap_time+collapse_bottom_length;
		
		walkway_wait();
		
		animated_walkway_tank Show();
		animated_walkway ScriptModelPlayAnimDeltaMotion("mp_sovereign_walkway_collapse_bottom_idle");
		walkway_tank_end Hide();	
		animated_walkway Hide();
		array_thread(walkway_clip_end, ::walkway_collapse_clip_hide);
		walkway_non_destroyed walkway_collapse_show();
		walkway_destroyed walkway_collapse_hide();
		if(IsDefined(animated_walkway_tank.clip))
		{
			animated_walkway_tank.clip walkway_collapse_clip_show();
		}
		
		wait 1; //TODO: Don't know why I need a wait here to make this anim play. and waitframe() is not enough
		animated_walkway_tank ScriptModelPlayAnimDeltaMotion("mp_sovereign_walkway_collapse_top_idle");
	}
}

walkway_collapse_hurt_trigger_stop()
{
	self notify("stop_walkway_collapse_hurt_trigger");
}

walkway_collapse_hurt_trigger()
{
	self endon("stop_walkway_collapse_hurt_trigger");
	
	while(1)
	{
		self waittill("trigger", player);
		if ( isPlayer( player ) )
		{
			player DoDamage( 1000, player.origin );
		}
	}
}

walkway_collapse_FastVelocityPush()
{
	self endon( "death" );

	while( 1 )
	{
		self waittill( "player_pushed", hitEnt, platformMPH );
		if ( isPlayer( hitEnt ) )
		{
			if ( platformMPH[2] < -20 )
			{
				hitEnt DoDamage( 1000, hitEnt.origin );
			}
		}
		wait 0.05;
	}
}


walkway_collapse_UnresolvedCollision()
{
	self endon( "death" );

	while( 1 )
	{
		self waittill( "unresolved_collision", hitEnt );
		if ( isPlayer( hitEnt ) )
		{
			hitEnt DoDamage( 1000, hitEnt.origin );
		}
		wait 0.05;
	}
}
	
walkway_wait(trigger)
{
	level thread walkway_wait_dvar();
	if(IsDefined(trigger))
		level thread walkway_wait_trigger(trigger);
	
	level waittill("activate_walkway");
}

walkway_wait_trigger(trigger)
{
	level endon("activate_walkway");
	trigger waittill("trigger");
	level notify("activate_walkway");
}

walkway_wait_dvar()
{
	level endon("activate_walkway");
	SetDevDvarIfUninitialized("trigger_walkway", "0");
	while(GetDvarInt("trigger_walkway")==0)
		wait .05;
	SetDevDvar("trigger_walkway", "0");
	
	level notify("activate_walkway");
}

walkway_collapse_hide()
{
	if(isDefined(self.walkway_collapse_hide) && self.walkway_collapse_hide)
		return;
	
	self.walkway_collapse_hide = true;
	self.origin -= (0,0,1000);
	
	foreach(ent in self.clip)
	{
		ent walkway_collapse_clip_hide();
	}
	
	self DontInterpolate();
}

walkway_collapse_clip_hide()
{
	if(self is_dynamic_path())
		self ConnectPaths();
	
	self.old_contents = self SetContents(0);
	self NotSolid();
	self Hide();
}

walkway_collapse_show()
{
	if(isDefined(self.walkway_collapse_hide) && !self.walkway_collapse_hide)
		return;
	
	self.walkway_collapse_hide = false;
	self.origin += (0,0,1000);
	
	foreach(ent in self.clip)
	{
		ent walkway_collapse_clip_show();
	}
	self DontInterpolate();
}

walkway_collapse_clip_show()
{
	self Solid();
	self SetContents(self.old_contents);
	self Show();
	
	if(self is_dynamic_path())
		self DisconnectPaths();
}

walkway_collapse_group(targetname)
{
	struct = GetStruct(targetname, "targetname");
	if(!IsDefined(struct))
		return undefined;
	
	parent = Spawn("script_model", struct.origin);
	parent SetModel("tag_origin");
	
	parent.clip = [];
	parent.linked = [];
	
	ents = struct get_linked_ents();
	foreach(ent in ents)
	{
		if(ent.classname == "script_brushmodel")
		{
			parent.clip[parent.clip.size] = ent;
		}
		else
		{
			parent.linked[parent.linked.size] = ent;
			ent LinkTo(parent);
			ent WillNeverChange();
		}
	}
	
	return parent;
}


