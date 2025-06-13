function [] = close(obj)

GetSoloFunctionArgs;

CurrentTrialPokesSubsection(obj, 'delete');
SessionDefinition(obj, 'delete');
delete(value(myfig));

flush_solo(['@' class(obj)]);

clear functions;
