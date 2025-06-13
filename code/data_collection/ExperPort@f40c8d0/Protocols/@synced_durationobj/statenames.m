function [WaitForCPoke, WaitForSPoke, RewardStart, ItiStart] = statenames(obj)

GetSoloFunctionArgs;

WaitForCPoke = 58;
WaitForSPoke = 45;
RewardStart  = 160;
ItiStart     = 200;

% Don't know if child will need to have more hard-coded state values here
% SSP 100605
