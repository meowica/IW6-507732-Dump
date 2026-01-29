#include maps\_utility;
//#include maps\_utility_code;
#include common_scripts\utility;
//#include maps\_vehicle;
#include maps\_anim;


// TEARGAS CONSTANTS
TEARGAS_HEIGHT = 100;
TEARGAS_DURATION = 15;
TEARGAS_SAFE_RADIUS = 200;
TEARGAS_EXPANSION_TIME = 3;
TEARGAS_AFFECT_PLAYER_DURATION = 7;
TEARGAS_SCRIPTED_FLEE_NODE_RADIUS = 2000;
TEARGAS_RADIUS = 300;


initTearGas()
{
	level.TEARGAS_LOADED = 1;
	
	precache_teargas();
	
	level.teargas_reaction_anim = [];
	level.teargas_reaction_anim[0] = "teargas_react1";
	level.teargas_reaction_anim[1] = "teargas_react2";
	level.teargas_reaction_anim[2] = "teargas_react3";

	level.teargas_recover_anim = [];
	level.teargas_recover_anim[0] = "teargas_recover1";
	level.teargas_recover_anim[1] = "teargas_recover2";
	level.teargas_recover_anim[2] = "teargas_recover3";
	level.teargas_recover_anim[3] = "teargas_recover4";
	level.teargas_recover_anim[4] = "teargas_recover5";
	level.teargas_recover_anim[5] = "teargas_recover6";
	level.teargas_recover_anim[6] = "teargas_react_inplace";

	level.teargas_flush_volumes = GetEntArray("teargas_flush_volume", "targetname");
	
	level.active_teargas =[];

	thread handle_teargas_grenades();
	thread handle_teargas_launcher();
}

handle_teargas_grenades()
{
	level.teargas_count = 0;

	level endon("death");
	
	for (;;)
	{
		level.player waittill ( "grenade_fire", grenade, weaponName );
		if (weaponName == "teargas_grenade")
		{
			level.player notify ("teargas_thrown");
			grenade thread track_teargas();
		}
	}
}

handle_teargas_launcher()
{
	level endon("death");
	
	for (;;)
	{
    	level.player waittill ( "missile_fire", grenade, weaponName ); 

    	if (weaponName == "m203_teargas_m4_acog")
		{
    		level.player notify("teargas_launched");
    		grenade thread track_teargas();
		}
	}
}

track_teargas()
{
	self endon("death");
	level endon("death");
	
	tracker = spawn("script_origin", (0,0,0) );
	
	tracker endon("death");
	
	self.exploded = false;
	self thread handle_teargas_explode(tracker);
	
	while ( IsDefined(self) && !self.exploded  )
	{
		tracker.origin = self.origin;
		foreach (vol in level.teargas_flush_volumes)
		{
			if ( tracker istouching( vol ) )
			{
				vol notify("teargas_touched");
			}
		}
		wait 0.05;
	}
}

handle_teargas_explode(tracker)
{
	self waittill("explode", org);
	flush_vols = 0;
	tracker.origin = org;
	
	foreach  ( vol in level.teargas_flush_volumes )
	{
		if ( tracker IsTouching( vol ) )
		{
			vol thread handle_teargas_volume(org);
			vol notify("teargas_exploded");
			flush_vols++;
		}
	}
	
	if ( flush_vols == 0 )
	{
		thread add_teargas_cloud_radius(TEARGAS_RADIUS, org);
	}
	
	tracker Delete();
}

handle_teargas_volume(teargas_origin)
{
	if ( !IsDefined(self.target) )
	{
		// nothing linked to this volume -- why put a volume in if you don't have a specific place for guys to flee to.
//		Assert( false );  // teargas flee volume created with no target nodes or volume
		thread add_teargas_cloud_radius(TEARGAS_RADIUS, teargas_origin, self);
		return;
	}
	
	affected_ai = self get_ai_touching_volume( "axis" );

	foreach( retreater in affected_ai )
	{
		wait (RandomIntRange(1,3));
		
		if(IsDefined(retreater) && IsAlive(retreater))
		{
			retreater.fixednode = 0;
			retreater.pathRandomPercent = randomintrange( 75, 100 );

			flee_node = undefined;
			flee_volume = undefined;
			
			nodes = GetNodeArray(self.target, "targetname");
				
			if ( nodes.size > 0)
			{
				flee_node = nodes[RandomInt(nodes.size)];
			}
			
			if ( IsDefined(flee_node) )
			{
				retreater thread ai_flee_from_teargas( flee_node );
			}
			else
			{
				// flee nodes not connected, check if its a volume
				
				flee_volume = GetEnt(self.target, "targetname");
				if (IsDefined(flee_volume) )// && check if this is a volume )
				{
					retreater thread ai_flee_from_teargas( undefined, flee_volume);
					waitframe();
					retreater SetGoalVolume( flee_volume );
					//wait(RandomFloatRange(delay_min,delay_max)); // Only want to wait if we actually processed someone.
				}
			}
		}
	}
}

add_teargas_cloud_radius(radius, origin, volume)
{
	// no volumes, use simple radius searches
	level.teargas_count++;
	idNum = level.teargas_count;
	
	level endon("death");
	
	guys = GetAIArray("axis");
	
	r2 = radius * radius;
	
	foreach (guy in guys)
	{
		d2 = distancesquared(guy.origin, origin);
		if ( r2 > d2 )
		{
			if(IsDefined(guy) && IsAlive(guy))
			{
				guy thread ai_react_to_teargas(origin, radius);
			}
		}
	}
	
	nodes = getNodesInRadius( origin, radius, 0, TEARGAS_HEIGHT, "Path" );
	teargas_trigger = Spawn( "trigger_radius", origin, 1, radius-100, TEARGAS_HEIGHT );

	teargas_trigger thread handle_people_in_teargas();
	new_teargas = teargas_trigger;
	new_teargas.nodes = nodes;
	new_teargas.origin = origin;
	new_teargas.time = GetTime();
	new_teargas.bp_id = idNum;
		
	level.active_teargas[level.active_teargas.size] = new_teargas;

	// put badplaces in for non-volume handled teargas - this appears to break guys pathing OUT of gassed areas - disabled for now
	
	// badplaces for allies?
	allies_badplace_name = undefined;
	if ( !IsDefined(level.disable_teargas_ally_badplaces) || level.disable_teargas_ally_badplaces == false)
	{
		allies_badplace_name = "ally_teargas_bp" + string(idNum);
		if ( IsDefined(volume) )
		{
			BadPlace_Brush(allies_badplace_name, TEARGAS_DURATION, volume, "allies");
		}
		else
		{
			BadPlace_Cylinder(allies_badplace_name, TEARGAS_DURATION, origin, radius, TEARGAS_HEIGHT, "allies" );
	////	BadPlace_Cylinder_Teargas(allies_badplace_name, TEARGAS_DURATION, origin, radius, TEARGAS_HEIGHT, "allies" );
		}
	}
	
	wait (TEARGAS_EXPANSION_TIME);
	
	// badplaces for enemies
	axis_badplace_name = "axis_teargas_bp" + string(idNum);
	if ( IsDefined(volume) )
	{
		BadPlace_Brush(axis_badplace_name, TEARGAS_DURATION, volume, "axis");
	}
	else
	{	
		BadPlace_Cylinder(axis_badplace_name, TEARGAS_DURATION, origin, radius, TEARGAS_HEIGHT, "axis");
////	BadPlace_Cylinder_Teargas(axis_badplace_name, TEARGAS_DURATION, origin, radius, TEARGAS_HEIGHT, "axis");
	}
	
	wait( TEARGAS_DURATION - TEARGAS_EXPANSION_TIME );

	if ( IsDefined(allies_badplace_name) )
	{
		BadPlace_Delete(allies_badplace_name);
	}
	BadPlace_Delete(axis_badplace_name);
	
	idx = array_find(level.active_teargas, new_teargas);
	array_remove_index(level.active_teargas, idx);
	teargas_trigger.finished = true;
	teargas_trigger notify("finished");
	waitframe();
	teargas_trigger delete();
}

handle_people_in_teargas()
{
	self endon("death");
	self endon("finished");

	for (;;)
	{
		self waittill("trigger", other);
		
		if (IsDefined(self.finished))
		{
			return;
		}

		if (other != level.player)
		{
			other ai_react_to_teargas(self.origin, TEARGAS_RADIUS);
		}
		else if ( !IsDefined(level.player.gasmask_on) || level.player.gasmask_on == false )
		{
			level.player SetWaterSheeting( 1, TEARGAS_AFFECT_PLAYER_DURATION);
			level.player ShellShock("default", TEARGAS_AFFECT_PLAYER_DURATION);
	//		level.player SetMoveSpeedScale(0.75);
			wait(TEARGAS_AFFECT_PLAYER_DURATION-1);
	//		level.player SetMoveSpeedScale(1);
		}

	}
}


remove_other_gassed_nodes(nodes, origin)
{
	badnodes = [];
	
	foreach (cloud in level.active_teargas)
	{
		if (IsDefined(cloud) && IsDefined(cloud.origin) && cloud.origin != origin && IsDefined(cloud.nodes) )
		{
			nodes = array_remove_array(nodes, cloud.nodes);
		}
	}
	
	return nodes;
}

find_scripted_teargas_flee_node(origin, gas_radius, search_radius)
{
	search_radius_squared = search_radius * search_radius;
	gas_radius_squared = gas_radius * gas_radius;
	gas_dist_to_player = DistanceSquared(origin, level.player.origin);
		
	nodes = GetNodeArray("teargas_flee_node", "targetname");
	ok_nodes = [];
	the_node = undefined;
	
	foreach (node in nodes)
	{
		dist = DistanceSquared(origin, node.origin);
		
		if (dist <= search_radius_squared && dist < gas_radius_squared)
		{
			dist_to_player = DistanceSquared(node.origin, level.player.origin);
			
			if ( dist_to_player < gas_dist_to_player )
			{
				ok_nodes[ok_nodes.size] = node;
			}
		}
	}
	
	if (ok_nodes.size > 0)
	{
		the_node = ok_nodes[ randomInt(ok_nodes.size) ];
	}
	
	return the_node;
}

find_teargas_free_node( origin, max_radius, min_radius )
{
	if ( !isdefined( min_radius ) )
	{
		min_radius = 0;
	}
	
	nodes = getNodesInRadius( origin, max_radius, min_radius, TEARGAS_HEIGHT, "Path" );

	nodes = remove_other_gassed_nodes(nodes, origin);

	if ( !isdefined( nodes ) || nodes.size == 0 )
		return;
	

	node = nodes[ randomInt( nodes.size ) ];
	nodes = array_remove( nodes, node );
	
	while ( isdefined( node.owner ) )
	{
		if ( nodes.size == 0 )
			return;
			
		node = nodes[ randomInt( nodes.size ) ];
		nodes = array_remove( nodes, node );
	}
	
	return node;
}

ai_react_to_teargas(origin, radius)
{
	self endon("death");

	if (IsDefined( self.gasmask_on ) && (self.gasmask_on == true))
	{
		return;
	}
	// make them not react immediately, unless they're right on top of it.
	dist = Distance2D(self.origin, origin);
	if (dist > 100)
	{
		wait_time = ( (dist/radius) * TEARGAS_EXPANSION_TIME );
		
		wait (wait_time);
		
		// check to see if the AI naturally left the area
		dist = Distance2D(self.origin, origin);
		if (dist > radius)
		{
			return;
		}
	}
	
	node = find_scripted_teargas_flee_node(origin, radius, TEARGAS_SCRIPTED_FLEE_NODE_RADIUS);

	if (!IsDefined(node))
	{
		node = find_teargas_free_node(origin, radius + TEARGAS_SAFE_RADIUS, radius);
	}

	if ( IsDefined( node ) )
		ai_flee_from_teargas( node );
}

ai_flee_from_teargas(node, newgoalvolume)	
{
	self endon("death");
	
	if ( IsDefined( self ) == false || IsAlive( self ) == false )
		return;
	
	self set_ignoreSuppression(true);

	old_animname = self.animname;
	self ClearEnemy();
	old_badplace_awareness = self.badplaceawareness;
	self.badplaceawareness = 0;
	self.ignoreall = true;
	self.allowdeath = true;
	self.disablearrivals = true;
	self.script_forcegoal = false;
	
	// play intial reaction anim
	if ( !IsDefined(self.teargassed) )
	{
		// only play tear gas animation if not already gassed
		self.teargassed = true;
	
		reaction_anim = level.teargas_reaction_anim[randomint(level.teargas_reaction_anim.size)];
			
		self.animname = "generic";		
		self childthread anim_generic(self, reaction_anim);
	}

	old_goalradius = self.goalradius;

	run_anim_name = "teargas_run" + (1 + RandomInt(5));
	self set_run_anim(run_anim_name);

	if(IsDefined(newgoalvolume))
	{
		self SetGoalVolumeAuto(newgoalvolume);
		self waittill("goal");
		//self waittill("reached_path_end");
		wait(RandomFloatRange(2, 5));
	}
	else
	{
		if (isDefined(node))
		{
			self set_goalradius(20);
			self SetGoalNode(node);
			self waittill("goal");
		}
		else
		{
			// no safe nodes make ai do something different.  die?
			self set_goalradius(50);
			self SetGoalEntity(level.player);
			
			self waittill("goal");
		}
	}
	self set_goalradius(old_goalradius);
	
	// play recover anim
	recover_anim = level.teargas_recover_anim[randomint(level.teargas_recover_anim.size)];
	
	self anim_generic(self, recover_anim);
	
	self clear_run_anim();
	self.ignoreall = false;
	//self.disablearrivals = false;
	self.badplaceawareness = old_badplace_awareness;
	self set_ignoreSuppression(false);
	
	if ( IsDefined(self.animname) && self.animname == "generic" )
	{
		self.animname = old_animname;
	}
	self.teargassed = undefined;

}

#using_animtree ("generic_human");
precache_teargas()
{
	PreCacheItem("teargas_grenade");
	
	level.scr_anim[ "generic" ][ "teargas_react1" ] = %teargas_react_1;
	level.scr_anim[ "generic" ][ "teargas_react2" ] = %teargas_react_2;
	level.scr_anim[ "generic" ][ "teargas_react3" ] = %teargas_react_3;
	level.scr_anim[ "generic" ][ "teargas_react_inplace" ] = %teargas_react_in_place_1;
	level.scr_anim[ "generic" ][ "teargas_run1" ][0] = %teargas_run_1;
	level.scr_anim[ "generic" ][ "teargas_run2" ][0] = %teargas_run_2;
	level.scr_anim[ "generic" ][ "teargas_run3" ][0] = %teargas_run_3;
	level.scr_anim[ "generic" ][ "teargas_run4" ][0] = %teargas_run_4;
	level.scr_anim[ "generic" ][ "teargas_run5" ][0] = %teargas_run_5;

	level.scr_anim[ "generic" ][ "teargas_recover1" ] = %teargas_recover_1;
	level.scr_anim[ "generic" ][ "teargas_recover2" ] = %teargas_recover_2;
	level.scr_anim[ "generic" ][ "teargas_recover3" ] = %teargas_recover_3;
	level.scr_anim[ "generic" ][ "teargas_recover4" ] = %teargas_recover_4;
	level.scr_anim[ "generic" ][ "teargas_recover5" ] = %teargas_recover_5;
	level.scr_anim[ "generic" ][ "teargas_recover6" ] = %teargas_recover_6;
	
	//addNotetrack_customFunction( "generic", "drop_riot_shield", animscripts\riotshield\riotshield::noteTrackDetachShield, "teargas_riot_react_1" );
}
