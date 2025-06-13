% Function called when RPBox requests protocol('close')
%
% Santiago Jaramillo - 2007.05.14

function [] = close(obj)

GetSoloFunctionArgs;

%CurrentTrialPokesSubsection(obj, 'delete');
%SessionDefinition(obj, 'delete');
delete(value(myfig));

flush_solo(['@' class(obj)]);

clear functions;

