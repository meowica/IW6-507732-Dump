

main()
{
	humans();
	dogs();
}

#using_animtree( "generic_human" );
humans()
{
	// STEALTH
	level.scr_anim[ "generic" ][ "_stealth_patrol_walk_gundown" ]				= %creepwalk_f;

	//level.scr_anim[ "generic" ][ "_stealth_look_around_gundown" ][ 0 ]			= %patrol_bored_gundown_alerted_1;
	//level.scr_anim[ "generic" ][ "_stealth_look_around_gundown" ][ 1 ]			= %patrol_bored_gundown_alerted_2;
	
	// PATROL
	level.scr_anim[ "generic" ][ "patrol_walk_creepwalk" ][0]						= %creepwalk_f;
	level.scr_anim[ "generic" ][ "patrol_walk_creepwalk" ][1]						= %creepwalk_twitch_a_1;
	level.scr_anim[ "generic" ][ "patrol_walk_creepwalk" ][2]						= %creepwalk_twitch_a_2;
	level.scr_anim[ "generic" ][ "patrol_walk_creepwalk" ][3]						= %creepwalk_twitch_a_3;
	level.scr_anim[ "generic" ][ "patrol_walk_creepwalk" ][4]						= %creepwalk_twitch_a_4;

	level.scr_anim[ "generic" ][ "patrol_idle_creepwalk" ][0]						= %readystand_idle;
	
	weights = [ 4, 1, 1, 1, 1 ];
	level.scr_anim[ "generic" ][ "patrol_walk_weights_creepwalk" ] = common_scripts\utility::get_cumulative_weights( weights );

	level.scr_anim[ "generic" ][ "patrol_stop_creepwalk" ]						= %creepwalk_2_readystand;
	level.scr_anim[ "generic" ][ "patrol_start_creepwalk" ]						= %readystand_2_creepwalk;
}

#using_animtree( "dog" );
dogs()
{
}

enable_creepwalk()
{
	self.script_animation = "creepwalk";
	if ( isdefined( self.script_patroller ) && self.script_patroller )
		self maps\_patrol::set_patrol_run_anim_array();
}