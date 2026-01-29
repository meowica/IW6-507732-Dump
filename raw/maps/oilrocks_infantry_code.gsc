#include maps\_utility;
#include common_scripts\utility;

infantry_teleport_start( struct_target_name )
{
	start	= getstructarray( struct_target_name, "targetname" )[ 0 ];
	level.player teleport_player( start );
	spawn_start_guys( start );
	level.player TakeAllWeapons();
	maps\_loadout::give_loadout();
}

spawn_start_guys( start_struct )
{
	guys = array_spawn_targetname( start_struct.target, true );
	foreach ( guy in guys )
		guy deletable_magic_bullet_shield();
	level.infantry_guys = guys;
} 
