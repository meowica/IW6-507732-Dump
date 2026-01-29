#include maps\mp\_utility;

////////////////////////////////////////
///           perk_money             ///
////////////////////////////////////////
DEFAULT_START_CURRENCY = 0;
DEFAULT_CURRENCY_SCALE_PER_KILL = 1.0;
DEFAULT_WALLET_SIZE = 6000;
DEFAULT_CURRENCY_SCALE_PER_HIVE = 1.0;
	
LEVEL_0_START_CURRENCY = 1000;
LEVEL_1_CURRENCY_SCALE_PER_KILL = 1.1;
LEVEL_2_WALLET_SIZE = 7000;
LEVEL_3_CURRENCY_SCALE_PER_HIVE = 1.1;
LEVEL_4_WALLET_SIZE = 8000;

init_perk_money()
{
	perk_data = spawnStruct();
	
	perk_data.start_currency          = DEFAULT_START_CURRENCY;
	perk_data.currency_scale_per_kill = DEFAULT_CURRENCY_SCALE_PER_KILL;
	perk_data.currency_scale_per_hive = DEFAULT_CURRENCY_SCALE_PER_HIVE;
	
	return perk_data;
}

set_perk_money_level_0()    
{ 
	self.perk_data[ "money" ].start_currency = LEVEL_0_START_CURRENCY; 
}

unset_perk_money_level_0()  
{ 
	self.perk_data[ "money" ].start_currency  = DEFAULT_START_CURRENCY; 
}

set_perk_money_level_1()    
{ 
	self.perk_data[ "money" ].start_currency  = LEVEL_0_START_CURRENCY;   
	
	self.perk_data[ "money" ].currency_scale_per_kill = LEVEL_1_CURRENCY_SCALE_PER_KILL; 
}

unset_perk_money_level_1()  
{ 
	self.perk_data[ "money" ].start_currency  = DEFAULT_START_CURRENCY;   
	
	self.perk_data[ "money" ].currency_scale_per_kill = DEFAULT_CURRENCY_SCALE_PER_KILL; 
}

set_perk_money_level_2()    
{ 
	self.perk_data[ "money" ].start_currency  = LEVEL_0_START_CURRENCY;
	self.perk_data[ "money" ].currency_scale_per_kill = LEVEL_1_CURRENCY_SCALE_PER_KILL; 
	
	self maps\mp\alien\_persistence::set_player_max_currency( LEVEL_2_WALLET_SIZE );
}

unset_perk_money_level_2()  
{ 
	self.perk_data[ "money" ].start_currency  = DEFAULT_START_CURRENCY;   
	self.perk_data[ "money" ].currency_scale_per_kill = DEFAULT_CURRENCY_SCALE_PER_KILL; 
	
	self maps\mp\alien\_persistence::set_player_max_currency( DEFAULT_WALLET_SIZE );
}

set_perk_money_level_3()    
{ 
	self.perk_data[ "money" ].start_currency  = LEVEL_0_START_CURRENCY; 
	self maps\mp\alien\_persistence::set_player_max_currency( LEVEL_2_WALLET_SIZE );
	
	self.perk_data[ "money" ].currency_scale_per_kill = LEVEL_3_CURRENCY_SCALE_PER_HIVE;
}

unset_perk_money_level_3()    
{ 
	self.perk_data[ "money" ].start_currency  = DEFAULT_START_CURRENCY;    
	self maps\mp\alien\_persistence::set_player_max_currency( DEFAULT_WALLET_SIZE );
	
	self.perk_data[ "money" ].currency_scale_per_kill = DEFAULT_CURRENCY_SCALE_PER_HIVE;
}

set_perk_money_level_4()    
{ 
	self.perk_data[ "money" ].start_currency  = LEVEL_0_START_CURRENCY; 
	self.perk_data[ "money" ].currency_scale_per_kill = LEVEL_3_CURRENCY_SCALE_PER_HIVE;
	
	self maps\mp\alien\_persistence::set_player_max_currency( LEVEL_4_WALLET_SIZE );
}

unset_perk_money_level_4()  
{ 
	self.perk_data[ "money" ].start_currency  = DEFAULT_START_CURRENCY;    
	self.perk_data[ "money" ].currency_scale_per_kill = DEFAULT_CURRENCY_SCALE_PER_HIVE;
	
	self maps\mp\alien\_persistence::set_player_max_currency( DEFAULT_WALLET_SIZE );
}

////////////////////////////////////////
///           perk_health            ///
////////////////////////////////////////
// <TODO J.C.> Directly changing player's max health is causing some ill effects.  No time to investigate at the moement.
//             Additionally, the LUI health bar's max width is hard coded right no.  Increasing the maxhealth is also causing 
//             the health bar to not display correctly.  As a potentially temp solution, reduce the damages that the player
//             is taking based on the upgrade level.
DEFAULT_DAMAGE_REDUCTION_SCALER = 1.0;
LEVEL_0_DAMAGE_REDUCTION_SCALER = 0.91;  // 1 / 1.1
LEVEL_1_DAMAGE_REDUCTION_SCALER = 0.83;  // 1 / 1.2
LEVEL_2_DAMAGE_REDUCTION_SCALER = 0.77;  // 1 / 1.3
LEVEL_3_DAMAGE_REDUCTION_SCALER = 0.71;  // 1 / 1.4
LEVEL_4_DAMAGE_REDUCTION_SCALER = 0.67;  // 1 / 1.5

init_perk_health()
{
	perk_data = spawnStruct();
	
	perk_data.damage_reduction_scaler = DEFAULT_DAMAGE_REDUCTION_SCALER;
	
	return perk_data;
}

set_perk_health_level_0()
{
	self.perk_data[ "health" ].damage_reduction_scaler = LEVEL_0_DAMAGE_REDUCTION_SCALER;
}

unset_perk_health_level_0()
{
	self.perk_data[ "health" ].damage_reduction_scaler = DEFAULT_DAMAGE_REDUCTION_SCALER;
}

set_perk_health_level_1()
{
	self.perk_data[ "health" ].damage_reduction_scaler = LEVEL_1_DAMAGE_REDUCTION_SCALER;
}

unset_perk_health_level_1()
{
	self.perk_data[ "health" ].damage_reduction_scaler = DEFAULT_DAMAGE_REDUCTION_SCALER;
}

set_perk_health_level_2()
{
	self.perk_data[ "health" ].damage_reduction_scaler = LEVEL_2_DAMAGE_REDUCTION_SCALER;
}

unset_perk_health_level_2()
{
	self.perk_data[ "health" ].damage_reduction_scaler = DEFAULT_DAMAGE_REDUCTION_SCALER;
}

set_perk_health_level_3()
{
	self.perk_data[ "health" ].damage_reduction_scaler = LEVEL_3_DAMAGE_REDUCTION_SCALER;
}

unset_perk_health_level_3()
{
	self.perk_data[ "health" ].damage_reduction_scaler = DEFAULT_DAMAGE_REDUCTION_SCALER;
}

set_perk_health_level_4()
{
	self.perk_data[ "health" ].damage_reduction_scaler = LEVEL_4_DAMAGE_REDUCTION_SCALER;
}

unset_perk_health_level_4()
{
	self.perk_data[ "health" ].damage_reduction_scaler = DEFAULT_DAMAGE_REDUCTION_SCALER;
}

////////////////////////////////////////
///        perk_quick_hands          ///
////////////////////////////////////////
DEFAULT_USE_TIME_SCALER = 1.0;
LEVEL_1_USE_TIME_SCALER = 0.7;

init_perk_quick_hands()
{
	perk_data = spawnStruct();
	
	perk_data.use_time_scaler = DEFAULT_USE_TIME_SCALER;
	
	return perk_data;
}

set_perk_quick_hands_level_0()
{
	self givePerk( "specialty_quickswap", false );
}

unset_perk_quick_hands_level_0()
{
	self _unsetPerk( "specialty_quickswap" );
}

set_perk_quick_hands_level_1()
{
	self givePerk( "specialty_quickswap", false );
	
	self.perk_data[ "quick_hands" ].use_time_scaler = LEVEL_1_USE_TIME_SCALER;
}

unset_perk_quick_hands_level_1()
{
	self _unsetPerk( "specialty_quickswap" );
	
	self.perk_data[ "quick_hands" ].use_time_scaler = DEFAULT_USE_TIME_SCALER;
}

set_perk_quick_hands_level_2()
{
	self givePerk( "specialty_quickswap", false );
	self.perk_data[ "quick_hands" ].use_time_scaler = LEVEL_1_USE_TIME_SCALER;
	
	self givePerk( "specialty_quickdraw", false );
}

unset_perk_quick_hands_level_2()
{
	self _unsetPerk( "specialty_quickswap" );
	self.perk_data[ "quick_hands" ].use_time_scaler = DEFAULT_USE_TIME_SCALER;
	
	self _unsetPerk( "specialty_quickdraw" );
}

set_perk_quick_hands_level_3()
{
	self givePerk( "specialty_quickswap", false );
	self.perk_data[ "quick_hands" ].use_time_scaler = LEVEL_1_USE_TIME_SCALER;
	self givePerk( "specialty_quickdraw", false );
	
	self setaimspreadmovementscale( 0.5 );
}

unset_perk_quick_hands_level_3()
{
	self _unsetPerk( "specialty_quickswap" );
	self.perk_data[ "quick_hands" ].use_time_scaler = DEFAULT_USE_TIME_SCALER;
	self _unsetPerk( "specialty_quickdraw" );
	
	self setaimspreadmovementscale( 1.0 );
}

set_perk_quick_hands_level_4()
{
	self givePerk( "specialty_quickswap", false );
	self.perk_data[ "quick_hands" ].use_time_scaler = LEVEL_1_USE_TIME_SCALER;
	self givePerk( "specialty_quickdraw", false );
	self setaimspreadmovementscale( 0.5 );
	
	self givePerk( "specialty_fastreload", false );
}

unset_perk_quick_hands_level_4()
{
	self _unsetPerk( "specialty_quickswap" );
	self.perk_data[ "quick_hands" ].use_time_scaler = DEFAULT_USE_TIME_SCALER;
	self _unsetPerk( "specialty_quickdraw" );
	self setaimspreadmovementscale( 1.0 );
	
	self _unsetPerk( "specialty_fastreload" );
}

////////////////////////////////////////
///          perk_fast_legs          ///
////////////////////////////////////////
set_perk_fast_legs_level_0()
{
	self.moveSpeedScaler = 1.08;
}

unset_perk_fast_legs_level_0()
{
	self.moveSpeedScaler = 1.0;
}

set_perk_fast_legs_level_1()
{
	self.moveSpeedScaler = 1.08;
	
	self givePerk( "specialty_stalker", false );
}

unset_perk_fast_legs_level_1()
{
	self.moveSpeedScaler = 1.0;
	
	self _unsetPerk( "specialty_stalker" );
}

set_perk_fast_legs_level_2()
{
	self.moveSpeedScaler = 1.08;
	self givePerk( "specialty_stalker", false );
	
	self givePerk( "specialty_fastsprintrecovery", false );
}

unset_perk_fast_legs_level_2()
{
	self.moveSpeedScaler = 1.0;
	self _unsetPerk( "specialty_stalker" );
	
	self _unsetPerk( "specialty_fastsprintrecovery" );
}

set_perk_fast_legs_level_3()
{
	self.moveSpeedScaler = 1.12;
	self givePerk( "specialty_stalker", false );
	self givePerk( "specialty_fastsprintrecovery", false );
}

unset_perk_fast_legs_level_3()
{
	self.moveSpeedScaler = 1.0;
	self _unsetPerk( "specialty_stalker" );
	self _unsetPerk( "specialty_fastsprintrecovery" );
}

set_perk_fast_legs_level_4()
{
	self.moveSpeedScaler = 1.12;
	self givePerk( "specialty_stalker", false );
	self givePerk( "specialty_fastsprintrecovery", false );
	
	self givePerk( "specialty_marathon", false );
}

unset_perk_fast_legs_level_4()
{
	self.moveSpeedScaler = 1.0;
	self _unsetPerk( "specialty_stalker" );
	self _unsetPerk( "specialty_fastsprintrecovery" );
	
	self _unsetPerk( "specialty_marathon" );
}
