#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;

carrier_javelin_init()
{
	precacheShader( "javelin_hud_target_offscreen" );

	//array_thread( level.players, maps\_javelin::ClearCLUTarget() );
	level.player thread maps\_javelin::ClearCLUTarget();

	SetSavedDvar( "vehHudTargetSize", 50 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferLeft", 120 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferRight", 126 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferTop", 139 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferBottom", 134 );

	//array_thread( level.players, ::carrier_JavelinToggleLoop );
	level.player thread carrier_JavelinToggleLoop();
	//array_thread( level.players,::JavelinFiredNotify );
	//thread TraceConstantTest();
}

carrier_JavelinToggleLoop()
{
	//self --> the player
	self endon( "death" );

	for ( ;; )
	{
		while ( ! self maps\_javelin::PlayerJavelinAds() )
			wait 0.05;
		self thread carrier_JavelinCLULoop();

		while ( self maps\_javelin::PlayerJavelinAds() )
			wait 0.05;
		self notify( "javelin_clu_off" );
		self maps\_javelin::ClearCLUTarget();
	}
}

carrier_JavelinCLULoop()
{
	//self --> the player
	self endon( "death" );
	self endon( "javelin_clu_off" );

	LOCK_LENGTH = 1250;

	for ( ;; )
	{
		wait 0.05;

		//-------------------------
		// Four possible states:
		//      No missile in the tube, so CLU will not search for targets.
		//		CLU has a lock.
		//		CLU is locking on to a target.
		//		CLU is searching for a target to begin locking on to.
		//-------------------------

		clipAmmo = self GetCurrentWeaponClipAmmo();
		if ( !clipAmmo )
		{
			self maps\_javelin::ClearCLUTarget();
			continue;
		}

		if ( level.javelinLockFinalized )
		{
			if ( ! self maps\_javelin::IsStillValidTarget( level.javelinTarget ) )
			{
				self maps\_javelin::ClearCLUTarget();
				continue;
			}
			self maps\_javelin::SetTargetTooClose( level.javelinTarget );
			self maps\_javelin::SetNoClearance();
			//print3D( level.javelinTarget.origin, "* LOCKED!", (.2, 1, .3), 1, 5 );
			continue;
		}

		if ( level.javelinLockStarted )
		{
			if ( ! self maps\_javelin::IsStillValidTarget( level.javelinTarget ) )
			{
				self maps\_javelin::ClearCLUTarget();
				continue;
			}

			//print3D( level.javelinTarget.origin, "* locking...!", (.2, 1, .3), 1, 5 );

			timePassed = getTime() - level.javelinLockStartTime;
			if ( timePassed < LOCK_LENGTH )
				continue;

			assert( isdefined( level.javelinTarget ) );
			self notify( "stop_lockon_sound" );
			level.javelinLockFinalized = true;
			self WeaponLockFinalize( level.javelinTarget );
			self PlayLocalSound( "javelin_clu_lock" );
			self maps\_javelin::SetTargetTooClose( level.javelinTarget );
			self maps\_javelin::SetNoClearance();
			continue;
		}

		bestTarget = self maps\_javelin::GetBestJavelinTarget();
		if ( !isDefined( bestTarget ) )
			continue;

		level.javelinTarget = bestTarget;
		level.javelinLockStartTime = getTime();
		level.javelinLockStarted = true;
		self WeaponLockStart( bestTarget );
		self thread maps\_javelin::LoopLocalSeekSound( "javelin_clu_aquiring_lock", 0.6 );
	}
}