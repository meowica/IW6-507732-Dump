#include common_scripts\utility;
#include maps\_utility;

init()
{
	level thread init_fx_triggers();
	level thread global_breakables_think();
	level thread func_glass_handler();
	level thread impact_override();
}
set_fungglass_life(weaken,destroy)
{
	SetSavedDvar("glass_damageToWeaken",weaken);
	SetSavedDvar("glass_damageToDestroy",destroy);
}

global_breakables_think()
{
	// groupname 			== Models
	// script_group 		== Damage radius (1/2->2x dmg)
	// script_noteworthy 	== vfx_breakable
	// script_parameters	== Effects to play
	// targetname 			== Optional, this is targeted from another
	// target				== who to do damage along with this one
	// Script_spawn_pool	== Health
	
	ents = GetEntArray("vfx_breakable","script_noteworthy");
	breakables = [];
	foreach ( ent in ents)
	{
		if (IsDefined(ent.script_parameters))
		{
			if( ( IsSubStr( ent.script_parameters, ".efx" ) ) || ( IsSubStr( ent.script_parameters, ".EFX" ) ) || ( IsSubStr( ent.script_parameters, "fx/" )))
				breakables[breakables.size] = ent;
		}
	}
	
	foreach ( breakable in breakables)
	{ 
		if ( isdefined( breakable.groupname ) && IsDefined(breakable.script_spawn_pool) )
		{
   			model_tokens = StrTok( breakable.groupname, "|" );
   			foreach (token in model_tokens)
   				if (token != "NO_MODEL" && token != "no_model")
					precacheModel( token ); 
   			vfx_efx_tokens = StrTok( breakable.script_parameters, "|" );
   			vfx_tokens = [];
   			health_tokens = StrTok( breakable.script_spawn_pool, "|" );
   			foreach ( vfx in vfx_efx_tokens)
   			{
   				fx_strp = StrTok( vfx, "." )[0]; // Remove .efx 
				level._effect[fx_strp]= LoadFX(fx_strp); 
				vfx_tokens[vfx_tokens.size]=fx_strp;
   			}  
   			
   			breakable thread global_breakable_wait(model_tokens,vfx_tokens,health_tokens,int(health_tokens[0]));
   			
		}
	}
}
global_breakable_target_damage_wait()
{
	origin = self.origin;
	self endon("delete");
	while(IsDefined(self))
	{
		targetname = self.target;
		self waittill("damage",amount);
		// Have to get targets here since a child could change
		targets = GetEntArray( targetname, "targetname" );
		foreach ( t in targets)
		{
			if (IsDefined(t))
				t DoDamage(amount,origin);
		}
	}
}
global_breakable_wait(model_tokens,vfx_tokens,health_tokens,this_health)
{
	// Damage radius psuedocode
	this_center = self.origin;
	if (isdefined(self.target))
	{
		self thread global_breakable_target_damage_wait();
	}
	
	self.health = this_health;
	self SetCanDamage(true);	
	self waittill("death");

	if( !IsDefined( self ) )
		return;
	
	model_next = 0;
	health_modifier = this_health;
	
	health_max = 0;
	foreach ( token in health_tokens)
	{
		itoken = int(token);
		health_max = health_max + itoken;
	}
	damage_done = self.health*-1 + this_health;
	
	this_targetname = "";
	this_newtarget = undefined;
	if (isdefined(self.targetname) && (self.targetname !=""))
		this_targetname = self.targetname;
	if (isdefined(self.target) )
		this_newtarget = self.target;
		
	//this_max_health = int(health_tokens[0]);
	/*
	current_health = health_max - this_max_health + self.health;
	*/
	//max_health = int(health_tokens[0]);
	

	model_next = -1;
	if (self.health !=0)
	{
		foreach ( token in health_tokens)
		{
			itoken = int(token);
			if (damage_done > itoken)
			{
				damage_done -= itoken;
				model_next++;
			}
			else
			{
				health_modifier = itoken - damage_done;
				break;
			}
		}
		//model_next -=1;
	}
	if (model_next < 0)
		model_next = 0;
	if (model_next > (model_tokens.size-1))
		model_next = model_tokens.size-1;
	neworigin = (0,0,0);
	if ( isdefined( self.origin ) )
		neworigin = self.origin;
	newangles = (0,0,0);
	if ( isdefined( self.angles ) )
		newangles = self.angles;
	script_group = undefined;
	if ( isdefined( self.script_group )  && (self.script_group !=0))
		script_group = self.script_group;
    
	PlayFX(level._effect[vfx_tokens[model_next]],self.origin,AnglesToForward(self.angles),AnglesToUp(self.angles));
	
	self delete();
	if (model_tokens[model_next] != "NO_MODEL" && model_tokens[model_next] != "no_model")
	{
		// Change this to model swap instead for faster runtime
		destroyed_model = spawn( "script_model", (0,0,0));
		destroyed_model.origin = neworigin;
		destroyed_model.angles = newangles;	
		destroyed_model.targetname = this_targetname;	
		destroyed_model.target = this_newtarget;	
		destroyed_model.script_group = script_group;
		destroyed_model SetModel(model_tokens[model_next]);
		
		if (model_tokens.size >model_next+1)
		{
			for ( i = 0; i < model_next+1; i++ )
			{
				model_tokens = array_remove_index(model_tokens,0);
				vfx_tokens =array_remove_index(vfx_tokens,0);
				health_tokens =array_remove_index(health_tokens,0);
			}
			new_health = health_modifier;//full_health-health_modifier;
			if (new_health <= 0)
				new_health = 1; // Just incase
			destroyed_model.health 		= new_health;
			destroyed_model thread global_breakable_wait(model_tokens,vfx_tokens,health_tokens,destroyed_model.health);
		}
		else
		{
			if ( isdefined( script_group ) )
				RadiusDamage(destroyed_model.origin,script_group,int(health_tokens[0])*2,int(health_tokens[0])/2);
		}
	}
	else
	{
		
		
	}
}
global_fx_array_to_string(vfx_array)
{
	vfx_string = "";
	for ( i = 0; i < vfx_array.size; i++ )
	{
		vfx_string+=vfx_array[i];
		if (i != vfx_array.size-1)
		{
			vfx_string+="|";
		}
	}
	
	return vfx_string;
}


/* 
Triggers
*/

init_fx_triggers()
{
	triggers = GetEntArray( "fx_trigger", "targetname");		// Get each object that has fx_trigger for targetname
	array_thread( triggers, ::handle_exploder_trigger );		// Thread flag trigger on this object
}

handle_exploder_trigger()
{
    // flag handle
    if (!flag_exist(self.script_flag))
    {
		flag_init( self.script_flag);
    }
    
    
    // Script_flag handle
    // Format = fx_100
    // Exploder number from second half
    
    tokens = StrTok( self.script_flag, "_" );
    fx_num = tokens[1];
    
    // Exploder must exist
    if (tokens.size == 2)
    {
        while( 1 )
        {
            flag_wait( self.script_flag );
            activate_exploder( fx_num );
            
            flag_waitopen( self.script_flag );
            stop_exploder( fx_num );
        }
    }
}


// Delete anything attached to this func glass
// Used for decals attached to glass
// Place decal inside of glass to get the cracking

func_glass_handler()
{
	// FuncGlassIndex  [ Index ] 
	// FuncGlassDecals [ Glass Index ] [ Attached SINGLE Decal ]
	// Funcglass.Targetname == Decal.Script_noteworthy
	funcglass_indexies = [];
	funcglass_decals = [];
	temp_decals = GetEntArray("vfx_custom_glass","targetname");
	foreach ( decal in temp_decals)
	{
		if (IsDefined(decal.script_noteworthy))
		{
			attached_glass = GetGlass(decal.script_noteworthy);
			if (IsDefined (attached_glass))
			{
				funcglass_decals[attached_glass] = decal;
				funcglass_indexies[funcglass_indexies.size] = attached_glass;
			}
		}
	}
	funcglass_alive_count   = funcglass_indexies.size;
	funcglass_count 		= funcglass_indexies.size;
	
	// Run up to 5 times on each frame, avoid too much going on
	max_iterations = 5;
	current_index = 0;
	while(funcglass_alive_count!=0)
	{
		max_index = current_index+max_iterations-1;
		if (max_index > funcglass_count)
			max_index = funcglass_count;
		if (current_index ==funcglass_count)
			current_index = 0;
		for (; current_index < max_index ; current_index++ )
		{
			glass_index = funcglass_indexies[current_index];
			decal 		= funcglass_decals[glass_index];
			
			// Decal is defined, glass isn't destroyed yet (here)
			if (IsDefined(decal))
			{
				// Glass is destroyed in the world
				if (IsGlassDestroyed(glass_index))
				{
					decal delete();
					funcglass_alive_count--;
					funcglass_decals[glass_index] = undefined;
				}
			}
		}
		wait(.05);
	}
}



impact_override()
{
	ents = GetEntArray("vfx_impact_override","targetname");
	breakables = [];
	foreach ( ent in ents)
	{
		if (IsDefined(ent.script_parameters))
		{
			if( ( IsSubStr( ent.script_parameters, ".efx" ) ) || ( IsSubStr( ent.script_parameters, ".EFX" ) ) || ( IsSubStr( ent.script_parameters, "fx/" )))
			{
   				fx_strp = StrTok( ent.script_parameters, "." )[0]; // Remove .efx 
				level._effect[fx_strp]= LoadFX(fx_strp); 
				ent.script_parameters = fx_strp;
				ent thread impact_override_object_damage_check();
			}
		}
	}
}
impact_override_object_damage_check()
{
	self SetCanDamage(true);	 
	self.health = 1000;
	self endon("delete");
	amount 			= undefined;
	attacker 		= undefined;
	direction_vec 	= undefined;
	point 			= undefined;
	type 			= undefined;
	
	while(IsDefined(self))
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type);
		type = ToLower( type );
		switch( type )
		{
			case "mod_pistol_bullet":
			case "mod_rifle_bullet":
			case "bullet":
			case "mod_projectile":
				fx = self.script_parameters;
				PlayFX(level._effect[fx],point,AnglesToForward(VectorToAngles(direction_vec)),AnglesToUp(VectorToAngles(direction_vec)));
		}
		self.health = 1000;
	}
}
