#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;
#include vehicle_scripts\_chopper_missile_defense_utility;

_precache()
{
	PreCacheModel( "angel_flare_rig" );

	_fx();
	
	flare_rig_anims();
}

_fx()
{
	level._effect[ "FX_chopper_flare_ai" ]			= LoadFX( "fx/_requests/apache/apache_flare_ai" );
	level._effect[ "FX_chopper_flare_explosion_ai" ]	= LoadFX( "fx/_requests/apache/apache_trophy_explosion_ai" );

	// JC-ToDo: This should not be here. Enemy AI need to be packaged up
	level._effect[ "FX_hind_damaged_smoke_heavy" ] 	= loadfx( "fx/smoke/smoke_trail_black_heli" );
}

#using_animtree( "script_model" );
flare_rig_anims()
{
	level.scr_animtree[ "ai_flare_rig" ] 				= #animtree;
	level.scr_model[ "ai_flare_rig" ] 					= "angel_flare_rig";

	level.scr_anim[ "ai_flare_rig" ][ "flare" ][ 0 ]	= %ac130_angel_flares01;
	level.scr_anim[ "ai_flare_rig" ][ "flare" ][ 1 ]	= %ac130_angel_flares02;
	level.scr_anim[ "ai_flare_rig" ][ "flare" ][ 2 ]	= %ac130_angel_flares03;
}

_init( owner, flareCooldown )
{
	Assert( IsDefined( owner ) && owner isVehicle() );
	
	missile_defense = SpawnStruct();
	
	// Generic Missile Defense Settings
	missile_defense.owner						= owner;
	missile_defense.vehicle						= owner;
	missile_defense.vehicle.missile_defense		= missile_defense;
	missile_defense.type						= "missile_defense";
	missile_defense.lockedOnToMe				= [];
	missile_defense.firedOnMe					= [];
	missile_defense.flareIndex					= 0;
	missile_defense.flares						= [];
	missile_defense.flareNumPairs				= 2;
	missile_defense.flareCooldown				= ter_op( IsDefined( flareCooldown ), flareCooldown, 6 );
	missile_defense.flareReloadTime				= 0;
	missile_defense.flareActiveRadius			= 4000;
	missile_defense.flareFx						= getfx( "FX_chopper_flare_ai" );
	missile_defense.flareFxExplode				= getfx( "FX_chopper_flare_explosion_ai" );
	missile_defense.missileTargetFlareRadius 	= 1500;
	missile_defense.flareDestroyMissileRadius	= 192;
	missile_defense.flareSpawnMaxPitchOffset	= 20;
	missile_defense.flareSpawnMinPitchOffset	= 10;
	missile_defense.flareSpawnMaxYawOffset		= 80;
	missile_defense.flareSpawnMinYawOffset		= 55;
	missile_defense.flareSpawnOffsetRight		= 104;
	missile_defense.flareRig_name				= "ai_flare_rig";
	missile_defense.flareRig_animRate			= 2;
	missile_defense.flareRig_link				= false;
	missile_defense.flareRig_tagOrigin			= "tag_flare";
	missile_defense.flareRig_tagAngles			= "tag_origin";
	missile_defense.flareSound					= "chopper_flare_fire_ai";
	
	return missile_defense;
}

_start()
{
	owner = self.owner;
	
	owner endon( "LISTEN_end_missile_defense" );
	
	// Common defense system logic
	self childthread monitorEnemyMissileLockOn();
	self childthread monitorEnemyMissileFire();
	self childthread monitorFlareRelease_auto();
	self childthread monitorFlares();
	
	// Local defense system logic specific to ai
	// JC-ToDo: This shouldn't go here. There should be a parent enemy logic script file which handles calling _destroy();
	self childthread monitorDeath();
}

_end()
{
	owner = self.owner;
	
	owner notify( "LISTEN_end_missile_defense" );
}

monitorDeath()
{
	owner = self.owner;
	owner waittill( "death" );
	self _destroy();
}
_destroy()
{
	self _end();
	
	// clean up circular reference to missile defense struct
	self.vehicle.missile_defense = undefined;
}