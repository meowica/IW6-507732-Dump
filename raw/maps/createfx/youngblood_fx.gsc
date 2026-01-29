//_createfx generated. Do not touch!!
#include common_scripts\utility;
#include common_scripts\_createfx;


main()
{
	// CreateFX fx entities placed: 246
	ent = createLoopEffect( "ygb_rod_impact_earth_a" );
	ent set_origin_and_angles( (-3845.96, -98356, -115195), (289.703, 283.378, 116.923) );
	ent.v[ "delay" ] = 22;

	ent = createLoopEffect( "ygb_rod_impact_earth_a" );
	ent set_origin_and_angles( (-8600.13, -102014, -115535), (300.017, 40.2329, 15.7299) );
	ent.v[ "delay" ] = 26;

	ent = createLoopEffect( "ygb_rod_impact_earth_a" );
	ent set_origin_and_angles( (-13156, -98442.4, -114677), (307.627, 25.2216, -59.7643) );
	ent.v[ "delay" ] = 24;

	ent = createOneshotEffect( "ygb_chaos_cloud_a" );
	ent set_origin_and_angles( (-788.472, -102216, -114306), (270, 0, 0) );

	ent = createExploderEx( "ygb_rod_impact_earth_a", "rod_impact_reveal_near" );
	ent set_origin_and_angles( (-3243.6, -101142, -115937), (294.673, 160.194, -104.649) );
	ent.v[ "soundalias" ] = "scn_yb_rod_impact_close";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-79.673, -102776, -114710), (270, 0, 0) );
	ent.v[ "delay" ] = 1.1;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-127.113, -102398, -114750), (270, 15.3955, -106.395) );
	ent.v[ "delay" ] = 1.1;
	ent.v[ "earthquake" ] = "small_long";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-145.793, -102162, -114759), (270, 0, 0) );
	ent.v[ "delay" ] = 1.75;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-449.45, -102859, -114709), (270, 0, 0) );
	ent.v[ "delay" ] = 1.1;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-31.3515, -101774, -114781), (270, 0, 0) );
	ent.v[ "delay" ] = 1.75;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (180.09, -101554, -114770), (270, 0, 0) );
	ent.v[ "delay" ] = 2.5;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-84.259, -101421, -114788), (270, 0, -1) );
	ent.v[ "delay" ] = 2.5;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-499.323, -102610, -114743), (270, 0, 0) );
	ent.v[ "delay" ] = 0.5;
	ent.v[ "earthquake" ] = "large_short";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-441.861, -102350, -114750), (277, 180, -75.0001) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_powerline_sparks_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-303.997, -101879, -114478), (270, 0, 0) );
	ent.v[ "delay" ] = 1;

	ent = createExploderEx( "ygb_powerline_sparks_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-380.057, -101070, -114471), (272.828, 315.024, -38.9895) );
	ent.v[ "delay" ] = 2.5;

	ent = createExploderEx( "ygb_chunk_fall_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-266.307, -102125, -114161), (290, 180, 180) );
	ent.v[ "delay" ] = 1.75;

	ent = createExploderEx( "ygb_chunk_fall_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-370.266, -101402, -114399), (290, 180, 180) );
	ent.v[ "delay" ] = 3;

	ent = createExploderEx( "No FX", "dust_ground_break_a" );
	ent set_origin_and_angles( (20.1422, -102580, -114704), (270, 0, 0) );
	ent.v[ "delay" ] = 0.3;
	ent.v[ "soundalias" ] = "scn_flood_mall_rumble_02";

	ent = createExploderEx( "No FX", "dust_ground_break_a" );
	ent set_origin_and_angles( (148.686, -102717, -114649), (270, 0, 0) );
	ent.v[ "soundalias" ] = "slowmo_bullet_whoosh";

	ent = createExploderEx( "No FX", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5699.34, -107435, -116006), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "scn_flood_debris_bridge_ceiling_debris_sm";

	ent = createExploderEx( "No FX", "deer_start" );
	ent set_origin_and_angles( (6232.36, -108635, -116283), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_short";

	ent = createExploderEx( "No FX", "mansion_int_rumble_a" );
	ent set_origin_and_angles( (355.908, -103098, -114674), (270, 0, 0) );
	ent.v[ "soundalias" ] = "elm_quake_sub_rumble";

	ent = createExploderEx( "No FX", "dust_ground_break_a" );
	ent set_origin_and_angles( (177.609, -102725, -114611), (270, 0, 0) );
	ent.v[ "delay" ] = 0.5;
	ent.v[ "soundalias" ] = "scn_flood_debris_bridge_ceiling_debris_sm";

	ent = createExploderEx( "No FX", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (5147.43, -106804, -115725), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "scn_flood_debris_bridge_ceiling_debris_sm";

	ent = createExploderEx( "No FX", "suburb_climb_a" );
	ent set_origin_and_angles( (4026.98, -106274, -115479), (270, 0, 0) );
	ent.v[ "earthquake" ] = "medium_medium";
	ent.v[ "soundalias" ] = "yb_stone_crack";

	ent = createExploderEx( "No FX", "suburb_climb_b" );
	ent set_origin_and_angles( (3252.47, -105315, -115334), (270, 0, 0) );
	ent.v[ "earthquake" ] = "medium_medium";
	ent.v[ "soundalias" ] = "yb_stone_crack";

	ent = createExploderEx( "No FX", "mansion_garden_a" );
	ent set_origin_and_angles( (773.205, -103955, -114807), (270, 0, 0) );
	ent.v[ "earthquake" ] = "medium_medium";
	ent.v[ "soundalias" ] = "yb_stone_crack";

	ent = createExploderEx( "ygb_earth_wall_fall_a", "cecotchunk_a" );
	ent set_origin_and_angles( (182.97, -101845, -114784), (352.758, 189.83, 2.09219) );

	ent = createExploderEx( "ygb_earth_wall_fall_a", "cecotchunk_a" );
	ent set_origin_and_angles( (156.738, -102167, -114785), (352.758, 189.83, 2.09219) );

	ent = createExploderEx( "ygb_earth_wall_fall_a", "cecotchunk_a" );
	ent set_origin_and_angles( (-57.8188, -101517, -114806), (353.83, 241.197, -4.33618) );

	ent = createExploderEx( "ygb_earth_wall_fall_a", "cecotchunk_a" );
	ent set_origin_and_angles( (142.133, -101587, -114801), (342.727, 221.443, -2.03323) );

	ent = createExploderEx( "ygb_water_pipe_gush_lg", "cecotchunk_a" );
	ent set_origin_and_angles( (-41.0073, -101517, -114825), (353.83, 241.197, -4.33618) );

	ent = createExploderEx( "ygb_water_pipe_gush_lg", "cecotchunk_a" );
	ent set_origin_and_angles( (192.187, -101751, -114827), (352.521, 198.903, 0.927653) );

	ent = createExploderEx( "ygb_crack_chunk_emitter_a", "suburb_climb_b" );
	ent set_origin_and_angles( (3455.78, -105397, -115368), (354.369, 150.762, -175.716) );

	ent = createExploderEx( "ygb_crack_chunk_emitter_a", "suburb_climb_b" );
	ent set_origin_and_angles( (3118.39, -105308, -115327), (357.024, 115.745, -172.688) );
	ent.v[ "delay" ] = 0.3;

	ent = createExploderEx( "ygb_crack_chunk_emitter_a", "suburb_climb_a" );
	ent set_origin_and_angles( (3837.69, -106306, -115463), (355.342, 113.496, -174.178) );

	ent = createExploderEx( "ygb_crack_chunk_emitter_a", "suburb_climb_a" );
	ent set_origin_and_angles( (4098.69, -106230, -115483), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5665.49, -107267, -115782), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5370.7, -107164, -115667), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (5055.72, -106796, -115467), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (4996.79, -106437, -115247), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (4732.1, -106681, -115290), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "No FX", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (5091.54, -106829, -115714), (270, 0, 0) );
	ent.v[ "soundalias" ] = "scn_yb_wind_gust_leafy";

	ent = createExploderEx( "No FX", "dust_ground_break_a" );
	ent set_origin_and_angles( (93.9404, -102615, -114689), (270, 0, 0) );
	ent.v[ "delay" ] = 0.8;
	ent.v[ "soundalias" ] = "scn_yb_rod_earthquake_lr";

	ent = createExploderEx( "No FX", "cecotchunk_a" );
	ent set_origin_and_angles( (222.455, -101788, -114750), (270, 0, 0) );
	ent.v[ "soundalias" ] = "scn_yb_rod_earthquake_lr";

	ent = createExploderEx( "No FX", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5765.95, -107369, -116021), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "bldg_long_rumble_debris";

	ent = createExploderEx( "No FX", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (5198.55, -106755, -115720), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "bldg_long_rumble_debris";

	ent = createExploderEx( "ygb_rod_impact_earth_a", "impact_b" );
	ent set_origin_and_angles( (-1993.53, -99841.6, -115580), (294.673, 160.194, -104.649) );
	ent.v[ "soundalias" ] = "scn_yb_rod_impact_far";

	ent = createExploderEx( "ygb_chunk_fall_a", "impact_b" );
	ent set_origin_and_angles( (-437.436, -100751, -114355), (290, 180, 180) );
	ent.v[ "delay" ] = 1.25;

	ent = createExploderEx( "ygb_chunk_fall_a", "impact_b" );
	ent set_origin_and_angles( (-505.655, -100023, -114230), (290, 180, 180) );
	ent.v[ "delay" ] = 1.25;

	ent = createExploderEx( "ygb_chunk_fall_a", "impact_b" );
	ent set_origin_and_angles( (50.406, -100149, -114261), (290, 180, 180) );
	ent.v[ "delay" ] = 1.25;

	ent = createExploderEx( "No FX", "impact_b" );
	ent set_origin_and_angles( (-267.051, -100865, -114786), (270, 0, 0) );
	ent.v[ "soundalias" ] = "slowmo_bullet_whoosh";

	ent = createExploderEx( "No FX", "impact_b" );
	ent set_origin_and_angles( (-319.604, -100727, -114815), (270, 0, 0) );
	ent.v[ "delay" ] = 0.8;
	ent.v[ "soundalias" ] = "scn_yb_rod_earthquake_lr";

	ent = createExploderEx( "No FX", "impact_b" );
	ent set_origin_and_angles( (-326.992, -100793, -114819), (270, 0, 0) );
	ent.v[ "delay" ] = 0.3;
	ent.v[ "soundalias" ] = "scn_flood_mall_rumble_02";

	ent = createExploderEx( "No FX", "impact_b" );
	ent set_origin_and_angles( (-352.197, -100645, -114832), (270, 0, 0) );
	ent.v[ "delay" ] = 0.5;
	ent.v[ "soundalias" ] = "scn_flood_debris_bridge_ceiling_debris_sm";

	ent = createExploderEx( "No FX", "impact_b" );
	ent set_origin_and_angles( (-36.9651, -101352, -114781), (270, 0, 0) );
	ent.v[ "delay" ] = 1.1;
	ent.v[ "earthquake" ] = "medium_medium";
	ent.v[ "soundalias" ] = "yb_stone_crack";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "impact_b" );
	ent set_origin_and_angles( (-1.95145, -101232, -114786), (270, 0, 0) );
	ent.v[ "delay" ] = 0.5;
	ent.v[ "earthquake" ] = "large_short";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "impact_b_move_a" );
	ent set_origin_and_angles( (-56.4655, -101015, -114780), (270, 0, 0) );
	ent.v[ "earthquake" ] = "medium_medium";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "impact_b_move_a" );
	ent set_origin_and_angles( (163.897, -100857, -114791), (270, 15.3955, -106.395) );
	ent.v[ "delay" ] = 0.2;
	ent.v[ "earthquake" ] = "small_long";

	ent = createExploderEx( "No FX", "impact_b_move_a" );
	ent set_origin_and_angles( (13.1453, -100959, -114800), (270, 0, 0) );
	ent.v[ "delay" ] = 0.8;
	ent.v[ "soundalias" ] = "scn_yb_rod_earthquake_lr";

	ent = createExploderEx( "No FX", "impact_b_move_a" );
	ent set_origin_and_angles( (-17.9946, -100958, -114801), (270, 0, 0) );
	ent.v[ "delay" ] = 0.1;
	ent.v[ "soundalias" ] = "scn_flood_mall_rumble_02";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "impact_b_move_a" );
	ent set_origin_and_angles( (329.052, -100535, -114776), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "impact_b_move_a" );
	ent set_origin_and_angles( (-261.053, -100885, -114801), (270, 0, 0) );

	ent = createExploderEx( "No FX", "impact_b_move_a" );
	ent set_origin_and_angles( (-110.407, -101013, -114802), (270, 0, 0) );
	ent.v[ "delay" ] = 0.2;
	ent.v[ "soundalias" ] = "yb_metal_groan_verb_05";

	ent = createExploderEx( "No FX", "impact_b_move_b" );
	ent set_origin_and_angles( (-64.3412, -100148, -114856), (270, 0, 0) );
	ent.v[ "delay" ] = 0.2;
	ent.v[ "soundalias" ] = "yb_building_shake_01";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "impact_b_move_b" );
	ent set_origin_and_angles( (-90.3533, -100114, -114929), (270, 0, 0) );
	ent.v[ "earthquake" ] = "medium_medium";

	ent = createExploderEx( "No FX", "impact_b_move_b" );
	ent set_origin_and_angles( (-116.534, -100038, -114948), (270, 0, 0) );
	ent.v[ "delay" ] = 0.8;
	ent.v[ "soundalias" ] = "scn_yb_rod_earthquake_lr";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "impact_b_move_b" );
	ent set_origin_and_angles( (-314.86, -99870.4, -115078), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_long";

	ent = createExploderEx( "No FX", "suburb_driveby_a" );
	ent set_origin_and_angles( (2979.3, -105150, -115287), (270, 0, 0) );
	ent.v[ "soundalias" ] = "yb_tire_skid_cement_long1";

	ent = createExploderEx( "No FX", "suburb_driveby_a" );
	ent set_origin_and_angles( (3566.34, -105752, -115387), (270, 0, 0) );
	ent.v[ "delay" ] = 0.8;
	ent.v[ "soundalias" ] = "yb_pars_volk_peel_out_r";

	ent = createExploderEx( "No FX", "suburb_driveby_a" );
	ent set_origin_and_angles( (3777.01, -106032, -115441), (270, 0, 0) );
	ent.v[ "delay" ] = 1.5;
	ent.v[ "soundalias" ] = "yb_chase_pileup_01";

	ent = createExploderEx( "No FX", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-1648.61, -101843, -114920), (270, 0, 0) );
	ent.v[ "loopsound" ] = "yb_emt_gulag_bombardment";

	ent = createExploderEx( "No FX", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-1709.84, -101717, -114921), (270, 0, 0) );
	ent.v[ "loopsound" ] = "yb_emt_siren_airraid";

	ent = createExploderEx( "No FX", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (177.519, -102773, -114633), (270, 0, 0) );
	ent.v[ "soundalias" ] = "slowmo_bullet_whoosh";

	ent = createExploderEx( "ygb_ground_move_dust_a", "impact_b_move_b" );
	ent set_origin_and_angles( (-602.505, -100081, -115162), (7.76049, 194.132, -178.053) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "impact_b" );
	ent set_origin_and_angles( (-513.539, -100481, -115113), (7.76049, 194.132, -178.053) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "impact_b_move_b" );
	ent set_origin_and_angles( (12.714, -99777.8, -115019), (19.6392, 197.665, -177.579) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "impact_b_move_b" );
	ent set_origin_and_angles( (-211.312, -100154, -115087), (20.7526, 194.6, -177.937) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "impact_b" );
	ent set_origin_and_angles( (-796.756, -99463, -115123), (19.6392, 197.665, -177.579) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "impact_b" );
	ent set_origin_and_angles( (129.899, -100551, -114848), (36.7406, 195.31, -177.592) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-14906, -94424, -101344), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-13697.8, -89467.6, -102962), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-26774.2, -82496.3, -102262), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-34655.9, -92925, -99145), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-16865.2, -119287, -99457.5), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-14074.2, -107078, -103922), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-24334, -100989, -103971), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-17411.5, -111270, -101836), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-26949.1, -104970, -97437.3), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-17364.5, -75549, -102061), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-25939, -74114.2, -101816), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-21342.1, -64361, -98915.9), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-13485.2, -54984.5, -98564.9), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (-6601.36, -82854.9, -106218), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (4667.65, -85037, -107335), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (2416.59, -76856.8, -105461), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_rog_bak_mover_a", "mansion_door_reveal_a" );
	ent set_origin_and_angles( (10170.6, -90158.1, -104724), (296, 0, 6.99993) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-168.297, -102554, -114810), (19.6392, 197.665, -177.579) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "cecotchunk_a" );
	ent set_origin_and_angles( (-64.0633, -101532, -114840), (19.6392, 197.665, -177.579) );

	ent = createExploderEx( "ygb_ground_move_dust_a", "cecotchunk_a" );
	ent set_origin_and_angles( (38.4072, -102025, -114825), (19.6392, 197.665, -177.579) );

	ent = createExploderEx( "No FX", "impact_b" );
	ent set_origin_and_angles( (-111.977, -100209, -114930), (270, 0, 0) );
	ent.v[ "delay" ] = 5.5;
	ent.v[ "soundalias" ] = "scn_flood_debris_bridge_ceiling_debris_sm";

	ent = createExploderEx( "No FX", "dust_ground_break_a" );
	ent set_origin_and_angles( (-3.68619, -101549, -114837), (270, 0, 0) );
	ent.v[ "delay" ] = 5.4;
	ent.v[ "loopsound" ] = "yb_veh_caralarm_02loop_22k";

	ent = createExploderEx( "No FX", "dust_ground_break_a" );
	ent set_origin_and_angles( (-23.7087, -101546, -114854), (270, 0, 0) );
	ent.v[ "delay" ] = 5.6;
	ent.v[ "soundalias" ] = "yb_chase_roadblock_smash";

	ent = createExploderEx( "ygb_birds_start_panicked", "deer_rumble_a" );
	ent set_origin_and_angles( (6394.78, -108790, -116330), (7.76005, 291.338, 1.06095) );
	ent.v[ "delay" ] = 1.75;
	ent.v[ "soundalias" ] = "yb_seagull_flock_01";

	ent = createExploderEx( "No FX", "deer_rumble_a" );
	ent set_origin_and_angles( (6188.71, -108687, -116279), (270, 0, 0) );
	ent.v[ "delay" ] = 1.5;
	ent.v[ "earthquake" ] = "small_med";

	ent = createExploderEx( "No FX", "deer_rumble_a" );
	ent set_origin_and_angles( (6313.23, -108587, -116271), (270, 0, 0) );
	ent.v[ "delay" ] = 1.5;
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "bldg_long_rumble_debris";

	ent = createExploderEx( "No FX", "deer_rumble_a" );
	ent set_origin_and_angles( (6241.63, -108631, -116259), (51.1662, 73.9661, 4.79371) );
	ent.v[ "delay" ] = 1.5;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (6026.45, -108104, -116263), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (5874.8, -108379, -116326), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (5768.3, -108136, -116161), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (6333.46, -107989, -116224), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (6195.64, -107906, -116185), (270, 0, 0) );

	ent = createExploderEx( "No FX", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (6053.86, -108302, -116309), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "yb_elm_quake_sub_rumble_loud";

	ent = createExploderEx( "No FX", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (6056.28, -108342, -116310), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "bldg_long_rumble_debris";

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (5841.49, -107997, -115853), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (6233.02, -108197, -116000), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "ygb_tree_shake_leaf_fall_a", "deer_hut_tremor_a" );
	ent set_origin_and_angles( (6296.9, -107586, -115926), (353.8, 152.632, -179.098) );

	ent = createExploderEx( "No FX", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5548.94, -107228, -115882), (270, 0, 0) );
	ent.v[ "delay" ] = 0.6;
	ent.v[ "soundalias" ] = "yb_contingency_tree_fall_01";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5283.79, -107405, -115914), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5630.32, -107005, -115899), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5788.6, -107428, -116017), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5593.04, -107271, -115987), (270, 0, 0) );
	ent.v[ "delay" ] = 1.5;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (5139.11, -106654, -115587), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (5034.39, -106867, -115639), (270, 0, 0) );

	ent = createExploderEx( "ygb_wind_light_a", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (5462.87, -106756, -115740), (24.6802, 294.309, -2.97037) );

	ent = createExploderEx( "ygb_wind_light_a", "deer_hill_tremor_a" );
	ent set_origin_and_angles( (4783.41, -107213, -115746), (23.3243, 322.782, -1.18492) );

	ent = createExploderEx( "ygb_wind_light_a", "deer_hill_tremor_b" );
	ent set_origin_and_angles( (4350.13, -106365, -115481), (13.3708, 333.586, -2.21157) );

	ent = createExploderEx( "ygb_birds_flee_cloud_a", "suburb_climb_a" );
	ent set_origin_and_angles( (431.899, -103334, -113825), (275, 0, 117) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_stampede_a" );
	ent set_origin_and_angles( (5506.2, -106832, -115804), (270, 0, 0) );
	ent.v[ "delay" ] = 1.2;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_stampede_a" );
	ent set_origin_and_angles( (5606.97, -106683, -115758), (270, 0, 0) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_stampede_a" );
	ent set_origin_and_angles( (4969.83, -107342, -115833), (270, 0, 0) );
	ent.v[ "delay" ] = 3.5;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_stampede_a" );
	ent set_origin_and_angles( (5273.59, -107083, -115790), (270, 0, 0) );
	ent.v[ "delay" ] = 2;

	ent = createExploderEx( "No FX", "deer_stampede_a" );
	ent set_origin_and_angles( (5546.71, -106850, -115831), (270, 0, 0) );
	ent.v[ "earthquake" ] = "small_med";
	ent.v[ "soundalias" ] = "bldg_long_rumble_debris";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "deer_stampede_a" );
	ent set_origin_and_angles( (5531.42, -106718, -115781), (270, 0, 0) );
	ent.v[ "delay" ] = 0.8;

	ent = createExploderEx( "No FX", "mansion_ext_a" );
	ent set_origin_and_angles( (1279.66, -104237, -114832), (270, 0, 0) );
	ent.v[ "earthquake" ] = "medium_medium";
	ent.v[ "soundalias" ] = "yb_stone_crack";

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "mansion_ext_a" );
	ent set_origin_and_angles( (1159.52, -104220, -114758), (275, 0, 171) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "mansion_ext_a" );
	ent set_origin_and_angles( (1238.33, -104187, -114756), (275, 0, 171) );

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "mansion_ext_a" );
	ent set_origin_and_angles( (1304.38, -104137, -114772), (275, 0, 171) );

	ent = createExploderEx( "No FX", "mansion_garden_a" );
	ent set_origin_and_angles( (758.873, -103798, -114720), (270, 0, 0) );
	ent.v[ "delay" ] = 0.5;
	ent.v[ "soundalias" ] = "yb_elm_flood_debris_splash_03";

	ent = createExploderEx( "No FX", "mansion_garden_a" );
	ent set_origin_and_angles( (781.735, -103852, -114751), (270, 0, 0) );
	ent.v[ "delay" ] = 5.5;
	ent.v[ "soundalias" ] = "yb_uw_pov_splash_04";

	ent = createExploderEx( "No FX", "mansion_garden_a" );
	ent set_origin_and_angles( (931.753, -103704, -114735), (270, 0, 0) );
	ent.v[ "delay" ] = 0.5;
	ent.v[ "soundalias" ] = "yb_shg_harb_boat_slowmo_splash";

	ent = createExploderEx( "No FX", "mansion_garden_a" );
	ent set_origin_and_angles( (940.324, -103754, -114753), (270, 0, 0) );
	ent.v[ "delay" ] = 0.85;
	ent.v[ "soundalias" ] = "yb_water_splash_lrg_02";

	ent = createExploderEx( "No FX", "mansion_garden_a" );
	ent set_origin_and_angles( (935.837, -103740, -114742), (270, 0, 0) );
	ent.v[ "delay" ] = 2.5;
	ent.v[ "soundalias" ] = "yb_water_fountain_splash_05";

	ent = createExploderEx( "No FX", "mansion_ext_a" );
	ent set_origin_and_angles( (1261.59, -104260, -114790), (270, 0, 0) );
	ent.v[ "delay" ] = 0.5;
	ent.v[ "soundalias" ] = "scn_flood_mall_rumble_02";

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (1005.08, -103551, -114774), (272.007, 232.961, -116.662) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (1070.51, -103669, -114775), (272.007, 232.961, -116.662) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (1196.47, -103874, -114784), (272.007, 232.961, -116.662) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (787.302, -103728, -114774), (272.007, 232.961, -116.662) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (831.681, -103507, -114783), (272.007, 232.959, -32.6605) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (831.623, -103861, -114777), (272.007, 232.961, -116.662) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (921.958, -104013, -114773), (272.007, 232.961, -116.662) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (1027.72, -104079, -114782), (272.007, 232.962, 120.337) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_pool_splash_a", "mansion_garden_a" );
	ent set_origin_and_angles( (1143.37, -104004, -114781), (272.007, 232.963, -170.664) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_bubbles_pool_crack_a", "mansion_garden_a" );
	ent set_origin_and_angles( (965.053, -103540, -114810), (358.055, 53.2837, -85.8356) );

	ent = createExploderEx( "ygb_bubbles_pool_crack_a", "mansion_garden_a" );
	ent set_origin_and_angles( (901.568, -103656, -114811), (357.458, 86.2813, -87.6317) );

	ent = createExploderEx( "ygb_bubbles_pool_crack_b", "mansion_garden_a" );
	ent set_origin_and_angles( (950.202, -103843, -114838), (350.188, 103.828, -85.4725) );

	ent = createExploderEx( "ygb_bubbles_pool_crack_b", "mansion_garden_a" );
	ent set_origin_and_angles( (943.581, -103981, -114869), (357.431, 86.2777, -87.9429) );

	ent = createExploderEx( "No FX", "family_a1" );
	ent set_origin_and_angles( (3979.15, -106400, -115476), (270, 0, 0) );
	ent.v[ "soundalias" ] = "youngblood_kid1_mommymommyhelp";

	ent = createExploderEx( "No FX", "family_a1" );
	ent set_origin_and_angles( (3964.75, -106410, -115475), (270, 0, 0) );
	ent.v[ "delay" ] = 3.1;
	ent.v[ "soundalias" ] = "youngblood_mom1_christinewhereareyou";

	ent = createExploderEx( "No FX", "family_a1" );
	ent set_origin_and_angles( (3949.06, -106420, -115474), (270, 0, 0) );
	ent.v[ "delay" ] = 5.2;
	ent.v[ "soundalias" ] = "youngblood_kid1_imhereimhere";

	ent = createExploderEx( "No FX", "family_a2" );
	ent set_origin_and_angles( (3891.43, -106479, -115471), (270, 0, 0) );
	ent.v[ "soundalias" ] = "youngblood_mom1_stayinthecar";

	ent = createExploderEx( "No FX", "family_a2" );
	ent set_origin_and_angles( (3862.18, -106485, -115468), (270, 0, 0) );
	ent.v[ "delay" ] = 2.6;
	ent.v[ "soundalias" ] = "youngblood_dad1_wecantcarryanymore";

	ent = createExploderEx( "No FX", "family_a2" );
	ent set_origin_and_angles( (3855.24, -106502, -115463), (270, 0, 0) );
	ent.v[ "delay" ] = 4.5;
	ent.v[ "soundalias" ] = "youngblood_mom1_butthedog";

	ent = createExploderEx( "No FX", "family_a2" );
	ent set_origin_and_angles( (3835.39, -106506, -115461), (270, 0, 0) );
	ent.v[ "delay" ] = 5.2;
	ent.v[ "soundalias" ] = "youngblood_dad1_getinthecar";

	ent = createExploderEx( "No FX", "family_a2" );
	ent set_origin_and_angles( (3802.77, -106513, -115459), (270, 0, 0) );
	ent.v[ "delay" ] = 6.2;
	ent.v[ "soundalias" ] = "youngblood_kid1_dadwhataboutchloe";

	ent = createExploderEx( "No FX", "family_b1" );
	ent set_origin_and_angles( (3964.42, -105552, -115332), (270, 0, 0) );
	ent.v[ "soundalias" ] = "youngblood_kid2_idontwantto";

	ent = createExploderEx( "No FX", "family_b1" );
	ent set_origin_and_angles( (3955.77, -105521, -115338), (270, 0, 0) );
	ent.v[ "delay" ] = 2.8;
	ent.v[ "soundalias" ] = "youngblood_dad2_dannygetyourass";

	ent = createExploderEx( "No FX", "family_b1" );
	ent set_origin_and_angles( (3937.41, -105506, -115336), (270, 0, 0) );
	ent.v[ "delay" ] = 4.4;
	ent.v[ "soundalias" ] = "youngblood_mom2_iforgotthefood";

	ent = createExploderEx( "No FX", "family_b1" );
	ent set_origin_and_angles( (3924.77, -105480, -115338), (270, 0, 0) );
	ent.v[ "delay" ] = 6.3;
	ent.v[ "soundalias" ] = "youngblood_dad2_marnimarni";

	ent = createExploderEx( "No FX", "family_c1" );
	ent set_origin_and_angles( (3420.9, -105589, -115386), (270, 0, 0) );
	ent.v[ "soundalias" ] = "youngblood_dad3_goteverything";

	ent = createExploderEx( "No FX", "family_c1" );
	ent set_origin_and_angles( (3411.02, -105600, -115385), (270, 0, 0) );
	ent.v[ "delay" ] = 0.9;
	ent.v[ "soundalias" ] = "youngblood_mom3_thisisthelast";

	ent = createExploderEx( "No FX", "family_c1" );
	ent set_origin_and_angles( (3395.2, -105605, -115384), (270, 0, 0) );
	ent.v[ "delay" ] = 2.8;
	ent.v[ "soundalias" ] = "youngblood_dad3_watchoutasshole";

	ent = createExploderEx( "No FX", "family_c1" );
	ent set_origin_and_angles( (3374.53, -105610, -115384), (270, 0, 0) );
	ent.v[ "delay" ] = 3.6;
	ent.v[ "soundalias" ] = "youngblood_mom3_johnletsjustgo";

	ent = createExploderEx( "No FX", "family_c1" );
	ent set_origin_and_angles( (3342.9, -105606, -115381), (270, 0, 0) );
	ent.v[ "delay" ] = 5.6;
	ent.v[ "soundalias" ] = "youngblood_dad3_screwthis";

	ent = createExploderEx( "No FX", "family_d1" );
	ent set_origin_and_angles( (3172.85, -104857, -115272), (270, 0, 0) );
	ent.v[ "soundalias" ] = "youngblood_bf1_babejusttakeme";

	ent = createExploderEx( "No FX", "family_d1" );
	ent set_origin_and_angles( (3159.01, -104836, -115274), (270, 0, 0) );
	ent.v[ "delay" ] = 3;
	ent.v[ "soundalias" ] = "youngblood_gf1_wehavetogo";

	ent = createExploderEx( "No FX", "family_d1" );
	ent set_origin_and_angles( (3147.82, -104820, -115271), (270, 0, 0) );
	ent.v[ "delay" ] = 4.6;
	ent.v[ "soundalias" ] = "youngblood_bf1_ineedtoget";

	ent = createExploderEx( "No FX", "family_d1" );
	ent set_origin_and_angles( (3135.5, -104817, -115266), (270, 0, 0) );
	ent.v[ "delay" ] = 5.7;
	ent.v[ "soundalias" ] = "youngblood_gf1_illgetyouto";

	ent = createExploderEx( "No FX", "family_e1" );
	ent set_origin_and_angles( (2618.57, -104783, -115296), (270, 0, 0) );
	ent.v[ "soundalias" ] = "youngblood_mom4_letsgowhatsthe";

	ent = createExploderEx( "No FX", "family_e1" );
	ent set_origin_and_angles( (2627.6, -104772, -115288), (270, 0, 0) );
	ent.v[ "delay" ] = 1.8;
	ent.v[ "soundalias" ] = "youngblood_dad4_idontknowwhat";

	ent = createExploderEx( "No FX", "family_b1" );
	ent set_origin_and_angles( (4047.55, -105261, -115276), (270, 0, 0) );
	ent.v[ "delay" ] = 6;
	ent.v[ "soundalias" ] = "yb_glass_smash_distant_01";

	ent = createExploderEx( "ygb_ground_move_dust_a", "impact_c" );
	ent set_origin_and_angles( (-1075.72, -98756.2, -115170), (19.6392, 197.665, -177.579) );

	ent = createExploderEx( "ygb_wood_explosion_a", "basement_exit_a" );
	ent set_origin_and_angles( (-2343.27, -96277.2, -114644), (280.274, 125.575, -145.425) );
	ent.v[ "delay" ] = 2.2;
	ent.v[ "earthquake" ] = "large_short";

	ent = createExploderEx( "ygb_wood_explosion_a", "basement_exit_a" );
	ent set_origin_and_angles( (-2235.09, -96382.4, -114667), (273.114, 342.521, 12.2867) );
	ent.v[ "delay" ] = 2.4;

	ent = createExploderEx( "ygb_wood_explosion_a", "basement_exit_a" );
	ent set_origin_and_angles( (-2093.51, -96456.2, -114633), (278.671, 229.651, 132.546) );
	ent.v[ "delay" ] = 2.6;
	ent.v[ "earthquake" ] = "medium_medium";

	ent = createExploderEx( "ygb_fireball_explosion", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3084.28, -96109.9, -114451), (280.274, 125.576, -116.426) );
	ent.v[ "delay" ] = 3;
	ent.v[ "earthquake" ] = "large_short";

	ent = createExploderEx( "ygb_fireball_explosion", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2833.92, -96120, -114513), (280.274, 125.576, 144.574) );
	ent.v[ "delay" ] = 3.2;

	ent = createExploderEx( "ygb_cliff_fall_a", "impact_c" );
	ent set_origin_and_angles( (-511.227, -98383, -115028), (346.686, 295.3, -0.71266) );

	ent = createExploderEx( "ygb_cliff_fall_a_long", "impact_c" );
	ent set_origin_and_angles( (-829.038, -98392.4, -115052), (2.09956, 226.391, -1.27152) );

	ent = createExploderEx( "ygb_cliff_fall_a", "impact_b" );
	ent set_origin_and_angles( (186.077, -100281, -114847), (3.15865, 201.288, -3.37578) );

	ent = createExploderEx( "ygb_cliff_fall_a", "impact_b_move_b" );
	ent set_origin_and_angles( (-6.65522, -99109.9, -114989), (351.958, 220.65, -1.49792) );

	ent = createExploderEx( "ygb_cliff_fall_a", "impact_b_move_b" );
	ent set_origin_and_angles( (139.435, -99282.6, -115030), (351.958, 220.65, -1.49792) );

	ent = createExploderEx( "ygb_cliff_fall_a_long", "impact_c" );
	ent set_origin_and_angles( (-934.75, -98247.3, -115036), (2.09956, 226.391, -1.27152) );

	ent = createExploderEx( "ygb_cliff_fall_a_long", "impact_c" );
	ent set_origin_and_angles( (-297.453, -98230.7, -115014), (345.778, 300.958, 1.75269) );

	ent = createExploderEx( "ygb_cliff_fall_a_long", "impact_c" );
	ent set_origin_and_angles( (-772.547, -98492, -115204), (2.42292, 248.406, -0.392063) );

	ent = createExploderEx( "ygb_ground_move_dust_b_lite", "basement_exit_a" );
	ent set_origin_and_angles( (-2355.02, -96684, -114681), (10.7675, 252.041, 166.401) );
	ent.v[ "delay" ] = 2.8;

	ent = createExploderEx( "ygb_ground_move_dust_b_lite", "basement_exit_a" );
	ent set_origin_and_angles( (-2781.09, -96476.6, -114626), (10.7675, 252.041, 166.401) );
	ent.v[ "delay" ] = 2.8;

	ent = createExploderEx( "ygb_ground_move_dust_b_lite", "basement_exit_a" );
	ent set_origin_and_angles( (-2342.63, -96219.5, -114613), (10.7675, 252.041, 166.401) );
	ent.v[ "delay" ] = 2.8;

	ent = createExploderEx( "ygb_wood_explosion_a", "vehicle_fall_a" );
	ent set_origin_and_angles( (-4143.05, -96342.7, -114048), (277.01, 280.155, -179.489) );
	ent.v[ "delay" ] = 2;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2767.46, -96158, -114590), (284.77, 150.922, -141.207) );
	ent.v[ "delay" ] = 3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3029.56, -96748.1, -114621), (298.633, 332.618, -3.66089) );
	ent.v[ "delay" ] = 3.2;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2753.39, -96812.7, -114704), (279.617, 313.667, 7.96742) );
	ent.v[ "delay" ] = 3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2540.33, -96610, -114706), (277.858, 294.893, 31.0683) );
	ent.v[ "delay" ] = 3.3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3228.96, -96075.5, -114497), (272.288, 318.832, 50.8488) );
	ent.v[ "delay" ] = 3.2;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2976.5, -96012.8, -114498), (280.274, 125.576, -116.426) );
	ent.v[ "delay" ] = 3.1;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3264.91, -96565.5, -114526), (276.404, 328.739, 2.57725) );
	ent.v[ "delay" ] = 3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3093.76, -96263.4, -114539), (282.582, 300.393, 33.4703) );
	ent.v[ "delay" ] = 3.2;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3324.74, -95950, -114489), (272.288, 318.832, 50.8488) );
	ent.v[ "delay" ] = 3.2;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3254.73, -95828.9, -114476), (272.288, 318.832, 50.8488) );
	ent.v[ "delay" ] = 3.2;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3496.37, -96001.1, -114493), (272.038, 27.0008, -55.6255) );
	ent.v[ "delay" ] = 3.2;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2624.43, -96303.1, -114666), (284.114, 274.702, 139.781) );
	ent.v[ "delay" ] = 3.3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2859.16, -96393.8, -114628), (280.274, 125.575, -100.425) );
	ent.v[ "delay" ] = 3.3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-2524.48, -96018.6, -114555), (280.274, 125.576, -116.426) );
	ent.v[ "delay" ] = 3.3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3208.61, -96767, -114559), (276.404, 328.74, 1.57719) );
	ent.v[ "delay" ] = 3;

	ent = createExploderEx( "vfx_fire_grounded_xtralarge_nxglight", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3451.43, -96374.3, -114505), (270.491, 295.486, 35.8156) );
	ent.v[ "delay" ] = 3;

	ent = createExploderEx( "ygb_fireball_explosion", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3323.65, -96372.6, -114513), (279.902, 120.273, -109.205) );
	ent.v[ "delay" ] = 3.3;

	ent = createExploderEx( "ygb_chaos_cloud_b_sml", "vehicle_fall_a" );
	ent set_origin_and_angles( (-3806.7, -96456.5, -114499), (272.288, 318.832, 50.8488) );
	ent.v[ "delay" ] = 2.5;

	ent = createExploderEx( "light_beam_glow_wide_underwater", "rescue_a" );
	ent set_origin_and_angles( (-4640.73, -95734.6, -114323), (15.1974, 310.934, -3.40532) );

	ent = createExploderEx( "light_beam_glow_wide_underwater", "rescue_a" );
	ent set_origin_and_angles( (-4594.45, -95710, -114325), (15.1974, 310.934, -3.40532) );

	ent = createExploderEx( "ygb_debris_basement_a", "basement_slide" );
	ent set_origin_and_angles( (-1627.75, -97931.8, -114954), (274.242, 135.039, -94.9605) );
	ent.v[ "delay" ] = 1;

	ent = createExploderEx( "ygb_debris_basement_a", "basement_slide" );
	ent set_origin_and_angles( (-1556.44, -97804.6, -114966), (270, 359.221, 38.7794) );
	ent.v[ "delay" ] = 1.2;

	ent = createExploderEx( "ygb_dust_basement_a", "basement_slide" );
	ent set_origin_and_angles( (-1633.3, -97836.6, -114955), (290.581, 319.792, 87.0818) );

	ent = createExploderEx( "ygb_debris_basement_a", "basement_slide" );
	ent set_origin_and_angles( (-1406.51, -97936.6, -115043), (270, 359.221, 38.7794) );
	ent.v[ "delay" ] = 0.25;

	ent = createExploderEx( "ygb_debris_basement_a", "basement_slide" );
	ent set_origin_and_angles( (-1620.39, -97971.8, -115013), (273, 308.005, 125.995) );
	ent.v[ "delay" ] = 0.4;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "impact_b" );
	ent set_origin_and_angles( (230.855, -101056, -114764), (277.448, 190.793, -49.384) );

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "impact_b" );
	ent set_origin_and_angles( (-358.107, -99694.8, -114481), (275.02, 125.757, 60.3554) );
	ent.v[ "delay" ] = 4.5;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "impact_b" );
	ent set_origin_and_angles( (-343.034, -100293, -114761), (275.02, 125.757, 60.3554) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-594.36, -102758, -114668), (286.504, 306.987, -175.601) );

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-166.166, -101864, -114765), (282.219, 349.397, 177.717) );
	ent.v[ "delay" ] = 0.8;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-473.572, -102168, -114632), (276.185, 329.827, -177.63) );
	ent.v[ "delay" ] = 2.5;

	ent = createExploderEx( "mall_rooftop_collapse_dust_medium", "dust_ground_break_a" );
	ent set_origin_and_angles( (-325.703, -101864, -114725), (277, 180, -17.0004) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (-736.854, -100996, -114589), (289.181, 331.449, -179.223) );
	ent.v[ "delay" ] = 1.5;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "dust_ground_break_a" );
	ent set_origin_and_angles( (318.054, -101299, -114697), (275.232, 352.449, 174.695) );
	ent.v[ "delay" ] = 1;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_b", "impact_b" );
	ent set_origin_and_angles( (404.031, -101453, -114426), (293.04, 19.4787, -171.631) );
	ent.v[ "delay" ] = 1;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_b", "impact_b" );
	ent set_origin_and_angles( (295.168, -100456, -114419), (282.907, 332.313, -121.607) );
	ent.v[ "delay" ] = 1.4;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "basement_exit_a" );
	ent set_origin_and_angles( (-2615.57, -97281.8, -114865), (295.596, 11.7579, -167.109) );

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "basement_exit_a" );
	ent set_origin_and_angles( (-3437.67, -97275.1, -114486), (280.602, 322.619, -79.4681) );

	ent = createExploderEx( "ygb_debris_earth_chunk_med_b", "impact_b_move_b" );
	ent set_origin_and_angles( (-595.9, -99540.4, -114993), (283.258, 11.3036, -171.979) );
	ent.v[ "delay" ] = 0.5;

	ent = createExploderEx( "ygb_wood_explosion_a", "roof_collapse" );
	ent set_origin_and_angles( (-795.55, -98704.2, -115237), (324.08, 208.209, 80.546) );

	ent = createExploderEx( "ygb_wood_explosion_a", "roof_collapse" );
	ent set_origin_and_angles( (-1254.42, -98683.7, -115210), (348.619, 61.3044, 22.4181) );
	ent.v[ "earthquake" ] = "large_short";

	ent = createExploderEx( "ygb_debris_earth_chunk_med_b", "impact_c" );
	ent set_origin_and_angles( (-830.23, -98223.5, -114796), (283.258, 11.3036, -171.979) );
	ent.v[ "delay" ] = 0.4;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "impact_c" );
	ent set_origin_and_angles( (-749.738, -98343.1, -115037), (283.258, 11.3036, -171.979) );
	ent.v[ "delay" ] = 0.3;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_b", "impact_c" );
	ent set_origin_and_angles( (-672.302, -98151, -114781), (283.258, 11.3036, -171.979) );
	ent.v[ "delay" ] = 0.7;

	ent = createExploderEx( "ygb_debris_earth_chunk_med_a", "impact_c" );
	ent set_origin_and_angles( (-856.224, -98367.1, -115098), (283.258, 11.3036, -171.979) );

	ent = createExploderEx( "ygb_debris_earth_chunk_med_b", "impact_c" );
	ent set_origin_and_angles( (-782.606, -98270, -114958), (283.258, 11.3036, -171.979) );
	ent.v[ "delay" ] = 0.8;

}
 
