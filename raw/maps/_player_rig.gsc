#include maps\_utility;
#include common_scripts\utility;

/*###################################################
		HELPER FOR USING PLAYER RIG/LEGS
		1) call maps\_player_rig::init_player_rig( player_rig_model, player_legs_model ); they are both optional
		2a) call link_player_to_arms() to link the player to the player_rig (will automatically spawn in the player_rig)
		2b) call blend_player_to_arms( time ) to link the player to the player_rig with blending (will automatically spawn in the player_rig)
		3) call get_player_rig() or get_player_legs() to spawn them in and/or get a reference to them
###################################################*/

#using_animtree( "player" );
init_player_rig( player_rig_model, player_legs_model ) 
{
	if ( isdefined( player_rig_model ) )
		PreCacheModel( player_rig_model );

	if ( isdefined( player_legs_model ) )
		PreCacheModel( player_legs_model );
	
	if ( isdefined( player_rig_model ) )
	{
		level.scr_animtree[ "player_rig" ] 					 	= #animtree;
		level.scr_model[ "player_rig" ] 					 	= player_rig_model;
	}

	if ( isdefined( player_legs_model ) )	
	{
		level.scr_animtree[ "player_legs" ] 					= #animtree;
		level.scr_model[ "player_legs" ] 					 	= player_legs_model;
	}
}

get_player_rig()
{
	if ( !IsDefined( level.player_rig ) )
	{
		level.player_rig = spawn_anim_model( "player_rig" );
		level.player_rig.origin = level.player.origin;
		level.player_rig.angles = level.player.angles;
	}

	return level.player_rig;
}

get_player_legs()
{
	if ( !IsDefined( level.player_legs ) )
	{
		level.player_legs = spawn_anim_model( "player_legs" );
		level.player_legs.origin = level.player.origin;
		level.player_legs.angles = level.player.angles;
	}

	return level.player_legs;
}

link_player_to_arms( r, l, u, d )
{
	
	if ( !IsDefined( r ) )
		r = 30;
	if ( !IsDefined( l ) )
		l = 30;	
	if ( !IsDefined( u ) )
		u = 30;	
	if ( !IsDefined( d ) )
		d = 30;
			
	player_rig = get_player_rig();
	player_rig Show();
	level.player PlayerLinkToAbsolute( player_rig, "tag_player" );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, r, l, u, d, true );
}

blend_player_to_arms( time )
{
	if ( !IsDefined( time ) )
		time = 0.7;
	player_rig = get_player_rig();
	player_rig Show();
	level.player PlayerLinkToBlend( player_rig, "tag_player", time );
}