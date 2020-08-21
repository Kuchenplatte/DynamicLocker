/**
 * ExileClient_gui_lockerDialog_event_onDepositButtonClick
 *
 * Exile Mod
 * www.exilemod.com
 * © 2015 Exile Mod Team
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
 
private["_display", "_amountInput", "_alphabet", "_forbiddenCharacter", "_playerMoney", "_depositAmount", "_lockerLimit", "_lockerAmount", "_newLockerAmount", "_lockerLimitDisplay", "_prefixLimitDisplay"];
disableSerialization;
_display = uiNameSpace getVariable ["RscExileLockerDialog", displayNull];
_amountInput = ctrlText (_display displayCtrl 4006);
try
{
	if((count _amountInput) isEqualTo 0) then 
	{
		throw "Please enter a deposit amount.";
	};
	_alphabet = getText (missionConfigFile >> "CfgLocker" >> "numbersOnly");
	_forbiddenCharacter = [_amountInput, _alphabet] call ExileClient_util_string_containsForbiddenCharacter;
	if !(_forbiddenCharacter isEqualTo -1) then 
	{
		throw "Please enter only numbers.";
	};
	_playerMoney = player getVariable ["ExileMoney",0];
	_depositAmount = ceil (abs (parseNumber _amountInput));
	if (_playerMoney < _depositAmount) then
	{
		throw "You cannot deposit more pop tabs than you have.";
	};
	//_lockerLimit = (getNumber(missionConfigFile >> "CfgLocker" >> "maxDeposit"));
	_lockerLimit = ([ExileClientPlayerScore] call LL_getLockerLimit);

// Make numbers look better when large > 2 decimal places
_lockerLimitDisplay = _lockerLimit;
if( _lockerLimitDisplay > 999999 ) then { _lockerLimitDisplay = _lockerLimitDisplay / 1000000; _prefixLimitDisplay = "M" } else { _prefixLimitDisplay = "" };
_lockerLimitDisplay = [_lockerLimitDisplay,2] call BIS_fnc_cutDecimals;
// End number clean-up	
	
	_lockerAmount = player getVariable ["ExileLocker", 0];
	_newLockerAmount = _depositAmount + _lockerAmount;
	if (_lockerLimit < _newLockerAmount) then
	{
		throw format ["Your locker can only hold %1 %2 pop tabs.", _lockerLimitDisplay, _prefixLimitDisplay];
	};
	["lockerDepositRequest", [_amountInput]] call ExileClient_system_network_send;
}
catch
{
	["ErrorTitleAndText", ["Failed to deposit!", _exception]] call ExileClient_gui_toaster_addTemplateToast;
};
true