
main()
{
	maps\mp\mp_chasm_precache::main();
	maps\createart\mp_chasm_art::main();
	maps\mp\mp_chasm_fx::main();
	
	level thread maps\mp\_movers::main();
	maps\mp\_movers::script_mover_add_parameters("falling_elevator", "delay_till_trigger=1");
	maps\mp\_movers::script_mover_add_parameters("falling_elevator_cables", "delay_till_trigger=1");
	maps\mp\_movers::script_mover_add_parameters("elevator_drop_1", "move_time=.7;accel_time=.7");
	maps\mp\_movers::script_mover_add_parameters("elevator_drop_2", "move_time=1.2;accel_time=1.2;name=elevator_end");
	maps\mp\_movers::script_mover_add_parameters("doughnut", "move_speed=300;unresolved_collisions=1");
	maps\mp\_movers::script_mover_add_parameters("doughnut_path_1", "delay_till_trigger=1");
	maps\mp\_movers::script_mover_add_parameters("doughnut_path_2", "delay_till_trigger=0");
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_chasm" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_chasm" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_outfit"] = "woodland";
	game["axis_outfit"] = "urban";
	
	level thread falling_elevator();
	level thread doughnut();
}

doughnut()
{
	doughnut = GetEnt("doughnut", "targetname");
	if(!IsDefined(doughnut))
		return;
	
	doughnut thread explosive_damage_watch(doughnut);
	
	while(1)
	{
		doughnut waittill("explosive_damage");
		
		doughnut notify("trigger");
		break;
	}
}

falling_elevator()
{
	elevator = GetEnt("falling_elevator", "targetname");
	cables = GetEnt("falling_elevator_cables", "targetname");
	
	if(!IsDefined(elevator) || !IsDefined(cables))
		return;
	
	while(!IsDefined(elevator.linked_ents))
		wait .05;
	
	elevator.state = 1;
	
	elevator thread falling_elevator_cables(cables);
	elevator thread explosive_damage_watch(elevator, "next_stage");
	foreach(ent in elevator.linked_ents)
	{
		elevator thread explosive_damage_watch(ent, "next_stage"); 
	}
	
	while(1)
	{
		elevator waittill("next_stage");
		if(elevator.moving)
			continue;
		
		elevator.state++;
		
		elevator notify("trigger"); //Move to next state
		if(IsDefined(cables))
			cables notify("trigger");
	}
}

explosive_damage_watch(ent, note)
{
	if(!IsDefined(note))
		note = "explosive_damage";
	
	ent SetCanDamage(true);
	while(1)
	{
		ent.health = 1000000;
		ent waittill("damage", amount, attacker, direction_vec, point, type);
		if(!is_explosive(type))
		{
			continue;
		}
		self notify(note);
	}
}

falling_elevator_cables(cables)
{
	large_health = 1000000;
	cables SetCanDamage(true);
	cables.health = large_health;
	cables.fake_health = 50;
	
	while(1)
	{
		cables waittill("damage", amount, attacker, direction_vec, point, type);
		
		if(cables.moving || (self.state==2 && !is_explosive(type)))
		{
			cables.health = cables.health + amount;
			continue;
		}
		
		if(cables.health>large_health-cables.fake_health)
		{
			continue;
		}
		
		self notify("next_stage");
		break;
	}
}

is_explosive( cause )
{
	if(!IsDefined(cause))
		return false;
	
	cause = tolower( cause );
	switch( cause )
	{
		case "mod_grenade_splash":
		case "mod_projectile_splash":
		case "mod_explosive":
		case "splash":
			return true;
		default:
			return false;
	}
	return false;
}


