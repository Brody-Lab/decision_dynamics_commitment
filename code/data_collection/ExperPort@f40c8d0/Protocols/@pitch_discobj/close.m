function [] = close(obj)

GetSoloFunctionArgs;

SidesSection(obj, 'delete');
ChordSection(obj, 'delete');
PokeMeasuresSection(obj, 'delete');
%delete(value(myfig));

