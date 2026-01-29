//_createfx generated. Do not touch!!
#include common_scripts\utility;
#include common_scripts\_createfx;


main()
{
	// CreateFX fx entities placed: 187
	ent = createOneshotEffect( "lens_flare_test_01" );
	ent set_origin_and_angles( (1774.69, -1179.3, -1881.34), (270, 0, 0) );

	ent = createExploderEx( "ambient_explosion", "explode01" );
	ent set_origin_and_angles( (-930, -3432, -1340), (1.00002, 270, 89.9995) );
	ent.v[ "flag" ] = "explode01";

	ent = createExploderEx( "ambient_explosion", "explode02" );
	ent set_origin_and_angles( (-976.2, -3508.7, -1223.93), (57.9999, 270, 89.9994) );
	ent.v[ "flag" ] = "explode02";

	ent = createExploderEx( "ambient_explosion", "explode03" );
	ent set_origin_and_angles( (-938.4, -3582.3, -1436.55), (270, 0, 0) );
	ent.v[ "flag" ] = "explode03";

	ent = createExploderEx( "ambient_explosion", "explode04" );
	ent set_origin_and_angles( (-837.7, -3794.4, -1397.3), (270, 0, 0) );
	ent.v[ "flag" ] = "explode04";

	ent = createExploderEx( "ambient_explosion", "explode05" );
	ent set_origin_and_angles( (-849.4, -3845.7, -1483.71), (296, 89.9995, -89.9995) );
	ent.v[ "flag" ] = "explode05";

	ent = createExploderEx( "ambient_explosion", "explode06" );
	ent set_origin_and_angles( (-935.6, -3856.9, -1524.34), (289, 89.9993, -89.9994) );
	ent.v[ "flag" ] = "explode06";

	ent = createExploderEx( "ambient_explosion", "explode07" );
	ent set_origin_and_angles( (-986.9, -3794.1, -1397.42), (297, 89.9995, -89.9995) );
	ent.v[ "flag" ] = "explode07";

	ent = createExploderEx( "ambient_explosion", "explode08" );
	ent set_origin_and_angles( (-1009.6, -3507.1, -1417.64), (270, 0, 0) );
	ent.v[ "flag" ] = "explode08";

	ent = createExploderEx( "ambient_explosion", "1" );
	ent set_origin_and_angles( (1003.3, -2796.1, -996.2), (0, 270, 89.9996) );
	ent.v[ "flag" ] = "s_explode01";

	ent = createExploderEx( "ambient_explosion", "1" );
	ent set_origin_and_angles( (657.6, -3045.9, -1020.9), (347, 0, 0) );
	ent.v[ "flag" ] = "s_explode02";

	ent = createExploderEx( "ambient_explosion", "1" );
	ent set_origin_and_angles( (1084.4, -3125, -1006.9), (357, 180, -180) );
	ent.v[ "flag" ] = "s_explode03";

	ent = createExploderEx( "ambient_explosion", "s_explode04" );
	ent set_origin_and_angles( (1007.5, -3171.7, -1023), (351.001, 272.842, 91.0123) );
	ent.v[ "flag" ] = "s_explode04";

	ent = createExploderEx( "ambient_explosion", "s_explode05" );
	ent set_origin_and_angles( (965.6, -2888, -1013.1), (358, 270, 89.9995) );
	ent.v[ "flag" ] = "s_explode05";

	ent = createExploderEx( "ambient_explosion", "s_explode06" );
	ent set_origin_and_angles( (775.2, -2899, -1024.6), (0, 270, 89.9996) );
	ent.v[ "flag" ] = "s_explode06";

	ent = createExploderEx( "ambient_explosion", "s_explode07" );
	ent set_origin_and_angles( (626.6, -2920.5, -1045.5), (346.434, 295.77, 83.5389) );
	ent.v[ "flag" ] = "s_explode07";

	ent = createExploderEx( "ambient_explosion", "s_explode08" );
	ent set_origin_and_angles( (526.7, -2917.9, -1082.5), (360, 250, 89.9995) );
	ent.v[ "flag" ] = "s_explode08";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light01" );
	ent set_origin_and_angles( (-1510.87, -5833.2, -60649.9), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light01";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light02" );
	ent set_origin_and_angles( (-1422.07, -5319.75, -60768), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light02";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light03" );
	ent set_origin_and_angles( (-1600.42, -5317.6, -60767.6), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light03";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light00" );
	ent set_origin_and_angles( (-1532.68, -3720.33, -1516.21), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light00";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light04" );
	ent set_origin_and_angles( (-1296.08, -3725.51, -1424.73), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light04";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light05" );
	ent set_origin_and_angles( (-1283.02, -3462.59, -1419.84), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light05";

	ent = createExploderEx( "electrical_spark_loop", "spark_loop01" );
	ent set_origin_and_angles( (-1403.68, -5376.79, -60747.5), (360, 180, 179) );
	ent.v[ "flag" ] = "spark_loop01";

	ent = createExploderEx( "electrical_spark_loop", "spark_loop02" );
	ent set_origin_and_angles( (-1623.62, -5378.15, -60747.5), (1.00022, 0, 1.00026) );
	ent.v[ "flag" ] = "spark_loop02";

	ent = createExploderEx( "electrical_spark_loop", "spark_loop04" );
	ent set_origin_and_angles( (-1588.06, -5329.87, -60603.3), (41.9925, 0.900529, 1.34569) );
	ent.v[ "flag" ] = "spark_loop04";

	ent = createExploderEx( "electrical_spark_loop", "spark_loop03" );
	ent set_origin_and_angles( (-1422.64, -5346.3, -60886.2), (319.007, 180.869, 178.675) );
	ent.v[ "flag" ] = "spark_loop03";

	ent = createExploderEx( "electrical_spark_loop", "spark_loop05" );
	ent set_origin_and_angles( (-1421.42, -5329.2, -60642.2), (23.9959, 179.555, 178.905) );
	ent.v[ "flag" ] = "spark_loop05";

	ent = createExploderEx( "electrical_spark_loop", "spark_loop06" );
	ent set_origin_and_angles( (-1501.42, -5325.83, -60679.3), (0.998724, 273.001, -179.948) );
	ent.v[ "flag" ] = "spark_loop06";

	ent = createExploderEx( "steam_jet_loop", "steam_loop01" );
	ent set_origin_and_angles( (-1618.2, -5339.49, -60761.4), (357.757, 357.194, -4.63131) );
	ent.v[ "flag" ] = "steam_loop01";

	ent = createExploderEx( "steam_jet_loop", "steam_loop02" );
	ent set_origin_and_angles( (-1473.67, -5294.13, -60805.2), (328.366, 174.154, -174.562) );
	ent.v[ "flag" ] = "steam_loop02";

	ent = createExploderEx( "steam_jet_loop", "steam_loop03" );
	ent set_origin_and_angles( (-1499.09, -3635.56, -65981.5), (4.83008, 133.178, 1.77409) );
	ent.v[ "flag" ] = "steam_loop03";

	ent = createExploderEx( "steam_jet_loop", "steam_loop00" );
	ent set_origin_and_angles( (-1548.48, -5531.91, -60719.9), (44.6724, 35.5655, 25.2384) );
	ent.v[ "flag" ] = "steam_loop00";

	ent = createExploderEx( "steam_jet_loop", "steam_loop04" );
	ent set_origin_and_angles( (-1545.67, -5217.82, -60727.5), (33.6248, 353.927, -5.56031) );
	ent.v[ "flag" ] = "steam_loop04";

	ent = createExploderEx( "steam_jet_loop", "steam_loop06" );
	ent set_origin_and_angles( (-1702.48, -3641.06, -65703.1), (29.4955, 53.6097, -1.40499) );
	ent.v[ "flag" ] = "steam_loop06";

	ent = createExploderEx( "steam_jet_loop", "steam_loop05" );
	ent set_origin_and_angles( (-1587, -3560.06, -65911.8), (355.14, 312.175, -1.6894) );
	ent.v[ "flag" ] = "steam_loop05";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light_spin01" );
	ent set_origin_and_angles( (-1450.51, -3577.55, -65968.1), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light_spin01";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light_spin02" );
	ent set_origin_and_angles( (-1646.47, -3580.61, -65968.1), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light_spin02";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light_spin03" );
	ent set_origin_and_angles( (-1672.96, -3603.46, -65651.4), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light_spin03";

	ent = createExploderEx( "glow_red_light_400_strobe", "red_emergency_light06" );
	ent set_origin_and_angles( (-1641.48, -4980.75, -60767), (270, 0, 0) );
	ent.v[ "flag" ] = "red_emergency_light06";

	ent = createExploderEx( "steam_jet_loop", "steam_loop07" );
	ent set_origin_and_angles( (-1750.64, -3625.74, -65791.8), (309.998, 82.3126, 100.42) );
	ent.v[ "flag" ] = "steam_loop07";

	ent = createExploderEx( "steam_jet_loop", "steam_loop08" );
	ent set_origin_and_angles( (-1769.74, -3570.17, -65696.8), (58.8935, 327.306, -28.7204) );
	ent.v[ "flag" ] = "steam_loop08";

	ent = createExploderEx( "xm25_explosion", "escape_out_explosion01" );
	ent set_origin_and_angles( (-2450.82, -3602.21, -1292.62), (4.0005, 360, 0) );
	ent.v[ "flag" ] = "escape_out_explosion01";

	ent = createExploderEx( "xm25_explosion", "escape_out_explosion02" );
	ent set_origin_and_angles( (-2416.28, -3424.88, -1472.55), (358.109, 340.989, 0.651212) );
	ent.v[ "flag" ] = "escape_out_explosion02";

	ent = createExploderEx( "xm25_explosion", "escape_out_explosion03" );
	ent set_origin_and_angles( (-2399.78, -5579.86, -60760.4), (4.00039, 360, -89.9989) );
	ent.v[ "flag" ] = "escape_out_explosion03";

	ent = createExploderEx( "xm25_explosion", "escape_out_explosion04" );
	ent set_origin_and_angles( (-2383.18, -5782.87, -60919.5), (343, 360, -89.9984) );
	ent.v[ "flag" ] = "escape_out_explosion04";

	ent = createExploderEx( "xm25_explosion", "escape_out_explosion05" );
	ent set_origin_and_angles( (-2362.64, -3639.71, -1450.17), (4.0005, 360, 0) );
	ent.v[ "flag" ] = "escape_out_explosion05";

	ent = createExploderEx( "xm25_explosion", "escape_out_explosion06" );
	ent set_origin_and_angles( (-2312.98, -5793.09, -60803.5), (4.00039, 360, -89.9989) );
	ent.v[ "flag" ] = "escape_out_explosion06";

	ent = createExploderEx( "electrical_spark_loop", "1" );
	ent set_origin_and_angles( (-2401.04, -5575.91, -60760.1), (355.002, 0.191589, -0.998318) );
	ent.v[ "flag" ] = "escape_spark_loop01";

	ent = createExploderEx( "electrical_spark_loop", "1" );
	ent set_origin_and_angles( (-2326.84, -5809.94, -60656.1), (358.002, 0.139558, -0.995115) );
	ent.v[ "flag" ] = "escape_spark_loop02";

	ent = createExploderEx( "electrical_spark_loop", "1" );
	ent set_origin_and_angles( (-2307.83, -5692.24, -60776.3), (355.002, 0.191589, -0.998318) );
	ent.v[ "flag" ] = "escape_spark_loop03";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash01" );
	ent set_origin_and_angles( (-1400.91, -5375, -60742.1), (359, 180, 180) );
	ent.v[ "flag" ] = "escape_breaker_flash01";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash02" );
	ent set_origin_and_angles( (-1621.62, -5374.66, -60750.2), (0, 360, 0) );
	ent.v[ "flag" ] = "escape_breaker_flash02";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash03" );
	ent set_origin_and_angles( (-1421.23, -5344.39, -60886.7), (328.992, 175.107, 179.797) );
	ent.v[ "flag" ] = "escape_breaker_flash03";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash04" );
	ent set_origin_and_angles( (-1588.94, -5328.5, -60605.4), (37.0001, 360, 0) );
	ent.v[ "flag" ] = "escape_breaker_flash04";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash06" );
	ent set_origin_and_angles( (-1503.02, -5326.75, -60683.6), (359.965, 268, 179) );
	ent.v[ "flag" ] = "escape_breaker_flash06";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash_early01" );
	ent set_origin_and_angles( (-2380.87, -3697.68, -1353.82), (0.996436, 355, 179.913) );
	ent.v[ "flag" ] = "escape_breaker_flash_early01";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash_early02" );
	ent set_origin_and_angles( (-2362.13, -3498.18, -1399.16), (0.996436, 355, 179.913) );
	ent.v[ "flag" ] = "escape_breaker_flash_early02";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash_early03" );
	ent set_origin_and_angles( (-2377.77, -3632.07, -1462.34), (1.99642, 354.999, 179.913) );
	ent.v[ "flag" ] = "escape_breaker_flash_early03";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash_early04" );
	ent set_origin_and_angles( (-1471.82, -5545.73, -60726.9), (42, 180, -180) );
	ent.v[ "flag" ] = "escape_breaker_flash_early04";

	ent = createExploderEx( "circuit_breaker", "escape_breaker_flash_early05" );
	ent set_origin_and_angles( (-1560.02, -5538.85, -60766.6), (0, 2.97164, -2.67552) );
	ent.v[ "flag" ] = "escape_breaker_flash_early05";

	ent = createExploderEx( "steam_jet_loop", "steam_loop_early01" );
	ent set_origin_and_angles( (-1524.83, -5541.5, -60814.5), (274.635, 90.1131, -93.0907) );
	ent.v[ "flag" ] = "steam_loop_early01";

	ent = createExploderEx( "steam_jet_loop", "steam_loop_early02" );
	ent set_origin_and_angles( (-1497.24, -5537.64, -60722.5), (74.82, 190.532, -166.014) );
	ent.v[ "flag" ] = "steam_loop_early02";

	ent = createExploderEx( "circuit_breaker", "spin_breaker_flash01" );
	ent set_origin_and_angles( (-1634.83, -3473.07, -65638.5), (0.866811, 290.691, -179.756) );
	ent.v[ "flag" ] = "spin_breaker_flash01";

	ent = createExploderEx( "electrical_spark_loop", "spark_loop_spin01" );
	ent set_origin_and_angles( (-1636.59, -3473.05, -65638.7), (0.998724, 273.001, -179.948) );
	ent.v[ "flag" ] = "spark_loop_spin01";

	ent = createExploderEx( "steam_jet_loop", "steam_loop_spin01" );
	ent set_origin_and_angles( (-1659.46, -3474.96, -65626.6), (22.6392, 291.03, -56.9209) );
	ent.v[ "flag" ] = "steam_loop_spin01";

	ent = createExploderEx( "airstrip_explosion", "3" );
	ent set_origin_and_angles( (-1116.57, -2607.28, -1837.48), (358, 89.9999, -89.9996) );
	ent.v[ "flag" ] = "odin_breach_enter";

	ent = createExploderEx( "airstrip_explosion", "3" );
	ent set_origin_and_angles( (-663.822, -3362.43, -1468.16), (358, 89.9999, -89.9996) );
	ent.v[ "flag" ] = "odin_breach_enter";

	ent = createExploderEx( "ambient_explosion", "escape_debris_explosion01" );
	ent set_origin_and_angles( (-1414.51, -4704.01, -60744.1), (11.9997, 180, 180) );
	ent.v[ "flag" ] = "escape_debris_explosion01";

	ent = createExploderEx( "ambient_explosion", "escape_debris_explosion02" );
	ent set_origin_and_angles( (-1405.67, -3621.8, -65390.9), (4.96228, 178.952, 94.7988) );
	ent.v[ "flag" ] = "escape_debris_explosion02";

	ent = createExploderEx( "glow_red_light_400_strobe", "spin02_emergency_light04" );
	ent set_origin_and_angles( (-2320, -3600.36, -65609.8), (270, 0, 0) );
	ent.v[ "flag" ] = "spin02_emergency_light04";

	ent = createExploderEx( "glow_red_light_400_strobe", "spin02_emergency_light03" );
	ent set_origin_and_angles( (-2320, -3600.63, -65872.6), (270, 0, 0) );
	ent.v[ "flag" ] = "spin02_emergency_light03";

	ent = createExploderEx( "glow_red_light_400_strobe", "spin02_emergency_light01" );
	ent set_origin_and_angles( (-1792, -3599.92, -65613.3), (270, 0, 0) );
	ent.v[ "flag" ] = "spin02_emergency_light01";

	ent = createExploderEx( "glow_red_light_400_strobe", "spin02_emergency_light02" );
	ent set_origin_and_angles( (-1792, -3597.34, -65880.8), (270, 0, 0) );
	ent.v[ "flag" ] = "spin02_emergency_light02";

	ent = createExploderEx( "steam_jet_loop", "spin02_glass_steam01" );
	ent set_origin_and_angles( (-2042.22, -3462.77, -65748.7), (0, 89.9997, -93.9997) );
	ent.v[ "flag" ] = "spin02_glass_steam01";

	ent = createExploderEx( "steam_jet_loop", "spin02_glass_steam02" );
	ent set_origin_and_angles( (-2096.39, -3469, -65716.5), (351.246, 93.6602, -94.5163) );
	ent.v[ "flag" ] = "spin02_glass_steam02";

	ent = createExploderEx( "steam_pipe_burst", "spin02_airlock_breach_steam01" );
	ent set_origin_and_angles( (-2361.09, -3602.09, -65742.9), (356, 180, 180) );
	ent.v[ "flag" ] = "spin02_airlock_breach_steam01";

	ent = createExploderEx( "steam_jet_loop", "spin02_glass_steam03" );
	ent set_origin_and_angles( (-2042.41, -3736.37, -65761.7), (19.9491, 271.454, 94.2556) );
	ent.v[ "flag" ] = "spin02_glass_steam03";

	ent = createExploderEx( "steam_jet_loop", "spin02_glass_steam04" );
	ent set_origin_and_angles( (-2069.18, -3738.14, -65734), (341.379, 258.786, 89.8363) );
	ent.v[ "flag" ] = "spin02_glass_steam04";

	ent = createExploderEx( "electrical_spark_loop", "spin02_spark_loop01" );
	ent set_origin_and_angles( (-1863.44, -3491.65, -65644.9), (13, 270, 89.9995) );
	ent.v[ "flag" ] = "spin02_spark_loop01";

	ent = createExploderEx( "electrical_spark_loop", "spin02_spark_loop02" );
	ent set_origin_and_angles( (-2187.06, -3485.95, -65689.7), (13, 270, 89.9995) );
	ent.v[ "flag" ] = "spin02_spark_loop02";

	ent = createExploderEx( "electrical_spark_loop", "spin02_spark_loop03" );
	ent set_origin_and_angles( (-2023.63, -3703.36, -65634.8), (37, 90.0007, -89.9994) );
	ent.v[ "flag" ] = "spin02_spark_loop03";

	ent = createExploderEx( "electrical_spark_loop", "spin02_spark_loop04" );
	ent set_origin_and_angles( (-2202.32, -3718.76, -65740), (356, 90.0004, -89.9996) );
	ent.v[ "flag" ] = "spin02_spark_loop04";

	ent = createExploderEx( "xm25_explosion", "spin02_out_explosion01" );
	ent set_origin_and_angles( (-2154.39, -3251.91, -65760.6), (2.00002, 270, 89.9995) );
	ent.v[ "flag" ] = "spin02_out_explosion01";

	ent = createExploderEx( "xm25_explosion", "spin02_out_explosion02" );
	ent set_origin_and_angles( (-2287.71, -3167.39, -65704.4), (0, 270.001, 89.9993) );
	ent.v[ "flag" ] = "spin02_out_explosion02";

	ent = createExploderEx( "xm25_explosion", "spin02_out_explosion03" );
	ent set_origin_and_angles( (-2202.47, -3998.49, -65777.9), (358, 90.0003, -89.9994) );
	ent.v[ "flag" ] = "spin02_out_explosion03";

	ent = createExploderEx( "xm25_explosion", "spin02_out_explosion04" );
	ent set_origin_and_angles( (-2694.42, -4143.7, -65715), (359.156, 24.9864, -88.1867) );
	ent.v[ "flag" ] = "spin02_out_explosion04";

	ent = createExploderEx( "steam_jet_loop", "spin02_glass_steam05" );
	ent set_origin_and_angles( (-2031.25, -3733.46, -65710.4), (341.379, 258.786, 89.8363) );
	ent.v[ "flag" ] = "spin02_glass_steam05";

	ent = createExploderEx( "steam_jet_loop", "spin02_glass_steam06" );
	ent set_origin_and_angles( (-2080.71, -3468.77, -65781.7), (21.0807, 90.3153, -94.6201) );
	ent.v[ "flag" ] = "spin02_glass_steam06";

	ent = createExploderEx( "xm25_explosion", "spin02_out_explosion05" );
	ent set_origin_and_angles( (-1958.04, -4304.65, -65794.5), (358, 90.0003, -89.9994) );
	ent.v[ "flag" ] = "spin02_out_explosion05";

	ent = createExploderEx( "xm25_explosion", "spin02_out_explosion06" );
	ent set_origin_and_angles( (-1868.46, -3056.12, -65737.3), (2.00002, 270, 89.9995) );
	ent.v[ "flag" ] = "spin02_out_explosion06";

	ent = createExploderEx( "wall_collapse_dust_wave_hamburg", "spin02_airlock_breach_dust" );
	ent set_origin_and_angles( (-2383.32, -3599.76, -65763.9), (356.799, 86.0503, -2.78518) );
	ent.v[ "flag" ] = "spin02_airlock_breach_dust";

	ent = createExploderEx( "glow_red_light_400_strobe", "pod_open_warning" );
	ent set_origin_and_angles( (-14557.7, -4044.14, -65734.5), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "glow_red_light_400_strobe", "pod_open_warning" );
	ent set_origin_and_angles( (-14723.5, -4374.12, -65697), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "glow_red_light_400_strobe", "pod_open_warning" );
	ent set_origin_and_angles( (-14964.1, -4243.85, -65512.4), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "glow_red_light_400_strobe", "pod_open_warning" );
	ent set_origin_and_angles( (-14808.3, -3909.55, -65548), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "xm25_explosion", "pod_open" );
	ent set_origin_and_angles( (-14557.7, -4044.14, -65734.5), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "xm25_explosion", "pod_open" );
	ent set_origin_and_angles( (-14723.5, -4374.12, -65697), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "xm25_explosion", "pod_open" );
	ent set_origin_and_angles( (-14964.1, -4243.85, -65512.4), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "xm25_explosion", "pod_open" );
	ent set_origin_and_angles( (-14808.3, -3909.55, -65548), (270, 0, 0) );
	ent.v[ "flag" ] = "1";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_01" );
	ent set_origin_and_angles( (-14645.9, -4080.38, -64625.4), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_02" );
	ent set_origin_and_angles( (-14855, -3998.74, -64924.6), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_03" );
	ent set_origin_and_angles( (-15030.3, -3967.19, -65179.9), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_04" );
	ent set_origin_and_angles( (-15213.8, -3912.51, -65465.2), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_05" );
	ent set_origin_and_angles( (-15357.3, -3852.91, -65746.4), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_06" );
	ent set_origin_and_angles( (-15543.1, -3817.23, -65945.4), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_07" );
	ent set_origin_and_angles( (-15673.6, -3752.05, -66158.6), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_08" );
	ent set_origin_and_angles( (-15806.8, -3734.34, -66371.1), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_09" );
	ent set_origin_and_angles( (-15970.7, -3680.87, -66572.9), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_10" );
	ent set_origin_and_angles( (-16089.9, -3634.34, -66776.8), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_11" );
	ent set_origin_and_angles( (-16227.9, -3596.21, -67025.8), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "rog_launch_barrel", "rog_barrel_12" );
	ent set_origin_and_angles( (-16406.3, -3551.62, -67268), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_01" );
	ent set_origin_and_angles( (-14645.9, -4080.38, -64625.4), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_02" );
	ent set_origin_and_angles( (-14855, -3998.74, -64924.6), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_03" );
	ent set_origin_and_angles( (-15030.3, -3967.19, -65179.9), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_04" );
	ent set_origin_and_angles( (-15213.8, -3912.51, -65465.2), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_05" );
	ent set_origin_and_angles( (-15357.3, -3852.91, -65746.4), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_06" );
	ent set_origin_and_angles( (-15543.1, -3817.23, -65945.4), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_07" );
	ent set_origin_and_angles( (-15673.6, -3752.05, -66158.6), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_08" );
	ent set_origin_and_angles( (-15806.8, -3734.34, -66371.1), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_09" );
	ent set_origin_and_angles( (-15970.7, -3680.87, -66572.9), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_10" );
	ent set_origin_and_angles( (-16089.9, -3634.34, -66776.8), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_11" );
	ent set_origin_and_angles( (-16227.9, -3596.21, -67025.8), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "rog_barrel_12" );
	ent set_origin_and_angles( (-16406.3, -3551.62, -67268), (270, 0, 0) );
	ent.v[ "flag" ] = "4";

	ent = createExploderEx( "strobe_flash_distant", "odin_5x5" );
	ent set_origin_and_angles( (1344.07, -3753.43, 3895.57), (270, 0, 0) );

	ent = createExploderEx( "strobe_flash_distant", "odin_5x5" );
	ent set_origin_and_angles( (720.077, -3266.89, 3642.17), (270, 0, 0) );

	ent = createExploderEx( "strobe_flash_distant", "odin_5x5" );
	ent set_origin_and_angles( (890.126, -4337.78, 3954.12), (270, 0, 0) );

	ent = createExploderEx( "strobe_flash_distant", "odin_5x5" );
	ent set_origin_and_angles( (312.27, -3902.19, 3566.3), (270, 0, 0) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_02" );
	ent set_origin_and_angles( (-96.0519, -3606.95, -65756.3), (360, 180, 178) );

	ent = createExploderEx( "rog_flash_odin", "decomp_01" );
	ent set_origin_and_angles( (-1599.96, -3663.61, -65828.8), (360, 180, 178) );

	ent = createExploderEx( "rog_ambientfire_odin", "decomp_01" );
	ent set_origin_and_angles( (-756.065, -4087.27, -65780.6), (360, 180, 178) );

	ent = createExploderEx( "rog_ambientfire_odin", "decomp_01" );
	ent set_origin_and_angles( (-964.402, -2827.8, -65780.3), (360, 180, 178) );

	ent = createExploderEx( "rog_smoke_odin", "decomp_01" );
	ent set_origin_and_angles( (-2135.62, -2484.24, -65957.3), (360, 180, 178) );

	ent = createExploderEx( "wall_collapse_dust_wave_hamburg", "decomp_01" );
	ent set_origin_and_angles( (-671.788, -3560.31, -65957.5), (360, 180, 178) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_02" );
	ent set_origin_and_angles( (-698.55, -3601.54, -65754.2), (360, 180, 178) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_02" );
	ent set_origin_and_angles( (-150.973, -3608.35, -65714), (15.9897, 179.426, 177.919) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_02" );
	ent set_origin_and_angles( (-152.875, -3605.48, -65782.6), (347.008, 180.462, 177.947) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_02" );
	ent set_origin_and_angles( (-154.605, -3643.29, -65742.7), (359.652, 170.006, 178.03) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_02" );
	ent set_origin_and_angles( (-150.215, -3560.17, -65745.9), (0.278025, 187.995, 178.019) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_sat" );
	ent set_origin_and_angles( (-4386.88, -3607.49, -65744.2), (360, 180, 178) );

	ent = createExploderEx( "wall_collapse_dust_wave_hamburg", "decomp_01" );
	ent set_origin_and_angles( (-1144.25, -4085.23, -65597), (360, 180, 178) );

	ent = createExploderEx( "glow_red_light_400_strobe", "post_explosion_damage" );
	ent set_origin_and_angles( (-4131.14, -3599.51, -65860.5), (270.834, 96.584, -92.6719) );

	ent = createExploderEx( "steam_jet_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3432.57, -3541.93, -65759), (14.167, 273.922, 90.0398) );

	ent = createExploderEx( "steam_jet_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3415.29, -3549.79, -65738.1), (339.167, 273.898, 90.0414) );

	ent = createExploderEx( "steam_jet_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3739.7, -3648.86, -65745.2), (74.833, 93.7701, -90.148) );

	ent = createExploderEx( "steam_jet_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3417.09, -3550.23, -65747), (339.167, 273.898, 90.0414) );

	ent = createExploderEx( "steam_jet_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3483.55, -3532.13, -65726.7), (339.167, 273.898, 90.0414) );

	ent = createExploderEx( "steam_jet_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3477.48, -3532.87, -65751.2), (339.167, 273.898, 90.0414) );

	ent = createExploderEx( "steam_jet_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3735.86, -3650.2, -65721.7), (74.833, 93.7701, -90.148) );

	ent = createExploderEx( "electrical_spark_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3802.06, -3679.01, -66055), (359.83, 87.9132, -90.021) );

	ent = createExploderEx( "electrical_spark_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3868.61, -3628.87, -66033.8), (359.83, 87.9132, -90.021) );

	ent = createExploderEx( "electrical_spark_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3874.57, -3866.4, -66177.1), (359.83, 87.9132, -90.021) );

	ent = createExploderEx( "electrical_spark_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3476.38, -3546.35, -65698.9), (359.17, 267.913, 90.0209) );

	ent = createExploderEx( "electrical_spark_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3394.76, -3542.97, -65689.1), (8.6152, 323.864, 102.534) );

	ent = createExploderEx( "electrical_spark_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-3770.64, -3661.78, -65803.1), (344.851, 87.114, -86.9136) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_sat" );
	ent set_origin_and_angles( (-4386.88, -3638.81, -65706), (360, 180, 178) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_sat" );
	ent set_origin_and_angles( (-4386.88, -3568.34, -65704.4), (360, 180, 178) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_sat" );
	ent set_origin_and_angles( (-4386.88, -3561.51, -65778.3), (360, 180, 178) );

	ent = createExploderEx( "explosive_decompression_1", "decomp_sat" );
	ent set_origin_and_angles( (-4386.88, -3639.4, -65780.6), (360, 180, 178) );

	ent = createExploderEx( "electrical_spark_loop", "post_explosion_damage" );
	ent set_origin_and_angles( (-4190.27, -3716.92, -65775.7), (326.83, 87.9266, -90.0251) );

	ent = createExploderEx( "rog_smoke_odin", "decomp_01" );
	ent set_origin_and_angles( (-2597.36, -4752.32, -66401.3), (360, 180, 178) );

	ent = createExploderEx( "airstrip_explosion", "pre_decomp_01" );
	ent set_origin_and_angles( (-797.272, -5667.94, -65741.2), (360, 180, 178) );

	ent = createExploderEx( "airstrip_explosion", "pre_decomp_01" );
	ent set_origin_and_angles( (-816.213, -1635.49, -65894.8), (360, 180, 178) );

	ent = createExploderEx( "airstrip_explosion", "pre_decomp_02" );
	ent set_origin_and_angles( (-793.302, -4938.27, -65714), (360, 180, 178) );

	ent = createExploderEx( "airstrip_explosion", "pre_decomp_02" );
	ent set_origin_and_angles( (-797.231, -2392.42, -65800.4), (360, 180, 178) );

	ent = createExploderEx( "airstrip_explosion", "pre_decomp_03" );
	ent set_origin_and_angles( (-804.069, -4198.04, -65715.8), (360, 180, 178) );

	ent = createExploderEx( "airstrip_explosion", "pre_decomp_03" );
	ent set_origin_and_angles( (-815.586, -3111.59, -65701.1), (360, 180, 178) );

	ent = createExploderEx( "explosive_decompression_1", "pre_decomp_03" );
	ent set_origin_and_angles( (112.617, -3731.18, -65750.7), (1.08921, 212.985, 178.322) );

	ent = createExploderEx( "explosive_decompression_1", "pre_decomp_03" );
	ent set_origin_and_angles( (123.928, -3469.28, -65749.9), (358.853, 145.017, 178.361) );

	ent = createExploderEx( "glow_red_light_400_strobe", "pre_decomp_03" );
	ent set_origin_and_angles( (-122.265, -3662.54, -65690.4), (2.00005, 270.001, -180) );

	ent = createExploderEx( "glow_red_light_400_strobe", "pre_decomp_03" );
	ent set_origin_and_angles( (-123.407, -3544.96, -65689), (2.00005, 270.001, -180) );

	ent = createExploderEx( "glow_red_light_400_strobe", "pre_decomp_03" );
	ent set_origin_and_angles( (-130.365, -3663.84, -65807.6), (2.00005, 270.001, -180) );

	ent = createExploderEx( "glow_red_light_400_strobe", "pre_decomp_03" );
	ent set_origin_and_angles( (-134.616, -3545.66, -65809.8), (2.00005, 270.001, -180) );

	ent = createExploderEx( "glow_red_light_400_strobe", "pre_decomp_03" );
	ent set_origin_and_angles( (213.874, -3600.63, -65538.1), (2.00005, 270.001, -180) );

	ent = createExploderEx( "glow_red_light_400_strobe", "pre_decomp_03" );
	ent set_origin_and_angles( (215.196, -3599.53, -65949.9), (2.00005, 270.001, -180) );

	ent = createExploderEx( "glow_red_light_400_strobe", "pre_decomp_03" );
	ent set_origin_and_angles( (-511.362, -3599.59, -65682.4), (2.00005, 270.001, -180) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-28.2202, -3494.09, -65690.2), (2.00005, 270.001, -180) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-44.61, -3490.41, -65832.9), (2.00005, 270.001, -180) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-500.645, -3713.44, -65686.2), (358.323, 56.9849, -178.91) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-624.125, -3666.07, -65778.6), (358.586, 135.018, 178.585) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-1200.14, -3734.16, -65782.7), (343.175, 65.7671, -179.15) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-1299.17, -3765.27, -65813.9), (2.00005, 270.001, -180) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-2144.57, -3753.17, -65957.6), (0.278325, 352.006, 179.981) );

	ent = createExploderEx( "electrical_spark_loop", "pre_decomp_03" );
	ent set_origin_and_angles( (-1853.62, -3741.43, -65972.4), (329.02, 81.8381, -179.675) );

	ent = createExploderEx( "debris_ambient_shell_casings", "fx_shell_casings_escape" );
	ent set_origin_and_angles( (2340.5, -3617.96, -65748.3), (270, 0, 0) );
	ent.v[ "flag" ] = "fx_shell_casings_escape";

	ent = createExploderEx( "debris_ambient_shell_casings", "fx_shell_casings_escape" );
	ent set_origin_and_angles( (1847.64, -3497.06, -65725.4), (270, 0, 0) );
	ent.v[ "flag" ] = "fx_shell_casings_escape";

	ent = createExploderEx( "debris_ambient_shell_casings", "fx_shell_casings_escape" );
	ent set_origin_and_angles( (1318.59, -3669.48, -65771), (270, 0, 0) );
	ent.v[ "flag" ] = "fx_shell_casings_escape";

}
 
