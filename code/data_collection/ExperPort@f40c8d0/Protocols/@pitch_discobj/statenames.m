function [WaitForCPoke, WaitForSPoke, RewardStart, ItiStart] = statenames(obj)

GetSoloFunctionArgs;

[WaitForCPoke, WaitForSPoke, RewardStart, ItiStart] = statenames(value(super));

% Don't know if child will need to have more hard-coded state values here
% SSP 100605
