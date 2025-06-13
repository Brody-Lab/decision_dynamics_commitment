function [] = close(obj)

GetSoloFunctionArgs;

 ChordSection(obj, 'delete');
% PokeMeasuresSection(obj, 'delete');
%delete(value(myfig));


% Delete everything owned by this object from the AutoSet register:
RegisterAutoSetParam(['@' class(obj)]);
% Delete everything owned by this object from the SoloFunction register:
SoloFunction(['@' class(obj)]);
% Delete all this object's SoloParamHandles:
delete_sphandle('owner', ['@' class(obj)]);
