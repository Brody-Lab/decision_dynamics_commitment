function [x,y, BadBoySound, BadBoySPL, WN_SPL, ITISound, ITILength, ITIReinitPenalty, ...
TimeOutSound, TimeOutLength, TimeOutReinitPenalty, ...
ExtraITIonError, DrinkTime] = TimesSection(obj, action, x, y);


GetSoloFunctionArgs;

if nargin > 2
[x,y, BadBoySound, BadBoySPL, WN_SPL, ITISound, ITILength, ITIReinitPenalty, ...
TimeOutSound, TimeOutLength, TimeOutReinitPenalty, ...
ExtraITIonError, DrinkTime] = TimesSection(value(super), action, x, y);
else
    TimesSection(value(super), action);
end;
