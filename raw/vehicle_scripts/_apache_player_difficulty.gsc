
difficulty()
{
	struct = SpawnStruct();
	
	Assert( IsDefined( level.gameskill ) );
	
	
	//defaults
	struct.dmg_bullet_delay_between_msec	= 350;
	struct.dmg_bullet_pct					= 0.08;			   //Bullet damage from ZPUs, Turrets (Gaz, Boats, Hinds) and infantry
	struct.dmg_projectile_pct				= 0.76;			   //Missiles
	struct.dmg_player_health_adjust_chance	= 0.45;			   //When the player's health is below this scale bullet chance relative to speed.
	struct.dmg_player_speed_evade_min_pct	= 0.50;			   //When the player's speed is at or above this pct of max speed the chance to hit is lowest
	struct.dmg_player_speed_evade_max_pct	= 0.20;			   //When the player's speed is at or below this pct of max speed the chance to hit is highest
	struct.dmg_bullet_chance_player_static	= 0.55;			   //Chance bullets will hit when the player is slow moving (below N speed)
	struct.dmg_bullet_chance_player_evade	= 0.10;			   //Chance bullets will hit when the player is evading (above N speed)
	struct.in_range_for_homing_missile_sqrd = squared( 24000 ); //
	
	switch( level.gameSkill )
	{
		case 0:									// Easy
			
			struct.dmg_bullet_delay_between_msec  = 450;
			struct.dmg_bullet_pct				   = 0.02;
			struct.dmg_bullet_chance_player_evade = 0.05; //Chance bullets will hit when the player is evading (above N speed)
			break;
		case 1:									// Regular
			struct.dmg_bullet_delay_between_msec = 350;
			struct.dmg_bullet_pct = 0.04;
			break;
		case 2:									// Hardened
			struct.dmg_bullet_delay_between_msec = 350;
			struct.dmg_bullet_pct = 0.06;
			break;
		case 3:									// Veteran
			break;
		default:
			AssertMsg( "apache player unhandled difficulty level: " + level.gameSkill );
			struct.flares_auto		= true;
			break;
	}
	
	level.apache_player_difficulty = struct;
	
}