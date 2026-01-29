

apache_mission_difficulty()
{
	level.apache_difficulty = SpawnStruct();
	
	Assert( IsDefined( level.gameskill ) );
	
	flares_auto		= undefined;
	
	ai_rpg_attack_delay_min = 7.0;	//Minimum seconds between allowed rpg lock on attacks from AI
	ai_rpg_attack_delay_max = 10.5; //Maximum seconds between allowed rpg lock on attacks from AI
	
	enemy_zpu_health	   = 600;
	enemy_gaz_health	   = 900;
	enemy_hind_health	   = 19999;
	enemy_gunboat_health = 1999;
	
	zpu_range_squared				   = 12000 * 12000;
	veh_turret_range_squared		   = 12000 * 12000;
	heli_vs_heli_mg_range_2d_squared   = squared( 900 ); //Inside this Distance 2D Squared AI helis will use their MG
	heli_vs_heli_min_shoot_time_msec   = 1500;			 // Helicopters shoot at each other (and the player) at the least every this many milliseconds
	heli_vs_heli_max_shoot_time_msec   = 3000;			 //Helicopters shoot at each other (and the player) at the most every this many milliseconds
	vehicle_vs_player_lock_on_time	   = 1.5;			 //Helicopters from
	gunboat_time_between_missiles_msec = 5000;			 //Delay between allowed missile launches from gunboats
	gunboat_chance_fire_missile_at_ai  = 0.4;			 //Chance that a gunboat will fire a missile at the player
	
	zpu_magic_bullets = 12; // number of bullets it takes to take down a zpu
	
	switch( level.gameSkill )
	{
		case 0:									// Easy
			ai_rpg_attack_delay_min = 8.0;
			ai_rpg_attack_delay_max = 11.5;
			enemy_zpu_health	   = 600;
			enemy_gaz_health	   = 900;
			enemy_hind_health	   = 11999;
			enemy_gunboat_health = 1199;
			zpu_magic_bullets = 5;
			flares_auto		= true;
			break;
		case 1:									// Regular
			flares_auto		= false;
			zpu_magic_bullets = 7;
			break;
		case 2:									// Hardened
			flares_auto		= false;
			zpu_magic_bullets = 10;
			break;
		case 3:									// Veteran
			ai_rpg_attack_delay_min = 6.0;
			ai_rpg_attack_delay_max = 9.5;
			flares_auto		= false;
			break;
		default:
			AssertMsg( "Oilrocks unhandled difficulty level: " + level.gameSkill );
			flares_auto		= true;
			break;
	}
	
	level.apache_difficulty.flares_auto = flares_auto;
	
	level.apache_difficulty.ai_rpg_attack_delay_min = ai_rpg_attack_delay_min;
	level.apache_difficulty.ai_rpg_attack_delay_max = ai_rpg_attack_delay_max;
	
	
	level.apache_difficulty.enemy_zpu_health	 = enemy_zpu_health;
	level.apache_difficulty.enemy_gaz_health	 = enemy_gaz_health;
	level.apache_difficulty.enemy_hind_health	 = enemy_hind_health;
	level.apache_difficulty.enemy_gunboat_health = enemy_gunboat_health;
	
	level.apache_difficulty.zpu_range_squared				   = zpu_range_squared;
	level.apache_difficulty.veh_turret_range_squared		   = veh_turret_range_squared;
	level.apache_difficulty.heli_vs_heli_mg_range_2d_squared   = heli_vs_heli_mg_range_2d_squared;
	level.apache_difficulty.heli_vs_heli_min_shoot_time_msec   = heli_vs_heli_min_shoot_time_msec;
	level.apache_difficulty.heli_vs_heli_max_shoot_time_msec   = heli_vs_heli_max_shoot_time_msec;
	level.apache_difficulty.vehicle_vs_player_lock_on_time	   = vehicle_vs_player_lock_on_time;
	level.apache_difficulty.gunboat_time_between_missiles_msec = gunboat_time_between_missiles_msec;
	level.apache_difficulty.gunboat_chance_fire_missile_at_ai  = gunboat_chance_fire_missile_at_ai;
	
	level.apache_difficulty.zpu_magic_bullets = zpu_magic_bullets;
	
}