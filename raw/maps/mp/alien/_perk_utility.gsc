#include maps\mp\alien\_perkfunctions;

//////////////////////////////////////////////////////////////////////////////////////////
//    This file contains perk interface function for other components of the game mode  //
//////////////////////////////////////////////////////////////////////////////////////////

init_each_perk()
{
	self.perk_data = [];
	
	self.perk_data[ "health" ]      = init_perk_health();
	self.perk_data[ "money" ]       = init_perk_money();
	self.perk_data[ "quick_hands" ] = init_perk_quick_hands();
}

// === perk_money ===
perk_GetStartCurrency()         { return self.perk_data[ "money" ].start_currency; }
perk_GetCurrencyScalePerKill()  { return self.perk_data[ "money" ].currency_scale_per_kill; }
perk_GetCurrencyScalePerHive()  { return self.perk_data[ "money" ].currency_scale_per_hive; }

// === perk_health ===
perk_GetDamageReductionScaler() { return self.perk_data[ "health" ].damage_reduction_scaler; }

// === perk_quick_hands ===
perk_GetUseTimeScaler()         { return self.perk_data[ "quick_hands" ].use_time_scaler; }