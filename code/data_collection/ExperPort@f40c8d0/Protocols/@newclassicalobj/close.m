function [] = close(obj)

GetSoloFunctionArgs;

PokesPlotSection(obj, 'delete');
SessionDefinition(obj, 'delete');
delete(value(myfig));

flush_solo(['@' class(obj)]);

clear functions;

