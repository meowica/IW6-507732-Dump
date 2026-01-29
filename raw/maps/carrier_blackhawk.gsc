#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_audio;
#include maps\_vehicle;




swap_blackhawk_guns(viewmodel_gun)
{
	//viewmodel_bones=["tag_barrel", "reloadgrip", "trigger", "barelrecoil", "bullet01", "bullet02", "bullet03", "bullet04", "bullet05", "bullet06", "bullet07", "bullet08", "bullet09", "bullet10" ];
	if (viewmodel_gun)
	{
		self.turret_model Hide();
		self.mgturret[0] Show();
		//self HidePart("tag_turret_npc");
		//foreach (bone in viewmodel_bones)
			//self ShowPart(bone);
	}
	else
	{
		self.turret_model Show();
		self.mgturret[0] Hide();
		//self ShowPart("tag_turret_npc");
		//foreach (bone in viewmodel_bones)
			//self HidePart(bone);
	}
}


// call on the vehicle when turret is not built into the vehicle
player_use_turret_with_viewmodel( tvm )
{
	level endon(tvm.end_on);
	tvm.turret assign_animtree();
	
	assert(!tvm.turret.is_occupied);
	tvm.turret.is_occupied = true;
	tvm.turret MakeUsable();
	tvm.turret SetMode( "manual" );
	tvm.turret UseBy(tvm.player );
	tvm.turret SetModel( tvm.turret_viewmodel_model );
	tvm.player DisableTurretDismount();
	tvm.turret MakeUnusable();

//	tvm.turret attach( tvm.viewmodel, "tag_player" );
	
	//JMCD - disabled for now - was rolling player's view a bit too much
//	level.player PlayerLinkedTurretAnglesEnable();
	
	flag_set( "player_on_blackhawkgun" );
	tvm.turret thread blackhawkgun_tracers(tvm.end_on);
//	tvm.turret thread blackhawkgun_shells(tvm.end_on);
	
	is_attacking = false;
	was_attacking = false;

	thread maps\_minigun_viewmodel::player_viewhands_minigun( tvm.turret, tvm.viewhands );
}

blackhawkgun_tracers( end_on )
{
	self endon( "death" );
	level endon( end_on );
	tracercount = 0;
	shotsbtntracers = 1;
	level endon( "player_off_blackhawkgun" );
	while( flag( "player_on_blackhawkgun" ) )
	{
		self waittill("missile_fire");
		tracercount = tracercount - 1;
		if (tracercount <= 0)
		{
			self handleTracer();
			tracercount = shotsbtntracers;
		}
		
	}
}

handleTracer()
{
	origin = self GetTagOrigin( "TAG_FLASH" );
	eyepos = level.player GetEye();
	forward = anglestoforward(level.player getplayerangles());
	tgtpos = eyepos + 12000*forward;
	startpos = eyepos + 60*forward;
	trace = BulletTrace( startpos, tgtpos, false );
	dest = trace["position"];
	//bullettracer( origin, dest, true );
	self thread play_fx_minigun();
}

play_fx_minigun()
{
	self endon( "death" );
	for(i=0;i<3;i++)
	{
		forward = anglestoforward(level.player getplayerangles());
		org = self GetTagOrigin( "TAG_FLASH" )+forward * 200;
		angles = level.player getplayerangles();
		//fx_origin linkto(self,"TAG_FLASH");
		playfx(getfx("minigun_projectile"),org,forward,(0,0,1));
		wait(.05);
	}
}

player_dismount_blackhawk_gun()
{
	//self ==> the vehicle being used by the player
	player_exit_turret_with_viewmodel(level.blackhawk_tvm);
	level.blackhawk_tvm.player unlink();
	level.blackhawk_tvm.player notify("unlink");

	level notify( "player_off_blackhawk_gun" );
	
	level.player AllowStand( true );
	level.player allowcrouch( true );
	level.player allowprone( true );
	level.player allowsprint( true );
	level.player allowjump( true );
	level.player DisableSlowAim();
}


player_lerped_onto_blackhawk_sideturret( nolerp )
{
	level.player AllowStand( false );
	level.player allowcrouch( true );
	level.player allowprone( false );
	level.player allowsprint( false );
	level.player allowjump( false );
	level.player EnableSlowAim( 0.6, 0.6 );	
	
	blackhawk_turret = level.player_blackhawk.mgturret[0];
	level.blackhawk_tvm = level.player_blackhawk setup_turret_with_viewmodel(blackhawk_turret, level.player, "tag_player_doorgun", undefined, 75, 75, 35, 45, "viewhands_player_udt");
	level.player_blackhawk thread player_use_turret_with_viewmodel( level.blackhawk_tvm );
	level.player_blackhawk swap_blackhawk_guns(true);

	level.onHeli = true;
}




// this is a level/turret specific setup
// the vehicle is passed in as self
setup_turret_with_viewmodel( turret, player, player_link_tag, viewmodel_tag, right_arc, left_arc, top_arc, bottom_arc, viewhands )
{
	tvm = spawnstruct();
	tvm.right_arc = right_arc;
	tvm.left_arc = left_arc;
	tvm.top_arc = top_arc;
	tvm.bottom_arc = bottom_arc;
	tvm.lerp_on = true;
	tvm.viewmodel_tag = viewmodel_tag;		// tag the viewmodel will link to
	tvm.viewhands = viewhands;
	tvm.player_tag = player_link_tag;
	tvm.vehicle = self;
	if (isdefined(turret))
	{
		turret.animname = "blackhawk_turret";
		turret.health = 99999;
		turret.is_occupied = false;
		if (isdefined(tvm.right_arc))
			AdjustBlackhawkPlayersViewArcs(tvm.right_arc, tvm.left_arc, tvm.top_arc, tvm.bottom_arc, 0);
		else
		{
			assert(0);
			player PlayerLinkToDelta( self, player_link_tag, 1 );
		}
	}
	//player EnableWeapons();
	tvm.turret = turret;								// which turret are we using
	tvm.player = player;								// for mp, we set save the player that is using this turret
	tvm.viewmodel = level.scr_model[ "player_rig" ];	// level needs to setup the appropriate rig
	tvm.end_on = "mortar_technical_hit";					// When the level is sent this notify, then the player_use thread will end
	if (isdefined(turret))
		tvm.turret_normal_model = turret.model;
	tvm.turret_viewmodel_model = "weapon_blackhawk_minigun_viewmodel";	// this needs to be viewmodel
	return tvm;
}




player_exit_turret_with_viewmodel( tvm )
{
	level notify(tvm.end_on);

	assert(tvm.turret.is_occupied);
	tvm.turret.is_occupied = false;
	tvm.turret MakeUsable();
	tvm.turret SetMode( "manual" );
	tvm.player EnableTurretDismount();
	tvm.turret MakeTurretInoperable();
	heli_crash_player_spot = getstruct( "heli_crash_player_spot", "targetname" );
	tvm.turret SetTurretDismountOrg( heli_crash_player_spot.origin );
	tvm.turret UseBy(tvm.player );
	tvm.turret SetModel( tvm.turret_normal_model );
	tvm.turret MakeUnusable();
}

AdjustBlackhawkPlayersViewArcs( right, left, top, bottom, time)
{
	player = level.player;
	if (!isdefined(player) || !isalive(player))
		return;
	if (!isdefined(player.right_view_arc) || (time <= 0))
	{	// snap to the requested values
		player.right_view_arc = right;
		player.left_view_arc = left;
		player.top_view_arc = top;
		player.bottom_view_arc = bottom;
		player PlayerLinkToDelta( level.player_blackhawk, "tag_player", 0.65, player.right_view_arc, player.left_view_arc, player.top_view_arc, player.bottom_view_arc );
	}
	else
	{
		player LerpViewAngleClamp(time, 0, 0, right, left, top, bottom);
	}
}

#using_animtree( "script_model" );
setup_carrier_blackhawk(blades_stopped)
{
	self.animname = "carrier_blackhawk";

	tag_turret_npc = "tag_turret_npc";
	self.turret_model = spawn("script_model", self gettagorigin(tag_turret_npc));
	self.turret_model setmodel("weapon_blackhawk_minigun");
	self.turret_model.angles = self gettagangles(tag_turret_npc);
	self.turret_model.origin = self gettagorigin(tag_turret_npc);
	self.turret_model LinkTo( self, tag_turret_npc, ( 0, 0, 0 ), ( 0, 0, 0 ) );
	while (!isdefined(self.mgturret))
		wait 0.05;
	self.turret_model.animname = "carrier_blackhawk";	// just so we use existing anims and animtrees
	self.turret_model setanimtree();
	/*
	idle_gun_anim = self getanim( "turret_gun_idle" );	// had to wait until other init completes
	self.turret_model setAnim( idle_gun_anim, 1, 0, 1 );	// put the world turret in a good anim state
	*/
	if (!isdefined(level.starting_on_blackhawk) || (level.starting_on_blackhawk == 0))
		self swap_blackhawk_guns(false);

}