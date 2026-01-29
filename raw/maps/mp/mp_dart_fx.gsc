main()
{
	level._effect[ "vfx_sunflare" ] = loadfx( "vfx/ambient/atmospheric/vfx_sunflare" );
	level._effect[ "vfx_fire_car_large_mp" ] = loadfx( "vfx/ambient/fire/fuel/vfx_fire_car_large_mp" );
	level._effect[ "vfx_bird" ] = loadfx( "vfx/ambient/animals/vfx_bird" );
	level._effect[ "electrical_sparks_20_flir_nooffset" ] = loadfx( "vfx/ambient/sparks/electrical_sparks_20_flir_nooffset" );
	level._effect[ "vfx_sand_ceiling_stream" ] = loadfx( "vfx/ambient/weather/sand/vfx_sand_ceiling_stream" );
	level._effect[ "vfx_gas_pump_exp" ] = loadfx( "vfx/ambient/props/vfx_gas_pump_exp" );
	level._effect[ "vfx_gas_station_sign_impact" ] = loadfx( "vfx/moments/mp_dart/vfx_gas_station_sign_impact" );
	level._effect[ "vfx_gas_station_column_dust_linger" ] = loadfx( "vfx/moments/mp_dart/vfx_gas_station_column_dust_linger" );
	level._effect[ "vfx_gas_station_column_dust_impact" ] = loadfx( "vfx/moments/mp_dart/vfx_gas_station_column_dust_impact" );
	level._effect[ "vfx_gas_station_smk_linger" ] = loadfx( "vfx/moments/mp_dart/vfx_gas_station_smk_linger" );
	level._effect[ "vfx_int_haze_mp_dart" ] = loadfx( "vfx/ambient/atmospheric/vfx_int_haze_mp_dart" );
	level._effect[ "vfx_amb_sand" ] = loadfx( "vfx/ambient/sand/vfx_amb_sand" );
	level._effect[ "vfx_sand_ambient_blowing" ] = loadfx( "vfx/ambient/weather/sand/vfx_sand_ambient_blowing" );
/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_dart_fx::main(); 
#/
	level._effect[ "smoky_fluorescent_light_fit" ] 			= loadfx( "vfx/ambient/lights/smoky_fluorescent_light_fit" );
	level._effect[ "vfx_sand_ceiling_impact_fall" ] 		= loadfx( "vfx/ambient/weather/sand/vfx_sand_ceiling_impact_fall" );
	level._effect[ "sand_spray_oriented" ] 					= loadfx( "fx/sand/sand_spray_oriented" );
	level._effect[ "sand_spiral_updraft_runner" ] 			= loadfx( "vfx/ambient/sand/sand_spiral_updraft_runner" );
	level._effect[ "paper_blowing_trash_r_frequent" ] 		= loadfx( "fx/misc/paper_blowing_trash_r_frequent" );
	level._effect[ "vfx_sand_trash_spiral_runner_mp" ] 		= loadfx( "vfx/ambient/weather/sand/vfx_sand_trash_spiral_runner_mp" );
	level._effect[ "dust_motes_interior" ] 					= loadfx( "vfx/ambient/dust/particulates/dust_motes_interior" );
	level._effect[ "insects_carcass_flies_heavy" ] 			= loadfx( "fx/misc/insects_carcass_flies_heavy" );
	level._effect[ "sand_spray_oriented_short" ] 			= loadfx( "fx/sand/sand_spray_oriented_short" ); 
	level._effect[ "mp_dart_ceiling_bloom" ] 				= loadfx( "vfx/moments/mp_dart/mp_dart_ceiling_bloom" );
	level._effect[ "sand_blowing_motes" ] 					= loadfx( "vfx/ambient/sand/sand_blowing_motes" );
	level._effect[ "mp_dart_breach_wall_01" ] 				= loadfx( "vfx/moments/mp_dart/mp_dart_breach_wall_01" );
	level._effect[ "mp_dart_breach_wall_02" ] 				= loadfx( "vfx/moments/mp_dart/mp_dart_breach_wall_02" );
	level._effect[ "mp_dart_breach_01" ] 					= loadfx( "vfx/moments/mp_dart/mp_dart_breach_01" );
	level._effect[ "mp_dart_breach_02" ] 					= loadfx( "vfx/moments/mp_dart/mp_dart_breach_02" );
	level._effect[ "mp_dart_breach_03" ] 					= loadfx( "vfx/moments/mp_dart/mp_dart_breach_03" );
	level._effect[ "vfx_gas_station_explosion" ] 			= loadfx( "vfx/moments/mp_dart/vfx_gas_station_explosion" );
	level._effect[ "vfx_sand_trail_falling_thin" ] 			= loadfx( "vfx/ambient/weather/sand/vfx_sand_trail_falling_thin" );
	level._effect[ "vfx_tv_flashing" ] 						= loadfx( "vfx/ambient/props/vfx_tv_flashing" );
	level._effect[ "vfx_bulb_single" ] 						= loadfx( "vfx/ambient/lights/vfx_bulb_single" );
	
	
	// Exploders don't work yet
	level.scripted_exploders[1][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1181.14, 575.832, 143.875));
	level.scripted_exploders[1][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1256.66, 571.887, 143.875));
	level.scripted_exploders[1][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1351.65, 610.288, 143.875));
	level.scripted_exploders[1][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1517.76, 550.515, 143.875));
	level.scripted_exploders[1][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1582.73, 713.015, 143.875));
	level.scripted_exploders[1][5] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1473.45, 780.619, 143.875));
	level.scripted_exploders[1][6] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1209.16, 752.125, 143.875));
		
	level.scripted_exploders[2][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1197.23, 886.814, 143.473));
	level.scripted_exploders[2][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1504.12, 1046.98, 143.875));
	level.scripted_exploders[2][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1194.52, 1210.06, 143.875));
	level.scripted_exploders[2][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1170.78, 986.678, 142.916));
	level.scripted_exploders[2][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1257.74, 1084.5, 143.875));
	level.scripted_exploders[2][5] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1610.65, 1022.24, 143.875));
	level.scripted_exploders[2][6] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1572.75, 879.922, 143.875));
											   
	level.scripted_exploders[3][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(401.018, 961.155, 171.875));
	level.scripted_exploders[3][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(319.428, 1157.88, 171.875));
	level.scripted_exploders[3][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(301.571, 1116.15, 171.875));
										   
	level.scripted_exploders[4][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(637.314, 733.011, 163.868));
	level.scripted_exploders[4][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(783, 591.557, 168.293));
	level.scripted_exploders[4][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(358.8, 663.463, 159.6));
	level.scripted_exploders[4][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(532.605, 647.937, 159.298));
	level.scripted_exploders[4][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(361.732, 761.039, 167.019));
									   									   
	level.scripted_exploders[5][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(161.282, 1515.53, 168.875));
	level.scripted_exploders[5][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-20.3556, 1558.26, 149.695));
	level.scripted_exploders[5][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(159.859, 1242.45, 149.829));
	level.scripted_exploders[5][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(162.098, 1398.34, 171.875));
	level.scripted_exploders[5][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(0.159668, 1294.82, 114.875));
	level.scripted_exploders[5][5] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-48.0906, 1347.53, 155.875));
	level.scripted_exploders[5][6] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(5.75989, 1254.6, 155.875) );
	level.scripted_exploders[5][7] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-30.7175, 1213.63, 155.875));
									   									   
	level.scripted_exploders[6][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-169.06, 1258.48, 155.875));
	level.scripted_exploders[6][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-218.196, 1351.17, 155.875));
	level.scripted_exploders[6][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-292.266, 1487.12, 157.292));
	level.scripted_exploders[6][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-231.97, 1580.67, 155.875));
	level.scripted_exploders[6][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-273.813, 1240.95, 175.875));
									   									   
	level.scripted_exploders[7][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-611.645, 1482.75, 155.875));
	level.scripted_exploders[7][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-875.099, 1523.41, 171.875));
	level.scripted_exploders[7][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-572.706, 1217.7, 175.875));
	level.scripted_exploders[7][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-490.054, 1362.99, 175.875));
	level.scripted_exploders[7][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-408.897, 1503.11, 155.875));
									   									   
	level.scripted_exploders[8][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1179.48, 1308.05, 283.875));
	level.scripted_exploders[8][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1101.97, 1379.72, 273.374));
	level.scripted_exploders[8][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1212.1, 1161.35, 275.875));
	level.scripted_exploders[8][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1187.52, 1068.91, 275.875));
									   									   
	level.scripted_exploders[9][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1206.38, 864.216, 272.539));
	level.scripted_exploders[9][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1211.6, 969.233, 275.875));
	level.scripted_exploders[9][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1079.99, 994.148, 276));
	level.scripted_exploders[9][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1089.83, 1164.82, 274.4) );
	level.scripted_exploders[9][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1184.61, 1235.09, 139.875));
									   									   
	level.scripted_exploders[10][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1515.27, 893.547, 179.875));
	level.scripted_exploders[10][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1326.9, 1114.95, 179.875));
	level.scripted_exploders[10][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1521.01, 1340.38, 179.875));
	level.scripted_exploders[10][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1428.84, 1118.52, 179.875));
	level.scripted_exploders[10][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1401.99, 769, 129.438));
									   									   
	level.scripted_exploders[11][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1415.07, 1412.44, 179.875));
	level.scripted_exploders[11][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1411.64, 1335.87, 179.875));
	level.scripted_exploders[11][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1325.52, 1596.6, 179.875));
	level.scripted_exploders[11][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1484.2, 1783, 122.669));
	level.scripted_exploders[11][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1520.57, 1592.47, 179.875));
									   									   
	level.scripted_exploders[12][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1356.08, -537.96, 139.875));
	level.scripted_exploders[12][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1466.49, -681.589, 139.875));
	level.scripted_exploders[12][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1396.87, -832.157, 287.599));
									   									   
	level.scripted_exploders[13][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(581.526, -571.925, 270.505));
	level.scripted_exploders[13][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(430.789, -640.791, 272.749));
	level.scripted_exploders[13][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(567.972, -716.861, 272.657));
	level.scripted_exploders[13][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(431.521, -561.067, 139.875));
	level.scripted_exploders[13][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(408.485, -672.934, 140.346));
	level.scripted_exploders[13][5] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(660.169, -561.845, 139.875));
									   									   
	level.scripted_exploders[14][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1159.34, -718.345, 139.766));
	level.scripted_exploders[14][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1035.55, -583.802, 139.875));
	level.scripted_exploders[14][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1188.91, -563.23, 139.875));
	level.scripted_exploders[14][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(1103.84, -798.871, 283.875));
									   									   
	level.scripted_exploders[15][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-601.15, -1475.97, 282.875));
	level.scripted_exploders[15][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-439.504, -1473.9, 282.875));
	level.scripted_exploders[15][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-608.803, -1272.13, 282.871));
	level.scripted_exploders[15][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-509.431, -1370.59, 139.875));
	level.scripted_exploders[15][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-822.282, -1488.44, 139.875));
									   									   
	level.scripted_exploders[16][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1360.35, -1123.28, 275.875));
	level.scripted_exploders[16][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1388.9, -951.665, 275.875));
	level.scripted_exploders[16][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1174.57, -969.424, 289.875));
	level.scripted_exploders[16][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1117.64, -1135.04, 287.004));
	level.scripted_exploders[16][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1257, -991.308, 138.875));
	level.scripted_exploders[16][5] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1040.94, -1142.26, 138.875));
									   									   
	level.scripted_exploders[17][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-598.81, -1152.33, 145.875));
	level.scripted_exploders[17][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-551.625, -948.538, 139.223));
	level.scripted_exploders[17][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-652.497, -1095.56, 278.088));
	level.scripted_exploders[17][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-493.15, -848.799, 275.875));
	level.scripted_exploders[17][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-745.44, -947.257, 272.169));
									   
	level.scripted_exploders[18][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-488.069, -769.008, 282.875));
	level.scripted_exploders[18][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-515.776, -528.95, 264.805));
	level.scripted_exploders[18][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-667.435, -471.058, 282.875));
	level.scripted_exploders[18][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-740.718, -427.237, 261.294));
	level.scripted_exploders[18][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-800.536, -412.705, 266.776));
	level.scripted_exploders[18][5] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-437.729, -691.024, 143.875));
	level.scripted_exploders[18][6] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-590.751, -533.819, 143.875));
									   									   
	level.scripted_exploders[19][0] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1043.56, -446.774, 145.875));
	level.scripted_exploders[19][1] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1288.59, -577.666, 145.875));
	level.scripted_exploders[19][2] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-770.351, -433.987, 270.071));
	level.scripted_exploders[19][3] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-880.566, -488.37, 282.875));
	level.scripted_exploders[19][4] = SpawnFx(level._effect["vfx_sand_ceiling_impact_fall"],(-1044.83, -584.047, 289.875));
	
}
 
