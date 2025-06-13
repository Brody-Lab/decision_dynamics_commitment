function [] = close(obj)

GetSoloFunctionArgs;

ChordSection(obj, 'delete');
PokeMeasuresSection(obj, 'delete');
delete(value(myfig));

