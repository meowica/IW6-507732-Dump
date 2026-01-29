// Roughly man-sized sphinx statue, with a few pieces that can be shot off.
#include common_scripts\_destructible;

main()
{
	destructible_create( "toy_statue_sphinx_small", "tag_origin", 1000, undefined, undefined, "splash" );
	sphinx_part_setup( "beard" );
	sphinx_part_setup( "forehead" );
	sphinx_part_setup( "head_l" );
	sphinx_part_setup( "leg_fl" );
	sphinx_part_setup( "leg_fr" );
	sphinx_part_setup( "leg_rl" );
	sphinx_part_setup( "leg_rr" );
}

sphinx_part_setup( part_substring )
{
	destructible_part( "tag_"+part_substring, "statue_sphinx_small_dest_"+part_substring, 30 );
	destructible_physics( "tag_"+part_substring, (20,0,0) );
	destructible_fx( "tag_"+part_substring, "fx/props/statue_sphinx_small_impact" );
	destructible_sound( "dst_sphinx_statue" );
	destructible_state();
}