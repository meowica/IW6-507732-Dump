#include maps\_vehicle_aianim;
#include maps\_vehicle;

main( model, type, classname )
{
	build_template( "zpu_antiair", model, type, classname );
	build_localinit( ::init_localoilrocks );
	build_deathmodel( "vehicle_zpu4_low", "vehicle_zpu4_burn" );
	build_deathfx( "fx/_requests/oilrocks/optimize_temp/deathfx_zpu_delete", undefined, "exp_armor_vehicle", undefined, undefined, 	undefined, 0 );
	build_mainturret( "tag_flash", "tag_flash2", "tag_flash1", "tag_flash3" );
	build_radiusdamage( ( 0, 0, 53 ), 512, 300, 20, false );
//	build_bulletshield(true);
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	build_aianims( vehicle_scripts\_zpu_antiair::setanims,  vehicle_scripts\_zpu_antiair::set_vehicle_anims );
}

init_localoilrocks()
{
	self.script_explosive_bullet_shield = true;
	self thread feelGoodApacheGunDeath();
	vehicle_scripts\_zpu_antiair::init_local();
}

feelGoodApacheGunDeath()
{
	self endon ( "death" );
	hit_count = 0;
	
	while ( hit_count < level.apache_difficulty.zpu_magic_bullets )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, dFlags, weaponName );
		if ( type == "MOD_EXPLOSIVE_BULLET" )
			hit_count++;
		
	}
	
	self force_kill();

}

/*QUAKED script_vehicle_zpu4_oilrocks (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_zpu_antiair_oilrocks::main( "vehicle_zpu4_low", undefined, "script_vehicle_zpu4_oilrocks" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_zpu4_low_zpu_oilrocks
sound,vehicle_zpu,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_zpu4_low"
default:"vehicletype" "zpu_antiair"
*/
