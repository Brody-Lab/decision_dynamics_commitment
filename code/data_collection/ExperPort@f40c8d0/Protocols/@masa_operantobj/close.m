function [] = close(obj)

GetSoloFunctionArgs;

ParamsSection(obj, 'delete');
ChordSection(obj, 'delete');
VpdsSection(obj, 'delete');
PokeDuration(obj, 'delete');
CurrentTrialPokesSubsection(obj, 'delete');
TrialEvents(obj, 'delete');
BeginnerSection(obj, 'delete');
delete(value(myfig));

